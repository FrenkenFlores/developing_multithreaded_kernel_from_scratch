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
	jmp short main
	nop
; Add zeros to the last 33 bytes.
times 33 db 0

CODE_SEG equ gdt_code_segment_discriptor - gdt_start
DATA_SEG equ gdt_data_segment_discriptor - gdt_start

; The BIOS in protected mode use Global Discriptor Tables to
; access memory. Memory gets defined by segment discriptors
; which are a part from the GDT. Our GDT will have a simple structure:
; - null segment discriptor
; - data segment discriptor
; - code segment discriptor

; Create a lable to address this part of memory.
; This will be used to calculate the size of the GDT.
gdt_start:
; A null segment descriptor (eight 0-bytes).
; This is required as a safety mechanism to catch errors
; where our code forgets to select a memory segment,
; thus yielding an invalid segment as the default one.
gdt_null_segment_discriptor:
	dd 0x00
	dd 0x00

; DS, SS, ES, FS, GS should be pointing at this label.
gdt_data_segment_discriptor:; 0x10 offset.
	; A 20-bit value, tells the maximum addressable unit, either in 1 byte units,
	; or in 4KiB pages. Hence, if you choose page granularity and set the Limit value
	; to 0xFFFFF the segment will span the full 4 GiB address space in 32-bit mode.
	dw 0xFFFF; [0:15]
	; Base 16 bit.
	dw 0x00; [16:31]
	; Base 8 bit.
	db 0x00; [32:39]
	; Access byte. E (Exicutable bit) for data segment is 0.
	db 10010010b; [40:47]
	db 11001111b; flags (4 bits) + segment length, bits 16-19, [48:55]
	db 0x0       ; segment base, bits 24-31, [56:63]

; The code and data segment discriptors will be the same.
; CS should be pointing at this label.
gdt_code_segment_discriptor:; 0x08 offset
	dw 0xFFFF; [0:15]
	; Base 16 bit.
	dw 0x00; [16:31]
	; Base 8 bit.
	db 0x00; [32:39]
	; Access byte. E (Exicutable bit) for data segment is 1.
	db 10011010b; [40:47]
	db 11001111b; flags (4 bits) + segment length, bits 16-19, [48:55]
	db 0x0       ; segment base, bits 24-31, [56:63]

# This is the second label that will be used to compute.
gdt_end:

; Setup a GDT descriptor. The descriptor contains both the GDT
; location (memory address) as well as its size.
gdt_descriptor:
    dw gdt_end - gdt_start - 1; size (16 bit)
    dd gdt_start; address (32 bit)

main:
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
.init_registers:
	; Setup all segment registers (ds, ss, es, fs, gs) to point to our single 4 GB data segment.
	mov ax, DATA_SEG
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	; Set the stack pointer to point somewhere in the memory.
	mov ebp, 0x00200000
	mov esp, ebp
; The A20 Line address is the physical representation of the 20-st bit (started count from 0, bit number 21).
; It is disabled by default, we should enable it so we can access all memroy in protected mode.
.enable_a20_line:
	in al, 0x92; Read from CPU bus.
	mov al, 2; Enable A20.
	out 0x92, al; Write to CPU bus.

	jmp $


times 510 - ( $ - $$ ) db 0
db 0x55
db 0xAA
