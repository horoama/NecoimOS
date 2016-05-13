struct FIFO8 {
    unsigned char *buf;
    //p: next_w
    // q: next_r
    // size:  buffer size
    // free:  size of the free bytes in the buffer
    // flags: flag "no free space"
    int p,  q,  size,  free,  flags;
};
void fifo8_init(struct FIFO8 *fifo, int size, unsigned char *buf);
int fifo8_put(struct FIFO8 *fifo,  unsigned char data);
int fifo8_get(struct FIFO8 *fifo);
int fifo8_status(struct FIFO8 *fifo);
