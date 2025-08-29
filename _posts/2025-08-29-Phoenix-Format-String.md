---
layout: single
title: "Exploit Education Phoenix - Format-String"
permalink: /_pages/pwn/format-string/
comments: true
excerpt: "Phoenix"
classes: wide
header:
  teaser: /assets/images/2025-08-29-Phoenix/logo.jpg
categories: [PWN]
tags: [PWN, Linux, Hacking, Easy]
---

![Untitled](/assets/images/2025-08-29-Phoenix/banner.png)

En esta categoría nos centraremos en las vulnerabilidades de tipo *format string*, que ocurren cuando una aplicación utiliza funciones inseguras para imprimir datos sin validar adecuadamente las cadenas de formato proporcionadas por el usuario. Estas vulnerabilidades permiten a un atacante leer y, en algunos casos, escribir en ubicaciones arbitrarias de memoria, lo que abre la puerta a la exposición de información sensible o incluso a la ejecución de código malicioso. A lo largo de los diferentes niveles aprenderemos a identificar este tipo de fallos, comprender cómo interactúan con la memoria del programa y explotarlos de forma controlada. oda la práctica se puede realizar en la plataforma:

[**Exploit Education > Phoenix**](https://exploit.education/phoenix/){:target="_blank"}

Que proporciona los binarios vulnerables y el entorno necesario para practicar este tipo de ejercicios de explotación.

[format-zero](/pwn/phoenix/format-zero/)