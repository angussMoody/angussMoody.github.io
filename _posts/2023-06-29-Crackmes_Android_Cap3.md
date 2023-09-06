
---
layout: single
title: Crackmes Android - Capitulo 3
comments: true
excerpt: "continuamos con estos crackmes de android"
date: 2023-06-09
classes: wide
header:
  teaser: /assets/images/2023-06-29-Crackmes_Android_Cap3/logo.png
  teaser_home_page: true
categories:
  - Crackmes
tags:
  - Android
  - Hacking
  - crackmes
  - Easy
---

# InsecureBankv2

Esta aplicación Android vulnerable se llama "InsecureBankv2" y está hecha para que los entusiastas de la seguridad y los desarrolladores aprendan las inseguridades de Android probando esta aplicación vulnerable.  ‣

Para descargar la aplicación APK, simplemente sigue este **[link](https://github.com/dineshshetty/Android-InsecureBankv2/blob/master/InsecureBankv2.apk)**. Antes de la instalación, asegúrate de tener un dispositivo en ejecución en el host, ya sea un emulador o un dispositivo físico. En este ejemplo, utilizaremos un dispositivo emulado con [**GenyMotion](https://angussmoody.github.io/android/Herramientas/#instalaci%C3%B3n-genymotion).**

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled.png)

Después de descargar la aplicación, dirígete al directorio donde se encuentra el archivo APK descargado. Luego, instala la aplicación en tu dispositivo usando el comando **`adb install InsecureBankv2.apk`**. Cuando abras la aplicación por primera vez en tu dispositivo, se te solicitarán algunos permisos. Haz clic en 'CONTINUE' para continuar.

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%201.png)

Con estos pasos se tiene la aplicación instalada en el dispositivo

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%202.png)

El siguiente paso es clonar el proyecto desde su repositorio en **[Git Hub](https://github.com/dineshshetty/Android-InsecureBankv2)** 

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%203.png)

Tener instalada la herramienta Git. En este [**link**](https://github.com/git-guides/install-git#debianubuntu) puedes encontrar las diferentes formas de instalar Git según tu sistema operativo. Una vez que cuentes con la herramienta, procede a clonar el proyecto con el siguiente comando `**git clone https://github.com/dineshshetty/Android-InsecureBankv2.git**` Para este ejemplo, realizaremos esta operación desde una termina**l [WSL](https://learn.microsoft.com/es-es/windows/wsl/about)** 

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%204.png)

Para ingresar al directorio descargado, utiliza el comando **`cd Android-InsecureBankv2/`**. Si tienes la herramienta **`exa`** instalada, puedes listar su contenido con **`exa`**. En caso de no contar con **`exa`**, puedes usar el comando **`ls -la`**.

Una vez que hayas confirmado los directorios, accede al directorio del servidor con el comando **`cd AndroLabServer/`** y nuevamente puedes listar los directorios o archivos que contenga.

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%205.png)

Debes prestar atención al archivo 'requirements.txt', que contiene las dependencias necesarias para el laboratorio. Para ejecutar el laboratorio, es esencial tener Python y pip instalados en tu sistema.

En el caso de estar utilizando Windows Subsystem for Linux (WSL), puedes instalar Python y pip con los siguientes comandos:

- Si estás como usuario root:
    - **`apt install python2`**
    - **`apt install python3-pip`**
- Si no estás como usuario root, utiliza **`sudo`** antes de los comandos:
    - **`sudo apt install python2`**
    - **`sudo apt install python3-pip`**

Estos comandos garantizarán que Python y pip estén correctamente instalados en tu sistema antes de ejecutar el laboratorio.

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%206.png)

Para instalar las dependencias necesarias, utiliza el comando **`pip install -r requirements.txt`**. Este comando se encargará de instalar todas las bibliotecas y paquetes especificados en el archivo 'requirements.txt'.

 

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%207.png)

