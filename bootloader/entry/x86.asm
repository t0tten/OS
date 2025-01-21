bits 16

section _TEXT class=CODE

global _x86_Video_WriteCharTeletype

_x86_Video_WriteCharTeletype:
	
	; make new call frame
	push bp				; save old call frame
	mov bp, sp			; create new call frame

	; save bx
	push bx

	; [bp + 2] - return address (small memory model = 2 bytes)
	; [bp + 4] - first argument (character)
	; [bp + 6] - second argument (page)
	; note: bytes are converted to words (2 bytes)
	mov ah, 0x0e
	mov al, [bp + 4]
	mov bh, [bp + 6]

	int 0x10

	; restore bx
	pop bx

	; restore old call frame
	mov sp, bp
	pop bp
	ret
