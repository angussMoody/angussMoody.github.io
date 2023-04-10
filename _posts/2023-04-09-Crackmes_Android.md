---
layout: single
title: Crackmes Android
comments: true
excerpt: "Crackmes Android"
date: 2023-04-09
classes: wide
header:
  teaser: /assets/images/2023-04-09-Crackmes_Android/logo.png
  teaser_home_page: true
categories:
  - Crackmes
tags:
  - Android
  - Hacking
  - crackmes
  - Easy
---

[**CRACKME-ONE.APK**](Crackmes%20Android%209dc7f8c42e444891ad3bb1c350144625.md)

[**CRACKME-TWO.APK**](Crackmes%20Android%209dc7f8c42e444891ad3bb1c350144625.md)

## CRACKME-ONE.APK

Reto: Encontrar la clave de la aplicación 

La aplicación será cargada en la herramienta jadx para revisar su código y se observa que hace una llamada a una clase de listeners.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled.png)

Al revisar las clases de listeners, se puede observar una condición que aparentemente captura lo que se ingresa en una caja de texto y lo compara con la cadena de texto 'poorly-protected-secret'. Para confirmar esto, se debe instalar la aplicación.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%201.png)

Para realizar esto, se necesitará tener activo un emulador o un dispositivo conectado al equipo. Utilizando la herramienta ADB, se puede verificar si hay dispositivos conectados mediante el comando `adb devices`. Así se podrá confirmar si el equipo está conectado correctamente.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%202.png)

Luego, con la misma herramienta, se procede a instalar la aplicación utilizando el comando `adb install crackme-one.apk` Sin embargo, en algunos casos puede aparecer una alerta de seguridad al momento de realizar la instalación. En tal caso, se debe hacer clic en 'Más detalles' para continuar con el proceso

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%203.png)

Una vez que se haya hecho clic en 'Más detalles', se debe seleccionar la opción de 'Instalar de todas formas' para continuar con la instalación de la aplicación.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%204.png)

Con los pasos previos completados, ahora es posible visualizar la aplicación en el dispositivo.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%205.png)

Para comprobar su funcionamiento, se realizará una prueba añadiendo cualquier texto y haciendo clic en el botón 'Check'. Como se espera, el resultado muestra que el texto ingresado no es correcto.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%206.png)

Sin embargo, al ingresar la cadena de texto 'poorly-protected-secret', se puede completar el reto y obtener una respuesta afirmativa por parte de la aplicación.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%207.png)

Para la segunda parte del reto, se nos pide modificar la aplicación para cambiar el secreto. Para llevar a cabo esta tarea, se utilizará la herramienta apktool para descompilar la aplicación. Se usará el comando `apktool d crackme-one.apk -o crackme-oneModified`, donde se emplea la opción 'd' para descompilar la aplicación, se escribe el nombre de la aplicación y se agrega la opción '-o' seguida del nombre que se quiere para la carpeta donde se creará la aplicación descompilada.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%208.png)

A continuación, se procede a abrir el proyecto utilizando un editor de texto como [Sublime Text](https://www.sublimetext.com/3), que permite visualizar la aplicación descompilada y hacer las modificaciones necesarias. En este caso, se busca el archivo ChallengeOneFragmentOnClickListener.smali para encontrar el secreto, que se encuentra en la línea 80.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%209.png)

Se identifica que el secreto también se encuentra en la línea 244 del archivo ChallengeOneFragmentOnClickListener.smali, la cual se ubica en una segunda sección que fue revisada.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2010.png)

Se decide modificar los datos correspondientes en ambas líneas, para lo cual se utiliza la frase be_hacker_pro como sustituto del secreto original.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2011.png)

Una vez realizados los cambios necesarios en la aplicación, se procede a guardar el archivo.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2012.png)

Después de haber modificado el archivo con la frase "be_hacker_pro", se procede a compilar la aplicación con los cambios realizados. Para llevar a cabo esto, se utiliza la herramienta apktool con el comando **`apktool b crackme-oneModified -o crackme-oneNew.apk`**. En este caso, el parámetro 'b' indica que se va a compilar la aplicación, mientras que '-o' se utiliza para especificar el nombre del archivo de salida.

