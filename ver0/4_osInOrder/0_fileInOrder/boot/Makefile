#dir used
OBJDIR:=../bin/

#src and target file
BOOTSRC:=		boot.asm
LOADERSRC:=		loader.asm
BOOT:=$(OBJDIR)$(subst .asm,.bin,$(BOOTSRC))
LOADER:=$(OBJDIR)$(subst .asm,.bin,$(LOADERSRC))

#program flags 
ASM:=		nasm
ASMFLAGS:= 	-I inc/

target:$(BOOT) $(LOADER)

$(BOOT):$(BOOTSRC)
	$(ASM) $(ASMFLAGS) -o $@ $<

$(LOADER):$(LOADERSRC)
	$(ASM) $(ASMFLAGS) -o $@ $<

