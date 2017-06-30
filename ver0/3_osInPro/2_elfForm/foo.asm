
extern choose

[section	.data]
num1st		dd		3
num2nd		dd		4

[section	.text]

global		_start
global		myprint

_start:
	push	DWORD[num2nd]
	push	DWORD[num1st]
	call	choose
	add		esp	,8
	mov		ebx	,0
	mov		eax	,1
	int		80h

myprint:
	mov		edx	,[esp+8]
	mov		ecx	,[esp+4]
	mov		ebx	,1
	mov		eax	,4
	int		80h
	ret
