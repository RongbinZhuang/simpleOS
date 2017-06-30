#include "initLibC.h"

//global function
	void init_8259A()
	{
		/* Master 8259, ICW1. */
		out_byte(INT_M_CTL,	0x11);

		/* Slave  8259, ICW1. */
		out_byte(INT_S_CTL,	0x11);

		/* Master 8259, ICW2. 设置 '主8259' 的中断入口地址为 0x20. */
		out_byte(INT_M_CTLMASK,	INT_VECTOR_IRQ0);

		/* Slave  8259, ICW2. 设置 '从8259' 的中断入口地址为 0x28 */
		out_byte(INT_S_CTLMASK,	INT_VECTOR_IRQ8);

		/* Master 8259, ICW3. IR2 对应 '从8259'. */
		out_byte(INT_M_CTLMASK,	0x4);

		/* Slave  8259, ICW3. 对应 '主8259' 的 IR2. */
		out_byte(INT_S_CTLMASK,	0x2);

		/* Master 8259, ICW4. */
		out_byte(INT_M_CTLMASK,	0x1);

		/* Slave  8259, ICW4. */
		out_byte(INT_S_CTLMASK,	0x1);

		/* Master 8259, OCW1.  */
		out_byte(INT_M_CTLMASK,	0xFE);

		/* Slave  8259, OCW1.  */
		out_byte(INT_S_CTLMASK,	0xFF);
		for(int i=0;i<NR_IRQ;i++)
			irq_table[i]=spurious_irq;
	}
	void init_prot()
	{
		init_8259A();

		// 全部初始化成中断门(没有陷阱门)
		init_idt_desc(INT_VECTOR_DIVIDE,DA_386IGate,
				divide_error,PRIVILEGE_KRNL);

		init_idt_desc(INT_VECTOR_DEBUG,DA_386IGate,
				single_step_exception,PRIVILEGE_KRNL);

		init_idt_desc(INT_VECTOR_NMI,DA_386IGate,
				nmi,PRIVILEGE_KRNL);

		init_idt_desc(INT_VECTOR_BREAKPOINT,DA_386IGate,
				breakpoint_exception,PRIVILEGE_USER);

		init_idt_desc(INT_VECTOR_OVERFLOW,DA_386IGate,
				overflow,PRIVILEGE_USER);

		init_idt_desc(INT_VECTOR_BOUNDS,DA_386IGate,
				bounds_check,PRIVILEGE_KRNL);

		init_idt_desc(INT_VECTOR_INVAL_OP,DA_386IGate,
				inval_opcode,PRIVILEGE_KRNL);

		init_idt_desc(INT_VECTOR_COPROC_NOT,DA_386IGate,
				copr_not_available,PRIVILEGE_KRNL);

		init_idt_desc(INT_VECTOR_DOUBLE_FAULT,	DA_386IGate,
				  double_fault,		PRIVILEGE_KRNL);

		init_idt_desc(INT_VECTOR_COPROC_SEG,	DA_386IGate,
				  copr_seg_overrun,		PRIVILEGE_KRNL);

		init_idt_desc(INT_VECTOR_INVAL_TSS,	DA_386IGate,
				  inval_tss,		PRIVILEGE_KRNL);

		init_idt_desc(INT_VECTOR_SEG_NOT,	DA_386IGate,
				  segment_not_present,	PRIVILEGE_KRNL);

		init_idt_desc(INT_VECTOR_STACK_FAULT,	DA_386IGate,
				  stack_exception,		PRIVILEGE_KRNL);

		init_idt_desc(INT_VECTOR_PROTECTION,	DA_386IGate,
				  general_protection,	PRIVILEGE_KRNL);

		init_idt_desc(INT_VECTOR_PAGE_FAULT,	DA_386IGate,
				  page_fault,		PRIVILEGE_KRNL);

		init_idt_desc(INT_VECTOR_COPROC_ERR,	DA_386IGate,
				  copr_error,		PRIVILEGE_KRNL);

		init_idt_desc(INT_VECTOR_SYS_CALL,	DA_386IGate,
				  sys_call,		PRIVILEGE_USER);

			init_idt_desc(INT_VECTOR_IRQ0 + 0,      DA_386IGate,
						  hwint00,                  PRIVILEGE_KRNL);

			init_idt_desc(INT_VECTOR_IRQ0 + 1,      DA_386IGate,
						  hwint01,                  PRIVILEGE_KRNL);

			init_idt_desc(INT_VECTOR_IRQ0 + 2,      DA_386IGate,
						  hwint02,                  PRIVILEGE_KRNL);

			init_idt_desc(INT_VECTOR_IRQ0 + 3,      DA_386IGate,
						  hwint03,                  PRIVILEGE_KRNL);

			init_idt_desc(INT_VECTOR_IRQ0 + 4,      DA_386IGate,
						  hwint04,                  PRIVILEGE_KRNL);

			init_idt_desc(INT_VECTOR_IRQ0 + 5,      DA_386IGate,
						  hwint05,                  PRIVILEGE_KRNL);

			init_idt_desc(INT_VECTOR_IRQ0 + 6,      DA_386IGate,
						  hwint06,                  PRIVILEGE_KRNL);

			init_idt_desc(INT_VECTOR_IRQ0 + 7,      DA_386IGate,
						  hwint07,                  PRIVILEGE_KRNL);

			init_idt_desc(INT_VECTOR_IRQ8 + 0,      DA_386IGate,
						  hwint08,                  PRIVILEGE_KRNL);

			init_idt_desc(INT_VECTOR_IRQ8 + 1,      DA_386IGate,
						  hwint09,                  PRIVILEGE_KRNL);

			init_idt_desc(INT_VECTOR_IRQ8 + 2,      DA_386IGate,
						  hwint10,                  PRIVILEGE_KRNL);

			init_idt_desc(INT_VECTOR_IRQ8 + 3,      DA_386IGate,
						  hwint11,                  PRIVILEGE_KRNL);

			init_idt_desc(INT_VECTOR_IRQ8 + 4,      DA_386IGate,
						  hwint12,                  PRIVILEGE_KRNL);

			init_idt_desc(INT_VECTOR_IRQ8 + 5,      DA_386IGate,
						  hwint13,                  PRIVILEGE_KRNL);

			init_idt_desc(INT_VECTOR_IRQ8 + 6,      DA_386IGate,
						  hwint14,                  PRIVILEGE_KRNL);

			init_idt_desc(INT_VECTOR_IRQ8 + 7,      DA_386IGate,
						  hwint15,                  PRIVILEGE_KRNL);

		initProc();
	}
	void exception_handler(int vec_no,int err_code,
			int eip,int cs,int eflags)
	{
		disp_str("exception_handler entered\n");
		int text_color = 0x74; /* 灰底红字 */

		char * err_msg[] = {
				(char*)	"#DE Divide Error",
				(char*)	"#DB RESERVED",
				(char*)	"—  NMI Interrupt",
				(char*)	"#BP Breakpoint",
				(char*)	"#OF Overflow",
				(char*)	"#BR BOUND Range Exceeded",
				(char*)	"#UD Invalid Opcode (Undefined Opcode)",
				(char*)	"#NM Device Not Available (No Math Coprocessor)",
				(char*)	"#DF Double Fault",
				(char*)	"    Coprocessor Segment Overrun (reserved)",
				(char*)	"#TS Invalid TSS",
				(char*)	"#NP Segment Not Present",
				(char*)	"#SS Stack-Segment Fault",
				(char*)	"#GP General Protection",
				(char*)	"#PF Page Fault",
				(char*)	"—  (Intel reserved. Do not use.)",
				(char*)	"#MF x87 FPU Floating-Point Error (Math Fault)",
				(char*)	"#AC Alignment Check",
				(char*)	"#MC Machine Check",
				(char*)	"#XF SIMD Floating-Point Exception"
		};

		/* 通过打印空格的方式清空屏幕的前五行，并把 disp_pos 清零 */
		dwDispPos = 0;
		for(int i=0;i<80*5;i++)
			disp_str(" ");
		dwDispPos = 0;

		disp_color_str("Exception! --> ", text_color);
		disp_color_str(err_msg[vec_no], text_color);
		disp_color_str("\n\n", text_color);
		disp_color_str("EFLAGS:", text_color);
		disp_int(eflags);
		disp_color_str("CS:", text_color);
		disp_int(cs);
		disp_color_str("EIP:", text_color);
		disp_int(eip);

		if(err_code != 0xFFFFFFFF){
			disp_color_str("Error code:", text_color);
			disp_int(err_code);
		}
	}
	void spurious_irq(int irq)
	{
		disp_str("spurious_irq: ");
		disp_int(irq);
		disp_str("\n");
	}
	void put_irq_handler(int irq, irq_handler handler)
	{
		disable_irq(irq);
		irq_table[irq] = handler;
	}
//local function
	static void init_idt_desc(unsigned char vector, u8 desc_type,
			int_handler handler, unsigned char privilege)
	{
		GATE *	p_gate	= &idt[vector];
		u32	base	= (u32)handler;
		p_gate->offset_low	= base & 0xFFFF;
		p_gate->selector	= SELECTOR_KERNEL_CS;
		p_gate->dcount		= 0;
		p_gate->attr		= desc_type | (privilege << 5);
		p_gate->offset_high	= (base >> 16) & 0xFFFF;
	}
