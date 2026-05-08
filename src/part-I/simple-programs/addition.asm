; sum one digit number
SYS_WRITE: equ 1
SYS_EXIT:  equ 60
STDOUT:    equ 1
EXIT_SUCCESS: equ 0

section .data
    num1: db 1
    num2: db 8
    result: db 0
    nl: db 10

section .text
    global _start

_start:
    mov al, [num1]
    add al, [num2]
    add al, '0'
    mov [result], al

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    lea rsi, [rel result]
    mov rdx, 1
    syscall
    
    mov rax, SYS_WRITE
    mov rdi, SYS_EXIT
    lea rsi, [rel nl]
    mov rdx, 1
    syscall

fin: 
    mov rax, SYS_EXIT
    mov rdi, EXIT_SUCCESS
    syscall