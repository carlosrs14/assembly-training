# Capitulo 4 - Operaciones aritmeticas

## Instrucciones aritmeticas basicas

Las operaciones aritmeticas son las instrucciones fundamentales del procesador. Todas operan sobre registros o memoria y afectan los flags del registro RFLAGS.

---

## Suma: add

Suma el operando fuente al operando destino y almacena el resultado en el destino.

```asm
add destino, fuente    ; destino = destino + fuente
```

### Ejemplos

```asm
mov rax, 10
add rax, 5          ; rax = 15

mov al, 3
add al, 7           ; al = 10

; sumar un valor de memoria
section .data
    num: db 20

section .text
    mov al, 5
    add al, [num]   ; al = 25
```

### Flags afectados

- **ZF**: Se activa si el resultado es 0
- **CF**: Se activa si hay acarreo (resultado excede el tamano del registro)
- **OF**: Se activa si hay desbordamiento con signo
- **SF**: Se activa si el resultado es negativo

---

## Resta: sub

Resta el operando fuente del operando destino.

```asm
sub destino, fuente    ; destino = destino - fuente
```

### Ejemplos

```asm
mov rax, 20
sub rax, 8          ; rax = 12

mov al, 10
sub al, 3           ; al = 7

; resultado negativo (con signo)
mov al, 5
sub al, 10          ; al = -5 (0xFB), SF se activa
```

---

## Incremento y decremento: inc, dec

Incrementar o decrementar en 1. No afectan el Carry Flag (CF).

```asm
inc rax     ; rax = rax + 1
dec rax     ; rax = rax - 1

inc byte [variable]    ; incrementar un byte en memoria
dec word [contador]    ; decrementar un word en memoria
```

---

## Negacion: neg

Cambia el signo del operando (complemento a dos).

```asm
mov rax, 5
neg rax         ; rax = -5 (0xFFFFFFFFFFFFFFFB)

mov rax, -10
neg rax         ; rax = 10
```

---

## Multiplicacion sin signo: mul

Multiplica el acumulador por el operando. El resultado se almacena en un par de registros porque la multiplicacion puede producir un resultado del doble de tamano.

```asm
mul fuente     ; resultado en rdx:rax (para 64 bits)
```

| Tamano del operando | Acumulador | Resultado |
|---------------------|------------|-----------|
| `mul r/m8` | AL | AX (AH:AL) |
| `mul r/m16` | AX | DX:AX |
| `mul r/m32` | EAX | EDX:EAX |
| `mul r/m64` | RAX | RDX:RAX |

### Ejemplo

```asm
mov rax, 7
mov rbx, 6
mul rbx         ; rdx:rax = 42 (rdx=0, rax=42)
```

---

## Multiplicacion con signo: imul

Similar a `mul` pero interpreta los operandos como numeros con signo. Tiene formas adicionales mas convenientes.

### Forma de un operando (igual que mul)

```asm
imul rbx        ; rdx:rax = rax * rbx (con signo)
```

### Forma de dos operandos

```asm
imul rax, rbx   ; rax = rax * rbx
imul rax, 5     ; rax = rax * 5
```

### Forma de tres operandos

```asm
imul rax, rbx, 10   ; rax = rbx * 10
```

---

## Division sin signo: div

Divide el par rdx:rax entre el operando. El cociente queda en rax y el residuo en rdx.

```asm
div divisor
```

| Tamano | Dividendo | Cociente | Residuo |
|--------|-----------|----------|---------|
| `div r/m8` | AX | AL | AH |
| `div r/m16` | DX:AX | AX | DX |
| `div r/m32` | EDX:EAX | EAX | EDX |
| `div r/m64` | RDX:RAX | RAX | RDX |

### Ejemplo

```asm
mov rax, 17
xor rdx, rdx    ; limpiar rdx (parte alta del dividendo)
mov rbx, 5
div rbx          ; rax = 3 (cociente), rdx = 2 (residuo)
```

Es critico limpiar `rdx` antes de `div` con `xor rdx, rdx`. Si `rdx` tiene basura, el dividendo sera incorrecto y probablemente cause una excepcion de division.

---

## Division con signo: idiv

Igual que `div` pero para numeros con signo. Antes de dividir, se debe extender el signo del dividendo.

```asm
; para extender el signo de rax a rdx:rax
cqo              ; sign-extend rax into rdx:rax

mov rax, -17
cqo              ; rdx = -1 (todos los bits en 1)
mov rbx, 5
idiv rbx         ; rax = -3, rdx = -2
```

Instrucciones de extension de signo:

| Instruccion | Operacion |
|-------------|-----------|
| `cbw` | Extiende AL a AX |
| `cwd` | Extiende AX a DX:AX |
| `cdq` | Extiende EAX a EDX:EAX |
| `cqo` | Extiende RAX a RDX:RAX |

---

## Conversion de digitos para imprimir

Los numeros de un solo digito (0-9) se pueden convertir a su caracter ASCII sumando `'0'` (que es 48).

```asm
; resultado numerico en AL
add al, '0'         ; convertir digito a caracter ASCII
mov [resultado], al ; almacenar para imprimir
```

Para convertir de caracter ASCII a valor numerico:

```asm
sub al, '0'         ; '5' (0x35) -> 5
```

---

## Ejemplo: suma de dos numeros

Basado en el codigo del repositorio:

```asm
; Sumar dos numeros de un digito y mostrar el resultado

section .data
    num1:   db 3
    num2:   db 4
    result: db 0
    nl:     db 10

section .text
    global _start

_start:
    mov al, [num1]      ; al = 3
    add al, [num2]      ; al = 3 + 4 = 7
    add al, '0'         ; al = '7' (convertir a ASCII)
    mov [result], al    ; almacenar el caracter

    ; imprimir resultado
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel result]
    mov rdx, 1
    syscall

    ; imprimir salto de linea
    mov rax, 1
    mov rdi, 1
    lea rsi, [rel nl]
    mov rdx, 1
    syscall

    ; salir
    mov rax, 60
    xor rdi, rdi
    syscall
```

---

## Ejemplo: resta

```asm
; Restar dos numeros de un digito

section .data
    num1:   db 9
    num2:   db 3
    result: db 0
    nl:     db 10

section .text
    global _start

_start:
    mov al, [num1]      ; al = 9
    sub al, [num2]      ; al = 9 - 3 = 6
    add al, '0'         ; al = '6'
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

    mov rax, 60
    xor rdi, rdi
    syscall
```

---

## Tabla resumen de instrucciones aritmeticas

| Instruccion | Operacion | Ejemplo |
|-------------|-----------|---------|
| `add a, b` | a = a + b | `add rax, 5` |
| `sub a, b` | a = a - b | `sub rax, 3` |
| `inc a` | a = a + 1 | `inc rcx` |
| `dec a` | a = a - 1 | `dec rcx` |
| `neg a` | a = -a | `neg rax` |
| `mul b` | rdx:rax = rax * b | `mul rbx` |
| `imul a, b` | a = a * b (con signo) | `imul rax, 5` |
| `div b` | rax = rdx:rax / b, rdx = residuo | `div rbx` |
| `idiv b` | igual que div, con signo | `idiv rbx` |

---

Anterior: [Capitulo 3 - Tipos de datos y variables](03-tipos-datos-variables.md) | Siguiente: [Capitulo 5 - Entrada y salida](05-entrada-salida.md)
