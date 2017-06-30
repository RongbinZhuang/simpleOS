BOOT:=boot.asm
LDR:=loader.asm
BOOT_BIN:=$(subst .asm,.bin,$(BOOT))
LDR_BIN:=$(subst .asm,.bin,$(LDR))

.PHONY : everything

everything : $(BOOT_BIN) $(LDR_BIN) kernel
	dd if=$(BOOT_BIN) of=a.img bs=512 count=1 conv=notrunc
	sudo mount a.img /mnt/floppy/ -o loop
	sudo cp $(LDR_BIN) /mnt/floppy/ -v
	sudo cp kernel.bin /mnt/floppy/ -v
	sudo umount /mnt/floppy/
	

clean :
	rm -f $(BOOT_BIN) $(LDR_BIN)

$(BOOT_BIN) : $(BOOT)
	nasm $< -o $@

$(LDR_BIN) : $(LDR)
	nasm $< -o $@

hello:hello.asm
	nasm -f elf64 hello.asm -o hello.o
	ld -s hello.o -o hello
	./hello

fix:foo.asm bar.cpp
	nasm -f elf32 foo.asm -o foo.o
	g++ -m32 -c bar.cpp -o bar.o
	ld -m elf_i386 -o foobar foo.o bar.o
	./foobar

kernel:kernel.asm
	nasm -f elf32 $< -o kernel.o
	ld -Ttext 0x30400 -m elf_i386 kernel.o -o kernel.bin
