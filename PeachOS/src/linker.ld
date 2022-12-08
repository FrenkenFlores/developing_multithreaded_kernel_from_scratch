/* Read more on https://sourceware.org/binutils/docs/ld/. */

/* _start is default entry point name that the GNU ld uses. */
ENTRY(_start)
OUTPUT_FORMAT(binary)
SECTIONS
{
	/* Set the place where the kernel will be loaded in memory, 1M = 1024 * 1024 = 100000h. */
	/* After linking the origin will start at 1M, that means at address 100000h. */
	. = 1M;
	/* The section where code will be kept. Align by 16 bits. */
	.text : ALIGN(4096) {
		*(.text)
	}
	/* Same as .data section but for variables that do not change. */
	.rodata : ALIGN(4096) {
		*(.rodata)
	}
	/* The section where we declare initialized variables and constants. */
	.data : ALIGN(4096) {
		*(.data)
	}
	/* In this section uninitialized variables get stored. */
	.bss : ALIGN(4096) {
		/* In the COMMON section uninitialized and unallocated variables get stored. */
		/* Common symbols only exist in object files, not in executable files. The idea
		 * of COMMON symbols in Unix is to allow multiple external definitions of a
		 * same variable (in different compilation units)
		 * under a single common symbol under certain conditions. */
		*(COMMON)
		/* In the .bss section uninitialized allocated variables get stored */
		*(.bss)
	}
	/* When assembly compiled code gets integrated with C compiled code
	it may cuse an alignment issue, that will harm the memory address in
	the binary file, that is why it is safer to store the assembly code
	after the C code, except for the kernel, it should be compiler first. */
	.asm : ALIGN(4096) {
		*(.asm)
	}
}
