#include "bootpack.h"
#include "int.h"
//#include "hankaku.h"
#include "printf.h"
#include "fifo.h"
#include "graphics.h"
#include "dsctbl.h"
//#include <stdio.h>
//#include <stdarg.h>

#define PORT_KEYDAT             0x0060
#define PORT_KEYSTA             0x0064
#define PORT_KEYCMD             0x0064
#define KEYSTA_SEND_NOTREADY    0x02
#define KEYCMD_WRITE_MODE       0x60
#define KBC_MODE                0x47

#define KEYCMD_SENDTO_MOUSE		0xd4
#define MOUSECMD_ENABLE			0xf4

void wait_KBC_sendready(void);
void enable_mouse(void);
void init_keyboard(void);

int read_mem8(int addr);
void write_mem8(int addr, int data);
int read_cr0(void);
void io_hlt(void);
void io_cli(void);
void io_out8(int port,  int data);
int io_load_eflags(void);
void io_store_eflags(int eflags);

extern struct FIFO8 keyfifo;
void Main(void)
{

    struct BOOTINFO *binfo = (struct BOOTINFO *)ADR_BOOTINFO;
    int num , mx, my, count, i;
    char s[40], mcursor[256];
    char keybuf[40];
	init_gdtidt();
	init_pic();
    io_sti();

    init_palette();
    init_screen(binfo->vram, binfo->scrnx, binfo->scrny);
    mx = (binfo->scrnx - 16)/2;
    my = (binfo->scrny -28 - 16)/2;
    init_mouse_cursor8(mcursor, COL8_008484);
    putblock8_8(binfo->vram, binfo->scrnx, 16, 16, mx, my, mcursor, 16);

    io_out8(PIC0_IMR,  0xf9);    // PIC1とキーボードを許可
    io_out8(PIC1_IMR,  0xef);    // マウスを許可))

    fifo8_init(&keyfifo, 32,  keybuf);
    for (;;) {
        io_cli();
        if (fifo8_status(&keyfifo) == 0){
            io_stihlt();
        }else{
            i = fifo8_get(&keyfifo);
            init_screen(binfo->vram, binfo->scrnx, binfo->scrny);
            io_sti();
            lsprintf(s, "%x",  i);
            putfont8_asc(binfo->vram,  binfo->scrnx,  0,  16,  COL8_FFFFFF,  s);
        }
    }
}
void init_keyboard(void)
{
    wait_KBC_sendready();
    io_out8(PORT_KEYCMD,  KEYCMD_WRITE_MODE);
    wait_KBC_sendready();
    io_out8(PORT_KEYDAT,  KBC_MODE);
    return;
}
void wait_KBC_sendready(void)
{
    /* Waiting for keyboard get ready */
    for (;;) {
            if ((io_in8(PORT_KEYSTA) & KEYSTA_SEND_NOTREADY) == 0) {
                        break;
                    }
        }
    return;
}
void enable_mouse(void)
{
    wait_KBC_sendready();
    io_out8(PORT_KEYCMD,  KEYCMD_SENDTO_MOUSE);
    wait_KBC_sendready();
    io_out8(PORT_KEYDAT,  MOUSECMD_ENABLE);
    return;
}
