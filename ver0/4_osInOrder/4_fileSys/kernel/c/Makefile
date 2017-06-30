#dir
OBJDIR:=		../libobj/

#src and target file
SRC=			$(wildcard *.c)
OBJ=			$(patsubst %.c,$(OBJDIR)%.o,$(SRC))

#program flags
CC=				gcc
CFLAGS= 		-c -m32 -fno-builtin -fno-stack-protector -Wall
CLIBS=			-I include/ 

target:$(OBJ)

#$(OBJ):$(SRC)
#	$(CC) $(CFLAGS) -o $@ $< $(CLIBS)

$(OBJDIR)start.o:start.c
	$(CC) $(CFLAGS) -o $@ $< $(CLIBS)

$(OBJDIR)initLibC.o:initLibC.c
	$(CC) $(CFLAGS) -o $@ $< $(CLIBS)

$(OBJDIR)dispLibC.o:dispLibC.c
	$(CC) $(CFLAGS) -o $@ $< $(CLIBS)

$(OBJDIR)mainC.o:mainC.c
	$(CC) $(CFLAGS) -o $@ $< $(CLIBS)

$(OBJDIR)procLibC.o:procLibC.c
	$(CC) $(CFLAGS) -o $@ $< $(CLIBS)

$(OBJDIR)timerLibC.o:timerLibC.c
	$(CC) $(CFLAGS) -o $@ $< $(CLIBS)

$(OBJDIR)keyboardLibC.o:keyboardLibC.c
	$(CC) $(CFLAGS) -o $@ $< $(CLIBS)

$(OBJDIR)tty.o:tty.c
	$(CC) $(CFLAGS) -o $@ $< $(CLIBS)

$(OBJDIR)consoleC.o:consoleC.c
	$(CC) $(CFLAGS) -o $@ $< $(CLIBS)

$(OBJDIR)printf.o:printf.c
	$(CC) $(CFLAGS) -o $@ $< $(CLIBS)

$(OBJDIR)piplineComm.o:piplineComm.c
	$(CC) $(CFLAGS) -o $@ $< $(CLIBS)

$(OBJDIR)systask.o:systask.c
	$(CC) $(CFLAGS) -o $@ $< $(CLIBS)

$(OBJDIR)debugC.o:debugC.c
	$(CC) $(CFLAGS) -o $@ $< $(CLIBS)

$(OBJDIR)hd.o:hd.c
	$(CC) $(CFLAGS) -o $@ $< $(CLIBS)

$(OBJDIR)fileSys.o:fileSys.c
	$(CC) $(CFLAGS) -o $@ $< $(CLIBS)


