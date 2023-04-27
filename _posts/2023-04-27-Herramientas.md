---
layout: single
title: Herramientas Laboratorio Android
comments: true
excerpt: "Herramientas Laboratorio Android"
date: 2023-04-11
classes: wide
header:
  teaser: /assets/images/2023-04-27-Herramientas/logo.jpg
  teaser_home_page: true
categories:
  - Android
tags:
  - Android
  - Herramientas
  - Genymotion
  - adb
---

Lo primero que vamos a hacer es crearnos nuestro laboratorio para realizar las pruebas, para esto vamos a necesitas unas Herramientas

 [Python3](Herramientas%20Laboratorio%20Android%208ef73abc8eab4902be50123935d3ce56.md) 

[Genymotion](Herramientas%20Laboratorio%20Android%208ef73abc8eab4902be50123935d3ce56.md)

[Frida](Herramientas%20Laboratorio%20Android%208ef73abc8eab4902be50123935d3ce56.md) 

[jadx-gui](Herramientas%20Laboratorio%20Android%208ef73abc8eab4902be50123935d3ce56.md)

[apktool](Herramientas%20Laboratorio%20Android%208ef73abc8eab4902be50123935d3ce56.md)

[Split App Share & install](Herramientas%20Laboratorio%20Android%208ef73abc8eab4902be50123935d3ce56.md)

[Total commander](Herramientas%20Laboratorio%20Android%208ef73abc8eab4902be50123935d3ce56.md)

[ADB y Otras Herramientas](Herramientas%20Laboratorio%20Android%208ef73abc8eab4902be50123935d3ce56.md)

Instalación Python3

para realizar la instalación nos descargamos el ejecutable de  [python.org](https://www.python.org/downloads/) 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled.png)

Realizamos la instalación normal 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%201.png)

y una vez terminado ejecutamos **`python --version`** en la terminal para comprobar la instalación de éste 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%202.png)

También debemos comprobar que tengamos pip instalado, lo podemos hacer con el comando **`pip3 --version`**

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%203.png)

---

Instalación Genymotion

Nos descargamos el ejecutable desde [genymotion.com](https://www.genymotion.com/download/) lo instalamos y nos creamos una cuenta 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%204.png)

Instalamos el binario como cualquier otro programa y la primera vez que lo utilicemos, debemos  crearnos una cuenta 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%205.png)

Una vez creada la cuenta podemos ejecutar esta Herramienta y crearnos un  dispositivo

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%206.png)

En mi caso selecciono la opción Personal Use, pero si tienen una licencia, seleccionar, I hace a license y dar clic en NEXT

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%207.png)

Aceptamos los términos y damos clic en NEXT

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%208.png)

Ya con estos pasos, tenemos nuestro emulador instalado

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%209.png)

Ya podemos dar clic en el icono de + y agregar un dispositivo, para este caso voy a crear un emulador de Samsung Galaxy S7, lo seleccionamos y damos clic en NEXT

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2010.png)

le ponemos un nombre al emulador, en este caso lo voy a dejar como viene por defecto y le damos clic en NEXT

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2011.png)

Nos pide las carácteristicas del sistema, para este ejemplo, también lo dejaré como viene por defecto y  dar clic en NEXT

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2012.png)

Nos pide las opciones del display, nuevamente, lo tomo como viene por defecto y doy clic en NEXT

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2013.png)

Realizo el mismo procedimiento que con los otros y lo dejamos por defecto en NAT y damos clic en instalar

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2014.png)

Una vez instalado, nos queda de esta manera, ahora solo debemos dar clic en el boton de play, para iniciar el emulador 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2015.png)

y ya tenemos nuestro dispositivo emulado

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2016.png)

---

Instalación Frida

y ahora vamos a instalar las herramientas de frida con el comando **`pip3 install frida-tool`** para instalar las herramientas en nuestra máquina

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2017.png)

Ahora vamos a instalar el frida para el dispositivo, para esto debemos saber la arquitectura que maneja éste 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2018.png)

Nos copiamos esta ruta y vamos a crear una nueva variable de entorno 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2019.png)

Vamos a donde dice Variables de entorno 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2020.png)

Seleccionamos Path y le damos en editar 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2021.png)

Le damos clic en nuevo y pegamos la ruta que teníamos copiada

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2022.png)

y para finalizar le damos clic en aceptar en todas las ventanas emergentes

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2023.png)

ahora con el comando **`adb deevices`** podemos comprobar que ya esta ruta está como variable de entorno y podemos ver los equipos que estén conectados y emulados en el host

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2024.png)

Vamos a ingresar a este equipo para ver su arquitectura  con el comando **`adb shell` y con el comando `uname -m`** podemos ver su arquitectura 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2025.png)

ya teniendo la arquitectura vamos a instalarnos en ese dispositivo el frida server que podemos encontrar en los [releases de github](https://github.com/frida/frida/releases) en este caso el de x86

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2026.png)

Extraemos el archivo y lo renombramos en este caso como frida-server

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2027.png)

