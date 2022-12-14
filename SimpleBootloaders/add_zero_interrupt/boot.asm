ORG 0
BITS 16 ; Define that the assembler will use 16 bytes.


; Some BIOS systems use USB FFD (Floppy Flash Drive)
; (not USB HDD - Hard Disk Drive, or something else) emulation
; which gives them the ability to interpret USB flash drive as hard disk drive.
; The BIOS expect the BPB at the begining of the sector (512 bytes), it finds it
; and then proceed to modify the BPB after it is loaded into memory to reflect the drive geometry.
; The BIOS Parameter Block is the block that holds all info about the Master Boot Record sector.
; read https://wiki.osdev.org/FAT for information.
; By adding a fake BPB which consists of 36 bytes, it should overwrite it with the actual values.
; If we don't add BPB it will overwrite first 36 bytes including our bootloader code.

; The first 3 bytes of the BPB.
init:
    ; jump over the BPB to the code.
    jmp short main
    nop
; The last 33 bytes of the BPB.
times 33 db 0; Create a fake BIOS Prameter Block

main:
    ; 0x7c00 is the segment address that the BIOS will execute from the bootloader.
    ; The actual location of the beginning of a segment in the linear address space
    ; can be calculated with segment×16: 0x7c0 * 0x10 = 0x7c00
    ; 0x7c0 is the logical address, it is generated by the CPU,
    ; it is used as a reference to access the physical memory location by CPU.
    jmp 0x7c0:start

; Create a Division by zero interrupt. We will overwrite the adderss of the
; zero handler in the IVT by the address of our intterrupt. Call int 0.
; By default the int 0 is an exception that gets called when we deivde by zero:
; mov ax, 0x00
; div ax
handle_zero:
    mov ah, 0eh
    mov al, '0'
    ; Print 0.
    int 0x10

handle_one:
    mov ah, 0eh
    mov al, '1'
    ; Print 1
    int 0x10

start:
    ; Different CPU can initialize registers differently, there is no garentee that
    ; they will be set correctly, that is why its important to init them by ourselves.

    ; Clear and disable interrupts, they use these registers and we don't want
    ;interrrupts to bother us while initailizing them.
    cli
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti ; Enable interrupts
    ; Handle int 0.
    ; Overwrite the Interrupt Vector Table (IVT).
    ; every vector (element) in the IVT consists of OFFSET (4 bytes, 16 bit): SEGMENT (4 bytes, 16 bit).
    ; Move 16 bit hex representation of handle_zero to the stack (RAM) address 0x00 which will be the offset.
    ; Note, by adding ss:0xNN we specify the stack segment, ds:0xNN - data segment, etc.
    ; Note, mov word[...], n - moves the 16-bit hex representation of n to [...].
    mov word[ss:0x00], handle_zero
    ; Move the logical address of the segment that the BIOS will start bootloader from.
    ; 0x7c00 is the physical address that the bootloader gets loaded from, 0x7c00 / 0x10 = 0x7c0
    ; is the logical address that reference that physical address.
    ; The physical address of the handler will be addressed by 0x7c0:hex_representation_of_handle_zero pair.
    mov word[ss:0x02], 0x7c0

    ; Handle int 1.
    mov word[ss:0x04], handle_one
    mov word[ss:0x06], 0x7c0

    ; Call interrupt 0.
    mov ax, 0x00
    div ax
    ; Or use:
    int 0
    ; Call interrupt 1.
    int 1

    mov si, msg ; Save the address of msg label to Source index.
    call print
    jmp $ ; infinite loop, jump to it self.


print:
    mov bx, 0
; Note, in NASM period (., dot) is used for local labels, you also can access them globally by
; lable_name.local_lable, like print.done, etc.
.loop:
    ; (http://www.jaist.ac.jp/iscenter-new/mpc/altix/altixdata/opt/intel/vtune/doc/users_guide/mergedProjects/analyzer_ec/mergedProjects/reference_olh/mergedProjects/instructions/instruct32_hh/vc161.htm)
    lodsb ; Load one string byte from the place where si is pointing to in al register.
    cmp al, 0
    je .done
    call print_char
    jmp .loop
.done:
    ret


print_char:
    mov ah, 0eh ; choose 0eh command that will print char from al register.
    int 0x10 ; call interrupt.
    ret


msg: db 'Hello, World!', 0 ; write msg and terminate by 0 at this address.

times 510 - ($ - $$) db 0   ; Fill at least 510 bytes of data.
; $ points to current line, $$ points to the begining of the section,
; ($ - $$) tells us how far we are in the current section.
; To find out how much bytes left to fill the segment with 510 bytes, we must substract.
dw 0xAA55 ; Add the boot signature. It should be 0x55AA, but Intel are little endian.
; BIOS will look for this signature in all storages, once it find it,
; it will load the bootloader that haves that signature.
; dw and db put the word or byte into the file as binary.

; We choose the bin (binary) type because the processor will run this file,
; the processor has no concept of executable files.
; nasm -f bin ./boot.asm -o ./boot.bin

; Check the binary file by executing: ndisasm ./boot.bin
; Run the bootloader by executing: qemu-system-x86_64 -hda ./boot.bin
