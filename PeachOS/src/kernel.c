#include "kernel.h"

void kernel_main() {
    // Text mode.
    // Characters gets stored in the memory, then
    // The video card prints them on the screen.
    char *vmem_ptr = (char*)(0XB8000);
    // Each character takes 2 bytes, the first stores the letter.
    vmem_ptr[0] = 'A';
    // The second stores the color.
    vmem_ptr[1] = 2;
}