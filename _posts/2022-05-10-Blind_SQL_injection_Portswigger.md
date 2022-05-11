---
layout: single
title: Blind SQL injection Portswigger
comments: true
excerpt: "Blind SQL injection Portswigger"
date: 2022-05-09
classes: wide
header:
  teaser: /assets/images/2022-05-10-Blind_SQL_injection_Portswigger/logo.png
  teaser_home_page: true
categories:
  - HacktheBox
tags:
  - Portswigger
  - labs
  - Hacking
  - SQLi
---
### [https://portswigger.net/web-security/sql-injection/blind](https://portswigger.net/web-security/sql-injection/blind)

### [https://portswigger.net/web-security/sql-injection/cheat-sheet](https://portswigger.net/web-security/sql-injection/cheat-sheet)

## Primer Reto: Inyección SQL ciega con respuestas condicionales

Este laboratorio contiene una vulnerabilidad de [inyección SQL ciega](https://portswigger.net/web-security/sql-injection/blind). La aplicación utiliza una cookie de seguimiento para análisis y realiza una consulta SQL que contiene el valor de la cookie enviada.

Los resultados de la consulta SQL no se devuelven y no se muestran mensajes de error. Pero la aplicación incluye un mensaje de "Bienvenido de nuevo" en la página si la consulta devuelve filas.

La base de datos contiene una tabla diferente llamada `users`, con columnas llamadas `username`y `password`. Debe aprovechar la vulnerabilidad de [inyección SQL](https://portswigger.net/web-security/sql-injection) ciega para averiguar la contraseña del `administrator`usuario.

Para resolver el laboratorio, inicie sesión como `administrator`usuario.

Entonces según lo que nos dice el laboratorio es que la cabecera Cookie: cuenta con un campo llamado TrackingId, donde está la cookie del usuario, y que es vulnerable a SQLi, solo que no nos muestra un error como tal, pero si nos devuelve un mensaje de bienvenida cada vez que la inyección está correcta, entonces debemos aprovechar esto, para extraer la contraseña del usuario administrador, que como nos dice el laboratorio se encuentra en la tabla users

Lo primero que vamos a hacer es identificar el mensaje de bienvenida que es Welcome back! 

![1.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/1.png)

Vemos que si modificamos la cookie, ya el mensaje de bienvenida se pierde, así que vamos  a hacer la prueba de la inyección enviando una condicional ' or 1=1 — para ver que nos da como respuesta y vemos que esta nos devuelve con el mensaje de bienvenida, así que confirmamos que tenemos una SQLi en este campo ya que nos toma la condicional, lo que le estamos enviando es que verifique la cookie ó que verifique si 1  es igual a 1 y como la segunda condicional se cumple, nos da el mensaje de bienvenida.

![1.3.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/1.3.png)

Ahora debemos empezar a realizar consultas a la base de datos, hasta que lleguemos a nuestro objetivo que es encontrar las credenciales del usuario administrador, vamos a ver primero cuantas columnas devuelve la consulta y cuantas de ellas son de tipo string, como hemos realizado en los laboratorios anteriores y después de realizar el proceso, vemos que la consulta nos devuelve  una columna y esta es de tipo string

![1.4.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/1.4.png)

Ahora podemos verificar que el Usuario administrator si exista en la base de datos con la siguiente inyección: '+UNION+SELECT+'a'+FROM+users+WHERE+username='administrator'— y vemos que este nos devuelve con un ok

![1.5.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/1.5.png)

Ahora vamos a tratar de analizar datos de la contraseña, lo primero que vamos a tratar de realizar es encontrar el tamaño de la contraseña de este usuario y para esto vamos a probar con la siguiente inyección: '+UNION+SELECT+'a'+FROM+users+WHERE+username='administrator'AND+length(password)>8—  y vemos que nos devuelve el mensaje de bienvenida, eso nos quiere decir que la contraseña es mayor a 8 caracteres, ahora debemos encontrar la cantidad exacta de caracteres que tiene esta

![1.6.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/1.6.png)

Después de realizar varias pruebas vemos que cuando le ponemos la condición >19 nos da el mensaje, pero cuando le ponemos >20 no nos lo muestra, entonces esto nos dice que la contraseña tiene un total de 20 caracteres 

![1.7.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/1.7.png)

Ya con el tamaño de la contraseña podemos empezar a extraer cada uno de los caracteres, para compararlos con uno que nosotros elijamos, la contraseña podría ser solo letras, solo números, solo símbolos o una combinación de varios, así que lo que vamos a hacer es enviar esta inyección: **'+UNION+SELECT+'a'+FROM+users+WHERE+username='administrator'AND+substring(password,1,1)='a'— donde le estamos diciendo que de la columna password nos extraiga el primer caracter y nos verifique si es una letra a minúscula, pero esta inyección no nos devuelve el mensaje de bienvenida, así que sabemos que no es una a**

![1.8.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/1.8.png)

Así que vamos a probar con las otras letras del abecedario para ver si tenemos respuesta con alguna y vemos que cuando le enviamos la letra l minúscula nos devuelve con el mensaje, así que ya sabemos que la primera letra de la contraseña es una l

![1.9.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/1.9.png)

Podríamos hacerlo manualmente, pero nos tomaría mucho tiempo realizar el proceso. así que vamos a hacer uso del Intruder, que viene en nuestro Burp, para esto le damos click derecho a la solicitud y le damos click en Send to Intruder o podemos darle Ctrl+i para enviarlo 

![1.10.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/1.10.png)

Ahora vamos a Intruder y le damos al botón de Clear para eliminar todo lo que tenemos seleccionado, la idea es que empecemos a extraer uno a uno de los caracteres del campo password y empecemos a compararlos con las letras del abecedario, tanto mayúsculas como minúsculas, números y también podemos agregar símbolos, ya que no sabemos el patrón que se utiliza para crear esta contraseña

![1.11.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/1.11.png)

Vamos a realizar un ataque Cluster bomb que podemos ver el uso de este en esta articulo: [https://portswigger.net/burp/documentation/desktop/tools/intruder/positions](https://portswigger.net/burp/documentation/desktop/tools/intruder/positions)  pero básicamente lo que realiza es una combinación de nuestro primer payload, con todos los del segundo payload, para más información podemos consultar el anterior articulo, ahora debemos decirle cuales son los campos que queremos que se vayan modificando, que sería el primer campo de la consulta que nos extrae el  caracter de la contraseña y la comparación que queremos hacer, así que en Position, nos quedaría de la siguiente manera

![1.12.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/1.12.png)

Pasamos a Pauloads y le decimos que para nuestro primer payload, como lo hemos hablado, queremos que sean números del 1 hasta el 20 que es la longitud de nuestra contraseña y que se vaya incrementando de 1 en 1 

![1.13.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/1.13.png)

Y para nuestro segundo Payload le decimos lo que queremos que tenga, como dijimos antes, vamos a ponerle todas las letras Mayúsculas, Minúsculas, números y unos caracteres especiales  ( #$&/"$() )

![1.14.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/1.14.png)

Podemos ir a opciones y modificar un poco los campos, para este caso le doy a decir que suba los hilos a 20 y pondré la condición que necesitamos, sabemos que cuando nos devuelve un Welcome back! es que la consulta fue exitosa, así que vamos a Grep - Match, le damos a clear para que borre los resultados que tiene y pones esta expresión en el campo de texto y le damos en add

![1.16.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/1.16.png)

Ya con todo configurado, lanzamos el ataque

![1.17.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/1.17.png)

Al finalizar el ataque, vemos que cuando el resultado es positivo, según nuestra configuración, en el campo de Welcome Back! nos devuelve un checklist, lo que quiere decir que en este ejemplo en la posición 18 el caracter es una letra s minúscula 

![1.18.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/1.18.png)

Filtramos por el campo que necesitamos que es el de la condición de Welcome back! y después de extraer los datos en el orden de 1 a 20 vemos que la contraseña para este laboratorio es v7fc0o1aik805lvhds3g 

![1.19.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/1.19.png)

Pasamos a iniciar sesión con el usuario administrator que es lo que nos pide este reto 

![1.20.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/1.20.png)

Y de esta manera resolvemos este primer reto de inyección a ciegas

![1.21.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/1.21.png)

---

## Segundo Reto: Inyección SQL ciega con errores condicionales

Este laboratorio contiene una vulnerabilidad de [inyección SQL ciega](https://portswigger.net/web-security/sql-injection/blind) . La aplicación utiliza una cookie de seguimiento para análisis y realiza una consulta SQL que contiene el valor de la cookie enviada.

Los resultados de la consulta SQL no se devuelven y la aplicación no responde de forma diferente en función de si la consulta devuelve filas. Si la consulta SQL causa un error, la aplicación devuelve un mensaje de error personalizado.

La base de datos contiene una tabla diferente llamada `users`, con columnas llamadas `username`y `password`. Debe aprovechar la vulnerabilidad de [inyección SQL](https://portswigger.net/web-security/sql-injection) ciega para averiguar la contraseña del usuario `administrator.`

Para resolver el laboratorio, inicie sesión como `administrator`usuario.

**Pista:** Este laboratorio utiliza una base de datos de Oracle. Para obtener más información, consulte la [hoja de trucos](https://portswigger.net/web-security/sql-injection/cheat-sheet) sobre la inyección de SQL .

Entonces lo que nos está diciendo el laboratorio es que podemos realizar consultas, dependiendo de los errores que nos manden nuestras inyecciones, lo primero que vamos a probar es que tipo de error nos manda cuando mandamos una comilla simple  y vemos que de esta forma nos responde con un error

![2.1.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/2.1.png)

Pero cuando le enviamos dos comillas simples esta nos devuelve con un estado de 200 OK

![2.2.png](/assets/images/2022-05-10-Blind_SQL_injection_Portswigger/2.2.png)

Ya con esto sabemos que tenemos un error al enviar mal una consulta, ahora vamos a realizar una consulta concatenada para revisar bien los errores que podemos tener