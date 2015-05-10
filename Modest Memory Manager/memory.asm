BITS 16
ORG 32768
%include 'mikedev.inc'

mov si, memory_area
mov ax, 1024
call memory_initialise
jc error

mov si, msg_init
call os_print_string
mov ax, memory_area
call os_print_4hex
call os_print_newline

mov ax, 20
call memory_allocate
jc error
mov cx, si

mov si, msg_alloc
call os_print_string
mov ax, cx
call os_print_4hex
call os_print_newline

mov ax, 300
call memory_allocate
jc error
mov dx, si

mov si, msg_alloc2
call os_print_string
mov ax, dx
call os_print_4hex
call os_print_newline

mov si, cx
call memory_free
jc error

mov si, msg_free
call os_print_string
mov ax, cx
call os_print_4hex
call os_print_newline

mov si, dx
call memory_free
jc error

mov si, msg_free2
call os_print_string
mov ax, dx
call os_print_4hex
call os_print_newline

ret

error:
	mov si, msg_problem
	call os_print_string
	ret

msg_init db 'Initialised 1024 bytes of memory from base address: 0x', 0
msg_alloc db 'Allocated 20 bytes of memory at address: 0x', 0
msg_alloc2 db 'Allocated 300 bytes of memory at address: 0x', 0
msg_free db 'Free 20 bytes of memory at address: 0x', 0
msg_free2 db 'Free 300 bytes of memory at address: 0x', 0
msg_problem db 'Something went wrong :(', 13, 10, 0

%include 'memory.lib'

memory_area: