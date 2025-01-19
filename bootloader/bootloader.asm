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

	; read something from floppy disk
	; BIOS should set DL to drive number
	mov [ebr_drive_number], dl
	mov ax, 1				; LBA=1, second sector from disk	
	mov cl, 1				; read 1 sector
	mov bx, 0x7E00				; data should be after the bootloader
	call disk_read

	; call hello world string
	mov si, hello_world
	call puts

	cli
	hlt

;
; Error handlers
;
floppy_error:
	mov si, msg_read_failed
	call puts
	jmp wait_key_and_reboot

wait_key_and_reboot:
	mov ah, 0
	int 0x16			; wait for key press
	jmp 0xFFFF:0			; jump to beginning of BIOS (reboot)

.halt:
	cli				; disable interrupts, CPU cant continue from "halt" state
	hlt

;
; Disk routines
;

;
; Converts an LBA address to a CHS address
; Parameters:
;  - ax: LBA address
; Returns
;  - cx: [bits 0-5]: sector number
;  - cx: [bnits 6-15]: cylinder
;  - dh: head

lba_to_chs:
	push ax
	push dx

	xor dx, dx				; dx = 0
	div word [bdb_sectors_per_track]	; ax = LBA / SectorsPerTrack
						; dx = LVA % SectorsPerTrack
	inc dx					; dx = (LBA % SectorsPerTrack + 1) = sector
	mov cx, dx				; cx = sector
	
	xor dx, dx				; dx = 0
	div word [bdb_heads]			; ax = (LBA / SectorsPerTrack) / Heads = cylinder
						; dx = (LBA / SectorsPerTrack) % Heads = head
	mov dh, dl				; dh = head
	mov ch, al				; ch = cylinder (lower 8 bits)
	shl ah, 6
	or cl, ah				; puts upper 2 bits of cylinder in cl
	
	pop ax
	mov dl, al
	pop ax
	ret

;
; Read sectors from disk
; Parameters:
;  - ax: LBA address
;  - cl: numbers of sectors to read (up to 128)
;  - dl: drive number
;  - es:bx: memory address where to store the read data
;
disk_read:
	push ax			; save registers we are modifying
	push bx
	push cx
	push dx
	push di

	push cx			; temporarily save CL (numbers of sectors to read)
	call lba_to_chs		; compute CHS
	pop ax			; AL = numbers of sectors to read
	
	mov ah, 0x02
	mov di, 3

.retry:
	pusha			; save all registers, we dont know what bios modifies
	stc			; set carry flag, some BIOSes dont set it
	int 0x13		; carry flag cleared = success
	jnc .done
	
	; read failed	
	popa
	call disk_reset

	dec di
	test di, di
	jnz .retry
	
.fail:
	; after all attempts exhausted
	jmp floppy_error
.done:
	popa

	pop di			; restore registers we were modifying
	pop dx
	pop cx
	pop bx
	pop ax
	ret

;
; Reset disk controller
; Parameters:
;  - dl: drive number
;
disk_reset:
	pusha
	
	mov ah, 0
	stc
	int 0x13
	jc floppy_error
	
	popa
	ret

hello_world:		db 'Hello World!', ENDL, 0
msg_read_failed:	db 'Read from disk failed!', ENDL, 0

times 510-($-$$) db 0
dw 0xaa55
