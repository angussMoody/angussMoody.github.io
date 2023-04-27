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

Para iniciar con pruebas a aplicaciones Android, lo primero que se necesita es tener el laboratorio con ciertas herramientas

 [Python3](https://angussmoody.github.io/android/Herramientas/#instalaci%C3%B3n-python3) 

[Genymotion](https://angussmoody.github.io/android/Herramientas/#instalaci%C3%B3n-genymotion)

[Frida](https://angussmoody.github.io/android/Herramientas/#instalaci%C3%B3n-frida) 

[jadx-gui](https://angussmoody.github.io/android/Herramientas/#instalaci%C3%B3n-jadx-gui)

[apktool](https://angussmoody.github.io/android/Herramientas/#instalaci%C3%B3n-apktool)

[Split App Share & install](https://angussmoody.github.io/android/Herramientas/#instalaci%C3%B3n-split-app-share--install)

[Total commander](https://angussmoody.github.io/android/Herramientas/#instalaci%C3%B3ntotal-commander)

[ADB y Otras Herramientas](https://angussmoody.github.io/android/Herramientas/#instalaci%C3%B3n-adb-y-otras-herramientas)

# Instalación Python3

para realizar la instalación se descarga el ejecutable de  [python.org](https://www.python.org/downloads/) 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled.png)

Se lleva a cabo la instalación de manera normal.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%201.png)

Una vez finalizada la instalación, se ejecuta el comando **`python --version`** en la terminal para comprobar la instalación de éste 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%202.png)

También es necesario verificar si se tiene instalado pip, lo cual se puede hacer utilizando el siguiente comando: **`pip3 --version`**

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%203.png)

---

# Instalación Genymotion

Se descarga el ejecutable desde [genymotion.com](https://www.genymotion.com/download/) e realiza la instalación y se crea una cuenta para el acceso al servicio.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%204.png)

El binario se instala como cualquier otro programa y, la primera vez que se utiliza, es necesario crear una cuenta.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%205.png)

Después de crear la cuenta, es posible ejecutar la herramienta y crear un dispositivo.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%206.png)

En este caso se ha seleccionado la opción "Personal Use". Sin embargo, si se dispone de una licencia, se debe seleccionar "I have a license" y luego hacer clic en "NEXT".

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%207.png)

Se deben aceptar los términos y luego hacer clic en "NEXT".

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%208.png)

Con estos pasos ya completados, el emulador ha sido instalado y se encuentra listo para su uso.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%209.png)

Ahora es posible hacer clic en el icono "+" y agregar un dispositivo. En este caso, se va a crear un emulador de Samsung Galaxy S7, se debe seleccionar esta opción y luego hacer clic en "NEXT".

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2010.png)

Es necesario asignar un nombre al emulador. En este caso, se ha decidido dejar el nombre por defecto y luego hacer clic en "NEXT".

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2011.png)

Se solicitan las características del sistema. Para este ejemplo, se ha decidido dejar las opciones por defecto y hacer clic en "NEXT".

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2012.png)

Ahora se solicitan las opciones de pantalla. De nuevo, se ha decidido dejar las opciones por defecto y hacer clic en "NEXT".

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2013.png)

Se debe realizar el mismo procedimiento que en los pasos anteriores, dejando las opciones por defecto y seleccionando "NAT". Luego, se puede hacer clic en "INSTALAR" para finalizar el proceso.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2014.png)

Una vez instalado, el emulador debería aparecer de la siguiente manera. Ahora, solo es necesario hacer clic en el botón de "play" para iniciar el emulador.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2015.png)

Una vez iniciado el dispositivo emulado, este estará listo para ser utilizado.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2016.png)

---

# Instalación Frida

Para instalar las herramientas de Frida en la máquina, se debe ejecutar el siguiente comando: **`pip3 install frida-tool`** Esto permitirá la instalación de las herramientas de Frida en la máquina para su uso posterior.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2017.png)

Para instalar Frida en el dispositivo emulado, es necesario conocer la arquitectura que se está utilizando en el dispositivo.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2018.png)

Se debe copiar la ruta correspondiente a la carpeta donde se encuentra instalado el archivo "frida-server". Luego, se debe crear una nueva variable de entorno en el sistema.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2019.png)

Para crear una nueva variable de entorno, se debe copiar la ruta correspondiente a la carpeta donde se encuentra instalado el archivo "frida-server". Luego, se procede a crear la nueva variable de entorno en el sistema.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2020.png)

Seleccionar Path y dar clic en editar 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2021.png)

Se le da clic en nuevo y se pega la ruta que tenían copiada.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2022.png)

Y para finalizar, se le da clic en "aceptar" en todas las ventanas emergentes.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2023.png)

ahora con el comando **`adb deevices`** se puede comprobar que la ruta ya se encuentra como variable de entorno y se pueden ver los dispositivos que estén conectados y emulados en el host.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2024.png)

Se ingresa al equipo mediante el uso del comando  **`adb shell`  Luego, se verifica la arquitectura del dispositivo utilizando el comando `uname -m`** Este último comando muestra la arquitectura del dispositivo.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2025.png)

Ya teniendo la arquitectura, se procede a instalar el servidor de Frida correspondiente en el dispositivo. Este servidor se puede encontrar en los[releases de github](https://github.com/frida/frida/releases) en este caso el de x86

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2026.png)

En este caso, se debe extraer el archivo descargado del servidor de Frida y, posteriormente, renombrarlo como "frida-server". De esta forma, se facilita la gestión y utilización del servidor en el dispositivo correspondiente.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2027.png)

