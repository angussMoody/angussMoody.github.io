---
layout: single
title: Crackmes Android - Capitulo 2
comments: true
excerpt: "continuamos con estos crackmes de android"
date: 2023-04-09
classes: wide
header:
  teaser: /assets/images/2023-04-29-Crackmes_Android_Cap2/logo.png
  teaser_home_page: true
categories:
  - Crackmes
tags:
  - Android
  - Hacking
  - crackmes
  - Easy
---

## un agradecimiento muy espacial a [Rafael Lior](https://twitter.com/rafael_lior)  por realizar este taller 🤙🏽

[**PINLOCKVIEWAPP**](Crackmes%20Android%20-%20Capitulo%202%20cf8d1edf19d6482aa53efa7a6e7b381e.md)

[**LOGIN REGISTER 3**](Crackmes%20Android%20-%20Capitulo%202%20cf8d1edf19d6482aa53efa7a6e7b381e.md)

# PINLOCKVIEWAPP

Reto: Encontrar el PIN de la aplicación 

Se procede a instalar la aplicación pinlockview.apk en el dispositivo, usando un equipo emulado con [**genymotion.com](https://www.genymotion.com/download/)**  Para ello, se verifica primero que el equipo responda a través del comando `**adb devices**` Después, situándose en el directorio donde se encuentra la aplicación, se realiza la instalación mediante el comando `**adb install pinlockview.apk**`

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled.png)

Al abrir la aplicación, se solicita un código de cuatro dígitos al usuario.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%201.png)

Se procede a abrir la aplicación utilizando la herramienta [**jadx](https://github.com/skylot/jadx/releases)** para verificar si el código que se necesita está incrustado en el código fuente. Sin embargo, luego de revisar la aplicación, no se encuentra el código de cuatro dígitos que se está buscando.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%202.png)

El siguiente paso consiste en buscar el código deseado desde una shell. Para ello, se utiliza el comando `**adb shell**` y se debe acceder como usuario root para poder explorar los directorios y archivos necesarios.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%203.png)

Posteriormente, se dirige al directorio /data/data/ mediante el comando **`cd /data/data`** que es donde el equipo almacena la información de las aplicaciones instaladas. Para acceder a esta información, es necesario tener permisos de usuario root. Dentro del directorio, se ejecuta el comando `**ls**` para listar todos los directorios y encontrar el directorio específico de la aplicación que se busca, que en este caso se llama com.andrognito.pinlockviewapp.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%204.png)

Luego de encontrar el directorio específico de la aplicación, com.andrognito.pinlockviewapp, se utiliza el comando `**cd com.andrognito.pinlockviewapp**` para ingresar al directorio de la aplicación. A continuación, se utiliza el comando `**ls -la**` para visualizar los archivos y subdirectorios que se encuentran en el interior de la aplicación.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%205.png)

Después de explorar los archivos y subdirectorios de la aplicación, se accede al directorio shared_prefs mediante el comando `**cd shared_prefs**` Este directorio suele contener información sensible. Una vez dentro de este directorio, se encuentra un archivo llamado MyPreferences.xml.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%206.png)

Para leer el contenido del archivo MyPreferences.xml, se utiliza el comando `**cat MyPreferences.xml**` Al hacerlo, se puede visualizar el contenido del archivo y encontrar el código de cuatro dígitos que se necesita en la aplicación.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%207.png)

Finalmente, se valida el código encontrado en el archivo MyPreferences.xml en la aplicación, ingresándolo en la interfaz gráfica de la misma. Si el código es correcto, se podrá acceder a la aplicación y utilizarla normalmente.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%208.png)

Si el código ingresado es correcto, se podrá acceder a la aplicación y visualizar la imagen de un gato, lo cual indica que se ha completado el reto con éxito.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%209.png)

---

# LOGIN REGISTER 3

Reto: El reto **Login Register 3** consiste en crear una cuenta de usuario, para ver el funcionamiento de ésta y obtener la base de datos de la aplicación en donde podamos visualizar las cuentas de usuarios creados.

