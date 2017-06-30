
[section .text]
global _start:
_start:
	mov		ah	,0fh
	mov		al	,'K'
	mov		[gs:((80*1+40)*2)]	,ax
	jmp		$
