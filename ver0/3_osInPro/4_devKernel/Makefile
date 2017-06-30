#const
#ENTRYPOINT=	0x30400
ENTRYPOINT=	0x30400

ENTRYOFFSET=0x400

#file used
IMG=		ver1.img
BOOT=		boot.asm
BOOTBIN=		boot.bin
LOADER= 	loader.asm
LOADERBIN= 	loader.bin
KERNEL= 	kernel.asm
KERNELBIN= 	kernel.bin
KERNELOBJ= 	kernel.o
OBJ= 		string.o start.o kliba.o i8259.o global.o protect.o klib.o

#dir used
MOUNTDIR= 	/mnt/floppy

#program & flags
	ASM=		nasm
	CC=			gcc
	LD=			ld
	DASM=		ndisasm
	DD=			dd

	ASMBFLAGS=
	ASMKFLAGS=	-f elf32
	CFLAGS=		-c -fno-builtin -m32 -fno-stack-protector
	LDFLAGS= 	-s -Ttext $(ENTRYPOINT) -m elf_i386
	DASMFLAGS= 	-u -o $(ENTRYPOINT) -e $(ENTRYOFFSET)
	DDFLAGS= 	bs=512 count=1 conv=notrunc

.PHONY: clean buildImg

target:buildImg

buildImg:$(IMG) $(LOADERBIN) $(KERNELBIN)
	sudo mount -o loop $(IMG) $(MOUNTDIR)
	sudo cp $(LOADERBIN) $(MOUNTDIR)
	sudo cp $(KERNELBIN) $(MOUNTDIR)
	sudo umount $(MOUNTDIR)
$(IMG):$(BOOTBIN)
	$(DD) if=$< of=$@ $(DDFLAGS)
#bin 

$(BOOTBIN):$(BOOT)
	$(ASM) $(ASMBFLAGS) -o $@ $<
$(LOADERBIN):$(LOADER)
	$(ASM) $(ASMBFLAGS) -o $@ $<
$(KERNELBIN):$(KERNELOBJ) $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $^

#obj
$(KERNELOBJ):$(KERNEL)
	$(ASM) $(ASMKFLAGS) -o $@ $<
string.o:string.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<
kliba.o:kliba.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<
start.o:start.c type.h const.h protect.h proto.h global.h
	$(CC) $(CFLAGS) -o $@ $<
i8259.o:i8259.c type.h const.h protect.h proto.h
	$(CC) $(CFLAGS) -o $@ $<
global.o:global.c type.h const.h protect.h proto.h global.h
	$(CC) $(CFLAGS) -o $@ $<
protect.o:protect.c type.h const.h protect.h global.h proto.h
	$(CC) $(CFLAGS) -o $@ $<
klib.o:klib.c type.h const.h protect.h proto.h string.h global.h
	$(CC) $(CFLAGS) -o $@ $<
clean:
	rm 	-f 	$(wildcard *.bin) $(wildcard *.o)
	

