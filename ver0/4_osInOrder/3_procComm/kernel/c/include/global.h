#ifndef _MY_GLOBAL_H
#define _MY_GLOBAL_H
#define	RETVAL		u.m3.m3i1

#define	phys_copy	memcpy
#define	phys_set	memset

#define	STR_DEFAULT_LEN	1024
#define FIRST_PROC	proc_table[0]
#define LAST_PROC	proc_table[NR_TASKS + NR_PROCS - 1]

#define proc2pid(x) (x - proc_table)

#define ASSERT
#define assert(exp)  if (exp) ; \
        else assertion_failure(#exp, __FILE__, __BASE_FILE__, __LINE__)
#define printl printf

/* magic chars used by `printx' */
#define MAG_CH_PANIC	'\002'
#define MAG_CH_ASSERT	'\003'
#define INVALID_DRIVER	-20
#define INTERRUPT	-10

#define SENDING   0x02	/* set when proc trying to send */
#define RECEIVING 0x04	/* set when proc trying to recv */

#define ANY		(NR_TASKS + NR_PROCS + 10)
#define NO_TASK		(NR_TASKS + NR_PROCS + 20)

#define SEND		1
#define RECEIVE		2
#define BOTH		3	/* BOTH = (SEND | RECEIVE) */


//macro define
#define TASK_TTY	0
#define TASK_SYS	1
#define TRUE		1
#define FALSE		0
#define SCR_UP	1	/* scroll forward */
#define SCR_DN	-1	/* scroll backward */

#define SCR_SIZE		(80 * 25)
#define SCR_WIDTH		80

#define DEFAULT_CHAR_COLOR	(MAKE_COLOR(BLACK, WHITE))
#define GRAY_CHAR		(MAKE_COLOR(BLACK, BLACK) | BRIGHT)
#define RED_CHAR		(MAKE_COLOR(BLUE, RED) | BRIGHT)


#define SCREEN_SIZE		(80 * 25)
#define SCREEN_WIDTH		80
#define NR_TASKS	2
#define NR_PROCS	3
#define NR_SYS_CALL 4

#define NR_CONSOLES	3	/* consoles */
#define TTY_IN_BYTES	256	/* tty input queue size */

/* stacks of tasks */
#define STACK_SIZE_TTY		0x8000
#define STACK_SIZE_TESTA	0x8000
#define STACK_SIZE_TESTB	0x8000
#define STACK_SIZE_TESTC	0x8000
#define STACK_SIZE_SYS		0x8000

/* VGA */
#define	CRTC_ADDR_REG	0x3D4	
#define	CRTC_DATA_REG	0x3D5
#define	START_ADDR_H	0xC	/* reg index of video mem start addr (MSB) */
#define	START_ADDR_L	0xD	/* reg index of video mem start addr (LSB) */
#define	CURSOR_H	0xE	/* reg index of cursor position (MSB) */
#define	CURSOR_L	0xF	/* reg index of cursor position (LSB) */
#define	V_MEM_BASE	0xB8000	/* base of color video memory */
#define	V_MEM_SIZE	0x8000	/* 32K: B8000H -> BFFFFH */

#define BLACK   0x0     /* 0000 */
#define WHITE   0x7     /* 0111 */
#define RED     0x4     /* 0100 */
#define GREEN   0x2     /* 0010 */
#define BLUE    0x1     /* 0001 */
#define FLASH   0x80    /* 1000 0000 */
#define BRIGHT  0x08    /* 0000 1000 */
#define MAKE_COLOR(x,y) (x | y) /* MAKE_COLOR(Background,Foreground) */

/* Hardware interrupts */
#define	NR_IRQ		16	/* Number of IRQs */
#define	CLOCK_IRQ	0
#define	KEYBOARD_IRQ	1
#define	CASCADE_IRQ	2	/* cascade enable for 2nd AT controller */
#define	ETHER_IRQ	3	/* default ethernet interrupt vector */
#define	SECONDARY_IRQ	3	/* RS232 interrupt vector for port 2 */
#define	RS232_IRQ	4	/* RS232 interrupt vector for port 1 */
#define	XT_WINI_IRQ	5	/* xt winchester */
#define	FLOPPY_IRQ	6	/* floppy disk */
#define	PRINTER_IRQ	7
#define	AT_WINI_IRQ	14	/* at winchester */

/* 8253/8254 PIT (Programmable Interval Timer) */
#define TIMER0         0x40 /* I/O port for timer channel 0 */
#define TIMER_MODE     0x43 /* I/O port for timer mode control */
#define RATE_GENERATOR 0x34 /* 00-11-010-0 :*/
#define TIMER_FREQ     1193182L/* clock frequency for timer in PC and AT */
#define HZ             100  /* clock freq (software settable on IBM-PC) */



#define vir2phys(seg_base, vir)	(u32)(((u32)seg_base) + (u32)(vir))

#define	GDT_SIZE		128
#define	IDT_SIZE		256

#define LDT_SIZE		2
#define INDEX_LDT_C             0
#define INDEX_LDT_RW            1



#define STACK_SIZE_TOTAL	(STACK_SIZE_TESTA + \
				STACK_SIZE_TESTB\
			+ 		STACK_SIZE_TESTC\
			+ 		STACK_SIZE_TESTC\
				)

