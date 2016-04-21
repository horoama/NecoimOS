.intel_syntax noprefix
.file "func.s"
.arch i486
.code32
.globl io_hlt,io_cli, io_sti,io_stihlt, write_mem8, read_mem8
.globl read_cr0
.globl io_in8,  io_in16,  io_in32
.globl io_out8,  io_out16,  io_out32
.globl io_load_eflags,  io_store_eflags


.text
write_mem8:
    mov ecx, [esp+4]
    mov al, [esp+8]
    mov [ecx], al
    ret
read_mem8:
    mov ecx, [esp+4]
    xor eax, eax
    mov al, [ecx]
    ret
read_cr0:
    mov eax, cr0
    ret
# HLT
io_hlt:
    hlt
    ret
io_cli:
    cli
    ret
io_sti:
    sti
    ret
io_stihlt:
    sti
    hlt
    ret
io_in8:
    mov edx, [esp+4]
    mov eax, 0
    in al, dx
    ret
io_in16:
    mov edx, [esp+4]
    mov eax, 0
    in al, dx
    ret
io_in32:
    mov edx, [esp+4]
    in eax, dx
    ret
io_out8:
   	mov		edx,dword ptr [esp+4]		# PORT
   	mov		al,byte ptr [esp+8]		# DATA
   	out	    dx, al
   	ret

io_out16:	# void io_out16(int port, int data)#
   	mov		edx,[esp+4]		# PORT
   	mov		eax,[esp+8]		# DATA
   	out		dx,ax
   	ret

io_out32:	# void io_out32(int port, int data)#
   	mov		edx,[esp+4]		# PORT
   	mov		eax,[esp+8]		# DATA
   	out		dx,eax
   	ret

io_load_eflags:	# int io_load_eflags(void)#
   	pushf		# push eflags ?ƃ????ӗ?
   	pop		eax
   	rET

io_store_eflags:	# void io_store_eflags(int eflags)#
   	mov		eax,dword ptr [esp+4]
   	push	eax
   	popf		# pop eflags ?ƃ????ӗ?
   	ret
