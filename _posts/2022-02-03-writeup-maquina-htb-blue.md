---
layout: single
title: Writeup HTB - Maquina Blue
comments: true
excerpt: "La maquina Blue es una masquina windows - Easy, encontramos una maquina con una vulnerabilidad muy conocida el popular ms17-010, para explotar dicha vulnerabilidad haremos uso de un exploit del repositorio AutoBlue, ejecutando dicho exploit podemos ejecutar comandos en el servidor como nt authority system."
date: 2022-02-03
classes: wide
header:
  teaser: /assets/images/2022-02-03-writeup-maquina-htb-blue/Untitled.png
  teaser_home_page: true
categories:
  - HackTheBox
tags:
  - OSCP  
  - Hacking
  - Windows
  - Easy
---

# Blue

<p align="center">
<img src="/assets/images/2022-02-03-writeup-maquina-htb-blue/Untitled.png">
</p>

## Resumen

<div style="text-align: justify">
La maquina Blue es una masquina windows - Easy, encontramos una maquina con una vulnerabilidad muy conocida el popular ms17-010, para explotar dicha vulnerabilidad haremos uso de un exploit del repositorio AutoBlue, ejecutando dicho exploit podemos ejecutar comandos en el servidor como nt authority system.
</div>

## Scan Nmap

Hacemos un escaneo simple a nuestra maquina

![Untitled](/assets/images/2022-02-03-writeup-maquina-htb-blue/Untitled%201.png)

podemos ver que es un **Windows 7 Professional 7601 Service Pack 1 microsoft-ds**  y entonces tambien notamos que tenemos el puerto 445. Partiendo de esto lo primero que podriamos probar son los scripts de nmap para ver si esta maquina tiene una vulnerabilidad conocida. Asi pues vemos que nmap nos arroja que existe un vulnerabilidad con CVE-2017-0143, que es el popular ms17-010

![Untitled](/assets/images/2022-02-03-writeup-maquina-htb-blue/Untitled%202.png)

para explotar dicha vulnerabilidad, buscamos un exploit del siguiente repositorio

[GitHub - 3ndG4me/AutoBlue-MS17-010: This is just an semi-automated fully working, no-bs, non-metasploit version of the public exploit code for MS17-010](https://github.com/3ndG4me/AutoBlue-MS17-010)

descargamos el repositorio e instalamos todo lo nesecario para hacerlo funcionar de la siguiente manera

```bash
Blue # ❯ git clone https://github.com/3ndG4me/AutoBlue-MS17-010.git
Blue # ❯ cd AutoBlue-MS17-010
AutoBlue-MS17-010 # ❯ pip install -r requirements.txt
```

![Untitled](/assets/images/2022-02-03-writeup-maquina-htb-blue/Untitled%203.png)

podemos usar el checker para ver si la maquina victima se encuentra parchado o no dicha vulnerabilidad

```bash
AutoBlue-MS17-010 # ❯ python eternal_checker.py 10.129.161.33
```

![Untitled](/assets/images/2022-02-03-writeup-maquina-htb-blue/Untitled%204.png)

el siguiente paso se generar unas shellcode de la siguiente manera

![Untitled](/assets/images/2022-02-03-writeup-maquina-htb-blue/Untitled%205.png)

al generar ingresamos nuestra direccion IP y los puertos que elegiremos para se conecten a una reverse shell

![Untitled](/assets/images/2022-02-03-writeup-maquina-htb-blue/Untitled%206.png)

a veces la herramienta no genera el sc_all.bin, asi que toca probar con sc_x86.bin y sc_x64.bin, asi de esta manera obtenemos una reverse shell con permisos de nt authority\system

```bash
Blue # ❯ python3 eternalblue_exploit7.py 10.129.161.39 shellcode/sc_x64.bin
```

![Untitled](/assets/images/2022-02-03-writeup-maquina-htb-blue/Untitled%207.png)

gracias por tomarte el tiempo de leer este writeup, nos vemos AbelJM.