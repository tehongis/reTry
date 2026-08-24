#ifndef FONT_H
#define FONT_H
#include "rocket68.h"

void font_init(u8* mem_ptr, u32 fb_start_addr, int fb_width, int fb_height);
void framebuffer_clear(void);
void framebuffer_scroll_up(void);
void framebuffer_print_char(char c);
void font_update_cursor(void); // UUSI RIVI

#endif
