# Capitulo 3 - Tipos de datos y variables

## Representacion de datos en el procesador

El procesador no distingue entre "texto", "numeros enteros" o "numeros flotantes". Todo es una secuencia de bits. La interpretacion depende de las instrucciones que uses y del contexto de tu programa.

---

## Tamanos de datos en x86-64

| Nombre | Abreviatura NASM | Tamano | Rango sin signo | Rango con signo |
|--------|-------------------|--------|-----------------|-----------------|
| Byte | `db` / `resb` | 1 byte (8 bits) | 0 a 255 | -128 a 127 |
| Word | `dw` / `resw` | 2 bytes (16 bits) | 0 a 65535 | -32768 a 32767 |
| Double Word | `dd` / `resd` | 4 bytes (32 bits) | 0 a ~4.2 mil millones | -2147483648 a 2147483647 |
| Quad Word | `dq` / `resq` | 8 bytes (64 bits) | 0 a ~18.4 quintillones | -9.2 a 9.2 quintillones |
| Ten Bytes | `dt` / `rest` | 10 bytes (80 bits) | Usado para flotantes extendidos | - |

---

## Definir variables inicializadas (section .data)

Se usan las directivas `db`, `dw`, `dd`, `dq` para definir datos con un valor inicial.

### Bytes (db)

```asm
section .data
    caracter:  db 'A'           ; un solo caracter ASCII (1 byte)
    numero:    db 42            ; un entero de 1 byte
    cadena:    db "Hola", 0     ; cadena terminada en nulo
    mensaje:   db "Hola", 10    ; cadena con salto de linea
    bytes:     db 0xFF, 0x0A    ; dos bytes definidos en hexadecimal
```

### Words (dw)

```asm
section .data
    puerto:    dw 8080          ; entero de 16 bits
    valores:   dw 100, 200, 300 ; arreglo de 3 words
```

### Double Words (dd)

```asm
section .data
    entero32:  dd 1000000       ; entero de 32 bits
    flotante:  dd 3.14          ; flotante de precision simple (32 bits)
```

### Quad Words (dq)

```asm
section .data
    entero64:  dq 9999999999    ; entero de 64 bits
    pi:        dq 3.14159265    ; flotante de doble precision (64 bits)
```

---

## Reservar variables no inicializadas (section .bss)

Se usan las directivas `resb`, `resw`, `resd`, `resq` para reservar espacio sin valor inicial.

```asm
section .bss
    buffer:    resb 256     ; reservar 256 bytes
    nombre:    resb 32      ; reservar 32 bytes para una cadena
    resultado: resb 1       ; reservar 1 byte
    edad:      resw 1       ; reservar 1 word (2 bytes)
    total:     resd 1       ; reservar 1 dword (4 bytes)
    puntaje:   resq 1       ; reservar 1 qword (8 bytes)
```

---

## Constantes con equ

Las constantes definidas con `equ` se resuelven en tiempo de ensamblado y no ocupan memoria.

```asm
TAM_BUFFER:  equ 256
SYS_WRITE:   equ 1
SYS_EXIT:    equ 60
STDOUT:      equ 1
NEWLINE:     equ 10
```

A diferencia de `db`, una constante `equ` no tiene direccion en memoria. Es un reemplazo directo del valor numerico.

---

## Cadenas de texto

En ensamblador no existe un tipo "string". Las cadenas son simplemente secuencias de bytes consecutivos.

### Terminacion en nulo (estilo C)

```asm
cadena: db "Hola mundo", 0     ; el byte 0 marca el final
```

### Con longitud calculada

```asm
msg:     db "Hola mundo", 10
msg_len: equ $ - msg           ; longitud calculada automaticamente
```

El operador `$` devuelve la posicion actual en el archivo. Al restar la posicion de inicio (`msg`), obtenemos la longitud de la cadena incluyendo el salto de linea.

### Caracteres especiales

| Codigo | Significado |
|--------|-------------|
| `10` | Salto de linea (line feed, `\n`) |
| `13` | Retorno de carro (carriage return, `\r`) |
| `0` | Terminador nulo |
| `9` | Tabulacion |

```asm
; linea con tabulacion y salto de linea
linea: db 9, "Texto tabulado", 10
```

---