Instalar la aplicación llamada **login-register3.apk** en el dispositivo, continuamos con el emulador  [genymotion.com](https://www.genymotion.com/download/) primero confirmamos que el equipo responda con el comando `**adb devices**` y luego estando en el directorio donde esté la aplicación la instalamos con el comando `**adb install login-register3.apk**`

Para instalar la aplicación llamada login-register3.apk en el dispositivo, se utiliza el emulador **[genymotion.com](https://www.genymotion.com/download/)** y se confirma que el equipo responda con el comando `**adb devices**`Una vez confirmado esto, se ingresa al directorio donde se encuentra la aplicación y se instala en el dispositivo con el comando `**adb install login-register3.apk**`

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%2010.png)

Al abrir la aplicación login-register3.apk, se muestra una pantalla de inicio de sesión (login) y se ofrece la opción de crear una cuenta.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%2011.png)

Si se decide crear una cuenta, se presenta un formulario para ingresar los datos requeridos. Luego de crear la cuenta, se puede iniciar sesión en la aplicación utilizando los datos ingresados en el formulario.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%2012.png)

En el reto planteado, se indica que se debe tratar de encontrar la base de datos de la aplicación. Para esto, se inicia una shell en el dispositivo a través del comando `**adb shell**` Se verifica que se esté ingresando como root mediante el comando `**whoami**`ya que es necesario para acceder a los directorios requeridos.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%2013.png)

Ahora dirigirse a la ruta donde se encuentran los directorios de las aplicaciones mediante el comando `**cd /data/data**` Una vez allí, utilizan el comando `**ls -la | grep register**` para localizar el directorio requerido en el reto.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%2014.png)

ingresar al directorio de la aplicación con el comando `**cd com.androidtutorialshub.loginregister**` y una vez dentro del directorio se corre el comando `**ls -la**` para ver los directorios y archivos que puedan estar dentro del mismo, y se puede observar que existe un directorio llamado "databases"

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%2015.png)

Con el comando **`cd databases`** se puede ingresar a este directorio y una vez dentro se corre el comando **`ls -la`** para ver los archivos o directorios que pueda tener éste, y se puede observar que existe un archivo llamado "UserManager.db"

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%2016.png)

Para pasar todo el directorio "databases" al host, se debe abrir una terminal y dirigirse al directorio deseado para descargar el directorio "databases". Una vez allí, se debe ejecutar el comando **`adb pull /data/data/com.androidtutorialshub.loginregister/databases`** para descargar el directorio desde el dispositivo Android. Luego, se puede confirmar que el directorio se descargó correctamente ejecutando el comando **`dir databases`** en la terminal, el cual mostrará el contenido del directorio actual. Si se encuentra la carpeta "databases" en el listado de la terminal, se puede confirmar que el directorio se descargó correctamente.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%2017.png)

Se hace uso de la Herramienta [**DB Browser for SQLite**](https://sqlitebrowser.org/about/), se puede ver la instalación de esta herramienta paso a paso en este [**link](https://angussmoody.github.io/android/Herramientas/),** Se abre el navegador de archivos y se confirma que el archivo UserManager.db se encuentra en el directorio, dar clic derecho y abrir con DB Browser for SQLite

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%2018.png)

Se solicita una contraseña, la cual no se tiene en este momento.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%2019.png)

Se hace uso de la herramienta [**jadx-gui**](https://github.com/skylot/jadx/releases) que también se puede ver el paso a paso de la instalación en este [**link**](https://angussmoody.github.io/android/Herramientas/#instalaci%C3%B3n-jadx-gui) Esta herramienta sirve para visualizar el código de la aplicación. Se abre el archivo apk con esta herramienta y se localiza una clase llamada DatabaseHelper. En esta clase, se puede observar información de la base de datos y, entre estos datos, se encuentra una variable llamada DB_PASS que tiene asignado el valor “la bamba”.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%2020.png)

Se selecciona SQLCipher 3 defaults y se establece la contraseña “la bamba” y se hace clic en OK.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%2021.png)

Se observa que la base de datos se carga correctamente y posteriormente, se hace clic en Browse Data

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%2022.png)

En el campo de Table: se selecciona la opción que dice 'user'.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%2023.png)

En esta tabla se muestran los nombres de usuario, correos y contraseñas de los usuarios registrados en la aplicación.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%2024.png)

Ahora se procede a probar el inicio de sesión con uno de los usuarios registrados en la aplicación, en este caso, se utilizan los datos del usuario EthCop.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%2025.png)

Se puede comprobar que las credenciales almacenadas en la base de datos son correctas y, por lo tanto, se puede concluir que se ha completado el reto con éxito.

![Untitled](/assets/images/2023-04-29-Crackmes_Android_Cap2/Untitled%2026.png)