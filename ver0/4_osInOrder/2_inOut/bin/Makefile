#dir 
BINDIR:=	bin/
MOUNTDIR:=	/mnt/floppy

#src and target file 
IMG:= 		ver1.img
BOOT:=		boot.bin
LOADER:=	loader.bin
KERNEL:= 	kernel.bin

#flags for action
ASM=		nasm
CC=			gcc
LD=			ld
DASM=		ndisasm
DD=			dd

ASMKFLAGS=	-f elf32
CFLAGS=		-c -fno-builtin -m32 -fno-stack-protector
LDFLAGS= 	-s -Ttext $(ENTRYPOINT) -m elf_i386
DASMFLAGS= 	-u -o $(ENTRYPOINT) -e $(ENTRYOFFSET)
DDFLAGS= 	bs=512 count=1 conv=notrunc

.PHONY: clean buildImg

target:subtarget buildImg

subtarget:
	make -C boot/
	make -C kernel/

buildImg:$(IMG) $(BINDIR)$(LOADER) $(BINDIR)$(KERNEL)
	sudo mount -o loop $(IMG) $(MOUNTDIR)
	sudo cp $(BINDIR)$(LOADER) $(MOUNTDIR)
	sudo cp $(BINDIR)$(KERNEL) $(MOUNTDIR)
	sudo umount $(MOUNTDIR)

$(IMG):$(BINDIR)$(BOOT)
	$(DD) if=$< of=$@ $(DDFLAGS)

clean:
	make -C kernel/ clean
	rm -f bin/*.*

