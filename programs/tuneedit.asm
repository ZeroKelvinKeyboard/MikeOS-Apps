; Tune Editor (TUNEEDIT.ASM)
; PC Speaker Sound Creation/Editing for MikeOS
; Produces sound format used by Music Master
; Created by Joshua Beck
; Licenced under the GNU General Public Licence v3
; Version 1.0.2
; For bug reports/questions/feature requests mail me at: mikeosdeveloper@gmail.com

bits 16							; MikeOS Program Header
org 32768
%include 'tachyonos.inc'

start:
	call os_clear_screen
	push si						; store the command line parameter pointer
	mov si, .welcome_msg
	call os_print_string
	call os_print_newline

	mov byte [clear_and_return], 1
	call cmd_clear					; create a blank sound file

	pop si
	jmp process_parameters

	.welcome_msg					db 'TUNEEDIT - Commandline Sound Editor for MikeOS', 13, 10
	.welcome_msg2					db 'Created by Joshua Beck', 13, 10
	.welcome_msg3					db 'Version 1.0.1', 13, 10
	.welcome_msg4					db 'Licenced under the GNU General Public Licence v3', 13, 10
	.welcome_msg5					db "Type '?' for help", 0

process_parameters:
	cmp si, 0
	je mainloop

	mov ax, si
	call os_string_length
	cmp ax, 12
	je .filename_too_long

	mov di, file_name
	call os_string_copy

	jmp cmd_open

.filename_too_long:
	mov si, .filename_too_long_msg
	call os_print_string
	call os_print_newline
	ret

	.filename_too_long_msg				db 'File name is too long', 0
	
mainloop:
	call os_print_newline
	mov si, prompt
	call os_print_string

	mov ax, input_buffer
	call os_input_string

	call os_string_uppercase
	mov si, ax

	lodsb
	
	cmp al, 0
	je mainloop
	
	call os_print_newline

;=======================
; Specific Commands
;=======================	
	cmp al, 'A'
	je cmd_author

	cmp al, 'B'
	je cmd_title

	cmp al, 'C'
	je cmd_clear

	cmp al, 'D'
	je cmd_display

	cmp al, 'E'
	je cmd_enter

	cmp al, 'H'
	je cmd_help
	
	cmp al, 'L'
	je cmd_length

	cmp al, 'M'
	je cmd_move

	cmp al, 'N'
	je cmd_name

	cmp al, 'O'
	je cmd_open

	cmp al, 'P'
	je cmd_play

	cmp al, 'Q'
	je cmd_quit
	
	cmp al, 'S'
	je cmd_save

	cmp al, 'T'
	je cmd_test

	cmp al, '?'
	je cmd_help

	jmp cmd_unknown

prompt			db "TUNEEDIT> ", 0
input_buffer		times 256 db 0


;===================
; AUTHOR COMMAND (A)
;===================
cmd_author:
	inc si
	
	mov di, sound_header
	add di, 24
	
	mov cx, 0	

.store_input:
	inc cx
	cmp cx, 11
	je mainloop

	lodsb

	cmp al, 0
	je .end_input
	stosb

	jmp .store_input


.end_input:
	mov al, 32
	stosb

	inc cx
	cmp cx, 10
	jge mainloop

	jmp .end_input
	

;==================
; TITLE COMMAND (B)
;==================
cmd_title:
	inc si
	
	mov di, sound_header
	add di, 4
	
	mov ax, si
	mov cx, 0	

.store_input:
	inc cx
	cmp cx, 21
	je mainloop

	lodsb

	cmp al, 0
	je .end_input
	stosb

	jmp .store_input


.end_input:
	mov al, 32
	stosb

	inc cx
	cmp cx, 20
	jge mainloop

	jmp .end_input

;==================
; CLEAR COMMAND (C)
;==================
cmd_clear:
	mov si, file_identifier				; copy the file identifier to the header
	mov di, sound_header
	call os_string_copy

	add di, 3					; store version number
	mov al, 1
	stosb

	mov al, 32					; fill the title and author with spaces
	mov cx, 30
	rep stosb
	
	mov ax, 0					; store the size as zero
	stosw

	mov al, 0					; blank to entire file space
	mov cx, 24000
	mov di, sound_file
	rep stosb

	cmp byte [clear_and_return], 1			; check if we have to return
	je .return

	jmp mainloop

.return:
	mov byte [clear_and_return], 0			; clear the return bit
	ret

	clear_and_return				db 0

;====================
; DISPLAY COMMAND (D)
;====================
cmd_display:
	inc si
	call get_number_parameter			; get tune number
	mov dx, ax
	
	cmp ax, 8000
	jge out_of_range

	mov bx, ax					; to get the actual location, multiply by three then add file start
	shl bx, 1
	add bx, ax
	add bx, sound_file

	call get_number_parameter			; get number of loops
	mov cx, ax

	add ax, dx					; error if total exceeds 8000
	cmp ax, 8000
	jg out_of_range
	
	mov si, bx

