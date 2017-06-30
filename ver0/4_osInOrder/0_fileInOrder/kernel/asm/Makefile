#constant
ENTRYPOINT=		0x30400
ENTRYOFFSET=	0x400

#dir used
OBJDIR:=		../libobj/
MAINDIR:= 		../

#src and target file
KERNELSRC:=		kernel.asm
KERNELOBJ:=		../$(subst .asm,.o,$(KERNELSRC))
MEMLIBSRC:= 	memLibA.asm
MEMLIBOBJ:=		$(OBJDIR)$(subst .asm,.o,$(MEMLIBSRC))
DISPLIBSRC:= 	dispLibA.asm
DISPLIBOBJ:=	$(OBJDIR)$(subst .asm,.o,$(DISPLIBSRC))

SRCS:=			$(subst $(KERNELSRC), ,$(wildcard *.asm))
OBJS:= 			$(patsubst %.asm,$(OBJDIR)%.o,$(SRCS))

#program flags 
ASM:=			nasm
ASMFLAGS:= 		-f elf32 -I inc/ 
DASMFLAGS:= 	-u -o $(ENTRYPOINT) -e $(ENTRYOFFSET)

target:$(KERNELOBJ) $(OBJS)

$(KERNELOBJ):$(KERNELSRC)
	$(ASM) $(ASMFLAGS) -o $@ $<

$(MEMLIBOBJ):$(MEMLIBSRC)
	$(ASM) $(ASMFLAGS) -o $@ $<

$(DISPLIBOBJ):$(DISPLIBSRC)
	$(ASM) $(ASMFLAGS) -o $@ $<

$(OBJDIR)ioLibA.o:ioLibA.asm
	$(ASM) $(ASMFLAGS) -o $@ $<



