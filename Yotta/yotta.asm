bits 16
org 32768
%include 'mikedev.inc'

run_main:
	mov word ax, program_start
	mov word bx, program_end
	sub bx, ax
	call os_run_basic
	call os_show_cursor
	cmp byte [program_crashed], 1
	je crash
	ret

crash:
	call os_wait_for_key
	call os_clear_screen
	mov si, crash_msg
	call os_print_string
	ret
	
	crash_msg			db "Yotta has crashed :(", 13, 10, 0

phase_cmd:
	mov word ax, [cmd]
	
	cmp ax, 0
	je insert_bytes_cmd
	
	cmp ax, 1
	je remove_bytes_cmd

	cmp ax, 2
;	je search_cmd
	
	cmp ax, 3
	je draw_cmd
	
	cmp ax, 4
	je set_filename
	
	cmp ax, 5
	je set_caption
	
	cmp ax, 6
	je input_caption
	
	cmp ax, 7
	je run_basic_cmd

	cmp ax, 8
	je render_text

	cmp ax, 9
	je set_modified
	
	cmp ax, 10
	je clear_text_area

	cmp ax, 11
	je shift_right_text
	
	cmp ax, 12
	je shift_left_text

	cmp ax, 13
	je ask_caption
	
	ret

insert_bytes_cmd:
	; IN: p1 = location, p2 = data size, p3 = bytes to increase
	mov word si, [p1]
	mov word cx, [p2]

	add si, cx
	dec si
	mov di, si
	add di, [p3]
	std
	
	rep movsb	

	cld		
	ret
	
remove_bytes_cmd:
	; IN: p1 = location, p2 = data size, p3 = bytes to remove
	mov word si, [p1]
	mov di, si
	mov word cx, [p2]
	add si, [p3]

	rep movsb

	ret


draw_cmd:
	call os_clear_screen
	mov dx, 0000h
	call os_move_cursor

	mov bl, 0F0h
	mov dh, 00h
	mov dl, 00h
	mov si, 50h
	mov di, 01h
	call os_draw_block	
		
	mov si, name_and_version
	call os_print_string

	mov dh, 23
	mov dl, 0
	call os_move_cursor
	
	mov ah, 09h
	mov al, 20h
	mov bh, 00h
	mov bl, 0Fh
	mov cx, 0F0h
	int 10h
	
	mov word si, key_strings
	mov cx, 12
	
	.print_shortcuts:
		push cx
		mov ah, 09h
		mov al, 20h
		mov bh, 00h
		mov bl, 0F0h
		mov cx, 2
		int 10h
		
		call os_print_string
		add si, 14
		
		pop cx
		loop .print_shortcuts
		
		ret
		
	key_strings			db 	'^G Get Help  ', 0
	        			db	'^O WriteOut  ', 0
	        			db	'^S Strt File ', 0
	        			db	'^Y Prev Page ', 0
	        			db	'^K Cut Text  ', 0
	        			db	'^Z Cur Pos ', 13, 10, 0
	        			db	'^X Exit      ', 0
	        			db	'^R Read File ', 0
	        			db	'^F End File  ', 0
	        			db	'^V Next Page ', 0
	        			db	'^U UnCut Txt ', 0
	        			db	'^L Del Line  ', 0
	
	name_and_version		db 	'yotta 2.00x10^24', 0
	
set_filename:
	; IN: p1 = filename (blank for none)
	mov si, [p1]
	lodsb
	cmp al, 0
	je .blank
	
	mov ax, [p1]
	call os_string_length
	add ax, 6
	shr ax, 1
	
	mov bx, 40
	sub bx, ax
	
	mov dh, 0
	mov dl, bl
	call os_move_cursor
	
	mov si, file_word
	call os_print_string
	
	add dl, 6
	call os_move_cursor
	mov si, [p1]
	call os_print_string
	
	ret
	
	.blank:
		mov dh, 0
		mov dl, 35
		call os_move_cursor
		
		mov si, no_file_word
		call os_print_string
		ret
		
	no_file_word			db	'New Buffer', 0
	file_word			db	'File: ', 0		

set_caption:
	; IN: p1 = caption
	mov dh, 22
	mov dl, 0
	call os_move_cursor

	mov ah, 09h
	mov al, 0
	mov bh, 0
	mov bl, 7
	mov cx, 80
	int 10h
	
	mov ax, [p1]
	call os_string_length
	add ax, 4
	shr ax, 1

	mov bx, 40
	sub bx, ax
	
	mov dh, 22
	mov dl, bl
	call os_move_cursor
	
	mov ax, [p1]
	call os_string_length
	add ax, 4
	mov cx, ax
	mov ah, 09h
	mov al, 20h
	mov bh, 0
	mov bl, 240
	int 10h

	mov si, opening_bracket
	call os_print_string
	
	add dl, 2
	call os_move_cursor
	
	mov si, [p1]
	call os_print_string
	
	mov ax, [p1]
	call os_string_length
	add dl, al
	call os_move_cursor
	
	mov si, closing_bracket
	call os_print_string
	
	ret
	
	opening_bracket			db '[ ', 0
	closing_bracket			db ' ]', 0


input_caption:
	; IN: p1 = prompt, p2 = input buffer
	mov dh, 22
	mov dl, 0
	call os_move_cursor
	
	mov ah, 09h
	mov al, 20h
	mov bh, 0
	mov bl, 0F0h
	mov cx, 80
	int 10h
	
	mov word si, [p1]
	call os_print_string
	
	mov word ax, [p1]
	call os_string_length
	mov dl, al
	call os_move_cursor
	
	call os_show_cursor
	mov word ax, [p2]
	call os_input_string
	call os_hide_cursor
	
	mov dl, 0
	call os_move_cursor
	
	mov ah, 09h
	mov al, 20h
	mov bh, 0
	mov bl, 15
	mov cx, 80
	int 10h
	
	ret
	
