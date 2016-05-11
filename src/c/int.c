#include "bootpack.h"
#include "int.h"
#include "graphics.h"
#include "dsctbl.h"

#define PORT_KEYDAT     0x0060

void init_pic(void)
{
    io_out8(PIC0_IMR,   0xff  );
    io_out8(PIC1_IMR,   0xff  );

    io_out8(PIC0_ICW1,  0x11  );
    io_out8(PIC0_ICW2,  0x20  );
    io_out8(PIC0_ICW3,  1 << 2);
    io_out8(PIC0_ICW4,  0x01  );

    io_out8(PIC1_ICW1,  0x11  );
    io_out8(PIC1_ICW2,  0x28  );
    io_out8(PIC1_ICW3,  2     );
    io_out8(PIC1_ICW4,  0x01  );

    io_out8(PIC0_IMR,   0xfb  );
    io_out8(PIC1_IMR,   0xff  );

    return;
}

void inthandler21(int *esp)
{
    struct BOOTINFO *binfo = (struct BOOTINFO *) ADR_BOOTINFO;
    unsigned char data,  s[4];

    boxfill8(binfo->vram,  binfo->scrnx,  COL8_008484,  0,  16,  15,  31);
    putfont8_asc(binfo->vram,  binfo->scrnx,  0,  16,  COL8_FFFFFF,  "intr");

    return ;
}
