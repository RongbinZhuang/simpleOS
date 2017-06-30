;pmtest3.asm
;nasm pmtest3.asm -o pmtest3.com

%include		"pm.inc"		;常量，宏

org 0100h
	jmp LABEL_BEGIN

PageDirBase0		equ		200000h
PageTblBase0		equ		201000h
PageDirBase1		equ		300000h
PageTblBase1		equ		301000h

LinearAddrDemo		equ		00401000h
ProcFoo				equ		00401000h
ProcBar				equ		00501000h
ProcPagingDemo		equ		00381000h

[section .gdt]
;GDT
;                            段基址,       段界限     , 属性
LABEL_GDT:         Descriptor       0,                 0, 0     	
	; 空描述符
LABEL_DESC_NORMAL: Descriptor       0,            0ffffh, DA_DRW	
	; Normal 描述符
;LABEL_DESC_CODE32: Descriptor       0,  SegCode32Len-1,DA_C + DA_32	

LABEL_DESC_CODE32: Descriptor       0,  SegCode32Len-1,DA_CR+ DA_32	
	; 非一致代码段, 32
LABEL_DESC_CODE16: Descriptor       0,            0ffffh, DA_C		; 非一致代码段, 16
;LABEL_DESC_DATA:   Descriptor       0,       DataLen - 1, DA_DRW+DA_DPL1	; Data
LABEL_DESC_DATA:   Descriptor       0,       DataLen - 1, DA_DRW	; Data
LABEL_DESC_STACK:  Descriptor       0,        TopOfStack, DA_DRWA + DA_32; Stack, 32 位
LABEL_DESC_LDT:    Descriptor       0,        LDTLen - 1, DA_LDT	; LDT
LABEL_DESC_VIDEO:  
;	Descriptor	0B8000H	,0FFFFH	,DA_DRW+DA_DPL3
	Descriptor	0B8000H	,0FFFFH	,DA_DRW
LABEL_DESC_CODE_DEST:	
	Descriptor	0	,SegCodeDestLen-1	,DA_C+DA_32
LABEL_CALL_GATE_TEST:
	Gate	SelectorCodeDest	,0	,0	,DA_386CGate+DA_DPL3
;			目标选择子			偏移	Dcount	属性
LABEL_DESC_CODE_RING3:
	Descriptor	0	,SegCodeRing3Len-1	,DA_C+DA_32+DA_DPL3
LABEL_DESC_STACK3:
	Descriptor	0	,TopOfStack3		,DA_DRWA+DA_32+DA_DPL3
LABEL_DESC_TSS:
	Descriptor	0	,TSSLen-1			,DA_386TSS
LABEL_DESC_PAGE_DIR:
	Descriptor	PageDirBase0	,4095	,DA_DRW
LABEL_DESC_PAGE_TBL:
	Descriptor	PageTblBase0	,1023	,DA_DRW|DA_LIMIT_4K
LABEL_DESC_FLAT_C:
	Descriptor	0		,0FFFFFH		,DA_CR|DA_32|DA_LIMIT_4K
LABEL_DESC_FLAT_RW:
	Descriptor	0		,0FFFFFH		,DA_DRW|DA_LIMIT_4K
; GDT 结束
GdtLen		equ	$ - LABEL_GDT	; GDT长度
GdtPtr		dw	GdtLen - 1	; GDT界限
		dd	0		; GDT基地址