ask_caption:
	; IN: p1 = prompt, p2 = answer (Y/N/C = 0/1/2)
	mov dh, 22
	mov dl, 0
	call os_move_cursor
	
	mov ah, 09h
	mov al, 20h
	mov bh, 0
	mov bl, 0F0h
	mov cx, 80
	int 10h
	
	mov word si, [p1]
	call os_print_string
	
	mov word ax, [p1]
	call os_string_length
	mov dl, al
	call os_move_cursor

	mov word si, .ask_prompt
	call os_print_string
	
	.get_key:
		call os_wait_for_key

		cmp al, 'Y'
		je .yes
		
		cmp al, 'y'
		je .yes
		
		cmp al, 13
		je .yes
		
		cmp al, 'N'
		je .no
		
		cmp al, 'n'
		je .no
		
		cmp al, 'C'
		je .cancel
		
		cmp al, 'c'
		je .cancel
		
		cmp al, 27
		je .cancel
		
		jmp .get_key

	.yes:
		mov word [p2], 0
		jmp .finished
		
	.no:
		mov word [p2], 1
		jmp .finished
		
	.cancel:
		mov word [p2], 2

	.finished:

	mov dl, 0
	call os_move_cursor
	
	mov ah, 09h
	mov al, 20h
	mov bh, 0
	mov bl, 15
	mov cx, 80
	int 10h
	
	ret
	
	.ask_prompt				db '(Y)es/(N)o/(C)ancel', 0
	
run_basic_cmd:
	; IN: p1 = start of code, p2 = size of code
	call os_clear_screen
	mov word ax, [p1]
	mov word bx, [p2]
	mov si, 0
	call os_run_basic
	call os_print_newline
	mov si, basic_end_string
	call os_print_string
	call os_clear_screen
	ret
	
	basic_end_string		db 	'Finished running BASIC program', 0

render_text:
	; IN: p1 = first char on screen, p2 = end of text
	call clear_text_area
	cmp word [p1], 0
	je .finish
	
	mov word si, [p1]
	mov dh, 2
	mov dl, 0
	call os_move_cursor
	
	mov ah, 9
	mov bh, 0
	mov bl, 15
	mov cx, 1	

	cmp word si, [p2]	
	jge .end_of_text

	.text_loop:
		lodsb
		
		call os_move_cursor
		
		cmp al, 09h
;		je .tab
		
		cmp al, 0Ah
		je .line_feed
		
		int 10h
		
		inc dl
	.check_limits:
		cmp dh, 21
		jge .finish
		
		cmp word si, [p2]	
		jge .end_of_text
	
		cmp dl, 80
		jge .skip_remaining
		
		jmp .text_loop
		
	.tab:
		mov al, 20h
		mov cx, 4
		int 10h
		mov cx, 1
		
		add dl, 3
		jmp .check_limits
		
	.newline:
		inc dh
		mov dl, 0
		
		jmp .check_limits
		
	.skip_remaining:
		lodsb
		cmp al, 0Ah
		je .newline
		jmp .skip_remaining
		
	.line_feed:
		mov al, 0FFh
		int 10h
		jmp .newline
		
	.end_of_text:
		call os_move_cursor
		mov ah, 0Eh
		mov al, 17
		int 10h
	.finish:
		ret

set_modified:
	; IN: p1 = modified on/off
	mov dh, 0
	mov dl, 72
	call os_move_cursor
	
	cmp word [p1], 0
	je .remove_modified

	.set_modified:
		mov si, modified_word
		call os_print_string
		ret
	
	.remove_modified:
		mov si, blank_word
		call os_print_string
		ret
	
	modified_word			db 'Modified', 0
	blank_word			db '        ', 0
	
clear_text_area:
	mov dh, 2
	mov dl, 0
	call os_move_cursor
	
	mov ah, 09h
	mov al, 0h
	mov bh, 00h
	mov bl, 0Fh
	mov cx, 1520
	int 10h
	ret
	
shift_right_text:
	; IN: p1 = column, p2 = row
	mov word ax, [p1]
	mov cl, al
	mov word ax, [p2]
	mov dh, al
	call os_move_cursor
	
	cmp cl, 79
	jge .finished
	
	mov bh, 0
	mov dl, 78
	call os_move_cursor
	

.move_loop:
	mov ah, 08h
	int 10h

	inc dl
	call os_move_cursor

	mov ah, 0Eh
	int 10h
	
	dec dl
	cmp dl, cl
	je .finished
	
	dec dl
	call os_move_cursor
	jmp .move_loop
	
.finished:
	ret
	
shift_left_text:
        ; IN: p1 = column, p2 = row
        mov word ax, [p1]
        mov dl, al
        mov word ax, [p2]
        mov dh, al
        
        mov bh, 0
        inc dl
	call os_move_cursor
        
.move_loop:
	mov ah, 08h
	int 10h
	
	dec dl
	call os_move_cursor
	
	mov ah, 0Eh
        int 10h
        
        add dl, 2
        cmp dl, 79
        jg .finished
        
        call os_move_cursor
        jmp .move_loop

.finished:
	mov dl, 79
	call os_move_cursor
	mov ah, 0Eh
	mov al, 0
	int 10h
	ret

; See doc/registers.txt for information about this data
registers:
	cmd				dw 0
	p1				dw 0
	p2				dw 0
	p3				dw 0
	p4				dw 0
	p5				dw 0
	p6				dw 0
	program_crashed			db 1
        data_pointer			dw cmd
       	phase_cmd_pointer		dw phase_cmd
	
program_start:
incbin 'yotta.bas.txt'
program_end:
