---
layout: single
title: Writeup HTB - Maquina Active
comments: true
excerpt: "La maquina Active es una maquina windows - Easy, nos encontramos con una maquina active directory donde enumeramos archivos compartidos en SMB, dentro de dichos archivos encontramos Groups.xml donde explotamos una vulnerabilidad antigua en windows para crackear un password, haciendo esto tenemos credenciales de un usuario del dominio y abusamos de la vulnerabilidad Kerberoasting para solicitar un TGS, obteniendo un hash para luego crackearlo con hashcat  y poder ejecutar comandos con la psexec.py con las credenciales del usuario Administrator."
date: 2022-01-22
classes: wide
header:
  teaser: /assets/images/2022-01-22-writeup-maquina-htb-active/Untitled.png
  teaser_home_page: true
categories:
  - HackTheBox
tags:
  - OSCP  
  - Hacking
  - Active Directory
---


# HTB - Active
<p align="center">
<img src="/assets/images/2022-01-22-writeup-maquina-htb-active/Untitled.png">
</p>

## Resumen

<div style="text-align: justify">
La maquina Active es una maquina windows - Easy, nos encontramos con una maquina active directory donde enumeramos archivos compartidos en SMB, dentro de dichos archivos encontramos Groups.xml donde explotamos una vulnerabilidad antigua en windows para crackear un password, haciendo esto tenemos credenciales de un usuario del dominio y abusamos de la vulnerabilidad Kerberoasting para solicitar un TGS, obteniendo un hash para luego crackearlo con hashcat  y poder ejecutar comandos con psexec.py con las credenciales del usuario Administrator.
</div>

## Scan nmap

![Untitled](/assets/images/2022-01-22-writeup-maquina-htb-active/Untitled%201.png)

haciendo un escaneo de los puertos con Nmap, logramos ver puertos interesantes que nos dan una idea de la maquina por ejemplo:

```bash
Port 88/tcp    Microsoft Windows Kerberos - Usa kerberos
Port 145/tcp, 445/tcp - usa Protocolo SMB
Port 389/tcp, 3268/tcp - usa Active Directory LDAP
Port 135/tcp, 593/tpc, 4915x/tcp - Microsoft Windows RCP
Port 464/tcp - Este puerto se usa para cambiar/establecer contraseñas contra Active Directory 
```

todo parece que esta maquina se relacion a un Active Directory, pero comenzamos hacer nuestro reconocimiento 

## Zone Transfer

ya que tenemos el port 53, hicimos una enumeracion Zone Transfer pero no dio resultado de eso.

![Untitled](/assets/images/2022-01-22-writeup-maquina-htb-active/Untitled%202.png)

![Untitled](/assets/images/2022-01-22-writeup-maquina-htb-active/Untitled%203.png)

## Enumeracion SMB

enumere samba para ver si podiamos acceder a un recurso compartido, y vemos que podemos acceder a la carpeta Replication

![Untitled](/assets/images/2022-01-22-writeup-maquina-htb-active/Untitled%204.png)

revisamos que contiene dicha carpeta y bueno encontramos otra carpeta llamada active.htb

![Untitled](/assets/images/2022-01-22-writeup-maquina-htb-active/Untitled%205.png)

entonces si tenemos una carpeta compartida en samba con mucha informacion y para no estar perdiendo tiempo lo mejor seria montar dicha carpeta Replication o listar todos los recursos de forma recursiva. opte por la ultima opcion

![Untitled](/assets/images/2022-01-22-writeup-maquina-htb-active/Untitled%206.png)

me mostro mucha informacion pero el groups.xml, es un archivo que me llamo la atencion, si buscamos en internet vemos que podemos explotar una vulnerabilidad muy conocida en windows para poder obtener credenciales 

![Untitled](/assets/images/2022-01-22-writeup-maquina-htb-active/Untitled%207.png)

como podemos ver tenemos el archivo groups.xml que contiene un usuario del dominio y un password cifrado, sin embargo buscando en internet vemos podemos crackear este password usando gpp-decrypt

[Credential Dumping: Group Policy Preferences (GPP) - Hacking Articles](https://www.hackingarticles.in/credential-dumping-group-policy-preferences-gpp/)

![Untitled](/assets/images/2022-01-22-writeup-maquina-htb-active/Untitled%208.png)

usamos gpp-decrypt para crackear el password

![Untitled](/assets/images/2022-01-22-writeup-maquina-htb-active/Untitled%209.png)

y dando como resultado estas credenciales encontradas

```bash
active.htb\SVC_TGS:GPPstillStandingStrong2k18
```

verificamos con smbmap a que recursos podemos acceder con estas credenciales

![Untitled](/assets/images/2022-01-22-writeup-maquina-htb-active/Untitled%2010.png)

me parecio interesante que tengamos acceso a la carpeta Users, asi que me conecte a dicha carpeta por smbclient

![Untitled](/assets/images/2022-01-22-writeup-maquina-htb-active/Untitled%2011.png)

sin embargo intente conectarme por [psexec.py](http://psexec.py) pero sin exito.

## Kerberoasting

<div style="text-align: justify">
Kerberoasting abusa de las características del protocolo Kerberos para  recolectar hashes de contraseña para cuentas de usuario de Active Directory con valores servicePrincipalName (SPN) (es decir, cuentas de servicio). Un usuario puede solicitar un ticket del servicio de otorgamiento de boletos (TGS) para cualquier SPN, y partes del TGS se pueden cifrar con RC4 utilizando el hash de contraseña de la cuenta de servicio asignada al SPN solicitado como clave.

Un adversario que pueda extraer los boletos TGS de la memoria, o capturarlos rastreando el tráfico de la red, puede extraer el hash de la contraseña de la cuenta de servicio e intentar un ataque de fuerza bruta fuera de línea para obtener la contraseña de texto sin formato.

Por lo tanto teniendo credenciales de un usuario del dominio haremos uso de la herramienta GetUsersSPNs.py y para solicitar un TGS de un servicio del dominio
</div>

![Untitled](/assets/images/2022-01-22-writeup-maquina-htb-active/Untitled%2012.png)

tenemos un hash del usuario administrator asi que usaremos nth para saber que tipo de hash es para poder crackear despues con hashcat

![Untitled](/assets/images/2022-01-22-writeup-maquina-htb-active/Untitled%2013.png)

utilizamos hashcat para crackear dicho hash

```bash
hashcat -a 0 -m 13100 hash.txt /usr/share/wordlists/rockyou.txt
```

![Untitled](/assets/images/2022-01-22-writeup-maquina-htb-active/Untitled%2014.png)

verificamos si podemos acceder con estas credenciales y ejecutar comandos

![Untitled](/assets/images/2022-01-22-writeup-maquina-htb-active/Untitled%2015.png)

entonces usamos [psexec.py](http://psexec.py) para conectarnos y ejecutar comandos

![Untitled](/assets/images/2022-01-22-writeup-maquina-htb-active/Untitled%2016.png)