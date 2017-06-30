org		07c00h
jmp		START

;.inc file included
	%include	"fat12hdr.inc"
	%include	"load.inc"
;constant define
	wDataSector			equ	RootDirSectors+DeltaSectorNo
	wSectorNo			dw	0
	bOdd				db	0
	LOADERNAME			db	"LOADER  BIN" ,0
	MESSAGELENGTH		equ	9
	MESSAGE:			db	"BOOTING  "
		.1:				db	"READY    "
		.2:				db	"NO LOADER"
;variable define
	pBaseOfStack		equ	07c00h
	wRootDirSizeForLoop dw	RootDirSectors
	bStrIndex			db	00h
	wDispPos			dw	0000h
;function define
	PRINTSTR:
		.pushReg:
			push	es
		mov		ax	,ds
		mov		es	,ax
		mov		ax	,MESSAGELENGTH
		mul		BYTE[bStrIndex]
		add		ax	,MESSAGE
		mov		bp	,ax
		mov		ax	,01301h
		mov		bx	,0007h
		mov		cx	,MESSAGELENGTH
		mov		dx	,[wDispPos]
		int		10h
		.popReg:
			pop		es
		ret
	READSECTOR:
		mov		dh	,[BPB_SecPerTrk]
		div		dh
		mov		dh	,al
		and		dh	,1
		mov		dl	,[BS_DrvNum]
		mov		ch	,al
		shr		ch	,1
		mov		al	,cl
		inc		ah
		mov		cl	,ah
		mov		ah	,02h
		.keepReading:
			int		13h 
			jc		.keepReading
		ret
	GETFATENTRY:
		.pushReg:
			push	es
			push	bx
		mov		dx	,BaseOfLoader
		sub		dx	,0100h
		mov		es	,dx
		mov		BYTE[bOdd]	,0
		mov		bx	,3
		mul		bx
		mov		bx	,2
		div		bx
		cmp		dx	,0
		and		dl	,1
		mov		BYTE[bOdd]	,dl
		xor		dx	,dx
		mov		bx	,WORD[BPB_BytsPerSec]
		div		bx
		push	dx
		mov		bx	,0
		add		ax	,SectorNoOfFAT1
		mov		cl	,2
		call	READSECTOR
		pop		dx
		add		bx	,dx
		mov		ax	,[es:bx]
		cmp		BYTE[bOdd]	,1
		jnz		.isEven
		shr		ax	,4
		.isEven:
			and		ax	,0fffh
		.popReg:
			pop		bx
			pop		es
		ret
	PRINTSPOT:
		.pushReg:
			push	bx
			push	ax
			push	es
		mov		ax	,0b800h
		mov		es	,ax
		mov		ah	,07h
		mov		al	,'.'
		mov		bx	,[wDispPos]
		mov		[es:bx]	,ax
		.popReg:
			pop		es
			pop		ax
			pop		bx
		ret
START:
	.initSeg:
		mov		ax	,cs
		mov		ds	,ax
		mov		es	,ax
		mov		ss	,ax
		mov		sp	,pBaseOfStack
	.initScreen:
		mov		ax	,0600h
		mov		bx	,0000h
		mov		cx	,0
		mov		dx	,0184fh
		int		10h
		mov		WORD[wDispPos]	,0000h
		mov		BYTE[bStrIndex]	,00h
		call	PRINTSTR
	.rstDriver:
		xor		ah	,ah
		xor		dl	,dl
		int		13h
	push	es
	mov		ax	,BaseOfLoader
	mov		es	,ax
	mov		bx	,OffsetOfLoader
	mov		WORD[wSectorNo]		,SectorNoOfRootDirectory
	.findFile:
		cmp		WORD[wRootDirSizeForLoop]	,0
		jz		.failFindFile
		dec		WORD[wRootDirSizeForLoop]
		mov		ax	,[wSectorNo]
		mov		cl	,1
		call	READSECTOR
		mov		dx	,10h
		mov		di	,OffsetOfLoader
		mov		si	,LOADERNAME
		cld
		.checkEachFile:
			cmp		dx	,0
			jz		.goNextSector
			dec		dx
			mov		cx	,11
			.cmpFileName:
				cmp		cx	,0
				jz		.sucFindFile
				dec		cx
				lodsb	
				cmp		al	,[es:di]
				jnz		.failCmpName
				inc		di
				jmp		.cmpFileName
			.failCmpName:
				and		di	,0ffe0h
				add		di	,20h
				mov		si	,LOADERNAME
				jmp		.checkEachFile
		.goNextSector:
			inc		WORD[wSectorNo]
			jmp		.findFile
	.failFindFile:
		pop		es
		mov		WORD[wDispPos]	,0200h
		mov		BYTE[bStrIndex]	,02h
		call	PRINTSTR
		jmp		$
	.sucFindFile:
		and		di	,0ffe0h
		add		di	,01ah
		mov		ax	,WORD[es:di]
		push	ax
		mov		WORD[wDispPos]	,12
	.loadFile:
		add		WORD[wDispPos]	,2
		call	PRINTSPOT
		add		ax	,wDataSector
		mov		cl	,1
		call	READSECTOR
		pop		ax
		call	GETFATENTRY
		cmp		ax	,0fffh
		jz		.sucLoadFile
		push	ax	
		add		bx	,[BPB_BytsPerSec]
		jmp		.loadFile
	.sucLoadFile:
		pop		es
		mov		WORD[wDispPos]	,0100h
		mov		BYTE[bStrIndex]	,01h
		call	PRINTSTR
	jmp		BaseOfLoader:OffsetOfLoader
	;jmp		$

times	510-($-$$)	db 0
dw		0aa55h