Ahora nos vamos a pasar este archivo al dispositivo para esto lo vamos a hacer con el comando **`adb push frida-server /data/local/tmp/` donde tenemos permisos, una vez lo subimos podemos comprobar que el archivo si esté en la ruta indicada, en este caso con el comando `adb shell`  y nos vamos a la ruta indicada /data/local/tmp** 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2028.png)

Ahora dentro del dispositivo vamos a darle los permisos de ejecución y ejecutamos el frida en segundo plano 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2029.png)

Comprobamos que el frida server esté corriendo correctamente con el comando **`frida-ps -Uai`** desde otra terminal para ver las aplicaciones que están corriendo en el dispositivo 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2030.png)

---

Instalar jadx-gui 

para esto vamos a ir a los releases de [jadx en Github](https://github.com/skylot/jadx/releases) y nos descargamos el archivo.exe

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2031.png)

Lo ejecutamos para probarlo y nos pide un permiso, le damos en mostrar más y luego en ejecutar de todas formas 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2032.png)

y ya con esto podemos ver que la aplicación corre sin ningún problema 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2033.png)

Vamos a crear una nueva variable de entorno donde tenemos esta herramienta para poderla llamar desde la terminal 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2034.png)

---

Instalar apktool

Vamos a la página de instalación de [aptktool](https://ibotpeaches.github.io/Apktool/install/) donde nos da un paso a paso de lo que debemos hacer en cada sistema, para este caso lo estamos haciendo desde windows

lo primero que debemos hacer es tener el archivo apktool.bat

```csharp
@echo off
setlocal
set BASENAME=apktool_
chcp 65001 2>nul >nul

set java_exe=java.exe

if defined JAVA_HOME (
set "java_exe=%JAVA_HOME%\bin\java.exe"
)

rem Find the highest version .jar available in the same directory as the script
setlocal EnableDelayedExpansion
pushd "%~dp0"
if exist apktool.jar (
    set BASENAME=apktool
    goto skipversioned
)
set max=0
for /f "tokens=1* delims=-_.0" %%A in ('dir /b /a-d %BASENAME%*.jar') do if %%~B gtr !max! set max=%%~nB
:skipversioned
popd
setlocal DisableDelayedExpansion

rem Find out if the commandline is a parameterless .jar or directory, for fast unpack/repack
if "%~1"=="" goto load
if not "%~2"=="" goto load
set ATTR=%~a1
if "%ATTR:~0,1%"=="d" (
    rem Directory, rebuild
    set fastCommand=b
)
if "%ATTR:~0,1%"=="-" if "%~x1"==".apk" (
    rem APK file, unpack
    set fastCommand=d
)

:load
"%java_exe%" -jar -Duser.language=en -Dfile.encoding=UTF8 "%~dp0%BASENAME%%max%.jar" %fastCommand% %*

rem Pause when ran non interactively
for /f "tokens=2" %%# in ("%cmdcmdline%") do if /i "%%#" equ "/c" pause
```

luego debemos descargar el [apktool_X.X.X.jar](https://bitbucket.org/iBotPeaches/apktool/downloads/)  con la versión que deseemos, pero una vez descargado lo vamos a renombrar como apktool.jar 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2035.png)

y ahora nos recomienda pasarlo al directorio c:\Windows o agregar el directorio donde lo tenemos a las variables de entorno, en ese caso este directorio ya lo tenemos agregado en la instalación anterior del [jadx-gui](https://www.notion.so/Android-ac00e5d9238c43419eaf73b0a97149ca)  ahora debemos comprobar que si podamos realizar el llamado desde una CMD con el comando **`apktool`**

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2036.png)

---

## Split App Share & install

Esta herramienta nos sirve para exportar en apk las aplicaciones que tengamos instaladas en nuestro dispositivo 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2037.png)

Ahora solo debemos ejecutar la ejecutamos y seleccionamos la aplicación que deseamos y damos en Export

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2038.png)

Y esto nos exportará el apk o las apks que tenga nuestra aplicación.

---

## Total Commander

Esta herramienta nos permite pasar archivos desde nuestro host principal a nuestro emulador y viceversa nos descargamos el instalador desde su [página principal](https://www.ghisler.com/download.htm)  un vez instalada nos debe salir de esta manera 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2039.png)

- descargamos el [plugin](https://totalcmd.net/plugring/android_adb.html) para que total commander se conecte a nuestro dispotivio movil desde adb , una vez descargado lo descomprimimos

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2040.png)

Ahora debemos cargar el plugin a nuestra herramienta, para eso vamos a configuración - opciones

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2041.png)

Luego vamos a complementos y damos clic en Configurar en la opción que dice .WFX

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2042.png)

Damos clic en añadir y luego vamos hasta la ruta donde descomprimimos el plugin, lo cargamos y damos clic en aceptar 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2043.png)

Ahora vamos donde dice ADB y buscamos nuestro dispositivo 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2044.png)

lo seleccionamos 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2045.png)

ya podemos arrastrar entre dispositivos los archivos que necesitemos 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2046.png)

---

ADB y Otras Herramientas

Nos las descargamos desde este [link](https://dl.google.com/android/repository/platform-tools-latest-windows.zip) y la descomprimimos en nuestra carpeta que tenemos en las variables de entorno y corremos el adb para ver si este nos carga

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2047.png)