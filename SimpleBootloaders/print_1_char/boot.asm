ORG 0x07c00 ; The address that the BIOS will execute from the bootloader.
BITS 16 ; Define that the assembler will use 16 bytes.

start:
    ; calling BIOS routine (http://www.ctyme.com/intr/rb-0106.htm).
    mov ah, 0eh ; 0eh is the command that will print char from al register.
    mov al, 'A' ; The character to write.
    mov bx, 0
    int 0x10 ; Call interrupt (video - teletype output).

    jmp $ ; infinite loop, jump to it self.

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