extern int read_mem8(int addr);
extern void write_mem8(int addr, int data);
extern int read_cr0(void);
extern void io_hlt(void);
extern void io_cli(void);
extern void io_out8(int port,  int data);
extern int io_load_eflags(void);
extern void io_store_eflags(int eflags);