//port for i8259 
#define INT_M_CTL		0x20
#define INT_M_CTLMASK	0x21
#define INT_S_CTL		0xA0
#define INT_S_CTLMASK	0xA1

//privilege
#define	PRIVILEGE_KRNL	0
#define	PRIVILEGE_TASK	1
#define	PRIVILEGE_USER	3

#define	RPL_KRNL	SA_RPL0
#define	RPL_TASK	SA_RPL1
#define	RPL_USER	SA_RPL3

/* GDT */
/* 描述符索引 */
#define	INDEX_DUMMY			0	// ┓
#define	INDEX_FLAT_C		1	// ┣ LOADER 里面已经确定了的.
#define	INDEX_FLAT_RW		2	// ┃
#define	INDEX_VIDEO			3	// ┛
#define	INDEX_TSS			4
#define	INDEX_LDT_FIRST		5

/* 选择子 */
#define	SELECTOR_DUMMY		0		// ┓
#define	SELECTOR_FLAT_C		0x08		// ┣ LOADER 里面已经确定了的.
#define	SELECTOR_FLAT_RW	0x10		// ┃
#define	SELECTOR_VIDEO		(0x18+3)	// ┛<-- RPL=3
#define	SELECTOR_TSS		0x20		
#define SELECTOR_LDT_FIRST	0x28

#define	SELECTOR_KERNEL_CS	SELECTOR_FLAT_C
#define	SELECTOR_KERNEL_DS	SELECTOR_FLAT_RW
#define	SELECTOR_KERNEL_GS	SELECTOR_VIDEO


/* 描述符类型值说明 */
#define	DA_32			0x4000	/* 32 位段				*/
#define	DA_LIMIT_4K		0x8000	/* 段界限粒度为 4K 字节			*/
#define	DA_DPL0			0x00	/* DPL = 0				*/
#define	DA_DPL1			0x20	/* DPL = 1				*/
#define	DA_DPL2			0x40	/* DPL = 2				*/
#define	DA_DPL3			0x60	/* DPL = 3				*/
/* 存储段描述符类型值说明 */
#define	DA_DR			0x90	/* 存在的只读数据段类型值		*/
#define	DA_DRW			0x92	/* 存在的可读写数据段属性值		*/
#define	DA_DRWA			0x93	/* 存在的已访问可读写数据段类型值	*/
#define	DA_C			0x98	/* 存在的只执行代码段属性值		*/
#define	DA_CR			0x9A	/* 存在的可执行可读代码段属性值		*/
#define	DA_CCO			0x9C	/* 存在的只执行一致代码段属性值		*/
#define	DA_CCOR			0x9E	/* 存在的可执行可读一致代码段属性值	*/
/* 系统段描述符类型值说明 */
#define	DA_LDT			0x82	/* 局部描述符表段类型值			*/
#define	DA_TaskGate		0x85	/* 任务门类型值				*/
#define	DA_386TSS		0x89	/* 可用 386 任务状态段类型值		*/
#define	DA_386CGate		0x8C	/* 386 调用门类型值			*/
#define	DA_386IGate		0x8E	/* 386 中断门类型值			*/
#define	DA_386TGate		0x8F	/* 386 陷阱门类型值			*/

