---
layout: single
title:  Examining the database in SQL injection attacks Portswigger
comments: true
excerpt: " Examining the database in SQL injection attacks Portswigger"
date: 2022-05-09
classes: wide
header:
  teaser: /assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/logo.png
  teaser_home_page: true
categories:
  - Portswigger
tags:
  - Portswigger
  - labs
  - Hacking
  - SQLi
---

### [https://portswigger.net/web-security/sql-injection/examining-the-database](https://portswigger.net/web-security/sql-injection/examining-the-database)

## Hoja de trucos [https://portswigger.net/web-security/sql-injection/cheat-sheet](https://portswigger.net/web-security/sql-injection/cheat-sheet)

## Primer Reto: A**taque de inyección SQL, consulta del tipo y versión de la base de datos en Oracle**

Este laboratorio contiene una vulnerabilidad de [inyección de SQL](https://portswigger.net/web-security/sql-injection) en el filtro de categoría de producto. Puede utilizar un ataque UNION para recuperar los resultados de una consulta inyectada.

Para resolver la práctica de laboratorio, muestre la cadena de versión de la base de datos.

Este laboratorio nos da una pista y nos dice que: 

En las bases de datos de Oracle, cada `SELECT`declaración debe especificar una tabla para seleccionar `FROM`. Si su `UNION SELECT`ataque no consulta desde una tabla, deberá incluir la `FROM`palabra clave seguida de un nombre de tabla válido.

Hay una tabla incorporada en Oracle llamada `dual`que puede usar para este propósito. Por ejemplo:`UNION SELECT 'abc' FROM dual`

Para resolver este reto nos dice que podemos hacer un ataque Union, como vimos en los retos anteriores y en este caso, necesitamos ver el tipo y la versión de la base de datos

Lo primero que vamos a hacer es ver cuantas columnas nos devuelve la consulta y cuales de ellas son de tipo string y vemos que con esta inyección '+UNION+SELECT+'test','test'+FROM+DUAL— nos devuelve un estado de 200 OK

![5.1.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/5.1.png)

Ya que tenemos este dato y que el laboratorio nos dijo que es una base de datos Oracle, vamos a la [hoja de trucos](https://portswigger.net/web-security/sql-injection/cheat-sheet) para ver cómo podemos hacer la consulta 

```abap
Database version
You can query the database to determine its type and version. This information is useful when formulating more complicated attacks.

Oracle	    SELECT banner FROM v$version
            SELECT version FROM v$instance

Microsoft	  SELECT @@version

PostgreSQL	SELECT version()

MySQL	      SELECT @@version
```

Pasamos a hacer la inyección como nos dice la hoja y vamos a probar de las dos maneras, primero con  SELECT version FROM v$instance y después con SELECT banner FROM v$version para que veamos si tienen alguna diferencia, la primera inyección nos devuelve la versión de la base de datos que nos pide el reto

![5.2.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/5.2.png)

De esta manera ya resolvimos el reto, pero vamos a ver la diferencia con la otra forma de ver la versión en una base de datos Oracle y vemos que esta inyección nos trae más información de la base de datos

![5.3.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/5.3.png)

De esta manera resolvemos el reto 

![5.4.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/5.4.png)

---

## Segundo reto: Ataque de inyección SQL, consulta del tipo y versión de la base de datos en MySQL y Microsoft

Este laboratorio contiene una vulnerabilidad de [inyección de SQL](https://portswigger.net/web-security/sql-injection) en el filtro de categoría de producto. Puede utilizar un ataque UNION para recuperar los resultados de una consulta inyectada.

Para resolver la práctica de laboratorio, muestre la cadena de versión de la base de datos.

Como pista nos dice que podemos buscar en la [Hoja de trucos](https://portswigger.net/web-security/sql-injection/cheat-sheet)

Entonces para este reto debemos buscar la misma información de el reto pasado, solo que la base de datos es MySQL o Microsoft que tienen una forma diferente de realizar las inyecciones, como por ejemplo los comentarios

```abap
Comments
You can use comments to truncate a query and remove the portion of the original query that follows your input.

Oracle	     --comment

Microsoft  	 --comment
             /*comment*/

PostgreSQL	 --comment
             /*comment*/

MySQL	       #comment
             -- comment [Note the space after the double dash]
             /*comment*/
```

Primero vamos a ver cuantas columnas devuelve la consulta, cuales de ellas son de tipo string y si podemos identificar el tipo de base de datos, después de hacer pruebas, vemos que con el comentario con doble guion  - - nos da un error   

![6.1.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/6.1.png)

Pero cuando mandamos el comentario con numeral # vemos que nos devuelve un estado de 200 OK, así que según lo que hemos visto en la hoja de trucos, podemos asumir que es una base de datos MySQL

![6.2.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/6.2.png)

Entonces vamos a probar ver la versión, según lo que nos dice la [Hoja de Trucos](https://portswigger.net/web-security/sql-injection/cheat-sheet) MySQL SELECT @@version y vemos que este nos da una versión en la respuesta

![6.3.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/6.3.png)

De esta manera realizamos este segundo reto

![6.4.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/6.4.png)

---

## Tercer Reto: Ataque de inyección SQL, enumerando el contenido de la base de datos, en bases de datos que no son de Oracle

Este laboratorio contiene una vulnerabilidad de [inyección de SQL](https://portswigger.net/web-security/sql-injection) en el filtro de categoría de producto. Los resultados de la consulta se devuelven en la respuesta de la aplicación para que pueda utilizar un ataque UNION para recuperar datos de otras tablas.

La aplicación tiene una función de inicio de sesión y la base de datos contiene una tabla que contiene nombres de usuario y contraseñas. Debe determinar el nombre de esta tabla y las columnas que contiene, luego recuperar el contenido de la tabla para obtener el nombre de usuario y la contraseña de todos los usuarios.

Para resolver el laboratorio, inicie sesión como `administrator`usuario.

Este reto es diferente a los anteriores y es un poco más realista, ya que nos dice que nosotros debemos buscar en la base de datos el nombre de la tabla, los nombres de las Columnas  y además los datos que tiene en ella, pero primero debemos saber cuantas columnas devuelve la consulta y de ellas cuales son de tipo string, como en retos anteriores, las únicas pista que nos da este reto es que podemos encontrar cosas útiles en la [Hoja de Trucos](https://portswigger.net/web-security/sql-injection/cheat-sheet)  y que la Base de datos no es Oracle, realizando la inyección vemos que la consulta devuelve 2 columnas y ambas son de tipo string

![7.1.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/7.1.png)

Ahora necesitamos ver las tablas que tiene esta base de datos y para ello vamos a ir a la  [Hoja de Trucos](https://portswigger.net/web-security/sql-injection/cheat-sheet) donde nos encontramos con Database contens, que nos dice que podemos ver la información de tablas y el contenido

```abap
Database contents
You can list the tables that exist in the database, and the columns that those tables contain.

Oracle	      SELECT * FROM all_tables
              SELECT * FROM all_tab_columns WHERE table_name = 'TABLE-NAME-HERE'

Microsoft	    SELECT * FROM information_schema.tables
              SELECT * FROM information_schema.columns WHERE table_name = 'TABLE-NAME-HERE'

PostgreSQL	  SELECT * FROM information_schema.tables
              SELECT * FROM information_schema.columns WHERE table_name = 'TABLE-NAME-HERE'

MySQL	        SELECT * FROM information_schema.tables
              SELECT * FROM information_schema.columns WHERE table_name = 'TABLE-NAME-HERE'
```

Como sabemos que la base de datos No es Oracle, vamos a intentar con information_schema.tables para ver si tenemos una respuesta adecuada, así que hacemos la inyección de la siguiente manera '+UNION+SELECT+table_name,+NULL+FROM+information_schema.tables— y vemos que esta nos devuelve al parecer los nombre de las tablas, ahora debemos identificar cual de ellas es la que tiene las credenciales de los usuarios

Me crearé un archivo con los nombres de todas estas tablas con la herramienta [nano](https://www.hostinger.co/tutoriales/instalar-nano-text-editor) que tengo en mi [WSL](https://www.wikiversus.com/informatica/windows/como-instalar-wsl-windows-subsystem-for-linux-windows-10/) que me permite tener una consola linux en mi máquina windows, para instalar nano basta con un apt install nano, en caso de que no lo tenga instalado por defecto, ahora para crearme un archivo solo tengo que llamar a la herramienta y ponerle un nombre, por ejemplo nano archivo.txt después de esto se me iniciará la herramienta y debe empezar a pegar las tablas que necesito o el texto que se necesite 

![7.4.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/7.4.png)

Ahora solo me queda Guardar el archivo y salirme de la aplicación que lo hago con las teclas Ctrl+o  y luego enter (para guardar) y las teclas Ctrl+x (para salir) ahora voy a usar la herramienta wc con la bandera -l para ver cuantas lineas tiene mi archivo, este me dice que tengo 190 lineas que equivalen a 190 tablas

```abap
┌──(root💀Csiete)-[/mnt/l/Preparación/Portswigger/1 SQL injection/Union]
└─# wc -l tablas.txt
190 tablas.txt
```

Necesito Filtrar un poco para tratar de identificar la tabla que contiene las credenciales así que voy a hacer uso de la herramienta [cat](https://ayudalinux.com/como-usar-el-comando-cat/#:~:text=Cat%20es%20uno%20de%20los,Mostrar%20archivos%20de%20texto&text=Agregue%20el%20contenido%20de%20un,otro%20archivo%20de%20texto%2C%20combin%C3%A1ndolos) que me permite leer archivos y la herramienta [grep](https://www.hostinger.co/tutoriales/comando-grep-linux) que me permite crear el filtro, para este caso, como lo que estoy necesitando es la lista de los usuarios, voy a hacer uso de la palabla user para ver si tengo suerte con las tablas y tengo un filtro de 16 tablas que contienen esta palabra, después de enumerar veo que hay una diferente a las otras, así que voy a tratar de enumerar la tabla users_hraoih

```abap
┌──(root💀Csiete)-[/mnt/l/Preparación/Portswigger/1 SQL injection/Union]
└─# cat tablas.txt | grep user
user_defined_types
pg_statio_user_sequences
pg_user_mappings
pg_stat_xact_user_functions
pg_user_mapping
user_mappings
pg_stat_user_tables
user_mapping_options
pg_stat_xact_user_tables
pg_statio_user_tables
pg_stat_user_indexes
_pg_user_mappings
pg_statio_user_indexes
users_hraoih
pg_user
pg_stat_user_functions
```

Vamos a modificar la inyección para tratar de ver las columnas de esta tabla ,  y con esta inyección '+UNION+SELECT+column_name,+NULL+FROM+information_schema.columns+WHERE+table_name='users_hraoih'— vemos que nos trae lo que al parecer son las columnas donde están las credenciales de los usuarios username_yzgwzb y password_xuxvzl

![7.5.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/7.5.png)

Ahora solo nos queda hacer una consulta de estas columnas como lo hemos realizado en retos anteriores, realizamos la inyección con los datos extraidos '+UNION+SELECT+username_yzgwzb,+password_xuxvzl+FROM+users_hraoih— y esta nos devuelve las credenciales de los usuarios

![7.6.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/7.6.png)

Para resolver el reto nos dice que debemos iniciar sesión como el usuarios `administrator`

![7.7.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/7.7.png)

De esta manera resolvemos este reto

![7.8.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/7.8.png)

---

## Cuarto Reto: Ataque de inyección SQL, enumerando el contenido de la base de datos en Oracle

Este laboratorio contiene una vulnerabilidad de [inyección de SQL](https://portswigger.net/web-security/sql-injection) en el filtro de categoría de producto. Los resultados de la consulta se devuelven en la respuesta de la aplicación para que pueda utilizar un ataque UNION para recuperar datos de otras tablas.

La aplicación tiene una función de inicio de sesión y la base de datos contiene una tabla que contiene nombres de usuario y contraseñas. Debe determinar el nombre de esta tabla y las columnas que contiene, luego recuperar el contenido de la tabla para obtener el nombre de usuario y la contraseña de todos los usuarios.

Para resolver el laboratorio, inicie sesión como `administrator`usuario.

Para este reto debemos realizar un proceso similar al anterior, solo que esta vez la base de datos es Oracle y nos da una pista:

En las bases de datos de Oracle, cada `SELECT`declaración debe especificar una tabla para seleccionar `FROM`. Si su `UNION SELECT`ataque no consulta desde una tabla, deberá incluir la `FROM`palabra clave seguida de un nombre de tabla válido.

Hay una tabla incorporada en Oracle llamada `dual`que puede usar para este propósito. Por ejemplo:`UNION SELECT 'abc' FROM dual`

Para obtener más información, consulte nuestra [hoja de trucos](https://portswigger.net/web-security/sql-injection/cheat-sheet).

Lo primero que debemos hacer como en todos los laboratorios hasta este momento es, ver cuantas columnas nos devuelve la consulta y cuantas de ellas son de tipo string, realizando la siguiente inyección '+UNION+SELECT+'test','test'+FROM+dual— vemos que nos dice que la petición tiene 2 columnas y que ambas son de tipo string

![8.1.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/8.1.png)

Ahora veremos la  para ver como podemos solicitar las tablas de la base de datos en Oracle

```abap
Database contents
You can list the tables that exist in the database, and the columns that those tables contain.

Oracle	      SELECT * FROM all_tables
              SELECT * FROM all_tab_columns WHERE table_name = 'TABLE-NAME-HERE'

Microsoft	    SELECT * FROM information_schema.tables
              SELECT * FROM information_schema.columns WHERE table_name = 'TABLE-NAME-HERE'

PostgreSQL	  SELECT * FROM information_schema.tables
              SELECT * FROM information_schema.columns WHERE table_name = 'TABLE-NAME-HERE'

MySQL	        SELECT * FROM information_schema.tables
              SELECT * FROM information_schema.columns WHERE table_name = 'TABLE-NAME-HERE'
```

Realizamos la siguiente inyección  '+UNION+SELECT+table_name,NULL+FROM+all_tables— y vemos que esta nos devuelve las tablas de la base de datos 

![8.2.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/8.2.png)

Podemos realizar este paso como en el reto anterior y crearnos un listado de las tablas, pero en este reto nos vamos a guiar por la experiencia del pasado y vamos a filtrar desde el mismo navegador para ver si encontramos la tabla que necesitamos siguiendo el patrón del reto anterior y vemos una tabla que nos llama la atención 

![8.3.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/8.3.png)

Ahora vamos a tratar de revisar las columnas de esta tabla como nos dice la [hoja de trucos](https://portswigger.net/web-security/sql-injection/cheat-sheet)  y vemos que con la siguiente inyección '+UNION+SELECT+column_name,NULL+FROM+all_tab_columns+WHERE+table_name='USERS_WSDACK'— nos devuelve al parecer las columnas de las credenciales de los usuarios

![8.4.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/8.4.png)

Ya en este punto debemos realizar la consulta de las columnas PASSWORD_ULWSOE y USERNAME_IRLRKK para ver si nos trae las credenciales y con la inyección '+UNION+SELECT+USERNAME_IRLRKK,PASSWORD_ULWSOE+FROM+USERS_WSDACK— nos trae las credenciales de los usuarios

![8.5.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/8.5.png)

Ahora debemos iniciar sesión como el usuarios `administrator` para terminar el reto 

![8.6.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/8.6.png)

De esta forma terminamos con esta sesión Examinando la base de datos en ataques de inyección SQL que consta de 4 retos 

![8.7.png](/assets/images/2022-05-10-Examining_the_database_in_SQL_injection_attacks_Portswigger/8.7.png)