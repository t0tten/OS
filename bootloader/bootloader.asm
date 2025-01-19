[org 0x7C00]
;bits 16

main:
	hlt
	mov ah, 0x0e
	mov al, 'A'
	int 0x10

.halt:
	jmp $

message:
	db 'Hello', 0

times 510-($-$$) db 0
dw 0A55h
