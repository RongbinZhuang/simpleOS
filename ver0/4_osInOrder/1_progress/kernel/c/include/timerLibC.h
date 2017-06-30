#ifndef _MY_TIMERLIB_H
#define _MY_TIMERLIB_H

#include "type.h"
#include "global.h"

extern void disp_str(char* );
extern int get_ticks();
extern void schedule();

extern PROCESS* p_proc_ready;
extern PROCESS proc_table[];
extern u32 k_reenter;
extern u32 ticks;

void delay(int );
void clock_handler(int );
int sys_get_ticks();
void milli_delay(int milli_sec);

#endif
