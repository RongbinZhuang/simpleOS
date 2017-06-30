;%define		_BOOT_DEBUG_

%ifdef	_BOOT_DEBUG_ 
	org		0100h
	BaseOfStack		equ		0100h
%else
	org		07c00h
	BaseOfStack		equ		07c00h
%endif

BaseOfLoader		equ		09000h
OffsetOfLoader		equ		0100h
;BPB数据结构以及其他相关保留项
	jmp short LABEL_START		; Start to boot.
	nop				; 这个 nop 不可少

%include			"fat12hdr.inc"
;origin
;LABEL_START:
	;	mov		ax	,cs
	;	mov		ds	,ax
	;	mov		es	,ax
	;
	;	mov		ax	,bootmessage
	;	mov		bp	,ax
	;	mov		cx	,16
	;	mov		ax	,01301h
	;	mov		bx	,000ch
	;	mov		dl	,0
	;	int		10h
	;
	;	jmp		$
	;
	;bootmessage:
	;	db	"Hello My OS"
	;times		510-($-$$)	db	0
	;dw		0aa55h

;load 
LABEL_START:
	mov		ax	,cs
	mov		ds	,ax
	mov		es	,ax
	mov		ss	,ax
	mov		sp	,BaseOfStack

	mov		ax	,0600h
	mov		bx	,0700h
	mov		cx	,0
	mov		dx	,0184fh
	int		10h
	mov		dh	,0
	call	DispStr

	xor		ah	,ah
	xor		dl	,dl
	int		13h

	mov		WORD[wSectorNo]	,SectorNoOfRootDirectory
LABEL_SEARCH_IN_ROOT_DIR_BEGIN:
	cmp		WORD[wRootDirSizeForLoop]	,0
	jz		LABEL_NO_LOADERBIN
	dec		WORD[wRootDirSizeForLoop]
	mov		ax	,BaseOfLoader
	mov		es	,ax
	mov		bx	,OffsetOfLoader
	mov		ax	,[wSectorNo]
	mov		cl	,1
	call	ReadSector
	mov		si	,LoaderFileName
	mov		di	,OffsetOfLoader

	cld
	mov		dx	,10h
LABEL_SEARCH_FOR_LOADERBIN:
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
	mov		si	,LoaderFileName
	jmp		LABEL_SEARCH_FOR_LOADERBIN
LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR:
	add		WORD[wSectorNo]	,1
	jmp		LABEL_SEARCH_IN_ROOT_DIR_BEGIN
LABEL_NO_LOADERBIN:
	mov		dh	,2
	call	DispStr
	jmp		$
LABEL_FILENAME_FOUND:
	mov		ax	,RootDirSectors
	and		di	,0ffe0h
	add		di	,01ah
	mov		cx	,WORD[es:di]
	push	cx
	add		cx	,ax
	add		cx	,DeltaSectorNo
	mov		ax	,BaseOfLoader
	mov		es	,ax
	mov		bx	,OffsetOfLoader
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
	mov		dh	,1
	call	DispStr
	jmp		BaseOfLoader:OffsetOfLoader

wRootDirSizeForLoop	dw	RootDirSectors	; Root Directory 占用的扇区数, 在循环中会递减至零.
wSectorNo		dw	0		; 要读取的扇区号
bOdd			db	0		; 奇数还是偶数

;============================================================================
;字符串
;----------------------------------------------------------------------------
LoaderFileName		db	"LOADER  BIN", 0	; LOADER.BIN 之文件名
; 为简化代码, 下面每个字符串的长度均为 MessageLength
MessageLength		equ	9
BootMessage:		db	"Booting  "; 9字节, 不够则用空格补齐. 序号 0
Message1		db	"Ready.   "; 9字节, 不够则用空格补齐. 序号 1
Message2		db	"No LOADER"; 9字节, 不够则用空格补齐. 序号 2
;
DispStr:
	mov	ax, MessageLength
	mul	dh
	add	ax, BootMessage
	mov	bp, ax			; ┓
	mov	ax, ds			; ┣ ES:BP = 串地址
	mov	es, ax			; ┛
	mov	cx, MessageLength	; CX = 串长度
	mov	ax, 01301h		; AH = 13,  AL = 01h
	mov	bx, 0007h		; 页号为0(BH = 0) 黑底白字(BL = 07h)
	mov	dl, 0
	int	10h			; int 10h
	ret


