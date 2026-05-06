# Capitulo 1 - Introduccion a NASM y el entorno de desarrollo

## Que es el lenguaje ensamblador

El lenguaje ensamblador (assembly) es el nivel de programacion mas cercano al hardware. Cada instruccion corresponde directamente a una operacion que el procesador puede ejecutar. A diferencia de lenguajes de alto nivel como Java o Python, aqui no hay abstracciones: tu controlas cada registro, cada byte de memoria y cada llamada al sistema operativo.

### Por que aprender ensamblador

- Entender como funciona realmente un procesador
- Comprender como los compiladores generan codigo
- Optimizar secciones criticas de rendimiento
- Analizar malware y realizar ingenieria inversa
- Desarrollar sistemas operativos y drivers
- Depurar problemas que son invisibles en alto nivel

---

## Que es NASM

NASM (Netwide Assembler) es un ensamblador para la arquitectura x86 y x86-64. Usa sintaxis Intel, que es mas legible que la sintaxis AT&T usada por el ensamblador de GNU (`as`).

### Diferencias entre sintaxis Intel y AT&T

| Caracteristica | Intel (NASM) | AT&T (GAS) |
|----------------|-------------|-------------|
| Orden de operandos | destino, fuente | fuente, destino |
| Prefijo de registros | ninguno | `%` |
| Prefijo de inmediatos | ninguno | `$` |
| Acceso a memoria | `[rax]` | `(%rax)` |

Ejemplo de la misma instruccion:

```
; Intel (NASM)
mov rax, 5

; AT&T (GAS)
movq $5, %rax
```

En este repositorio usamos exclusivamente sintaxis Intel con NASM.

---

## Arquitectura x86-64

La arquitectura x86-64 (tambien llamada AMD64 o x64) es una extension de 64 bits de la arquitectura x86. Los procesadores modernos de Intel y AMD usan esta arquitectura.

### Registros de proposito general

Los registros son pequeñas unidades de almacenamiento dentro del procesador. Son mucho mas rapidos que la memoria RAM.

```
Registro completo (64 bits):  RAX
Parte baja de 32 bits:        EAX
Parte baja de 16 bits:        AX
Byte alto de AX:              AH
Byte bajo de AX:              AL
```

Lista de registros de proposito general en x86-64:

| Registro | Uso comun |
|----------|-----------|
| `rax` | Acumulador, valor de retorno de funciones y syscalls |
| `rbx` | Base, preservado entre llamadas |
| `rcx` | Contador, usado por instrucciones de ciclo |
| `rdx` | Datos, tercer argumento de syscall |
| `rsi` | Source Index, segundo argumento de syscall |
| `rdi` | Destination Index, primer argumento de syscall |
| `rbp` | Base Pointer, apunta a la base del stack frame |
| `rsp` | Stack Pointer, apunta al tope de la pila |
| `r8-r15` | Registros adicionales de x86-64 |

### Registros especiales

| Registro | Proposito |
|----------|-----------|
| `rip` | Instruction Pointer, apunta a la siguiente instruccion |
| `rflags` | Registro de flags (resultado de comparaciones, estado del procesador) |

### Flags importantes en RFLAGS

| Flag | Nombre | Se activa cuando... |
|------|--------|---------------------|
| ZF | Zero Flag | El resultado de una operacion es cero |
| SF | Sign Flag | El resultado es negativo (bit mas significativo = 1) |
| CF | Carry Flag | Hay acarreo en operaciones sin signo |
| OF | Overflow Flag | Hay desbordamiento en operaciones con signo |

---

## Instalacion del entorno

### Debian / Ubuntu

```bash
sudo apt update
sudo apt install nasm gcc binutils
```

### Arch Linux

```bash
sudo pacman -S nasm gcc binutils
```

### Fedora

```bash
sudo dnf install nasm gcc binutils
```

### Verificar la instalacion

```bash
nasm --version
ld --version
gcc --version
```

---

## Flujo de trabajo: del codigo fuente al ejecutable

El proceso para convertir un archivo `.asm` en un programa ejecutable tiene dos pasos:

### Paso 1: Ensamblar

NASM convierte el codigo fuente en un archivo objeto (`.o`), que contiene codigo maquina pero todavia no es ejecutable.

```bash
nasm -f elf64 programa.asm -o programa.o
```

- `-f elf64`: Formato de salida ELF de 64 bits (el estandar en Linux x86-64)
- `-o programa.o`: Nombre del archivo objeto de salida

### Paso 2: Enlazar (link)

El enlazador (`ld`) toma el archivo objeto y produce un ejecutable.

```bash
ld programa.o -o programa
```

Si el programa usa funciones de la libreria estandar de C (como `printf`), se enlaza con `gcc`:

```bash
gcc programa.o -o programa -no-pie
```

- `-no-pie`: Desactiva Position Independent Executable para simplificar el direccionamiento

### Paso 3: Ejecutar

```bash
./programa
```

### Resumen del flujo

```
programa.asm  -->  [nasm]  -->  programa.o  -->  [ld/gcc]  -->  programa
  (fuente)        (ensamblar)    (objeto)        (enlazar)     (ejecutable)
```

---

## Depuracion con GDB

GDB (GNU Debugger) es la herramienta principal para depurar programas en ensamblador.

### Ensamblar con informacion de depuracion

```bash
nasm -f elf64 -g -F dwarf programa.asm -o programa.o
ld programa.o -o programa
```

### Comandos basicos de GDB

```bash
gdb ./programa
```

Dentro de GDB:

| Comando | Accion |
|---------|--------|
| `break _start` | Colocar un punto de interrupcion en `_start` |
| `run` | Ejecutar el programa |
| `stepi` | Ejecutar una sola instruccion |
| `info registers` | Ver el estado de todos los registros |
| `print/x $rax` | Ver el valor de `rax` en hexadecimal |
| `x/10xb &variable` | Examinar 10 bytes en memoria a partir de `variable` |
| `quit` | Salir de GDB |

---

## Primer programa: verificacion del entorno

Crea un archivo `test.asm` para comprobar que todo funciona:

```asm
section .data
    msg: db "El entorno funciona correctamente", 10
    len: equ $ - msg

section .text
    global _start

_start:
    mov rax, 1      ; syscall: sys_write
    mov rdi, 1      ; file descriptor: stdout
    mov rsi, msg    ; direccion del mensaje
    mov rdx, len    ; longitud del mensaje
    syscall

    mov rax, 60     ; syscall: sys_exit
    mov rdi, 0      ; codigo de salida: 0
    syscall
```

Ensambla, enlaza y ejecuta:

```bash
nasm -f elf64 test.asm -o test.o
ld test.o -o test
./test
```

Si ves el mensaje en la terminal, tu entorno esta listo.

---

Siguiente: [Capitulo 2 - Estructura de un programa](02-estructura-programa.md)
