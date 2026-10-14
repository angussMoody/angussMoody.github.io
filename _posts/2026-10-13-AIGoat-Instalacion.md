---
layout: single
title: AIGoat – Instalación del laboratorio en Windows
comments: true
excerpt: "AIGoat – Instalación del laboratorio en Windows"
date: 2026-10-13
classes: wide
header:
  teaser: /assets/images/2026-10-13-AIGoat-Instalacion/logo.jpg
  teaser_home_page: true
categories:
  - IA
tags:
  - IA
  - LLM
  - prompt
  - Hacklab
  - Red Team
---

En este artículo vamos a instalar **AIGoat**, una plataforma deliberadamente vulnerable creada por el [AI Security Consortium](https://github.com/AISecurityConsortium/AIGoat){:target="_blank"} para practicar *red teaming* contra modelos de lenguaje. AIGoat simula una tienda de e-commerce con un asistente de compras llamado **Cracky**, que corre un LLM real (**Mistral** a través de **Ollama**) conectado a una base de datos de productos, un sistema de órdenes y una base de conocimiento vectorial que se puede envenenar. Todos los laboratorios están mapeados al **OWASP Top 10 para LLM 2026**, al **OWASP Top 10 para Aplicaciones Agénticas 2026** y al **OWASP MCP Top 10**, y todo corre en local, gratis y sin API keys.

Para este laboratorio vamos a hacer la instalación en **Windows 11** de forma nativa, y veremos un par de problemas que nos vamos a encontrar en el camino y cómo los solucionamos.

![arquitectura.png](/assets/images/2026-10-13-AIGoat-Instalacion/arquitectura.png)

# Contenido:

[Requisitos](#requisitos)

[Verificando las herramientas](#verificando-las-herramientas)

[Verificando los recursos](#verificando-los-recursos)

[Instalando lo que nos falta](#instalando-lo-que-nos-falta)

[Clonando el repositorio](#clonando-el-repositorio)

[Por qué start.sh no corre en Windows (y cómo solucionarlo)](#y-el-startsh-en-windows)

[Levantando AIGoat](#levantando-aigoat)

[Accediendo a la aplicación](#accediendo-a-la-aplicación)

[Detener y reiniciar](#detener-y-reiniciar)

## Requisitos

Antes de empezar, vamos a revisar lo que nos pide el proyecto:

| Requisito | Mínimo | Recomendado |
| --- | --- | --- |
| **Python** | 3.11 (exactamente) | 3.11 |
| **Node.js** | 18+ | 18+ |
| **Git** | cualquier versión | — |
| **Ollama** | última versión | — |
| **RAM** | 8 GB **libres** | 16 GB+ en total |
| **Disco** | 6 a 10 GB libres | — |
| **GPU** | no es obligatoria | NVIDIA o Apple Silicon con 6 GB+ de VRAM |

Algo importante es que Mistral 7B necesita cerca de 4.5 GB de RAM, así que si no tenemos al menos 8 GB **libres** el chatbot no va a funcionar. Sin GPU las respuestas tardan entre 10 y 30 segundos, con GPU entre 1 y 3 segundos.

## Verificando las herramientas

Vamos a confirmar qué tenemos instalado y en qué versión:

**Python**, que se usa para el backend (FastAPI). Acá debemos tener cuidado, porque el script de instalación exige **exactamente Python 3.11** y rechaza cualquier otra versión, en mi caso tenía instalada la 3.12, así que más adelante vamos a instalar la 3.11 al lado.

```jsx
PS D:\> python --version
Python 3.12.10
PS D:\>
```

**Node.js**, necesario para el frontend en React.

```jsx
PS D:\> node --version
v24.19.0
PS D:\>
```

**Git**, para clonar el repositorio.

```jsx
PS D:\> git --version
git version 2.55.0.windows.5
PS D:\>
```

**Ollama**, el runtime que nos permite correr el LLM en local, en mi caso no lo tenía instalado, si tienes todo instalado y en las versiones necesarias puedas saltarte la parte de [Instalando lo que nos falta](#instalando-lo-que-nos-falta).

```jsx
PS D:\> ollama --version
ollama : El término 'ollama' no se reconoce como nombre de un cmdlet, función, archivo de script o programa
ejecutable.
PS D:\>
```

## Verificando los recursos

Ahora vamos a revisar cuánta RAM libre, disco y GPU tenemos disponible con PowerShell:

```jsx
PS D:\> $os = Get-CimInstance Win32_OperatingSystem
PS D:\> "RAM total: {0:N1} GB" -f ($os.TotalVisibleMemorySize/1MB)
RAM total: 31,7 GB
PS D:\> "RAM libre: {0:N1} GB" -f ($os.FreePhysicalMemory/1MB)
RAM libre: 17,4 GB
PS D:\> Get-PSDrive -PSProvider FileSystem

Name Used (GB) Free (GB) Provider   Root CurrentLocation
---- --------- --------- --------   ---- ---------------
C       142,10    322,50 FileSystem C:\
D       341,50    146,80 FileSystem D:\

PS D:\>
```

Y con `nvidia-smi` revisamos la GPU:

```jsx
PS D:\> nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv
name, memory.total [MiB], memory.free [MiB]
NVIDIA GeForce RTX 3050 Ti Laptop GPU, 4096 MiB, 3990 MiB
PS D:\>
```

Con 17 GB de RAM libre y una RTX 3050 Ti de 4 GB estamos bien. La GPU tiene menos de los 6 GB recomendados, así que el modelo no va a caber completo en VRAM, pero Ollama lo reparte entre GPU y CPU automáticamente, como veremos más adelante.

## Instalando lo que nos falta

Para instalar Python 3.11 y Ollama vamos a usar `winget`. Ambos se instalan a nivel de usuario, así que **no necesitamos permisos de administrador**.

```jsx
PS D:\> winget install -e --id Python.Python.3.11 --scope user
...
Instalado correctamente
PS D:\> winget install -e --id Ollama.Ollama
...
El hash del instalador se verificó correctamente
Iniciando instalación de paquete...
Instalado correctamente
PS D:\>
```

Cerramos y abrimos de nuevo la terminal para que se actualice el PATH y verificamos. Como ahora tenemos dos versiones de Python, usamos el lanzador `py` para llamar a la 3.11:

```jsx
PS D:\> py -3.11 --version
Python 3.11.9
PS D:\> ollama --version
ollama version is 0.40.3
PS D:\>
```

## Clonando el repositorio

Vamos al repositorio oficial de [AIGoat](https://github.com/AISecurityConsortium/AIGoat){:target="_blank"} en GitHub.

![repo.png](/assets/images/2026-10-13-AIGoat-Instalacion/repo.png)

Y aquí nos encontramos con el primer problema, si lo clonamos de forma normal en Windows el checkout falla:

```jsx
PS D:\> git clone https://github.com/AISecurityConsortium/AIGoat.git
Cloning into 'AIGoat'...
error: invalid path 'media/The "Adversarial" Red Team T-Shirt.png'
fatal: unable to checkout working tree
warning: Clone succeeded, but checkout failed.
PS D:\>
```

Esto pasa porque el repositorio tiene unas imágenes de productos con **comillas dobles** en el nombre (`The "Adversarial" Red Team T-Shirt.png`), y NTFS no permite ese carácter en los nombres de archivo. Son solo 4 imágenes de la tienda, así que la solución es clonar sin hacer checkout, usar un **sparse-checkout** que excluya los archivos con comillas, y hacer el checkout desactivando la validación `core.protectNTFS` para que git simplemente se los salte:

```jsx
PS D:\> git clone --no-checkout https://github.com/AISecurityConsortium/AIGoat.git
PS D:\> cd AIGoat
PS D:\AIGoat> git sparse-checkout set --no-cone '/*' '!/media/*"*'
PS D:\AIGoat> git -c core.protectNTFS=false checkout main
Already on 'main'
Your branch is up to date with 'origin/main'.
PS D:\AIGoat>
```

Ya con esto tenemos todo el proyecto descargado, a excepción de esas 4 imágenes, que solo hacen que esos productos se vean sin foto en la tienda.

```jsx
PS D:\AIGoat> ls

Mode   LastWriteTime            Length Name
----   -------------            ------ ----
d----- 13/10/2026 5:15:47 p. m.        .github
d----- 13/10/2026 5:15:47 p. m.        alembic
d----- 13/10/2026 5:15:47 p. m.        app
d----- 13/10/2026 5:15:47 p. m.        colab_notebooks
d----- 13/10/2026 5:15:47 p. m.        config
d----- 13/10/2026 5:15:47 p. m.        docker
d----- 13/10/2026 5:15:47 p. m.        docs
d----- 13/10/2026 5:15:47 p. m.        frontend
d----- 13/10/2026 5:15:47 p. m.        guardrails
d----- 13/10/2026 5:15:47 p. m.        media
d----- 13/10/2026 5:15:47 p. m.        prompts
d----- 13/10/2026 5:15:47 p. m.        scripts
d----- 13/10/2026 5:15:47 p. m.        tests
-a---- 13/10/2026 5:15:47 p. m. 810    alembic.ini
-a---- 13/10/2026 5:15:47 p. m. 34436  README.md
-a---- 13/10/2026 5:15:47 p. m. 1083   requirements.txt
...

PS D:\AIGoat>
```

## Por qué start.sh no corre en Windows (y cómo solucionarlo) {#y-el-startsh-en-windows}

El README nos dice que todo se levanta con un solo comando:

```jsx
./scripts/start.sh
```

Pero si revisamos el script, vemos que **no funciona en Windows**, ni siquiera desde Git Bash, por varias razones:

- Busca el binario `python3.11`, que en Windows no existe (aquí se usa `py -3.11`).
- Activa el entorno virtual con `venv/bin/activate`, y en Windows la ruta es `venv\Scripts\`.
- Usa `lsof` y `pgrep` para revisar los puertos y procesos, que no vienen en Git Bash.

Las alternativas serían usar **WSL** o **Docker Desktop**, pero en WSL el Ollama no ve la GPU sin configuración adicional, y la opción de Docker requiere asignarle al menos 12 GB de RAM a Docker Desktop. Así que la opción más limpia es correrlo de forma **nativa en Windows**, y para eso vamos a usar dos scripts en PowerShell que hacen exactamente los mismos pasos que `start.sh` y `stop.sh`:

- [start.ps1](/assets/files/aigoat/start.ps1)
- [stop.ps1](/assets/files/aigoat/stop.ps1)

Los descargamos y los guardamos dentro de la carpeta `scripts` del proyecto. El `start.ps1` hace lo siguiente:

1. Crea el entorno virtual con Python 3.11 e instala las dependencias de `requirements.txt`.
2. Revisa si Ollama está corriendo (si no, lo inicia con `ollama serve`) y descarga el modelo configurado en `config/config.yml` si no lo tenemos.
3. Aplica las migraciones de la base de datos con Alembic.
4. Carga los datos de demo (usuarios, productos, retos y base de conocimiento).
5. Levanta el backend (uvicorn) en el puerto 8000.
6. Instala las dependencias del frontend y lo levanta en el puerto 3000.

Antes de ejecutarlo, un ajuste recomendado: en `config/config.yml` el timeout de Ollama viene en 90 segundos. La primera vez que le escribimos a Cracky, Ollama tiene que cargar el modelo en memoria, y con una GPU pequeña esa primera respuesta puede pasarse de ese tiempo, y nos responde con `I'm sorry, I couldn't process that request.`. Para evitarlo lo subimos a 180:

```yaml
ollama:
  base_url: "http://localhost:11434"
  model: "mistral"
  agent_model: null
  timeout: 180
```

## Levantando AIGoat

Primero vamos a descargar el modelo **Mistral** (unos 4.4 GB), el script también lo hace solo, pero así podemos ver el progreso:

```jsx
PS D:\AIGoat> ollama pull mistral
pulling manifest
...
writing manifest
success
PS D:\AIGoat> ollama list
NAME              ID              SIZE      MODIFIED
mistral:latest    6577803aa9a0    4.4 GB    45 seconds ago
PS D:\AIGoat>
```

Ahora sí ejecutamos el script. Usamos `-ExecutionPolicy Bypass` porque por defecto Windows no deja ejecutar scripts descargados:

```jsx
PS D:\AIGoat> powershell -ExecutionPolicy Bypass -File .\scripts\start.ps1

==========================================
       AI Goat -- Starting Application
==========================================

[OK]    Python 3.11 virtual environment
[INFO]  Checking Python dependencies...
[OK]    Python dependencies ready
[INFO]  Checking Ollama...
[OK]    Ollama is running
[OK]    Model 'mistral' is available
[INFO]  Applying database migrations...
INFO  [alembic.runtime.migration] Context impl SQLiteImpl.
INFO  [alembic.runtime.migration] Will assume non-transactional DDL.
[OK]    Database schema ready
[OK]    Database already has required data
[OK]    Support tickets ready
[OK]    Challenge metadata synced
[INFO]  Starting backend on port 8000...
[OK]    Backend ready (PID: 1176)
[INFO]  Starting frontend on port 3000...
[OK]    Frontend ready (PID: 1548)

==========================================
       AI Goat is running!
==========================================

  Application:  http://localhost:3000
  API Docs:     http://localhost:8000/docs
  Demo login:   alice / password123
  Admin login:  admin / admin123
  Stop:         .\scripts\stop.ps1   (add -Clean to delete the DB)

PS D:\AIGoat>
```

La primera vez tarda varios minutos, porque tiene que instalar todas las dependencias de Python y de Node, las siguientes veces es mucho más rápido.

Con `ollama ps` podemos ver cómo quedó repartido el modelo, en mi caso como la GPU tiene 4 GB, Ollama dejó el 49% en GPU y el 51% en CPU. Aun así, Cracky responde en unos 10 segundos.

```jsx
PS D:\AIGoat> ollama ps
NAME              ID              SIZE      PROCESSOR          CONTEXT    RUNNER      UNTIL
mistral:latest    6577803aa9a0    5.1 GB    51%/49% CPU/GPU    4096       llamacpp    4 minutes from now
PS D:\AIGoat>
```

## Accediendo a la aplicación

Ya con todo arriba vamos a nuestro navegador y entramos a `http://localhost:8000/docs`, donde tenemos la documentación de la API en Swagger, que nos va a servir más adelante para atacar los endpoints directamente.

![api-docs.png](/assets/images/2026-10-13-AIGoat-Instalacion/api-docs.png)

Ahora vamos a `http://localhost:3000` y nos carga la página de login.

![login.png](/assets/images/2026-10-13-AIGoat-Instalacion/login.png)

Las credenciales por defecto que vienen documentadas en el README son:

| Usuario | Contraseña | Rol |
| --- | --- | --- |
| `alice` | `password123` | Usuario normal |
| `bob` | `password123` | Usuario normal |
| `charlie` | `password123` | Usuario normal |
| `frank` | `password123` | Usuario normal |
| `admin` | `admin123` | Administrador |

Iniciamos sesión con el usuario `alice` y la contraseña `password123`

![login-alice.png](/assets/images/2026-10-13-AIGoat-Instalacion/login-alice.png)

Y ya tenemos acceso a la tienda de **AI Goat**, arriba a la derecha podemos ver el nivel de defensa activo, en este caso **L0 Vulnerable**, que es el nivel sin ninguna protección.

![home.png](/assets/images/2026-10-13-AIGoat-Instalacion/home.png)

En la esquina inferior derecha tenemos el botón para abrir el chat con **Cracky**, vamos a escribirle algo para confirmar que el modelo está funcionando:

![cracky.png](/assets/images/2026-10-13-AIGoat-Instalacion/cracky.png)

Cracky nos responde, así que la conexión con Ollama y Mistral está funcionando correctamente.

En el menú **Try** encontramos los **Attack Labs**, donde están los laboratorios guiados y los podemos filtrar por framework, riesgo, superficie de ataque o dificultad.

![labs.png](/assets/images/2026-10-13-AIGoat-Instalacion/labs.png)

También tenemos los **retos CTF**, que son los que vamos a ir resolviendo en próximos artículos.

![challenges.png](/assets/images/2026-10-13-AIGoat-Instalacion/challenges.png)

Y en el menú **Learn** tenemos la sección del **OWASP Top 10**, donde podemos ver cada riesgo con los laboratorios y retos que tiene asociados.

![owasp.png](/assets/images/2026-10-13-AIGoat-Instalacion/owasp.png)

Por último vamos a cerrar sesión e iniciar con el usuario `admin` y la contraseña `admin123`

![login-admin.png](/assets/images/2026-10-13-AIGoat-Instalacion/login-admin.png)

En el **Admin Dashboard** podemos confirmar que el servicio de Ollama está disponible con el modelo `mistral`, además de las estadísticas de la tienda. Desde el usuario administrador también tenemos acceso al **Admin Assistant**, la página de RAG y el **Agentic Kill Chain**, que son exclusivos para staff.

![admin-dashboard.png](/assets/images/2026-10-13-AIGoat-Instalacion/admin-dashboard.png)

> **Nota:** los laboratorios de agentes, MCP y el Agentic Kill Chain necesitan un modelo que soporte *tool calling* de forma nativa, y Mistral no lo tiene. Para esos labs podemos descargar el modelo recomendado con `ollama pull qwen3.5:9b` (unos 6.6 GB) y seleccionarlo en el desplegable de modelos de cada consola.

## Detener y reiniciar

Para detener todo (frontend, backend y Ollama si fue el script quien lo inició) usamos:

```jsx
PS D:\AIGoat> powershell -ExecutionPolicy Bypass -File .\scripts\stop.ps1

==========================================
       AI Goat -- Stopping Application
==========================================

[INFO]  Stopping frontend (PID: 21944)...
[OK]    frontend stopped
[INFO]  Stopping backend (PID: 23360)...
[OK]    backend stopped
[INFO]  No PID file for ollama
[OK]    AI Goat stopped.

PS D:\AIGoat>
```

Y si queremos reiniciar con la base de datos limpia, por ejemplo después de envenenar la base de conocimiento en algún laboratorio, usamos el parámetro `-Fresh`, que borra la base de datos y el vector store antes de iniciar:

```jsx
PS D:\AIGoat> powershell -ExecutionPolicy Bypass -File .\scripts\start.ps1 -Fresh
```

Los equivalentes en Linux y macOS son:

```bash
./scripts/stop.sh            # detener todo
./scripts/start.sh --fresh   # borrar la base de datos y volver a iniciar
```

Ya con esto tenemos nuestro laboratorio de **AIGoat** listo para empezar a practicar *prompt injection*, extracción del system prompt, envenenamiento de RAG y muchos otros ataques contra LLMs. En los próximos artículos vamos a ir resolviendo los retos.

> AIGoat es una aplicación **deliberadamente vulnerable**, no la expongas a internet ni a redes en las que no confíes.
