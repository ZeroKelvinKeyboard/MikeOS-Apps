Modest Memory Manager --- A simple memory management library for MikeOS

This library is designed to perform simple memory allocating/freeing for binary
applications on MikeOS. 
All names of inputs and outputs are registers, except for 'CF' which is the
carry flag.

Name: memory_initialise
Input:          SI = pointer to start of managed area
                AX = size of managed area
Output:         CF = set on failure, otherwise clear
Description: Sets the area managed by the heap and initialises the heap. This
call must be performed before any other library calls can be performed.

Name: memory_allocate
Input:          AX = request size (bytes)
Output:         SI = pointer to memory block
                CF = set on failure, otherwise clear
Description: Allocates the given number of bytes on the heap and return the
address of the memory area.

Name: memory_free
Input:          SI = pointer to memory block
Output:         CF = set on failure, otherwise clear
Description: Frees previously allocated memory for later use.

See the included demo program 'memory.asm' for usage examples.



