; use C calling conventions to get user input and print output
; user input: radius of a circle
; output: area and circumference of the circle

default rel
extern printf
extern scanf

section .data
    msg: db "Enter radius: ", 0

    area_msg: db "Area: %lf", 10, 0
    circ_msg: db "Circumference: %lf", 10, 0
    
    fmt_scan: db "%lf", 0
    pi: dq 3.1415926535

section .bss
    r: resq 1

section .text
    global main

main:
    sub rsp, 8 ; align stack

    lea rdi, [msg]
    xor eax, eax ; clear eax before
    call printf

    lea rdi, [fmt_scan]
    lea rsi, [r]
    xor eax, eax
    call scanf

    ; calculate area
    movsd xmm0, [r]
    mulsd xmm0, xmm0
    mulsd xmm0, [pi]

    lea rdi, [area_msg]
    mov eax, 1
    call printf

    ; calculate circumference
    movsd xmm0, [r]
    mulsd xmm0, [pi]
    addsd xmm0, xmm0

    lea rdi, [circ_msg]
    mov eax, 1
    call printf

fin:
    add rsp, 8
    xor eax, eax
    ret

; ignore warnings
section .note.GNU-stack noalloc noexec nowrite progbits