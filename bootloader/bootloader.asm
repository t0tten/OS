[org 0x7c00]

%define ENDL 0x0d, 0x0a 

;
; FAT 12 Headers
;

jmp short start
nop

bdb_oem:			db 'MSWIN4.1' 			; 8 bytes
bdb_bytes_per_sector:		dw 512
bdb_sectors_per_cluster:	db 1
bdb_reserved_sectors:		dw 1
bdb_fat_count:			db 2
bdb_dir_entry_counts:		dw 0xE0
bdb_total_sectors:		dw 2880				; 2880 _* 512 = 1,44MB 
bdb_media_descriptor_type:	db 0xF0				; F0 = 3,5" floppt disk
bdb_sectors_per_fat:		dw 9				; 9 sectors/fat
bdb_sectors_per_track:		dw 18
bdb_heads:			dw 2
bdb_hidden_sectors:		dd 0
bdb_large_sector_count:		dd 0

; extended boot record
ebr_drive_number:		db 0				; 0x00 floppy, 0x80 hdd
				db 0				; reserved
ebr_signature:			db 0x29
ebr_volume_id:			db 0x12, 0x34, 0x56, 0x78	; serial number
rbe_volume_label:		db 'OS         '		; 11 bytes
ebr_system_id:			db 'FAT12   '			; 8 bytes

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
