#ifndef _MY_CONSOLE_H
#define _MY_CONSOLE_H

#include "type.h"
#include "global.h"


extern CONSOLE console_table[];
extern int nr_current_console;
extern int dwDispPos;
extern void disable_int();
extern void enable_int();
extern void out_byte(u16,u32);
extern TTY tty_table[];

void scroll_screen(CONSOLE* p_con, int direction);
int is_current_console(CONSOLE* p_con);
void out_char(CONSOLE* p_con,char);


#endif
