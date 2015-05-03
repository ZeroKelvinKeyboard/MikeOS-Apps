bits 16
org 32768
%include 'tachyonos.inc'

cmp si, 0
je help

mov ax, si
call os_string_uppercase
mov di, help_word
jc help_word

load_file:
	mov ax, si
	mov cx, file_start
	call os_load_file
	jc error.file

verify:
	mov si, file_start
	mov di, file_identifier
	call os_string_compare
	jne error.identifier

	add si, 4
	lodsb
	cmp al, 1
	jne error.version
	
	lodsb
	cmp al, 1
	je picture
	
	cmp al, 2
	je error.palette

	cmp al, 3
	je animation
	
	jmp error.subtype
	
	file_identifier				db "AAP", 0
	
	
picture:
	lodsw
	add ax, file_start
	mov di, ax
	
	lodsb
	mov cl, al
	
	lodsb
	mov ch, al
	
	call os_clear_screen
	mov dx, 0
	mov si, di
	call display_aap
	
	call os_hide_cursor
	call os_wait_for_key
	call os_show_cursor
		
	call os_clear_screen
	call os_move_cursor
	ret
	
animation:
	lodsb
	add ax, file_start
	mov di, ax
	
	lodsb
	mov cl, al
	
	lodsb
	mov ch, al
	
	mul cl
	shl ax, 1
	mov di, ax
	
	lodsb
	mov bx, 0
	mov bl, al
	
	lodsb
	mov ah, 0
	
	mov dx, 0
	mov si, di
	
	.animate_picture:
		call os_clear_screen
		call display_aap
		add si, di
		
		dec bx
		cmp bx, 0
		jne .frame_delay
		
		mov dh, ch
		mov dl, 0
		call os_move_cursor
		ret
		
	.frame_delay:
		call os_pause
		jmp .animate_picture
		

display_aap:
	; si = data location, ch = size (rows), cl = size (columns), dh = starting row, dl = starting column
	pusha
	push es
	mov ax, 0xB800
	mov es, ax
	push dx
	
	mov ax, 0
	mov al, dl
	mov bx, 0
	mov bl, dh
	xchg dh, dl
	mov dh, 0
	shl dx, 6
	shl bx, 4
	add ax, dx
	add ax, bx
	shl ax, 1
	mov di, ax
	pop dx
	
	mov bh, cl
	mov bl, 80
	sub bl, bh
	add bl, dl
	shl bl, 1
	
.display_row:
	.display_character:
		lodsw
		xchg ah, al
		stosw
		dec bh
		cmp bh, 0
		jne .display_character
	
	mov ax, 0
	mov al, bl
	add di, ax
	mov bh, cl
	
	dec ch
	cmp ch, 0
	jne .display_row
	
	pop es
	popa
	ret
	
help:
	mov si, help_string
	call os_print_string
	ret
	
	help_word				db "HELP", 0
	help_string				db "DISPLAY - Show AAP picture files", 13, 10
	help_string2				db "Syntax: DISPLAY filename", 13, 10
	help_string3				db "Copyright (C) Joshua Beck 2012", 13, 10
	help_string4				db "Email: mikeosdeveloper@gmail.com", 13, 10
	help_string5				db "Licenced under the GNU General Public Licence", 13, 10
	help_string6				db 13, 10, 0
	
error:
	.file:
		mov si, .msg_invalid_file
		call os_print_string
		ret
		
	.identifier:
		mov si, .msg_incorrect_identifier
		call os_print_string
		ret
		
	.version:
		mov si, .msg_bad_version
		call os_print_string
		ret
		
	.palette:
		mov si, .msg_subtype_palette
		call os_print_string
		ret

	.subtype:
		cmp si, .msg_subtype_unknown
		call os_print_string
		ret

	.msg_invalid_file			db "File not found.", 0
	.msg_incorrect_identifier		db "File type is not correct.", 0
	.msg_bad_version			db "Cannot load this version.", 0
	.msg_subtype_palette			db "Cannot display palette files.", 0
	.msg_subtype_unknown			db "Unknown file subtype.", 0
	
file_start:
