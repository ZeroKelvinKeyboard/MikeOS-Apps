; Modest Memory Manager
; A memory management library for MikeOS
; Created by Joshua Beck

%ifndef HASMEMORYMANAGER

%define MEMORY_BLOCK_FREE -1
%define MEMORY_BLOCK_ALLOCATED 1
%define MEMORY_BLOCK_RESERVED 2
%define MEMORY_BLOCK_END 3

%define MEMORY_HEADER_LENGTH 3
%define MEMORY_MINIMUM_BLOCK_SIZE 10

; -------------------------------------------------------------------
; Function: memory_initialise
; Description: Assigns a memory area for use by the memory manager.
; Input: SI = pointer to the area, AX = size of the area
; Output: CF = set on failure, otherwise clear
; Note: This must be called before using the memory manager and 
;       information about any existing memory areas will be lost.

memory_initialise:
	cmp ax, (MEMORY_HEADER_LENGTH * 2) + MEMORY_MINIMUM_BLOCK_SIZE
	jl .failed
	
	push ax
	push si
	
	; Remember the address of the first block
	mov [memory_data.base_address], si
	
	; Create a free space block covering the entire area
	; Minus six bytes for the block header and the end marker
	mov byte [si], MEMORY_BLOCK_FREE
	sub ax, MEMORY_HEADER_LENGTH*2
	mov word [si + 1], ax
	
	; Create the end marker with the last three bytes
	add ax, MEMORY_HEADER_LENGTH
	add si, ax
	mov byte [si], MEMORY_BLOCK_END
	mov word [si + 1], 0
	
	pop si
	pop ax
	clc
	ret
	
.failed:
	stc
	ret
	
; -------------------------------------------------------------------
; Function: memory_allocate
; Description: Allocates free memory for use by a program
; Input: AX = Requested Size (bytes)
; Output: SI = Memory Address, CF = set on failure, otherwise clear

memory_allocate:
	push ax
	
	; Start looking at the first block
	mov si, [memory_data.base_address]
	
	; Make sure the memory manager has been initialised
	cmp si, 0
	je .failed
	
	; Increase the size request if it is below minimum block size
	cmp ax, MEMORY_MINIMUM_BLOCK_SIZE
	jge .locate_free
	
	mov ax, MEMORY_MINIMUM_BLOCK_SIZE
	
.locate_free:
	; If the end block is found, all memory blocks have been checked
	cmp byte [si], MEMORY_BLOCK_END
	je .failed
	
	; If the memory is free, continue to the next stage
	cmp byte [si], MEMORY_BLOCK_FREE
	je .check_size
	
	; Otherwise check the next memory block
.next_block:
	add si, [si + 1]
	add si, MEMORY_HEADER_LENGTH
	jmp .locate_free

.check_size:
	; Make sure this block has at least the requested amount of memory
	cmp [si + 1], ax
	jl .next_block
	
	; Check how much larger the free block is than the size requested
	; Split the block if the difference is big enough to create an independent
	; block, otherwise just ignore it.
	add ax, MEMORY_HEADER_LENGTH + MEMORY_MINIMUM_BLOCK_SIZE
	cmp [si + 1], ax
	jge .split_block
	
.allocate_block:
	; Allocate the new memory block
	mov byte [si], MEMORY_BLOCK_ALLOCATED
	
	; Move pointer to first free byte rather than header
	add si, MEMORY_HEADER_LENGTH
	
	pop ax
	clc
	ret

.split_block:
	; Restore AX to the requested memory size
	sub ax, MEMORY_HEADER_LENGTH + MEMORY_MINIMUM_BLOCK_SIZE
	
	push bx

	; Find the size of the new block
	; Size = Original_Size - Allocated_Amount - Header_Length
	mov bx, [si + 1]
	sub bx, ax
	sub bx, MEMORY_HEADER_LENGTH
	
	; Create the new memory block after the existing one
	add si, ax
	add si, MEMORY_HEADER_LENGTH
	mov byte [si], MEMORY_BLOCK_FREE
	mov [si + 1], bx
	
	pop bx
	
	; Return to the original block and change the length
	sub si, MEMORY_HEADER_LENGTH
	sub si, ax
	mov [si + 1], ax
	
	jmp .allocate_block
	
.failed:
	pop ax
	mov si, 0
	stc
	ret
	
	
	
; -------------------------------------------------------------------
; Function: memory_free
; Description: Frees a previously created memory block
; Input: SI = Memory Address (as returned by memory_allocate)
; Output: CF = set on failure, otherwise clear

memory_free:
	pusha
	
	mov di, si
	; Pointer to the header rather than the first byte of memory
	sub di, MEMORY_HEADER_LENGTH
	
	; Make sure the memory manager is initialised
	mov si, [memory_data.base_address]
	cmp si, 0
	je .failed
	
	; Check if the base block is the requested block
	cmp si, di
	je .free_block
	
.find_block:
	; If this is the last block the request block could not be found
	cmp byte [si], MEMORY_BLOCK_END
	je .failed
	
	; Check if the address of the next block is the requested block
	; If so, we've found the block to free, move on to the next stage
	mov ax, si
	add ax, [si + 1]
	add ax, MEMORY_HEADER_LENGTH
	cmp ax, di
	je .check_merge
	
	; If not, keep searching for the next block
.next_block:
	mov si, ax
	jmp .find_block
	
.check_merge:
	; If the block before the requested block is free it would be better
	; to merge the free space rather than just freeing the requested block
	cmp byte [si], MEMORY_BLOCK_FREE
	je .merge_block
	
	mov si, di
	jmp .free_block
	
.merge_block:
	; Add the space occupied by the requested block to the previous block
	mov ax, [di + 1]
	add ax, MEMORY_HEADER_LENGTH
	add [si + 1], ax
	
	mov byte [di], 0
	mov word [di + 1], 0
	mov di, si
	
	jmp .check_merge2
	
.free_block:
	mov byte [si], MEMORY_BLOCK_FREE
	
.check_merge2:
	; Check the block after the requested block
	add di, [si + 1]
	add di, MEMORY_HEADER_LENGTH
	
	; If the block after the requested block is free the space should
	; also be merged.
	cmp byte [di], MEMORY_BLOCK_FREE
	jne .finished
	
	mov ax, [di + 1]
	add ax, MEMORY_HEADER_LENGTH
	add [si + 1], ax
	
	mov byte [di], 0
	mov word [di + 1], 0
	
.finished:
	; Return with success
	popa
	clc
	ret
	
.failed:
	; Return with failure
	popa
	stc
	ret
	
	
memory_data:
	.base_address							dw 0
	

%endif
	
%define HASMEMORYMANAGER
	