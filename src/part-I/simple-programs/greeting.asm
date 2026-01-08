; ask for a name and greet the user

section .data
    msg: db "Enter your name: ", 0
    msg_len: equ $ - msg

    greet: db "Hello, ", 0
    greet_len: equ $ - greet

    nl: db 10

section .bss
    name: resb 32          ; reserve 32 bytes for name input
    name_len: resq 1       ; reserve 8 byte for length of name

section .text
    global _start

_start:
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel msg]
    mov rdx, msg_len
    syscall

    ; read user input
    mov rax, 0
    mov rdi, 0
    lea rsi, [rel name]
    mov rdx, 32
    syscall

    ; store length of name
    dec rax
    mov [name_len], rax


    mov rax, 1
    mov rdi, 1
    lea rsi, [rel greet]
    mov rdx, greet_len
    syscall

    mov rax, 1
    mov rdi, 1
    lea rsi, [rel name]
    mov rdx, [name_len]
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