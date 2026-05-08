SYS_WRITE:    equ 1
SYS_EXIT:     equ 60
STDOUT:       equ 1
EXIT_SUCCESS: equ 0

section .data:
    ; d = define, b = 1byte, w = 16bytes, d = 4 bytes, q 8bytes
    msg: db "Hello world", 10     ; 'H', 'e', 'l', 'l', 'o' or in ascii code, 10 = 0x0a
    len: equ $ - msg              ; centinel direction memory - first character memory = len

section .text
    global _start

_start:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, msg
    mov rdx, len
    syscall

fin:
    mov rax, SYS_EXIT              ; sys exit
    mov rdi, EXIT_SUCCESS          ; code 0
    syscall
