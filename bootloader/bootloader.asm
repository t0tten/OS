[org 0x7c00]

%define ENDL 0x0d, 0x0a 

start:
	jmp main

;
; Prints a character to the screen
; params:
;  - ds:si: ponts to string
; 
puts:
	; save registers we will modify
	push si
	push ax

.loop:
	lodsb		; loads next chasracter in al
	or al, al	; check is next character is null
	jz .done
	
	mov ah, 0x0e
	int 0x10
	jmp .loop

.done:
	pop ax
	pop si
	ret
	
main:
	;setup data segment
	mov ax, 0
	mov ds, ax
	mov es, ax
	
	; setup stack segment
	mov ss, ax
	mov sp, 0x7c00	; stack grows downwards, set to start of app

	; call hello world string
	mov si, hello_world
	call puts

	cli
	hlt

.halt:
	jmp .halt

hello_world: db 'Hello World!', ENDL, 0

times 510-($-$$) db 0
dw 0xaa55
