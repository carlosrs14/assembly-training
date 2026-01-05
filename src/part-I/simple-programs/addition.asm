; sum one digit number

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

    mov rax, 1
    mov rdi, 1
    lea rsi, [rel result]
    mov rdx, 1
    syscall
    
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel nl]
    mov rdx, 1
    syscall

fin: 
    mov rax, 60
    xor rdi, rdi
    syscall