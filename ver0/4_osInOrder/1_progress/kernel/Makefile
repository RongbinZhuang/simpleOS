#const
ENTRYPOINT=	0x30400
ENTRYOFFSET=0x400

#dir used
OBJDIR:=	../bin/
SRCDIR:= 	libobj/

#file used
SRC=		$(wildcard $(SRCDIR)*.o)
MAINSRC= 	$(wildcard *.o)

#program & flags
KERNEL:=	$(OBJDIR)kernel.bin
LD=			ld

LDFLAGS= 	-s -Ttext $(ENTRYPOINT) -m elf_i386

DASMFLAGS= 	-u -o $(ENTRYPOINT) -e $(ENTRYOFFSET)

target:$(KERNEL)

subtarget:
	make -C asm/
	make -C c/

$(KERNEL):subtarget $(MAINSRC) $(SRC)
	$(LD) $(LDFLAGS) -o $@ $(MAINSRC) $(SRC)

.PHONY:clean

clean:
	rm -f $(wildcard $(SRCDIR)*.*)
