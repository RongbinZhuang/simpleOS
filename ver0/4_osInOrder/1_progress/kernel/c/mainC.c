#include "mainC.h"

int mainC()
{
	disp_str((char*)"mainC entered\n");

	TASK*		p_task		= task_table;
	PROCESS*	p_proc		= proc_table;
	char*		p_task_stack	= task_stack + STACK_SIZE_TOTAL;
	u16		selector_ldt	= SELECTOR_LDT_FIRST;
	int i;
	for(i=0;i<NR_TASKS;i++){
		strcpy(p_proc->p_name, p_task->name);	// name of the process
		p_proc->pid = i;			// pid

		p_proc->ldt_sel = selector_ldt;

		memcpy(&p_proc->ldts[0], &gdt[SELECTOR_KERNEL_CS >> 3],
		       sizeof(DESCRIPTOR));
		p_proc->ldts[0].attr1 = DA_C | PRIVILEGE_TASK << 5;
		memcpy(&p_proc->ldts[1], &gdt[SELECTOR_KERNEL_DS >> 3],
		       sizeof(DESCRIPTOR));
		p_proc->ldts[1].attr1 = DA_DRW | PRIVILEGE_TASK << 5;
		p_proc->regs.cs	= ((8 * 0) & SA_RPL_MASK & SA_TI_MASK)
			| SA_TIL | RPL_TASK;
		p_proc->regs.ds	= ((8 * 1) & SA_RPL_MASK & SA_TI_MASK)
			| SA_TIL | RPL_TASK;
		p_proc->regs.es	= ((8 * 1) & SA_RPL_MASK & SA_TI_MASK)
			| SA_TIL | RPL_TASK;
		p_proc->regs.fs	= ((8 * 1) & SA_RPL_MASK & SA_TI_MASK)
			| SA_TIL | RPL_TASK;
		p_proc->regs.ss	= ((8 * 1) & SA_RPL_MASK & SA_TI_MASK)
			| SA_TIL | RPL_TASK;
		p_proc->regs.gs	= (SELECTOR_KERNEL_GS & SA_RPL_MASK)
			| RPL_TASK;

		p_proc->regs.eip = (u32)p_task->initial_eip;
		p_proc->regs.esp = (u32)p_task_stack;
		p_proc->regs.eflags = 0x1202; /* IF=1, IOPL=1 */

		p_task_stack -= p_task->stacksize;
		p_proc++;
		p_task++;
		selector_ldt += 1 << 3;
	}

	proc_table[0].ticks=proc_table[0].priority=150;
	proc_table[1].ticks=proc_table[1].priority=50;
	proc_table[2].ticks=proc_table[2].priority=30;

	k_reenter = 0;
	ticks=0;

	p_proc_ready	= proc_table;

	disable_irq(CLOCK_IRQ);
	irq_table[CLOCK_IRQ]=clock_handler;
	enable_irq(CLOCK_IRQ);

	out_byte(TIMER_MODE,RATE_GENERATOR);
	out_byte(TIMER0,(u8) (TIMER_FREQ/HZ));
	out_byte(TIMER0,(u8) ((TIMER_FREQ/HZ)>>8));

	clearScreen();

	restart();
	
	while(1);
	return 0;
}

void TestA()
{
	int i=0;
	while(1)
	{
		//disp_int(get_ticks());
		disp_str((char*)"A.");
		//disp_int(i++);
		milli_delay(100);
	}
}

void TestB()
{
	int i=0;
	while(1)
	{
		disp_str((char*)"B.");
		//disp_int(i++);
		milli_delay(100);
		//delay(1);
	}
}

void TestC()
{
	int i=0;
	while(1)
	{
		disp_str((char*)"C.");
		//disp_int(i++);
		milli_delay(100);
		//delay(1);
	}
}
