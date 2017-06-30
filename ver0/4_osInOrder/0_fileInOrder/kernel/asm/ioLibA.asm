[section	.data]
[section	.text]
global	out_byte
global	in_byte

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