/* 选择子类型值说明 */
/* 其中, SA_ : Selector Attribute */
#define	SA_RPL_MASK	0xFFFC
#define	SA_RPL0		0
#define	SA_RPL1		1
#define	SA_RPL2		2
#define	SA_RPL3		3

#define	SA_TI_MASK	0xFFFB
#define	SA_TIG		0
#define	SA_TIL		4


/* 中断向量 */
#define	INT_VECTOR_DIVIDE		0x0
#define	INT_VECTOR_DEBUG		0x1
#define	INT_VECTOR_NMI			0x2
#define	INT_VECTOR_BREAKPOINT		0x3
#define	INT_VECTOR_OVERFLOW		0x4
#define	INT_VECTOR_BOUNDS		0x5
#define	INT_VECTOR_INVAL_OP		0x6
#define	INT_VECTOR_COPROC_NOT		0x7
#define	INT_VECTOR_DOUBLE_FAULT		0x8
#define	INT_VECTOR_COPROC_SEG		0x9
#define	INT_VECTOR_INVAL_TSS		0xA
#define	INT_VECTOR_SEG_NOT		0xB
#define	INT_VECTOR_STACK_FAULT		0xC
#define	INT_VECTOR_PROTECTION		0xD
#define	INT_VECTOR_PAGE_FAULT		0xE
#define	INT_VECTOR_COPROC_ERR		0x10

/* 中断向量 */
#define	INT_VECTOR_IRQ0			0x20
#define	INT_VECTOR_IRQ8			0x28
#define INT_VECTOR_SYS_CALL             0x90

#define	KB_IN_BYTES	32	/* size of keyboard input buffer */
#define MAP_COLS	3	/* Number of columns in keymap */
#define NR_SCAN_CODES	0x80	/* Number of scan codes (rows in keymap) */

#define FLAG_BREAK	0x0080		/* Break Code			*/
#define FLAG_EXT	0x0100		/* Normal function keys		*/
#define FLAG_SHIFT_L	0x0200		/* Shift key			*/
#define FLAG_SHIFT_R	0x0400		/* Shift key			*/
#define FLAG_CTRL_L	0x0800		/* Control key			*/
#define FLAG_CTRL_R	0x1000		/* Control key			*/
#define FLAG_ALT_L	0x2000		/* Alternate key		*/
#define FLAG_ALT_R	0x4000		/* Alternate key		*/
#define FLAG_PAD	0x8000		/* keys in num pad		*/

#define MASK_RAW	0x01FF

#define ESC		(0x01 + FLAG_EXT)	/* Esc		*/
#define TAB		(0x02 + FLAG_EXT)	/* Tab		*/
#define ENTER		(0x03 + FLAG_EXT)	/* Enter	*/
#define BACKSPACE	(0x04 + FLAG_EXT)	/* BackSpace	*/

#define GUI_L		(0x05 + FLAG_EXT)	/* L GUI	*/
#define GUI_R		(0x06 + FLAG_EXT)	/* R GUI	*/
#define APPS		(0x07 + FLAG_EXT)	/* APPS	*/

/* Shift, Ctrl, Alt */
#define SHIFT_L		(0x08 + FLAG_EXT)	/* L Shift	*/
#define SHIFT_R		(0x09 + FLAG_EXT)	/* R Shift	*/
#define CTRL_L		(0x0A + FLAG_EXT)	/* L Ctrl	*/
#define CTRL_R		(0x0B + FLAG_EXT)	/* R Ctrl	*/
#define ALT_L		(0x0C + FLAG_EXT)	/* L Alt	*/
#define ALT_R		(0x0D + FLAG_EXT)	/* R Alt	*/

/* Lock keys */
#define CAPS_LOCK	(0x0E + FLAG_EXT)	/* Caps Lock	*/
#define	NUM_LOCK	(0x0F + FLAG_EXT)	/* Number Lock	*/
#define SCROLL_LOCK	(0x10 + FLAG_EXT)	/* Scroll Lock	*/

