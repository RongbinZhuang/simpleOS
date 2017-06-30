#ifndef _MY_PROCLIB_H
#define _MY_PROCLIB_H

#include "global.h"
#include "type.h"

void init_descriptor(DESCRIPTOR *p_desc,u32 base,u32 limit,u16 attribute);
u32 seg2phys(u16 seg);
void schedule();

extern void disp_str(char*);
extern void*	memcpy(void* p_dst, void* p_src, int size);
extern void	memset(void* p_dst, char ch, int size);

extern DESCRIPTOR gdt[];
extern PROCESS proc_table[];
extern TSS tss;
extern PROCESS* p_proc_ready;
extern char	task_stack[];


#endif

