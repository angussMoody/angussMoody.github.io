---
layout: single
title: SQL injection UNION attacks  Portswigger
comments: true
excerpt: "SQL injection UNION attacks Portswigger"
date: 2022-05-09
classes: wide
header:
  teaser: /assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/logo.png
  teaser_home_page: true
categories:
  - Portswigger
tags:
  - Portswigger
  - labs
  - Hacking
  - SQLi
---
### [https://portswigger.net/web-security/sql-injection/union-attacks](https://portswigger.net/web-security/sql-injection/union-attacks)

## Primer Reto: Determinar el número de columnas necesarias en un ataque UNION de inyección SQL

Este laboratorio contiene una vulnerabilidad de inyección de SQL en el filtro de categoría de producto. Los resultados de la consulta se devuelven en la respuesta de la aplicación, por lo que puede utilizar un ataque UNION para recuperar datos de otras tablas. El primer paso de un ataque de este tipo es determinar el número de columnas que devuelve la consulta. Luego, utilizará esta técnica en laboratorios posteriores para construir el ataque completo.

Para resolver el laboratorio, determine el número de columnas devueltas por la consulta realizando un ataque [UNION de inyección SQL](https://portswigger.net/web-security/sql-injection/union-attacks) que devuelve una fila adicional que contiene valores nulos.

Paro esto nos dan una página con varias categorías

![1.png](/assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/1.png)

Ingresamos a una categoría e interceptamos el trafico

![2.png](/assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/2.png)

Cómo nos lo dice el reto debemos buscar el número de columnas que nos devulve esta consulta, para esto basta con enviar una comilla, un union select y enviar NULL, y terminar con doble - hasta que tengamos un resultado de esta manera  '+UNION+SELECT+NULL,NULL— pero vemos que así nos devuelve un error

![3.png](/assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/3.png)

Así que vamos incrementando hasta que tangamos una respuesta positiva y vemos que enviando 3 nos devuelve un estado de 200 

![4.png](/assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/4.png)

Y nos dice que resolvimos el reto

![5.png](/assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/5.png)

---

## Segundo Reto: Encontrar columnas con un tipo de datos útil en un ataque UNION de inyección SQL

Este laboratorio contiene una vulnerabilidad de inyección de SQL en el filtro de categoría de producto. Los resultados de la consulta se devuelven en la respuesta de la aplicación, por lo que puede utilizar un ataque UNION para recuperar datos de otras tablas. Para construir un ataque de este tipo, primero debe determinar el número de columnas devueltas por la consulta. Puede hacer esto usando una técnica que aprendió en un [laboratorio anterior](https://portswigger.net/web-security/sql-injection/union-attacks/lab-determine-number-of-columns) . El siguiente paso es identificar una columna que sea compatible con los datos de la cadena.

El laboratorio proporcionará un valor aleatorio que debe hacer que aparezca dentro de los resultados de la consulta. Para resolver el laboratorio, realice un ataque [UNION de inyección SQL](https://portswigger.net/web-security/sql-injection/union-attacks) que devuelva una fila adicional que contenga el valor proporcionado. Esta técnica le ayuda a determinar qué columnas son compatibles con los datos de la cadena

entonces para este reto necesitamos saber cuantas columnas tiene y cuantas con de tipo string

Realizando el ataque, como lo hicimos en el anterior, vemos que esta petición también cuenta con 3 Columnas

![2.1.png](/assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/2.1.png)

Ahora debemos modificar los NULL por un texto para ver si una de ellas o varias son de tipo string como por ejemplo realizarlo de esta manera '+UNION+SELECT+'angussMoody',NULL,NULL — Pero vemos que en la primera nos sale un error

![2.2.png](/assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/2.2.png)

Al realizar el proceso con la segunda y tercera columna vemos que solo tenemos resultados con la segunda

![2.3.png](/assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/2.3.png)

Para resolver el reto, vamos a interceptar la petición y la modificamos tal como lo hicimos con el repetidor pero con el string que nos da el laboratorio

![2.4.png](/assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/2.4.png)

![2.5.png](/assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/2.5.png)

Le damos continuar y ya vemos que hemos resuelto el laboratorio

![2.6.png](/assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/2.6.png)

---

## Tercer Reto: Usando un ataque UNION de inyección SQL para recuperar datos interesantes

Este laboratorio contiene una vulnerabilidad de inyección de SQL en el filtro de categoría de producto. Los resultados de la consulta se devuelven en la respuesta de la aplicación, por lo que puede utilizar un ataque UNION para recuperar datos de otras tablas. Para construir un ataque de este tipo, debe combinar algunas de las técnicas que aprendió en los laboratorios anteriores.

La base de datos contiene una tabla diferente llamada `users`, con columnas llamadas `username`y `password`.

Para resolver el laboratorio, realice un ataque [UNION de inyección SQL](https://portswigger.net/web-security/sql-injection/union-attacks) que recupere todos los nombres de usuario y contraseñas, y use la información para iniciar sesión como usuario`administrator.`

Lo primero que debemos hacer en este reto es ver cuantas columnas devuelve la petición y cuales de ellas son de tipo string y vemos que la consulta devuelve 2 Columnas y ambas son de tipo string

![3.1.png](/assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/3.1.png)

Ahora debemos realizar una petición a la base de datos y como ya nos dijo el laboratorio las columnas se llaman `username`y `password` y la tabla se llama `users`  hacemos la consulta de esta manera: '+UNION+SELECT+username,password+FROM+USERS— y esta nos devuelve los campos de esa tabla

![3.2.png](/assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/3.2.png)

Lo que nos pide el laboratorio es que iniciamos sesión con el usuario `administrator.` y como ya tenemos los datos de este pasamos a iniciar sesión con este usuario

![3.3.png](/assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/3.3.png)

y de esta manera ya resolvemos este reto

![3.4.png](/assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/3.4.png)

---

## Cuarto Reto: Recuperar varios valores dentro de una sola columna

Este laboratorio contiene una vulnerabilidad de inyección de SQL en el filtro de categoría de producto. Los resultados de la consulta se devuelven en la respuesta de la aplicación para que pueda utilizar un ataque UNION para recuperar datos de otras tablas.

La base de datos contiene una tabla diferente llamada `users`, con columnas llamadas `username`y `password`.

Para resolver el laboratorio, realice un ataque [UNION de inyección SQL](https://portswigger.net/web-security/sql-injection/union-attacks) que recupere todos los nombres de usuario y contraseñas, y use la información para iniciar sesión como `administrator`usuario.

Para iniciar con el reto debemos primero saber cuantas columnas tiene y cuantas son de tipo string como en los retos pasados y vemos que nos devuelve 2 columnas y solo una de tipo strting, así que con la descripción del reto, vemos que debemos traer los datos de  `username`y `password` en esta columna

![4.1.png](/assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/4.1.png)

para este reto nos dan una pista y es una hoja de trucos [https://portswigger.net/web-security/sql-injection/cheat-sheet](https://portswigger.net/web-security/sql-injection/cheat-sheet) donde podemos ver una parte de concatenación 

```abap
String concatenation
You can concatenate together multiple strings to make a single string.

Oracle	    'foo'||'bar'
Microsoft	  'foo'+'bar'
PostgreSQL	'foo'||'bar'
MySQL	      'foo' 'bar' [Note the space between the two strings] CONCAT('foo','bar')
```

Así que podemos pensar de acuerdo a lo que nos dice el reto, que si concatenamos las columnas que necesitamos en la que nos devuelve de tipo string podemos tener los datos `username`y `password` de la tabla  `users` y vemos que si realizamos la inyección de esta manera '+UNION+SELECT+NULL,username||password+FROM+USERS— nos devuelve los datos

![4.2.png](/assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/4.2.png)

pero aunque se distingue los datos no sabemos bien en que parte termina el username y el que parte empieza el password  así que vamos a aprovechar la concatenación para realizar un separador entre ambos de esta manera '+UNION+SELECT+NULL,username||'-'||password+FROM+USERS— y así podemos leer mejor los datos de respuesta 

![4.3.png](/assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/4.3.png)

para terminar el Reto, nos dice que debemos iniciar sesión como el administrador 

![4.4.png](/assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/4.4.png)

y ya de esta manera resolvemos este reto

![4.5.png](/assets/images/2022-05-10-SQL_injection_UNION_attacks_Portswigger/4.5.png)

Y de esta manera terminamos la sesión de **Ataques de Inyección SQL por medio de UNION**