/* Function keys */
#define F1		(0x11 + FLAG_EXT)	/* F1		*/
#define F2		(0x12 + FLAG_EXT)	/* F2		*/
#define F3		(0x13 + FLAG_EXT)	/* F3		*/
#define F4		(0x14 + FLAG_EXT)	/* F4		*/
#define F5		(0x15 + FLAG_EXT)	/* F5		*/
#define F6		(0x16 + FLAG_EXT)	/* F6		*/
#define F7		(0x17 + FLAG_EXT)	/* F7		*/
#define F8		(0x18 + FLAG_EXT)	/* F8		*/
#define F9		(0x19 + FLAG_EXT)	/* F9		*/
#define F10		(0x1A + FLAG_EXT)	/* F10		*/
#define F11		(0x1B + FLAG_EXT)	/* F11		*/
#define F12		(0x1C + FLAG_EXT)	/* F12		*/

/* Control Pad */
#define PRINTSCREEN	(0x1D + FLAG_EXT)	/* Print Screen	*/
#define PAUSEBREAK	(0x1E + FLAG_EXT)	/* Pause/Break	*/
#define INSERT		(0x1F + FLAG_EXT)	/* Insert	*/
#define DELETE		(0x20 + FLAG_EXT)	/* Delete	*/
#define HOME		(0x21 + FLAG_EXT)	/* Home		*/
#define END		(0x22 + FLAG_EXT)	/* End		*/
#define PAGEUP		(0x23 + FLAG_EXT)	/* Page Up	*/
#define PAGEDOWN	(0x24 + FLAG_EXT)	/* Page Down	*/
#define UP		(0x25 + FLAG_EXT)	/* Up		*/
#define DOWN		(0x26 + FLAG_EXT)	/* Down		*/
#define LEFT		(0x27 + FLAG_EXT)	/* Left		*/
#define RIGHT		(0x28 + FLAG_EXT)	/* Right	*/

/* ACPI keys */
#define POWER		(0x29 + FLAG_EXT)	/* Power	*/
#define SLEEP		(0x2A + FLAG_EXT)	/* Sleep	*/
#define WAKE		(0x2B + FLAG_EXT)	/* Wake Up	*/

/* Num Pad */
#define PAD_SLASH	(0x2C + FLAG_EXT)	/* /		*/
#define PAD_STAR	(0x2D + FLAG_EXT)	/* *		*/
#define PAD_MINUS	(0x2E + FLAG_EXT)	/* -		*/
#define PAD_PLUS	(0x2F + FLAG_EXT)	/* +		*/
#define PAD_ENTER	(0x30 + FLAG_EXT)	/* Enter	*/
#define PAD_DOT		(0x31 + FLAG_EXT)	/* .		*/
#define PAD_0		(0x32 + FLAG_EXT)	/* 0		*/
#define PAD_1		(0x33 + FLAG_EXT)	/* 1		*/
#define PAD_2		(0x34 + FLAG_EXT)	/* 2		*/
#define PAD_3		(0x35 + FLAG_EXT)	/* 3		*/
#define PAD_4		(0x36 + FLAG_EXT)	/* 4		*/
#define PAD_5		(0x37 + FLAG_EXT)	/* 5		*/
#define PAD_6		(0x38 + FLAG_EXT)	/* 6		*/
#define PAD_7		(0x39 + FLAG_EXT)	/* 7		*/
#define PAD_8		(0x3A + FLAG_EXT)	/* 8		*/
#define PAD_9		(0x3B + FLAG_EXT)	/* 9		*/
#define PAD_UP		PAD_8			/* Up		*/
#define PAD_DOWN	PAD_2			/* Down		*/
#define PAD_LEFT	PAD_4			/* Left		*/
#define PAD_RIGHT	PAD_6			/* Right	*/
#define PAD_HOME	PAD_7			/* Home		*/
#define PAD_END		PAD_1			/* End		*/
#define PAD_PAGEUP	PAD_9			/* Page Up	*/
#define PAD_PAGEDOWN	PAD_3			/* Page Down	*/
#define PAD_INS		PAD_0			/* Ins		*/
#define PAD_MID		PAD_5			/* Middle key	*/
#define PAD_DEL		PAD_DOT			/* Del		*/


#endif

