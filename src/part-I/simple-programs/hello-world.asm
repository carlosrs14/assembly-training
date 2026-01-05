section .data:
    ; d = define, b = 1byte, w = 16bytes, d = 4 bytes, q 8bytes
    msg: db "Hello world", 10 ; 'H', 'e', 'l', 'l', 'o' or in ascii code, 10 = 0x0a
    len: equ $ - msg          ; centinel direction memory - first character memory = len

section .text
    global _start

_start:
    mov rax, 1    ; sys write
    mov rdi, 1    ; std out
    mov rsi, msg
    mov rdx, len
    syscall        ; modern system call

fin:
    mov rax, 60   ; sys exit
    mov rdi, 0    ; code 0
    syscall
