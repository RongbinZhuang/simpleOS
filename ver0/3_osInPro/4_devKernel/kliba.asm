[section	.data]
extern	disp_pos
[section	.text]
global	disp_str
global	out_byte
global	in_byte
global	disp_color_str

disp_color_str:
	push	ebp
	mov	ebp, esp

	mov	esi, [ebp + 8]	; pszInfo
	mov	edi, [disp_pos]
	mov	ah, [ebp + 12]	; color
	.1:
	lodsb
	test	al, al
	jz	.2
	cmp	al, 0Ah	; 是回车吗?
	jnz	.3
	push	eax
	mov	eax, edi
	mov	bl, 160
	div	bl
	and	eax, 0FFh
	inc	eax
	mov	bl, 160
	mul	bl
	mov	edi, eax
	pop	eax
	jmp	.1
	.3:
	mov	[gs:edi], ax
	add	edi, 2
	jmp	.1

	.2:
	mov	[disp_pos], edi

	pop	ebp
	ret


disp_str:
	.pushReg:
		push	ebx
		push	esi
		push	edi
	mov		ebx		,esp
	mov		esi		,[ebx+16]
	mov		edi		,[disp_pos]
	mov		ah	,0fh
	.printEachByte:
		lodsb
		test	al	,al
		jz		.finiDisp
		cmp		al	,0ah
		jz		.breakLine
		mov		[gs:edi]	,ax
		add		edi		,2
		jmp		.printEachByte
	.breakLine:
		push	eax		
		mov		bl	,160
		mov		eax		,edi
		div		bl
		inc		eax
		mul		bl
		mov		edi		,eax
		pop		eax
		jmp		.printEachByte
	.finiDisp:
		mov		[disp_pos]		,edi
	.popReg:
		pop		edi
		pop		esi
		pop		ebx
	ret
out_byte:
	mov		edx		,[esp+4]
	mov		al	,[esp+8]
	out		dx	,al
	nop
	nop
	ret

in_byte:
	mov		edx		,[esp+4]
	xor		eax		,eax
	in		al	,dx
	nop
	nop
	ret
