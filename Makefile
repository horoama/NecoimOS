OSNAME=os

ASRC=./src/asm
CSRC=./src/c
SRC=./src
OBJ=./obj
LS=./ls

IMG=$(OSNAME).img
OSSYS=$(OBJ)/$(OSNAME).sys
IPL=$(OBJ)/ipl.bin
BOOTPAK=$(OBJ)/boot.bin

BINOPT=-nostdlib -Wl,--oformat=binary
QEMUOPT=-m 32 -localtime -vga std -fda

$(IMG) : $(OSSYS) $(IPL)
	mformat -f 1440 -C -B $(IPL) -i $(IMG) ::
	mcopy $(OSSYS) -i $(IMG) ::

$(OSSYS) : $(ASRC)/head.s $(ASRC)/func.s $(CSRC)/bootpack.c
	#as   --32  $(ASRC)/head.s -o $(OBJ)/asmhead.bin
	gcc  -m32 $(ASRC)/head.s -nostdlib -T$(LS)/asmhead.ls -o $(OBJ)/asmhead.bin
	#gcc -Tlnk.ls -c -g -Wa,-a,-ad $(ASRC)/head.s > asmhead.ls
	#as   --32 $(ASRC)/font.s -o $(OBJ)/font.o
	gcc  -m32 $(CSRC)/bootpack.c  $(BINOPT) -c -o $(OBJ)/boot.o
	gcc  -m32 $(CSRC)/printf.c  $(BINOPT) -c -o $(OBJ)/printf.o
	gcc  -m32 $(CSRC)/graphics.c  $(BINOPT) -c -o $(OBJ)/graphics.o
	as    --32 $(ASRC)/func.s -o $(OBJ)/func.o
	ld    -m elf_i386 -T$(LS)/main.ls -e Main --oformat=binary -o $(OBJ)/boot.bin $(OBJ)/boot.o $(OBJ)/func.o $(OBJ)/printf.o $(OBJ)/graphics.o
	cat $(OBJ)/asmhead.bin $(OBJ)/boot.bin > $(OSSYS)

$(IPL) : $(ASRC)/ipl.s
	gcc $(ASRC)/ipl.s -nostdlib -T$(LS)/ipl.ls -o $(IPL)
	#gcc -Tlnk.ls -c -g -Wa,-a,-ad $(ASRC)/ipl.s > ipl.ls

#$(BOOTPAK) : boot.o func.o font.o
#	ld -Tmain.ls -m elf_i386 -o $@ $^

run        : $(IMG)
	qemu-system-i386 $(QEMUOPT) $(IMG)
debug    : $(IMG)
	    qemu-system-i386 -s -S $(QEMUOPT) $(IMG) -redir tcp:5555:127.0.0.1:1234 &
img			:;make $(IMG)
clean		:;
	rm obj/*
	rm os.img
