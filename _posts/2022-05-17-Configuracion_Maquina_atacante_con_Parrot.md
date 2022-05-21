---
layout: single
title: Configuración Maquina atacante con Parrot
comments: true
excerpt: "Configuración Maquina atacante con Parrot"
date: 2022-05-17
classes: wide
header:
  teaser: /assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/1.png
  teaser_home_page: true
categories:
  - Hacklab
tags:
  - Hacklab
  - Active Directory
  - Hacking
  - Kerberos
---

Para este laboratorio nos vamos a basar en una máquina [Parrot Security](https://www.parrotsec.org/download/), pero también podría ser una máquina Kali linux o una debian, la ventaja de estas dos primeras es que ya vienen con muchas herramientas listas para pruebas de penetración y ejercicio de Red Team, en este ejemplo vamos a ir a la página oficial de [Parrot](https://www.parrotsec.org/download/) y descargamos la versión Security

![1.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/1.png)

Una vez descargado se realiza la instalación, en este ejemplo vamos a hacerlo desde VMware Workstation, pero si  lo vas a realizar desde VirtualBox puede ver el paso a paso desde este [videos](https://www.youtube.com/watch?v=N3drrsjEvGg) 

Vamos a VMware y le damos en File y New Virtual Machine

![2.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/2.png)

Luego en Typical  y le damos en siguiente (Next)

![3.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/3.png)

Se cargando la ISO del sistema Operativo que descargamos previamente y le damos siguiente (Next)

![4.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/4.png)

Ahora le vamos a poner el nombre con el que queremos identificar nuestra máquina, ponemos la ruta donde la vamos a instalar y le damos a siguiente (Next)

![5.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/5.png)

Escogemos el tamaño que deseemos, por defecto nos dice que sean 20 GB, pero según el uso que le vayamos a dar y la capacidad de nuestra máquina principal, escogemos el espacio que deseemos y podemos escoger entre ponerlo como un disco dinámico o fijo, en este caso lo pongo como fijo, ya que de esta manera puede ser un poco más rápido, pero ambas funcionan bien 

![6.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/6.png)

Podemos ir a personalizar el hardware para poner las características que queremos para nuestra máquina

![7.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/7.png)

Para este ejemplo vamos a poner una memoria RAM de 6GB y 6 procesadores, aunque con 2 de RAM y 2 Procesadores, nos podría funcionar bien

![8.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/8.png)

Una vez tenemos todo configurado podemos darle en Finalizar (Finish) para que inicie el proceso de la instalación del sistema

![9.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/9.png)

Dependiendo de la versión del sistema el menú puede cambiar, en este caso vamos a darle a la primera opción para instalar nuestra máquina 

![10.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/10.png)

Este nos carga el sistema operativo, que es funcional, pero si lo utilizamos no nos guardará los cambios que realicemos en el, así que vamos a darle en la opción de Install Parrot

![11.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/11.png)

Lo primero que nos dice es solicitar un idioma, en este caso vamos a seleccionar el español de México y le damos en siguiente

![12.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/12.png)

Luego vamos a seleccionar la zona horaria, para este caso vamos a escoger la zona Bogotá que es nuestra zona horaria y le damos en siguiente 

![13.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/13.png)

Nos pide que seleccionemos la distribución del teclado, en este ejemplo vamos a escoger el español de latino américa y podemos hacer algunos ejemplos de nuestra distribución antes de darle en siguiente 

![14.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/14.png)

Nos pide el tipo de la instalación de disco, vamos a seleccionar Borrar disco para que nos tome todo el espacio y cree las particiones necesarias para el sistema 

![15.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/15.png)

luego vamos a poner los datos del usuario con el que vamos a trabajar en la máquina, la contraseña que queremos para este usuario y le damos en siguiente 

![16.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/16.png)

Para finalizar vamos a poner Instalar y luego nos saldrá una ventana emergente con la confirmación de la instalación 

![17.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/17.png)

ya con esto inicia nuestra instalación y debemos esperar a que llegue a 100% el proceso de instalación del sistema 

![18.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/18.png)

Una vez finalizado nos dice que el sistema ha sido instalado y que reiniciemos para iniciar con éste 

![19.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/19.png)

Le damos en terminé la instalación, ponemos nuestra contraseña y le damos enter

![20.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/20.png)

Y así ya tenemos nuestro sistema operativo instalado

![21.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/21.png)

iniciamos una terminal y ponemos el comando `sudo su`para pasarnos al usuario root, la primera vez nos dice que le asignemos una contraseña, ponemos la contraseña que queremos para nuestro usuario root y le damos enter 

![22.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/22.png)

ya que estemos como root vamos a usar el comando `apt update` para ver cuántos paquetes tenemos pendientes de actualizar en este caso nos dice que tenemos 14 

![23.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/23.png)

Ahora con el comando `parrot-upgrade` vamos a realizar la actualización de estos paquetes 

![24.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/24.png)

ya con nuestro sistema actualizado, vamos a iniciar la instalar las herramientas que necesitamos para nuestro laboratorio de ataques en Active Directory

## Instalación de Herramientas

La primera herramienta que nos vamos a instalar es el fping que nos sirve para hacer descubrimiento de host y lo hacemos con el comando `apt install fping -y`

```csharp
┌─[root@angussmoody]─[/opt/ldapdomaindump]
└──╼ #apt install fping -y
Leyendo lista de paquetes... Hecho
Creando árbol de dependencias... Hecho
Leyendo la información de estado... Hecho
Los paquetes indicados a continuación se instalaron de forma automática y ya no son necesarios.
  ibverbs-providers ldap-utils libapache2-mod-php libapache2-mod-php7.4 libcephfs2 libgfapi0 libgfrpc0 libgfxdr0 libglusterfs0 libibverbs1 librados2 librdmacm1 libucl1 php-common
  php7.4-cli php7.4-common php7.4-json php7.4-opcache php7.4-readline python3-pcapy python3-qrcode samba samba-vfs-modules tdb-tools upx-ucl
Utilice «sudo apt autoremove» para eliminarlos.
Se instalarán los siguientes paquetes NUEVOS:
  fping
0 actualizados, 1 nuevos se instalarán, 0 para eliminar y 4 no actualizados.
Se necesita descargar 39,7 kB de archivos.
Se utilizarán 90,1 kB de espacio de disco adicional después de esta operación.
Ign:1 https://deb.parrot.sh/parrot lts/main amd64 fping amd64 5.0-1
Des:1 https://mirror.uta.edu.ec/parrot lts/main amd64 fping amd64 5.0-1 [39,7 kB]
Descargados 39,7 kB en 3s (13,0 kB/s)               
Seleccionando el paquete fping previamente no seleccionado.
(Leyendo la base de datos ... 436333 ficheros o directorios instalados actualmente.)
Preparando para desempaquetar .../archives/fping_5.0-1_amd64.deb ...
Desempaquetando fping (5.0-1) ...
Configurando fping (5.0-1) ...
Procesando disparadores para man-db (2.10.1-1~bpo11+1) ...
Scanning application launchers
Removing duplicate launchers or broken launchers
Launchers are updated
```

Vamos a realizar la instalación de python3 ya que muchas herramientas de las que vamos a estar utilizando corren con este python de esta manera `apt install python3`

```csharp
┌─[✗]─[root@angussmoody]─[/home/angussmoody]
└──╼ #apt install python3
Leyendo lista de paquetes... Hecho
Creando árbol de dependencias... Hecho
Leyendo la información de estado... Hecho
python3 ya está en su versión más reciente (3.9.2-3).
fijado python3 como instalado manualmente.
Los paquetes indicados a continuación se instalaron de forma automática y ya no son necesarios.
  alsa-tools certgraph cython3 dh-elpa-helper famfamfam-flag-png faraday-angular-frontend faraday-client fonts-open-sans golang-1.15 golang-1.15-doc golang-1.15-go golang-1.15-src
  golang-1.16 golang-1.16-doc golang-1.16-go golang-1.16-src greenbone-security-assistant greenbone-security-assistant-common i2p i2p-router libbox2d2.3.0 libconst-fast-perl libct4
  libeclipse-jdt-core-java libel-api-java libgetopt-java libgvm20 libio-interactive-perl libio-prompt-tiny-perl libjbigi-jni libjetty9-java libjson-simple-java libjsp-api-java
  liblist-someutils-perl liblist-someutils-xs-perl liblttng-ust-ctl4 liblttng-ust0 libmicrohttpd12 libmotif-common libperlio-utf8-strict-perl libservice-wrapper-java
  libservice-wrapper-jni libservlet-api-java libservlet3.1-java libsort-versions-perl libtaglibs-standard-impl-java libtaglibs-standard-jstlel-java libtaglibs-standard-spec-java
  libtomcat9-java libwebsocket-api-java libxm4 libzxingcore1 lightdm-parrot linux-compiler-gcc-10-x86 linux-headers-5.10.0-6parrot1-amd64 linux-headers-5.10.0-6parrot1-common
  linux-headers-5.14.0-9parrot1-common linux-image-5.10.0-6parrot1-amd64 linux-kbuild-5.10 linux-kbuild-5.14 lshw-gtk parrot-tools-forensic parrot-tools-info parrot-tools-report pgcli
  python3-apispec python3-apispec-webframeworks python3-autobahn python3-bleach python3-bottle python3-cbor python3-deprecation python3-django python3-faraday-agent-parameters-types
  python3-faraday-plugins python3-feedparser python3-filedepot python3-filteralchemy python3-flask-classful python3-flask-kvsession python3-flask-limiter python3-flask-login
  python3-flask-mail python3-flask-principal python3-flask-security python3-flask-sqlalchemy python3-flaskext.wtf python3-html2text python3-humanize python3-hupper python3-limits
  python3-marshmallow python3-marshmallow-sqlalchemy python3-nplusone python3-pgspecial python3-plaster python3-plaster-pastedeploy python3-png python3-pyqrcode python3-pyramid
  python3-simplekv python3-snappy python3-speaklater python3-sqlalchemy-schemadisplay python3-sqlparse python3-syslog-rfc5424-formatter python3-translationstring python3-trie
  python3-txaio python3-u-msgpack python3-ubjson python3-unidecode python3-venusian python3-webargs python3-wsaccel python3-wtforms python3-zope.deprecation service-wrapper sqsh
  webext-https-everywhere webext-privacy-badger
Utilice «apt autoremove» para eliminarlos.
0 actualizados, 0 nuevos se instalarán, 0 para eliminar y 1 no actualizados.
```

También vamos a instalar pip3 que es un gestor de paquetes de python y que vamos a utilizar para nuestra herramienta `apt install python3-pip`

```csharp
┌─[root@angussmoody]─[/home/angussmoody]
└──╼ #apt install python3-pip
Leyendo lista de paquetes... Hecho
Creando árbol de dependencias... Hecho
Leyendo la información de estado... Hecho
python3-pip ya está en su versión más reciente (20.3.4-4+deb11u1).
fijado python3-pip como instalado manualmente.
0 actualizados, 0 nuevos se instalarán, 0 para eliminar y 4 no actualizados.
```

Vamos a instalar [crackmapexec](https://github.com/byt3bl33d3r/CrackMapExec/wiki/Installation)  aprovechado que ya tenemos pip3 instalado vamos a realizar la instalación con éste, `pip3 install crackmapexec` nos instalará las dependencias necesarias para correr nuestra herramienta

```csharp
┌─[root@angussmoody]─[/home/angussmoody]
└──╼ #pip3 install crackmapexec
ERROR: Introspect error on :1.1:/modules/kwalletd5: dbus.exceptions.DBusException: org.freedesktop.DBus.Error.NoReply: Message recipient disconnected from message bus without replying
WARNING: Keyring is skipped due to an exception: Failed to open keyring: org.freedesktop.DBus.Error.ServiceUnknown: The name :1.1 was not provided by any .service files.
Collecting crackmapexec
  Downloading crackmapexec-5.2.3-py3-none-any.whl (7.1 MB)
     |████████████████████████████████| 7.1 MB 97 kB/s 
Collecting pypsrp<0.6.0,>=0.5.0
  Downloading pypsrp-0.5.0-py2.py3-none-any.whl (86 kB)
     |████████████████████████████████| 86 kB 28 kB/s 
Collecting neo4j<5.0.0,>=4.1.1
  Downloading neo4j-4.4.3.tar.gz (90 kB)
     |████████████████████████████████| 90 kB 62 kB/s 
Requirement already satisfied: msgpack<2.0.0,>=1.0.0 in /usr/lib/python3/dist-packages (from crackmapexec) (1.0.0)
Requirement already satisfied: requests>=2.9.1 in /usr/lib/python3/dist-packages (from crackmapexec) (2.25.1)
Collecting pywerview<0.4.0,>=0.3.2
  Downloading pywerview-0.3.3-py3-none-any.whl (56 kB)
     |████████████████████████████████| 56 kB 113 kB/s 
Collecting aioconsole<0.4.0,>=0.3.1
  Downloading aioconsole-0.3.3.tar.gz (27 kB)
Collecting bs4<0.0.2,>=0.0.1
  Downloading bs4-0.0.1.tar.gz (1.1 kB)
Collecting requests-ntlm>=0.3.0
  Downloading requests_ntlm-1.1.0-py2.py3-none-any.whl (5.7 kB)
Requirement already satisfied: termcolor<2.0.0,>=1.1.0 in /usr/lib/python3/dist-packages (from crackmapexec) (1.1.0)
Collecting lsassy>=3.0.0
  Downloading lsassy-3.1.1-py3-none-any.whl (1.6 MB)
     |████████████████████████████████| 1.6 MB 73 kB/s 
Requirement already satisfied: paramiko<3.0.0,>=2.7.2 in /usr/lib/python3/dist-packages (from crackmapexec) (2.7.2)
Collecting pylnk3<0.4.0,>=0.3.0
  Downloading pylnk3-0.3.0-py3-none-any.whl (19 kB)
Requirement already satisfied: terminaltables<4.0.0,>=3.1.0 in /usr/lib/python3/dist-packages (from crackmapexec) (3.1.0)
Requirement already satisfied: xmltodict<0.13.0,>=0.12.0 in /usr/lib/python3/dist-packages (from crackmapexec) (0.12.0)
Collecting impacket<0.10.0,>=0.9.23
  Downloading impacket-0.9.24.tar.gz (7.1 MB)
     |████████████████████████████████| 7.1 MB 99 kB/s 
Requirement already satisfied: beautifulsoup4 in /usr/lib/python3/dist-packages (from bs4<0.0.2,>=0.0.1->crackmapexec) (4.9.3)
Requirement already satisfied: chardet in /usr/lib/python3/dist-packages (from impacket<0.10.0,>=0.9.23->crackmapexec) (4.0.0)
Requirement already satisfied: flask>=1.0 in /usr/lib/python3/dist-packages (from impacket<0.10.0,>=0.9.23->crackmapexec) (1.1.2)
Requirement already satisfied: future in /usr/lib/python3/dist-packages (from impacket<0.10.0,>=0.9.23->crackmapexec) (0.18.2)
Requirement already satisfied: ldap3!=2.5.0,!=2.5.2,!=2.6,>=2.5 in /usr/lib/python3/dist-packages (from impacket<0.10.0,>=0.9.23->crackmapexec) (2.8.1)
Requirement already satisfied: ldapdomaindump>=0.9.0 in /usr/lib/python3/dist-packages (from impacket<0.10.0,>=0.9.23->crackmapexec) (0.9.3)
Requirement already satisfied: pyOpenSSL>=0.16.2 in /usr/lib/python3/dist-packages (from impacket<0.10.0,>=0.9.23->crackmapexec) (20.0.1)
Requirement already satisfied: pyasn1>=0.2.3 in /usr/lib/python3/dist-packages (from impacket<0.10.0,>=0.9.23->crackmapexec) (0.4.8)
Requirement already satisfied: pycryptodomex in /usr/lib/python3/dist-packages (from impacket<0.10.0,>=0.9.23->crackmapexec) (3.9.7)
Requirement already satisfied: six in /usr/lib/python3/dist-packages (from impacket<0.10.0,>=0.9.23->crackmapexec) (1.16.0)
Collecting rich
  Downloading rich-12.4.0-py3-none-any.whl (231 kB)
     |████████████████████████████████| 231 kB 88 kB/s 
Requirement already satisfied: netaddr in /usr/lib/python3/dist-packages (from lsassy>=3.0.0->crackmapexec) (0.7.19)
Collecting pypykatz>=0.4.8
  Downloading pypykatz-0.5.7-py3-none-any.whl (382 kB)
     |████████████████████████████████| 382 kB 98 kB/s 
Requirement already satisfied: pytz in /usr/lib/python3/dist-packages (from neo4j<5.0.0,>=4.1.1->crackmapexec) (2021.1)
Collecting pyspnego
  Downloading pyspnego-0.5.2-py2.py3-none-any.whl (123 kB)
     |████████████████████████████████| 123 kB 34 kB/s 
Requirement already satisfied: cryptography in /usr/lib/python3/dist-packages (from pypsrp<0.6.0,>=0.5.0->crackmapexec) (3.3.2)
Collecting minidump>=0.0.21
  Downloading minidump-0.0.21-py3-none-any.whl (75 kB)
     |████████████████████████████████| 75 kB 113 kB/s 
Collecting winacl>=0.1.2
  Downloading winacl-0.1.3-py3-none-any.whl (48 kB)
     |████████████████████████████████| 48 kB 77 kB/s 
Collecting msldap>=0.3.38
  Downloading msldap-0.3.38-py3-none-any.whl (144 kB)
     |████████████████████████████████| 144 kB 48 kB/s 
Collecting aiosmb>=0.3.8
  Downloading aiosmb-0.3.8-py3-none-any.whl (747 kB)
     |████████████████████████████████| 747 kB 102 kB/s 
Collecting aiowinreg>=0.0.7
  Downloading aiowinreg-0.0.7-py3-none-any.whl (28 kB)
Collecting aesedb>=0.0.5
  Downloading aesedb-0.0.5-py3-none-any.whl (40 kB)
     |████████████████████████████████| 40 kB 134 kB/s 
Collecting unicrypto>=0.0.5
  Downloading unicrypto-0.0.5-py3-none-any.whl (92 kB)
     |████████████████████████████████| 92 kB 87 kB/s 
Collecting minikerberos>=0.2.20
  Downloading minikerberos-0.2.20-py3-none-any.whl (96 kB)
     |████████████████████████████████| 96 kB 68 kB/s 
Requirement already satisfied: tqdm in /usr/lib/python3/dist-packages (from aesedb>=0.0.5->pypykatz>=0.4.8->lsassy>=3.0.0->crackmapexec) (4.57.0)
Requirement already satisfied: colorama in /usr/lib/python3/dist-packages (from aesedb>=0.0.5->pypykatz>=0.4.8->lsassy>=3.0.0->crackmapexec) (0.4.4)
Requirement already satisfied: asn1crypto in /usr/lib/python3/dist-packages (from aiosmb>=0.3.8->pypykatz>=0.4.8->lsassy>=3.0.0->crackmapexec) (1.4.0)
Collecting winsspi>=0.0.9
  Downloading winsspi-0.0.10-py3-none-any.whl (22 kB)
Requirement already satisfied: wcwidth in /usr/lib/python3/dist-packages (from aiosmb>=0.3.8->pypykatz>=0.4.8->lsassy>=3.0.0->crackmapexec) (0.1.9)
Requirement already satisfied: prompt-toolkit>=3.0.2 in /usr/lib/python3/dist-packages (from aiosmb>=0.3.8->pypykatz>=0.4.8->lsassy>=3.0.0->crackmapexec) (3.0.14)
Collecting asysocks>=0.1.7
  Downloading asysocks-0.1.7-py3-none-any.whl (50 kB)
     |████████████████████████████████| 50 kB 87 kB/s 
Collecting oscrypto>=1.2.1
  Downloading oscrypto-1.3.0-py2.py3-none-any.whl (194 kB)
     |████████████████████████████████| 194 kB 86 kB/s 
Collecting asn1crypto
  Downloading asn1crypto-1.5.1-py2.py3-none-any.whl (105 kB)
     |████████████████████████████████| 105 kB 64 kB/s 
Requirement already satisfied: lxml in /usr/lib/python3/dist-packages (from pywerview<0.4.0,>=0.3.2->crackmapexec) (4.6.3)
Collecting ntlm-auth>=1.0.2
  Downloading ntlm_auth-1.5.0-py2.py3-none-any.whl (29 kB)
Requirement already satisfied: soupsieve>1.2 in /usr/lib/python3/dist-packages (from beautifulsoup4->bs4<0.0.2,>=0.0.1->crackmapexec) (2.2.1)
Requirement already satisfied: pygments<3.0.0,>=2.6.0 in /usr/lib/python3/dist-packages (from rich->lsassy>=3.0.0->crackmapexec) (2.7.1)
Collecting commonmark<0.10.0,>=0.9.0
  Downloading commonmark-0.9.1-py2.py3-none-any.whl (51 kB)
     |████████████████████████████████| 51 kB 84 kB/s 
Building wheels for collected packages: aioconsole, bs4, impacket, neo4j
  Building wheel for aioconsole (setup.py) ... done
  Created wheel for aioconsole: filename=aioconsole-0.3.3-py3-none-any.whl size=29001 sha256=8b192aa1b90c633c77984a156d565ce0782aa54b057b13790d1e73525fab8962
  Stored in directory: /root/.cache/pip/wheels/bc/c3/27/f4859de582512505510c319c37a51c01dfa95604e8dde28168
  Building wheel for bs4 (setup.py) ... done
  Created wheel for bs4: filename=bs4-0.0.1-py3-none-any.whl size=1272 sha256=844d10355c47f66d5e341630187d722dba612c94b59ebc0e63a7eb831687ea36
  Stored in directory: /root/.cache/pip/wheels/73/2b/cb/099980278a0c9a3e57ff1a89875ec07bfa0b6fcbebb9a8cad3
  Building wheel for impacket (setup.py) ... done
  Created wheel for impacket: filename=impacket-0.9.24-py3-none-any.whl size=1450131 sha256=5748993ef9f4601617901068835b7b4d025114f6864aaf129fbfb90826c17cbd
  Stored in directory: /root/.cache/pip/wheels/94/3d/3c/7263bdd823142aaf2166e10e144dbee1271ec35dbc93c01f95
  Building wheel for neo4j (setup.py) ... done
  Created wheel for neo4j: filename=neo4j-4.4.3-py3-none-any.whl size=116041 sha256=98f2bbe2c00d96332c0567ef79dff1b45319735d35991bbb97810f842039760f
  Stored in directory: /root/.cache/pip/wheels/a0/8c/08/e5396fee5c4d6c2e7901c049aad7aec428eafe2d752565019c
Successfully built aioconsole bs4 impacket neo4j
Installing collected packages: asn1crypto, unicrypto, oscrypto, asysocks, winacl, minikerberos, winsspi, aiowinreg, msldap, minidump, commonmark, aiosmb, aesedb, rich, pyspnego, pypykatz, ntlm-auth, impacket, bs4, requests-ntlm, pywerview, pypsrp, pylnk3, neo4j, lsassy, aioconsole, crackmapexec
  Attempting uninstall: asn1crypto
    Found existing installation: asn1crypto 1.4.0
    Not uninstalling asn1crypto at /usr/lib/python3/dist-packages, outside environment /usr
    Can't uninstall 'asn1crypto'. No files were found to uninstall.
  Attempting uninstall: impacket
    Found existing installation: impacket 0.9.22
    Not uninstalling impacket at /usr/lib/python3/dist-packages, outside environment /usr
    Can't uninstall 'impacket'. No files were found to uninstall.
Successfully installed aesedb-0.0.5 aioconsole-0.3.3 aiosmb-0.3.8 aiowinreg-0.0.7 asn1crypto-1.5.1 asysocks-0.1.7 bs4-0.0.1 commonmark-0.9.1 crackmapexec-5.2.3 impacket-0.9.24 lsassy-3.1.1 minidump-0.0.21 minikerberos-0.2.20 msldap-0.3.38 neo4j-4.4.3 ntlm-auth-1.5.0 oscrypto-1.3.0 pylnk3-0.3.0 pypsrp-0.5.0 pypykatz-0.5.7 pyspnego-0.5.2 pywerview-0.3.3 requests-ntlm-1.1.0 rich-12.4.0 unicrypto-0.0.5 winacl-0.1.3 winsspi-0.0.10
```

Una vez finalizada la instalación podemos correrla para comprobar que esta esté corriendo bien en nuestro sistema, la primera vez nos saldrá de esta mañera 

```csharp
┌─[root@angussmoody]─[/home/angussmoody]
└──╼ #crackmapexec 
[*] First time use detected
[*] Creating home directory structure
[*] Creating default workspace
[*] Initializing LDAP protocol database
[*] Initializing MSSQL protocol database
[*] Initializing SMB protocol database
[*] Initializing SSH protocol database
[*] Initializing WINRM protocol database
[*] Copying default configuration file
[*] Generating SSL certificate
usage: crackmapexec [-h] [-t THREADS] [--timeout TIMEOUT] [--jitter INTERVAL] [--darrell] [--verbose] {ldap,mssql,smb,ssh,winrm} ...

      ______ .______           ___        ______  __  ___ .___  ___.      ___      .______    _______ ___   ___  _______   ______
     /      ||   _  \         /   \      /      ||  |/  / |   \/   |     /   \     |   _  \  |   ____|\  \ /  / |   ____| /      |
    |  ,----'|  |_)  |       /  ^  \    |  ,----'|  '  /  |  \  /  |    /  ^  \    |  |_)  | |  |__    \  V  /  |  |__   |  ,----'
    |  |     |      /       /  /_\  \   |  |     |    <   |  |\/|  |   /  /_\  \   |   ___/  |   __|    >   <   |   __|  |  |
    |  `----.|  |\  \----. /  _____  \  |  `----.|  .  \  |  |  |  |  /  _____  \  |  |      |  |____  /  .  \  |  |____ |  `----.
     \______|| _| `._____|/__/     \__\  \______||__|\__\ |__|  |__| /__/     \__\ | _|      |_______|/__/ \__\ |_______| \______|

                                                A swiss army knife for pentesting networks
                                    Forged by @byt3bl33d3r and @mpgn_x64 using the powah of dank memes

                                           Exclusive release for Porchetta Industries users
                                                       https://porchetta.industries/

                                                   Version : 5.2.3
                                                   Codename: The Dark Knight

optional arguments:
  -h, --help            show this help message and exit
  -t THREADS            set how many concurrent threads to use (default: 100)
  --timeout TIMEOUT     max timeout in seconds of each thread (default: None)
  --jitter INTERVAL     sets a random delay between each connection (default: None)
  --darrell             give Darrell a hand
  --verbose             enable verbose output

protocols:
  available protocols

  {ldap,mssql,smb,ssh,winrm}
    ldap                own stuff using LDAP
    mssql               own stuff using MSSQL
    smb                 own stuff using SMB
    ssh                 own stuff using SSH
    winrm               own stuff using WINRM
```

La siguiente herramienta será [kerbrute](https://github.com/TarlogicSecurity/kerbrute)  esta herramienta nos ayuda a realizar ataques de fuerza bruta en el protocolo de kerberos, se puede instalar con pip3 o clonarnos su repositorio y ejecutarla desde ahí, para este ejemplo vamos a realizarlo desde pip3 `pip3 install kerbute`

```csharp
Installation
From pypi:

pip3 install kerbrute
From repo:

git clone https://github.com/TarlogicSecurity/kerbrute
cd kerbrute
pip install -r requirements.txt
```

```csharp
┌─[✗]─[root@angussmoody]─[/home/angussmoody]
└──╼ #pip3 install kerbrute
ERROR: Introspect error on :1.3:/modules/kwalletd5: dbus.exceptions.DBusException: org.freedesktop.DBus.Error.NoReply: Message recipient disconnected from message bus without replying
WARNING: Keyring is skipped due to an exception: Failed to open keyring: org.freedesktop.DBus.Error.ServiceUnknown: The name :1.3 was not provided by any .service files.
Collecting kerbrute
  Downloading kerbrute-0.0.2-py3-none-any.whl (17 kB)
Requirement already satisfied: impacket in /usr/local/lib/python3.9/dist-packages (from kerbrute) (0.9.24)
Requirement already satisfied: six in /usr/lib/python3/dist-packages (from impacket->kerbrute) (1.16.0)
Requirement already satisfied: ldap3!=2.5.0,!=2.5.2,!=2.6,>=2.5 in /usr/lib/python3/dist-packages (from impacket->kerbrute) (2.8.1)
Requirement already satisfied: chardet in /usr/lib/python3/dist-packages (from impacket->kerbrute) (4.0.0)
Requirement already satisfied: pyOpenSSL>=0.16.2 in /usr/lib/python3/dist-packages (from impacket->kerbrute) (20.0.1)
Requirement already satisfied: ldapdomaindump>=0.9.0 in /usr/lib/python3/dist-packages (from impacket->kerbrute) (0.9.3)
Requirement already satisfied: pycryptodomex in /usr/lib/python3/dist-packages (from impacket->kerbrute) (3.9.7)
Requirement already satisfied: future in /usr/lib/python3/dist-packages (from impacket->kerbrute) (0.18.2)
Requirement already satisfied: flask>=1.0 in /usr/lib/python3/dist-packages (from impacket->kerbrute) (1.1.2)
Requirement already satisfied: pyasn1>=0.2.3 in /usr/lib/python3/dist-packages (from impacket->kerbrute) (0.4.8)
Installing collected packages: kerbrute
Successfully installed kerbrute-0.0.2
```

Una vez instalada vamos a correrla para comprobar que corre bien en nuestro sistema y vemos que nos corre sin ningún problema

```csharp
┌─[root@angussmoody]─[/home/angussmoody]
└──╼ #kerbrute 
Impacket v0.9.24 - Copyright 2021 SecureAuth Corporation

usage: kerbrute [-h] [-debug] (-user USER | -users USERS) [-password PASSWORD | -passwords PASSWORDS] -domain DOMAIN [-dc-ip <ip_address>] [-threads THREADS] [-outputfile OUTPUTFILE]
                [-outputusers OUTPUTUSERS] [-no-save-ticket]

optional arguments:
  -h, --help            show this help message and exit
  -debug                Turn DEBUG output ON
  -user USER            User to perform bruteforcing
  -users USERS          File with user per line
  -password PASSWORD    Password to perform bruteforcing
  -passwords PASSWORDS  File with password per line
  -domain DOMAIN        Domain to perform bruteforcing
  -dc-ip <ip_address>   IP Address of the domain controller
  -threads THREADS      Number of threads to perform bruteforcing. Default = 1
  -outputfile OUTPUTFILE
                        File to save discovered user:password
  -outputusers OUTPUTUSERS
                        File to save discovered users
  -no-save-ticket       Do not save retrieved TGTs with correct credentials

Examples: 
	./kerbrute.py -users users_file.txt -passwords passwords_file.txt -domain contoso.com
```

Por lo general nuestro sistema operativo viene con la herramienta [grep](https://www.interserver.net/tips/kb/linux-grep-command-usage-examples/) instalada, pero si no es el caso, podemos instalar de esta manera: `apt install grep`

```csharp
┌─[✗]─[root@angussmoody]─[/home/angussmoody]
└──╼ #apt install grep
Leyendo lista de paquetes... Hecho
Creando árbol de dependencias... Hecho
Leyendo la información de estado... Hecho
grep ya está en su versión más reciente (3.6-1).
0 actualizados, 0 nuevos se instalarán, 0 para eliminar y 4 no actualizados.
```

También la herramienta [sed](https://www.gnu.org/software/sed/) viene instalada con nuestro sistema por defecto, que la utilizaremos para realizar un filtro en uno de nuestros archivos, pero si no es el caso podemos instalar de esta manera: `apt install sed`

```csharp
┌─[✗]─[root@angussmoody]─[/home/angussmoody]
└──╼ #apt install sed
Leyendo lista de paquetes... Hecho
Creando árbol de dependencias... Hecho
Leyendo la información de estado... Hecho
sed ya está en su versión más reciente (4.7-1).
0 actualizados, 0 nuevos se instalarán, 0 para eliminar y 4 no actualizados.
```

Continuando con nuestra instalación de herramientas, seguiremos con  [usersgenerator](https://github.com/abeljm/UsersGenerator), una herramienta que nos sirve para realizar un listado de posibles usuarios cuando le pasamos una lista de nombres y apellidos, podemos clonarnos el repositorio o instalarlo con pip3, `pip3 install usersgenerator`que para este laboratorio lo vamos a realizar de esta manera 

```csharp
┌─[root@angussmoody]─[/home/angussmoody]
└──╼ #pip3 install usersgenerator
ERROR: Introspect error on :1.5:/modules/kwalletd5: dbus.exceptions.DBusException: org.freedesktop.DBus.Error.NoReply: Message recipient disconnected from message bus without replying
WARNING: Keyring is skipped due to an exception: Failed to open keyring: org.freedesktop.DBus.Error.ServiceUnknown: The name :1.5 was not provided by any .service files.
Collecting usersgenerator
  Downloading usersgenerator-2.2.0.tar.gz (2.9 kB)
Requirement already satisfied: colorama in /usr/lib/python3/dist-packages (from usersgenerator) (0.4.4)
Building wheels for collected packages: usersgenerator
  Building wheel for usersgenerator (setup.py) ... done
  Created wheel for usersgenerator: filename=usersgenerator-2.2.0-py3-none-any.whl size=3337 sha256=ab25335b18ecf5ad00e4a4e4f8ca58dedc6acd3cca5191bfc0dd1d1a1aaff668
  Stored in directory: /root/.cache/pip/wheels/30/4a/51/dc3d04c357e7b8a513e25b16a57ebaae6eace066b2ec2fdbf6
Successfully built usersgenerator
Installing collected packages: usersgenerator
Successfully installed usersgenerator-2.2.0
```

Una vez instalada vamos a correr la herramienta para que comprobemos que nos está corriendo en nuestro sistema 

```csharp
┌─[root@angussmoody]─[/home/angussmoody]
└──╼ #usersgenerator 
usage: usersgenerator [-h] -u USERS -o OUTPUT
usersgenerator: error: the following arguments are required: -u/--users, -o/--output
┌─[✗]─[root@angussmoody]─[/home/angussmoody]
└──╼ #usersgenerator -h
usage: usersgenerator [-h] -u USERS -o OUTPUT

Ejemplo:

optional arguments:
  -h, --help            show this help message and exit
  -u USERS, --users USERS
                        lista de usuarios en archivo de texto, ejemplo: -u users.txt
  -o OUTPUT, --output OUTPUT
                        Guardar resultado en archivo de texto, poner nombre ejemplo: -o resultado.txt

python3 usersgenerator.py -u users.txt -o resultado.txt
```

Otra herramienta que vamos a estar utilizando mucho, para estos ataques en Active Directory es [impacket](https://github.com/SecureAuthCorp/impacket) en las ultimas distribuciones de parrot security ya vienen instaladas con el sistema, pero si no es el caso podemos instalarnos esta herramienta clonando su repositorio o instalarla con el comando `apt install python3-impacket`

```csharp
┌─[✗]─[root@angussmoody]─[/opt/impacket/examples]
└──╼ #apt install python3-impacket 
Leyendo lista de paquetes... Hecho
Creando árbol de dependencias... Hecho
Leyendo la información de estado... Hecho
Los paquetes indicados a continuación se instalaron de forma automática y ya no son necesarios.
  ibverbs-providers ldap-utils libapache2-mod-php libapache2-mod-php7.4 libcephfs2 libgfapi0 libgfrpc0 libgfxdr0 libglusterfs0 libibverbs1 librados2 librdmacm1 libucl1 php-common
  php7.4-cli php7.4-common php7.4-json php7.4-opcache php7.4-readline python3-pcapy python3-qrcode samba samba-vfs-modules tdb-tools upx-ucl
Utilice «sudo apt autoremove» para eliminarlos.
Se instalarán los siguientes paquetes NUEVOS:
  python3-impacket
0 actualizados, 1 nuevos se instalarán, 0 para eliminar y 4 no actualizados.
Se necesita descargar 861 kB de archivos.
Se utilizarán 6.384 kB de espacio de disco adicional después de esta operación.
Des:1 https://mirror.uta.edu.ec/parrot lts/main amd64 python3-impacket all 0.9.22-2 [861 kB]
Descargados 861 kB en 3s (322 kB/s)                 
Seleccionando el paquete python3-impacket previamente no seleccionado.
(Leyendo la base de datos ... 436124 ficheros o directorios instalados actualmente.)
Preparando para desempaquetar .../python3-impacket_0.9.22-2_all.deb ...
Desempaquetando python3-impacket (0.9.22-2) ...
Configurando python3-impacket (0.9.22-2) ...
Scanning application launchers
Removing duplicate launchers or broken launchers
Launchers are updated
```

Vamos a utilizar la herramienta [John the Ripper](https://es.wikipedia.org/wiki/John_the_Ripper) que nos sirve para crackear contraseñas, como algunas de las anteriores, esta herramienta viene instalada por defecto en nuestro sistema Parrot Security, pero si no es el caso podemos instalarla de esta manera: `apt install john -y`

```csharp
┌─[✗]─[root@angussmoody]─[/opt/impacket/examples]
└──╼ #apt install john -y
Leyendo lista de paquetes... Hecho
Creando árbol de dependencias... Hecho
Leyendo la información de estado... Hecho
john ya está en su versión más reciente (1.9.0-Jumbo-1-1parrot3).
fijado john como instalado manualmente.
Los paquetes indicados a continuación se instalaron de forma automática y ya no son necesarios.
  ibverbs-providers ldap-utils libapache2-mod-php libapache2-mod-php7.4 libcephfs2 libgfapi0 libgfrpc0 libgfxdr0 libglusterfs0 libibverbs1 librados2 librdmacm1 libucl1 php-common
  php7.4-cli php7.4-common php7.4-json php7.4-opcache php7.4-readline python3-pcapy python3-qrcode samba samba-vfs-modules tdb-tools upx-ucl
Utilice «sudo apt autoremove» para eliminarlos.
0 actualizados, 0 nuevos se instalarán, 0 para eliminar y 4 no actualizados.
```

Vamos a descargarnos el script de [LDAPDomainDump](https://github.com/dirkjanm/ldapdomaindump)  que nos permite realizar un volcado de información de Active Directory a través de LDAP, podemos instalar la herramienta o clonarnos su repositorio, para este ejemplo vamos a clonarlo, nos copiamos el repositorio  

![25.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/25.png)

Debemos tener instalada la herramienta git, esta viene instalada por defecto en nuestro sistema parrot security, pero si no es el caso podemos instalarla de la siguiente manera: `apt install git`

```csharp
┌─[✗]─[root@angussmoody]─[/home/angussmoody]
└──╼ #apt install git
Leyendo lista de paquetes... Hecho
Creando árbol de dependencias... Hecho
Leyendo la información de estado... Hecho
git ya está en su versión más reciente (1:2.30.2-1).
Los paquetes indicados a continuación se instalaron de forma automática y ya no son necesarios.
  alsa-tools certgraph cython3 dh-elpa-helper famfamfam-flag-png faraday-angular-frontend faraday-client fonts-open-sans golang-1.15 golang-1.15-doc golang-1.15-go golang-1.15-src
  golang-1.16 golang-1.16-doc golang-1.16-go golang-1.16-src greenbone-security-assistant greenbone-security-assistant-common i2p i2p-router libbox2d2.3.0 libconst-fast-perl libct4
  libeclipse-jdt-core-java libel-api-java libgetopt-java libgvm20 libio-interactive-perl libio-prompt-tiny-perl libjbigi-jni libjetty9-java libjson-simple-java libjsp-api-java
  liblist-someutils-perl liblist-someutils-xs-perl liblttng-ust-ctl4 liblttng-ust0 libmicrohttpd12 libmotif-common libperlio-utf8-strict-perl libservice-wrapper-java
  libservice-wrapper-jni libservlet-api-java libservlet3.1-java libsort-versions-perl libtaglibs-standard-impl-java libtaglibs-standard-jstlel-java libtaglibs-standard-spec-java
  libtomcat9-java libwebsocket-api-java libxm4 libzxingcore1 lightdm-parrot linux-compiler-gcc-10-x86 linux-headers-5.10.0-6parrot1-amd64 linux-headers-5.10.0-6parrot1-common
  linux-headers-5.14.0-9parrot1-common linux-image-5.10.0-6parrot1-amd64 linux-kbuild-5.10 linux-kbuild-5.14 lshw-gtk parrot-tools-forensic parrot-tools-info parrot-tools-report pgcli
  python3-apispec python3-apispec-webframeworks python3-autobahn python3-bleach python3-bottle python3-cbor python3-deprecation python3-django python3-faraday-agent-parameters-types
  python3-faraday-plugins python3-feedparser python3-filedepot python3-filteralchemy python3-flask-classful python3-flask-kvsession python3-flask-limiter python3-flask-login
  python3-flask-mail python3-flask-principal python3-flask-security python3-flask-sqlalchemy python3-flaskext.wtf python3-html2text python3-humanize python3-hupper python3-limits
  python3-marshmallow python3-marshmallow-sqlalchemy python3-nplusone python3-pgspecial python3-plaster python3-plaster-pastedeploy python3-png python3-pyqrcode python3-pyramid
  python3-simplekv python3-snappy python3-speaklater python3-sqlalchemy-schemadisplay python3-sqlparse python3-syslog-rfc5424-formatter python3-translationstring python3-trie
  python3-txaio python3-u-msgpack python3-ubjson python3-unidecode python3-venusian python3-webargs python3-wsaccel python3-wtforms python3-zope.deprecation service-wrapper sqsh
  webext-https-everywhere webext-privacy-badger
Utilice «apt autoremove» para eliminarlos.
0 actualizados, 0 nuevos se instalarán, 0 para eliminar y 15 no actualizados.
```

Una vez copiado, en nuestra máquina para este ejemplo vamos a irnos a /opt/ y ahí clonarnos éste repositorio con el comando git clone y el link del repositorio de esta manera `git clone http://github.com/dirkjanm/ldapdomaindump.git` una vez clonado entramos al directorio que este nos crea llamado ldapdomaindump, donde podemos ver el script ldapdomaindump.py y con python3 lo corremos para ver que nos responde correctamente 

`cd /opt/`

```csharp
┌─[✗]─[root@angussmoody]─[/opt/impacket/examples]
└──╼ #cd /opt/

```

`git clone http://github.com/dirkjanm/ldapdomaindump.git`

```csharp
┌─[root@angussmoody]─[/opt]
└──╼ #git clone https://github.com/dirkjanm/ldapdomaindump.git
Clonando en 'ldapdomaindump'...
remote: Enumerating objects: 259, done.
remote: Counting objects: 100% (62/62), done.
remote: Compressing objects: 100% (10/10), done.
remote: Total 259 (delta 51), reused 52 (delta 51), pack-reused 197
Recibiendo objetos: 100% (259/259), 117.12 KiB | 1.35 MiB/s, listo.
Resolviendo deltas: 100% (137/137), listo.
```

`cd ldapdomaindump`

```csharp
┌─[root@angussmoody]─[/opt]
└──╼ #cd ldapdomaindump/
```

`ls`

```csharp
┌─[root@angussmoody]─[/opt/ldapdomaindump]
└──╼ #ls
bin  ldapdomaindump  ldapdomaindump.py  LICENSE  MANIFEST.in  Readme.md  requirements.txt  setup.py
```

`python3 ldapdomaindump.py`

```csharp
┌─[root@angussmoody]─[/opt/ldapdomaindump]
└──╼ #python3 ldapdomaindump.py 
usage: ldapdomaindump.py [-h] [-u USERNAME] [-p PASSWORD] [-at {NTLM,SIMPLE}] [-o DIRECTORY] [--no-html] [--no-json] [--no-grep] [--grouped-json] [-d DELIMITER] [-r] [-n DNS_SERVER] [-m]
                         HOSTNAME
ldapdomaindump.py: error: the following arguments are required: HOSTNAME

```

`python3 ldapdomaindump.py -h` 

```csharp
┌─[✗]─[root@angussmoody]─[/opt/ldapdomaindump]
└──╼ #python3 ldapdomaindump.py -h
usage: ldapdomaindump.py [-h] [-u USERNAME] [-p PASSWORD] [-at {NTLM,SIMPLE}] [-o DIRECTORY] [--no-html] [--no-json] [--no-grep] [--grouped-json] [-d DELIMITER] [-r] [-n DNS_SERVER] [-m]
                         HOSTNAME

Domain information dumper via LDAP. Dumps users/computers/groups and OS/membership information to HTML/JSON/greppable output.

Required options:
  HOSTNAME              Hostname/ip or ldap://host:port connection string to connect to (use ldaps:// to use SSL)

Main options:
  -h, --help            show this help message and exit
  -u USERNAME, --user USERNAME
                        DOMAIN\username for authentication, leave empty for anonymous authentication
  -p PASSWORD, --password PASSWORD
                        Password or LM:NTLM hash, will prompt if not specified
  -at {NTLM,SIMPLE}, --authtype {NTLM,SIMPLE}
                        Authentication type (NTLM or SIMPLE, default: NTLM)

Output options:
  -o DIRECTORY, --outdir DIRECTORY
                        Directory in which the dump will be saved (default: current)
  --no-html             Disable HTML output
  --no-json             Disable JSON output
  --no-grep             Disable Greppable output
  --grouped-json        Also write json files for grouped files (default: disabled)
  -d DELIMITER, --delimiter DELIMITER
                        Field delimiter for greppable output (default: tab)

Misc options:
  -r, --resolve         Resolve computer hostnames (might take a while and cause high traffic on large networks)
  -n DNS_SERVER, --dns-server DNS_SERVER
                        Use custom DNS resolver instead of system DNS (try a domain controller IP)
  -m, --minimal         Only query minimal set of attributes to limit memmory usage
```

Un script que utilizaremos es el [Invoke-PowerShellTcp.ps1](https://github.com/samratashok/nishang/blob/master/Shells/Invoke-PowerShellTcp.ps1) de **[nishang](https://github.com/samratashok/nishang),** podemos clonarnos el repositorio 

![14.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/14%201.png)

O para esta laboratorio nos descargamos solo el script que necesitamos  [Invoke-PowerShellTcp.ps1](https://github.com/samratashok/nishang/blob/master/Shells/Invoke-PowerShellTcp.ps1) con la herramienta [wget](https://geekflare.com/es/wget-command-examples/) que nos permite traer el contenido de una web, en este caso el script de **[nishang](https://github.com/samratashok/nishang),** para tener una reverse shell , si no se tiene la herramienta se puede instalar de esta manera:

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Preparación/AD]
└──╼ #apt install wget
Leyendo lista de paquetes... Hecho
Creando árbol de dependencias... Hecho
Leyendo la información de estado... Hecho
wget ya está en su versión más reciente (1.21-1+deb11u1).
Los paquetes indicados a continuación se instalaron de forma automática y ya no son necesarios.
  certgraph coinor-libcbc3 coinor-libcgl1 coinor-libclp1 coinor-libcoinmp1v5 coinor-libcoinutils3v5 coinor-libosi1v5 cython3 famfamfam-flag-png faraday
  faraday-angular-frontend faraday-client fonts-opensymbol fonts-roboto-slab gir1.2-evince-3.0 gir1.2-gst-plugins-base-1.0 gir1.2-gstreamer-1.0
  gir1.2-javascriptcoregtk-4.0 gir1.2-soup-2.4 gjs gobject-introspection greenbone-security-assistant greenbone-security-assistant-common gstreamer1.0-gtk3 i2p
  i2p-router libabw-0.1-1 libboost-locale1.74.0 libbox2d2.3.0 libcdr-0.1-1 libclucene-contribs1v5 libclucene-core1v5 libct4 libe-book-0.1-1
  libeclipse-jdt-core-java libel-api-java libeot0 libepubgen-0.1-1 libetonyek-0.1-1 libevdocument3-4 libevview3-3 libexttextcat-2.0-0 libexttextcat-data
  libfreehand-0.1-1 libgetopt-java libgjs0g libgpgmepp6 libjbigi-jni libjetty9-java libjson-simple-java libjsp-api-java liblangtag-common liblangtag1
  liblttng-ust-ctl4 liblttng-ust0 libmicrohttpd12 libmotif-common libmozjs-78-0 libmspub-0.1-1 libmusicbrainz5-2 libmusicbrainz5cc2v5 libmwaw-0.3-3
  libmythes-1.2-0 libnumbertext-1.0-0 libnumbertext-data libodfgen-0.1-1 liborcus-0.16-0 liborcus-parser-0.16-0 libpagemaker-0.0-0 libqxp-0.0-0 libraptor2-0
  librasqal3 librdf0 libreoffice-common libreoffice-style-colibre librevenge-0.0-0 libservice-wrapper-java libservice-wrapper-jni libservlet-api-java
  libservlet3.1-java libstaroffice-0.0-0 libtaglibs-standard-impl-java libtaglibs-standard-jstlel-java libtaglibs-standard-spec-java libtomcat9-java libuno-cppu3
  libuno-cppuhelpergcc3-3 libuno-purpenvhelpergcc3-3 libuno-sal3 libuno-salhelpergcc3-3 libvisio-0.1-1 libwebsocket-api-java libwpd-0.10-10 libwpg-0.3-3
  libwps-0.4-4 libxm4 libxmlsec1-nss libzmf-0.0-0 libzxingcore1 lp-solve lshw-gtk parrot-tools-forensic parrot-tools-info parrot-tools-report pgcli pwgen
  python3-advancedhttpserver python3-aiofiles python3-alembic python3-apispec python3-apispec-webframeworks python3-autobahn python3-bleach python3-boltons
  python3-bottle python3-cairo-dev python3-cbor python3-deprecation python3-django python3-ecdsa python3-editor python3-email-validator
  python3-faraday-agent-parameters-types python3-faraday-plugins python3-fastapi python3-feedparser python3-filedepot python3-filteralchemy
  python3-flask-classful python3-flask-kvsession python3-flask-limiter python3-flask-login python3-flask-mail python3-flask-principal python3-flask-security
  python3-flask-sqlalchemy python3-flaskext.wtf python3-geojson python3-graphene python3-graphene-sqlalchemy python3-graphql-core python3-graphql-relay
  python3-html2text python3-humanize python3-hupper python3-icalendar python3-limits python3-marshmallow python3-marshmallow-sqlalchemy python3-nplusone
  python3-orjson python3-pgspecial python3-plaster python3-plaster-pastedeploy python3-png python3-promise python3-pyotp python3-pyqrcode python3-pyramid
  python3-requests-file python3-rule-engine python3-rx python3-simplekv python3-singledispatch python3-slowapi python3-smoke-zephyr python3-speaklater
  python3-sqlalchemy-schemadisplay python3-sqlparse python3-starlette python3-syslog-rfc5424-formatter python3-translationstring python3-trie python3-txaio
  python3-tzlocal python3-u-msgpack python3-ubjson python3-unidecode python3-uvicorn python3-venusian python3-webargs python3-wsaccel python3-wtforms
  python3-zope.deprecation service-wrapper sqsh uno-libs-private ure
Utilice «apt autoremove» para eliminarlos.
0 actualizados, 0 nuevos se instalarán, 0 para eliminar y 70 no actualizados.
```

Ahora para descargarnos el script lo único que necesitamos es ir a la ruta de este  [Invoke-PowerShellTcp.ps1](https://github.com/samratashok/nishang/blob/master/Shells/Invoke-PowerShellTcp.ps1)  y darle en raw 

![15.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/15%201.png)

Una vez ahí nos copiamos la dirección web y con wget más la dirección nos descargamos este script

```csharp
┌─[root@angussmoody]─[/mnt/angussMoody/Preparación/AD]
└──╼ #wget https://raw.githubusercontent.com/samratashok/nishang/master/Shells/Invoke-PowerShellTcp.ps1
--2022-05-16 22:11:01--  https://raw.githubusercontent.com/samratashok/nishang/master/Shells/Invoke-PowerShellTcp.ps1
Resolviendo raw.githubusercontent.com (raw.githubusercontent.com)... 185.199.110.133, 185.199.111.133, 185.199.108.133, ...
Conectando con raw.githubusercontent.com (raw.githubusercontent.com)[185.199.110.133]:443... conectado.
Petición HTTP enviada, esperando respuesta... 200 OK
Longitud: 4339 (4,2K) [text/plain]
Grabando a: «Invoke-PowerShellTcp.ps1»

Invoke-PowerShellTcp.ps1                 100%[=================================================================================>]   4,24K  --.-KB/s    en 0,003s  

2022-05-16 22:11:02 (1,45 MB/s) - «Invoke-PowerShellTcp.ps1» guardado [4339/4339]

┌─[root@angussmoody]─[/mnt/angussMoody/Preparación/AD]
└──╼ #ll Invoke-PowerShellTcp.ps1 
Permissions Size User        Date Modified Name
.rwxrwxrwx  4,3k angussmoody 16 may 22:11  Invoke-PowerShellTcp.ps1
```


Vamos a instalar una herramienta llamada [responder](https://www.kali.org/tools/responder/)  esta herramienta permite envenenar la red y poder obtener  algunos hash o información que pase por esta para instalarnos esta herramienta podemos clonar su repositorio  desde [GitHub](https://github.com/lgandx/Responder) o podemos instalar directamente en nuestro sistema de esta manera  `apt install responder` aunque ya viene instalada por defecto en nuestro sistema Parrot Security

```csharp
**┌─[root@angussmoody]─[/home/angussmoody]
└──╼ #apt install responder 
Leyendo lista de paquetes... Hecho
Creando árbol de dependencias... Hecho
Leyendo la información de estado... Hecho
responder ya está en su versión más reciente (3.0.6.0-0parrot1).
fijado responder como instalado manualmente.
0 actualizados, 0 nuevos se instalarán, 0 para eliminar y 16 no actualizados.
┌─[root@angussmoody]─[/home/angussmoody]
└──╼ #responder
                                         __
  .----.-----.-----.-----.-----.-----.--|  |.-----.----.
  |   _|  -__|__ --|  _  |  _  |     |  _  ||  -__|   _|
  |__| |_____|_____|   __|_____|__|__|_____||_____|__|
                   |__|

           NBT-NS, LLMNR & MDNS Responder 3.0.6.0

  Author: Laurent Gaffie (laurent.gaffie@gmail.com)
  To kill this script hit CTRL-C**
```

Ya para finalizar vamos a descargar los diccionarios que vamos a utilizar en esta práctica, el primero que vamos a utilizar es el KaonashiWPA100M de [kaonashi](https://github.com/kaonashi-passwords/Kaonashi), como dice el nombre, este diccionario cuenta con 100 millones de contraseñas, vamos a la git hub de  [kaonashi](https://github.com/kaonashi-passwords/Kaonashi) 

![7.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/7%201.png)

Y nos descargamos este archivo [KaonashiWPA100M](https://mega.nz/#!jeRRgQgZ!xcRcLpm0ftuu7z7JN32LHMECqk9vmpVNH2JFVxSICfU), nos enviará a un enlace de mega

![8.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/8%201.png)

Estando en Mega le vamos a dar en descargar 

![9.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/9%201.png)

Una vez descargado el diccionario le damos en  Extraer aquí y ya tenemos nuestro diccionario listo 

![11.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/11%201.png)

![12.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/12%201.png)

y como segundo diccionario vamos a utilizar el [rockyou.txt](https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt) que por lo general ya viene en nuestro sistema operativo Parrot, pero si no es el caso podemos descárgalo de este enlace [rockyou.txt](https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt)  que es una descarga directa

![13.png](/assets/images/2022-05-17-Configuracion_Maquina_atacante_con_Parrot/13%201.png)

O podemos extraerlo de nuestro sistema Parrot en la ruta  /usr/share/wordlists/ con el comando gzip -d y el nombre del archivo, de esta manera: 

Ingresamos a la ruta con el comando cd

```csharp
┌─[root@angussmoody]─[/home/angussmoody]
└──╼ #cd /usr/share/wordlists/
```

listamos para confirmar que nuestro archivo se encuentra en la ruta y esté comprimido 

```csharp
┌─[root@angussmoody]─[/usr/share/wordlists]
└──╼ #ls rockyou.txt.gz 
rockyou.txt.gz
```

Le pasamos el comando gzip -d y el nombre del archivo

```csharp
┌─[✗]─[root@angussmoody]─[/usr/share/wordlists]
└──╼ #gzip -d rockyou.txt.gz 
```

Y listamos para ver si ya tenemos el diccionario y nos debe salir de esta manera para que podamos  utilizarlo para crackear contraseñas

```csharp
┌─[root@angussmoody]─[/usr/share/wordlists]
└──╼ #ls rockyou.txt 
rockyou.txt
```