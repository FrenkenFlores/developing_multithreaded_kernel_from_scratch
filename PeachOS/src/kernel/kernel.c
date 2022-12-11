#include "kernel.h"
#include <stddef.h>
#include <stdint.h>


// Video buffer is a segment of memory that is mapped as video memroy.
// VGA supports various modes, one of them is the Color text mode.
// Color text mode is mapped to 0xB8000, writing to that memory will
// change the ouput on screem.
uint16_t *video_mem;
uint16_t video_col;
uint16_t video_row;

void init_terminal() {
    video_mem = (uint16_t *)(0XB8000);
    video_col = 0;
    video_row = 0;
    // Clean the screem from BIOS output.
    for (int y = 0; y < VGA_HEIGHT; y++) {
        for (int x = 0; x < VGA_WIDTH; x++) {
            // The output on the screen is defined by two bytes, the top 8 bits
            // represent the color, the lower 8 bits that character in ASCI format.
            video_mem[x + y * VGA_WIDTH] = (uint16_t)((0 << 8) | ' ');
        }
    }
}

int strlen(char *str) {
    int i = 0;
    while (str[i]) {
        i++;
    }
    return i;
}

void print_char(char c) {
    if (c == '\n') {
        video_row += 1;
        video_col = 0;
        return;
    }
    video_mem[video_col + video_row * VGA_WIDTH] = (uint16_t)((15 << 8) | c);
    video_col += 1;
}

void print_str(char *str) {
    int i = 0;
    int len = strlen(str);
    while (i < len) {
        print_char(str[i++]);
    }
    return;
}

void kernel_main() {
    init_terminal();
    print_str("Hello, World!");
}
