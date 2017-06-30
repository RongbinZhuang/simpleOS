#ifndef _MY_PROCLIB_H
#define _MY_PROCLIB_H

#include "global.h"
#include "type.h"

//extern function
	extern char* itoa(char*,int);
	extern void disp_int(int);
	extern void disp_str(char *);
	extern void init_descriptor(DESCRIPTOR * p_desc, 
			u32 base, u32 limit, u16 attribute);
	extern void	memset(void* p_dst, char ch, int size);

//extern varibale
	extern DESCRIPTOR gdt[];
	extern TSS tss;

//local define function
	u32 seg2phys(u16 seg);

extern	PROCESS*	p_proc_ready;

extern PROCESS		proc_table[NR_TASKS];

char		task_stack[STACK_SIZE_TOTAL];
//
//TASK	task_table[NR_TASKS] = {{TestA, STACK_SIZE_TESTA, "TestA"},
//			{TestB, STACK_SIZE_TESTB, "TestB"},
//			{TestC, STACK_SIZE_TESTC, "TestC"}};
//
//irq_handler		irq_table[NR_IRQ];
//
//system_call		sys_call_table[NR_SYS_CALL] = {sys_get_ticks};
//                     




#endif

