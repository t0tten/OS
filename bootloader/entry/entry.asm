bits 16

section _ENTRY class=CODE

extern _cstart_
global entry

entry:
	cli
	mov ax, ds
	mov ss, ax
	mov sp, 0
	mov bp, sp
	sti

	; expect boot drive in dl
	; by pushing it to stack it will be treated as a parameter
	xor dh, dh
	push dx
	call _cstart_

	jmp $
