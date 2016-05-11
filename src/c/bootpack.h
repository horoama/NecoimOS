extern int read_mem8(int addr);
extern void write_mem8(int addr, int data);
extern int read_cr0(void);
extern void io_hlt(void);
extern void io_cli(void);
extern void io_out8(int port,  int data);
extern int io_load_eflags(void);
extern void io_store_eflags(int eflags);
extern void io_sti(void);
extern void io_cli(void);
extern void load_gdtr(int limit, int addr);
extern void load_idtr(int limit, int addr);
#define ADR_BOOTINFO    0x00000ff0
struct BOOTINFO{
    char cyls,  leds,  vmode,  reserve;
    short scrnx,  scrny;
    char *vram;
};


