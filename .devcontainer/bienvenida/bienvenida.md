---
title: Bienvenida a la Nueva Somosaguas
subtitle: Manual de la primera vez
author: Nueva Somosaguas
abstract: |
  Este sistema trae ya instalado todo lo que el pensum necesita: los lenguajes, los editores, las bibliotecas y los lectores, con las mismas versiones para todos. No hay nada que configurar antes de empezar. Estas páginas cuentan dónde está cada cosa y por dónde empezar; si solo lees una sección, que sea la primera.
---

## Los cinco primeros minutos

**El menú.** El botón del panel de abajo abre el menú de aplicaciones, con los favoritos arriba: el terminal, VS Code, RStudio, Obsidian, Zotero, el navegador y el gestor de archivos. Se puede escribir para buscar: «calc», «pdf», «notas».

**Las carpetas.** Todo lo tuyo vive en tu carpeta personal, y el gestor de archivos (Thunar) tiene un marcador para cada una:

| Carpeta | Qué va ahí |
| :--- | :--- |
| `Documents` | Tus trabajos. Aquí están este manual, el de la terminal y la biblioteca de la Nueva Somosaguas |
| `Biblioteca` | Tus referencias y sus PDF, que Zotero guarda solo |
| `Notas` | Tu cuaderno de Obsidian |
| `Downloads` | Lo que baja el navegador |
| `Cursos` | Los vídeos que descargues con `yt-dlp` |
| `Screenshots` | Las capturas de pantalla |

**Comprobar que todo funciona.** Abre un terminal y escribe:

```bash
verificar_entorno.sh
```

En unos segundos compila un documento en Typst, hace una cuenta en Julia y una consulta en SQL. Si termina con «Entorno calibrado. Comience a calcular.», el sistema está listo.^[En Codespaces y en el contenedor local está en la carpeta del repositorio: `./verificar_entorno.sh`.]

**Si arrancaste desde un USB.** Estás en la sesión *en vivo*: nada se guarda al apagar. La contraseña es `somosaguas`. Para quedarte con el sistema, el icono *Instalar la Nueva Somosaguas* del escritorio lo copia al disco, con cifrado si lo marcas.^[En vivo, el equipo no se suspende solo: al despertar, el USB volvería como otro dispositivo y el sistema dejaría de leerse. Instalado, sí se suspende.]

## La terminal

La terminal no es un remanente del pasado: es la forma más rápida y reproducible de trabajar con datos. Se abre de tres maneras:

| Cómo | Qué abre |
| :--- | :--- |
| `F12` | Un terminal que baja desde arriba; `F12` otra vez lo esconde |
| `Super+Intro` en Thunar | Un terminal en la carpeta que estás viendo (`Super` es la tecla de Windows) |
| *Sesión de trabajo*, en el menú | Zellij, con una pestaña por herramienta: terminal, git, Julia, R, SQL, lecturas y sistema |

Tres ayudas para no memorizar nada:

- **`Ctrl+R`** busca en todo lo que has escrito antes: teclea un trozo y elige.
- **`tldr` y una orden** (`tldr tar`, o `tldr -L es tar` en español) da ejemplos de uso en lugar del manual completo.
- ***The Linux Command Line***, el libro de William Shotts, está en `Documents`: es el mejor sitio por donde empezar.

**Git.** La primera vez que hagas un commit, Git te pedirá tu correo; con el de tu cuenta de GitHub, una vez y para siempre:

```bash
git config --global user.email "tu@correo.es"
```

## Calcular

| Lenguaje | Cómo se abre |
| :--- | :--- |
| Julia | `julia` en el terminal, o `pluto` para los cuadernos reactivos (en el navegador, `localhost:1234`) |
| R | RStudio, en el menú, o `R` en el terminal |
| Python | `python`, con pandas, polars y DuckDB ya instalados |
| SQL | `psql` (tu base de PostgreSQL ya existe) y `sqlite3` |

Las versiones de todo están congeladas por semestre: un laboratorio de hoy da los mismos números dentro de diez años. No instales paquetes en el sistema; si un proyecto necesita otros, van en el propio proyecto (`Project.toml` en Julia, `uv` en Python).

Si un cálculo agota la memoria, el sistema lo cierra antes de congelarse y te avisa con una notificación. No es un fallo: es la señal de que hay que trabajar con menos datos a la vez.

## Escribir y citar

Los informes se escriben en **Quarto** o en **Typst**, y salen ya con el diseño de la Nueva Somosaguas, el de este manual. Incluso un Markdown suelto:

```bash
pandoc informe.md -o informe.pdf
```

**Citar.** La biblioteca de la Nueva Somosaguas y la tuya están siempre disponibles. En el texto se escribe la clave precedida de una arroba y la lista de referencias sale sola al final, como esta: @plomin2018blueprint.

- **Guardar una referencia:** en Firefox o Brave, el botón de Zotero guarda la página que lees, con su PDF, en `Biblioteca`.
- **Buscar una clave:** en VS Code y en Obsidian, al escribir `@` aparece la lista de referencias: se escribe un autor o una palabra del título y se elige.
- **Desde el terminal:** `bibsearch` busca en todas tus bibliografías, `bibpdf` abre el PDF de una entrada y `bibclave` copia su clave al portapapeles.
- **Empezar un trabajo:** `nuevo-proyecto nombre` crea su carpeta, con los datos, el análisis, las pruebas y el informe, y `./construir.sh` lo compila. Lo explica `Documents/Proyectos.pdf`.
- **Una web propia:** `nueva-web nombre` crea una con el diseño de la Nueva Somosaguas, para tus entradas, tus análisis en R o Julia y las notas de Obsidian que marques con `publicar: true` (las demás no salen nunca).
- **Para entregar un trabajo:** `bibcongelar informe.md` guarda a su lado `referencias.bib`, con lo que cita y nada más: así se compila igual en cualquier ordenador.
- **Lo que no se cita** (datos, documentación, cursos) va a los marcadores: *Marcadores*, en el menú y en la barra del navegador, los muestra, con lo que guardes como marcador en Firefox o Brave, y basta arrastrar un enlace sobre la página para guardarlo; `B` en Newsboat guarda un artículo, y `marcadores` los busca desde el terminal.

## Leer, anotar y capturar

- **PDF:** Zathura, que abre este manual. `J` y `K` pasan de página, `Ctrl+R` cambia al modo noche y `C` copia el texto de la página.
- **Libros EPUB:** Foliate.
- **Retomar una lectura:** `lecturas` en el terminal lista lo último que abriste en Zathura o Foliate, con la página a la que llegaste, y lo abre ahí.
- **En papel:** `biblectura` crea en Obsidian la nota de lectura de un libro de la bibliografía, con sus datos, y `lecturas` la lista con los demás.
- **Revistas y preprints:** `newsboat` en el terminal, ya suscrito a las fuentes de la facultad. Sobre un artículo, `o` pregunta qué hacer con él: abrirlo en el navegador (`Intro`), guardarlo en tu biblioteca de Zotero, con su clave para citarlo (`z`), o en los marcadores (`b`); `,p` baja su PDF si es un preprint.
- **Notas:** Obsidian, en `Notas`. La primera vez pregunta si confías en el cuaderno: acepta.
- **A mano:** Xournal++, para escribir y anotar PDF.

| Tecla | Captura |
| :--- | :--- |
| `Impr Pant` | Una zona, al portapapeles |
| `Ctrl+Impr` | El texto de una zona, reconocido (OCR), al portapapeles |
| `Super+Mayús+Impr` | La última captura, abierta en Xournal++ para anotarla |
| `Ctrl+Alt+Impr` | Empieza o termina una grabación de la pantalla |

## Si algo va mal

- **Un programa no responde:** `htop` en el terminal muestra qué consume la memoria y el procesador; `k` cierra el proceso elegido.
- **El sistema no calcula como debe:** vuelve a ejecutar `verificar_entorno.sh`; dice qué parte falla.
- **Contraseñas:** en el sistema instalado, KeePassXC las guarda cifradas y las rellena en el navegador. Nunca en un documento ni en un repositorio.
- **Dudas:** la web, <https://nuevasomosaguas.github.io>, tiene el currículo, la guía autodidacta y la página del entorno, con todo lo que este manual resume.

**Un curso en vídeo.** `mpv` y la dirección de la lista lo reproduce, y al volver sigue en la clase y el minuto donde lo dejaste; `n` copia ese momento para tus notas. Cómo anotar y practicar lo que enseña, en `Documents/Aprender.pdf`.

Este manual se abre solo la primera vez. Después está siempre en `Documents/Bienvenida.pdf`.

## Referencias
