; Music Master (PLAY.ASM)
; A sound player for MikeOS, uses tune editor sound format
; Created by Joshua Beck
; Released under the GNU General Public Licence, revision 3
; Version 1.0.1

bits 16						; MikeOS program header
org 32768
%include 'tachyonos.inc'


load_parameters:
	cmp si, 0				; check for command line parameters
	je no_file				; if there is a null pointer there is no parameter, so ask for a file

	mov ax, si				; attempt to load the specified file
	mov cx, file_header
	call os_load_file

	jc no_file				; if it fails, ask for a file

validate_file:
	; check the file is valid

	mov si, file_header			; copy the file header into the string buffer
	mov di, string_buffer
	mov cx, 3
	rep movsb

	mov al, 0				; null terminate it
	stosb

	mov si, string_buffer			; check if the file header is correct
	mov di, sound_file_identifier
	call os_string_compare
	jnc invalid_file			; if not present an error and exit

	mov si, file_header			; get the version number
	add si, 3

	lodsb

	cmp al, 0				; version can't be zero
	je invalid_version

	cmp al, 1				; we use version 1 in this release, if greater it must be a future version
	jg future_version

display_information:
	; display the media information

	push si					; Print "Now Playing "
	mov si, now_playing_text
	call os_print_string
	pop si

	mov di, string_buffer			; copy the title to the string buffer and zero terminate
	mov cx, 20
	rep movsb

	mov al, 0
	stosb
	
	push si
	mov si, string_buffer			; print the title
	call os_print_string

	mov si, by_text				; print " By "
	call os_print_string
	pop si

	mov di, string_buffer			; copy the author into the string buffer and zero terminate it
	mov cx, 10
	rep movsb

	mov al, 0
	stosb

	push si
	mov si, string_buffer			; print the author
	call os_print_string
	pop si

	call os_print_newline

	lodsw					; get the song length
	mov cx, ax
	inc cx
	
play_sound:
	; now to play the tune, here's the loop

	lodsw					; get the freqency
	cmp ax, 0				; if the frequency is zero, don't play it
	je .skip
	call os_speaker_freq
	.skip:
	lodsb					; get the length
	mov ah, 0
	call os_pause				; wait for the specified length
	call os_speaker_off			; stop sound
	loop play_sound				; loop until end of song

	mov si, exit_message			; print exit message and return to the OS
	call os_print_string
	call os_print_newline
	call os_wait_for_key
	ret
	
.cancel:
	mov si, exit_message
	call os_print_string
	call os_wait_for_key
	ret

no_file:
	mov si, err_no_file
	call os_print_string
	call os_wait_for_key
	ret

file_not_found:
	mov si, err_file_not_found		; if a file cannot be loaded
	call os_print_string
	call os_print_newline
	call os_wait_for_key
	ret

invalid_file:
	mov si, err_invalid_file		; if the file is formatted incorrectly
	call os_print_string
	call os_print_newline
	call os_wait_for_key
	ret

invalid_version:
	mov si, err_invalid_version		; if the version is zero
	call os_print_string
	call os_print_newline
	call os_wait_for_key
	ret

future_version:
	mov si, err_future_version		; if the version is greater than the program supports
	call os_print_string
	mov si, err_future_version2
	call os_print_string
	call os_print_newline
	call os_wait_for_key
	ret


data:
	by_text					db '" by ', 0
	exit_text				db 'EXIT', 0
	exit_message				db 'Sound File Complete.', 0
	input_file_msg 				db 'Input a filename or "EXIT" to cancel', 0
	input_file_prompt			db 'Sound File> ', 0
	err_no_file				db 'You must specify a tune to play (commandline).', 0
	err_file_not_found			db 'File could not be loaded', 0
	err_invalid_file			db 'Error: File is not supported', 0
	err_invalid_version			db 'Error: Invalid version number', 0
	err_future_version			db 'Error: The version number is higher than this program supports.', 0
	err_future_version2			db 'You may need to update your program to support this version.', 0
	now_playing_text			db 'Now Playing: "', 0
	sound_file_identifier			db 'SND', 0
	string_buffer				times 256 db 0
	file_header				times 36 db 0
	file_contents				db 0
