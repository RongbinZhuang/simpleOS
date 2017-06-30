[section	.data]
strHello:		db		"Hello World",0ah
strLen			equ		$-strHello

[section	.text]

global	_start
_start:
	mov		edx	,strLen
	mov		ecx	,strHello
	mov		ebx	,1
	mov		eax	,4
	int		80h
	mov		ebx	,0
	mov		eax	,1
	int		80h
