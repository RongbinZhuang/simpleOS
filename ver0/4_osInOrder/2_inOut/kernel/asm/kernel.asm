;extern function
	extern		cstart
	extern		exception_handler
	extern		spurious_irq
	extern		mainC
	extern		disp_str
	extern		delay
	extern		clock_handler
;extern  variable
	extern		dwDispPos
	extern		gdt_ptr
	extern		idt_ptr
	extern		p_proc_ready
	extern		tss
	extern		k_reenter
	extern		irq_table
	extern		sys_call_table
	extern		ticks

;include inc
	%include	"sconst.inc"
[section	.data]
clock_int_msg		db	"%"		,0

[section	.bss]
StackSpace		resb	2*1024
StackTop:

[section	.text]
;declare
	;entry declare
		global	_start
		global	restart
	;int function declare
		global	divide_error
		global	single_step_exception
		global	nmi
		global	breakpoint_exception
		global	overflow
		global	bounds_check
		global	inval_opcode
		global	copr_not_available
		global	double_fault
		global	copr_seg_overrun
		global	inval_tss
		global	segment_not_present
		global	stack_exception
		global	general_protection
		global	page_fault
		global	copr_error
		global  hwint00
		global  hwint01
		global  hwint02
		global  hwint03
		global  hwint04
		global  hwint05
		global  hwint06
		global  hwint07
		global  hwint08
		global  hwint09
		global  hwint10
		global  hwint11
		global  hwint12
		global  hwint13
		global  hwint14
		global  hwint15
		global	sys_call

_start:
	mov		esp		,StackTop
	sgdt	[gdt_ptr]
	call	cstart
	lgdt	[gdt_ptr]
	lidt	[idt_ptr]
	jmp		SELECTOR_KERNEL_CS:csinit
csinit:
	xor		eax		,eax
	mov		ax	,SELECTOR_TSS
	ltr		ax
	jmp		mainC

;function define
	PRINTCHECK:
		mov		ah	,07h
		mov		al	,'Z'
		mov		[gs:(80*5+40)*2]	,ax
		ret
	;interrupt total
		exception:
			call	exception_handler
			add		esp, 4*2	
			hlt
		%macro  hwint_master    1
				call	save
				in	al, INT_M_CTLMASK	; `.
				or	al, (1<<%1)			;  | 不允许再发生时钟中断
				out	INT_M_CTLMASK, al	; /

				inc		BYTE[gs:0]
				mov		al	,EOI
				out		INT_M_CTL	,al
				sti		

				push	%1
				call	[irq_table+4*%1]
				pop		ecx

				cli
					
				in	al, INT_M_CTLMASK	; `.
				and	al, ~(1<<%1)	;  | 又允许时钟中断发生
				out	INT_M_CTLMASK, al	; /

				ret

		%endmacro
		%macro  hwint_slave     1
				push    %1
				call    spurious_irq
				add     esp, 4
				hlt
		%endmacro
	;interrupt function
		;internal int
			divide_error:
				push	0xFFFFFFFF	; no err code
				push	0		; vector_no	= 0
				jmp	exception
			single_step_exception:
				push	0xFFFFFFFF	; no err code
				push	1		; vector_no	= 1
				jmp	exception
			nmi:
				push	0xFFFFFFFF	; no err code
				push	2		; vector_no	= 2
				jmp	exception
			breakpoint_exception:
				push	0xFFFFFFFF	; no err code
				push	3		; vector_no	= 3
				jmp	exception
			overflow:
				push	0xFFFFFFFF	; no err code
				push	4		; vector_no	= 4
				jmp	exception
			bounds_check:
				push	0xFFFFFFFF	; no err code
				push	5		; vector_no	= 5
				jmp	exception
			inval_opcode:
				call PRINTCHECK
				push	0xFFFFFFFF	; no err code
				push	6		; vector_no	= 6
				jmp	exception
			copr_not_available:
				push	0xFFFFFFFF	; no err code
				push	7		; vector_no	= 7
				jmp	exception
			double_fault:
				push	8		; vector_no	= 8
				jmp	exception
			copr_seg_overrun:
				push	0xFFFFFFFF	; no err code
				push	9		; vector_no	= 9
				jmp	exception
			inval_tss:
				push	10		; vector_no	= A
				jmp	exception
			segment_not_present:
				push	11		; vector_no	= B
				jmp	exception
			stack_exception:
				push	12		; vector_no	= C
				jmp	exception
			general_protection:
				push	13		; vector_no	= D
				jmp	exception
			page_fault:
				push	14		; vector_no	= E
				jmp	exception
			copr_error:
				push	0xFFFFFFFF	; no err code
				push	16		; vector_no	= 10h
				jmp	exception
		;external int
			ALIGN   16
			hwint00: 
					hwint_master    0
			ALIGN   16
			hwint01:
					hwint_master    1
			ALIGN   16
			hwint02:
					hwint_master    2
			ALIGN   16
			hwint03:
					hwint_master    3
			ALIGN   16
			hwint04:
					hwint_master    4
			ALIGN   16
			hwint05:
					hwint_master    5
			ALIGN   16
			hwint06:
					hwint_master    6
			ALIGN   16
			hwint07:
					hwint_master    7
			ALIGN   16
			hwint08:  
			        hwint_slave     8
			ALIGN   16
			hwint09: 
			        hwint_slave     9
			ALIGN   16
			hwint10:
			        hwint_slave     10
			ALIGN   16
			hwint11: 
			        hwint_slave     11
			ALIGN   16
			hwint12: 
			        hwint_slave     12
			ALIGN   16
			hwint13: 
			        hwint_slave     13
			ALIGN   16
			hwint14: 
			        hwint_slave     14
			ALIGN   16
			hwint15: 
			        hwint_slave     15
		;sys_call
			sys_call:
				call	save
				push	DWORD[p_proc_ready]
				sti
				push	ecx
				push	ebx
				call	[sys_call_table+4*eax]
				add		esp		,12
				mov		[esi+EAXREG-P_STACKBASE]	,eax
				cli
				ret
			
	save:
		.pushReg:
			pushad
			push	ds
			push	es
			push	fs
			push	gs
		mov		dx	,ss
		mov		ds	,dx
		mov		es	,dx
		mov		esi		,esp

		inc		DWORD[k_reenter]
		cmp		DWORD[k_reenter]	,0
		jne		.1
		;jne		.re_enter
		mov		esp		,StackTop
		push	restart
		;jmp		.2
		jmp		[esi+RETADR-P_STACKBASE]
		.1:
			push	restart.reenter	
			jmp		[esi+RETADR-P_STACKBASE]
	restart:
		mov		esp		,[p_proc_ready]
		lldt	[esp+P_LDT_SEL]

		lea		eax		,[esp+P_STACKTOP]
		mov		DWORD[tss+TSS3_S_SP0]	,eax
		.reenter:
			dec		DWORD[k_reenter]
		.popReg:
			pop		gs
			pop		fs
			pop		es
			pop		ds
			popad
			add		esp		,4
		iretd


