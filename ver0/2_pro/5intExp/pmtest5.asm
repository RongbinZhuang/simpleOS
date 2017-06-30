%include		"pm.inc"

PageDirBase0		equ		200000h
PageTblBase0		equ		201000h
PageDirBase1		equ		210000h
PageTblBase1		equ		211000h

LinearAddrDemo		equ		00401000h
ProcFoo				equ		00401000h
ProcBar				equ		00501000h

ProcPagingDemo		equ		00301000h

org		0100h
	jmp		LABEL_BEGIN

[section	.gdt]
;GDT
	LABEL_GDT:
		Descriptor		0			,0				,0
	LABEL_DESC_NORMAL:
		Descriptor		0			,0ffffh			,DA_DRW
	LABEL_DESC_FLAT_C:
		Descriptor		0			,0fffffh		,DA_CR|DA_32|DA_LIMIT_4K
	LABEL_DESC_FLAT_RW:
		Descriptor		0			,0fffffh		,DA_DRW|DA_LIMIT_4K
	LABEL_DESC_CODE32:
		Descriptor		0			,SegCode32Len-1	,DA_CR|DA_32
	LABEL_DESC_CODE16:
		Descriptor		0			,SegCode16Len-1	,DA_C
	LABEL_DESC_DATA:
		Descriptor		0			,DataLen-1		,DA_DRW
	LABEL_DESC_STACK:
		Descriptor		0			,TopOfStack		,DA_DRWA|DA_32
	LABEL_DESC_VIDEO:
		Descriptor		0b8000h		,0ffffh			,DA_DRW
GdtLen				equ		$-LABEL_GDT
GdtPtr				dw		GdtLen-1
					dd		0
;Selector					
	SelectorNormal		equ	LABEL_DESC_NORMAL	- LABEL_GDT
	SelectorFlatC		equ	LABEL_DESC_FLAT_C	- LABEL_GDT
	SelectorFlatRW		equ	LABEL_DESC_FLAT_RW	- LABEL_GDT
	SelectorCode32		equ	LABEL_DESC_CODE32	- LABEL_GDT
	SelectorCode16		equ	LABEL_DESC_CODE16	- LABEL_GDT
	SelectorData		equ	LABEL_DESC_DATA		- LABEL_GDT
	SelectorStack		equ	LABEL_DESC_STACK	- LABEL_GDT
	SelectorVideo		equ	LABEL_DESC_VIDEO	- LABEL_GDT

[section	.idt]
	align	32
	[BITS	32]
LABEL_IDT:
	%rep	255
		Gate	SelectorCode32	,SpuriousHandler	\
				,0				,DA_386IGate
	%endrep
IdtLen				equ		$-LABEL_IDT
IdtPtr				equ		IdtLen-1
					dd		0

[section	.data1]
	align	32
	[BITS	32]
LABEL_DATA:
	;实模式下符号
		_szPMMessage:
			db	"In Protect Mode now.",0ah,0ah,0
		_szMemChkTitle:
			db	"BaseAddrL BaseAddrH LengthL LengthH Type",0ah,0
		_szRAMSize:
			db	"RAM Size",0ah,0
		_szReturn:
			db	0ah,0
		_wSPValueInRealMode:
			dw	0
		_dwMCRNumber:
			dd	0
		_dwDispPos:
			dd	(80*10+20)*2
		_dwMemSize:
			dd	0
		_ARDStruct:
			_dwBaseAddrLow:		dd	0
			_dwBaseAddrHigh:	dd	0
			_dwLengthLow:		dd	0
			_dwLengthHigh:		dd	0
			_dwType:			dd	0
		_PageTableNumber:
			dd	0
		_SavedIDTR:
			times	2	dd	0
		_SavedIMREG:
			db	0
		_MemChkBuf:
			times	256	db	0
	;保护模式下符号
		szPMMessage		equ	_szPMMessage	- $$
		szMemChkTitle	equ	_szMemChkTitle	- $$
		szRAMSize		equ	_szRAMSize	- $$
		szReturn		equ	_szReturn	- $$
		dwDispPos		equ	_dwDispPos	- $$
		dwMemSize		equ	_dwMemSize	- $$
		dwMCRNumber		equ	_dwMCRNumber	- $$
		ARDStruct		equ	_ARDStruct	- $$
			dwBaseAddrLow	equ	_dwBaseAddrLow	- $$
			dwBaseAddrHigh	equ	_dwBaseAddrHigh	- $$
			dwLengthLow		equ	_dwLengthLow	- $$
			dwLengthHigh	equ	_dwLengthHigh	- $$
			dwType		equ	_dwType		- $$
		MemChkBuf		equ	_MemChkBuf	- $$
		SavedIDTR		equ	_SavedIDTR	- $$
		SavedIMREG		equ	_SavedIMREG	- $$
		PageTableNumber		equ	_PageTableNumber- $$
DataLen				equ		$-LABEL_DATA
		
[section	.gs]
	align	32
	[BITS	32]
LABEL_STACK:
	times	512		db		0
TopOfStack			equ	$-LABEL_STACK-1

[section	.s16]
	[BITS	16]
LABEL_BEGIN:
	mov		ax	,cs
	mov		ds	,ax
	mov		es	,ax
	mov		ss	,ax
	mov		sp	,0100h

	mov		[LABEL_GO_BACK_TO_REAL+3]	,ax
	mov		[_wSPValueInRealMode]	,sp

	mov		ebx	,0
	mov		di	,_MemChkBuf

	.loop:
		mov		eax	,0e820h
		mov		ecx	,20
		mov		edx	,0534d4150h
		int		15h
		jc		LABEL_MEM_CHK_FAIL
		add		di	,20
		inc		DWORD[_dwMCRNumber]
		cmp		ebx	,0
		jne		.loop
		jmp		LABEL_MEM_CHK_OK
	LABEL_MEM_CHK_FAIL: 
		mov		DWORD[_dwMCRNumber]	,0
	LABEL_MEM_CHK_OK:
	;initialize descriptor
		mov		ax	,cs
		movzx	eax	,ax
		shl		eax	,4
		add		eax	,LABEL_SEG_CODE16
		mov		WORD[LABEL_DESC_CODE16+2]	,ax
		shr		eax	,16
		mov		BYTE[LABEL_DESC_CODE16+4]	,al
		mov		BYTE[LABEL_DESC_CODE16+7]	,ah

		xor		eax	,eax
		mov		ax	,cs
		shl		eax	,4
		add		eax	,LABEL_SEG_CODE32
		mov		WORD[LABEL_DESC_CODE32+2]	,ax
		shr		eax	,16
		mov		BYTE[LABEL_DESC_CODE32+4]	,al
		mov		BYTE[LABEL_DESC_CODE32+7]	,ah

		xor		eax	,eax
		mov		ax	,ds
		shl		eax	,4
		add		eax	,LABEL_DATA
		mov		WORD[LABEL_DESC_DATA+2]	,ax
		shr		eax	,16
		mov		BYTE[LABEL_DESC_DATA+4]	,al
		mov		BYTE[LABEL_DESC_DATA+7]	,ah

		xor		eax	,eax
		mov		ax	,ds
		shl		eax	,4
		add		eax	,LABEL_STACK
		mov		WORD[LABEL_DESC_STACK+2]	,ax
		shr		eax	,16
		mov		BYTE[LABEL_DESC_STACK+4]	,al
		mov		BYTE[LABEL_DESC_STACK+7]	,ah
	xor		eax	,eax
	mov		ax	,ds
	shl		eax	,4
	add		eax	,LABEL_GDT		; eax <- gdt 基地址
	mov		DWORD[GdtPtr+2]	,eax	; [GdtPtr+2] <- gdt 基地址
	xor		eax	,eax
	mov		ax	,ds
	shl		eax	,4
	add		eax	,LABEL_IDT		; eax <- idt 基地址
	mov		DWORD[IdtPtr+2]	,eax	; [IdtPtr+2] <- idt 基地址
	sidt	[_SavedIDTR]

	in		al	,21h
	mov		[_SavedIMREG]	,al
	cli
	lgdt	[GdtPtr]
	lidt	[IdtPtr]

	in		al	,92h
	or		al	,00000010b
	out		92h	,al

	mov		eax	,cr0
	or		eax	,1
	mov		cr0	,eax

	jmp		DWORD SelectorCode32:0	
LABEL_REAL_ENTRY:		; 从保护模式跳回到实模式就到了这里
	mov		ax	,cs
	mov		ds	,ax
	mov		es	,ax
	mov		ss	,ax
	mov		sp	,[_wSPValueInRealMode]

	lidt	[_SavedIDTR]	; 恢复 IDTR 的原值

	mov		al	,[_SavedIMREG]	; ┓恢复中断屏蔽寄存器(IMREG)的原值
	out		21h	,al			; ┛

	in		al	,92h		; ┓
	and		al	,11111101b	; ┣ 关闭 A20 地址线
	out		92h	,al		; ┛

	sti				; 开中断

	mov		ax	,4c00h	; ┓
	int		21h		; ┛回到 DOS

SegBeginLen		equ	$-LABEL_BEGIN

[section	.s32]
	align	32
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

;	call	Init8259A

;	int		080h
;	sti
;	jmp		$

	push	szPMMessage
	call	DispStr
	add		esp	,4

	push	szMemChkTitle
	call	DispStr
	add		esp	,4

	jmp		SelectorCode16:0

_SpuriousHandler:
	mov		ah	,0f3h
	mov		al	,'b'
	mov		[gs:((80*2+40)*2)]	,ax
	iretd
SpuriousHandler		equ	_SpuriousHandler-$$

_ClockHandler:
	inc		BYTE[gs:((80*2+40)*2)]
	mov		al	,20h
	out		20h	,al
	iretd
ClockHandler		equ	_ClockHandler-$$
%include		"lib.inc"
SegCode32Len		equ	$-LABEL_SEG_CODE32
	
[section	.s16code]
	align	32
	[BITS	16]
LABEL_SEG_CODE16:
	push	szPMMessage
	call	DispStr
	add		esp	,4

	mov		ax	,SelectorNormal
	mov		ds	,ax
	mov		es	,ax
	mov		fs	,ax
	mov		gs	,ax
	mov		ss	,ax

	mov		eax	,cr0
	and		al	,11111110b
	mov		cr0	,eax

LABEL_GO_BACK_TO_REAL:
	jmp		0:LABEL_REAL_ENTRY

SegCode16Len		equ	$-LABEL_SEG_CODE16