## Acceso a variables en memoria

Para leer o escribir una variable en memoria, se usan corchetes `[]` para indicar acceso a la direccion de memoria.

### Mover un valor de memoria a un registro

```asm
section .data
    valor: db 25

section .text
    mov al, [valor]         ; cargar el byte de "valor" en al
```

Es importante usar el registro del tamano correcto:

```asm
section .data
    byte_val:  db 10
    word_val:  dw 1000
    dword_val: dd 100000
    qword_val: dq 9999999999

section .text
    mov al,  [byte_val]     ; 1 byte  -> registro de 8 bits
    mov ax,  [word_val]     ; 2 bytes -> registro de 16 bits
    mov eax, [dword_val]    ; 4 bytes -> registro de 32 bits
    mov rax, [qword_val]    ; 8 bytes -> registro de 64 bits
```

### Mover un valor de un registro a memoria

```asm
section .data
    resultado: db 0

section .text
    mov byte [resultado], 42    ; escribir el valor 42 en "resultado"
```

Cuando se mueve un inmediato a memoria, es necesario especificar el tamano (`byte`, `word`, `dword`, `qword`).

---

## LEA vs MOV

Estas dos instrucciones se confunden a menudo:

- `mov rax, [variable]` -- carga el **valor** almacenado en la direccion de `variable`
- `lea rax, [variable]` -- carga la **direccion** de `variable` (sin acceder a memoria)

```asm
section .data
    msg: db "Hola", 0

section .text
    mov al, [msg]           ; al = 'H' (el primer byte del contenido)
    lea rsi, [rel msg]      ; rsi = direccion de memoria donde esta "msg"
```

`lea` es util cuando necesitas pasar la direccion de una variable a una syscall o funcion.

---

## Orden de bytes: Little Endian

Los procesadores x86 usan orden **little endian**: el byte menos significativo se almacena primero en la direccion de memoria mas baja.

Por ejemplo, el valor `0x12345678` almacenado como `dd`:

```
Direccion:  0x00  0x01  0x02  0x03
Contenido:  0x78  0x56  0x34  0x12
```

Esto es importante cuando examinas memoria con un depurador o con `hexdump`.

---

## Arreglos

Un arreglo es simplemente una secuencia de valores consecutivos en memoria.

```asm
section .data
    numeros: db 10, 20, 30, 40, 50     ; arreglo de 5 bytes
    pares:   dw 2, 4, 6, 8, 10         ; arreglo de 5 words (10 bytes total)
    datos:   dd 100, 200, 300           ; arreglo de 3 dwords (12 bytes total)
```

Para acceder a un elemento especifico, se calcula la direccion base + (indice * tamano del elemento):

```asm
; Acceder al tercer elemento del arreglo "numeros" (indice 2)
mov al, [numeros + 2]       ; al = 30

; Acceder al segundo elemento de "pares" (indice 1, cada word ocupa 2 bytes)
mov ax, [pares + 2]         ; ax = 4

; Acceder al tercer elemento de "datos" (indice 2, cada dword ocupa 4 bytes)
mov eax, [datos + 8]        ; eax = 300
```

---

## Ejemplo completo

```asm
; Programa: define varias variables y muestra un mensaje

SYS_WRITE: equ 1
SYS_EXIT:  equ 60
STDOUT:    equ 1

section .data
    nombre:     db "NASM", 0
    version:    dw 2
    msg:        db "Tipos de datos en ensamblador", 10
    msg_len:    equ $ - msg
    numeros:    db 1, 2, 3, 4, 5

section .bss
    buffer:     resb 128
    resultado:  resq 1

section .text
    global _start

_start:
    ; mostrar el mensaje
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, msg
    mov rdx, msg_len
    syscall

    ; leer el tercer numero del arreglo
    movzx rax, byte [numeros + 2]   ; rax = 3

    ; salir
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall
```

Nota: `movzx` (move with zero extension) extiende un valor pequeño a un registro mas grande llenando con ceros. Esto evita que queden datos basura en los bits superiores del registro.

---

Anterior: [Capitulo 2 - Estructura de un programa](02-estructura-programa.md) | Siguiente: [Capitulo 4 - Operaciones aritmeticas](04-operaciones-aritmeticas.md)
