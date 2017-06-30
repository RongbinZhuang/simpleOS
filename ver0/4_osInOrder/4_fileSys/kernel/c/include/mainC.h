#ifndef _MY_MAIN_H
#define _MY_MAIN_H

#include "type.h"
#include "global.h"

extern DESCRIPTOR gdt[];

extern void* memcpy(void* p_dst,void* p_src,int iSize);
extern void disp_str(char *);
extern void disp_int(int);
extern void delay(int);
extern void restart();
extern void strcpy(char*,char*);
extern void enable_irq(int);
extern void disable_irq(int );
extern void clock_handler(int );
extern int sys_get_ticks();
extern int get_ticks();
extern void	out_byte(u16 port, u8 value);
extern void milli_delay(int);
extern void clearScreen();
extern void init_keyboard();
extern void task_tty();
extern void init_clock();
extern int sys_write(char*,int ,PROCESS*);
extern void write(char* buf,int len);
extern int printf(const char*,...);
extern int sendrec(int function, int src_dest, MESSAGE* p_msg);
extern int printx(char* str);
extern void task_sys();
extern int	sys_sendrec(int function, int src_dest, 
		MESSAGE* m, struct proc* p);
extern int	sys_printx(int _unused1, int _unused2, 
		char* s, struct proc * p_proc);
extern void assertion_failure(char *exp, char *file, 
		char *base_file, int line);
extern int	send_recv(int function, int src_dest, MESSAGE* msg);
extern void	reset_msg(MESSAGE* p);



extern irq_handler irq_table[];

int mainC();
void TestA();
void TestB();
void TestC();

u32		k_reenter;
u32		ticks;
TTY		tty_table[NR_CONSOLES];
PROCESS	proc_table[NR_TASKS + NR_PROCS];
TSS tss;
PROCESS* p_proc_ready;
char task_stack[STACK_SIZE_TOTAL];

TASK	task_table[NR_TASKS] = 
	{
		{task_tty, STACK_SIZE_TTY, "tty"}
		,{task_sys, STACK_SIZE_SYS, "SYS"}
	};

TASK    user_proc_table[NR_PROCS] = 
	{
		{TestA, STACK_SIZE_TESTA, "TestA"},
		{TestB, STACK_SIZE_TESTB, "TestB"},
		{TestC, STACK_SIZE_TESTC, "TestC"}
	};

system_call sys_call_table[NR_SYS_CALL]=
	{
		(system_call)sys_get_ticks
	//	,(system_call)sys_write
		,(system_call)sys_printx
		,(system_call)sys_sendrec
	};


#endif
