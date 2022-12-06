CODE_SEG equ gdt_code_segment_discriptor - gdt_start
DATA_SEG equ gdt_data_segment_discriptor - gdt_start

; Export the DATA_SEG variable to be able to use it from another asm files.
global DATA_SEG

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
