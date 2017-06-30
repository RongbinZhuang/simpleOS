org		0100h

mov		ax	,0B800h
mov		gs	,ax
mov		ah	,0f3h
mov		al	,'B'
mov		[gs:((80*6+40)*2)]	,ax

jmp		$