Ahora se va a pasar el archivo al dispositivo utilizando el comando  **`adb push frida-server /data/local/tmp/` En la ruta indicada, es posible comprobar que se cuenta con los permisos necesarios para subir archivos. Una vez se sube el archivo, se puede verificar si se encuentra en la ruta indicada utilizando el comando  `adb shell`  y navegando hasta la ruta  /data/local/tmp** 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2028.png)

Ahora, dentro del dispositivo se le dan los permisos de ejecución y se ejecuta el frida en segundo plano

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2029.png)

Se comprueba que el servidor de frida esté corriendo correctamente con el comando **`frida-ps -Uai`** desde otra terminal, para ver las aplicaciones que están corriendo en el dispositivo.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2030.png)

---

# Instalación jadx-gui 

Para descargar el archivo.exe de los releases de [jadx en Github](https://github.com/skylot/jadx/releases), se debe ir a la sección de releases en la página del repositorio y seleccionar la versión deseada. Luego, se debe descargar el archivo.exe correspondiente.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2031.png)

Al ejecutar el archivo.exe descargado desde los releases de jadx en GitHub, es posible que aparezca una ventana solicitando permiso para continuar. En este caso, se debe hacer clic en "Mostrar más" para ver más detalles y luego seleccionar la opción "Ejecutar de todas formas" para permitir que se ejecute el programa.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2032.png)

Una vez que se ha permitido la ejecución del archivo.exe de jadx descargado desde los releases de GitHub y se ha iniciado la aplicación, se puede comprobar que funciona correctamente y sin problemas.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2033.png)

Se procederá a crear una nueva variable de entorno con el fin de poder invocar la herramienta desde la terminal. Para ello, se agregará la ruta del archivo ejecutable al PATH del sistema. Con esto se logrará que la herramienta jadx pueda ser llamada desde cualquier ubicación en la terminal sin necesidad de encontrarse en el directorio donde se encuentra el archivo ejecutable.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2034.png)

---

# Instalación apktool

Se procede a acceder a la página de instalación de Apktool, disponible en [aptktool](https://ibotpeaches.github.io/Apktool/install/)  la cual brinda una guía paso a paso para la instalación del programa en diferentes sistemas operativos. Para el caso específico de Windows, es importante asegurarse de contar con el archivo apktool.bat en la ruta de instalación, ya que este archivo es necesario para la ejecución del programa. Dicho archivo se encuentra disponible para su descarga en el sitio web de Apktool.


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

Una vez que se ha verificado la existencia del archivo apktool.bat, se debe descargar el archivo [apktool_X.X.X.jar](https://bitbucket.org/iBotPeaches/apktool/downloads/) correspondiente a la versión deseada desde. Una vez descargado el archivo, es necesario renombrarlo como apktool.jar para poder utilizarlo adecuadamente en la instalación del programa.


![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2035.png)

Una vez renombrado el archivo apktool_X.X.X.jar como apktool.jar, es recomendable agregar la ruta del directorio donde se encuentra ubicado este archivo a las variables de entorno del sistema, para poder llamar el programa desde cualquier ubicación en la terminal. Sin embargo, ya se ha agregado el directorio correspondiente durante la instalación anterior del [jadx-gui](https://angussmoody.github.io/android/Herramientas/#instalaci%C3%B3n-jadx-gui)  por lo que se puede proceder a comprobar si es posible llamar al programa desde una CMD mediante el comando **`apktool`** De esta manera, se puede verificar que la herramienta Apktool se encuentra correctamente instalada y configurada en el sistema.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2036.png)

---

# Instalación Split App Share & install

Esta herramienta permite la exportación de aplicaciones instaladas en un dispositivo en formato APK.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2037.png)

Se debe ejecutar la herramienta y seleccionar la aplicación deseada para luego hacer clic en el botón de Exportar (Export).

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2038.png)

Este paso exporta el apk o apks que tenga la aplicación

---

# InstalaciónTotal Commander

La herramienta permite pasar archivos desde el host principal al emulador y viceversa. El instalador se descarga desde su  [página principal](https://www.ghisler.com/download.htm)  Una vez instalada, la herramienta aparece de esta manera.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2039.png)

Se descarga el plugin desde [plugin](https://totalcmd.net/plugring/android_adb.html) para conectar Total Commander al dispositivo móvil a través de adb. Una vez descargado, se descomprime el archivo.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2040.png)

Para cargar el plugin en la herramienta, se accede a Configuración -> Opciones.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2041.png)

A continuación, se selecciona la pestaña de Complementos y se hace clic en Configurar en la opción .WFX

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2042.png)

Luego, se hace clic en el botón de "Añadir" y se navega hasta la ruta en la que se descomprimió el plugin. Se selecciona el plugin y se hace clic en "Aceptar" para cargarlo en la herramienta

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2043.png)

Después, se busca el dispositivo en la sección ADB en Total Commander

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2044.png)

A continuación, se selecciona el dispositivo encontrado.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2045.png)

Una vez seleccionado el dispositivo, se pueden arrastrar y soltar archivos entre los dispositivos para transferirlos según sea necesario

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2046.png)

---

# Instalación ADB y Otras Herramientas

Para descargar las herramientas de plataforma de Android, se accede al enlace [Herramientas](https://dl.google.com/android/repository/platform-tools-latest-windows.zip)y se descomprime en la carpeta especificada en las variables de entorno. Luego, se ejecuta ADB para confirmar que se ha cargado correctamente.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2047.png)