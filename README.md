# entorno

El entorno de trabajo de la [Nueva Somosaguas](https://nuevasomosaguas.github.io/entorno.html): una imagen de Debian 13 con Julia, R, Python, SQL, Quarto, Typst y la terminal de Unix, lista para abrir en el navegador o en VS Code.

[![Abrir en GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/nuevasomosaguas/entorno)

## Puertas de entrada

1. **Navegador.** Pulsa el botón de arriba. GitHub Codespaces construye el entorno y lo abre en VS Code, sin instalar nada.
2. **Devcontainer.** Con Docker y la extensión *Dev Containers* de VS Code, clona el repositorio y elige *Reopen in Container*.

## Qué incluye

| | |
| :--- | :--- |
| Julia 1.13 | Pluto, CSV, DataFrames, CairoMakie y `somosaguas-makie`, ya precompilados |
| R 4.5 | ggplot2, dplyr, readr, ragg, knitr, rmarkdown, DBI, RSQLite, RPostgres y `somosaguas-ggplot2` |
| Python 3 | pandas, polars, pyarrow, duckdb, psycopg y ruff en `/opt/venv` |
| SQL | SQLite y PostgreSQL (el usuario `vscode` ya tiene base propia: basta `psql`) |
| Documentos | Quarto y Typst, con EB Garamond y Fira Code |
| Terminal | jq, ripgrep, bat, fd, xsv, GNU parallel, curl, wget, yt-dlp y ffmpeg |
| Aplicaciones | RStudio Server, Brave y mpv |

VS Code viene con las extensiones de Julia, R, Quarto, Typst (Tinymist) y Python, y formatea el código al guardar.

## Puertos

| Puerto | Servicio | Cómo se abre |
| :--- | :--- | :--- |
| 8787 | RStudio | Arranca solo, sin contraseña. |
| 1234 | Pluto | Ejecuta `pluto` en la terminal. |
| 6080 | Escritorio con Brave y mpv | Arranca solo; se abre en el navegador (noVNC). |

## Reproducibilidad

Todas las versiones están fijadas en [`.devcontainer/Dockerfile`](.devcontainer/Dockerfile). Los paquetes de R y Python salen de una instantánea fechada (`SNAPSHOT`), así que reconstruir la imagen años después instala exactamente los mismos. Los de Julia los congela el `Manifest.toml` de cada proyecto.
