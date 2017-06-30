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

