//#include "bootpack.h"
//#include "hankaku.h"
#include "printf.h"
#include "graphics.h"
#include "dsctbl.h"
//#include <stdio.h>
//#include <stdarg.h>

int read_mem8(int addr);
void write_mem8(int addr, int data);
int read_cr0(void);
void io_hlt(void);
void io_cli(void);
void io_out8(int port,  int data);
int io_load_eflags(void);
void io_store_eflags(int eflags);

struct BOOTINFO{
    char cyls, leds, vmode, reserve;
    short scrnx, scrny;
    char *vram;
};
void Main(void)
{

    struct BOOTINFO *binfo = (struct BOOTINFO *)0x0ff0;
    int num , mx, my, count;
    char s[40], mcursor[256];
    init_palette();
	init_gdtidt();

    init_screen(binfo->vram, binfo->scrnx, binfo->scrny);
    mx = (binfo->scrnx - 16)/2;
    my = (binfo->scrny -28 - 16)/2;
    init_mouse_cursor8(mcursor, COL8_008484);
    lsprintf(s,"hoge = %x.%x",10, 255);
    putfont8_asc(binfo->vram, binfo->scrnx, 30, 30, COL8_00FF00, s);
    putblock8_8(binfo->vram, binfo->scrnx, 16, 16, mx, my, mcursor, 16);

    for (;;) {
        io_hlt();
    }
}

