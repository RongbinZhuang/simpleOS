
%include "sconst.inc"

_NR_get_ticks       equ 0 ; 要跟 global.c 中 sys_call_table 的定义相对应！
_NR_write			equ 1
_NR_sendrec			equ 2
_NR_printx			equ 1
INT_VECTOR_SYS_CALL equ 0x90

global	get_ticks ; 导出符号
global	write
global	sendrec
global	printx

bits 32
[section .text]

get_ticks:
	mov	eax, _NR_get_ticks
	int	INT_VECTOR_SYS_CALL
	ret

write:
	mov     ebx, [esp + 4]
	mov     ecx, [esp + 8]
	mov     eax, _NR_write
	int     INT_VECTOR_SYS_CALL
	ret

sendrec:
	mov	eax, _NR_sendrec
	mov	ebx, [esp + 4]	; function
	mov	ecx, [esp + 8]	; src_dest
	mov	edx, [esp + 12]	; p_msg
	int	INT_VECTOR_SYS_CALL
	ret

printx:
	mov	eax, _NR_printx
	mov	edx, [esp + 4]
	int	INT_VECTOR_SYS_CALL
	ret


