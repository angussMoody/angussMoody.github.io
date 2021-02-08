---
layout: single
title: Writeup HTB - Maquina Doctor
comments: true
excerpt: "Hola a todos, no se en que momento se retiro esta maquina pero esta estuvo muy interesante, asi comencemos"
date: 2020-02-06
classes: wide
published: true
header:
  teaser: /assets/images/writeup-maquina-htb-doctor/2021-02-06_20-22.png
  teaser_home_page: true
categories:
  - HackTheBox
tags:
  - OSCP
  - HackTheBox
  - Hacking
---

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-06_20-22.png">
</p>

Hola a todos, no se en que momento se retiro esta maquina pero esta estuvo muy interesante, asi que me gustaria contarles como la resolvi. 

Asi que comencemos primero haciendo un escaneo para ver a que nos enfrentamos

```bash
# Nmap 7.80 scan initiated Wed Jan 13 19:17:14 2021 as: nmap -sC -sV -p22,80,8089 -vvv -Pn -oN Targeted 10.10.10.209
Nmap scan report for 10.10.10.209
Host is up, received user-set (0.32s latency).
Scanned at 2021-01-13 19:17:14 -05 for 55s

PORT     STATE SERVICE  REASON         VERSION
22/tcp   open  ssh      syn-ack ttl 63 OpenSSH 8.2p1 Ubuntu 4ubuntu0.1 (Ubuntu Linux; protocol 2.0)
80/tcp   open  http     syn-ack ttl 63 Apache httpd 2.4.41 ((Ubuntu))
| http-methods: 
|_  Supported Methods: OPTIONS HEAD GET POST
|_http-server-header: Apache/2.4.41 (Ubuntu)
|_http-title: Doctor
8089/tcp open  ssl/http syn-ack ttl 63 Splunkd httpd
| http-methods: 
|_  Supported Methods: GET HEAD OPTIONS
| http-robots.txt: 1 disallowed entry 
|_/
|_http-server-header: Splunkd
|_http-title: splunkd
| ssl-cert: Subject: commonName=SplunkServerDefaultCert/organizationName=SplunkUser
| Issuer: commonName=SplunkCommonCA/organizationName=Splunk/stateOrProvinceName=CA/countryName=US/localityName=San Francisco/emailAddress=support@splunk.com
| Public Key type: rsa
| Public Key bits: 2048
| Signature Algorithm: sha256WithRSAEncryption
| Not valid before: 2020-09-06T15:57:27
| Not valid after:  2023-09-06T15:57:27
| MD5:   db23 4e5c 546d 8895 0f5f 8f42 5e90 6787
| SHA-1: 7ec9 1bb7 343f f7f6 bdd7 d015 d720 6f6f 19e2 098b
| -----BEGIN CERTIFICATE-----
| MIIDMjCCAhoCCQC3IKogA4zEAzANBgkqhkiG9w0BAQsFADB/MQswCQYDVQQGEwJV
| UzELMAkGA1UECAwCQ0ExFjAUBgNVBAcMDVNhbiBGcmFuY2lzY28xDzANBgNVBAoM
| BlNwbHVuazEXMBUGA1UEAwwOU3BsdW5rQ29tbW9uQ0ExITAfBgkqhkiG9w0BCQEW
| EnN1cHBvcnRAc3BsdW5rLmNvbTAeFw0yMDA5MDYxNTU3MjdaFw0yMzA5MDYxNTU3
| MjdaMDcxIDAeBgNVBAMMF1NwbHVua1NlcnZlckRlZmF1bHRDZXJ0MRMwEQYDVQQK
| DApTcGx1bmtVc2VyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0JgJ
| NKrC4SrGzEhhyluUIcBW+eD6y+4paEikip5bzO7Xz8+tVJmFBcDfZdkL3TIZFTCF
| 95BMqL4If1SNZlFQxpMZB/9PzCMm0HmhEK/FlHfdrLwaeK71SWeO/MMNtsAheIPA
| pNByri9icp2S9u7wg89g9uHK4ION8uTJMxbmtCRT4jgRcenOZYghvsTEMLPhwlb2
| M/59WRopfyakIEl/w/zF1jCfnrT6XfZtTos6ueet6lhjd8g5WW9ZJIfmjYDaqHPg
| Tg3yLCRjYhLk+2vLyrO23l5kk8H+H4JgIOCqhAw38hC0r+KETsuWCGIxl4rBBDQw
| E5TvP75NsGW2O3JNDQIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQBJjjx+KHFwYJei
| lMJlmXBOEs7V1KiAjCenWd0Bz49Bkbik/5Rcia9k44zhANE7pJWNN6gpGJBn7b7D
| rliSOwvVoBICHtWFuQls8bRbMn5Kfdd9G7tGEkKGdvn3jOFkQFSQQQ56Uzh7Lezj
| hjtQ1p1Sg2Vq3lJm70ziOlRa0i/Lk7Ydc3xJ478cjB9nlb15jXmSdZcrCqgsAjBz
| IIDPzC+f7hJYlnFau2OA5uWPX/HIR7JfQsKXWCM6Tx0b9tZKgNNOr+DwyML4CH6o
| qrryh7elUJojAaZ0wYNd5koGZzEH4ymAQoshgFyEgetm1BbzMbA3PfZkX1VR6AV+
| guO5oa9R
|_-----END CERTIFICATE-----
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Read data files from: /usr/bin/../share/nmap
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Wed Jan 13 19:18:09 2021 -- 1 IP address (1 host up) scanned in 55.27 seconds
```

