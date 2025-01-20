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
bdb_dir_entry_counts:		dw 0x0E0
bdb_total_sectors:		dw 2880				; 2880 _* 512 = 1,44MB 
bdb_media_descriptor_type:	db 0x0F0			; F0 = 3,5" floppt disk
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
	;setup data segment
	mov ax, 0
	mov ds, ax
	mov es, ax
	
	; setup stack segment
	mov ss, ax
	mov sp, 0x7C00	; stack grows downwards, set to start of app

	; Could start at 07C0:0000 instead of 000:7C00
	; This is to make sure we are at the correct location
	push es
	push word .after
	retf

.after:
	; Read something from floppy disk
	; BIOS should set DL to drive number
	mov [ebr_drive_number], dl

	; show loading message
	mov si, msg_loading
	call puts

	; Ask BIOS for active drive parameters
	push es
	mov ah, 0x08
	int 0x13
	jc floppy_error
	pop es

	and cl, 0x3F				; remove top 2 bits
	xor ch, ch
	mov [bdb_sectors_per_track], cx		; number of sectors
	
	inc dh
	mov [bdb_heads], dh			; number of heads

	; Read FAT root directory
	; Compute LBA of root directory = reserved + fats * sectors_per_fat
	mov ax, [bdb_sectors_per_fat]			
	mov bl, [bdb_fat_count]
	xor bh, bh
	mul bx					; ax = (fats * sectors per fat)
	add ax, [bdb_reserved_sectors]		; ax = LBA of root directory
	push ax	

	; compute size of root directory = 32 * number of entries / bytes per sector
	mov ax, [bdb_dir_entry_counts]
	shl ax, 5				; number of entries * 32
	xor dx, dx				
	div word [bdb_bytes_per_sector]		; ax / bytes per sector
						; ax contains division
						; dx contains remainder
	test dx, dx				; if dx != 0, add 1
	jz .root_dir_after
	inc ax					; means we have a sector partially filled with entries

.root_dir_after:
	; read root directory
	mov cl, al				; cl = numbers of sectors to read (size of root directory)	
	pop ax					; ax = LBA of root directory (sector)
	mov dl, [ebr_drive_number]		; dl = driver number
	mov bx, buffer				; es:bx = buffer
	call disk_read

	; Search for kernel.bin file
	xor  bx, bx ;				; count number of entries checked
	mov di, buffer				; current directory entry, filename is first entry

.search_kernel:
	mov si, file_kernel_bin
	mov cx, 11				; length - compare up to 11 characters
	push di
	repe cmpsb				; cmpsb: compare srting bytes - repe: repeat while equal
	pop di
	je .found_kernel

	add di, 32
	inc bx
	cmp bx, [bdb_dir_entry_counts]
	jl .search_kernel			; jump less
	
	jmp kernel_not_found_error

.found_kernel:
	; di should still have the address to the entry	
	mov ax, [di + 26]			; offset of the lower first cluster field is 26 bytes
	mov [kernel_cluster], ax
	
	; load FAT from disk into memory
	mov ax, [bdb_reserved_sectors]
	mov bx, buffer
	mov cl, [bdb_sectors_per_fat]
	mov dl, [ebr_drive_number]
	call disk_read

	; Read kernel and process FAT chain
	mov bx, KERNEL_LAOD_SEGMENT
	mov es, bx
	mov bx, KERNEL_LOAD_OFFSET

.load_kernel_loop:
	; Read next cluster
	mov ax, [kernel_cluster]
	; should not be hard coded
	add ax, 31				; first cluster = (cluster number  - 2) * sectors per cluster + start_sector
						; start_sector = reserved + fats + root directory size ( 1 + 18 + 14 = 33)
	mov cl, 1
	mov dl, [ebr_drive_number]
	call disk_read

	add bx, [bdb_bytes_per_sector]
	
	; compute location of next cluster - 12 bytes	
	; current_cluster * 3 / 2 = fatIndex
	mov ax, [kernel_cluster]
	mov cx, 3
	mul cx
	mov cx, 2
	div cx					; index of entry in FAT, dx = cluster % 2

	mov si, buffer
	add si, ax	
	mov ax, [ds:si]				; read entry from FAT table at index ax
	
	or dx, dx				; check if 0 -  see below
	jz .even

 	; if (current cluster % 2 == 0) current cluster = fatIndex & 0x0FFF - pick lower part
	; else 	fatIndex >> 4						    - pick upper part
.odd:
	shr ax, 4
	jmp .next_cluster_after

.even:
	and ax, 0x0FFF

.next_cluster_after:
	cmp ax, 0x0FF8				; end of chain
	jae .read_finish			; jump above or equal

	mov [kernel_cluster], ax
	jmp .load_kernel_loop	

.read_finish:
	; do a far jump to kernel.bin
	; before - restore some registers
	; boot device in dl
	mov dl, [ebr_drive_number]
	
	; set segment registers
	mov ax, KERNEL_LAOD_SEGMENT
	mov ds, ax
	mov es, ax

	jmp KERNEL_LAOD_SEGMENT:KERNEL_LOAD_OFFSET
	
	jmp wait_key_and_reboot
	
	cli
	hlt

; Error handlers
;
floppy_error:
	mov si, msg_read_failed
	call puts
	jmp wait_key_and_reboot

kernel_not_found_error:
	mov si, msg_kernel_not_found
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

msg_loading:		db 'Loading...', ENDL, 0
msg_read_failed:	db 'Read from disk failed!', ENDL, 0
msg_kernel_not_found: 	db 'kernel.bin not found', ENDL, 0

file_kernel_bin:	db 'KERNEL  BIN'
kernel_cluster:		dw 0

KERNEL_LAOD_SEGMENT	equ 0x2000
KERNEL_LOAD_OFFSET	equ 0

times 510-($-$$) db 0
dw 0xaa55

buffer:
