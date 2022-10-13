ORG 0
BITS 16 ; Define that the assembler will use 16 bytes.
jmp 0x7c0:start
start:
    cli ; Clear and disable interrupts.
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti ; Enable interrupts
    mov si, msg ; Save the address of msg label to Source index.
    call print
    jmp $ ; infinite loop, jump to it self.


print:
    mov bx, 0
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