Una vez que todas las dependencias estén instaladas, puedes verificar la IP del segmento de red utilizando el comando **`ifconfig`**. Para este ejemplo, asumimos que la interfaz de red se llama 'wifi0', por lo que ejecutas el comando **`ifconfig wifi0`**. Esto te mostrará la dirección IP de esa interfaz en tu red.

Luego, para ejecutar el servidor de la aplicación, utiliza el comando **`python2 app.py`**. Deberías obtener una respuesta similar a la que se muestra en la imagen

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%208.png)

Con el dato de la dirección IP en tu poder, sigue estos pasos:

1. Haz clic en los tres cuadritos (a menudo representados como un icono de menú) en la interfaz de la aplicación.
2. Luego, selecciona 'Preferences' o 'Preferencias' en el menú desplegable."

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%209.png)

Usa la dirección IP y puerto proporcionados por el servidor en las preferencias, luego haz clic en 'Submit' para guardar la configuración.

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2010.png)

Para comprobar que está configurado correctamente, intenta iniciar sesión con credenciales de prueba. Deberías ver un error que indica que el usuario no existe

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2011.png)

---

# Proxy

Para configurar el  [**Burp Suite](https://portswigger.net/burp)**  y interceptar el tráfico, sigue estos pasos:

1. Ve a la pestaña 'Proxy'.
2. Luego, selecciona 'Options'.
3. Haz clic en 'Add' o 'Agregar'.
4. Configura el puerto 9999 en todas las interfaces."

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2012.png)

En la ventana emergente, establece el puerto en '9999' y selecciona 'All interfaces' en la opción 'Bind to port’

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2013.png)

Dirígete a la pestaña 'Request handling' y activa la opción 'Support invisible proxying (enable if needed)'.

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2014.png)

Descarga el certificado de Burp para el proceso de proxy siguiendo estos pasos:

1. Ve a la pestaña 'Proxy'.
2. Luego, haz clic en 'Intercept'.
3. Finalmente, selecciona 'Open Browser' para abrir el navegador de Burp.

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2015.png)

1. En el navegador de Burp Suite, accede a **[http://burp](http://burp/)**.
2. Haz clic en 'CA Certificate' para descargar el certificado.
3. Después de descargarlo, cambia la extensión del archivo a .crt.

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2016.png)

Utilizando la herramienta **`adb`**, copia el certificado al dispositivo con el comando **`adb push cacert.crt /storage/emulated/0/Download/`**.

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2017.png)

En el dispositivo, ve a 'Settings' (Configuración) para instalar el certificado

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2018.png)

"Una vez allí, escribe 'install' y selecciona 'Install from SD card' (Instalar desde tarjeta SD) entre las opciones disponibles.

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2019.png)

Después, haz clic en 'Install from SD card' (Instalar desde tarjeta SD).

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2020.png)

Una vez que hayas hecho clic en 'Install from SD card', busca el directorio donde guardaste el certificado, en este caso, selecciona 'Download’

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2021.png)

Verás que el certificado se encuentra en esta ruta.

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2022.png)

Ahora, haz clic en el certificado y cuando te pida un nombre, déjalo como 'cacert' y haz clic en 'Ok’

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2023.png)

El certificado ahora está instalado y listo para su uso.

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2024.png)

Configura el proxy manual desde la configuración de Wi-Fi. Desde allí, selecciona 'AndroidWifi'

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2025.png)

1. Haz clic en 'Editar' en la parte superior de la pantalla.
2. En 'Proxy hostname', coloca la IP de tu host.
3. En 'Proxy port', ingresa el puerto 9999.
4. Luego, haz clic en 'SAVE' para guardar la configuración.

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2026.png)

Con estos pasos, ahora puedes interceptar el tráfico de la aplicación.

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2027.png)

Puedes enviar esta solicitud al repetidor para realizar una enumeración de usuarios. Si intentas con cualquier usuario, recibirás un mensaje que indica que el usuario no existe

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2028.png)

