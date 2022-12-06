BITS 32

; Import the data segment.
EXTERN DATA_SEG

; Protected mode (32-bit mode).
; _start is default entry point name that the GNU ld uses.
_start:
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
