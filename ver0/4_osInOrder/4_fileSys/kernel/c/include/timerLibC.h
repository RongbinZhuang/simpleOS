#ifndef _MY_TIMERLIB_H
#define _MY_TIMERLIB_H

#include "type.h"
#include "global.h"

extern void disp_str(char* );
extern int get_ticks();
extern void schedule();
extern void put_irq_handler(int irq, irq_handler handler);
extern void enable_irq(int);


extern PROCESS* p_proc_ready;
extern PROCESS proc_table[];
extern u32 k_reenter;
extern u32 ticks;

void delay(int );
void clock_handler(int );
int sys_get_ticks();
void milli_delay(int milli_sec);
void init_clock();
void out_byte(u16,u32);

#endif
