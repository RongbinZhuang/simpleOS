#ifndef _MY_SYSTASK_H
#define _MY_SYSTASK_H
#include "type.h"
#include "global.h"

extern void disp_str(char*);
extern int	sendrec(int function, int src_dest, MESSAGE* p_msg);
extern int	send_recv(int function, int src_dest, MESSAGE* msg);
extern void panic(const char *fmt, ...);

extern u32 ticks;

void task_sys();

#endif
