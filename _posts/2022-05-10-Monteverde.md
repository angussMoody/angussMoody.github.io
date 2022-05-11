---
layout: single
title: Máquina Monteverde Hack the Box
comments: true
excerpt: "Máquina Monteverde Hack the Box"
date: 2022-05-09
classes: wide
header:
  teaser: /assets/images/2022-05-10-Monteverde/logo.png
  teaser_home_page: true
categories:
  - HacktheBox
tags:
  - Hackthebox
  - Windows
  - Hacking
  - Easy
---


# **Usuario:**

Realizamos un escaneo, para saber que puertos y que servicio están corriendo en esta máquina y nos encontramos con servicios interesantes como Kerberos, ldap, msrcp y además vemos que esta máquina está bajo AD, como hemos realizado en [máquinas anteriores](https://angussmoody.github.io/) [](https://angussmoody.github.io/index.html#portfolio)podemos realizar una búsqueda de usuarios de varías maneras, podríamos hacer uso de sparta o enum4linux que nos traen mucha información, pero hoy vamos a utilizar una herramienta un poco más específica para el caso.

![1.JPG](/assets/images/2022-05-10-Monteverde/1.jpg)

Vamos a hacer uso de la Herramienta rpcclient y corremos el comando con la opción -U “” porque no tenemos ningun usuario hasta este momento y -N para la opción de No-pass, de esta manera ingresamos, utilizamos enumdomusers, para enumerar los usuarios y nos encontramos con 10 usuarios, así que vamos a ver la información de cada uno de ellos con queryuser, encontramos que en el tiempo de inicio se sesión hay 3 usuarios con fechas muy recientes mhope, SABatchjobs y ADD_987d7f2f57d2 y ya con esta información vamos a ver que podemos encontrar por medio de smbclient.

![2.JPG](/assets/images/2022-05-10-Monteverde/2.jpg)

Probando los 3 usuarios que vimos anteriormente, vemos que con SABatchjobs y de password el mismo nombre de usuario tenemos conexión a algunos directorios

![3.JPG](/assets/images/2022-05-10-Monteverde/3.jpg)

Vamos a enumerar y nos encontramos que dentro de users$ se encuentran 4 directorios de usuario.

![4.JPG](/assets/images/2022-05-10-Monteverde/4.jpg)

Dentro del directorio mhope nos encontramos con un archivo llamado Azure.xml, así que con get nos descargamos este archivo, para revisar de que trata.

![5.JPG](/assets/images/2022-05-10-Monteverde/5.jpg)

Leyendo el archivo nos encontramos con un password, vamos a probar una conexión con [evil-winrm](https://github.com/Hackplayers/evil-winrm) como hemos realizado en [máquinas anteriores](https://angussmoody.github.io/index.html#portfolio)

![6.JPG](/assets/images/2022-05-10-Monteverde/6.jpg)

![7.JPG](/assets/images/2022-05-10-Monteverde/7.jpg)

**y así obtenemos nuestra primera flag .**

# **Escalada de Privilegios:**

Enumerando la máquina nos damos cuenta que está corriendo Azure, así que tratamos de encontrar una vulnerabilidad conocida para realizar el escalamiento de privilegios

![8.JPG](/assets/images/2022-05-10-Monteverde/8.jpg)

Revisando un poco en google, y después de varias pruebas, nos encontramos con un [script](https://github.com/Hackplayers/PsCabesha-tools/blob/master/Privesc/Azure-ADConnect.ps1) que nos da las credenciales de administrador que necesitamos para la escalación de privilegios. Modificamos un poco el script y lo subimos con la Shell que tenemos en este momento.

![9.JPG](/assets/images/2022-05-10-Monteverde/9.jpg)

Corremos nuestro script y obtenemos las credenciales de administrador.

![10.JPG](/assets/images/2022-05-10-Monteverde/10.jpg)

Ahora solo queda probar una conexión en [evil-winrm](https://github.com/Hackplayers/evil-winrm)

![11.JPG](/assets/images/2022-05-10-Monteverde/11.jpg)

**De esta manera encontramos la flag del Root.**