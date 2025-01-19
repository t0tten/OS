[org 0x7C00]

print_text_to_screen:
	mov ah, 0x0e
	mov bx, message

print_characters:
	mov al, [bx]
	cmp al, 0
	je halt
	int 0x10
	inc bx
	jmp print_characters

halt:
	jmp $

message:
	db 'Welcome!', 0

times 510-($-$$) db 0
dw 0xaa55
