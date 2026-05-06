# Capitulo 2 - Estructura de un programa en NASM

## Anatomia de un programa en ensamblador

Todo programa en NASM para Linux x86-64 se organiza en secciones. Cada seccion tiene un proposito distinto y el sistema operativo las carga en diferentes regiones de memoria con permisos especificos.

---

## Secciones principales

### section .data - Datos inicializados

Esta seccion contiene variables que tienen un valor definido antes de que el programa comience a ejecutarse. Los datos aqui se almacenan directamente en el archivo ejecutable.

```asm
section .data
    mensaje: db "Hola", 10    ; cadena con salto de linea
    numero:  dd 42            ; entero de 32 bits con valor 42
    pi:      dq 3.14159       ; flotante de 64 bits
```

### section .bss - Datos no inicializados

Esta seccion reserva espacio en memoria sin asignar un valor inicial. Es util para buffers de entrada y variables que se llenan durante la ejecucion. No ocupa espacio en el archivo ejecutable, solo reserva memoria al cargar el programa.

```asm
section .bss
    buffer: resb 64      ; reservar 64 bytes
    edad:   resb 1       ; reservar 1 byte
    total:  resq 1       ; reservar 8 bytes (qword)
```

### section .text - Codigo ejecutable

Aqui se colocan las instrucciones del programa. Esta seccion tiene permisos de lectura y ejecucion, pero no de escritura.

```asm
section .text
    global _start     ; exportar el punto de entrada

_start:
    ; las instrucciones van aqui
```

---

## El punto de entrada: _start

Cuando se usa `ld` como enlazador, el punto de entrada del programa es la etiqueta `_start`. La directiva `global _start` la hace visible para el enlazador.

```asm
section .text
    global _start

_start:
    ; primera instruccion que ejecuta el procesador
    mov rax, 60
    xor rdi, rdi
    syscall
```

Si se enlaza con `gcc` (para usar funciones de C), el punto de entrada es `main`:

```asm
section .text
    global main

main:
    ; ...
    ret
```

---

## Comentarios

Los comentarios en NASM comienzan con punto y coma (`;`). Todo lo que sigue al `;` en una linea es ignorado por el ensamblador.

```asm
mov rax, 1    ; esto es un comentario
; esta linea completa es un comentario
```

---

## Etiquetas

Las etiquetas son nombres que representan posiciones en el codigo o en los datos. Se usan como referencia para saltos, direcciones de variables y puntos de entrada a subrutinas.

```asm
_start:           ; etiqueta de punto de entrada
    jmp fin       ; salta a la etiqueta "fin"

mostrar:          ; etiqueta de subrutina
    ; ...
    ret

fin:              ; etiqueta de salida
    mov rax, 60
    xor rdi, rdi
    syscall
```

Las etiquetas locales comienzan con un punto y pertenecen a la etiqueta global anterior:

```asm
funcion1:
    .inicio:      ; etiqueta local: funcion1.inicio
    ; ...

funcion2:
    .inicio:      ; etiqueta local: funcion2.inicio (diferente)
    ; ...
```

---

## Directivas del ensamblador

Las directivas no son instrucciones del procesador. Son comandos que le indican a NASM como procesar el codigo fuente.

### global

Exporta un simbolo para que sea visible desde el enlazador:

```asm
global _start
global main
```

### extern

Declara un simbolo definido en otro archivo objeto o libreria:

```asm
extern printf
extern scanf
```

### equ - Constantes

Define una constante que se resuelve en tiempo de ensamblado. No ocupa memoria.

```asm
SYS_WRITE: equ 1
SYS_EXIT:  equ 60
STDOUT:    equ 1

section .data
    msg: db "Hola", 10
    len: equ $ - msg       ; $ = direccion actual, msg = inicio de la cadena
```

El operador `$` representa la direccion actual en el programa. La expresion `$ - msg` calcula la distancia entre la posicion actual y el inicio de `msg`, lo que da como resultado la longitud del mensaje.

### default rel

Indica que todas las referencias a memoria deben ser relativas al instruction pointer (`rip`). Necesario para codigo PIC (Position Independent Code):

```asm
default rel

section .text
    global main

main:
    lea rdi, [msg]      ; con default rel, esto es equivalente a [rel msg]
```

---

## Programa completo de ejemplo

Veamos como se integran todas las partes en un programa funcional:

```asm
; Programa: Muestra un mensaje de saludo
; Enlazar con: ld

SYS_WRITE: equ 1
SYS_EXIT:  equ 60
STDOUT:    equ 1

section .data
    saludo: db "Bienvenido al curso de NASM", 10
    saludo_len: equ $ - saludo

section .bss
    ; no usamos datos no inicializados en este ejemplo

section .text
    global _start

_start:
    ; escribir el mensaje en pantalla
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, saludo
    mov rdx, saludo_len
    syscall

    ; salir del programa
    mov rax, SYS_EXIT
    mov rdi, 0           ; codigo de salida 0 = exito
    syscall
```

---

## El formato ELF

Cuando NASM ensambla con `-f elf64`, produce un archivo en formato ELF (Executable and Linkable Format), que es el formato estandar de ejecutables en Linux. El archivo ELF contiene:

1. **Cabecera ELF**: Identifica el archivo como ELF, especifica la arquitectura y el punto de entrada
2. **Tabla de secciones**: Describe las secciones (.text, .data, .bss)
3. **Tabla de simbolos**: Lista los simbolos exportados (como `_start`)
4. **Codigo y datos**: El contenido real de cada seccion

Puedes inspeccionar un archivo objeto con:

```bash
objdump -d programa.o        # desensamblar
readelf -a programa.o        # ver estructura ELF
hexdump -C programa.o        # ver bytes en hexadecimal
```

---

## Errores comunes en la estructura

| Error | Causa | Solucion |
|-------|-------|----------|
| `undefined reference to _start` | Falta `global _start` | Agregar la directiva |
| `segmentation fault` al ejecutar | Falta la syscall de salida | Agregar `sys_exit` al final |
| `section .data:` con dos puntos | Sintaxis incorrecta de la seccion | Quitar los dos puntos despues del nombre de seccion |
| Datos corruptos en `.data` | Tipo de dato incorrecto (`db` vs `dq`) | Verificar el tamaño correcto |

---

Anterior: [Capitulo 1 - Introduccion](01-introduccion.md) | Siguiente: [Capitulo 3 - Tipos de datos y variables](03-tipos-datos-variables.md)