Una vez finalizado el proceso de compilación, se genera un nuevo archivo con el nombre especificado. Este archivo puede ser instalado en un dispositivo Android de la misma manera que se hizo con la aplicación original. Con estos cambios, la aplicación ahora utilizará la nueva cadena de texto como secreto para el reto.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2013.png)

Si se intenta instalar la aplicación en este momento, se mostrará un error ya que la aplicación no está firmada.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2014.png)

Para firmar la aplicación, se utiliza la herramienta  [uber  apk, signer](https://github.com/patrickfav/uber-apk-signer/releases/tag/v1.3.0) . El comando para firmar la nueva aplicación es: `java -jar uber-apk-signer-1.3.0.jar --apks crackme-oneNew.apk` Este comando exporta una nueva aplicación firmada y se puede instalar en el dispositivo.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2015.png)

La nueva aplicación creada, llamada crackme-oneNew-aligned-debugSigned.apk, debe ser instalada para comprobar si las modificaciones que se hicieron funcionan correctamente. Para realizar la instalación se puede utilizar la herramienta adb y ejecutar el comando **`adb install crackme-oneNew-aligned-debugSigned.apk`**

Luego de instalar la aplicación, se debe verificar si aparece la misma alerta de seguridad que en la aplicación original y se debe hacer clic en "más detalles".

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2016.png)

Y se da clic en "Instalar de todas formas".

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2017.png)

Se observa que la aplicación carga, ahora se debe comprobar que los cambios realizados en la aplicación se encuentran presentes en la nueva versión instalada.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2018.png)

Ahora al poner el nuevo secreto be_hacker_pro la aplicación indica que el reto ha sido completado.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2019.png)

---

# CRACKME-ONE.APK

Reto: Encontrar las credenciales que se encuentran almacenadas en la aplicación 

La aplicación será cargada en la herramienta jadx para revisar su código y se observa que hace una llamada a una clase de listeners.

Se observa un código muy similar al reto anterior, lo que permite deducir que se debe dirigir la atención hacia los listeners

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2020.png)

Al revisar las clases de listeners, se puede observar una condición que aparentemente captura lo que se ingresa en una caja de texto y lo compara con las credenciales almacenadas en la aplicación para confirmar esto. Para verificar esta funcionalidad, será necesario instalar la aplicación.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2021.png)

Para realizar esto, se necesitará tener activo un emulador o un dispositivo conectado al equipo. Utilizando la herramienta ADB, se puede verificar si hay dispositivos conectados mediante el comando `adb devices`. Así se podrá confirmar si el equipo está conectado correctamente.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2022.png)

Luego, con la misma herramienta, se procede a instalar la aplicación utilizando el comando `adb install crackme-one.apk` Sin embargo, en algunos casos puede aparecer una alerta de seguridad al momento de realizar la instalación. En tal caso, se debe hacer clic en 'Más detalles' para continuar con el proceso

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2023.png)

Una vez que se haya hecho clic en 'Más detalles', se debe seleccionar la opción de 'Instalar de todas formas' para continuar con la instalación de la aplicación.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2024.png)

Con los pasos previos completados, ahora es posible visualizar la aplicación en el dispositivo.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2025.png)

Ahora se debe comprobar los datos encontrados almacenados en la aplicación, pero el secreto parece estar encriptado con un hash. Para descifrarlo, se utilizará la herramienta en línea [crackstation.net](https://crackstation.net/) , la cual permite realizar una descifrado rápido de varios tipos de hash.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2026.png)

Para utilizar la herramienta, se debe hacer clic en "No soy un robot" y luego en "Crack Hashes". Como resultado de este reto, se obtiene la clave secreta en texto plano "zipdrive”

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2027.png)

Cuando se ingresa una contraseña incorrecta, no se muestra ningún mensaje de error.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2028.png)

Sin embargo, cuando se ingresa un correo electrónico incorrecto, el sistema muestra un mensaje de error indicando que la combinación de correo electrónico y contraseña es incorrecta.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2029.png)

Después de ingresar los datos correctos, se muestra un mensaje que advierte sobre los peligros de dejar código en modo de depuración en la aplicación.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2030.png)

