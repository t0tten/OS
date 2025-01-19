[org 0x7C00]

mov ah, 0x0e

mov bx, new_line
call print_characters

mov bx, message
call print_characters

mov bx, new_line
call print_characters

mov bx, line2
call print_characters

mov bx, new_line
call print_characters
mov bx, new_line
call print_characters

mov bx, prompt_text
call print_characters

mov bx, new_line
call print_characters

mov bx, prompt
call print_characters

jmp halt

print_characters:
	mov al, [bx]
	cmp al, 0
	je end
	int 0x10
	inc bx
	jmp print_characters
end:
	ret

halt:
	jmp $

message: db 'Welcome to Test-OS!', 0
line2: db 'This is a test of writing text on a new line.', 0
prompt_text: db 'Enter your command:', 0
prompt: db '$ ', 0

new_line: db 13, 10, 0

times 510-($-$$) db 0
dw 0xaa55