Sin embargo, si pruebas con un usuario válido, recibirás un mensaje que indica 'Wrong Password' (Contraseña incorrecta).

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2029.png)

---

# Login Bypass

Puedes utilizar la herramienta ****[MobSF](https://github.com/MobSF/Mobile-Security-Framework-MobSF),** para realizar análisis estáticos y dinámicos de aplicaciones móviles. Los requisitos previos y la instalación paso a paso se encuentran en este ****[link](https://angussmoody.github.io/android/Herramientas/).**

Una vez instalada la aplicación, puedes ejecutarla utilizando el archivo **`run.bat`**.

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2030.png)

Una vez que la herramienta esté en funcionamiento, puedes acceder a la aplicación desde tu navegador web utilizando cualquiera de las siguientes URL: **`http://127.0.0.1:8000/`** o **`http://localhost:8000/`**. Deberías ver la interfaz de la aplicación como se muestra en la imagen

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2031.png)

Bajo la sección 'Upload & Analyze', carga la APK que deseas analizar, en este caso, 'InsecureBankv2.apk'. La herramienta realizará un análisis y puede tomar un tiempo mientras procesa la aplicación.

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2032.png)

Una vez que se complete el análisis, verás un resultado similar a esto:

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2033.png)

Puedes aprovechar esta herramienta para ver las actividades de la aplicación, en este caso, hay 10 actividades. Haz clic en 'View' y accede a la sección donde se muestran estas actividades. En el contexto de Android, una actividad es equivalente a una pantalla de la interfaz de usuario, similar a las ventanas de una aplicación de escritorio. Una aplicación Android puede contener una o más actividades, lo que representa una o más pantallas.

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2034.png)

Ahora, utilizando la herramienta [**jadx**](https://github.com/skylot/jadx), puedes ver la aplicación y sus actividades. Observarás que muchas de estas actividades tienen el atributo **`android:exported="true"`**. Esto indica que estas actividades pueden ser accedidas por otras aplicaciones.

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2035.png)

Al investigar, descubrimos que si el atributo **`android:exported`** está configurado en 'true', permite que las actividades sean accesibles desde componentes externos, lo que podría generar un fallo de seguridad al permitir un posible bypass en la aplicación de inicio de sesión.

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2036.png)

Puedes intentar llamar a las aplicaciones que tienen el atributo **`android:exported`** en 'true' utilizando el comando **`adb shell am start -n com.android.insecurebankv2/com.android.insecurebankv2.ChangePassword`** con la herramienta **`adb`**. Esto se debe a que el atributo **`am`** (Activity Manager) permite realizar diversas operaciones relacionadas con las actividades de la aplicación, y **`-n`** se utiliza para especificar el nombre completo de la actividad que deseas iniciar, en este caso, la actividad se llama 'ChangePassword'. Esto podría permitir un posible bypass en el proceso de inicio de sesión de la aplicación

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2037.png)

Al consumir la actividad e ingresar datos en el campo de cambio de contraseña con un texto sencillo, la aplicación te informa que la contraseña no es lo suficientemente compleja

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2038.png)

Cuando ingresamos una contraseña más robusta, la aplicación realiza una petición que podemos observar a través del proxy que configuramos. Sin embargo, esta petición resulta en un error debido a la falta de un usuario. Aunque hemos enumerado algunos usuarios, la aplicación tiene una configuración defectuosa que no solicita la contraseña actual del usuario ni requiere autorización para realizar el cambio de contraseña.

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2039.png)

Al enviar esta solicitud al repetidor, intentamos cambiar la contraseña del usuario enumerado 'jack'. Observamos un mensaje con un estado '200 OK' que indica que el cambio de contraseña se realizó con éxito

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2040.png)

Ahora intentamos iniciar sesión con estas credenciales.

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2041.png)

Observamos que ahora tenemos acceso con las credenciales de este usuario

![Untitled](/assets/images/2023-06-29-Crackmes_Android_Cap3/Untitled%2042.png)