Para la segunda parte del reto, se nos pide modificar la aplicación para cambiar el secreto. Para llevar a cabo esta tarea, se utilizará la herramienta apktool para descompilar la aplicación. Se usará el comando `apktool d crackme-two.apk -o crackme-twoModified`, donde se emplea la opción 'd' para descompilar la aplicación, se escribe el nombre de la aplicación y se agrega la opción '-o' seguida del nombre que se quiere para la carpeta donde se creará la aplicación descompilada.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2031.png)

A continuación, se procede a abrir el proyecto utilizando un editor de texto como [Sublime Text](https://www.sublimetext.com/3), que permite visualizar la aplicación descompilada y hacer las modificaciones necesarias. En este caso, se busca el archivo ChallengeTwoFragmentOnClickListener.smali para encontrar el secreto, que se encuentra en la línea 124.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2032.png)

Se identifica que el secreto también se encuentra en la línea 206 del archivo ChallengeTwoFragmentOnClickListener.smali, la cual se ubica en una segunda sección que fue revisada.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2033.png)

Ahora se procederá a cambiar la clave secreta utilizando la frase "be_hacker_pro". Sin embargo, para este reto es necesario realizar un paso adicional, que consiste en convertir esta frase a MD5. Para hacerlo, se utilizará la herramienta en línea [md5online.org](https://www.md5online.org/md5-encrypt.html).

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2034.png)

Luego, se procede a cambiar el MD5 almacenado en la aplicación con el que se acaba de crear, en ambas líneas, comenzando por la línea 124.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2035.png)

inalmente, se completa el proceso de cambio de MD5 en la aplicación modificando también la línea 206.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2036.png)

También es posible cambiar el correo electrónico que actualmente tiene el valor manager@corp.net

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2037.png)

En este caso, se modificará el correo electrónico en la aplicación, reemplazando "**manager@corp.net**" por "**angussmoody@behacker.pro**"

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2038.png)

Después de haber modificado el archivo con la frase "be_hacker_pro", y el correo con "angussmoody@behacker.pro" se procede a compilar la aplicación con los cambios realizados. Para llevar a cabo esto, se utiliza la herramienta apktool con el comando **`apktool b crackme-twoModified -o crackme-twoNew.apk`**. En este caso, el parámetro 'b' indica que se va a compilar la aplicación, mientras que '-o' se utiliza para especificar el nombre del archivo de salida.

Una vez finalizado el proceso de compilación, se genera un nuevo archivo con el nombre especificado. Este archivo puede ser instalado en un dispositivo Android de la misma manera que se hizo con la aplicación original. Con estos cambios, la aplicación ahora utilizará la nueva cadena de texto como secreto para el reto.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2039.png)

Si se intenta instalar la aplicación en este momento, se mostrará un error ya que la aplicación no está firmada, igual que revisamos en el primer reto.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2040.png)

Para firmar la aplicación, se utiliza la herramienta  [uber  apk, signer](https://github.com/patrickfav/uber-apk-signer/releases/tag/v1.3.0) . El comando para firmar la nueva aplicación es: `java -jar uber-apk-signer-1.3.0.jar --apks crackme-twoNew.apk` Este comando exporta una nueva aplicación firmada y se puede instalar en el dispositivo.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2041.png)

La nueva aplicación creada, llamada crackme-twoNew-aligned-debugSigned.apk, debe ser instalada para comprobar si las modificaciones que se hicieron funcionan correctamente. Para realizar la instalación se puede utilizar la herramienta adb y ejecutar el comando **`adb install crackme-twoNew-aligned-debugSigned.apk`**

Luego de instalar la aplicación, se debe verificar si aparece la misma alerta de seguridad que en la aplicación original y se debe hacer clic en "más detalles".

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2042.png)

Y se da clic en "Instalar de todas formas".

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2043.png)

Se observa que la aplicación carga, ahora se debe comprobar que los cambios realizados en la aplicación se encuentran presentes en la nueva versión instalada.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2044.png)

Ahora al poner el nuevo email angussmoody@behacker.pro y el secreto be_hacker_pro la aplicación indica que el reto ha sido completado.

![Untitled](/assets/images/2023-04-09-Crackmes_Android/Untitled%2045.png)