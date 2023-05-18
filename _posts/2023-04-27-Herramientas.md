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

[DB Browser for SQLite](https://angussmoody.github.io/android/Herramientas/#db-browser-for-sqlite)

[Requerimientos previos para Mobile Security Framework (MobSF)](https://angussmoody.github.io/android/Herramientas/#requerimientos-previos-para-mobsf)

- [Instalación Git](https://angussmoody.github.io/android/Herramientas/#instalaci%C3%B3n-git)
- [Instalar JDK 8+](https://angussmoody.github.io/android/Herramientas/#instalar-jdk-8)
- [Instalación Microsoft Visual C++ Build Tools](https://angussmoody.github.io/android/Herramientas/#instalaci%C3%B3n-microsoft-visual-c-build-tools)
- [Instalación OpenSSL (non-light)](https://angussmoody.github.io/android/Herramientas/#instalaci%C3%B3n-openssl-non-light)
- [Instalación wkhtmltopdf](https://angussmoody.github.io/android/Herramientas/#instalaci%C3%B3n-wkhtmltopdf)
- [Instalación Mobile Security Framework (MobSF)](https://angussmoody.github.io/android/Herramientas/#instalaci%C3%B3n-mobile-security-framework-mobsf)

# Instalación Python3

para realizar la instalación se descarga el ejecutable de  [python.org](https://www.python.org/downloads/) 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled.png)

Se lleva a cabo la instalación de manera normal.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%201.png)

Una vez finalizada la instalación, se ejecuta el comando `python --version` en la terminal para comprobar la instalación de éste 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%202.png)

También es necesario verificar si se tiene instalado pip, lo cual se puede hacer utilizando el siguiente comando: `pip3 --version`

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

Para instalar las herramientas de Frida en la máquina, se debe ejecutar el siguiente comando: `pip3 install frida-tool` Esto permitirá la instalación de las herramientas de Frida en la máquina para su uso posterior.

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

ahora con el comando `adb deevices` se puede comprobar que la ruta ya se encuentra como variable de entorno y se pueden ver los dispositivos que estén conectados y emulados en el host.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2024.png)

Se ingresa al equipo mediante el uso del comando  `adb shell`  Luego, se verifica la arquitectura del dispositivo utilizando el comando `uname -m` Este último comando muestra la arquitectura del dispositivo.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2025.png)

Ya teniendo la arquitectura, se procede a instalar el servidor de Frida correspondiente en el dispositivo. Este servidor se puede encontrar en los[releases de github](https://github.com/frida/frida/releases) en este caso el de x86

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2026.png)

En este caso, se debe extraer el archivo descargado del servidor de Frida y, posteriormente, renombrarlo como "frida-server". De esta forma, se facilita la gestión y utilización del servidor en el dispositivo correspondiente.

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2027.png)

Ahora se va a pasar el archivo al dispositivo utilizando el comando  `adb push frida-server /data/local/tmp/` En la ruta indicada, es posible comprobar que se cuenta con los permisos necesarios para subir archivos. Una vez se sube el archivo, se puede verificar si se encuentra en la ruta indicada utilizando el comando  `adb shell`  y navegando hasta la ruta  /data/local/tmp 

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2028.png)

Ahora, dentro del dispositivo se le dan los permisos de ejecución y se ejecuta el frida en segundo plano

![Untitled](/assets/images/2023-04-27-Herramientas/Untitled%2029.png)

Se comprueba que el servidor de frida esté corriendo correctamente con el comando `frida-ps -Uai` desde otra terminal, para ver las aplicaciones que están corriendo en el dispositivo.

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

Una vez renombrado el archivo apktool_X.X.X.jar como apktool.jar, es recomendable agregar la ruta del directorio donde se encuentra ubicado este archivo a las variables de entorno del sistema, para poder llamar el programa desde cualquier ubicación en la terminal. Sin embargo, ya se ha agregado el directorio correspondiente durante la instalación anterior del [jadx-gui](https://angussmoody.github.io/android/Herramientas/#instalaci%C3%B3n-jadx-gui)  por lo que se puede proceder a comprobar si es posible llamar al programa desde una CMD mediante el comando `apktool` De esta manera, se puede verificar que la herramienta Apktool se encuentra correctamente instalada y configurada en el sistema.

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

# DB Browser for SQLite

Se descarga la aplicación DB Browser for SQLite desde su [sitio web](https://sqlitebrowser.org/dl/) y se selecciona la versión adecuada para el sistema operativo en uso. En este caso, se opta por descargar la instalación estándar, aunque también se podría elegir la versión portable si se desea.

![Untitled](/assets/images/2023-04-27-Herramientas/11.png)

Una vez descargado el archivo de instalación, se ejecuta el binario y se hace clic en Next.

![Untitled](/assets/images/2023-04-27-Herramientas/12.png)

Se aceptan los términos y condiciones de la aplicación y se hace clic en Next.

![Untitled](/assets/images/2023-04-27-Herramientas/13.png)

Se elige la configuración deseada y se hace clic en Next.

![Untitled](/assets/images/2023-04-27-Herramientas/14.png)

Se selecciona la ruta de instalación deseada para la aplicación. En este caso, se decide dejar la ruta por defecto y se hace clic en Next.

![Untitled](/assets/images/2023-04-27-Herramientas/15.png)

Se hace clic en Install para iniciar el proceso de instalación de la herramienta.

![Untitled](/assets/images/2023-04-27-Herramientas/16.png)

Finalmente, se hace clic en Finish para completar la instalación de la herramienta.

![Untitled](/assets/images/2023-04-27-Herramientas/17.png)


# Requerimientos previos para MobSF

Se realizará una instalación de los requerimientos necesarios para la instalación de la Herramienta MobSF (se recomienda tener python en la versión 3.9).

# Instalación Git

En este ejemplo, se realiza una instalación de los requerimientos necesarios para la Herramienta MobSF desde el sistema operativo Windows. Puedes descargar el binario correspondiente en el siguiente [enlace](https://git-scm.com/download/win), eligiendo la opción de 64 bits.

![Untitled](/assets/images/2023-04-27-Herramientas/18.png)

1. Una vez descargado, ejecutas el binario, el cual muestra los términos y condiciones. Haces clic en "Next" para continuar.

![Untitled](/assets/images/2023-04-27-Herramientas/19.png)

A continuación, se te solicita la ruta de instalación de la herramienta. Seleccionas la ruta deseada y haces clic en "Next".

![Untitled](/assets/images/2023-04-27-Herramientas/20.png)

1. Luego, seleccionar los componentes necesarios. En este caso, dejas los valores por defecto y haces clic en "Next".

![Untitled](/assets/images/2023-04-27-Herramientas/21.png)

Pide seleccionar el directorio del menú de inicio. En este caso, también dejarlo  por defecto y hacer clic en "Next".

![Untitled](/assets/images/2023-04-27-Herramientas/22.png)

Se solicita elegir un editor, y en este caso mantiener Vim como opción predeterminada.

![Untitled](/assets/images/2023-04-27-Herramientas/23.png)

Se pide seleccionar la rama de los repositorios. Para este caso, al necesitar solo la herramienta para la instalación de MobSF, se deja esta opción por defecto, permitiendo que la herramienta decida

![Untitled](/assets/images/2023-04-27-Herramientas/24.png)

A continuación, se solicita ajustar el PATH, seleccionando las opciones "Desde línea de comandos" y "Desde software de terceros".

![Untitled](/assets/images/2023-04-27-Herramientas/25.png)

Se pide seleccionar el ejecutable SSH, y se elige OpenSSH que viene incluido.

![Untitled](/assets/images/2023-04-27-Herramientas/26.png)

Se solicita seleccionar el transporte de HTTPs, eligiendo la biblioteca de OpenSSL.

![Untitled](/assets/images/2023-04-27-Herramientas/27.png)

A continuación, pide seleccionar la línea de los archivos de texto, seleccionando que se confirme la línea de comando al estilo Unix.

![Untitled](/assets/images/2023-04-27-Herramientas/28.png)

Se solicita seleccionar el terminal, dejando el que viene por defecto como el terminal predeterminado.

![Untitled](/assets/images/2023-04-27-Herramientas/29.png)

Seleccionar el comportamiento del git pull, dejándolo por defecto y haciendo clic en "Next".

![Untitled](/assets/images/2023-04-27-Herramientas/30.png)

Para esta pantalla, se pide seleccionar el asistente de credenciales, eligiendo el administrador de credenciales Git.

![Untitled](/assets/images/2023-04-27-Herramientas/31.png)

Se solicitan configuraciones extras, las cuales se dejan por defecto, seleccionando "Habilitar el almacenamiento en caché del sistema de archivos".

![Untitled](/assets/images/2023-04-27-Herramientas/32.png)

En la pantalla que indica "Configuración de opciones experimentales", no se selecciona nada y se da clic en "Install".

![Untitled](/assets/images/2023-04-27-Herramientas/33.png)

Una vez finalizada la instalación, se hace clic en "Finish" para terminar la instalación de esta herramienta.

![Untitled](/assets/images/2023-04-27-Herramientas/34.png)

---

# Instalar JDK 8+

Para realizar la instalación de JDK 8+ (Java Development Kit), se puede acceder al siguiente [enlace](https://adoptopenjdk.net/releases.html?variant=openjdk8&jvmVariant=hotspot) y seleccionar la versión requerida, como OpenJDK 8 (LTS).

![Untitled](/assets/images/2023-04-27-Herramientas/35.png)

bajar un poco para seleccionar la Opción señalada 

![Untitled](/assets/images/2023-04-27-Herramientas/36.png)

Luego, se dirige a otro [enlace](https://adoptium.net/es/temurin/releases/?version=8) donde se puede descargar el archivo en formato .zip o .msi, según las preferencias. En este ejemplo, se descargará el binario en .msi

![Untitled](/assets/images/2023-04-27-Herramientas/37.png)

Ejecutar el programa y hacer clic en "Siguiente".

![Untitled](/assets/images/2023-04-27-Herramientas/38.png)

n la siguiente pantalla, se pueden dejar las opciones por defecto y hacer clic en "Siguiente".

![Untitled](/assets/images/2023-04-27-Herramientas/39.png)

• Aparecerá una pantalla donde se debe hacer clic en "Instalar" para iniciar la instalación del componente.

![Untitled](/assets/images/2023-04-27-Herramientas/40.png)

Una vez finalizada la instalación, se mostrará una pantalla donde se debe hacer clic en "Finalizar".

![Untitled](/assets/images/2023-04-27-Herramientas/41.png)

---

# Instalación Microsoft Visual C++ Build Tools

Para esta herramienta, se puede descargar el binario desde el siguiente [enlace](https://visualstudio.microsoft.com/es/thank-you-downloading-visual-studio/?sku=BuildTools&rel=16) para proceder con la instalación.

![Untitled](/assets/images/2023-04-27-Herramientas/42.png)

Al ejecutar el binario, aparecerá una pantalla con los términos de licencia, donde se debe hacer clic en "Continuar".

![Untitled](/assets/images/2023-04-27-Herramientas/43.png)

La herramienta iniciará la descarga e instalación de manera automática.

![Untitled](/assets/images/2023-04-27-Herramientas/44.png)

Una vez finalizada la instalación, se mostrarán complementos que pueden ser útiles, pero para la Herramienta MobSF, se puede dejar la configuración por defecto y hacer clic en "Instalar".

![Untitled](/assets/images/2023-04-27-Herramientas/45.png)

La instalación se iniciará y el tiempo requerido dependerá de las especificaciones de cada equipo y la velocidad de conexión a internet del proveedor.

![Untitled](/assets/images/2023-04-27-Herramientas/46.png)

Una vez instalada, la herramienta deberá mostrarse de la siguiente manera, indicando que se ha completado la instalación de esta herramienta.

![Untitled](/assets/images/2023-04-27-Herramientas/47.png)

---

# Instalación OpenSSL (non-light)

Para instalar la biblioteca, es necesario dirigirse al siguiente [enlace](https://slproweb.com/products/Win32OpenSSL.html), el cual mostrará la siguiente pantalla.

![Untitled](/assets/images/2023-04-27-Herramientas/48.png)

Desplazarse hacia abajo y, como se mencionó anteriormente, para la instalación de estos complementos en el sistema operativo Windows, se debe descargar el ejecutable correspondiente.

![Untitled](/assets/images/2023-04-27-Herramientas/49.png)

Al ejecutar el binario es posible que aparezca un mensaje similar al siguiente. En ese caso, hacer clic en "Más Información”

![Untitled](/assets/images/2023-04-27-Herramientas/50.png)

En la siguiente pantalla, se ofrece la opción de ejecución. Hacer clic en "Ejecutar de todas formas".

![Untitled](/assets/images/2023-04-27-Herramientas/51.png)

Aceptar los términos y hacer clic en "Next".

![Untitled](/assets/images/2023-04-27-Herramientas/52.png)

Se solicitará la ruta de instalación para la biblioteca. Seleccionar la ruta deseada y hacer clic en "Next".

![Untitled](/assets/images/2023-04-27-Herramientas/53.png)

Se pedirá seleccionar el directorio de inicio. Se recomienda dejarlo por defecto y hacer clic en "Next".

![Untitled](/assets/images/2023-04-27-Herramientas/54.png)

Seleccionar la opción del directorio del sistema Windows y hacer clic en "Next".

![Untitled](/assets/images/2023-04-27-Herramientas/55.png)

Luego, hacer clic en "Install" para iniciar la instalación de la biblioteca.

![Untitled](/assets/images/2023-04-27-Herramientas/56.png)

Una vez finalizada la instalación, hacer clic en "Finish" para completar este requerimiento.

![Untitled](/assets/images/2023-04-27-Herramientas/57.png)

---

# Instalación wkhtmltopdf

Se procede a realizar la instalación de wkhtmltopdf . En este ejemplo, se descarga el ejecutable destinado al sistema operativo Windows en este [enlace](https://wkhtmltopdf.org/downloads.html), siguiendo el mismo enfoque utilizado para las herramientas anteriores.

![Untitled](/assets/images/2023-04-27-Herramientas/58.png)

Se ejecuta el binario y se hace clic en "I Agree" para aceptar los términos.

![Untitled](/assets/images/2023-04-27-Herramientas/59.png)

A continuación, se solicita la ruta de instalación para esta herramienta. Por defecto, se deja como está y se hace clic en "Install" para iniciar la instalación. 

![Untitled](/assets/images/2023-04-27-Herramientas/60.png)

Una vez finalizada la instalación, se hace clic en "Close".

![Untitled](/assets/images/2023-04-27-Herramientas/61.png)

Para el segundo paso, se coloca la ruta donde se instaló la herramienta como variable de entorno, copiar la ruta.

![Untitled](/assets/images/2023-04-27-Herramientas/62.png)

En el explorador de windows, se escriben las primeras letras de "variables" para que aparezca la opción de "Editar las variables de entorno del sistema". Se hace clic en dicha opción.

![Untitled](/assets/images/2023-04-27-Herramientas/63.png)

Aparece una ventana de "Propiedades del sistema". Se hace clic en "Variables de entorno".

![Untitled](/assets/images/2023-04-27-Herramientas/64.png)

Se selecciona la variable "Path" y se hace clic en "Editar".

![Untitled](/assets/images/2023-04-27-Herramientas/65.png)

En la ventana emergente, se pega la ruta que se copió previamente en la última línea y se hace clic en "Aceptar".

![Untitled](/assets/images/2023-04-27-Herramientas/66.png)

Se hace clic en "Aceptar" y se cierra la ventana de "Variables de entorno".

![Untitled](/assets/images/2023-04-27-Herramientas/67.png)

Se hace clic en "Aceptar" y se cierra la ventana de "Propiedades del sistema" de esta manera, se concluye la instalación de esta herramienta.

![Untitled](/assets/images/2023-04-27-Herramientas/68.png)

---

# Instalación Mobile Security Framework (MobSF)

Una vez que se tienen los requerimientos, se puede iniciar la instalación de MobSF. Para ello, se puede clonar el proyecto desde el siguiente [enlace](https://github.com/MobSF/Mobile-Security-Framework-MobSF) utilizando el comando `git clone https://github.com/MobSF/Mobile-Security-Framework-MobSF.git`

![Untitled](/assets/images/2023-04-27-Herramientas/69.png)

O se puede descargar el proyecto en formato .zip haciendo clic en "<>Code" y luego en "Download ZIP".

![Untitled](/assets/images/2023-04-27-Herramientas/70.png)

Luego, se ingresa al directorio que se crea utilizando el comando `cd Mobile-Security-Framework-MobSF` y se puede confirmar los archivos que contiene el proyecto mediante el comando `dir`

![Untitled](/assets/images/2023-04-27-Herramientas/71.png)

Una vez dentro del directorio del proyecto, se puede ejecutar el instalador utilizando el comando `setup.bat` 

![Untitled](/assets/images/2023-04-27-Herramientas/72.png)

Esto instalará la herramienta y, una vez que finalice, se mostrará un mensaje “[INSTALL] Installation Complete”

![Untitled](/assets/images/2023-04-27-Herramientas/73.png)

ara ejecutar la herramienta, se puede utilizar el archivo de inicio con el comando `run.bat` y se debería ver el siguiente mensaje: "Running MobSF on "0.0.0.0:8000 [::]:8000".

![Untitled](/assets/images/2023-04-27-Herramientas/74.png)

Con esto, se puede abrir el navegador de preferencia y acceder a la ruta "127.0.0.1:8000" o "localhost:8000" para confirmar que la herramienta se puede ejecutar correctamente.

![Untitled](/assets/images/2023-04-27-Herramientas/75.png)