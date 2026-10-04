# Entorno

El entorno de trabajo de la [Nueva Somosaguas](https://nuevasomosaguas.github.io/entorno.html): una imagen de Debian 13 con Julia, R, Python, SQL, Quarto, Typst y la terminal de Unix, lista para abrir en el navegador o en VS Code.

[![Abrir en GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/nuevasomosaguas/entorno)

## Puertas de entrada

1. **Navegador.** Pulsa el botón de arriba. GitHub Codespaces construye el entorno y lo abre en VS Code, sin instalar nada.
2. **Devcontainer.** Con Docker y la extensión *Dev Containers* de VS Code, clona el repositorio, elige *Reopen in Container* y luego *Nueva Somosaguas (local)*: la misma imagen, sin las aplicaciones gráficas. El contenedor se llama `nueva-somosaguas`. En Linux, el usuario tiene que estar en el grupo `docker` (`sudo usermod -aG docker $USER` y volver a iniciar sesión); en un Mac con Apple Silicon, Docker la ejecuta con Rosetta.
3. **Distribución.** Debian 13 con todo el entorno y el escritorio, desde un USB o [en una máquina virtual](#la-distribución-en-una-máquina-virtual): para probarla sin tocar el disco, o para instalarla. Ver [`distribucion/`](distribucion/).

Al abrirlo, una línea comprueba que todo calcula (ver [La verificación](#3-la-verificación)):

```bash
./verificar_entorno.sh
```

Todo el entorno está en **español** (menús, mensajes, fechas) y en la hora de Madrid, igual en los tres niveles. Los números conservan el punto decimal (`LC_NUMERIC=C.UTF-8`): con la coma española, `printf` y `sort -n` de la terminal fallarían o no coincidirían con R, Julia y Python.

## Qué incluye

| Herramientas | Descripción |
| :--- | :--- |
| Julia 1.13 | Pluto, CSV, DataFrames, CairoMakie, Agents, HTTP, Oxygen y `somosaguas-makie`, ya precompilados |
| R 4.5 | tidyverse, ragg, knitr, rmarkdown, DBI, RSQLite, RPostgres y `somosaguas-ggplot2` |
| Python 3 | uv, con pandas, polars, pyarrow, duckdb, psycopg y ruff en `/opt/venv`, para la fontanería y la ingesta de datos |
| SQL | SQLite y PostgreSQL (el usuario `alumno` ya tiene base propia: basta `psql`) |
| Documentos | Quarto, Typst y Hugo (webs, con `nueva-web`), con EB Garamond y Fira Code; lo que Fira Code no tiene (⋅, ⊗, ᵀ, 𝛃…) sale de JuliaMono, y cualquier otro carácter, de Noto (también chino, japonés y coreano), sin cuadraditos. Quarto trae instalado el [tema de Somosaguas](https://github.com/nuevasomosaguas/somosaguas-quarto-theme) y lo usa por omisión: un documento nuevo en HTML o Typst sale ya con él y en español. La misma plantilla, en Typst puro, como paquete: `typst init @local/somosaguas:0.1.0 trabajo` crea un documento nuevo con ella, y en VS Code, en un `.typ`, `doc` y Tab la escribe entera (el fragmento de la extensión de la Nueva Somosaguas, en Codespaces, en el devcontainer y en la distribución). Pandoc 3.12, con la misma plantilla: `pandoc texto.md -o texto.pdf` compila con Typst, sin LaTeX; TinyTeX de reserva para los PDF con LaTeX desde RStudio |
| Terminal | git, ssh, rsync, nano, Zellij (multiplexor), Newsboat (RSS), htop, lazygit, tldr (chuletas: `tldr tar`, o `tldr -L es tar` en español), jq, ripgrep, bat, fd, xsv, GNU parallel, curl, wget, unzip, yt-dlp, ffmpeg y GNU units (conversión de unidades: `units '3 miles' km`) |
| Aplicaciones | RStudio Server |
| Escritorio (Codespaces y la distribución) | XFCE con Obsidian, Zathura, Foliate, LibreOffice Calc, Mousepad, Ristretto, JabRef, Zotero, Brave y mpv |

**Git** viene ajustado para todo el sistema con lo que recomiendan sus propios desarrolladores: la rama principal es `main`, `git pull` rebasa en lugar de crear commits de fusión, `git push` crea la rama en GitHub la primera vez, los nombres con tildes se ven tal cual, los conflictos muestran también el texto original (`zdiff3`) y `nano` escribe los mensajes. Son ajustes de sistema (`/etc/gitconfig`): los del `~/.gitconfig` de cada uno mandan sobre ellos. En Codespaces el nombre y el correo vienen de la cuenta de GitHub, y el devcontainer copia los del ordenador; en la distribución, el nombre es el de la cuenta y el correo lo pide Git en el primer commit (`git config --global user.email "tu@correo.es"`).

VS Code formatea el código al guardar y viene con estas extensiones:

* **Julia**, **R** (los gráficos se abren en un panel, con httpgd), **Quarto** y **Typst** (Tinymist).
* **Python** con Jupyter y Ruff.
* **SQL** con SQLTools: la base PostgreSQL del usuario ya aparece como *PostgreSQL local*, y cualquier archivo `.db` de SQLite se abre con el driver de SQLite.
* **Rainbow CSV**, para leer y consultar CSV por columnas.

**`~/Biblioteca`**, la bibliografía propia, en el escritorio: el sitio de los libros y los artículos, y Zotero, su puerta. Lo que se guarda en Zotero desde el navegador (con el Zotero Connector de Firefox o Brave), lo que se arrastra a Zotero desde `~/Downloads` y lo que baja `,p` en Newsboat acaba ahí. `~/Downloads` es de paso: lo que no pasa por Zotero no se puede citar ni lo encuentran `bibpdf` y `lecturas`. Se ordena con las colecciones y etiquetas de Zotero, no con carpetas: el almacén es plano a propósito, un archivo por obra con un nombre que se busca bien.

* **Los PDF, en `~/Biblioteca/almacen_pdf`**, con el nombre «Autor - Año - Título» (ZotMoov los saca del almacén interno de Zotero y los deja vinculados).
* **Las referencias, en `~/Biblioteca/zotero.bib`**, que Better BibTeX reescribe cada vez que la biblioteca cambia, con claves de cita estables (`plominBlueprint2018`). `pandoc` y VS Code la leen junto a la de la Nueva Somosaguas, sin declararla; Obsidian solo lee esta última.

En la terminal, tres órdenes buscan con fzf en todas las entradas de todos los `.bib` de la cuenta y en la biblioteca de la Nueva Somosaguas, por clave, autor, año o título a la vez (`plomin 2018`, `pearl causal`), con la entrada completa al lado:

| Orden | Qué hace con la entrada elegida |
| :--- | :--- |
| `bibsearch` | La escribe en la terminal |
| `bibpdf` | Abre su PDF en Zathura (solo lista las que tienen uno, como las de Zotero) |
| `bibclave` | Copia `@clave` al portapapeles, para pegarla en Typst, Quarto u Obsidian |

**Tres capas de bibliografía.** La de la Nueva Somosaguas, la propia de Zotero y, para cada trabajo, la suya: `bibcongelar texto.md` (o `.qmd`, o `.typ`, o varios) escribe junto al documento un `referencias.bib` con las entradas que cita, y solo esas, sacadas de las otras dos (o del `referencias.bib` anterior, si una ya no está en ellas). Va con el trabajo, en su repositorio: se compila igual en cualquier máquina, sin la biblioteca de Zotero de quien lo escribió, y es lo que pide la reproducibilidad. Si la carpeta tiene `referencias.bib`, `pandoc` cita solo con él; en Quarto se declara (`bibliography: referencias.bib`) y en Typst, `#bibliography("referencias.bib")`. Tras una cita nueva, se vuelve a lanzar; las claves que no están en ninguna capa salen avisadas.

**Lecturas.** Zathura, Foliate y mpv recuerdan dónde se quedó cada PDF, cada EPUB y cada curso en vídeo; `lecturas` junta sus historiales en fzf, el más reciente arriba, con la página o el porcentaje y la clave de la bibliografía (si una entrada lleva el archivo en su campo `file`, como las de Zotero), e `Intro` lo abre donde se dejó. Cada vez deja al día `~/Biblioteca/lecturas.tsv` (clave, título, formato, progreso, última lectura y ruta), un archivo plano para Obsidian, R o una hoja de cálculo; `lecturas --tsv` solo lo escribe.

**En papel.** `biblectura` elige un libro de la bibliografía con fzf y abre en Obsidian su nota de lectura, `~/Notas/Lecturas/clave.md`; la primera vez la crea con sus datos (título, autores, año, estrato y nivel) y con `@clave` en el texto, para que el panel de Pandoc Reference List muestre la referencia completa. Es una ficha, no un diario: el mecanismo y el núcleo formal (supuestos, ecuación, traducción analítica), las anotaciones al margen con su página, las tareas de verificación en la terminal y los enlaces a otras notas. En la cabecera, `paginas_leidas` y `estado`: `pendiente`, `en curso`, `leído` o `verificado`, que es cuando la ecuación ya funciona como script. `Lecturas.base`, en la bóveda, las pone en una tabla por estado (Bases, de serie en Obsidian), y `lecturas` las muestra junto a los PDF y los EPUB. Una nota hecha a mano en `Lecturas/`, con *Nuevo* en esa tabla o desde el explorador, nace con la misma cabecera, vacía y en `pendiente`: se la pone Templater, desde `Plantillas/Lectura.md` (Obsidian, por sí solo, la dejaría en blanco). La construcción de la imagen comprueba que la plantilla y `biblectura` llevan los mismos campos, y las columnas de la tabla. Solo tienen referencia completa en Obsidian los libros de la biblioteca de la Nueva Somosaguas: es la única que lee.

**Marcadores.** Lo que no se cita pero se quiere tener a mano (conjuntos de datos, documentación, herramientas, cursos) va a [buku](https://github.com/jarun/buku), una base SQLite en `~/.local/share/buku`. `buku -a URL` guarda una página (con su título y etiquetas, que buku saca de ella); en Newsboat, `B` guarda el artículo, con la revista como etiqueta; y lo que se guarda o se borra como marcador en Firefox o en Brave se refleja también, en unos segundos (el servidor de Marcadores vigila los marcadores de los dos navegadores; `marcadores --importar` hace lo mismo a mano). Cada marcador lleva su origen como etiqueta: `origen:firefox`, `origen:brave` u `origen:newsboat`. Uno de navegador se borra de buku cuando ya no está en ninguno de sus navegadores; lo guardado desde Newsboat, la terminal o la página de Marcadores no se borra nunca desde el navegador, y quitarle a un marcador su etiqueta de origen lo conserva aunque se borre allí. Si un navegador no se puede leer o sale vacío (un perfil nuevo), no se borra nada de lo suyo. `marcadores` los busca con fzf, por título o etiqueta: `Intro` abre la página y `Ctrl+Y` copia su URL. En el escritorio, **Marcadores** (en el menú, en *Internet*, y en la barra de Firefox y Brave, junto al GitHub de la Nueva Somosaguas) los muestra en el navegador con el aspecto de la web: se buscan, se filtran por etiqueta, se editan y se borran, y basta **arrastrar un enlace o una pestaña** sobre la página para guardarlo. Es un servidor local (`marcadores-web`, en `127.0.0.1:8484`) que arranca con el escritorio, pasa todo por la orden `buku` y se pone al día solo cuando la base cambia desde Newsboat o la terminal; solo atiende a su propia página. No hay extensión de navegador que guarde en buku: la que había, Bukubrow, está abandonada desde 2023.

**Proyectos.** `nuevo-proyecto carpeta` crea un trabajo listo para empezar: `datos/` (con su procedencia en `LEEME.md`), `codigo/` (las funciones y el análisis), `pruebas/`, el informe con la plantilla de Somosaguas, `referencias.bib`, `.gitignore`, `git init` y `./construir.sh`, que lo rehace todo desde cero: el análisis, sus pruebas, la bibliografía (`bibcongelar`) y el PDF. Las cifras del texto las escribe el análisis en `resultados/cifras.yml` y el informe las lee: ninguna se copia a mano. Por omisión, Typst y Julia (con el `Project.toml` y el `Manifest.toml` de la cuenta); `--quarto` y `--r` o `--python` (con su `uv.lock`) cambian el informe y el lenguaje. Trae un ejemplo que ya compila, la mortalidad por edad en Virginia en 1940, y lo explica `~/Documents/Proyectos.pdf`.

**Una web propia.** `nueva-web carpeta` crea una web con [Hugo](https://gohugo.io) y el [tema de la Nueva Somosaguas](https://github.com/nuevasomosaguas/somosaguas-hugo-theme): la portada con lo último (el título a la izquierda, cortado si no cabe, y la fecha a la derecha), *Sobre mí*, *Portafolio*, *Archivo* y *Contacto*, con la marca y el granate de la web, EB Garamond y las fórmulas con MathJax. Se escribe de tres maneras: en Markdown; en Quarto (`format: hugo-md`), con código de R, Julia o Python que se ejecuta al construir y deja sus figuras; o en Obsidian, donde `publicar-notas` trae solo las notas con `publicar: true` en la cabecera, traduce `[[enlaces]]` e `![[imágenes]]`, quita los comentarios `%%…%%` y deja como texto los enlaces a notas sin publicar (una nota a la que se le quita `publicar` desaparece de la web). `./construir.sh` lo hace todo y `hugo server` la muestra en `localhost:1313`. El tema, fijado por commit en la imagen, va copiado en la propia web (`themes/somosaguas`) y trae un flujo de GitHub Actions que la publica en GitHub Pages con cada `git push`: GitHub solo ejecuta Hugo sobre lo comprometido, nunca ve el cuaderno.

En `~/Documents` esperan cinco lecturas:

* **`Bienvenida.pdf`**, el manual de la primera vez: dónde está cada cosa, cómo abrir la terminal, calcular, citar y capturar, y qué hacer si algo va mal. Cuatro páginas con la plantilla de Somosaguas, compiladas con el pandoc de la imagen desde [`bienvenida/bienvenida.md`](.devcontainer/bienvenida/bienvenida.md). En el escritorio, Zathura lo abre solo la primera vez que se entra (en vivo, en cada arranque: la sesión no guarda nada).
* **`Aprender.pdf`**, el manual para seguir un curso en vídeo: mpv con listas que se retoman también en streaming, `n` para copiar el momento como enlace y `s` para la captura, una nota por concepto en Obsidian con sus preguntas, repasos espaciados y cómo practicar lo visto en lugar de releerlo.
* **`Proyectos.pdf`**, el manual de los trabajos: cómo empezar uno con `nuevo-proyecto`, qué va en cada carpeta, las cinco reglas (los datos no se tocan, ninguna cifra a mano, las pruebas las escribe el alumno, el azar con semilla y las versiones congeladas) y cómo comprobar antes de entregar que se reconstruye desde cero.
* **`nuevasomosaguas.bib`**, la [biblioteca de la Nueva Somosaguas](https://nuevasomosaguas.github.io/biblioteca.html) en BibTeX, la misma que publica la web: un enlace a la copia del sistema, que no se edita. `pandoc` la usa sola: `[@clave]` en un Markdown y la lista de referencias sale al final. En VS Code, `@` en un Typst, un Quarto o un Markdown abre la lista de las entradas de todas las bibliotecas (la propia de Zotero, la de la Nueva Somosaguas y el `referencias.bib` del trabajo), con autores, año y título, para buscar por cualquiera de ellos y elegir; al guardar, `bibcongelar` pone al día el `referencias.bib`, y la cita recién puesta ya compila. Lo hace la [extensión de la Nueva Somosaguas](https://github.com/nuevasomosaguas/somosaguas-vscode), fijada por commit en la imagen, que trae también los fragmentos de Typst (`doc` y Tab, un documento con la plantilla; `nota`, `fig`, `tabla`, `ec`, `cifras` y `bib`); en Obsidian, `@` en una nota las propone con su título, y la barra lateral muestra las referencias de la nota en Chicago, como `pandoc` (Pandoc Reference List). En RStudio y al renderizar con Quarto, el documento tiene que declararla: `bibliography: /usr/local/share/somosaguas/nuevasomosaguas.bib`, o la copia del proyecto; el editor visual de RStudio busca además en el Zotero local. En el escritorio se abre en JabRef y se importa en Zotero. Para citarla en un trabajo, se copia a su carpeta y se versiona con él: así el documento no cambia si la biblioteca crece.
* **El manual de la terminal**, [*The Linux Command Line*](https://linuxcommand.org/tlcl.php) de William Shotts, en PDF (licencia CC BY-NC-ND 3.0).

## Zellij: la sesión de trabajo

`zellij attach -c somosaguas`, desde la carpeta del proyecto, abre la sesión con una pestaña por herramienta; al volver otro día, la misma orden la recupera tal como quedó.

| Pestaña | Qué abre |
| :--- | :--- |
| terminal | La terminal, en la carpeta del proyecto |
| git | lazygit: cambios, commits, ramas y el historial del proyecto, con el teclado. Si la sesión se abrió fuera de un repositorio (desde `~`, por ejemplo), propone con fzf los de la cuenta, el último usado arriba, en lugar de ofrecer `git init` en la carpeta personal; sin ninguno, explica cómo empezar uno |
| julia | Julia con el entorno del proyecto (el `Project.toml` más cercano) |
| R | R, sin el mensaje de bienvenida |
| SQL | `psql` con la base PostgreSQL del usuario y, al lado, `sqlite3` |
| lecturas | Newsboat |
| sistema | htop: los procesos en árbol, un medidor por núcleo, la memoria y la swap |

En **htop**, el árbol muestra quién lanzó cada proceso: un script que sigue calculando tras cerrar el editor queda a la vista. Los hilos de Julia o de Polars no se listan uno por uno (`Shift+H` los muestra, para revisar la concurrencia). La cabecera se ajusta a la máquina:

* **Un medidor por núcleo.** Si una simulación en paralelo solo llena uno, el código está corriendo en un solo hilo.
* **La memoria**, en colores: verde lo que ocupan los programas y los datos cargados; azul y amarillo, los búferes y la caché de disco del sistema, que se liberan en cuanto hacen falta.
* **La swap.** Si empieza a llenarse, los datos ya no caben en la memoria y todo se ralentiza. En una máquina sin swap, como suelen ser las de Codespaces, la barra queda vacía y, al agotarse la memoria, el sistema cierra el proceso más grande.

Para que la máquina no se congele, **earlyoom** vigila la memoria. Si la disponible baja del 6 %, cierra el cálculo que la está agotando (Julia, R —también dentro de RStudio— o Python) en lugar de dejar que todo se atasque, y nunca el editor, el escritorio, Zellij, RStudio ni PostgreSQL. En el escritorio, cada cierre sale como un aviso que no se va hasta pulsarlo, con el programa cerrado; el detalle queda en `/var/log/earlyoom.log` (en la distribución, `journalctl -u earlyoom`). Antes de llegar ahí, Julia recoge la basura en cuanto su montón pasa de la mitad de la memoria (`JULIA_HEAP_SIZE_HINT=50%`; en un contenedor, la mitad de su límite): con muchos objetos pequeños, el pico baja casi a la mitad a cambio de algo más de tiempo de recolección. Es una pista, no un tope, y vale para cada proceso de Julia por separado (Pluto abre uno por cuaderno); para un cálculo concreto, `julia --heap-size-hint=4G` manda sobre la variable.

`Alt` + flechas cambia de pestaña y de panel, y la barra de abajo muestra el resto de atajos. Si una herramienta termina, `Enter` la vuelve a abrir.

## Newsboat: la literatura, en texto plano

`newsboat` abre ya suscrito a las revistas y los preprints de la frontera: PNAS, *Nature Human Behaviour*, *American Sociological Review*, *American Journal of Sociology* y *Annual Review of Sociology* (las revistas de referencia de la sociología; la última, desde Crossref, porque su web no deja leer el RSS a un programa), arXiv (metodología estadística, redes, poblaciones), bioRxiv (genética), NBER, *Intelligence*, *Demographic Research*, *European Journal of Population* y *Behavior Genetics*. Sin algoritmos ni métricas: titular, autores, fecha y resumen.

* Se navega con las teclas de vi: `j`/`k` para moverse, `l` o `Enter` para abrir, `h` para volver, `J`/`K` para saltar de fuente, `n` al siguiente sin leer y `t` para filtrar por etiqueta.
* **`o` pregunta qué hacer con el artículo**, con las tres opciones primero: `Intro` (o `n`) lo abre en el navegador (en VS Code, el del ordenador; en el escritorio, Brave), `z` lo guarda en Zotero y `b` en los marcadores de buku. `Esc` vuelve sin hacer nada.
* `,p` sobre un artículo de arXiv, bioRxiv o medRxiv baja su PDF y lo guarda en Zotero, como el botón del navegador con un PDF abierto: Zotero saca su ficha del propio PDF y lo deja en `~/Biblioteca/almacen_pdf`, de donde se abre en Zathura. Sin Zotero (fuera del escritorio), se queda en `~/Downloads`, de paso.
* **`B` lo guarda en los marcadores de buku** sin pasar por el menú, con su título y la revista como etiqueta: para lo que interesa leer, no citar (ver *Marcadores*, arriba). No es `Ctrl+B`, el atajo de Newsboat, porque Zellij lo usa.
* **`,z` guarda el artículo en tu biblioteca de Zotero** sin pasar por el menú, sin salir de Newsboat: busca su DOI (en el enlace o en la página; también en arXiv, NBER, Nature y ScienceDirect, cuyos enlaces no lo llevan), trae su ficha de doi.org y se la da a Zotero, que se abre solo si estaba cerrado. Better BibTeX le pone su clave y la escribe en `~/Biblioteca/zotero.bib`, lista para citarla. Si el artículo aún no tiene ficha (un DOI recién dado), lo abre en el navegador, donde el botón de Zotero lo guarda. Necesita el escritorio (Codespaces o la distribución), donde está Zotero.
* Las fuentes propias se añaden en `~/.config/newsboat/mis-fuentes`, una URL por línea (con `"~Nombre"` y etiquetas si se quiere). Newsboat las junta con las de la facultad al abrirse y las pone todas bajo la etiqueta *Fuentes propias*, aunque no se escriba; la fuente *Fuentes propias*, arriba del todo, las reúne en una sola lista. La lista de la facultad no se toca, y una fuente que ya esté en ella no se repite.
* Como todo el directorio personal, `mis-fuentes` se pierde al reconstruir el contenedor: conviene guardar una copia en el proyecto.

## yt-dlp: cursos y conferencias

`yt-dlp URL_DE_LA_LISTA` baja un curso entero con los ajustes de la facultad ([`.devcontainer/yt-dlp.conf`](.devcontainer/yt-dlp.conf)):

* **Hasta 1080p**, con el mejor audio, y siempre en **MKV** (también cuando YouTube solo da WebM).
* **Subtítulos en inglés en `.srt`**, junto a cada vídeo: los hechos a mano si existen y, si no, los automáticos. mpv los carga solo. Los automáticos de YouTube ruedan línea a línea (cada línea nueva empuja la anterior); mpv los muestra de dos en dos líneas, quietos, como los de una película (ver *mpv*, abajo).
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
* **`copia`** hace una copia rápida de lo tuyo en un disco: lo elige de una lista con fzf (los montados y los USB aún sin montar, que monta sin `sudo`), o `copia CARPETA` para uno de red. Copia `Documents`, `Notas`, `Biblioteca`, `Desktop`, `Screenshots` y `Cursos` (sin sus vídeos, que se bajan otra vez) a `DISCO/copia-nueva-somosaguas/USUARIO/actual`, como espejo con `rsync`: la primera vez todo, y luego solo lo que cambió. Lo borrado o cambiado desde la copia anterior no se pierde: queda en `anteriores/FECHA`. En los USB de siempre (FAT, exFAT, NTFS) copia sin permisos ni enlaces, que no admiten; antes de empezar comprueba que cabe, y al acabar ofrece expulsar el disco.
* **mpv** retoma cada vídeo donde se dejó, también tras un cierre inesperado (guarda la posición cada 30 s), y `h` abre el historial de lo visto. Una lista también: `mpv URL_DE_LA_LISTA`, en streaming, o `mpv ~/Cursos/curso/` vuelven a la clase en la que se iba (`~/.local/state/mpv/listas.json`), que retoma en su minuto. Un curso visto en streaming deja además su ficha en `~/Cursos/<título de la lista>/curso.m3u` (`guardar-curso`, al abrirlo y en cada visita, con las clases nuevas, con la misma orden `yt-dlp` que usa mpv; si no puede, sin conexión o con yt-dlp desfasado, lo dice en pantalla): el título, la duración y la dirección de cada clase, en unos kilobytes y sin bajar ningún vídeo. Es la carpeta en la que `yt-dlp` lo bajaría; abrirla con doble clic sigue en la misma clase y el mismo minuto que la dirección de la lista, y `lecturas` la lista con los PDF y los libros («clase 2 de 40, 1:41»). Los bajados con `yt-dlp` salen también, con «descargado» (lo que ocupa disco); si un curso se ha visto de las dos maneras, cuenta la última, y se abre así. Una carpeta se abre como la lista de sus vídeos, sin la ficha, que repetiría el curso en streaming (`directory-filter-types` en `mpv.conf`). Para las notas, `n` copia el momento como enlace de Markdown, `[Título, 12:30](…&t=750s)`, que abre el vídeo en ese minuto, y `s` guarda el fotograma en `~/Screenshots` con el título y el minuto en el nombre. En streaming, los subtítulos son solo los ingleses, como al bajar con yt-dlp (sin `sub-langs`, el `ytdl_hook` de mpv pediría las ~150 traducciones automáticas de YouTube); mpv los elige por idioma al abrir cada vídeo, y no por número de pista, que al volver apuntaba a otra o a ninguna, y si se ocultan con `v` siguen ocultos en ese vídeo. Los subtítulos automáticos de YouTube, en streaming o en el `.srt` de yt-dlp, salen **de dos en dos líneas**: las dos a la vez, hasta que las dos siguientes las sustituyen; tras un silencio empieza otro bloque, y `[Music]` va solo. Al elegir la pista, `subtitulos-bloques` la reescribe y mpv la cambia por la nueva; los subtítulos hechos a mano no se tocan.
* **`F12`** despliega un terminal desde arriba de la pantalla; `F12` de nuevo lo esconde. Ocupa la tecla en todo el escritorio, también en VS Code (ir a la definición) y en los navegadores (herramientas de desarrollo).
* **Obsidian** arranca con la bóveda `~/Notas`: las imágenes pegadas van a `imagenes/` y *Auto Link Title* convierte cada URL pegada en un enlace con su título. Lleva el tema nocturno de Somosaguas, la paleta oscura de la web en Inter, con Fira Code para el código. La bóveda llega ya como de confianza, con las extensiones activas: Obsidian no pregunta si confía en su autor. Esa respuesta vive en su localStorage (`enable-plugin-` más el id de la bóveda, el que fija `obsidian.json`), y `obsidian-confianza.mjs` la deja escrita en la plantilla al construir la imagen.
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

## La distribución en una máquina virtual

Para probar la distribución sin tocar el disco del ordenador, o para tenerla instalada al lado del sistema propio.

**La ISO.** Se baja de la publicación `distribucion-AAAA.N` del repositorio, en trozos de menos de 2 GiB, y se junta y se comprueba (en Windows, `copy /b` y `certutil`, como dicen las notas de la publicación):

```bash
cat nueva-somosaguas-AAAA.N.iso.parte* > nueva-somosaguas-AAAA.N.iso
sha256sum -c nueva-somosaguas-AAAA.N.iso.sha256
```

O se construye en local (`distribucion/construir.sh`) y queda en `distribucion/salida/`.

**La máquina.** La sesión en vivo corre entera en la memoria, así que hace falta memoria de sobra:

| | Mínimo | Recomendado |
| :--- | :--- | :--- |
| Memoria | 4 GB | 8 GB |
| Procesadores | 2 | 4 |
| Disco (solo para instalar) | 40 GB | 60 GB |
| Firmware | BIOS o UEFI, sin arranque seguro | UEFI |

Sin disco basta para probarla en vivo; para instalarla, el instalador pide al menos 40 GB y se niega con menos.

### Virtual Machine Manager (Linux)

La opción natural en Linux: QEMU con KVM, a velocidad casi nativa, y la integración ya viene en la ISO (`spice-vdagent`: la pantalla se ajusta a la ventana y el portapapeles se comparte).

1. *Archivo → Nueva máquina virtual → Medio de instalación local* y elegir la ISO. Si pregunta por los permisos de la carpeta, aceptar: QEMU corre con otro usuario y tiene que poder leerla.
2. Sistema operativo: *Debian 13* (o el Debian más reciente de la lista, si no aparece).
3. Memoria y procesadores, según la tabla; un disco nuevo de 40 GB o más, si se va a instalar.
4. Marcar *Personalizar la configuración antes de instalar* y, en *Vista general → Firmware*, elegir **UEFI** (el que no dice `secboot`). La ISO arranca también con BIOS.
5. *Iniciar la instalación*. Arranca en vivo, con el usuario `alumno` (contraseña: `somosaguas`).

### VirtualBox (Windows, macOS con Intel y Linux)

1. *Nueva*: nombre, la ISO, tipo *Linux*, versión *Debian (64-bit)*. **Marcar *Omitir la instalación desatendida***: si no, VirtualBox intenta instalar Debian a su manera y no arranca la sesión en vivo.
2. Memoria y procesadores, según la tabla; marcar *Habilitar EFI* (el arranque seguro de VirtualBox queda desactivado, como debe).
3. Un disco de 40 GB o más, si se va a instalar.
4. En *Configuración → Pantalla*: controlador **VMSVGA** y 128 MB de memoria de vídeo, sin aceleración 3D.
5. *Iniciar*.

La ISO no trae las Guest Additions de VirtualBox (no están en Debian): la resolución de la pantalla se elige en *Configuración → Pantalla* del propio escritorio y el portapapeles no se comparte. Con Virtual Machine Manager, sí. En un Mac con Apple Silicon no arranca: la distribución es solo para procesadores x86-64.

### En vivo o instalada

* **En vivo** no se guarda nada al apagar, y la máquina no se suspende sola. El manual de bienvenida se abre en cada arranque.
* **Para instalarla**, el icono *Instalar la Nueva Somosaguas* del escritorio abre el instalador (pide la contraseña, `somosaguas`). Al terminar, se apaga la máquina y se quita la ISO de la unidad virtual (en Virtual Machine Manager, *Detalles → CDROM → Desconectar*; en VirtualBox, *Configuración → Almacenamiento*), para que arranque desde el disco. Con una gráfica NVIDIA y el arranque seguro activado, el primer arranque pasa por una pantalla azul (MOK): *Enroll MOK → Continue → Yes*, la contraseña `somosaguas` y *Reboot*. Inscribe la clave con la que el instalador firmó el controlador de NVIDIA de ese equipo; es una sola vez.

## Versiones

Hay una imagen por semestre, con etiqueta de calendario: `AAAA.2` en septiembre y `AAAA.1` en febrero. Entre medias solo se publican arreglos (`2026.2.1`).

1. Unas dos semanas antes, se suben los `ARG` del Dockerfile y se mueve `SNAPSHOT` a esa fecha: lo hace el flujo *Versiones del semestre* (ver [La lista del semestre](#la-lista-del-semestre)). Las versiones menores (Julia 1.x, R 4.x) y el salto de Debian solo cambian en septiembre, para que un curso anual no cambie de versión a mitad de año.
2. Se empuja la etiqueta: `git tag 2026.2 && git push origin 2026.2`. GitHub Actions construye las dos imágenes y las publica como `ghcr.io/nuevasomosaguas/entorno:2026.2` y `ghcr.io/nuevasomosaguas/entorno-escritorio:2026.2`.
3. Hasta que se publica, mientras se prueba, la etiqueta del semestre se mueve con cada arreglo (`git tag -f 2026.2 && git push -f origin 2026.2`): los equipos instalados la siguen por el commit de la imagen, no por el número, y no hace falta un `2026.2.1` por cada par de arreglos. Publicada, ya no se mueve ni se borra: un laboratorio de 2026 se vuelve a abrir en 2036 con la misma imagen, y los arreglos son `2026.2.1`, `2026.2.2`…
4. Cerrada la configuración del semestre, la **distribución** se publica a mano: *Actions → Publicar la distribución → Run workflow*, con la versión del semestre (`2026.2`). Construye la ISO desde ese commit y la sube como `distribucion-2026.2`, en trozos de menos de 2 GiB (el límite de GitHub por archivo) con su suma SHA-256; las notas de la publicación explican cómo juntarlos. Ver [`distribucion/`](distribucion/).

### La lista del semestre

El 15 de enero y el 15 de agosto, el flujo *Versiones del semestre* ([`semestre.yml`](.github/workflows/semestre.yml)) abre la petición de cambios `semestre/AAAA.N` con esta lista; también a mano, en *Actions → Versiones del semestre → Run workflow → subida*. Lo que se puede automatizar lo hace él; lo que pide criterio o hardware, una persona. Nada se fusiona ni se publica solo.

**Lo hace el flujo**

* Sube cada `ARG` de los dos Dockerfile a su última versión publicada y vuelve a calcular las sumas SHA-256 de lo que se descarga con suma ([`mantenimiento/versiones.py`](mantenimiento/versiones.py)). Julia solo cambia de versión menor en agosto y septiembre.
* Mueve `SNAPSHOT` (CRAN) al día, actualiza `uv.lock` (`uv lock --upgrade`) y el `Manifest.toml` de Julia (`Pkg.update()`), con la revisión nueva de `somosaguas-makie`.
* Apunta la distribución a la imagen del semestre nuevo (`ARG IMAGEN` y `construir.sh`).
* Lanza la construcción de prueba de las dos imágenes (*Publicar la imagen*, sin publicar), con todas sus comprobaciones.

**Antes de fusionar, a mano**

- [ ] La construcción de prueba termina en verde.
- [ ] Las notas de cada versión mayor nueva (Quarto, Pandoc, Typst, Zotero, Obsidian, JabRef, RStudio, VS Code). El tema de Somosaguas cambia tres líneas del código de Quarto; si Quarto las ha movido, la construcción se para y hay que ajustarlas.
- [ ] Solo en septiembre: ¿hay Debian estable nuevo? El salto (`trixie` → la siguiente) se hace a mano en los `FROM` y en los nombres de paquete que cambien, igual que la versión menor de Julia.
- [ ] Un Codespace sobre la rama: `./verificar_entorno.sh`, un laboratorio de muestra, RStudio, el escritorio y `pandoc` con una cita.
- [ ] La ISO en local, desde la imagen de la rama (`distribucion/construir.sh AAAA.N nueva-somosaguas/escritorio:local`): en una máquina virtual con BIOS y con UEFI, y en un equipo real (Wi-Fi, sonido, suspensión ya instalado, instalación con cifrado, las instantáneas de Snapper, Zotero desde el navegador, KeePassXC).
- [ ] Las incidencias abiertas del semestre anterior: se cierran o pasan a este.

**Publicar**

- [ ] Fusionar y etiquetar: `git tag AAAA.N && git push origin AAAA.N`; GitHub Actions publica las dos imágenes.
- [ ] Los paquetes nuevos de GHCR, públicos (en la web de GitHub, si no lo son ya).
- [ ] *Actions → Publicar la distribución → Run workflow*, con `AAAA.N`.
- [ ] La web: la versión nueva en la página del entorno.

**Entre semestres.** Cada día 1, el mismo flujo actualiza la incidencia *Versiones del entorno* (etiqueta `versiones`) con la tabla de lo fijado frente a lo publicado. Los paquetes de Debian reciben sus parches en cada reconstrucción y, en los equipos instalados, solos; lo que no llega por Debian (Zotero, Obsidian, VS Code, RStudio, Quarto, JabRef, LocalSend…) no. Un arreglo de seguridad en una de esas piezas merece un `AAAA.N.1`: `python3 mantenimiento/versiones.py --actualizar --solo ZOTERO_VERSION`, la construcción de prueba, la etiqueta.

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
