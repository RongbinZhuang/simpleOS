org		0100h
jmp		START

;include file
	%include		"fat12hdr.inc"
	%include		"load.inc"
	%include		"pm.inc"

[section	data1]
align	32
DATA:
	;gdt
		GDT:			
			Descriptor  0,  0, 0
		DESC_FLAT_C:
			Descriptor  0,  0fffffh, DA_CR  | DA_32 | DA_LIMIT_4K
		DESC_FLAT_RW:		
			Descriptor  0,  0fffffh, DA_DRW | DA_32 | DA_LIMIT_4K
		DESC_VIDEO:		
			Descriptor	0B8000h,0ffffh, DA_DRW | DA_DPL3
		GdtLen			equ	$ - GDT
		GdtPtr			dw	GdtLen - 1				; 段界限
						dd	BaseOfLoaderPhyAddr + GDT		; 基地址
		SelectorFlatC	equ	DESC_FLAT_C	- GDT
		SelectorFlatRW	equ	DESC_FLAT_RW- GDT
		SelectorVideo	equ	DESC_VIDEO	- GDT + SA_RPL3
	;data in real mode
		;const define
			wDataSector			equ	RootDirSectors+DeltaSectorNo
			KERNELNAME			db	"KERNEL  BIN",0
			MESSAGELENGTH		equ	9
			pMESSAGE:			db	"LOADING  "
				.1:					db	"READY    "
				.2:					db	"NO KERNEL"
			_szMemChkTitle:		
								db	"BaseAddrL "
								db	"BaseAddrH "
								db	"LengthLow "
								db	"LengthHigh"
								db	"   Type", 0Ah, 0
		;variable define
			_dwMCRNumber		dd	0
			_szRAMSize			db	"RAM size:",0
			_szReturn			db	0ah,0
			_dwDispPos			dd	(80*6+0)*2
			_dwMemSize			dd	0
			_ARDStruct:	
				_dwBaseAddrLow		dd	0
				_dwBaseAddrHigh		dd	0
				_dwLengthLow		dd	0
				_dwLengthHigh		dd	0
				_dwType			dd	0
			_MemChkBuf:
				times	256		db	0
			bOdd				db	0
			wSectorNo			dw	0
			wRootDirSizeForLoop dw	RootDirSectors
			wPrintPos			dw	0000h
			bMesInd				db	00h
	;data in pm mode
		;variable define
			szMemChkTitle		equ	BaseOfLoaderPhyAddr + _szMemChkTitle
			szRAMSize			equ	BaseOfLoaderPhyAddr + _szRAMSize
			szReturn			equ	BaseOfLoaderPhyAddr + _szReturn
			dwDispPos			equ	BaseOfLoaderPhyAddr + _dwDispPos
			dwMemSize			equ	BaseOfLoaderPhyAddr + _dwMemSize
			dwMCRNumber			equ	BaseOfLoaderPhyAddr + _dwMCRNumber
			ARDStruct			equ	BaseOfLoaderPhyAddr + _ARDStruct
				dwBaseAddrLow		equ	BaseOfLoaderPhyAddr + _dwBaseAddrLow
				dwBaseAddrHigh		equ	BaseOfLoaderPhyAddr + _dwBaseAddrHigh
				dwLengthLow			equ	BaseOfLoaderPhyAddr + _dwLengthLow
				dwLengthHigh		equ	BaseOfLoaderPhyAddr + _dwLengthHigh
				dwType		equ	BaseOfLoaderPhyAddr + _dwType
			MemChkBuf		equ	BaseOfLoaderPhyAddr + _MemChkBuf
times	1024	db	0
TopOfStack		equ $-$$

