---
layout: single
title: Escalamiento de Privilegios - Windows
comments: true
excerpt: "Escalaremos privilegios en windows haciendo uso de un Exploit de kernel"
date: 2020-10-04
classes: wide
header:
  teaser: /assets/images/buffer-overflow-minishare/
  teaser_home_page: true
categories:
  - Hacking
tags:
  - OSCP
  - HTB
  - Hacking
---

## Escalamiento Privilegios - Windows

Un atacante logro obtener acceso al sistema con una shell. Sin embargo en muchos casos los permisos actualmente obtenidos son limitados. Por ello intentarán escalar los privilegios para obtener más permisos u obtener acceso a sistemas adicionales más sensibles.

En este escenario se relata las diversas tecnicas que se usan para ganar privilegios System en Windows.

### Exploit Kernel de Windows

Aca hemos tenido acceso por medio de una shell con netcat, al revisar los permisos que actualmente tenemos con el commando whoami, vemos que solo tenemos iis apppool\web

<p align="center">
<img src="/assets/images/Escalamiento-de-Privilegios-Windows-01/2020-11-19 10-00-20.png">
</p>

ahora ejecutaremos el comando Systeminfo para obtener mas informacion del sistema operativo en el que queremos ganar privilegios


```bash
c:\windows\system32\inetsrv>systeminfo
systeminfo

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
System Boot Time:          22/11/2020, 11:57:24 ��
System Manufacturer:       VMware, Inc.
System Model:              VMware Virtual Platform
System Type:               X86-based PC
Processor(s):              1 Processor(s) Installed.
                           [01]: x64 Family 6 Model 79 Stepping 1 GenuineIntel ~2100 Mhz
BIOS Version:              Phoenix Technologies LTD 6.00, 12/12/2018
Windows Directory:         C:\Windows
System Directory:          C:\Windows\system32
Boot Device:               \Device\HarddiskVolume1
System Locale:             el;Greek
Input Locale:              en-us;English (United States)
Time Zone:                 (UTC+02:00) Athens, Bucharest, Istanbul
Total Physical Memory:     1.023 MB
Available Physical Memory: 743 MB
Virtual Memory: Max Size:  2.047 MB
Virtual Memory: Available: 1.471 MB
Virtual Memory: In Use:    576 MB
Page File Location(s):     C:\pagefile.sys
Domain:                    HTB
Logon Server:              N/A
Hotfix(s):                 N/A
Network Card(s):           1 NIC(s) Installed.
                           [01]: Intel(R) PRO/1000 MT Network Connection
                                 Connection Name: Local Area Connection
                                 DHCP Enabled:    No
                                 IP address(es)
                                 [01]: 10.10.10.5


```

una vez hecho esto nesecitaremos usar unas herramientas que nos ahorraran mucho tiempo y nos faciliran la vida, para encontrar vulnerabilidades en el kernel de windows. 

- Windows Exploit Suggester
- Sherlock

#### Windows Exploit Suggester

Es una herramienta que compara con uno base de datos e identifica la vulnerabilidades de Kernel de windows por falta de parches de seguridad.

Primero descargaremos de su repositorio en github

```bash

git clone https://github.com/AonCyberLabs/Windows-Exploit-Suggester

```

entramos a la carpeta Windows-Exploit-Suggester y generamos la base de datos de la herramienta con 

```bash
python windows-exploit-suggester.py --update
```

<p align="center">
<img src="/assets/images/Escalamiento-de-Privilegios-Windows-01/2020-11-19 12-49-04.png">
</p>

en nuestra shell volvemos a ejecutar el commando systeminfo y seleccionamos y copiamos todo el output para luego guardarlo en un archivo llamado systeminfo.txt

```bash
c:\windows\system32\inetsrv>systeminfo
```

<p align="center">
<img src="/assets/images/Escalamiento-de-Privilegios-Windows-01/2020-11-19 13-39-53.png">
</p>

<p align="center">
<img src="/assets/images/Escalamiento-de-Privilegios-Windows-01/2020-11-19 13-43-42.png">
</p>

ahora tenemos todo listo para hacer funcionar nuestra herramienta, ejecutamos el siguiente comando 

```bash
python windows-exploit-suggester.py --systeminfo systeminfo.txt --database 2020-11-19-mssb.xls
```
<p align="center">
<img src="/assets/images/Escalamiento-de-Privilegios-Windows-01/2020-11-19-13-43-42.png">
</p>

como podemos ver tenemos 