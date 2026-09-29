# entorno

El entorno de trabajo de la [Nueva Somosaguas](https://nuevasomosaguas.github.io/entorno.html): una imagen de Debian 13 con Julia, R, Python, SQL, Quarto, Typst y la terminal de Unix, lista para abrir en el navegador o en VS Code.

[![Abrir en GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/nuevasomosaguas/entorno)

## Puertas de entrada

1. **Navegador.** Pulsa el botón de arriba. GitHub Codespaces construye el entorno y lo abre en VS Code, sin instalar nada.
2. **Devcontainer.** Con Docker y la extensión *Dev Containers* de VS Code, clona el repositorio, elige *Reopen in Container* y luego *Nueva Somosaguas (local)*: la misma imagen, sin las aplicaciones gráficas.

## Qué incluye

| | |
| :--- | :--- |
| Julia 1.13 | Pluto, CSV, DataFrames, CairoMakie y `somosaguas-makie`, ya precompilados |
| R 4.5 | tidyverse, ragg, knitr, rmarkdown, DBI, RSQLite, RPostgres y `somosaguas-ggplot2` |
| Python 3 | pandas, polars, pyarrow, duckdb, psycopg y ruff en `/opt/venv` |
| SQL | SQLite y PostgreSQL (el usuario `vscode` ya tiene base propia: basta `psql`) |
| Documentos | Quarto y Typst, con EB Garamond y Fira Code |
| Terminal | git, nano, jq, ripgrep, bat, fd, xsv, GNU parallel, curl, wget, yt-dlp y ffmpeg |

yt-dlp deja de funcionar cada vez que YouTube cambia su web; se pone al día con `pip install -U yt-dlp`.
| Aplicaciones | RStudio Server |
| Escritorio (solo Codespaces) | XFCE con Obsidian, Zathura, Mousepad, Brave y mpv |

VS Code formatea el código al guardar y viene con estas extensiones:

* **Julia**, **R** (los gráficos se abren en un panel, con httpgd), **Quarto** y **Typst** (Tinymist).
* **Python** con Jupyter y Ruff.
* **SQL** con SQLTools: la base PostgreSQL del usuario ya aparece como *PostgreSQL local*, y cualquier archivo `.db` de SQLite se abre con el driver de SQLite.
* **Rainbow CSV**, para leer y consultar CSV por columnas.

## Puertos

| Puerto | Servicio | Cómo se abre |
| :--- | :--- | :--- |
| 8787 | RStudio | Arranca solo, sin contraseña. |
| 1234 | Pluto | Ejecuta `pluto` en la terminal. |
| 6080 | Escritorio XFCE (solo Codespaces) | Arranca solo; se abre en el navegador (noVNC). |

## El escritorio

* **Zathura** abre los PDF con la paleta de la web: papel crema, tinta y granate. `Ctrl+R` pasa al modo noche sin alterar el color de las figuras, y lo que se selecciona va al portapapeles.
* **Obsidian** arranca con la bóveda `~/Notas`: las imágenes pegadas van a `imagenes/` y *Auto Link Title* convierte cada URL pegada en un enlace con su título. Lleva el tema nocturno de Somosaguas, la paleta oscura de la web en Inter, con Fira Code para el código. La primera vez, Obsidian pregunta si confías en la bóveda; hay que aceptar para activar la extensión.
* **Mousepad** para apuntar algo rápido.

## Versiones

Hay una imagen por semestre, con etiqueta de calendario: `AAAA.2` en septiembre y `AAAA.1` en febrero. Entre medias solo se publican arreglos (`2026.2.1`).

1. Unas dos semanas antes, se suben los `ARG` del Dockerfile y se mueve `SNAPSHOT` a esa fecha. Las versiones menores (Julia 1.x, R 4.x) y el salto de Debian solo cambian en septiembre, para que un curso anual no cambie de versión a mitad de año.
2. Se empuja la etiqueta: `git tag 2026.2 && git push origin 2026.2`. GitHub Actions construye las dos imágenes y las publica como `ghcr.io/nuevasomosaguas/entorno:2026.2` y `ghcr.io/nuevasomosaguas/entorno-escritorio:2026.2`.
3. Las etiquetas publicadas no se borran: un laboratorio de 2026 se vuelve a abrir en 2036 con la misma imagen.

## Reproducibilidad

Todas las versiones están fijadas en [`.devcontainer/Dockerfile`](.devcontainer/Dockerfile). Los paquetes de R y Python salen de una instantánea fechada (`SNAPSHOT`), así que reconstruir la imagen años después instala exactamente los mismos. Los de Julia los congela el `Manifest.toml` de cada proyecto.
