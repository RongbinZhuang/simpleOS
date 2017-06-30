#include "procLibC.h"

void initProc()
{
	disp_str((char*)"initProc entered\n");
	/* 填充 GDT 中 TSS 这个描述符 */
	memset(&tss, 0, sizeof(tss));
	tss.ss0 = SELECTOR_KERNEL_DS;
	init_descriptor(&gdt[INDEX_TSS],
			vir2phys(seg2phys(SELECTOR_KERNEL_DS), &tss),
			sizeof(tss) - 1,
			DA_386TSS);
	tss.iobase = sizeof(tss); /* 没有I/O许可位图 */



	/* 填充 GDT 中进程的 LDT 的描述符 */
	PROCESS* p_proc	= proc_table;
	u16 selector_ldt = INDEX_LDT_FIRST << 3;
	for(int i=0;i<NR_TASKS;i++){
		init_descriptor(&gdt[selector_ldt>>3],
				vir2phys(seg2phys(SELECTOR_KERNEL_DS),
					proc_table[i].ldts),
				LDT_SIZE * sizeof(DESCRIPTOR) - 1,
				DA_LDT);
		p_proc++;
		selector_ldt += 1 << 3;
	}
}

void init_descriptor(DESCRIPTOR *p_desc,u32 base,u32 limit,u16 attribute)
{
	p_desc->limit_low	= limit & 0x0FFFF;
	p_desc->base_low	= base & 0x0FFFF;
	p_desc->base_mid	= (base >> 16) & 0x0FF;
	p_desc->attr1		= attribute & 0xFF;
	p_desc->limit_high_attr2= ((limit>>16) & 0x0F) | (attribute>>8) & 0xF0;
	p_desc->base_high	= (base >> 24) & 0x0FF;
}

u32 seg2phys(u16 seg)
{
	DESCRIPTOR* p_dest = &gdt[seg >> 3];
	return (p_dest->base_high<<24 | p_dest->base_mid<<16 | p_dest->base_low);
}

void schedule()
{
	//disp_str((char*)"*");
	PROCESS* p;
	int	 greatest_ticks = 0;
	while (!greatest_ticks) {
		for (p = proc_table; p < proc_table+NR_TASKS; p++) {
			if (p->ticks > greatest_ticks) {
				greatest_ticks = p->ticks;
				p_proc_ready = p;
			}
		}

	//	if (!greatest_ticks) {
	//		for (p = proc_table; p < proc_table+NR_TASKS; p++) {
	//			p->ticks = p->priority;
	//		}
	//	}
	}

}
