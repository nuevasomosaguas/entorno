# Entorno

El entorno de trabajo de la [Nueva Somosaguas](https://nuevasomosaguas.github.io/entorno.html): una imagen de Debian 13 con Julia, R, Python, SQL, Quarto, Typst y la terminal de Unix, lista para abrir en el navegador o en VS Code.

[![Abrir en GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/nuevasomosaguas/entorno)

## Puertas de entrada

1. **Navegador.** Pulsa el botón de arriba. GitHub Codespaces construye el entorno y lo abre en VS Code, sin instalar nada.
2. **Devcontainer.** Con Docker y la extensión *Dev Containers* de VS Code, clona el repositorio, elige *Reopen in Container* y luego *Nueva Somosaguas (local)*: la misma imagen, sin las aplicaciones gráficas. El contenedor se llama `nueva-somosaguas`. En Linux, el usuario tiene que estar en el grupo `docker` (`sudo usermod -aG docker $USER` y volver a iniciar sesión); en un Mac con Apple Silicon, Docker la ejecuta con Rosetta.

Al abrirlo, una línea comprueba que todo calcula (ver [La verificación](#3-la-verificación)):

```bash
./verificar_entorno.sh
```

Todo el entorno está en **español** (menús, mensajes, fechas) y en la hora de Madrid, igual en los tres niveles. Los números conservan el punto decimal (`LC_NUMERIC=C.UTF-8`): con la coma española, `printf` y `sort -n` de la terminal fallarían o no coincidirían con R, Julia y Python.

## Qué incluye

| Herramientas | Descripción |
| :--- | :--- |
| Julia 1.13 | Pluto, CSV, DataFrames, CairoMakie, Agents y `somosaguas-makie`, ya precompilados |
| R 4.5 | tidyverse, ragg, knitr, rmarkdown, DBI, RSQLite, RPostgres y `somosaguas-ggplot2` |
| Python 3 | uv, con pandas, polars, pyarrow, duckdb, psycopg y ruff en `/opt/venv`, para la fontanería y la ingesta de datos |
| SQL | SQLite y PostgreSQL (el usuario `alumno` ya tiene base propia: basta `psql`) |
| Documentos | Quarto y Typst, con EB Garamond y Fira Code. Quarto trae instalado el [tema de Somosaguas](https://github.com/nuevasomosaguas/somosaguas-quarto-theme) y lo usa por omisión: un documento nuevo en HTML o Typst sale ya con él y en español. Pandoc 3.12, con la misma plantilla: `pandoc texto.md -o texto.pdf` compila con Typst, sin LaTeX; TinyTeX de reserva para los PDF con LaTeX desde RStudio |
| Terminal | git, ssh, rsync, nano, Zellij (multiplexor), Newsboat (RSS), htop, lazygit, tldr (chuletas: `tldr tar`, o `tldr -L es tar` en español), jq, ripgrep, bat, fd, xsv, GNU parallel, curl, wget, yt-dlp y ffmpeg |
| Aplicaciones | RStudio Server |
| Escritorio (solo Codespaces) | XFCE con Obsidian, Zathura, Foliate, LibreOffice Calc, Mousepad, Ristretto, JabRef, Zotero, Brave y mpv |

VS Code formatea el código al guardar y viene con estas extensiones:

* **Julia**, **R** (los gráficos se abren en un panel, con httpgd), **Quarto** y **Typst** (Tinymist).
* **Python** con Jupyter y Ruff.
* **SQL** con SQLTools: la base PostgreSQL del usuario ya aparece como *PostgreSQL local*, y cualquier archivo `.db` de SQLite se abre con el driver de SQLite.
* **Rainbow CSV**, para leer y consultar CSV por columnas.

**`~/Biblioteca`**, la bibliografía propia, en el escritorio. Lo que se guarda en Zotero desde el navegador (con el Zotero Connector de Firefox o Brave) acaba ahí:

* **Los PDF, en `~/Biblioteca/almacen_pdf`**, con el nombre «Autor - Año - Título» (ZotMoov los saca del almacén interno de Zotero y los deja vinculados).
* **Las referencias, en `~/Biblioteca/zotero.bib`**, que Better BibTeX reescribe cada vez que la biblioteca cambia, con claves de cita estables (`plominBlueprint2018`). `pandoc` y VS Code la leen junto a la de la Nueva Somosaguas, sin declararla; Obsidian solo lee esta última.

En la terminal, tres órdenes buscan con fzf en todas las entradas de todos los `.bib` de la cuenta y en la biblioteca de la Nueva Somosaguas, por clave, autor, año o título a la vez (`plomin 2018`, `pearl causal`), con la entrada completa al lado:

| Orden | Qué hace con la entrada elegida |
| :--- | :--- |
| `bibsearch` | La escribe en la terminal |
| `bibpdf` | Abre su PDF en Zathura (solo lista las que tienen uno, como las de Zotero) |
| `bibclave` | Copia `@clave` al portapapeles, para pegarla en Typst, Quarto u Obsidian |

En `~/Documents` esperan dos lecturas:

* **`nuevasomosaguas.bib`**, la [biblioteca de la Nueva Somosaguas](https://nuevasomosaguas.github.io/biblioteca.html) en BibTeX, la misma que publica la web: un enlace a la copia del sistema, que no se edita. `pandoc` la usa sola: `[@clave]` en un Markdown y la lista de referencias sale al final. En VS Code, `@` en un Markdown o un Quarto propone sus entradas (Pandoc Citer); en Obsidian, `Ctrl+Mayús+E` busca una e inserta `[@clave]` (Citations). En RStudio y al renderizar con Quarto, el documento tiene que declararla: `bibliography: /usr/local/share/somosaguas/nuevasomosaguas.bib`, o la copia del proyecto; el editor visual de RStudio busca además en el Zotero local. En el escritorio se abre en JabRef y se importa en Zotero. Para citarla en un trabajo, se copia a su carpeta y se versiona con él: así el documento no cambia si la biblioteca crece.
* **El manual de la terminal**, [*The Linux Command Line*](https://linuxcommand.org/tlcl.php) de William Shotts, en PDF (licencia CC BY-NC-ND 3.0).

## Zellij: la sesión de trabajo

`zellij attach -c somosaguas`, desde la carpeta del proyecto, abre la sesión con una pestaña por herramienta; al volver otro día, la misma orden la recupera tal como quedó.

| Pestaña | Qué abre |
| :--- | :--- |
| terminal | La terminal, en la carpeta del proyecto |
| git | lazygit: cambios, commits, ramas y el historial del proyecto, con el teclado |
| julia | Julia con el entorno del proyecto (el `Project.toml` más cercano) |
| R | R, sin el mensaje de bienvenida |
| SQL | `psql` con la base PostgreSQL del usuario y, al lado, `sqlite3` |
| lecturas | Newsboat |
| sistema | htop: los procesos en árbol, un medidor por núcleo, la memoria y la swap |

En **htop**, el árbol muestra quién lanzó cada proceso: un script que sigue calculando tras cerrar el editor queda a la vista. Los hilos de Julia o de Polars no se listan uno por uno (`Shift+H` los muestra, para revisar la concurrencia). La cabecera se ajusta a la máquina:

* **Un medidor por núcleo.** Si una simulación en paralelo solo llena uno, el código está corriendo en un solo hilo.
* **La memoria**, en colores: verde lo que ocupan los programas y los datos cargados; azul y amarillo, los búferes y la caché de disco del sistema, que se liberan en cuanto hacen falta.
* **La swap.** Si empieza a llenarse, los datos ya no caben en la memoria y todo se ralentiza. En una máquina sin swap, como suelen ser las de Codespaces, la barra queda vacía y, al agotarse la memoria, el sistema cierra el proceso más grande.

Para que la máquina no se congele, **earlyoom** vigila la memoria. Si la disponible baja del 6 %, cierra el cálculo que la está agotando (Julia, R —también dentro de RStudio— o Python) en lugar de dejar que todo se atasque, y nunca el editor, el escritorio, Zellij, RStudio ni PostgreSQL. En el escritorio, cada cierre sale como un aviso que no se va hasta pulsarlo, con el programa cerrado; el detalle queda en `/var/log/earlyoom.log` (en la distribución, `journalctl -u earlyoom`).

`Alt` + flechas cambia de pestaña y de panel, y la barra de abajo muestra el resto de atajos. Si una herramienta termina, `Enter` la vuelve a abrir.

## Newsboat: la literatura, en texto plano

`newsboat` abre ya suscrito a las revistas y los preprints de la frontera: PNAS, *Nature Human Behaviour*, arXiv (metodología estadística, redes, poblaciones), bioRxiv (genética), NBER, *Intelligence*, *Demographic Research*, *European Journal of Population* y *Behavior Genetics*. Sin algoritmos ni métricas: titular, autores, fecha y resumen.

* Se navega con las teclas de vi: `j`/`k` para moverse, `l` o `Enter` para abrir, `h` para volver, `J`/`K` para saltar de fuente, `n` al siguiente sin leer y `t` para filtrar por etiqueta.
* `o` abre el artículo en el navegador (en VS Code, el del ordenador; en el escritorio, Brave).
* `,p` sobre un artículo de arXiv, bioRxiv o medRxiv baja su PDF a `~/Documents/articulos` y, en el escritorio, lo abre en Zathura.
* Las fuentes propias se añaden en `~/.config/newsboat/mis-fuentes`, una URL por línea (con `"~Nombre"` y etiquetas si se quiere). Newsboat las junta con las de la facultad al abrirse y las pone todas bajo la etiqueta *Fuentes propias*, aunque no se escriba; la fuente *Fuentes propias*, arriba del todo, las reúne en una sola lista. La lista de la facultad no se toca, y una fuente que ya esté en ella no se repite.
* Como todo el directorio personal, `mis-fuentes` se pierde al reconstruir el contenedor: conviene guardar una copia en el proyecto.

## yt-dlp: cursos y conferencias

`yt-dlp URL_DE_LA_LISTA` baja un curso entero con los ajustes de la facultad ([`.devcontainer/yt-dlp.conf`](.devcontainer/yt-dlp.conf)):

* **Hasta 1080p**, con el mejor audio, y siempre en **MKV** (también cuando YouTube solo da WebM).
* **Subtítulos en inglés en `.srt`**, junto a cada vídeo: los hechos a mano si existen y, si no, los automáticos. mpv los carga solo.
* **Una carpeta por curso**: `~/Cursos/<lista>/03 - <clase>.mkv`, con las clases numeradas en orden. Un vídeo suelto va a `~/Cursos/Vídeos sueltos`.
* **Solo lo nuevo**: volver a lanzar la misma lista baja únicamente las clases que falten.
* **Capítulos** dentro del archivo, para saltar entre ellos en mpv.

Para otra cosa, basta con cambiar la opción en la orden: `yt-dlp --sub-langs es URL`, o `-o "%(title)s.%(ext)s"` para bajarlo aquí mismo.

## Puertos

| Puerto | Servicio | Cómo se abre |
| :--- | :--- | :--- |
| 8787 | RStudio | Arranca solo, sin contraseña. |
| 1234 | Pluto | Ejecuta `pluto` en la terminal. |
| 6080 | Escritorio XFCE (solo Codespaces) | Arranca solo; se abre en el navegador (noVNC). |

## El escritorio

* **XFCE** con el aspecto de Manjaro: tema Matcha oscuro, iconos Papirus y un solo panel abajo con el menú Whisker y Clipman, el historial del portapapeles. El fondo es el papel de la web con dos franjas a la derecha, granate y tinta, y el escritorio queda limpio, sin iconos. El menú abre con los favoritos de cada día: VS Code (en la distribución), el terminal, la *Sesión de trabajo* de Zellij, Thunar, Brave, RStudio, Obsidian, Zotero, JabRef, Mousepad y LibreOffice Calc. En lugar del verde de Manjaro, el rojo de Matcha, cercano al granate de la web. Las letras son las del estándar gráfico: Inter en la interfaz, EB Garamond como serifa y Fira Code para el código, con suavizado en escala de grises y hinting ligero, como macOS y GNOME. La pantalla va a 24 bits de color y noVNC la ajusta al tamaño de la ventana del navegador, sin reescalarla.
* **Thunar**, el gestor de archivos, con marcadores a `Documents`, `Downloads`, `Notas`, `Cursos` y `Screenshots`: `Super+Intro` abre XFCE Terminal en la carpeta que se está viendo (o en la seleccionada), y el menú contextual ofrece lo mismo como *Abrir un terminal aquí*.
* **Zathura** abre los PDF y los DjVu con la paleta de la web: papel crema, tinta y granate. `Ctrl+R` pasa al modo noche sin alterar el color de las figuras, y lo que se selecciona va al portapapeles. Recuerda en SQLite la página de cada documento y ofrece los 100 últimos al escribir `:open`. `C` copia el texto de la página en pantalla e `I`, la página como imagen, lista para pegar en Obsidian.
* **mpv** retoma cada vídeo donde se dejó, también tras un cierre inesperado (guarda la posición cada 30 s), y `h` abre el historial de lo visto.
* **`F12`** despliega un terminal desde arriba de la pantalla; `F12` de nuevo lo esconde. Ocupa la tecla en todo el escritorio, también en VS Code (ir a la definición) y en los navegadores (herramientas de desarrollo).
* **Obsidian** arranca con la bóveda `~/Notas`: las imágenes pegadas van a `imagenes/` y *Auto Link Title* convierte cada URL pegada en un enlace con su título. Lleva el tema nocturno de Somosaguas, la paleta oscura de la web en Inter, con Fira Code para el código. La primera vez, Obsidian pregunta si confías en la bóveda; hay que aceptar para activar la extensión.
* **Foliate** abre los EPUB, en modo oscuro y con EB Garamond para el texto.
* **LibreOffice Calc** abre las hojas de Excel (`.xlsx`, `.xls`) y OpenDocument (`.ods`); para analizarlas, mejor leerlas desde R, Julia o Python.
* **Capturas de pantalla**, todas en `~/Screenshots`:

  | Tecla | Qué hace |
  | :--- | :--- |
  | `Impr Pant` | Una zona, al portapapeles (lista para pegar en Obsidian o Xournal++) |
  | `Mayús+Impr` / `Alt+Impr` | La pantalla entera / la ventana activa |
  | `Ctrl+Impr` | El **texto** de una zona, al portapapeles (OCR en español e inglés): un PDF escaneado, una diapositiva de un vídeo |
  | `Super+Mayús+Impr` | Abre la última captura en Xournal++ para anotarla |
  | `Ctrl+Alt+Impr` | Empieza o termina una grabación de la pantalla, en MKV |
  | `Super+Impr` | xfce4-screenshooter, para capturas con retardo o más opciones |
 En Codespaces, el sistema del ordenador o el navegador pueden quedarse la tecla antes que el escritorio.
* **Xournal++** para escribir a mano y anotar PDF, y **Mousepad** para apuntar algo rápido, en Fira Code 12 y con las líneas ajustadas; guarda siempre la sesión, así vuelve con lo abierto tras cerrarse o tras un fallo.
* **Firefox**, además de Brave, con Zotero Connector y AdGuard y sin telemetría, Pocket ni publicidad. Los dos navegadores abren en la web de la Nueva Somosaguas y **Ristretto** para ver imágenes; el gestor de archivos muestra sus miniaturas.
* **JabRef** abre los `.bib` (la 5.15 estable) y **Zotero** guarda y ordena referencias, con su botón en Brave (Zotero Connector) para guardar la página que se está leyendo; los dos exportan a BibTeX para Quarto y Typst.

## Versiones

Hay una imagen por semestre, con etiqueta de calendario: `AAAA.2` en septiembre y `AAAA.1` en febrero. Entre medias solo se publican arreglos (`2026.2.1`).

1. Unas dos semanas antes, se suben los `ARG` del Dockerfile y se mueve `SNAPSHOT` a esa fecha. Las versiones menores (Julia 1.x, R 4.x) y el salto de Debian solo cambian en septiembre, para que un curso anual no cambie de versión a mitad de año.
2. Se empuja la etiqueta: `git tag 2026.2 && git push origin 2026.2`. GitHub Actions construye las dos imágenes y las publica como `ghcr.io/nuevasomosaguas/entorno:2026.2` y `ghcr.io/nuevasomosaguas/entorno-escritorio:2026.2`.
3. Las etiquetas publicadas no se borran: un laboratorio de 2026 se vuelve a abrir en 2036 con la misma imagen.
4. Cerrada la configuración del semestre, la **distribución** se publica a mano: *Actions → Publicar la distribución → Run workflow*, con la versión del semestre (`2026.2`). Construye la ISO desde ese commit y la sube como `distribucion-2026.2`, en trozos de menos de 2 GiB (el límite de GitHub por archivo) con su suma SHA-256; las notas de la publicación explican cómo juntarlos. Ver [`distribucion/`](distribucion/).

## Las reglas del juego

El entorno no es una lista de programas, sino un acuerdo de método. Lo sostienen tres reglas.

### 1. Versiones congeladas

Ningún paquete se instala flotante, en la última versión del día. Cada versión queda escrita en un archivo que viaja con el código, y así un laboratorio escrito en 2026 compila en 2036 con idénticos resultados numéricos.

* **Julia.** Cada proyecto compromete su `Project.toml` y su `Manifest.toml`. Se trabaja siempre dentro del entorno del proyecto, con `julia --project=.`, y `] add Paquete` actualiza los dos archivos.
* **Python** se reserva a la fontanería y la ingesta de datos (descargar, limpiar, convertir) y se gestiona solo con uv: `uv init`, `uv add polars`, y se comprometen `pyproject.toml` y `uv.lock`. Quien clona el proyecto ejecuta `uv sync --frozen` y obtiene exactamente las mismas versiones. Ni `pip install` ni `uv pip install`.
* **La imagen** cumple la misma regla. Julia sale de [`.devcontainer/julia/Manifest.toml`](.devcontainer/julia/Manifest.toml), Python de [`.devcontainer/python/uv.lock`](.devcontainer/python/uv.lock), R de una instantánea fechada de CRAN (`SNAPSHOT`), y cada herramienta, de la versión fijada en el [`Dockerfile`](.devcontainer/Dockerfile).

### 2. El sistema es de la facultad; el directorio personal, del alumno

La imagen base (`/usr` y `/opt`) no se toca: nada de `sudo apt install`, y `/opt/venv` es de solo lectura. Lo accesorio va al espacio del usuario:

* **Herramientas de terminal**, con `uv tool install`. Se instalan en `~/.local/bin`, que va antes que la imagen en el `PATH`. Así se pone al día yt-dlp, que deja de funcionar cada vez que YouTube cambia su web: `uv tool install "yt-dlp[default]"`. Para usar una herramienta una sola vez, `uvx`.
* **Bibliotecas pesadas, como PyTorch**, solo en el proyecto que las necesita. Para la versión de CPU, se añade al `pyproject.toml`

  ```toml
  [tool.uv.sources]
  torch = { index = "pytorch-cpu" }

  [[tool.uv.index]]
  name = "pytorch-cpu"
  url = "https://download.pytorch.org/whl/cpu"
  explicit = true
  ```

  y se ejecuta `uv add torch`. Con una GPU NVIDIA, que solo hay en el devcontainer local, se cambia `cpu` por la versión de CUDA (`cu128`) y se añade `"runArgs": ["--gpus", "all"]` al `devcontainer.json`.
* **Aplicaciones gráficas** como Heynote o un visor ligero, en el escritorio de Codespaces. Se baja su `.AppImage` a `~/.local/bin`, se le da permiso con `chmod +x` y se abre con `--appimage-extract-and-run --no-sandbox`, porque el contenedor no tiene FUSE ni sandbox de usuario.

Reconstruir el contenedor devuelve la imagen a su estado original: lo que vive en el directorio personal se pierde, y lo que vive en el proyecto (`/workspaces`) se conserva. Por eso las dependencias de un trabajo van en su lockfile, nunca solo en el directorio personal.

### 3. La verificación

[`verificar_entorno.sh`](verificar_entorno.sh) comprueba en unos segundos que las tres piezas calculan: compila en Typst un DAG de juguete, hace en Julia una actualización bayesiana (Beta-Binomial, contrastada con su solución exacta) y lanza en SQLite una consulta con funciones de ventana. Si las tres pasan, responde:

```
Entorno calibrado. Comience a calcular.
```

Si alguna falla, dice cuál y termina con error.
