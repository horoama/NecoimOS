int intToHex(char *str, int num){
    char hex[17] = "0123456789ABCDEF";
    int i;
    str[0]='0';str[1]='x';
    for(i=0;i<8;i++){
      str[1+8-i] = hex[((num >> i*4) & 0x0000000f)];
    }
    str[14] = '\0';
    return 1;
}
void strcls(char *str) {
    while(*str != '\0') *str++ = '\0';
}
int lsprintf(char *str, const char *fmt, ...){
    int *arg = (int *)(&str + 2);
    int cnt, i, argc = 0;
    char buf[20];
    const char *p = fmt;

    for (cnt = 0;*p != '\0'; p++){
        if(*p == '%'){
            strcls(buf);
            if(p[1] == 'x'){
                intToHex(buf, arg[argc++]);
            }
            for(i = 0;buf[i] != '\0';i++, cnt++) *str++ = buf[i];
            p++;
        }else{
            *str++ = *p;cnt++;
        }
    }
    return cnt;
}