[section	s16]
[BITS	16]
;function
	;print function 
		PRINTSTR:
			.pushReg:
				push	es
			mov		ax	,ds
			mov		es	,ax
			mov		ax	,MESSAGELENGTH
			mul		BYTE[bMesInd]
			add		ax	,pMESSAGE
			mov		bp	,ax
			mov		ax	,01301h
			mov		bx	,0007h
			mov		cx	,MESSAGELENGTH
			mov		dx	,[wPrintPos]
			int		10h
			.popReg:
				pop		es
			ret
		PRINTCHECK:
			mov		ax	,0b800h
			mov		gs	,ax
			mov		ah	,07h
			mov		al	,'L'
			mov		[gs:(80*4+40)*2]	,ax
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
			mov		bx	,[wPrintPos]
			mov		[es:bx]	,ax
			.popReg:
				pop		es
				pop		ax
				pop		bx
			ret
	CHECKMEM:
		mov		ebx		,0
		mov		di	,_MemChkBuf
		.checkLoop:
			mov		eax		,0e820h
			mov		ecx		,20
			mov		edx		,0534d4150h
			int		15h
			jc		.failCheck
			add		di	,20
			inc		DWORD[_dwMCRNumber]
			cmp		ebx		,0
			jne		.checkLoop		
			jmp		.sucCheck
		.failCheck:
			mov		DWORD[_dwMCRNumber]		,0
		.sucCheck:
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
	FINDKERNEL:
		mov		ax	,BaseOfKernel
		mov		es	,ax
		mov		bx	,OffsetOfKernel
		mov		WORD[wSectorNo]		,SectorNoOfRootDirectory
		.findLoop:
			cmp		WORD[wRootDirSizeForLoop]	,0
			jz		.failFind
			dec		WORD[wRootDirSizeForLoop]
			mov		ax	,[wSectorNo]
			mov		cl	,1
			call	READSECTOR
			mov		dx	,10h
			mov		di	,OffsetOfKernel
			mov		si	,KERNELNAME
			cld
			.checkEachFile:
				cmp		dx	,0
				jz		.goNextSector
				dec		dx
				mov		cx	,11
				.cmpFileName:
					cmp		cx	,0
					jz		.sucFind
					dec		cx
					lodsb	
					cmp		al	,[es:di]
					jnz		.failCmpName
					inc		di
					jmp		.cmpFileName
				.failCmpName:
					and		di	,0ffe0h
					add		di	,20h
					mov		si	,KERNELNAME
					jmp		.checkEachFile
			.goNextSector:
				inc		WORD[wSectorNo]
				jmp		.findLoop
		.failFind:
			mov		ax	,0
			ret
		.sucFind:
			mov		ax	,1
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
	KILLMOTOR:
		push	dx
		mov		dx	,03f2h
		mov		al	,0
		out		dx	,al
		pop		dx
		ret
START:
	.initReg:
		mov		ax	,cs
		mov		es	,ax
		mov		ss	,ax
		mov		ds	,ax
		mov		sp	,TopOfStack
	.initScrean:
		mov		WORD[wPrintPos]	,0300h
		mov		BYTE[bMesInd]	,00h
		call	PRINTSTR
	.checkMem:
		call	CHECKMEM
	.findFile:
		call	FINDKERNEL
		cmp		ax	,1
		je		.sucFindFile
	.failFindFile:
		mov		WORD[wPrintPos]	,0500h
		mov		BYTE[bMesInd]	,02h
		call	PRINTSTR
		jmp		$
	.sucFindFile:
		and		di	,0ffe0h
		add		di	,01ah
		mov		ax	,WORD[es:di]
		push	ax
		mov		WORD[wPrintPos]	,(80*3+6)*2
	.loadFile:
		add		WORD[wPrintPos]	,2
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
		mov		WORD[wPrintPos]	,0400h
		mov		BYTE[bMesInd]	,01h
		call	PRINTSTR
	.enterPMMode:
		call	KILLMOTOR
		lgdt	[GdtPtr]
		cli
		in		al	,92h
		or		al	,00000010b
		out		92	,al
		mov		eax		,cr0
		or		eax		,1
		mov		cr0		,eax
		jmp		DWORD SelectorFlatC:(BaseOfLoaderPhyAddr+PM_START)

