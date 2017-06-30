	org 07c00h
	mov ax, cs
	mov ds, ax
	mov es, ax
	call dispstr
	jmp $
dispstr:
	mov ax, bootmessage
	mov bp,ax
	mov cx,16
	mov ax,01301h
	mov bx,000ch
	mov dl,0
	int 10h
	ret
bootmessage:
	db "Hello, My OS"
times	510-($-$$)	db 0
dw	0aa55h

