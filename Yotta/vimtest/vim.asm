bits 16
org 32768
%include 'mikedev.inc'

; Key code values with BIOS (using scan code set 1)
%define UP_KEYCODE		0x48E0
%define DOWN_KEYCODE		0x50E0
%define LEFT_KEYCODE		0x4BE0
%define RIGHT_KEYCODE		0x4DE0
%define INSERT_KEYCODE		0x52E0
%define DELETE_KEYCODE		0x53E0
%define HOME_KEYCODE		0x47E0
%define END_KEYCODE		0x4FE0
%define PAGEUP_KEYCODE		0x49E0
%define PAGEDOWN_KEYCODE	0x51E0

; BASIC programs can still use this as whilst running.
%define variables_tmp			65000
%define filename_tmp			65052
%define parameters_tmp			65065

code_start:
; Launcher code --- Starts the control section (BASIC part)
; Uses BASIC/Assembly hybrid 
run_main:
	mov word ax, program_start
	mov word bx, program_end
	sub bx, ax
	call os_run_basic
	call os_show_cursor

	cmp byte [exit_code], 2
	je run_basic

	cmp byte [exit_code], 1
	je crash

	ret

; BASIC runner --- Little bit tricky, loads the BASIC program immediately after
; it, overwriting most of the editor and original code location to maximize
; memory available, then reloads everything. Completely fine, just don't rename
; the editor binary.

run_basic:
	mov si, [p1]
	mov di, .filename
	mov cx, 13
	rep movsb

	mov si, [p2]
	mov di, .variables
	mov cx, 26
	rep movsw

	call os_clear_screen

	mov ax, .filename
	mov cx, basic_load_area
	call os_load_file
	jc crash

	mov ax, basic_load_area
	mov si, .parameters
	call os_run_basic

	mov si, .finished_msg
	call os_print_string
	call os_wait_for_key

	mov si, .filename
	mov di, filename_tmp
	mov cx, 13
	rep movsb

	mov si, .variables
	mov di, variables_tmp
	mov cx, 26
	rep movsw

	mov si, .parameters
	mov di, parameters_tmp
	mov cx, 128
	rep movsw

	mov si, .reload_msg
	call os_print_string

	mov ax, .editor_filename
	mov cx, code_start
	call os_load_file
	jc crash

	mov si, filename_tmp
	mov di, .filename
	mov cx, 13
	rep movsb

	mov si, variables_tmp
	mov di, .variables
	mov cx, 26
	rep movsw

	mov si, parameters_tmp
	mov di, .parameters
	mov cx, 128
	rep movsw

	mov word [cmd], .variables

	mov byte [exit_code], 2
	mov si, .filename
	jmp run_main

	ret
	
.filename				times 13 db 0
.editor_filename			db 'YOTTA.BIN', 0
.variables				times 26 dw 0
.parameters				times 128 db 0
.finished_msg 				db '>>> BASIC Program Finished, press any key to continue...', 13, 10, 0
.reload_msg 				db 'Reloading the editor...', 0


basic_load_area:

; Crash handler --- The program crash indicator should be zero if the program
; ended successfully, otherwise assume the control section (BASIC part) messed
; up somehow.
crash:
	call os_wait_for_key
	call os_clear_screen
	mov si, crash_msg
	call os_print_string
	ret
	
	crash_msg			db "Yotta has crashed :(", 13, 10
	db 'You can report this bug by putting a bug report on the MikeOS Forum or email:'
	db 13, 10, 'zerokelvinkeyboard@gmail.com', 13, 10, 0

; A whole heap of commands that make up the command section. Can be called by
; the control section, see 'doc/registers.txt' for the information on the
; calling procedure and 'doc/command.txt' for information on commands and
; parameters involved.
phase_cmd:
	mov word ax, [cmd]
	
	cmp ax, 0
	je insert_bytes_cmd
	
	cmp ax, 1
	je remove_bytes_cmd

	cmp ax, 2
	je search_cmd
	
	cmp ax, 3
	je draw_cmd
	
	cmp ax, 4
	je set_filename
	
	cmp ax, 5
	je set_caption
	
	cmp ax, 6
	je input_caption

	cmp ax, 7
	je set_basic_parameters
	
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

	cmp ax, 14
	je get_help
	
	cmp ax, 17
	je read_key

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
	
	ret
	