; GDT 选择子
SelectorNormal		equ	LABEL_DESC_NORMAL	- LABEL_GDT
SelectorCode32		equ	LABEL_DESC_CODE32	- LABEL_GDT
SelectorCode16		equ	LABEL_DESC_CODE16	- LABEL_GDT
SelectorData		equ	LABEL_DESC_DATA		- LABEL_GDT
SelectorStack		equ	LABEL_DESC_STACK	- LABEL_GDT
SelectorLDT			equ	LABEL_DESC_LDT		- LABEL_GDT
SelectorVideo		equ	LABEL_DESC_VIDEO	- LABEL_GDT
SelectorCodeDest	equ	LABEL_DESC_CODE_DEST- LABEL_GDT
SelectorCallGateTest	equ	LABEL_CALL_GATE_TEST-LABEL_GDT
SelectorCodeRing3	equ	LABEL_DESC_CODE_RING3	-LABEL_GDT+SA_RPL3
SelectorStack3		equ	LABEL_DESC_STACK3	-LABEL_GDT+SA_RPL3
SelectorTSS			equ	LABEL_DESC_TSS		-LABEL_GDT
SelectorPageDir		equ	LABEL_DESC_PAGE_DIR	-LABEL_GDT
SelectorPageTbl		equ	LABEL_DESC_PAGE_TBL	-LABEL_GDT
SelectorFlatC		equ	LABEL_DESC_FLAT_C	-LABEL_GDT
SelectorFlatRW		equ	LABEL_DESC_FLAT_RW	-LABEL_GDT

; END of [SECTION .gdt]

[section	.data1]
align 32
[BITS	32]
LABEL_DATA:
_szPMMessage:			db	"In Protect Mode now. ^-^", 0Ah, 0Ah, 0	
_szMemChkTitle:			db	"BaseAddrL BaseAddrH LengthLow LengthHigh   Type", 0Ah, 0	; 进入保护模式后显示此字符串
_szRAMSize			db	"RAM size:", 0
_szReturn			db	0Ah, 0
; 变量
_wSPValueInRealMode		dw	0
_PageTableNumber		dd	0
_dwMCRNumber:			dd	0	; Memory Check Result
_dwDispPos:			dd	(80 * 6 + 0) * 2	; 屏幕第 6 行, 第 0 列。
_dwMemSize:			dd	0
_ARDStruct:			; Address Range Descriptor Structure
	_dwBaseAddrLow:		dd	0
	_dwBaseAddrHigh:	dd	0
	_dwLengthLow:		dd	0
	_dwLengthHigh:		dd	0
	_dwType:		dd	0

_MemChkBuf:	times	256	db	0

; 保护模式下使用这些符号
szPMMessage		equ	_szPMMessage	- $$
szMemChkTitle		equ	_szMemChkTitle	- $$
szRAMSize		equ	_szRAMSize	- $$
szReturn		equ	_szReturn	- $$
dwDispPos		equ	_dwDispPos	- $$
dwMemSize		equ	_dwMemSize	- $$
dwMCRNumber		equ	_dwMCRNumber	- $$
ARDStruct		equ	_ARDStruct	- $$
	dwBaseAddrLow	equ	_dwBaseAddrLow	- $$
	dwBaseAddrHigh	equ	_dwBaseAddrHigh	- $$
	dwLengthLow	equ	_dwLengthLow	- $$
	dwLengthHigh	equ	_dwLengthHigh	- $$
	dwType		equ	_dwType		- $$
MemChkBuf		equ	_MemChkBuf	- $$
PageTableNumber	equ	_PageTableNumber-$$

DataLen			equ		$-LABEL_DATA

[section .gs]
ALIGN	32
[BITS	32]
LABEL_STACK:
	times	512		db	0
TopOfStack		equ		$-LABEL_STACK-1

[section	.s16]
[BITS	16]
LABEL_BEGIN:
	mov		ax	,cs
	mov		ds	,ax
	mov		es	,ax
	mov		ss	,ax
	mov		sp	,0100h

	mov		[LABEL_GO_BACK_TO_REAL+3]	,ax
	mov		[_wSPValueInRealMode]		,sp

	mov		ebx	,0
	mov		di	,_MemChkBuf
.loop:
	mov		eax	,0E820H
	mov		ecx	,20
	mov		edx	,0534D4150H;'swap'
	int		15h
	jc		LABEL_MEM_CHK_FAIL
	add		di	,20
	inc		dword[_dwMCRNumber]
	cmp		ebx	,0
	jne		.loop
	jmp		LABEL_MEM_CHK_OK
LABEL_MEM_CHK_FAIL:
	mov		DWORD[_dwMCRNumber],0
LABEL_MEM_CHK_OK:
	
	mov		ax	,cs
	movzx	eax	,ax
	shl		eax	,4
	add		eax	,LABEL_SEG_CODE16
	mov		word[LABEL_DESC_CODE16+2]	,ax
	shr		eax	,16
	mov		byte[LABEL_DESC_CODE16+4]	,al
	mov		byte[LABEL_DESC_CODE16+7]	,ah

;	xor		eax	,eax
;	mov		ax	,cs
;	movzx	eax	,ax
;	shl		eax	,4
;	add		eax	,LABEL_TSS
;	mov		WORD[LABEL_DESC_TSS+2]	,ax
;	shr		eax	,16
;	mov		BYTE[LABEL_DESC_TSS+4]	,al
;	mov		BYTE[LABEL_DESC_TSS+7]	,ah
;
;	xor		eax	,eax
;	mov		ax	,cs
;	movzx	eax	,ax
;	shl		eax	,4
;	add		eax	,LABEL_CODE_RING3
;	mov		word[LABEL_DESC_CODE_RING3+2]	,ax
;	shr		eax	,16
;	mov		byte[LABEL_DESC_CODE_RING3+4]	,al
;	mov		byte[LABEL_DESC_CODE_RING3+7]	,ah
;
;	xor		eax	,eax
;	mov		ax	,cs
;	movzx	eax	,ax
;	shl		eax	,4
;	add		eax	,LABEL_STACK3
;	mov		word[LABEL_DESC_STACK3+2]	,ax
;	shr		eax	,16
;	mov		byte[LABEL_DESC_STACK3+4]	,al
;	mov		byte[LABEL_DESC_STACK3+7]	,ah
;
;	xor		eax	,eax
;	mov		ax	,cs
;	movzx	eax	,ax
;	shl		eax	,4
;	add		eax	,LABEL_SEG_CODE_DEST
;	mov		word[LABEL_DESC_CODE_DEST+2]	,ax
;	shr		eax	,16
;	mov		byte[LABEL_DESC_CODE_DEST+4]	,al
;	mov		byte[LABEL_DESC_CODE_DEST+7]	,ah

	xor		eax	,eax
	mov		ax	,cs
	shl		eax	,4
	add		eax	,LABEL_SEG_CODE32
	mov		WORD[LABEL_DESC_CODE32+2]	,ax
	shr		eax	,16
	mov		BYTE[LABEL_DESC_CODE32+4]	,al
	mov		BYTE[LABEL_DESC_CODE32+7]	,ah

	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_DATA
	mov	word [LABEL_DESC_DATA + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_DATA + 4], al
	mov	byte [LABEL_DESC_DATA + 7], ah

	; 初始化堆栈段描述符
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_STACK
	mov	word [LABEL_DESC_STACK + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_STACK + 4], al
	mov	byte [LABEL_DESC_STACK + 7], ah

	; 初始化 LDT 在 GDT 中的描述符
;	xor	eax, eax
;	mov	ax, ds
;	shl	eax, 4
;	add	eax, LABEL_LDT
;	mov	word [LABEL_DESC_LDT + 2], ax
;	shr	eax, 16
;	mov	byte [LABEL_DESC_LDT + 4], al
;	mov	byte [LABEL_DESC_LDT + 7], ah

;	xor	eax, eax
;	mov	ax, ds
;	shl	eax, 4
;	add	eax, LABEL_CODE_A
;	mov	word [LABEL_LDT_DESC_CODEA + 2], ax
;	shr	eax, 16
;	mov	byte [LABEL_LDT_DESC_CODEA + 4], al
;	mov	byte [LABEL_LDT_DESC_CODEA + 7], ah
;
	xor		eax	,eax
	mov		ax	,ds
	shl		eax	,4
	add		eax	,LABEL_GDT
	mov		DWORD[GdtPtr+2]	,eax	

	lgdt	[GdtPtr]

	cli

	in		al	,92h
	or		al	,00000010b
	out		92h	,al

	mov		eax	,cr0
	or		eax	,1
	mov		cr0	,eax

	jmp		DWORD	SelectorCode32:0

LABEL_REAL_ENTRY:
	mov		ax	,cs
	mov		ds	,ax
	mov		es	,ax
	mov		ss	,ax
	mov		sp	,[_wSPValueInRealMode]

	in		al	,92h
	and		al	,11111101b
	out		92h	,al

	sti

	mov		ax	,4c00h
	int		21h

[section	.s32]
[BITS	32]

LABEL_SEG_CODE32:
	mov		ax	,SelectorData
	mov		ds	,ax
	mov		es	,ax
	mov		ax	,SelectorVideo
	mov		gs	,ax
	mov		ax	,SelectorStack
	mov		ss	,ax

	mov		esp	,TopOfStack

;	mov		ah	,0ch
;	xor		esi	,esi
;	xor		edi	,edi
;	mov		esi	,szPMMessage
;	mov		edi	,40
;
;	cld

	push	szPMMessage
	call	DispStr
	add		esp	,4

	push	szMemChkTitle
	call	DispStr
	add		esp	,4

	call	DispMemSize

;	call	SetupPaging

	call	PagingDemo

	jmp		SelectorCode16:0
	
.1:
	lodsb
	test	al	,al
	jz		.2
	mov		[gs:edi]	,ax
	add		edi	,2
	jmp		.1
.2:
	call	DispReturn
	mov		ax	,SelectorLDT
	lldt	ax
	mov		ax	,SelectorTSS
	ltr		ax

	push	SelectorStack3
	push	TopOfStack3
	push	SelectorCodeRing3
	push	0
	retf
	call	SelectorCallGateTest:0
	jmp		SelectorLDTCodeA:0
	jmp		SelectorCode16:0

SetupPaging:
	;initialize all the pagetable
		;	mov		ax	,SelectorPageDir
		;	mov		es	,ax
		;	mov		ecx	,1024
		;	xor		edi	,edi
		;	xor		eax	,eax
		;	mov		eax	,PageTblBase | PG_P | PG_USU | PG_RWW
		;	cld
		;.1:
		;	stosd
		;	add		eax	,4096
		;	loop	.1
		;
		;	mov		ax	,SelectorPageTbl
		;	mov		es	,ax
		;	mov		ecx	,1024*1024
		;	xor		edi	,edi
		;	xor		eax	,eax
		;	mov		eax	,PG_P|PG_USU|PG_RWW
		;.2:
		;	stosd
		;	add		eax	,4096
		;	loop	.2
		;
		;	mov		eax	,PageDirBase0
		;	mov		cr3	,eax
		;	mov		eax	,cr0
		;	or		eax	,80000000h
		;	mov		cr0	,eax
		;	jmp		short	.3
		;.3:
		;	nop
		;
		;	ret
		;

	xor		edx	,edx
	mov		eax	,[dwMemSize]
	mov		ebx	,400000h
	div		ebx
	mov		ecx	,eax
	test	edx	,edx
	jz		.no_remainder
	inc		ecx
.no_remainder:
	;	push	ecx
	mov		[PageTableNumber]	,ecx

	;	mov		ax	,SelectorPageDir
	mov		ax	,SelectorFlatRW
	mov		es	,ax
	;	xor		edi	,edi
	mov		edi	,PageDirBase0
	xor		eax	,eax
	mov		eax	,PageTblBase0|PG_P|PG_USU|PG_RWW
.1:
	stosd
	add		eax	,4096
	loop	.1

	;	mov		ax	,SelectorPageTbl
	;	mov		es	,ax
	;	pop		eax	
	mov		eax	,[PageTableNumber]
	mov		ebx	,1024
	mul		ebx
	mov		ecx	,eax
	;	xor		edi	,edi
	mov		edi	,PageTblBase0
	xor		eax	,eax
	mov		eax	,PG_P|PG_USU|PG_RWW
.2:
	stosd
	add		eax	,4096
	loop	.2

	mov		eax	,PageDirBase0
	mov		cr3	,eax
	mov		eax	,cr0
	or		eax	,80000000h
	mov		cr0	,eax
	jmp		short	.3
.3:
	nop
	ret		
	
DispMemSize:
	push	esi
	push	edi
	push	ecx

	mov		esi	,MemChkBuf
	mov		ecx	,[dwMCRNumber]
.loop:
	mov		edx	,5
	mov		edi	,ARDStruct
.1:
	push	DWORD[esi]
	call	DispInt
	pop		eax
	stosd
	add		esi	,4
	dec		edx
	cmp		edx	,0
	jnz		.1
	call	DispReturn
	cmp		DWORD[dwType]	,1
	jne		.2
	mov		eax	,[dwBaseAddrLow]
	add		eax	,[dwLengthLow]
	cmp		eax	,[dwMemSize]
	jb		.2
	mov		[dwMemSize]	,eax
.2:
	loop	.loop

	call	DispReturn
	push	szRAMSize
	call	DispStr
	add		esp	,4
	
	push	DWORD[dwMemSize]
	call	DispInt
	add		esp	,4
	call	DispReturn

	pop		ecx
	pop		edi
	pop		esi
	ret

PagingDemo:
	mov		ax	,cs
	mov		ds	,ax

;	push	szMemChkTitle
;	call	DispStr
;	add		esp	,4

	mov		ax	,SelectorFlatRW
	mov		es	,ax

	push	LenFoo
	push	OffsetFoo
	push	ProcFoo
	call	MemCpy
	add	esp, 12

	push	LenBar
	push	OffsetBar
	push	ProcBar
	call	MemCpy
	add	esp, 12

	push	LenPagingDemoAll
	push	OffsetPagingDemoProc
	push	ProcPagingDemo
	call	MemCpy
	add	esp, 12

	mov	ax, SelectorData
	mov	ds, ax			; 数据段选择子
	mov	es, ax

	call	SetupPaging		; 启动分页

	call	SelectorFlatC:ProcPagingDemo
	call	PSwitch			; 切换页目录，改变地址映射关系
	call	SelectorFlatC:ProcPagingDemo

	ret

PSwitch:
	; 初始化页目录
	mov	ax, SelectorFlatRW
	mov	es, ax
	mov	edi, PageDirBase1	; 此段首地址为 PageDirBase1
	xor	eax, eax
	mov	eax, PageTblBase1 | PG_P  | PG_USU | PG_RWW
	mov	ecx, [PageTableNumber]
.1:
	stosd
	add	eax, 4096		; 为了简化, 所有页表在内存中是连续的.
	loop	.1

	; 再初始化所有页表
	mov	eax, [PageTableNumber]	; 页表个数
	mov	ebx, 1024		; 每个页表 1024 个 PTE
	mul	ebx
	mov	ecx, eax		; PTE个数 = 页表个数 * 1024
	mov	edi, PageTblBase1	; 此段首地址为 PageTblBase1
	xor	eax, eax
	mov	eax, PG_P  | PG_USU | PG_RWW
.2:
	stosd
	add	eax, 4096		; 每一页指向 4K 的空间
	loop	.2

	; 在此假设内存是大于 8M 的
	mov	eax, LinearAddrDemo
	shr	eax, 22
	mov	ebx, 4096
	mul	ebx
	mov	ecx, eax
	mov	eax, LinearAddrDemo
	shr	eax, 12
	and	eax, 03FFh	; 1111111111b (10 bits)
	mov	ebx, 4
	mul	ebx
	add	eax, ecx
	add	eax, PageTblBase1
	mov	dword [es:eax], ProcBar | PG_P | PG_USU | PG_RWW

	mov	eax, PageDirBase1
	mov	cr3, eax
	jmp	short .3
.3:
	nop

	ret

PagingDemoProc:
OffsetPagingDemoProc	equ	PagingDemoProc - $$
	mov	eax, LinearAddrDemo
	call	eax
	retf
LenPagingDemoAll	equ	$ - PagingDemoProc

foo:
OffsetFoo		equ	foo - $$
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, 'F'
	mov	[gs:((80 * 17 + 0) * 2)], ax	; 屏幕第 17 行, 第 0 列。
	mov	al, 'o'
	mov	[gs:((80 * 17 + 1) * 2)], ax	; 屏幕第 17 行, 第 1 列。
	mov	[gs:((80 * 17 + 2) * 2)], ax	; 屏幕第 17 行, 第 2 列。
	ret
LenFoo			equ	$ - foo

bar:
OffsetBar		equ	bar - $$
	mov	ah, 0Ch			; 0000: 黑底    1100: 红字
	mov	al, 'B'
	mov	[gs:((80 * 18 + 0) * 2)], ax	; 屏幕第 18 行, 第 0 列。
	mov	al, 'a'
	mov	[gs:((80 * 18 + 1) * 2)], ax	; 屏幕第 18 行, 第 1 列。
	mov	al, 'r'
	mov	[gs:((80 * 18 + 2) * 2)], ax	; 屏幕第 18 行, 第 2 列。
	ret
LenBar			equ	$ - bar

%include		"lib.inc"

SegCode32Len	equ	$-LABEL_SEG_CODE32

[section	.s16code]
align	32
[BITS	16]
LABEL_SEG_CODE16:
	mov	ax	,SelectorNormal
	mov	ds	,ax
	mov	es	,ax
	mov	fs	,ax
	mov	gs	,ax
	mov	ss	,ax

	mov	eax	,cr0
	and	eax	,7FFFFFFEh
	mov	cr0	,eax

LABEL_GO_BACK_TO_REAL:
	jmp	0:LABEL_REAL_ENTRY

Code16Len	equ		$-LABEL_SEG_CODE16

[section	.ldt]
align	32
LABEL_LDT:
LABEL_LDT_DESC_CODEA:Descriptor	0	,CodeALen-1	,DA_C+DA_32
LDTLen		equ		$-LABEL_LDT

SelectorLDTCodeA	equ	LABEL_LDT_DESC_CODEA-LABEL_LDT+SA_TIL

[section	.la]
align	32
[BITS	32]
LABEL_CODE_A:
	mov		ax	,SelectorVideo
	mov		gs	,ax

	mov		edi	,160*12
	mov		ah	,0ch
	mov		al	,'L'
	mov		[gs:edi]	,ax

	jmp		SelectorCode16:0

CodeALen	equ	$-LABEL_CODE_A

[section .sdest]
[BITS	32]
LABEL_SEG_CODE_DEST:
	;JMP	$
	mov		ax	,SelectorVideo
	mov		gs	,ax

	mov		edi	,(80*12+40)*2
	mov		ah	,0ch
	mov		al	,'c'
	mov		[gs:edi]	,ax

	mov		ax	,SelectorLDT
	lldt	ax

	jmp		SelectorLDTCodeA:0
	;retf

SegCodeDestLen		equ		$-LABEL_SEG_CODE_DEST

[section	.s3]
align	32
[BITS	32]
LABEL_STACK3:
	times	512		db	0
TopOfStack3		equ		$-LABEL_STACK3-1


[section	.ring3]
align	32
[BITS	32]
LABEL_CODE_RING3:
	mov		ax	,SelectorVideo
	mov		gs	,ax

	mov		edi	,(80*13+40)*2
	mov		ah	,0ch
	mov		al	,'3'
	mov		[gs:edi]	,ax

	call	SelectorCallGateTest:0
	jmp		$

SegCodeRing3Len		equ		$-LABEL_CODE_RING3

[section	.tss]
align	32
[BITS	32]
LABEL_TSS:
	DD	0
	DD	TopOfStack
	DD	SelectorStack
	DD	0
	DD	0
	DD	0
	DD	0
	DD	0
	DD	0
	DD	0
	DD	0
	DD	0
	DD	0
	DD	0
	DD	0
	DD	0
	DD	0
	DD	0
	DD	0
	DD	0
	DD	0
	DD	0
	DD	0
	DD	0
	DD	0
	DW	0
	DW	$-LABEL_TSS+2
	DB	0FFH
TSSLen	equ	$-LABEL_TSS

