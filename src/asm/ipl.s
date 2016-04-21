.intel_syntax noprefix
.equ CYLS,  10
.text
.code16
    jmp entry

    .byte 0x90
    .ascii "HELLOIPL"
    .word 512
    .byte 1
    .word 1
    .byte 2
    .word 224
    .word 2880
    .byte 0xf0
    .word 9
    .word 18
    .word 2
    .int 0
    .int 2880
    .byte 0, 0, 0x29
    .int 0xffffffff
    .ascii "HELLO-OS   "
    .ascii "FAT12   "
.skip 18,  0x00

entry:
    mov ax,  0x0
    mov ss,  ax
    mov sp, word ptr 0x7c00
    mov ds,  ax
    mov es,  ax

    mov ax, word ptr 0x0820
    mov es, ax
    mov ch, 0x00
    mov dh, 0x00
    mov cl, 0x02
readloop:
    mov si, 0x00
retry:
    mov ah, 0x02
    mov al, 0x01
    xor bx, bx
    mov dl, 0x00
    int 0x13
    jnc next
    add si, 0x01
    cmp si, 0x05
    jae error
    mov ah, 0x00
    mov dl, 0x00
    int 0x13
    jmp retry
next:
    mov ax, es
    add ax, 0x0020
    mov es, ax
    add cl, 0x01
    cmp cl, 18
    jbe readloop

    mov cl, 0x01
    add dh, 0x01
    cmp dh, 0x02
    jb readloop
    mov dh, 0x00
    add ch, 0x01
    cmp ch, byte ptr CYLS
    jb readloop
_load_fin:
    mov byte ptr  [0x0ff0], CYLS
    jmp 0xc200

error:
    mov si, load_err
    call print
_error_fin:
    hlt
    jmp _error_fin

print:
    mov al, [si]
    add si, 1
    cmp al, 0
    je  _print_fin
    mov ah, 0x0e
    mov bx, 15
    int 0x10
    jmp print
_print_fin:
    ret

load_err:
    .ascii "load error"
    .byte 0x00
.org 510
    .byte 0x55, 0xaa


