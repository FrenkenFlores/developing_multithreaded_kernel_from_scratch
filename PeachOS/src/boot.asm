; Specify target processor mode. Real mode uses 16 bit mode.
BITS 16
; The CPU will load the bootloader from the 0x7c0 address.
; That's why our bootloader should start from this address.
ORG 0x7c00
; Set the BIOS parameter block that takes the first 36 bytes.
; This block holds information about the hard drive, the BIOS
; do read/write operations on this block, this may harm our code
; that is why we set offset our main bootloader code.
init:
	jmp short _start
	nop
; Add zeros to the last 33 bytes.
times 33 db 0

%include "./gdt.asm"


global _start
; _start is default entry point name that the GNU ld uses.
_start:
.init_interrupts:
	; Before entering the protected mode we must disable interrupts.
	cli
	; Reset registers, different BIOS systems and CPU may set different
	; initial valuse to the general use registers.
	mov ax, 0x00
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7c00
	; Enable interrupts.
	sti
.load_protected_mode:
	cli; disable interrupts.
	lgdt [gdt_descriptor]; Load GDT register with start address of Global Descriptor Table.
	mov eax, cr0; Copy value from the control register cr0 register to the general eax register
	; to execute the OR logical operation.
	or al, 0x1; Set PE (Protection Enable) bit in CR0 (Control Register 0).
	mov cr0, eax; Give the cr0 register the return value.
	; Perform far jump to selector 10h (offset into GDT, pointing at a 32bit PM code segment descriptor) 
	; to load CS with proper PM32 descriptor)
	jmp CODE_SEG:protected_mode32

BITS 32
protected_mode32:
	; Set the starting sector we will load from. 0 is the boot sector. LBA.
	mov eax, 1
	; The total amount of sectors we will load.
	mov ecx, 100
	; The memory address where we will load it (1M = 1024 * 1024 = 100000h)
	mov edi, 100000h
	; Call the driver that will load sectors including the kernel.
	call ata_lba_read
	; Jump to the location where we loaded our kernel.
	jmp CODE_SEG:0x100000



; To use the IDENTIFY command, select a target drive by sending 0xA0
; for the master drive, or 0xB0 for the slave, to the "drive select" IO port.
; On the Primary bus, this would be port 0x1F6. Then set the Sectorcount, LBAlo,
; LBAmid, and LBAhi IO ports to 0 (port 0x1F2 to 0x1F5). Then send the IDENTIFY
; command (0xEC) to the Command IO port (0x1F7). Then read the Status
; port (0x1F7) again. If the value read is 0, the drive does not exist.
; For any other value: poll the Status port (0x1F7) until bit 7
; (BSY, value = 0x80) clears. Because of some ATAPI drives that do
; not follow spec, at this point you need to check the LBAmid and LBAhi ports
; (0x1F4 and 0x1F5) to see if they are non-zero. If so, the drive is not ATA,
; and you should stop polling. Otherwise, continue polling one of the Status
; ports until bit 3 (DRQ, value = 8) sets, or until bit 0 (ERR, value = 1) sets.
; At that point, if ERR is clear, the data is ready to read from the Data port (0x1F0).
; Read 256 16-bit values, and store them.
ata_lba_read:
	; Send 0xE0 for the "master" or 0xF0 for the "slave", ORed with the
	; highest 4 bits of the LBA to port 0x1F6: outb(0x1F6, 0xE0 | (slavebit << 4) | ((LBA >> 24) & 0x0F))
	; Specify the port that is used to select the target drive.
	; Drive select I/O port.
	mov dx, 0x1F6
	; backup LBA.
	mov ebx, eax
	; Shift eax 24 bits to the right, that will leave in al
	; the highest LBA 8 bits. (LBA >> 24).
	shr eax, 24
	; Select the master drive.
	or eax, 0xE0
	; Write the LBA highest 8 bits to the port.
	; With the out command we talk to the bus on the motherboard.
	out dx, al

	; Then set the Sectorcount, LBAlo, LBAmid, and LBAhi IO ports to 0 (port 0x1F2 to 0x1F5)
	; 0x1F2 is the port that reads the number of sectors to read.
	; Send the sectorcount to port 0x1F2: outb(0x1F2, (unsigned char) count)
	mov dx, 0x1F2
	mov eax, ecx
	shr eax, 24
	; Send the total sectors to read.
	out dx, al

	; Send the 8 low bits of the LBA.
	; Send the low 8 bits of the LBA to port 0x1F3: outb(0x1F3, (unsigned char) LBA))
	mov dx, 0x1F3
	mov eax, ebx
	out dx, al

	; Send the 8 mid bits of the LBA.
	; Send the next 8 bits of the LBA to port 0x1F4: outb(0x1F4, (unsigned char)(LBA >> 8))
	mov dx, 0x1F4
	mov eax, ebx
	shr eax, 8
	out dx, al
	
	; Send the 8 high bits of the LBA.
	; Send the next 8 bits of the LBA to port 0x1F5: outb(0x1F5, (unsigned char)(LBA >> 16))
	mov dx, 0x1F5
	mov eax, ebx
	shr eax, 16
	out dx, al

	; Send the "READ SECTORS" command (0x20) to port 0x1F7: outb(0x1F7, 0x20)
	mov dx, 0x1F7
	mov al, 0x20
	out dx, al

; Read all sectors into memroy.
.next_sector:
	; Store ecx on stack to save it. The ecx register is used by the assembler loop
	; command, it will dicrement it every iteration until it reaches 0.
	; Loop uses ecx as a loop counter.
	push ecx
; Check if we need to read.
.try:
	mov dx, 0x1F7
	; Status Register, it has 8 bits: ERR, IDX, CORR, DRQ, SRV, DF, RDY, BSY.
	; Read the Regular Status port until bit 7 (BSY, value = 0x80) clears, and bit 3
	; (DRQ, value = 8) sets -- or until bit 0 (ERR, value = 1) or bit 5 (DF, value = 0x20) sets.
	; If neither error bit is set, the device is ready right then.
	in al, dx
	; DRQ is set when the drive has PIO data to transfer, or is ready to accept PIO data.
	; Check if DRQ bit is set to 8. If it is, then set ZF to 1.
	test al, 8
	; Check if ZF is set to 1, if it is, then jump back to try.
	jz .try
; Read if we are ready to do so.
.read:
	; Transfer 256 16-bit values (512 bytes) (Read 256 words at a time.), a uint16_t at a time,
	; into your buffer rom I/O port 0x1F0. (In assembler, REP INSW works well for this.)
	mov ecx, 256
	mov dx, 0x1F0
	; Input word from I/O port specified in DX into memory location specified in ES:(E)DI.
	; Our EDI is pointing to 0x100000 memory address where our kernel should be loaded.
	; Do rep insw 256 times.
	rep insw
	pop ecx
	loop .next_sector
	; Return from the routine.
	ret
; Fill the rest of the sector with zeros.
times 510 - ( $ - $$ ) db 0
; Put the boot sector end signature.
db 0x55
db 0xAA