<br>
al ver la salida de nmap, me parecio interesante el puerto 8089 pero no encontre nada. Todo nos sugiere que la pega puede ser por la web que esta corriendo por el puerto 80


<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-06_22-51.png">
</p>

corri con dirsearch para hacer un escaneo para descubrir algunos directorios, pero sin exito 

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-06_23-00.png">
</p>

revisando la web me parecio algo interesante al ir a la seccion Contacts, habia un correo con un dominio que me llamo la atencion 

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-06_23-03.png">
</p>

entonces quise probar y agregue el dominio doctors.htb en /etc/hosts

```bash
10.10.10.209 doctor.htb doctors.htb
```
lo que nos dio una web donde se encuentra un login,lo que nos lleva de nuevo a enumerar todo en las funciones de la aplicacion, codigo fuente,etc. 

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-06_23-07.png">
</p>

entonces crearemos un usuario en la seccion Register

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-06_23-08.png">
</p>

lo que nos crea un usuario con un tiempo limite de 20 minutos

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-06_23-10.png">
</p>

al revisar el codigo fuente vemos un comentario donde dice que archive esta en prueba beta 

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-06_23-12.png">
</p>

asi que crearemos un nuevo mensaje de prueba

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-06_23-13.png">
</p>

una vez creado el nuevo mensaje vamos a doctors.htb/archive pero nos sale todo en blanco pero si revisamos el codigo fuente 

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-06_23-14_1.png">
</p>

podemos ver se ve reflejado el titulo del mensaje,lo que se ocurre entonces atacar por una injeccion, probe con una ataque inyeccion SQL, XSS, pero sin exito.

Entonces aqui viene lo divertido haremos una nuevo mensaje probando una injeccion SSTI - server-side template injection

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-06_23-16.png">
</p>

al irme de nuevo a la pagina doctors.htb/archive, vemos esto

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-06_23-17.png">
</p>

maravilloso! podemos ver que se produjo la ejecucion de codigo al injectar en el titulo del mensaje nuestra expresion matematica, dandonos como resultado 49 en la web Archive. Entonces lo que nesecimos es obtener una reverse shell pero para ello nesecitamos identificar el motor de plantillas, para ello usaremos el grafico de portswigger que nos ayudara para lograr nuestro cometido

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-06_23-20.png">
</p>

asi que realizaremos la siguiente expresion en el titulo del mensaje

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-06_23-34.png">
</p>

ahora revisamos la web archive para ver el resultado

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-06_23-34_1.png">
</p>

como podemos ver el resultado es 7777777, lo que nos dice segun el grafico anterior es que la tecnologia de nuestra plantilla es jinja2, si el resultado hubiera sido 49 hubiera sido Twig. Por lo tanto usemos nuestro payload para este motor de plantilla que nos otorgue una reverse shell, yo la encontre en el siguiente enlace 

```bash
https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Server%20Side%20Template%20Injection/README.md
```
asi que agregamos un nuevo mensaje y en el titulo ingresemos nuestro payload para obtener nuestra reverse shell 

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-06_23-34_2.png">
</p>

dejamos en escucha un puerto con netcat en mi caso fue el puerto 443 y revisamos la web Archive y pudimos conectarnos sin problemas

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-06_23-49-1.png">
</p>

enumerando la maquina nos damos cuenta que tenemos el usuario Shaun y el comando groups revela que el usuario actual es miembro del grupo adm. Investigando en internet no dice que este grupo se usa para tareas de monitoreo del sistema y proporciona acceso de lectura a los archivos de registro ubicados en /var/log. Dichos archivos registro son ideales para buscar algun password de un usuario

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-06_23-52.png">
</p>

como vemos hacemos la busqueda de un password con grep en la ruta /var/log/apache2 al archivo backup, lo que nos da un password que podemos usarlo para loguearnos en este caso con el usuario Shaun

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-07_00-15.png">
</p>

ahora estamos listo para obtener nuestra flag de user

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-07_00-18.png">
</p>

## Escalamiento de Privilegios

comenzamos hacer la enumeracion para escalar privilegios, yo me ayude de la herramienta de linpeas. Me parecio interesante que el proceso splunkd este corriendo como root

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-08_08-44.png">
</p>

yo use este exploit que encontre en este repositorio

```bash
https://github.com/cnotin/SplunkWhisperer2
```

entonces ejecutamos el exploit para que se conecte al puerto 4444, que ya deje en escucha previamente

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-08_09-06.png">
</p>

como ver nos conectamos sin problemas y logramos ser root!! 

<p align="center">
<img src="/assets/images/writeup-maquina-htb-doctor/2021-02-08_09-07.png">
</p>

solo nos faltaria buscar la flag de root en /root/root.txt y logramos vencer la maquina, que por cierto estuvo muy divertida jeje.

Si tienes una recomendacion o duda con este writeup, no dudes en escribirme a mi correo abel@gmail.com. nos vemos cuidense :)