set_filename:
	ret
	
set_caption:
	; IN: p1 = caption
	mov dh, 24
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
	cmp ax, 0
	je .done

	mov dh, 24
	mov dl, 0
	call os_move_cursor
	
	mov ax, [p1]
	call os_string_length
	mov cx, ax
	mov ah, 09h
	mov al, 20h
	mov bh, 0
	mov bl, 7
	int 10h

	call os_move_cursor
	
	mov si, [p1]
	call os_print_string
	
.done:
	ret
	

input_caption:
	; IN: p1 = prompt, p2 = input buffer
	mov dh, 24
	mov dl, 0
	call os_move_cursor
	
	mov ah, 09h
	mov al, 20h
	mov bh, 0
	mov bl, 07h
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
	
	ret
	
set_basic_parameters:
	; IN: p1 = parameter string pointer
	mov si, [p1]
	mov di, run_basic.parameters
	call os_string_copy
	ret

ask_caption:
	; IN: p1 = prompt, p2 = answer (Y/N/C = 0/1/2)
	mov dh, 24
	mov dl, 0
	call os_move_cursor
	
	mov ah, 09h
	mov al, 20h
	mov bh, 0
	mov bl, 07h
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
	mov bl, 7
	mov cx, 80
	int 10h
	
	ret
	
	.ask_prompt				db '(Y)es/(N)o/(C)ancel', 0

render_text:
	; IN: p1 = first char on screen, p2 = end of text
	call clear_text_area
	cmp word [p1], 0
	je .finish
	
	mov word si, [p1]
	mov dh, 0
	mov dl, 0
	call os_move_cursor
	
	mov ah, 9
	mov bh, 0
	mov bl, 7
	mov cx, 1	

	cmp word si, [p2]	
	jge .finish

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
		cmp dh, 24
		jge .finish
		
		cmp word si, [p2]	
		jg .finish
	
		cmp dl, 80
		jge .line_overflow
		
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
		
	.line_overflow:
		mov al, '$'
		int 10h

	.skip_remaining:
		lodsb
		cmp al, 0Ah
		je .newline
		jmp .skip_remaining
		
	.line_feed:
		mov al, 0FFh
		int 10h
		jmp .newline
		
	.finish:
		ret

set_modified:
	; IN: p1 = modified on/off
	ret
	
clear_text_area:
	mov dh, 0
	mov dl, 0
	call os_move_cursor
	
	mov ah, 09h
	mov al, 0h
	mov bh, 00h
	mov bl, 07h
	mov cx, 1920
	int 10h
	ret
	
shift_right_text:
	; IN: p1 = column, p2 = row
	mov word ax, [p1]
	mov cl, al
	mov word ax, [p2]
	mov dh, al
	call os_move_cursor
	
	cmp cl, 78
	jge .finished
	
	mov bh, 0
	mov dl, 77
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
        cmp dl, 78
        jg .finished
        
        call os_move_cursor
        jmp .move_loop

.finished:
	mov dl, 78
	call os_move_cursor
	mov ah, 0Eh
	mov al, 0
	int 10h
	ret


get_help:
	call clear_text_area
	mov dl, 0
	mov dh, 2
	call os_move_cursor

	mov si, help_text_1
	call os_print_string

	mov si, help_text_system
	mov ax, code_start
	call print_buffer_size

	mov si, help_text_program
	mov ax, [p1]
	sub ax, code_start
	call print_buffer_size

	mov si, help_text_file
	mov ax, [p2]
	sub ax, [p1]
	call print_buffer_size

	mov si, help_text_free
	mov ax, 0
	sub ax, [p2]
	call print_buffer_size

	call next_screen_delay

	ret


; SI = message, AX = size (bytes)
print_buffer_size:
	call os_print_string
	mov bx, ax
	call os_int_to_string
	mov si, ax
	call os_print_string
	mov si, help_text_bytes
	call os_print_string
	cmp bx, 1
	je .onebyte

	mov ah, 0x0E
	mov al, 's'
	mov bh, 0
	int 10h

.onebyte:
	call os_print_newline
	ret

next_screen_delay:
	call os_print_newline
	mov si, help_text_wait
	call os_print_string
	call os_wait_for_key
	call clear_text_area
	ret

help_text_1:
  db 'Experimental vim clone for MikeOS', 13, 10
  db 'Version 1.0.0', 13, 10
  db 'Copyright (C) Joshua Beck 2015', 13, 10
  db 'Licenced under the GNU GPL v3', 13, 10
  db 'Email: zerokelvinkeyboard@gmail.com', 13, 10
  db 13, 10
  db 'Memory Usage', 13, 10
  db '============', 13, 10
  db 'Total: 65536 bytes', 13, 10, 0

help_text_system				db 'System:  ', 0
help_text_program				db 'Program: ', 0
help_text_file					db 'File: ', 0
help_text_free					db 'Free: ', 0
help_text_bytes					db ' byte', 0
help_text_wait					db 'Press any key to continue...', 0


read_key:
	call os_wait_for_key

	cmp ax, UP_KEYCODE
	je .up_key

	cmp ax, DOWN_KEYCODE
	je .down_key

	cmp ax, LEFT_KEYCODE
	je .left_key

	cmp ax, RIGHT_KEYCODE
	je .right_key

	cmp ax, INSERT_KEYCODE
	je .insert_key

	cmp ax, DELETE_KEYCODE
	je .delete_key

	cmp ax, HOME_KEYCODE
	je .home_key

	cmp ax, END_KEYCODE
	je .end_key

	cmp ax, PAGEUP_KEYCODE
	je .pageup_key

	cmp ax, PAGEDOWN_KEYCODE
	je .pagedown_key

	and ax, 0x00FF
.done:
	mov [p1], ax
	ret

.up_key:
	mov ax, 0x80
	je .done

.down_key:
	mov ax, 0x81
	je .done

.left_key:
	mov ax, 0x82
	je .done

.right_key:
	mov ax, 0x83
	je .done

.insert_key:
	mov ax, 0x84
	je .done

.delete_key:
	mov ax, 0x7F
	je .done

.home_key:
	mov ax, 0x85
	je .done

.end_key:
	mov ax, 0x86
	je .done

.pageup_key:
	mov ax, 0x87
	je .done

.pagedown_key:
	mov ax, 0x88
	je .done

search_cmd:
; IN: p1 = file start, p2 = file length, p3 = search term
; OUT: p1 = 0/1 for no match/match, p2 = match pointer, p3 = lines skipped
	mov di, [p1]
	mov dx, [p2]
	mov si, [p3]
	mov word [.nl_count], 0

	mov ax, si
	call os_string_uppercase
	call os_string_length
	mov bx, ax
	mov ah, [si]
	
.find_match:
	cmp dx, 0
	je .no_match
	dec dx

	mov al, [di]
	inc di

	cmp al, 10
	je .newline

	cmp al, ah
	jne .find_match

	push di

	dec di
	mov si, [p3]
	mov cx, bx
.check_match:
	cmp cx, 0
	je .found_match
	dec cx

	mov ah, [si]
	mov al, [di]
	inc si
	inc di

	cmp al, 'a'
	jl .check_char

	cmp al, 'z'
	jg .check_char

	sub al, 0x20

.check_char:
	cmp al, ah
	je .check_match

.bad_match:
	pop di
	jmp .find_match

.newline:
	inc word [.nl_count]
	jmp .find_match

.found_match:
	pop di
	dec di

	mov word [p1], 1
	mov [p2], di
	mov ax, [.nl_count]
	mov [p3], ax
	ret

.no_match:
	mov word [p1], 0
	ret

.nl_count				dw 0


; Registers used by the control section to run sections of the command section.
; See doc/registers.txt for information about this data
registers:
	cmd				dw 0
	p1				dw 0
	p2				dw 0
	p3				dw 0
	p4				dw 0
	p5				dw 0
	p6				dw 0
	exit_code			db 1
        data_pointer			dw cmd
       	phase_cmd_pointer		dw phase_cmd
	
; Include the control section (BASIC part) after the command section (binary 
; part). Contains BASIC programming but not an independent program, needs
; the command section and the launcher to run properly.
; Has to have '.txt' on the end or the build script will think it is a
; stand alone program and add it to disk.
program_start:
incbin 'vim.bas.txt'
program_end:

