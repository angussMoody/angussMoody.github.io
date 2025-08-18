---
layout: single
title: "Stack Six"
permalink: /pwn/phoenix/stack-six/
parent: Phoenix
comments: true
excerpt: "Stack Six"
classes: wide
header:
  teaser: /assets/images/2025-08-17-Phoenix/logo.jpg
categories: [PWN]
tags: [PWN, Linux, Hacking, Easy]
---


- ¿Dónde se equivoca Stack Six y qué puedes hacer con él?
- Dependiendo de la arquitectura en la que estés haciendo esto, puede que necesites explorar más y ser creativo con la forma de resolver este nivel.
- La macro GREET depende de la arquitectura

```csharp
/*
 * phoenix/stack-six, by https://exploit.education
 *
 * Can you execve("/bin/sh", ...) ?
 *
 * Why do fungi have to pay double bus fares? Because they take up too
 * mushroom.
 */

#include <err.h>       // Incluye funciones para mostrar errores y terminar el programa (err, errx, etc.)
#include <stdio.h>     // Incluye funciones de entrada/salida estándar (printf, etc.)
#include <stdlib.h>    // Incluye funciones de utilidad como getenv(), malloc(), etc.
#include <string.h>    // Incluye funciones para manejo de strings (strlen, strcpy, strncpy, etc.)
#include <unistd.h>    // Incluye funciones del sistema como execve(), etc.

#define BANNER \
  "Welcome to " LEVELNAME ", brought to you by https://exploit.education"
// Define una cadena constante con un mensaje de bienvenida

char *what = GREET; // Puntero a char inicializado con GREET (probablemente definido en un macro al compilar)

char *greet(char *who) {                // Función greet que recibe un puntero a char (nombre)
  char buffer[128];                     // Declara un buffer local de 128 bytes
  int maxSize;                          // Variable para tamaño máximo permitido

  maxSize = strlen(who);                // maxSize se iguala a la longitud de "who"
  if (maxSize > (sizeof(buffer) - 1)) { // Si la longitud es mayor que el tamaño del buffer menos 1
    maxSize = sizeof(buffer) - 1;       // Ajusta maxSize para evitar desbordar y dejar espacio para '\0'
  }

  strcpy(buffer, what);                 // Copia el contenido de "what" dentro del buffer
  strncpy(buffer + strlen(buffer),      // Copia a partir del final del contenido ya copiado
          who,                          // Lo que viene de "who"
          maxSize);                     // Hasta maxSize caracteres

  return strdup(buffer);                // Duplica el contenido del buffer en memoria dinámica y lo retorna
}

int main(int argc, char **argv) {       // Función principal
  char *ptr;                            // Puntero para almacenar valor de variable de entorno
  printf("%s\n", BANNER);               // Imprime el mensaje de bienvenida

#ifdef NEWARCH                          // Si se compiló con la macro NEWARCH definida
  if (argv[1]) {                        // Si hay argumento en la línea de comandos
    what = argv[1];                     // Cambia "what" para apuntar a ese argumento
  }
#endif

  ptr = getenv("ExploitEducation");     // Busca la variable de entorno "ExploitEducation"
  if (NULL == ptr) {                    // Si no existe esa variable de entorno
    errx(1, "Please specify an environment variable called ExploitEducation");
    // Muestra un error y termina con código de salida 1
  }

  printf("%s\n", greet(ptr));           // Llama a greet con el valor de la variable de entorno y lo imprime
  return 0;                             // Termina el programa
}
```