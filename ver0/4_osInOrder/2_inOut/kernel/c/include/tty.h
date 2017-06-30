#ifndef _MY_TTY_H
#define _MY_TTY_H

#include "type.h"
#include "global.h"

int nr_current_console;

TTY		tty_table[NR_CONSOLES];
CONSOLE		console_table[NR_CONSOLES];

extern void keyboard_read();
extern void disp_str(char*);
extern void disp_int(u32);
extern void disable_int();
extern void enable_int();
extern void out_byte(u16,u32);
extern void init_keyboard();
extern void keyboard_read(TTY*);
extern int is_current_console(CONSOLE*);
extern void out_char(CONSOLE* p_con,char ch);
extern void select_console(int );
extern void init_screen(TTY*);
extern int dwDispPos;
extern void scroll_screen(CONSOLE* p_con, int direction);

int sys_write(char* buf, int len, PROCESS* p_proc);
void tty_write(TTY*,char*,int);
void task_tty();
void in_process(TTY*,u32 key);

#endif
