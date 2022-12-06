/* Read more on https://sourceware.org/binutils/docs/ld/. */

/* _start is default entry point name. */
ENTRY(_start)
OUTPUT_FORMAT(binary)
SECTIONS
{
	/* Set the place where the kernel will be loaded in memory, 1M = 1024 * 1024 = 100000h. */
	/* After linking the origin will start at 1M, that means at address 100000h. */
	. = 1M;
	/* The section where code will be kept. */
	.text : {
		*(.text)
	}
	/* Same as .data section but for variables that do not change. */
	.rodata : {
		*(.rodata)
	}
	/* The section where we declare initialized variables and constants. */
	.data : {
		*(.data)
	}
	/* In this section uninitialized variables get stored. */
	.bss : {
		/* In the COMMON section uninitialized and unallocated variables get stored. */
		/* Common symbols only exist in object files, not in executable files. The idea
		 * of COMMON symbols in Unix is to allow multiple external definitions of a
		 * same variable (in different compilation units)
		 * under a single common symbol under certain conditions. */
		*(COMMON)
		/* In the .bss section uninitialized allocated variables get stored */
		*(.bss)
	}
}