[section	s32]
align	32
[BITS	32]
;function define
	;print function
		DISPSTR:
			.pushReg:
				push	ebx
				push	esi
				push	edi
			mov		ebx		,esp
			mov		esi		,[ebx+16]
			mov		edi		,[dwDispPos]
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
				mov		[dwDispPos]		,edi
			.popReg:
				pop		edi
				pop		esi
				pop		ebx
			ret
		DISPRETURN:
			push	szReturn
			call	DISPSTR
			add		esp		,4
			ret
		DISPAL:
			.pushReg:
				push	ecx
				push	edx
				push	edi
			mov		edi		,[dwDispPos]
			mov		ah	,0fh
			mov		dl	,al
			shr		al	,4
			mov		ecx		,2
			.dispHex:
				and		al	,01111b
				cmp		al	,9
				ja		.beyondNine
				add		al	,'0'
				jmp		.dispSingle
			.beyondNine:
				sub		al	,0Ah
				add		al	,'A'
			.dispSingle:
				mov		[gs:edi]	,ax
				add		edi		,2
				mov		al	,dl
				loop	.dispHex
			mov		[dwDispPos]		,edi
			.popReg:
				pop	edi
				pop	edx
				pop	ecx
			ret
		DISPINT:
			.pushReg:
				push	edi
			.shiftDisp:
				mov		eax		,[esp+8]
				shr		eax		,24
				call	DISPAL
				mov		eax		,[esp+8]
				shr		eax		,16
				call	DISPAL
				mov		eax		,[esp+8]
				shr		eax		,8
				call	DISPAL
				mov		eax		,[esp+8]
				call	DISPAL
			mov		ah	,07h	
			mov		al	,'h'
			mov		edi	,[dwDispPos]
			mov		[gs:edi]	,ax
			add		edi		,4
			mov		[dwDispPos]		,edi
			.popReg:
				pop		edi
			ret
		DISPCHECK:
			mov		ah	,0fh
			mov		al	,'P'
			mov		[gs:(80*0+39)*2]	,ax
			ret
	DISPMEM:
		.pushReg:
			push	esi
			push	edi
			push	ecx
		.dispTitle:
			push	szMemChkTitle
			call	DISPSTR
			add		esp		,4
		mov		esi		,MemChkBuf
		mov		ecx		,[dwMCRNumber]
		.dispEachARD:
			mov		edx		,5
			mov		edi		,ARDStruct
			.dispEachElem:
				push	DWORD[esi]
				call	DISPINT
				pop		eax
				stosd
				add		esi		,4
				dec		edx
				cmp		edx		,0
				jnz		.dispEachElem
				.calMemSize:
					cmp		DWORD[dwType]	,1
					jne		.dispNextARD
					mov		eax		,[dwLengthLow]
					cmp		eax		,[dwMemSize]
					jb		.dispNextARD
					mov		[dwMemSize]		,eax
			.dispNextARD:
				call	DISPRETURN
				loop	.dispEachARD
				call	DISPRETURN
		.dispMemSize:
			push	szRAMSize
			call	DISPSTR
			add		esp		,4
			push	DWORD[dwMemSize]
			call	DISPINT
			add		esp		,4
		.popReg:
			pop		ecx
			pop		edi
			pop		esi
		ret
	SETUPPAGING:
		.calNumOfPagePDE:
			xor		edx	   ,edx
			mov		eax	   ,[dwMemSize]
			mov		ebx	   ,400000h
			div		ebx	   
			mov		ecx	   ,eax
			test	edx, edx
			jz		.divWithoutR
			inc		ecx	
			.divWithoutR:
			push	ecx	
		mov		ax	,SelectorFlatRW
		mov		es	,ax
		mov		edi		,PageDirBase
		xor		eax		,eax
		mov		eax		,PageTblBase|PG_P|PG_USU|PG_RWW
		.createEachPDE:
			stosd
			add		eax		,4096
			loop	.createEachPDE
		pop		eax		    
		mov		ebx		,1024
		mul		ebx		
		mov		ecx		,eax
		mov		edi		,PageTblBase	
		xor		eax		,eax
		mov		eax		,PG_P |PG_USU|PG_RWW
		.createEachPTE:
			stosd
			add		eax		,4096		; 每一页指向 4K 的空间
			loop	.createEachPTE
		mov		eax		,PageDirBase
		mov		cr3		,eax
		mov		eax		,cr0
		or		eax		,80000000h
		mov		cr0		,eax
		;jmp		short	.3
		;.3:
		;	nop
		ret
	INITKERNEL:
		.getFileInfo:
			mov		cx	,WORD[BaseOfKernelFilePhyAddr+2Ch]
			movzx	ecx		,cx					 
			mov		esi		,[BaseOfKernelFilePhyAddr+1Ch]
			add		esi		,BaseOfKernelFilePhyAddr	
			test	ecx		,ecx
			jz		.popReg
		.getSegInfo:
			mov		eax		,[esi]
			test	eax		,eax
			jz		.endFile
			.copyMem:
				mov		eax		,[esi+04h]	
				add		eax		,BaseOfKernelFilePhyAddr
				push	DWORD[esi+010h]
				push	eax			
				push	DWORD[esi+08h]
				call	MEMCPY			
				add		esp		,12			
		.endFile:
			add		esi		,020h	
			loop	.getSegInfo
		.popReg:
		ret
	MEMCPY:
		.pushReg:
			push	esi
			push	edi
			push	ecx
		.getPara:
			mov		edi		,[esp+16]
			mov		esi		,[esp+20]
			mov		ecx 	,[esp+24]
			test	ecx		,ecx
			jz		.popReg
		.copyLoop:
			lodsb
			stosb
			loop 	.copyLoop
		.popReg:
			pop		ecx
			pop		edi
			pop		esi
		ret		

PM_START:
	mov		ax	,SelectorVideo
	mov		gs	,ax
	mov		ax	,SelectorFlatRW
	mov		ds	,ax
	mov		es	,ax
	mov		fs	,ax
	mov		ss	,ax
	mov		esp	,TopOfStack

	call	DISPMEM
	call	SETUPPAGING
	call	DISPCHECK
	call	INITKERNEL
	jmp		SelectorFlatC:KernelEntryPointPhyAddr
	jmp		$


