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

main:
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
	jmp $

times 510 - ( $ - $$ ) db 0
db 0x55
db 0xAA
