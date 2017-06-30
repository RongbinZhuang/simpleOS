#ifndef _MY_INTLIB_H
#define _MY_INTLIB_H

#include "type.h"
#include "global.h"

//extern function 
	extern void disp_int(int);
	extern void out_byte(u16 , u8);
	extern void disp_color_str(char*, u8);
	extern void disp_str(char *);
	extern void init_proc();

//extern variable
	extern int dwDispPos;
	extern GATE idt[];
	extern TSS tss;
	extern DESCRIPTOR gdt[];

//local function
	static void init_idt_desc(unsigned char vector, u8 desc_type,
			int_handler handler, unsigned char privilege);
	void init_descriptor(DESCRIPTOR * p_desc, 
			u32 base, u32 limit, u16 attribute);

//global int init function
	void init_8259A();
	void init_prot();
	void exception_handler(int vec_no,int err_code,
			int eip,int cs,int eflags);
	void memset();
	u32 seg2phys(u16 seg);

//global int_handler for each int
	void	divide_error();
	void	single_step_exception();
	void	nmi();
	void	breakpoint_exception();
	void	overflow();
	void	bounds_check();
	void	inval_opcode();
	void	copr_not_available();
	void	double_fault();
	void	copr_seg_overrun();
	void	inval_tss();
	void	segment_not_present();
	void	stack_exception();
	void	general_protection();
	void	page_fault();
	void	copr_error();
	void    hwint00();
	void    hwint01();
	void    hwint02();
	void    hwint03();
	void    hwint04();
	void    hwint05();
	void    hwint06();
	void    hwint07();
	void    hwint08();
	void    hwint09();
	void    hwint10();
	void    hwint11();
	void    hwint12();
	void    hwint13();
	void    hwint14();
	void    hwint15();

//local struct
#endif