.print_byte:
	mov ax, dx					; print location, then seperator
	call os_int_to_string
	push si
	mov si, ax
	call os_print_string
	mov si, seperator
	call os_print_string
	pop si

	lodsw						; load the tone, convert it to a string and print
	call os_int_to_string
	push si
	mov si, ax
	call os_print_string
	pop si
	
	call os_print_space

	mov ah, 0					; do the same with the length
	lodsb
	
	call os_int_to_string
	push si
	mov si, ax
	call os_print_string
	pop si

	call os_print_newline

	inc dx						; continue required times
	loop .print_byte

	jmp mainloop

seperator							db " - ", 0

out_of_range:
	call os_print_newline
	mov si, err_out_of_range
	call os_print_string

	jmp mainloop

	err_out_of_range					db "Location out of range!", 0

;==================
; ENTER COMMAND (E)
;==================
cmd_enter:
	inc si
	call get_number_parameter

	mov cx, ax

	mov bx, ax
	shl bx, 1
	add ax, bx
	add ax, sound_file
	mov di, ax

.get_input:
	mov ax, cx
	call os_int_to_string
	mov si, ax
	call os_print_string

	mov si, prompt_marker
	call os_print_string

	mov ax, input_buffer
	call os_input_string
	
	mov si, ax
	lodsb
	cmp al, 0
	je mainloop
	dec si

	call get_number_parameter
	stosw

	call get_number_parameter
	stosb
	call os_print_newline
	
	inc cx	
	jmp .get_input

	prompt_marker						db '> ', 0

;===================
; LENGTH COMMAND (L)
;===================
cmd_length:
	inc si							; get a number off the commandline
	call get_number_parameter

	mov di, sound_header					; store it in the sound header
	add di, 34
	stosw

	jmp mainloop

;=================
; MOVE COMMAND (M)
;=================
cmd_move:
	inc si
	call get_number_parameter

	mov bx, ax
	shl bx, 1
	add ax, bx
	add ax, sound_file
	mov dx, ax

	call get_number_parameter

	mov bx, ax
	shl bx, 1
	add ax, bx
	add ax, sound_file
	mov di, ax

	call get_number_parameter

	mov bx, ax
	shl bx, 1
	add ax, bx
	mov cx, ax

	mov si, dx

	rep movsb
	jmp mainloop

;=================
; NAME COMMAND (N)
;=================
cmd_name:
	mov di, file_name
	
	lodsb
	cmp al, 0
	je .null

	mov cx, 12
	rep movsb
	mov al, 0
	stosb
	
	jmp mainloop

.null:
	stosb
	jmp mainloop

;=================
; OPEN COMMAND (O)
;=================
cmd_open:
	mov ax, file_name
	mov cx, sound_header
	call os_load_file
	jc .not_found

	mov si, sound_header
	mov cx, 3
	mov di, input_buffer
	rep movsb
	mov al, 0
	stosb

	mov si, file_identifier
	mov di, input_buffer
	call os_string_compare
	jnc .bad_format

	mov si, sound_header
	add si, 3
	lodsb
	cmp al, 0
	je .bad_version

	cmp al, 1
	jg .higher_version

	mov si, .file_loaded_msg
	call os_print_string
	mov si, file_name
	call os_print_string
	call os_print_newline

	mov si, sound_header
	add si, 34
	lodsw

	call os_int_to_string
	mov si, ax
	call os_print_string

	mov si, .tune_length_msg
	call os_print_string
	
	mov si, file_name
	mov di, open_file_name
	call os_string_copy
	
	jmp mainloop

.not_found:
	mov si, .load_failed_msg
	call os_print_string

	mov si, file_name
	call os_print_string
	
	jmp mainloop

.bad_format:
	mov si, .bad_format_msg
	call os_print_string
	call os_print_newline
	ret

.bad_version:
	mov si, .bad_version_msg
	call os_print_string
	call os_print_newline
	ret

.higher_version:
	mov si, .higher_version_msg
	call os_print_string
	call os_print_newline
	ret

	.bad_format_msg				db "File is not in the correct format.", 0
	.bad_version_msg			db "Version number is blank", 0
	.higher_version_msg			db "The file was created by a later version of this program", 0
	.file_loaded_msg			db "Loaded Tune: ", 0
	.tune_length_msg			db " tones in this tune.", 0
	.load_failed_msg			db "Failed to load the file: ", 0
	
;=================
; PLAY COMMAND (P)
;=================
cmd_play:
	inc si
	call get_number_parameter
	mov bx, ax
	shl bx, 1
	add ax, bx
	add ax, sound_file
	mov dx, ax

	call get_number_parameter
	mov cx, ax

	mov si, dx
	
.play_section:
	; now to play the tune, here's the loop

	lodsw					; get the frequency
	cmp ax, 0				; if the frequency is zero, don't play it
	je .skip
	call os_speaker_freq
	.skip:
	lodsb					; get the length
	mov ah, 0
	call os_pause				; wait for the specified length
	call os_speaker_off			; stop sound
	loop .play_section			; loop until end of song

	jmp mainloop

