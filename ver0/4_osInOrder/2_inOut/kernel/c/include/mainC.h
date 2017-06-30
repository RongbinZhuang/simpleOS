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

extern irq_handler irq_table[];

int mainC();
void TestA();
void TestB();
void TestC();

u32		k_reenter;
u32		ticks;
PROCESS	proc_table[NR_TASKS + NR_PROCS];
TSS tss;
PROCESS* p_proc_ready;
char task_stack[STACK_SIZE_TOTAL];

TASK	task_table[NR_TASKS] = {
	{task_tty, STACK_SIZE_TTY, "tty"}};

TASK    user_proc_table[NR_PROCS] = {
	{TestA, STACK_SIZE_TESTA, "TestA"},
	{TestB, STACK_SIZE_TESTB, "TestB"},
	{TestC, STACK_SIZE_TESTC, "TestC"}};

system_call sys_call_table[NR_SYS_CALL]=
			{
				(system_call)sys_get_ticks
				,(system_call)sys_write
			};


#endif
