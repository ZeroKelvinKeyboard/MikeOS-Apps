%INCLUDE 'tachyonos.inc'
org 32768
bits 16

; clear screen beforehand
call os_clear_screen
call os_hide_cursor

; reset the mouse position
mov cx, 0
mov dx, 0
call os_mouse_move

mouse_loop:
	mov dx, 0
	call os_move_cursor
	call os_mouse_locate
	
	; Print Mouse X
	mov si, mouse_x_string
	call os_print_string
	mov ax, cx
	call os_int_to_string
	mov si, ax
	push dx
	call os_get_cursor_pos
	sub dl, 2
	call os_move_cursor
	call os_print_string
	call os_print_newline
	
	; Print Mouse Y
	pop dx
	mov si, mouse_y_string
	call os_print_string
	mov ax, dx
	call os_int_to_string
	mov si, ax
	call os_get_cursor_pos
	sub dl, 2
	call os_move_cursor
	call os_print_string
	call os_print_newline
	
	mov si, exit_msg
	call os_print_string

	; Show the cursor
	call os_mouse_show
	
	; Wait for input
	call os_input_wait
	
	; If the input was keyboard input, check the key
	jc key_pressed
	
	; If it was a mouse click then finish program
	call os_mouse_anyclick
	jc exit
	
	; Otherwise hide the cursor and loop
	call os_mouse_hide
	jmp mouse_loop
	
key_pressed:
	call os_check_for_key

	; Was the escape key pressed?
	cmp al, 27
	je exit
	
	; If not hide the cursor and loop
	call os_mouse_hide
	
	jmp mouse_loop
	
exit:
	call os_mouse_hide
	call os_clear_screen
	call os_show_cursor
	ret
	
mouse_x_string				db 'Mouse X:   ', 0
mouse_y_string				db 'Mouse Y:   ', 0
exit_msg				db 'Press the escape key or click any mouse button to exit.', 0
