;pmtest3.asm
;nasm pmtest3.asm -o pmtest3.com

%include		"pm.inc"		;常量，宏

org 0100h
	jmp LABEL_BEGIN

[section .gdt]
;GDT
;                            段基址,       段界限     , 属性
LABEL_GDT:         Descriptor       0,                 0, 0     	
	; 空描述符
LABEL_DESC_NORMAL: Descriptor       0,            0ffffh, DA_DRW	
	; Normal 描述符
LABEL_DESC_CODE32: Descriptor       0,  SegCode32Len-1,DA_C + DA_32	
	; 非一致代码段, 32
LABEL_DESC_CODE16: Descriptor       0,            0ffffh, DA_C		; 非一致代码段, 16
LABEL_DESC_DATA:   Descriptor       0,       DataLen - 1, DA_DRW+DA_DPL1	; Data
LABEL_DESC_STACK:  Descriptor       0,        TopOfStack, DA_DRWA + DA_32; Stack, 32 位
LABEL_DESC_LDT:    Descriptor       0,        LDTLen - 1, DA_LDT	; LDT
LABEL_DESC_VIDEO:  
	Descriptor	0B8000H	,0FFFFH	,DA_DRW+DA_DPL3
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
; END of [SECTION .gdt]

[section .s16]
align 32
[BITS	32]
LABEL_DATA:
	SPValueInRealMode	dw	0
PMMessage:		db		"In Protect Mode now.",0
OffsetPMMessage	equ		PMMessage - $$
StrTest:		db		"HELLOWORLD",0
OffsetStrText	equ		StrTest-$$
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
	mov		[SPValueInRealMode]		,sp

	mov		ax	,cs
	movzx	eax	,ax
	shl		eax	,4
	add		eax	,LABEL_SEG_CODE16
	mov		word[LABEL_DESC_CODE16+2]	,ax
	shr		eax	,16
	mov		byte[LABEL_DESC_CODE16+4]	,al
	mov		byte[LABEL_DESC_CODE16+7]	,ah

	xor		eax	,eax
	mov		ax	,cs
	movzx	eax	,ax
	shl		eax	,4
	add		eax	,LABEL_TSS
	mov		WORD[LABEL_DESC_TSS+2]	,ax
	shr		eax	,16
	mov		BYTE[LABEL_DESC_TSS+4]	,al
	mov		BYTE[LABEL_DESC_TSS+7]	,ah

	xor		eax	,eax
	mov		ax	,cs
	movzx	eax	,ax
	shl		eax	,4
	add		eax	,LABEL_CODE_RING3
	mov		word[LABEL_DESC_CODE_RING3+2]	,ax
	shr		eax	,16
	mov		byte[LABEL_DESC_CODE_RING3+4]	,al
	mov		byte[LABEL_DESC_CODE_RING3+7]	,ah

	xor		eax	,eax
	mov		ax	,cs
	movzx	eax	,ax
	shl		eax	,4
	add		eax	,LABEL_STACK3
	mov		word[LABEL_DESC_STACK3+2]	,ax
	shr		eax	,16
	mov		byte[LABEL_DESC_STACK3+4]	,al
	mov		byte[LABEL_DESC_STACK3+7]	,ah

	xor		eax	,eax
	mov		ax	,cs
	movzx	eax	,ax
	shl		eax	,4
	add		eax	,LABEL_SEG_CODE_DEST
	mov		word[LABEL_DESC_CODE_DEST+2]	,ax
	shr		eax	,16
	mov		byte[LABEL_DESC_CODE_DEST+4]	,al
	mov		byte[LABEL_DESC_CODE_DEST+7]	,ah

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
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_LDT
	mov	word [LABEL_DESC_LDT + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_LDT + 4], al
	mov	byte [LABEL_DESC_LDT + 7], ah

	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_CODE_A
	mov	word [LABEL_LDT_DESC_CODEA + 2], ax
	shr	eax, 16
	mov	byte [LABEL_LDT_DESC_CODEA + 4], al
	mov	byte [LABEL_LDT_DESC_CODEA + 7], ah

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
	mov		sp	,[SPValueInRealMode]

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
	mov		ax	,SelectorVideo
	mov		gs	,ax
	mov		ax	,SelectorStack
	mov		ss	,ax

	mov		esp	,TopOfStack

	mov		ah	,0ch
	xor		esi	,esi
	xor		edi	,edi
	mov		esi	,OffsetPMMessage
	mov		edi	,40

	cld
	
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

DispReturn:
	push	eax
	push	ebx
	mov		eax	,edi
	mov		bl	,160
	div		bl
	and		eax	,0ffh
	inc		eax
	mov		bl	,160
	mul		bl
	mov		edi	,eax
	pop		ebx
	pop		eax

	ret
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
	and	al	,11111110b
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