;=================
; QUIT COMMAND (Q)
;=================

cmd_quit:
	call os_clear_screen
	mov si, exit_message
	call os_print_string
	call os_print_newline

	ret

	exit_message				db 'Thanks for using TUNEEDIT sound editor! Bye Bye!', 0

;=================
; SAVE COMMAND (S)
;=================
cmd_save:
	mov ax, file_name
	call os_string_length
	cmp ax, 0
	je .no_filename
	
	mov ax, sound_header
	add bp, 34
	mov word bx, [bp]
;	cmp bx, 0
;	je .no_length
	
	mov ax, file_name
	call os_file_exists
	jnc .file_exists

	mov cx, bx
	shl cx, 1
	add cx, bx
	add cx, 36

	mov ax, file_name
	mov bx, sound_header

	call os_write_file
	jc .save_failed

.save_success:
	mov si, .success_msg
	call os_print_string

	mov si, file_name
	call os_print_string
	
	mov di, open_file_name
	call os_string_copy
	
	jmp mainloop

.file_exists:
	mov si, file_name
	mov di, open_file_name
	call os_string_compare
	jc .auto_overwrite
	
	mov si, .file_exists_msg
	call os_print_string

.ask_overwrite:
	mov si, file_name
	mov di, open_file_name
	call os_string_compare
	jc .auto_overwrite
	
	call os_wait_for_key
	cmp al, 'y'
	je .confirm_overwrite
	
	cmp al, 'Y'
	je .confirm_overwrite
	
	cmp al, 'n'
	je mainloop
	
	cmp al, 'N'
	je mainloop

	jmp .ask_overwrite
	
.confirm_overwrite:
	call os_print_newline
.auto_overwrite:
	mov ax, file_name
	call os_remove_file

	jmp cmd_save

.save_failed:
	mov si, .failure_msg
	call os_print_string
	call os_print_newline
	jmp mainloop
	
.no_filename:
	mov si, .no_filename_msg
	call os_print_string
	call os_print_newline
	jmp mainloop

.no_length:
	mov si, .no_length_msg
	call os_print_string
	call os_print_newline
	jmp mainloop

.data:
	.file_exists_msg			db 'File exists! Overwrite? (Y/N)', 0
	.success_msg				db 'Tune Saved to: ', 0
	.failure_msg				db 'File save failed.', 0
	.no_filename_msg			db 'You must set a file name before saving', 0
	.no_length_msg				db 'You must set the length of the file', 0


;=================
; TEST COMMAND (T)
;=================
cmd_test:
	inc si
	call get_number_parameter
	call os_speaker_freq

	call get_number_parameter
	mov ah, 0
	call os_pause

	call os_speaker_off
	jmp mainloop
	
;=================
; HELP COMMAND (?)
;=================
cmd_help:
	call os_print_newline
	
	mov si, help_string
	call os_print_string
	call os_print_newline	

	jmp mainloop


	help_string				db "Commands avaliable:", 13, 10
	help_string2				db "===================", 13, 10
	help_string3				db "?                      presents this help", 13, 10
	help_string4				db "a [string]             sets the author of the tune", 13, 10
	help_string5				db "b [string]             sets the title of the tune", 13, 10
	help_string6				db "c                      clear all data", 13, 10
	help_string7				db "d [loc] [num]          displays the stored value of tones", 13, 10
	help_string8				db "e [loc]                prompts to enter tones at location (as >[freq] [length])", 13, 10
	help_string9				db "l [num]                sets the length of the tune in tones", 13, 10
	help_string10				db "m [loc1] [loc2] [num]  copies data from one location to another", 13, 10
	help_string11				db "n [string]             sets the name of the file", 13, 10
	help_string12				db "o                      loads a file", 13, 10
	help_string13				db "p [loc] [num]          plays number of tones from location", 13, 10
	help_string14				db "q                      quit the program", 13, 10
	help_string15				db "s                      saves a file", 13, 10
	help_string16				db "t [freq] [len]         plays a specific tone", 0


cmd_unknown:
	mov si, unknown_command_msg
	call os_print_string

	jmp mainloop

	unknown_command_msg			db "Unknown Command! Type '?' for help", 0

get_number_parameter:
	push di
	push cx

	mov ax, 0

	mov di, number_tmp
	mov cx, 5

.number_digit:
	lodsb
	cmp al, '0'
	jl .end_number

	cmp al, '9'
	jg .end_number

	stosb
	loop .number_digit

.end_number:
	mov al, 0
	stosb

	push si
	mov si, number_tmp
	call os_string_to_int
	pop si

	pop cx
	pop di
	ret
	
	number_tmp				times 6 db 0

filespace:
	file_identifier				db 'SND', 0
	file_name				times 13 db 0
	open_file_name				times 13 db 0
	sound_header				times 36 db 0
	sound_file				db 0
