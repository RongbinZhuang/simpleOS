#include "timerLibC.h"

void delay(int time)
{
	for(int i=0;i<time;i++)
		for(int j=0;j<10;j++)
			for(int k=0;k<10000;k++);
}

void clock_handler(int irq)
{
	//disp_str((char*)"~");
	ticks++;
	p_proc_ready->ticks--;
	if(k_reenter!=0) return ;
	if(p_proc_ready->ticks>0)return;
	schedule();
}

int sys_get_ticks()
{
	return ticks;
}

void milli_delay(int milli_sec)
{
        int t = get_ticks();
        while(((get_ticks() - t) * 1000 / HZ) < milli_sec) {}
}

void init_clock()
{
	/* 初始化 8253 PIT */
	out_byte(TIMER_MODE, RATE_GENERATOR);
	out_byte(TIMER0, (u8) (TIMER_FREQ/HZ) );
	out_byte(TIMER0, (u8) ((TIMER_FREQ/HZ) >> 8));

	put_irq_handler(CLOCK_IRQ, clock_handler);    /* 设定时钟中断处理程序 */
	enable_irq(CLOCK_IRQ);                        /* 让8259A可以接收时钟中断 */
}


