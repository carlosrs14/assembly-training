SYS_WRITE:    equ 1
SYS_EXIT:     equ 60
STDOUT:       equ 1
EXIT_SUCCESS: equ 0

section .data
    name:     db "NASM", 0
    version:  dw 2
    msg:      db "Data types on asm", 10
    msg_len:  equ $ - msg
    numbers:  db 1, 2, 3, 4, 5

section .bss
    buffer: resb 128
    res:    resq 1

section .text
    global _start

_start:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, msg
    mov rdx, msg_len
    syscall

    movzx rax, byte [numbers + 2]

fin:
    mov rax, SYS_EXIT
    mov rdi, EXIT_SUCCESS
    syscall