ReadSector:
	; -----------------------------------------------------------------------
	; 怎样由扇区号求扇区在磁盘中的位置 (扇区号 -> 柱面号, 起始扇区, 磁头号)
	; -----------------------------------------------------------------------
	; 设扇区号为 x
	;                           ┌ 柱面号 = y >> 1
	;       x           ┌ 商 y ┤
	; -------------- => ┤      └ 磁头号 = y & 1
	;  每磁道扇区数     │
	;                   └ 余 z => 起始扇区号 = z + 1
	push	bp
	mov	bp, sp
	sub	esp, 2			; 辟出两个字节的堆栈区域保存要读的扇区数: byte [bp-2]

	mov	byte [bp-2], cl
	push	bx			; 保存 bx
	mov	bl, [BPB_SecPerTrk]	; bl: 除数
	div	bl			; y 在 al 中, z 在 ah 中
	inc	ah			; z ++
	mov	cl, ah			; cl <- 起始扇区号
	mov	dh, al			; dh <- y
	shr	al, 1			; y >> 1 (其实是 y/BPB_NumHeads, 这里BPB_NumHeads=2)
	mov	ch, al			; ch <- 柱面号
	and	dh, 1			; dh & 1 = 磁头号
	pop	bx			; 恢复 bx
	; 至此, "柱面号, 起始扇区, 磁头号" 全部得到 ^^^^^^^^^^^^^^^^^^^^^^^^
	mov	dl, [BS_DrvNum]		; 驱动器号 (0 表示 A 盘)
.GoOnReading:
	mov	ah, 2			; 读
	mov	al, byte [bp-2]		; 读 al 个扇区
	int	13h
	jc	.GoOnReading		; 如果读取错误 CF 会被置为 1, 这时就不停地读, 直到正确为止

	add	esp, 2
	pop	bp

	ret

;	需要注意的是, 中间需要读 FAT 的扇区到 es:bx 处, 所以函数一开始保存了 es 和 bx
GetFATEntry:
	push	es
	push	bx
	push	ax
	mov	ax, BaseOfLoader; `.
	sub	ax, 0100h	;  | 在 BaseOfLoader 后面留出 4K 空间用于存放 FAT
	mov	es, ax		; /
	pop	ax
	mov	byte [bOdd], 0
	mov	bx, 3
	mul	bx			; dx:ax = ax * 3
	mov	bx, 2
	div	bx			; dx:ax / 2  ==>  ax <- 商, dx <- 余数
	cmp	dx, 0
	jz	LABEL_EVEN
	mov	byte [bOdd], 1
LABEL_EVEN:;偶数
	; 现在 ax 中是 FATEntry 在 FAT 中的偏移量,下面来
	; 计算 FATEntry 在哪个扇区中(FAT占用不止一个扇区)
	xor	dx, dx			
	mov	bx, [BPB_BytsPerSec]
	div	bx ; dx:ax / BPB_BytsPerSec
		   ;  ax <- 商 (FATEntry 所在的扇区相对于 FAT 的扇区号)
		   ;  dx <- 余数 (FATEntry 在扇区内的偏移)。
	push	dx
	mov	bx, 0 ; bx <- 0 于是, es:bx = (BaseOfLoader - 100):00
	add	ax, SectorNoOfFAT1 ; 此句之后的 ax 就是 FATEntry 所在的扇区号
	mov	cl, 2
	call	ReadSector ; 读取 FATEntry 所在的扇区, 一次读两个, 避免在边界
			   ; 发生错误, 因为一个 FATEntry 可能跨越两个扇区
	pop	dx
	add	bx, dx
	mov	ax, [es:bx]
	cmp	byte [bOdd], 1
	jnz	LABEL_EVEN_2
	shr	ax, 4
LABEL_EVEN_2:
	and	ax, 0FFFh

LABEL_GET_FAT_ENRY_OK:

	pop	bx
	pop	es
	ret
;----------------------------------------------------------------------------

times		510-($-$$)	db	0
dw			0aa55h
