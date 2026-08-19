---
layout: single
title: UnCrackable-Level1.apk - Frida Gadget
comments: true
excerpt: "UnCrackable-Level1.apk - Frida Gadget"
date: 2026-08-19
classes: wide
header:
  teaser: /assets/images/2026-08-19-UnCrackable-Level1_apk-Frida_Gadget/logo.png
  teaser_home_page: true
categories:
  - IA
tags:
  - Frida
  - reversing
  - Hacking
  - Medium
---


# 

En este laboratorio vamos a trabajar con **UnCrackable-Level1**, uno de los retos clásicos del OWASP MASTG para practicar instrumentación dinámica con Frida en Android. La app implementa detección de root y de modo debug, y como vamos a trabajar sobre un dispositivo **sin root**, no podemos usar `frida-server` (que requiere privilegios de root para ejecutarse). Por eso nuestra estrategia va a ser inyectar el **Frida Gadget** directamente dentro del APK, una librería que se carga junto con la propia aplicación y nos permite instrumentarla en tiempo de ejecución sin depender de root en el dispositivo.

Para iniciar, descargamos el archivo [UnCrackable-Level1.apk](https://github.com/OWASP/mastg/blob/master/Crackmes/Android/Level_01/UnCrackable-Level1.apk)  directamente desde el repositorio oficial de OWASP MASTG en GitHub.

![image.png](/assets/images/2026-08-19-UnCrackable-Level1_apk-Frida_Gadget/image.png)


Antes de empezar, vamos a confirmar que tenemos instaladas todas las herramientas que vamos a necesitar durante el proceso desde las que usamos para descompilar y reempaquetar el APK, hasta las que nos permiten interactuar con Frida y el dispositivo:

**Java (JDK)**, necesario porque apktool, jadx y las herramientas del SDK de Android están construidas sobre la JVM.

```jsx
D:\>java -version
openjdk version "21.0.5" 2024-10-15 LTS
OpenJDK Runtime Environment Temurin-21.0.5+11 (build 21.0.5+11-LTS)
OpenJDK 64-Bit Server VM Temurin-21.0.5+11 (build 21.0.5+11-LTS, mixed mode, sharing)

D:\>
```

**apktool**, la herramienta que usaremos para descompilar el APK a smali y recursos editables, y luego para reempaquetarlo con el Gadget inyectado.

```jsx
D:\>apktool --version
3.0.2

D:\>
```

**jadx**, que descompila el APK directamente a un pseudo-código Java (más legible que el smali), útil para entender la lógica de la app rápidamente antes de editar el smali.

```jsx
D:\>jadx --version
1.5.5
D:\>
```

**adb (Android Debug Bridge)**, la herramienta que usamos para instalar/desinstalar el APK, ejecutar comandos en el dispositivo y hacer el forward de puertos para conectarnos con Frida.

```jsx
D:\>adb --version
Android Debug Bridge version 1.0.41
Version 35.0.2-12147458
Installed as C:\Users\user\AppData\Local\Android\Sdk\platform-tools\adb.exe
Running on Windows 10.0.26200

D:\>
```

**apksigner**, que usaremos al final del proceso para firmar el APK modificado, ya que Android no permite instalar un APK sin una firma válida.

```jsx
D:\>apksigner version
0.9
D:\>
```

**zipalign**, que alinea los archivos dentro del APK antes de firmarlo, un paso recomendado que veremos en detalle más adelante.

```jsx
D:\>zipalign
Zip alignment utility
Copyright (C) 2009 The Android Open Source Project

Usage: zipalign [-f] [-p] [-P <pagesize_kb>] [-v] [-z] <align> infile.zip outfile.zip
       zipalign -c [-p] [-P <pagesize_kb>] [-v] <align> infile.zip

  <align>: alignment in bytes, e.g. '4' provides 32-bit alignment
  -c: check alignment only (does not modify file)
  -f: overwrite existing outfile.zip
  -p: 4kb page-align uncompressed .so files
  -v: verbose output
  -z: recompress using Zopfli
  -P <pagesize_kb>: Align uncompressed .so files to the specified
                    page size. Valid values for <pagesize_kb> are 4, 16
                    and 64. '-P' cannot be used in combination with '-p'.

D:\>
```

**aapt (Android Asset Packaging Tool)**, que apktool usa internamente para compilar los recursos del APK durante el reempaquetado.

```jsx
D:\>aapt2 version
Android Asset Packaging Tool (aapt) 2.19-12874835

D:\>
```

**d8**, el compilador que convierte bytecode Java a formato DEX, usado también internamente durante el reempaquetado con apktool.

```jsx
D:\>d8 --version
D8 8.6.2-dev (build abaab469b5ebd4dd2bb91ba0ed6f45277faae4ca from go/r8bot (luci-r8-custom-ci-archive-0-77gl))
D:\>
```

**Python**, requerido para instalar y ejecutar Frida y objection, que están escritos en este lenguaje.

```jsx
D:\>python --version
Python 3.12.0

D:\>
```

**pip**, el gestor de paquetes de Python con el que instalaremos frida-tools y objection.

```jsx
D:\>pip --version
pip 26.1.2 from C:\Users\user\AppData\Local\Programs\Python\Python312\Lib\site-packages\pip (python 3.12)

D:\>
```

**Frida**, el framework de instrumentación dinámica que vamos a inyectar en el APK como Gadget. Confirmamos la versión porque, como veremos más adelante, el Gadget debe coincidir exactamente con esta versión del cliente.

```jsx
D:\>frida --version
16.5.9

D:\>
```

**objection**, que nos va a facilitar automatizar todo el proceso de parchar el APK con el Gadget (como alternativa al método manual que hacemos primero para entender qué pasa por debajo).

```jsx
D:\>objection --help

A newer version of objection is available!
You have v1.11.0 and v1.12.5 is ready for download.

Upgrade with: pip3 install objection --upgrade
For more information, please see: https://github.com/sensepost/objection/wiki/Updating

Usage: objection [OPTIONS] COMMAND [ARGS]...

       _   _         _   _
   ___| |_|_|___ ___| |_|_|___ ___
  | . | . | | -_|  _|  _| | . |   |
  |___|___| |___|___|_| |_|___|_|_|
        |___|(object)inject(ion)

       Runtime Mobile Exploration
          by: @leonjza from @sensepost

  By default, communications will happen over USB, unless the --network option
  is provided.

Options:
  -N, --network            Connect using a network connection instead of USB.
  -h, --host TEXT          [default: 127.0.0.1]
  -p, --port INTEGER       [default: 27042]
  -ah, --api-host TEXT     [default: 127.0.0.1]
  -ap, --api-port INTEGER  [default: 8888]
  -g, --gadget TEXT        Name of the Frida Gadget/Process to connect to.
                           [default: Gadget]
  -S, --serial TEXT        A device serial to connect to.
  -d, --debug              Enable debug mode with verbose output. (Includes
                           agent source map in stack traces)
  --help                   Show this message and exit.

Commands:
  api          Start the objection API server in headless mode.
  device-type  Get information about an attached device.
  explore      Start the objection exploration REPL.
  patchapk     Patch an APK with the frida-gadget.so.
  patchipa     Patch an IPA with the FridaGadget dylib.
  run          Run a single objection command.
  signapk      Zipalign and sign an APK with the objection key.
  version      Prints the current version and exists.

D:\>
```

Confirmamos que el dispositivo esté conectado por USB y revisamos su arquitectura de CPU, ya que de esto depende qué versión del Frida Gadget debemos usar

```jsx
D:\Linux\Android\Frida Gadget>adb devices
List of devices attached
HGR4QW07        device

D:\Linux\Android\Frida Gadget>adb shell getprop ro.product.cpu.abi
armeabi-v7a

D:\Linux\Android\Frida Gadget>
```

Confirmamos que el dispositivo usa esta arquitectura de 32 bits, lo que significa que el Gadget que descarguemos debe ser específicamente para **armeabi-v7a** (no arm64, x86, etc.) o no cargará correctamente.

![image.png](/assets/images/2026-08-19-UnCrackable-Level1_apk-Frida_Gadget/image%201.png)

ahora instalamos el APK original en el dispositivo para confirmar que funciona antes de empezar a modificarlo

```jsx
D:\Linux\Android\Frida Gadget>adb install UnCrackable-Level1.apk
Performing Streamed Install
Success

D:\Linux\Android\Frida Gadget>
```

Al abrir la aplicación, esta carga sin problemas ya que el dispositivo no tiene root, vemos el título de la app, el cuadro de texto para ingresar el secreto y el botón **VERIFY**

![image.png](/assets/images/2026-08-19-UnCrackable-Level1_apk-Frida_Gadget/image%202.png)

primero vamos a descompilar el APK con **`apktool d`**, que toma el archivo `.apk` y lo convierte de vuelta en código smali (el ensamblador de la máquina virtual de Android) y recursos editables, en lugar del bytecode compilado que no podemos modificar directamente: `apktool d UnCrackable-Level1.apk -o UnCrackable-Level1-patched`

```jsx
D:\Linux\Android\Frida Gadget>apktool d UnCrackable-Level1.apk -o UnCrackable-Level1-patched
I: Using Apktool 3.0.2 on UnCrackable-Level1.apk with 8 threads
I: Loading resource table...
I: Baksmaling classes.dex...
I: Decoding value resources...
I: Decoding file resources...
I: Loading resource table from file: C:\Users\user\AppData\Local\apktool\framework\1.apk
I: Generating values XMLs...
I: Decoding AndroidManifest.xml with resources...
I: Copying original files...
I: Copying unknown files...

D:\Linux\Android\Frida Gadget>
```

verificamos el contenido del directorio generado por apktool

```jsx
D:\Linux\Android\Frida Gadget>dir UnCrackable-Level1-patched
 El volumen de la unidad D es Nuevo vol
 El número de serie del volumen es: BCF2-9935

 Directorio de D:\Linux\Android\Frida Gadget\UnCrackable-Level1-patched

23/07/2026  03:26 p. m.    <DIR>          .
23/07/2026  03:26 p. m.    <DIR>          ..
23/07/2026  03:26 p. m.               660 AndroidManifest.xml
23/07/2026  03:26 p. m.               256 apktool.yml
23/07/2026  03:26 p. m.    <DIR>          original
23/07/2026  03:26 p. m.    <DIR>          res
23/07/2026  03:26 p. m.    <DIR>          smali
               2 archivos            916 bytes
               5 dirs  28.216.995.840 bytes libres

D:\Linux\Android\Frida Gadget>
```

Como confirmamos antes que tenemos instalada la versión **16.5.9** de Frida, debemos usar exactamente esa misma versión del Gadget, Frida es estricto con la compatibilidad entre el cliente y el Gadget, así que una diferencia de versión puede impedir la conexión. También sabemos que el dispositivo es **armeabi-v7a de 32 bits**, así que necesitamos la versión del Gadget compilada para esa arquitectura específica, para este caso vamos a utilizar la versión 16.5.9 ya que es más estable que las versiones más recientes.

Descargamos la release correspondiente desde el repositorio oficial de Frida: [https://github.com/frida/frida/releases/tag/16.5.9](https://github.com/frida/frida/releases/tag/16.5.9)

![image.png](/assets/images/2026-08-19-UnCrackable-Level1_apk-Frida_Gadget/image%203.png)

Una vez descargado el archivo `.so.xz`, el siguiente paso es descomprimirlo para obtener la librería `.so` que vamos a inyectar en el APK.

![image.png](/assets/images/2026-08-19-UnCrackable-Level1_apk-Frida_Gadget/image%204.png)

Lo descomprimimos para obtener el archivo `.so` del Gadget, que ya podemos usar en el siguiente paso.

![image.png](/assets/images/2026-08-19-UnCrackable-Level1_apk-Frida_Gadget/image%205.png)

confirmamos que el archivo del Gadget se descargó y descomprimió correctamente

```jsx
D:\Linux\Android\Frida Gadget>dir frida-gadget*
 El volumen de la unidad D es Nuevo vol
 El número de serie del volumen es: BCF2-9935

 Directorio de D:\Linux\Android\Frida Gadget

22/07/2026  03:40 p. m.        21.313.664 frida-gadget-16.5.9-android-arm.so
22/07/2026  03:40 p. m.         6.126.468 frida-gadget-16.5.9-android-arm.so.xz
               2 archivos     27.440.132 bytes
               0 dirs  28.195.680.256 bytes libres

D:\Linux\Android\Frida Gadget>
```

creamos la carpeta `lib/armeabi-v7a` dentro del proyecto descompilado, que es donde Android espera encontrar las librerías nativas para esta arquitectura: `mkdir UnCrackable-Level1-patched\lib\armeabi-v7a`

```
D:\Linux\Android\Frida Gadget>mkdir UnCrackable-Level1-patched\lib\armeabi-v7a

D:\Linux\Android\Frida Gadget>
```

vamos a copiarlo al directorio y lo renombramos `copy frida-gadget-16.5.9-android-arm.so UnCrackable-Level1-patched\lib\armeabi-v7a\libfrida-gadget.so`

```
D:\Linux\Android\Frida Gadget>copy frida-gadget-16.5.9-android-arm.so UnCrackable-Level1-patched\lib\armeabi-v7a\libfrida-gadget.so
        1 archivo(s) copiado(s).

D:\Linux\Android\Frida Gadget>
```

confirmamos que el archivo quedó copiado correctamente: `dir UnCrackable-Level1-patched\lib\armeabi-v7a`

```
D:\Linux\Android\Frida Gadget>dir UnCrackable-Level1-patched\lib\armeabi-v7a
	El volumen de la unidad D es Nuevo vol
	El número de serie del volumen es: BCF2-9935
	Directorio de D:\Linux\Android\Frida Gadget\UnCrackable-Level1-patched\lib\armeabi-v7a
23/07/2026  03:41 p. m.    \<DIR\>          .
23/07/2026  03:40 p. m.    \<DIR\>          ..
22/07/2026  03:40 p. m.        21.313.664 [libfrida-gadget.so](http://libfrida-gadget.so)
	1 archivos     21.313.664 bytes
	2 dirs  28.174.364.672 bytes libres
	
D:\Linux\Android\Frida Gadget>
```

Por ahora vamos a hacerlo de la forma más simple, sin un archivo `libfrida-gadget.config.js` que nos permita cargar scripts personalizados al iniciar, la idea es primero confirmar que el Gadget carga correctamente y podemos conectarnos a él. Más adelante, en otro laboratorio, sí vamos a configurar ese archivo para automatizar bypasses y hooks apenas arranca la app.

### Modificar el smali para cargar el Gadget

La idea es inyectar una llamada a `System.loadLibrary("frida-gadget")` lo más temprano posible en el ciclo de vida de la app idealmente en un bloque estático (`<clinit>`) de la Activity principal, porque ese código corre **antes** que cualquier otra cosa, incluso antes del constructor normal.

Primero, identifiquemos la Activity principal (launcher) esto lo vemos en el archivo AndroidManifest.xml

```
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="owasp.mstg.uncrackable1">
    <application android:allowBackup="true" android:icon="@mipmap/ic_launcher" android:label="@string/app_name" android:theme="@style/AppTheme">
        <activity android:label="@string/app_name" android:name="sg.vantagepoint.uncrackable1.MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
```

la Activity principal es `sg.vantagepoint.uncrackable1.MainActivity`

ahora vamos a ver el archivo MainActivity.smali

```
.class public Lsg/vantagepoint/uncrackable1/MainActivity;
.super Landroid/app/Activity;
# direct methods
.method public constructor \<init\>()V
	.locals 0
	invoke-direct \{p0\}, Landroid/app/Activity;-\>\<init\>()V
	return-void
.end method
.method private a(Ljava/lang/String;)V
	.locals 3
	new-instance v0, Landroid/app/AlertDialog\$Builder;
	invoke-direct \{v0, p0\}, Landroid/app/AlertDialog\$Builder;-\>\<init\>(Landroid/content/Context;)V
	invoke-virtual \{v0\}, Landroid/app/AlertDialog\$Builder;-\>create()Landroid/app/AlertDialog;
	move-result-object v0
	invoke-virtual \{v0, p1\}, Landroid/app/AlertDialog;-\>setTitle(Ljava/lang/CharSequence;)V
	const-string p1, "This is unacceptable. The app is now going to exit."
	invoke-virtual \{v0, p1\}, Landroid/app/AlertDialog;-\>setMessage(Ljava/lang/CharSequence;)V
	const-string p1, "OK"
	new-instance v1, Lsg/vantagepoint/uncrackable1/MainActivity\$1;
	invoke-direct \{v1, p0\}, Lsg/vantagepoint/uncrackable1/MainActivity\$1;-\>\<init\>(Lsg/vantagepoint/uncrackable1/MainActivity;)V
	const/4 v2, -0x3
	invoke-virtual \{v0, v2, p1, v1\}, Landroid/app/AlertDialog;-\>setButton(ILjava/lang/CharSequence;Landroid/content/DialogInterface\$OnClickListener;)V
	const/4 p1, 0x0
	invoke-virtual \{v0, p1\}, Landroid/app/AlertDialog;-\>setCancelable(Z)V
	invoke-virtual \{v0\}, Landroid/app/AlertDialog;-\>show()V
	return-void
.end method
# virtual methods
.method protected onCreate(Landroid/os/Bundle;)V
	.locals 1
	invoke-static \{\}, Lsg/vantagepoint/a/c;-\>a()Z
	move-result v0
	if-nez v0, :cond_0
	invoke-static \{\}, Lsg/vantagepoint/a/c;-\>b()Z
	move-result v0
	if-nez v0, :cond_0
	invoke-static \{\}, Lsg/vantagepoint/a/c;-\>c()Z
	move-result v0
	if-eqz v0, :cond_1
	:cond_0
	const-string v0, "Root detected!"
	invoke-direct \{p0, v0\}, Lsg/vantagepoint/uncrackable1/MainActivity;-\>a(Ljava/lang/String;)V
	:cond_1
	invoke-virtual \{p0\}, Lsg/vantagepoint/uncrackable1/MainActivity;-\>getApplicationContext()Landroid/content/Context;
	move-result-object v0
	invoke-static \{v0\}, Lsg/vantagepoint/a/b;-\>a(Landroid/content/Context;)Z
	move-result v0
	if-eqz v0, :cond_2
	const-string v0, "App is debuggable!"
	invoke-direct \{p0, v0\}, Lsg/vantagepoint/uncrackable1/MainActivity;-\>a(Ljava/lang/String;)V
	:cond_2
	invoke-super \{p0, p1\}, Landroid/app/Activity;-\>onCreate(Landroid/os/Bundle;)V
	const/high16 p1, 0x7f030000
	invoke-virtual \{p0, p1\}, Lsg/vantagepoint/uncrackable1/MainActivity;-\>setContentView(I)V
	return-void
.end method
.method public verify(Landroid/view/View;)V
	.locals 3
	const p1, 0x7f020001
	invoke-virtual \{p0, p1\}, Lsg/vantagepoint/uncrackable1/MainActivity;-\>findViewById(I)Landroid/view/View;
	move-result-object p1
	check-cast p1, Landroid/widget/EditText;
	invoke-virtual \{p1\}, Landroid/widget/EditText;-\>getText()Landroid/text/Editable;
	move-result-object p1
	invoke-virtual \{p1\}, Ljava/lang/Object;-\>toString()Ljava/lang/String;
	move-result-object p1
	new-instance v0, Landroid/app/AlertDialog\$Builder;
	invoke-direct \{v0, p0\}, Landroid/app/AlertDialog\$Builder;-\>\<init\>(Landroid/content/Context;)V
	invoke-virtual \{v0\}, Landroid/app/AlertDialog\$Builder;-\>create()Landroid/app/AlertDialog;
	move-result-object v0
	invoke-static \{p1\}, Lsg/vantagepoint/uncrackable1/a;-\>a(Ljava/lang/String;)Z
	move-result p1
	if-eqz p1, :cond_0
	const-string p1, "Success!"
	invoke-virtual \{v0, p1\}, Landroid/app/AlertDialog;-\>setTitle(Ljava/lang/CharSequence;)V
	const-string p1, "This is the correct secret."
	:goto_0
	invoke-virtual \{v0, p1\}, Landroid/app/AlertDialog;-\>setMessage(Ljava/lang/CharSequence;)V
	goto :goto_1
	:cond_0
	const-string p1, "Nope..."
	invoke-virtual \{v0, p1\}, Landroid/app/AlertDialog;-\>setTitle(Ljava/lang/CharSequence;)V
	const-string p1, "That's not it. Try again."
	goto :goto_0
	:goto_1
	const/4 p1, -0x3
	const-string v1, "OK"
	new-instance v2, Lsg/vantagepoint/uncrackable1/MainActivity\$2;
	invoke-direct \{v2, p0\}, Lsg/vantagepoint/uncrackable1/MainActivity\$2;-\>\<init\>(Lsg/vantagepoint/uncrackable1/MainActivity;)V
	invoke-virtual \{v0, p1, v1, v2\}, Landroid/app/AlertDialog;-\>setButton(ILjava/lang/CharSequence;Landroid/content/DialogInterface\$OnClickListener;)V
	invoke-virtual \{v0\}, Landroid/app/AlertDialog;-\>show()V
	return-void
.end method
```

en este caso **no existe un bloque `<clinit>`** (constructor estático), así que vamos a crear uno desde cero. Este es el punto de inyección ideal porque un constructor estático se ejecuta la primera vez que la JVM carga la clase — **antes** de `onCreate()`, antes de cualquier chequeo de root, antes de todo.

Vamos a añadir este bloque justo después del comentario `# direct methods` y antes del `<init>()` existente:

```
.method static constructor \<clinit\>()V
	.locals 1
	const-string v0, "frida-gadget"
	invoke-static \{v0\}, Ljava/lang/System;-\>loadLibrary(Ljava/lang/String;)V
	return-void
.end method
```

el archivo queda de la siguiente manera 

```
.class public Lsg/vantagepoint/uncrackable1/MainActivity;
.super Landroid/app/Activity;
# direct methods
.method static constructor \<clinit\>()V
	.locals 1
	const-string v0, "frida-gadget"
	invoke-static \{v0\}, Ljava/lang/System;-\>loadLibrary(Ljava/lang/String;)V
	return-void
.end method
.method public constructor \<init\>()V
	.locals 0
	invoke-direct \{p0\}, Landroid/app/Activity;-\>\<init\>()V
	return-void
.end method
.method private a(Ljava/lang/String;)V
	.locals 3
	new-instance v0, Landroid/app/AlertDialog\$Builder;
	invoke-direct \{v0, p0\}, Landroid/app/AlertDialog\$Builder;-\>\<init\>(Landroid/content/Context;)V
	invoke-virtual \{v0\}, Landroid/app/AlertDialog\$Builder;-\>create()Landroid/app/AlertDialog;
	move-result-object v0
	invoke-virtual \{v0, p1\}, Landroid/app/AlertDialog;-\>setTitle(Ljava/lang/CharSequence;)V
	const-string p1, "This is unacceptable. The app is now going to exit."
	invoke-virtual \{v0, p1\}, Landroid/app/AlertDialog;-\>setMessage(Ljava/lang/CharSequence;)V
	const-string p1, "OK"
	new-instance v1, Lsg/vantagepoint/uncrackable1/MainActivity\$1;
	invoke-direct \{v1, p0\}, Lsg/vantagepoint/uncrackable1/MainActivity\$1;-\>\<init\>(Lsg/vantagepoint/uncrackable1/MainActivity;)V
	const/4 v2, -0x3
	invoke-virtual \{v0, v2, p1, v1\}, Landroid/app/AlertDialog;-\>setButton(ILjava/lang/CharSequence;Landroid/content/DialogInterface\$OnClickListener;)V
	const/4 p1, 0x0
	invoke-virtual \{v0, p1\}, Landroid/app/AlertDialog;-\>setCancelable(Z)V
	invoke-virtual \{v0\}, Landroid/app/AlertDialog;-\>show()V
	return-void
.end method
# virtual methods
.method protected onCreate(Landroid/os/Bundle;)V
	.locals 1
	invoke-static \{\}, Lsg/vantagepoint/a/c;-\>a()Z
	move-result v0
	if-nez v0, :cond_0
	invoke-static \{\}, Lsg/vantagepoint/a/c;-\>b()Z
	move-result v0
	if-nez v0, :cond_0
	invoke-static \{\}, Lsg/vantagepoint/a/c;-\>c()Z
	move-result v0
	if-eqz v0, :cond_1
	:cond_0
	const-string v0, "Root detected!"
	invoke-direct \{p0, v0\}, Lsg/vantagepoint/uncrackable1/MainActivity;-\>a(Ljava/lang/String;)V
	:cond_1
	invoke-virtual \{p0\}, Lsg/vantagepoint/uncrackable1/MainActivity;-\>getApplicationContext()Landroid/content/Context;
	move-result-object v0
	invoke-static \{v0\}, Lsg/vantagepoint/a/b;-\>a(Landroid/content/Context;)Z
	move-result v0
	if-eqz v0, :cond_2
	const-string v0, "App is debuggable!"
	invoke-direct \{p0, v0\}, Lsg/vantagepoint/uncrackable1/MainActivity;-\>a(Ljava/lang/String;)V
	:cond_2
	invoke-super \{p0, p1\}, Landroid/app/Activity;-\>onCreate(Landroid/os/Bundle;)V
	const/high16 p1, 0x7f030000
	invoke-virtual \{p0, p1\}, Lsg/vantagepoint/uncrackable1/MainActivity;-\>setContentView(I)V
	return-void
.end method
.method public verify(Landroid/view/View;)V
	.locals 3
	const p1, 0x7f020001
	invoke-virtual \{p0, p1\}, Lsg/vantagepoint/uncrackable1/MainActivity;-\>findViewById(I)Landroid/view/View;
	move-result-object p1
	check-cast p1, Landroid/widget/EditText;
	invoke-virtual \{p1\}, Landroid/widget/EditText;-\>getText()Landroid/text/Editable;
	move-result-object p1
	invoke-virtual \{p1\}, Ljava/lang/Object;-\>toString()Ljava/lang/String;
	move-result-object p1
	new-instance v0, Landroid/app/AlertDialog\$Builder;
	invoke-direct \{v0, p0\}, Landroid/app/AlertDialog\$Builder;-\>\<init\>(Landroid/content/Context;)V
	invoke-virtual \{v0\}, Landroid/app/AlertDialog\$Builder;-\>create()Landroid/app/AlertDialog;
	move-result-object v0
	invoke-static \{p1\}, Lsg/vantagepoint/uncrackable1/a;-\>a(Ljava/lang/String;)Z
	move-result p1
	if-eqz p1, :cond_0
	const-string p1, "Success!"
	invoke-virtual \{v0, p1\}, Landroid/app/AlertDialog;-\>setTitle(Ljava/lang/CharSequence;)V
	const-string p1, "This is the correct secret."
	:goto_0
	invoke-virtual \{v0, p1\}, Landroid/app/AlertDialog;-\>setMessage(Ljava/lang/CharSequence;)V
	goto :goto_1
	:cond_0
	const-string p1, "Nope..."
	invoke-virtual \{v0, p1\}, Landroid/app/AlertDialog;-\>setTitle(Ljava/lang/CharSequence;)V
	const-string p1, "That's not it. Try again."
	goto :goto_0
	:goto_1
	const/4 p1, -0x3
	const-string v1, "OK"
	new-instance v2, Lsg/vantagepoint/uncrackable1/MainActivity\$2;
	invoke-direct \{v2, p0\}, Lsg/vantagepoint/uncrackable1/MainActivity\$2;-\>\<init\>(Lsg/vantagepoint/uncrackable1/MainActivity;)V
	invoke-virtual \{v0, p1, v1, v2\}, Landroid/app/AlertDialog;-\>setButton(ILjava/lang/CharSequence;Landroid/content/DialogInterface\$OnClickListener;)V
	invoke-virtual \{v0\}, Landroid/app/AlertDialog;-\>show()V
	return-void
.end method
```

**el Gadget necesita el permiso `INTERNET`** para poder escuchar en el socket/puerto donde `frida -U` se conecta. Si el APK original no lo declaraba la conexión falla silenciosamente más adelante, lo vamos a agregar al  `AndroidManifest.xml`

agregamos el permiso 

<uses-permission android:name="android.permission.INTERNET"/>

y quedaría así 

```
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="owasp.mstg.uncrackable1">
    <uses-permission android:name="android.permission.INTERNET"/>
    <application android:allowBackup="true" android:icon="@mipmap/ic_launcher" android:label="@string/app_name" android:theme="@style/AppTheme">
        <activity android:label="@string/app_name" android:name="sg.vantagepoint.uncrackable1.MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
```

**Con el smali y el manifiesto ya modificados, el siguiente paso es recompilar el APK** con apktool: `apktool b UnCrackable-Level1-patched -o UnCrackable-Level1-gadget.apk`

Esto va a:

1. Tomar el smali modificado (con nuestro `<clinit>`)
2. Tomar el manifiesto modificado (con el permiso INTERNET)
3. Empaquetar de nuevo el `libfrida-gadget.so` dentro de `lib/armeabi-v7a/`
4. Generar un APK nuevo: `UnCrackable-Level1-gadget.apk`

```
D:\Linux\Android\Frida Gadget>apktool b UnCrackable-Level1-patched -o UnCrackable-Level1-gadget.apk
I: Using Apktool 3.0.2 on UnCrackable-Level1.apk with 8 threads
I: Smaling smali folder into classes.dex...
I: Building resources with aapt2...
I: Building apk file...
I: Importing lib...
I: Built apk into: UnCrackable-Level1-gadget.apk

D:\Linux\Android\Frida Gadget>
```

Confirmamos que el APK se generó correctamente: debe quedar un apk llamado  UnCrackable-Level1-gadget.apk

```
D:\Linux\Android\Frida Gadget>dir UnCrackable-Level1-gadget.apk
 El volumen de la unidad D es Nuevo vol
 El número de serie del volumen es: BCF2-9935

 Directorio de D:\Linux\Android\Frida Gadget

23/07/2026  04:19 p. m.         8.844.012 UnCrackable-Level1-gadget.apk
               1 archivos      8.844.012 bytes
               0 dirs  28.165.365.760 bytes libres

D:\Linux\Android\Frida Gadget>
```

**Con el APK ya reempaquetado, toca firmarlo.** Empezamos generando un keystore de debug:

```
D:\Linux\Android\Frida Gadget>keytool -genkey -v -keystore debug.keystore -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US"
Generando par de claves RSA de 2.048 bits para certificado autofirmado (SHA384withRSA) con una validez de 10.000 días
        para: CN=Android Debug, O=Android, C=US
[Almacenando debug.keystore]

D:\Linux\Android\Frida Gadget>
```

Creó un **certificado digital + su clave privada**, guardados en un archivo llamado `debug.keystore`.

**Para qué:** Android **no instala ningún APK sin firma digital**. Es una regla del sistema operativo, no relacionada con seguridad "de verdad" en este contexto — es más una forma de decir "este APK viene de X origen y nadie lo modificó después de firmarlo". Como nosotros SÍ modificamos el APK (le metimos el Gadget), la firma original de OWASP ya no es válida para este archivo, así que necesitamos poner **nuestra propia firma** encima.

Piensa en esto como un sello de cera en una carta: no importa que el sello sea "oficial" o no, Android solo exige que *haya* un sello y que coincida con el contenido. `keytool` fue el que fabricó ese sello (el certificado).

#### Alinear el APK (zipalign) antes de firmar

Es buena práctica hacer zipalign **antes** de firmar con `apksigner`

```
D:\Linux\Android\Frida Gadget>zipalign -v -p 4 UnCrackable-Level1-gadget.apk UnCrackable-Level1-gadget-aligned.apk
Verifying alignment of UnCrackable-Level1-gadget-aligned.apk (4)...
      49 AndroidManifest.xml (OK - compressed)
     786 classes.dex (OK - compressed)
    3758 res/layout/activity_main.xml (OK - compressed)
    4323 res/menu/menu_main.xml (OK - compressed)
    4648 res/mipmap-hdpi/ic_launcher.png (OK)
    9460 res/mipmap-mdpi/ic_launcher.png (OK)
   11872 res/mipmap-xhdpi/ic_launcher.png (OK)
   19212 res/mipmap-xxhdpi/ic_launcher.png (OK)
   33676 res/mipmap-xxxhdpi/ic_launcher.png (OK)
   56524 resources.arsc (OK)
   59424 lib/armeabi-v7a/libfrida-gadget.so (OK - compressed)
Verification succesful

D:\Linux\Android\Frida Gadget>
```

Reorganizó internamente los archivos dentro del APK (que en el fondo es un `.zip`) para que cada uno empiece en un offset de memoria múltiplo de 4 bytes.

**Para qué:** Es una optimización de rendimiento de Android — cuando los archivos (especialmente los `.so` nativos como nuestro Gadget) están alineados a estos límites de memoria, el sistema operativo puede mapearlos directamente en RAM sin copiarlos primero, lo cual es más rápido y usa menos memoria. No es estrictamente obligatorio para que la app funcione, pero **si no lo haces y luego firmas, algunas versiones de Android pueden rechazar el APK o rendir peor con librerías nativas** — por eso lo hacemos antes de firmar.

Una vez alineado, procedemos a firmarlo con apksigner:

```
D:\Linux\Android\Frida Gadget>apksigner sign --ks debug.keystore --ks-pass pass:android --out UnCrackable-Level1-gadget-signed.apk UnCrackable-Level1-gadget-aligned.apk

D:\Linux\Android\Frida Gadget>
```

Tomó el certificado que generamos en el paso 1 (`debug.keystore`) y lo usó para **firmar criptográficamente** el APK alineado, generando un archivo de salida nuevo (`UnCrackable-Level1-gadget-signed.apk`) con la firma incrustada.

**Para qué:** Este es el paso que realmente hace que Android acepte instalar el APK. Sin este paso, `adb install` te devolvería un error tipo `INSTALL_PARSE_FAILED_NO_CERTIFICATES`.

Por último, verificamos que la firma quedó bien aplicada

```
D:\Linux\Android\Frida Gadget>apksigner verify UnCrackable-Level1-gadget-signed.apk

D:\Linux\Android\Frida Gadget>
```

Simplemente **revisó** el APK ya firmado y confirmó que la firma es válida y está correctamente aplicada, sin devolver nada en consola (que es la señal de "todo bien"; si hubiera un problema, te habría mostrado un error explícito).

**Para qué:** Es un chequeo de sanidad antes de instalar, más vale descubrir un problema de firma aquí, en 2 segundos, que después de instalar y que el dispositivo te dé un error de instalación críptico.

**Con el APK ya firmado, toca reemplazar la versión original por la nuestra en el dispositivo.** Empezamos desinstalando la app original

```
D:\Linux\Android\Frida Gadget>adb uninstall owasp.mstg.uncrackable1
Success

D:\Linux\Android\Frida Gadget>
```

Y a continuación instalamos la versión modificada con el Gadget

```
D:\Linux\Android\Frida Gadget>adb install UnCrackable-Level1-gadget-signed.apk
Performing Incremental Install
Serving...
All files should be loaded. Notifying the device.
Success
Install command complete in 927 ms

D:\Linux\Android\Frida Gadget>
```

**Al abrir la aplicación, esta se queda congelada en el logo de inicio**  y esto es justo lo que esperamos: como inyectamos la llamada a `System.loadLibrary("frida-gadget")` en el `<clinit>`, la app se detiene ahí esperando a que un cliente Frida se conecte al Gadget antes de continuar su ejecución normal

![image.png](/assets/images/2026-08-19-UnCrackable-Level1_apk-Frida_Gadget/image%206.png)

Frida en modo Gadget con `frida -U` normalmente detecta el Gadget vía USB automáticamente en modo listen, pero como es un `TCP port 27042` local **en el dispositivo**, necesitamos hacer el forward del puerto primero para poder conectarnos desde el PC:

```
D:\Linux\Android\Frida Gadget>adb forward tcp:27042 tcp:27042
27042

D:\Linux\Android\Frida Gadget>
```

Con la pantalla todavía congelada, nos conectamos al Gadget con `frida -U -n Uncrackable1`, y vemos que la aplicación retoma su ejecución sin problemas:

```
D:\Linux\Android\Frida Gadget>frida -U -n Uncrackable1
     ____
    / _  |   Frida 16.5.9 - A world-class dynamic instrumentation toolkit
   | (_| |
    > _  |   Commands:
   /_/ |_|       help      -> Displays the help system
   . . . .       object?   -> Display information about 'object'
   . . . .       exit/quit -> Exit
   . . . .
   . . . .   More info at https://frida.re/docs/home/
   . . . .
   . . . .   Connected to TB300FU (id=HGR4QW07)

[TB300FU::Uncrackable1 ]->
```

En el dispositivo (izquierda), la aplicación ya no está congelada: vemos el cuadro de texto y el botón **VERIFY** funcionando con normalidad. En la consola (derecha), la sesión de Frida quedó conectada y esperando comandos a partir de aquí ya podemos empezar a interactuar con la app en tiempo real.

![image.png](/assets/images/2026-08-19-UnCrackable-Level1_apk-Frida_Gadget/image%207.png)

**También podemos hacer el mismo procedimiento usando el nombre genérico `Gadget` en vez del nombre de la app, con `frida -U -n Gadget`, que nos da el mismo resultado**

```
D:\Linux\Android\Frida Gadget>frida -U -n Gadget
     ____
    / _  |   Frida 16.5.9 - A world-class dynamic instrumentation toolkit
   | (_| |
    > _  |   Commands:
   /_/ |_|       help      -> Displays the help system
   . . . .       object?   -> Display information about 'object'
   . . . .       exit/quit -> Exit
   . . . .
   . . . .   More info at https://frida.re/docs/home/
   . . . .
   . . . .   Connected to TB300FU (id=HGR4QW07)

[TB300FU::Gadget ]->
```

El resultado es idéntico al anterior: la app funciona con normalidad y Frida queda conectado a la sesión, esta vez identificada como `Gadget` en lugar del nombre específico de la aplicación, útil cuando no conocemos de antemano el nombre exacto con el que el proceso se identifica.

![image.png](/assets/images/2026-08-19-UnCrackable-Level1_apk-Frida_Gadget/image%208.png)

Esta es la forma manual de hacerlo, pero también se puede automatizar con objection: basta con correr el siguiente comando y la herramienta hace todo el proceso por nosotros: `objection patchapk -s UnCrackable-Level1.apk -V 16.5.9`

```
D:\Linux\Android\Frida Gadget\Objetion>objection patchapk -s UnCrackable-Level1.apk -V 16.5.9
No architecture specified. Determining it using `adb`...
Detected target device architecture as: armeabi-v7a
Using manually specified version: 16.5.9
Remote FridaGadget version is v16.5.9, local is v17.16.4. Downloading...
Downloading from: https://github.com/frida/frida/releases/download/16.5.9/frida-gadget-16.5.9-android-arm.so.xz
Downloading armeabi-v7a library to C:\Users\user\.objection\android\armeabi-v7a\libfrida-gadget.so.xz...
Unpacking C:\Users\user\.objection\android\armeabi-v7a\libfrida-gadget.so.xz...
Cleaning up downloaded archives...
Patcher will be using Gadget version: 16.5.9
Detected apktool version as: 3.0.2
Running apktool empty-framework-dir...
Apktool 3.0.2 - a tool for reengineering Android apk files
with smali 3.0.9-dev and baksmali 3.0.9-dev
Copyright 2010 Ryszard Wiśniewski <brut.alll@gmail.com>
Copyright 2010 Connor Tumbleson <connor.tumbleson@gmail.com>

General options:
 -q,--quiet     Suppress normal output.
 -v,--verbose   Increase output verbosity.

apktool d|decode [options] <apk-file>
 -a,--all-src              Decode all sources in the apk (includes unknown dex files).
 -f,--force                Force delete destination directory.
 -j,--jobs <num>           Set the number of jobs to execute in parallel to <num>.
 -l,--lib <package:file>   Use shared library <package> located in <file>.
                           Can be specified multiple times.
 -o,--output <dir>         Output decoded files to <dir>. (default: apk.out)
 -p,--frame-path <dir>     Use framework files located in <dir>.
 -r,--no-res               Do not decode resources.
 -s,--no-src               Do not decode sources.
 -t,--frame-tag <tag>      Use framework files tagged with <tag>.

apktool b|build [options] <apk-dir>
 -f,--force                Skip changes detection and build all files.
 -j,--jobs <num>           Set the number of jobs to execute in parallel to <num>.
 -l,--lib <package:file>   Use shared library <package> located in <file>.
                           Can be specified multiple times.
 -o,--output <file>        Output the built apk to <file>. (default: dist/name.apk)
 -p,--frame-path <dir>     Use framework files located in <dir>.

apktool if|install-framework [options] <apk-file>
 -p,--frame-path <dir>   Set the path for framework files to <dir>.
 -t,--frame-tag <tag>    Suffix framework files with <tag>.

apktool h|help
apktool v|version

For additional info, see: https://apktool.org
For smali/baksmali info, see: https://github.com/google/smali
Unpacking UnCrackable-Level1.apk
App does not have android.permission.INTERNET, attempting to patch the AndroidManifest.xml...
Injecting permission: android.permission.INTERNET
Writing new Android manifest...
Target class not specified, searching for launchable activity instead...
Reading smali from: C:\Users\user\AppData\Local\Temp\tmpm3asje9m.apktemp\smali\sg/vantagepoint/uncrackable1/MainActivity.smali
Injecting loadLibrary call at line: 5
Attempting to fix the constructors .locals count
Current locals value is 0, updating to 1:
Writing patched smali back to: C:\Users\user\AppData\Local\Temp\tmpm3asje9m.apktemp\smali\sg/vantagepoint/uncrackable1/MainActivity.smali
Creating library path: C:\Users\user\AppData\Local\Temp\tmpm3asje9m.apktemp\lib\armeabi-v7a
Copying Frida gadget to libs path...
Rebuilding the APK with the frida-gadget loaded...
Built new APK with injected loadLibrary and frida-gadget
Performing zipalign
Zipalign completed
Signing new APK.
Signed the new APK
Copying final apk from C:\Users\user\AppData\Local\Temp\tmpm3asje9m.apktemp.aligned.objection.apk to UnCrackable-Level1.objection.apk in current directory...
Cleaning up temp files...

D:\Linux\Android\Frida Gadget\Objetion>
```

Con el APK ya parchado automáticamente, repetimos el mismo ciclo: desinstalar, instalar, y volver a conectar Frida. Primero desinstalamos la versión anterior

```
D:\Linux\Android\Frida Gadget\Objetion>adb uninstall owasp.mstg.uncrackable1
Success

D:\Linux\Android\Frida Gadget\Objetion>
```

Instalamos la nueva versión generada por objection

```
D:\Linux\Android\Frida Gadget\Objetion>adb install UnCrackable-Level1.objection.apk
Performing Streamed Install
Success

D:\Linux\Android\Frida Gadget\Objetion>
```

Forzamos el cierre de cualquier instancia previa de la app

```
D:\Linux\Android\Frida Gadget\Objetion>adb shell am force-stop owasp.mstg.uncrackable1

D:\Linux\Android\Frida Gadget\Objetion>
```

Y volvemos a hacer el forward del puerto para poder conectarnos

```
D:\Linux\Android\Frida Gadget\Objetion>adb forward tcp:27042 tcp:27042

D:\Linux\Android\Frida Gadget\Objetion>
```

Abrimos la aplicación esta se queda congelada en el logo de inicio, tal como esperamos  y corremos el comando de Frida para conectarnos y veremos el mismo resultado anterior, la aplicación carga sin problemas 

```
D:\Linux\Android\Frida Gadget\Objetion>frida -U -n Uncrackable1
     ____
    / _  |   Frida 16.5.9 - A world-class dynamic instrumentation toolkit
   | (_| |
    > _  |   Commands:
   /_/ |_|       help      -> Displays the help system
   . . . .       object?   -> Display information about 'object'
   . . . .       exit/quit -> Exit
   . . . .
   . . . .   Prefer a GUI? Luma is the official Frida app, with a live REPL,
   . . . .   persistent sessions & collaboration. https://luma.frida.re/
   . . . .
   . . . .   Connected to TB300FU (id=HGR4QW07)

[TB300FU::Uncrackable1 ]->
```

Con el APK ya parchado y funcionando, vamos a usar **objection** para completar el bypass de este crackme, ya que, al ser un reto conocido de OWASP MASTG, la lógica de validación ya la identificamos antes en el smali (el método estático `sg.vantagepoint.uncrackable1.a.a`). Conectamos la aplicación con el comando `objection -n Uncrackable1 explore` Y confirmamos que todo carga correctamente: la aplicación queda visible en el dispositivo, mientras objection nos da el prompt interactivo listo para trabajar.

![image.png](/assets/images/2026-08-19-UnCrackable-Level1_apk-Frida_Gadget/image%209.png)

Antes de aplicar el bypass, confirmamos el comportamiento normal de la app: escribimos cualquier texto en la caja y presionamos el botón **VERIFY**. Como es de esperarse (aún no hemos modificado nada en tiempo de ejecución), la aplicación nos indica que el secreto ingresado no es correcto.

![image.png](/assets/images/2026-08-19-UnCrackable-Level1_apk-Frida_Gadget/image%2010.png)

Ahora sí ejecutamos el comando que hace el bypass real: `android hooking set return_value sg.vantagepoint.uncrackable1.a.a true`. Esto le dice a Frida que, sin importar la lógica interna del método, siempre devuelva `true` como resultado.

Con el hook activo, volvemos a escribir el mismo texto incorrecto en la caja y presionamos **VERIFY** de nuevo y esta vez la aplicación muestra

**Success!**

This is the correct secret.

![image.png](2026-08-19-UnCrackable-Level1_apk-Frida_Gadget/image%2011.png)

## **Conclusión**:

Esto confirma el bypass completo: logramos alterar el resultado de la validación en tiempo de ejecución sin tocar el secreto real ni modificar la lógica original del método, únicamente forzando su valor de retorno desde Frida.

Y lo más importante, este resultado se logró en un **dispositivo sin root**, que era justamente el foco de todo este laboratorio. No necesitamos rootear el dispositivo ni depender de `frida-server` corriendo con privilegios elevados: inyectamos el **Frida Gadget** directamente dentro del APK durante el proceso de patching, y eso fue suficiente para instrumentar la aplicación en tiempo de ejecución, interceptar su lógica y modificar su comportamiento a voluntad. Esto demuestra que, aun en dispositivos **cerrados** o **sin acceso privilegiado**, un análisis dinámico completo sigue siendo posible cuando se tiene control sobre el APK.