org		0100h

jmp		LABEL_START

BaseOfStack			equ	0100h
BaseOfKernelFile	equ 08000h
OffsetOfKernelFile	equ 0h

%include			"fat12hdr.inc"
wRootDirSizeForLoop	dw	RootDirSectors	; Root Directory 占用的扇区数
wSectorNo		dw	0		; 要读取的扇区号
bOdd			db	0		; 奇数还是偶数
dwKernelSize		dd	0		; KERNEL.BIN 文件大小

KernelFileName		db	"KERNEL  BIN", 0	; KERNEL.BIN 之文件名
; 为简化代码, 下面每个字符串的长度均为 MessageLength
MessageLength		equ	9
LoadMessage:		db	"Loading  "
Message1		db	"Ready.   "
Message2		db	"No KERNEL"


LABEL_START:
;origin version
	;	mov		ax	,0B800h
	;	mov		gs	,ax
	;	mov		ah	,07bh
	;	mov		al	,'B'
	;	mov		[gs:((80*6+40)*2)]	,ax
	;
	;	jmp		$
;loading kernel
	mov		ax	,cs
	mov		ds	,ax
	mov		es	,ax
	mov		ss	,ax
	mov		sp	,BaseOfStack

	
	mov		dh	,0
	call	DispStr
		
	mov		WORD[wSectorNo]	,SectorNoOfRootDirectory
	xor		ah	,ah
	xor		dl	,dl
	int		13h
LABEL_SEARCH_IN_ROOT_DIR_BEGIN:
	cmp		WORD[wRootDirSizeForLoop]	,0
	jz		LABEL_NO_KERNELBIN
	dec		WORD[wRootDirSizeForLoop]
	mov		ax	,BaseOfKernelFile
	mov		es	,ax
	mov		bx	,OffsetOfKernelFile
	mov		ax	,[wSectorNo]
	mov		cl	,1
	call	ReadSector
	
	mov		si	,KernelFileName
	mov		di	,OffsetOfKernelFile
	cld
	mov		dx	,10h
LABEL_SEARCH_FOR_KERNELBIN:
	cmp		dx	,0
	jz		LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR
	dec		dx
	mov		cx	,11
LABEL_CMP_FILENAME:
	cmp		cx	,0
	jz		LABEL_FILENAME_FOUND
	dec		cx
	lodsb
	cmp		al	,BYTE[es:di]
	jz		LABEL_GO_ON
	jmp		LABEL_DIFFERENT
LABEL_GO_ON:
	inc		di
	jmp		LABEL_CMP_FILENAME
LABEL_DIFFERENT:
	and		di	,0ffe0h
	add		di	,20h
	mov		si	,KernelFileName
	jmp		LABEL_SEARCH_IN_ROOT_DIR_BEGIN
LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR:
	add		WORD[wSectorNo]	,1
	jmp		LABEL_SEARCH_IN_ROOT_DIR_BEGIN

LABEL_NO_KERNELBIN:
	mov		dh	,2
	call	DispStr
%ifdef _LOADER_DEBUG_
	mov		ax	,4c00h
	int		21h
%else
	jmp		$
%endif
LABEL_FILENAME_FOUND:
	mov		ax	,RootDirSectors
	and		di	,0fff0h
	push	eax
	mov		eax ,[es:di+01ch]
	mov		DWORD[dwKernelSize]	,eax
	pop		eax

	add		di	,01ah
	mov		cx	,WORD[es:di]
	push	cx
	add		cx	,ax
	add		cx	,DeltaSectorNo
	mov		ax	,BaseOfKernelFile
	mov		es	,ax
	mov		bx	,OffsetOfKernelFile
	mov		ax	,cx
LABEL_GOON_LOADING_FILE:
	push	ax
	push	bx
	mov		ah	,0eh
	mov		al	,'.'
	mov		bl	,0fh
	int		10h
	pop		bx
	pop		ax

	mov		cl	,1
	call	ReadSector
	pop		ax
	call	GetFATEntry
	cmp		ax	,0fffh
	jz		LABEL_FILE_LOADED
	push	ax
	mov		dx	,RootDirSectors
	add		ax	,dx
	add		ax	,DeltaSectorNo
	add		bx	,[BPB_BytsPerSec]
	jmp		LABEL_GOON_LOADING_FILE
LABEL_FILE_LOADED:
	call	KillMotor
	mov		dh	,1
	call	DispStr
	jmp		$

DispStr:
	mov		ax	,MessageLength
	mul		dh
	add		ax	,LoadMessage
	mov		bp	,ax
	mov		ax	,ds
	mov		es	,ax
	mov		cx	,MessageLength
	mov		ax	,01301h
	mov		bx	,0007h
	mov		dl	,0
	add		dh	,3
	int		10h
	ret
ReadSector:
	push	bp
	mov		bp	,sp
	sub		esp		,2
	mov		BYTE[bp-2]	,cl
	push	bx
	mov		bl	,[BPB_SecPerTrk]
	div		bl
	inc		ah
	mov		cl	,ah
	mov		dh	,al
	shr		al	,1
	mov		ch	,al
	and		dh	,1
	pop		bx
	mov		dl	,[BS_DrvNum]
.GoOnReading:
	mov		ah	,2
	mov		al	,BYTE[bp-2]
	int		13h
	jc		.GoOnReading

	add		esp		,2
	pop		bp
	ret 
GetFATEntry:
	push	es
	push	bx
	push	ax
	mov		ax	,BaseOfKernelFile
	sub		ax	,0100h
	mov		es	,ax
	pop		ax
	mov		BYTE[bOdd]	,0
	mov		bx	,3
	mul		bx	
	mov		bx	,2
	div		bx 
	cmp		dx	,0
	jz		LABEL_EVEN
	mov		BYTE[bOdd]	,1
LABEL_EVEN:
	xor		dx	,dx
	mov		bx	,[BPB_BytsPerSec]
	div		bx
	push	dx
	mov		bx	,0
	mov		cl	,2
	call	ReadSector
	pop		dx
	add		bx	,dx
	mov		ax	,[es:bx]
	cmp		BYTE[bOdd]	,1
	jnz		LABEL_EVEN_2
	shr		ax	,4
LABEL_EVEN_2:
	and		ax	,0fffh
LABEL_GET_FAT_ENTRY_OK:
	pop		bx
	pop		es
	ret
KillMotor:
	push	dx
	mov		dx	,03f2h
	mov		al	,0
	out		dx	,al
	pop		dx
	ret
