# Imagen del entorno de la Nueva Somosaguas: Debian 13 (trixie) estable.
# Cada versión se fija aquí; la imagen publicada lleva etiqueta de calendario (2026.2).
# Tres etapas: `julia` precompila los paquetes de Julia aparte, para que su caché
# no dependa del resto; `base` es el devcontainer local, sin aplicaciones
# gráficas; `escritorio` le añade el escritorio XFCE para Codespaces.
# ponytail: solo amd64 (RStudio Server y xsv no publican binarios arm64 para Linux);
# en Mac con Apple Silicon, Docker la ejecuta con Rosetta.

# Julia: la precompilación de CairoMakie es lo más lento de la imagen (≈13 min).
# En su propia etapa solo se rehace si cambian estas líneas o julia/, y se
# construye en paralelo con `base`.
FROM mcr.microsoft.com/devcontainers/base:trixie AS julia
ARG JULIA_VERSION=1.13.1
# Código nativo para varias generaciones de CPU, como los binarios oficiales de
# Julia: la imagen se construye en una máquina y se usa en otras, y con el valor
# por defecto (la CPU de la construcción) Julia volvería a precompilarlo todo.
ENV JULIA_CPU_TARGET="generic;sandybridge,-xsaveopt,clone_all;haswell,-rdrnd,base(1);x86-64-v4,-rdrnd,base(1)"
RUN curl -fsSL "https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION%.*}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz" \
      | tar -xz -C /opt && mv "/opt/julia-${JULIA_VERSION}" /opt/julia
# Paquetes del entorno global, ya precompilados: Pluto, CSV, DataFrames, CairoMakie,
# Agents y somosaguas-makie, con las versiones exactas del Manifest.toml. Cada
# asignatura trae el suyo; este solo ahorra la primera espera. Van en un depósito
# compartido y de solo lectura, /opt/julia/depot: cada cuenta escribe en su ~/.julia y
# encuentra aquí lo ya compilado (JULIA_DEPOT_PATH, en la etapa base). El registro de
# paquetes no se queda: cada cuenta baja el suyo cuando le hace falta.
# Para subir versiones: `julia --project=.devcontainer/julia -e 'using Pkg; Pkg.update()'`.
# La traducción de Pluto al español usa el género neutro en «-e» («bienvenide», «atascade»):
# se cambia por el masculino genérico, en el JSON y en los paquetes ya compilados del
# frontend. Si Pluto cambia esas frases, grep no las encuentra y la construcción se para.
ENV JULIA_DEPOT_PATH=/opt/julia/depot
COPY julia/ /tmp/entorno-julia/
RUN mkdir -p /opt/julia/depot/environments \
    && cp -r /tmp/entorno-julia /opt/julia/depot/environments/"v${JULIA_VERSION%.*}" \
    && /opt/julia/bin/julia -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()' \
    && sed -i -e 's/bienvenide a {{pluto}}/bienvenido a {{pluto}}/' -e 's/¡Bienvenide a la/¡Bienvenido a la/' -e 's/atascade/atascado/' \
      $(grep -rl -e 'bienvenide a {{pluto}}' -e 'atascade' /opt/julia/depot/packages/Pluto) \
    && grep -rq 'bienvenido a {{pluto}}' /opt/julia/depot/packages/Pluto/*/frontend-dist \
    && rm -rf /opt/julia/depot/registries /opt/julia/depot/logs && chmod -R a+rX /opt/julia

FROM mcr.microsoft.com/devcontainers/base:trixie AS base

# El usuario del entorno se llama alumno, no vscode como en la imagen base: el mismo
# uid (1000) y el mismo sudo, con otro nombre y otra carpeta personal.
# Todo lo de cada cuenta se prepara en la plantilla, /etc/skel, y somosaguas-cuenta lo
# copia a alumno al final de cada etapa. Así, en la distribución, cualquier cuenta nueva
# (la que crea el instalador) nace igual. La plantilla empieza con la terminal de la
# imagen base (el indicador y zsh con oh-my-zsh).
RUN usermod -l alumno -d /home/alumno -m vscode && groupmod -n alumno vscode \
    && sed -i 's/^vscode /alumno /' /etc/sudoers.d/vscode && mv /etc/sudoers.d/vscode /etc/sudoers.d/alumno \
    && sed -i 's/^vscode:/alumno:/' /etc/subuid /etc/subgid \
    && cp -a /home/alumno/.bashrc /home/alumno/.zshrc /home/alumno/.zprofile /home/alumno/.oh-my-zsh /etc/skel/
COPY somosaguas-cuenta /usr/local/bin/

ARG QUARTO_VERSION=1.10.18
ARG PANDOC_VERSION=3.12
ARG TYPST_VERSION=0.15.1
ARG RSTUDIO_VERSION=2026.09.0-174
ARG XSV_VERSION=0.13.0
ARG ZELLIJ_VERSION=0.45.1
# Tema de Quarto de Somosaguas (HTML y Typst), fijado por commit.
ARG SOMOSAGUAS_QUARTO_REV=89de882052b999fa725dd1356ccb64868f327e7c
# La plantilla de Typst de Somosaguas, como paquete local (@local/somosaguas), fijada por commit.
ARG SOMOSAGUAS_TYPST_REV=d8760d5333d7d0418a71db69f8b2da6c28de5644
# Tema de ggplot2 de Somosaguas, fijado por commit (el de Makie, en julia/Manifest.toml).
ARG SOMOSAGUAS_GGPLOT2_REV=2e92406c850bb03e9cfeaebbeac33041f8d6ee01
# Instantánea de CRAN (Posit Package Manager): reconstruir la imagen en 2036
# instala los mismos paquetes de R. Python y Julia se fijan con sus lockfiles.
ARG SNAPSHOT=2026-09-01

ENV DEBIAN_FRONTEND=noninteractive

# Terminal, SQL, R, Python y tipografías del estándar gráfico. Node y npm los
# pide la extensión SQLTools para instalar su driver de SQLite.
RUN apt-get update && apt-get install -y --no-install-recommends \
      jq ripgrep bat fd-find fzf buku tealdeer newsboat htop lazygit earlyoom curl wget parallel less nano git openssh-client rsync ffmpeg manpages-es units \
      sqlite3 postgresql \
      r-base r-base-dev libcurl4-openssl-dev libssl-dev libxml2-dev libpq-dev \
      libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype-dev \
      libpng-dev libtiff-dev libjpeg-dev libwebp-dev \
      python3 python3-venv nodejs npm \
      fonts-firacode gdebi-core \
    && ln -s /usr/bin/batcat /usr/local/bin/bat \
    && ln -s /usr/bin/fdfind /usr/local/bin/fd \
    && for d in /home/alumno /etc/skel; do \
      printf '\n# fzf, como en Omarchy: Ctrl+R busca en el historial, Ctrl+T archivos y Alt+C carpetas.\n%s\n' 'eval "$(fzf --bash)"' >> "$d/.bashrc"; \
      printf '\n# fzf, como en Omarchy: Ctrl+R busca en el historial, Ctrl+T archivos y Alt+C carpetas.\n%s\n' 'source <(fzf --zsh)' >> "$d/.zshrc"; \
    done \
    && rm -rf /var/lib/apt/lists/*

# Git con los ajustes que sus propios desarrolladores recomiendan, para todo el sistema
# (--system): el ~/.gitconfig de cada cuenta, o el que escribe Codespaces, manda sobre
# ellos. La rama principal se llama main; git pull rebasa (sin commits de fusión de
# relleno) y guarda antes lo que esté a medias; git push crea la rama en GitHub la primera
# vez; los nombres con tildes («Pérez.csv») se ven tal cual y no como \303\251; las
# diferencias y los conflictos, más legibles; las ramas, de la más reciente a la más
# antigua; y nano como editor de los mensajes. El nombre sale de la cuenta (el que se
# escribió en el instalador); el correo lo pide Git en el primer commit, con las dos
# órdenes que lo configuran. Codespaces y el devcontainer ya traen los dos.
RUN git config --system init.defaultBranch main \
    && git config --system pull.rebase true \
    && git config --system rebase.autoStash true \
    && git config --system push.autoSetupRemote true \
    && git config --system fetch.prune true \
    && git config --system core.quotePath false \
    && git config --system core.editor nano \
    && git config --system diff.algorithm histogram \
    && git config --system diff.colorMoved default \
    && git config --system merge.conflictStyle zdiff3 \
    && git config --system rerere.enabled true \
    && git config --system branch.sort -committerdate \
    && git config --system tag.sort version:refname \
    && git config --system column.ui auto \
    && git config --system help.autocorrect prompt \
    && git config --system commit.verbose true

# Binarios sueltos. Zellij, sin su servidor web: el terminal no se abre al navegador.
RUN curl -fsSLo /tmp/quarto.deb "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" \
    && curl -fsSLo /tmp/pandoc.deb "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-amd64.deb" \
    && curl -fsSLo /tmp/rstudio.deb "https://download2.rstudio.org/server/jammy/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb" \
    && apt-get update && gdebi -n /tmp/quarto.deb && gdebi -n /tmp/pandoc.deb && gdebi -n /tmp/rstudio.deb \
    && rm -rf /tmp/*.deb /var/lib/apt/lists/* \
    && curl -fsSL "https://github.com/typst/typst/releases/download/v${TYPST_VERSION}/typst-x86_64-unknown-linux-musl.tar.xz" \
      | tar -xJ -C /usr/local/bin --strip-components=1 typst-x86_64-unknown-linux-musl/typst \
    && curl -fsSL "https://github.com/BurntSushi/xsv/releases/download/${XSV_VERSION}/xsv-${XSV_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
      | tar -xz -C /usr/local/bin xsv \
    && curl -fsSL "https://github.com/zellij-org/zellij/releases/download/v${ZELLIJ_VERSION}/zellij-no-web-x86_64-unknown-linux-musl.tar.gz" \
      | tar -xz -C /usr/local/bin zellij

# El tema de Quarto de la Nueva Somosaguas, dentro de Quarto: la extensión entre las
# que trae de serie (somosaguas-html y somosaguas-typst funcionan en cualquier carpeta,
# sin quarto install extension) y, además, como aspecto por omisión. Quarto no tiene
# ajustes globales, y el diálogo de documento nuevo de RStudio escribe «format: html»
# o «format: typst»: sus plantillas de Typst pasan a ser las de Somosaguas, el tema
# somosaguas se añade a los de Bootstrap y es el que se usa cuando el documento no pide
# ninguno, y el idioma por omisión es el español. EB Garamond, la del tema (la de
# Octavio Pardo), para todo el sistema: la de Debian (fonts-ebgaramond) es la antigua,
# se llama «EB Garamond 12» y Typst no la encuentra por «EB Garamond» fuera de Quarto,
# que pasa la carpeta de la extensión. Lo último, en el código de Quarto
# (fijado por versión): si una versión nueva cambia esas líneas, grep falla y la
# construcción se para.
RUN q=$(dirname "$(dirname "$(readlink -f "$(command -v quarto)")")") \
    && curl -fsSL "https://github.com/nuevasomosaguas/somosaguas-quarto-theme/archive/${SOMOSAGUAS_QUARTO_REV}.tar.gz" | tar -xz -C /tmp \
    && e="/tmp/somosaguas-quarto-theme-${SOMOSAGUAS_QUARTO_REV}/_extensions/somosaguas" \
    && cp -r "$e" "$q/share/extensions/somosaguas" \
    && cp "$e/typst-template.typ" "$e/typst-show.typ" "$q/share/formats/typst/pandoc/quarto/" \
    && cp "$e/somosaguas.scss" "$q/share/formats/html/bootstrap/themes/" \
    && mkdir -p /usr/local/share/fonts/somosaguas && cp "$e"/fonts/EBGaramond*.ttf /usr/local/share/fonts/somosaguas/ && fc-cache -f \
    && sed -i -e 's/metadata\[kTheme\] || \[\];/metadata[kTheme] || "somosaguas";/' \
      -e 's/\[kLang\]: "en",/[kLang]: "es",/' -e 's/metadata\[kLang\] || "en";/metadata[kLang] || "es";/' "$q/bin/quarto.js" \
    && grep -q 'metadata\[kTheme\] || "somosaguas";' "$q/bin/quarto.js" \
    && grep -q '\[kLang\]: "es",' "$q/bin/quarto.js" && grep -q 'metadata\[kLang\] || "es";' "$q/bin/quarto.js" \
    && mkdir -p /etc/skel/.local/share/pandoc/templates \
    && cp "$e/typst-template.typ" "$e/../../pandoc/default.typst" /etc/skel/.local/share/pandoc/templates/ \
    && rm -rf /tmp/somosaguas-quarto-theme-*
# La misma plantilla en Typst puro, como paquete local de cada cuenta: se importa desde
# cualquier carpeta (#import "@local/somosaguas:0.1.0") y «typst init
# @local/somosaguas:0.1.0 trabajo» crea un documento nuevo con ella.
RUN curl -fsSL "https://github.com/nuevasomosaguas/somosaguas-typst-template/archive/${SOMOSAGUAS_TYPST_REV}.tar.gz" | tar -xz -C /tmp \
    && t="/tmp/somosaguas-typst-template-${SOMOSAGUAS_TYPST_REV}" \
    && v=$(sed -n 's/^version *= *"\(.*\)"/\1/p' "$t/typst.toml") && d="/etc/skel/.local/share/typst/packages/local/somosaguas/$v" \
    && mkdir -p "$d" && cp -r "$t/typst.toml" "$t/template.typ" "$t/plantilla" "$d/" \
    && rm -rf "$t"
# Pandoc suelto (Quarto y RStudio usan el suyo): «pandoc texto.md -o texto.pdf» sale
# con Typst y la misma plantilla, desde la carpeta de Pandoc de cada cuenta, y cita con
# la biblioteca de la Nueva Somosaguas (más abajo) y la propia de Zotero, si la hay.
COPY pandoc/pandoc /usr/local/bin/pandoc
# bibsearch, bibpdf y bibclave: las entradas de todos los .bib de la cuenta, con fzf;
# bibcongelar, la bibliografía propia de un trabajo (referencias.bib, solo lo citado);
# biblectura, la nota de Obsidian de un libro que se lee en papel; y
# marcadores, las páginas guardadas en buku (lo que no se cita), también con fzf.
COPY bib/bibfzf bib/marcadores /usr/local/bin/
RUN for o in bibsearch bibpdf bibclave bibcongelar biblectura; do ln -s bibfzf /usr/local/bin/$o; done
# nuevo-proyecto, un trabajo listo para empezar: datos, análisis, pruebas, informe y
# ./construir.sh (lo explica ~/Documents/Proyectos.pdf, más abajo).
COPY proyecto/nuevo-proyecto /usr/local/bin/

# RStudio Server en modo de un solo usuario, sin contraseña: el puerto solo
# se reenvía a localhost o, en Codespaces, es privado para su dueño.
RUN ln -s /usr/lib/rstudio-server/bin/rserver /usr/local/bin/rserver \
    && mkdir -p /var/lib/rstudio-server-alumno \
    && printf 'provider=sqlite\ndirectory=/var/lib/rstudio-server-alumno\n' > /var/lib/rstudio-server-alumno/dbconf.conf \
    && chown -R alumno:alumno /var/lib/rstudio-server-alumno \
    && printf '%s\n' server-user=alumno auth-none=1 \
      server-data-dir=/var/lib/rstudio-server-alumno \
      database-config-file=/var/lib/rstudio-server-alumno/dbconf.conf > /etc/rstudio/rserver.conf

# R: binarios de Posit Package Manager congelados en la fecha de SNAPSHOT.
# warn = 2 convierte en error cualquier paquete que no se instale. El tema se baja
# como tarball y no con install_github: la API de GitHub sin token solo admite
# 60 peticiones por hora, y Codespaces y Actions comparten IP.
RUN printf '%s\n' \
      "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/trixie/${SNAPSHOT}'))" \
      "options(HTTPUserAgent = sprintf('R/%s R (%s)', getRversion(), paste(getRversion(), R.version['platform'], R.version['arch'], R.version['os'])))" \
      >> /etc/R/Rprofile.site \
    && Rscript -e 'options(warn = 2, Ncpus = parallel::detectCores()); \
      install.packages(c("tidyverse", "ragg", "systemfonts", "knitr", "rmarkdown", \
        "DBI", "RSQLite", "RPostgres", "remotes", "languageserver", "styler", "httpgd")); \
      remotes::install_url("https://github.com/nuevasomosaguas/somosaguas-ggplot2/archive/'"${SOMOSAGUAS_GGPLOT2_REV}"'.tar.gz", upgrade = "never")'

# Python: uv (y uvx) y un entorno en /opt/venv con las versiones exactas de
# python/uv.lock. Es de root: el alumno no puede estropearlo, y lo suyo lo instala
# con uv en su proyecto o en ~/.local/bin, que va antes en el PATH (con TinyTeX).
COPY --from=ghcr.io/astral-sh/uv:0.12.20 /uv /uvx /usr/local/bin/
COPY python/ /opt/entorno-python/
ENV PATH=/home/alumno/.local/bin:/home/alumno/.TinyTeX/bin/x86_64-linux:/opt/venv/bin:$PATH
RUN UV_PROJECT_ENVIRONMENT=/opt/venv UV_PYTHON_DOWNLOADS=never \
      uv sync --frozen --no-cache --python /usr/bin/python3 --project /opt/entorno-python

# earlyoom: cierra el cálculo que agota la memoria antes de que la máquina se congele,
# sin tocar el editor ni el escritorio (ajustes y motivos en earlyoom/earlyoom).
# postStartCommand lo arranca, como a PostgreSQL. La swap comprimida (zram) y los
# sysctl de memoria son del kernel del anfitrión: un contenedor no puede cambiarlos.
COPY earlyoom/earlyoom /etc/default/earlyoom
COPY earlyoom/aviso-earlyoom /usr/local/bin/

# yt-dlp, pensado para cursos: hasta 1080p, subtítulos en .srt y cada lista en su
# carpeta de ~/Cursos. En /etc, para que valga también el yt-dlp que el alumno ponga
# al día con `uv tool install`.
COPY yt-dlp.conf /etc/yt-dlp.conf

# PostgreSQL: el usuario alumno es superusuario con su propia base, así `psql` entra sin más.
RUN service postgresql start \
    && su postgres -c "createuser -s alumno && createdb -O alumno alumno" \
    && service postgresql stop

# Newsboat con las revistas y preprints de la frontera ya suscritos: `,p` sobre un
# artículo baja su PDF (leer-pdf) y el resto de enlaces van al navegador (abrir-enlace).
# La lista de la facultad es de root; /usr/local/bin/newsboat le suma las fuentes del
# alumno (mis-fuentes), siempre bajo la etiqueta "Fuentes propias".
COPY newsboat/newsboat newsboat/abrir-enlace newsboat/que-hacer newsboat/leer-pdf newsboat/crossref-rss newsboat/zotero-guardar newsboat/buku-newsboat /usr/local/bin/
COPY newsboat/urls /usr/local/share/somosaguas/newsboat/urls
COPY newsboat/config newsboat/mis-fuentes /etc/skel/.config/newsboat/
# Zellij abre con la sesión del alumno: terminal, git (lazygit), Julia, R, SQL,
# lecturas (Newsboat) y sistema (htop).
COPY zellij/ /etc/skel/.config/zellij/
COPY lazygit/ /etc/skel/.config/lazygit/
COPY htop/ /etc/skel/.config/htop/

# Pluto en el puerto 1234, accesible desde el reenvío de Codespaces.
RUN printf '#!/bin/sh\nexec julia -e "using Pluto; Pluto.run(host=\\"0.0.0.0\\", port=1234, launch_browser=false)"\n' \
      > /usr/local/bin/pluto && chmod +x /usr/local/bin/pluto

# Julia y su depósito precompilado, desde la etapa julia. Cada cuenta empieza con una
# copia del entorno global (Project.toml y Manifest.toml, que ocupan nada) en su
# ~/.julia: sus paquetes y su compilación salen del depósito compartido, y lo que la
# cuenta añada va a su depósito, el primero de JULIA_DEPOT_PATH.
COPY --from=julia /opt/julia /opt/julia
RUN ln -s /opt/julia/bin/julia /usr/local/bin/julia \
    && mkdir -p /etc/skel/.julia && cp -r /opt/julia/depot/environments /etc/skel/.julia/
ENV JULIA_DEPOT_PATH=:/opt/julia/depot

# El sistema en español (mensajes, menús, fechas) y en la hora de Madrid, igual en todos
# los niveles. Los números, en C: con coma decimal, el printf y el sort -n de la
# terminal fallarían o no coincidirían con R, Julia y Python, que usan punto.
RUN sed -i 's/^# *es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
ENV LANG=es_ES.UTF-8 LANGUAGE=es_ES:es LC_NUMERIC=C.UTF-8 TZ=Europe/Madrid

# TinyTeX, de reserva para los PDF con LaTeX desde RStudio (y Quarto), fijado en la
# versión del mes de SNAPSHOT. Cada cuenta tiene el suyo en ~/.TinyTeX (unos 250 MB),
# copiado de la plantilla, para que tinytex instale los paquetes de LaTeX que falten
# sin tocar el sistema ni las demás cuentas. Sin enlaces en ~/bin: el PATH ya lo incluye.
# ponytail: tlmgr baja esos paquetes del CTAN actual, que solo sirve hasta que salga
# el TeX Live siguiente (abril); luego, apuntar tlmgr al archivo histórico del año.
ARG TINYTEX_VERSION=2026.09
RUN Rscript -e 'tinytex::install_tinytex(version = "'"${TINYTEX_VERSION}"'", bundle = "TinyTeX-1", dir = "/etc/skel/.TinyTeX", add_path = FALSE)'

# Chuletas de tldr (tealdeer), ya descargadas, y en ~/Documents el manual de la
# terminal, The Linux Command Line, de William Shotts (CC BY-NC-ND 3.0), fijado por su
# suma SHA-256, y la biblioteca de la Nueva Somosaguas en BibTeX. La biblioteca vive
# en el repositorio de la web, su única fuente; aquí se fija el commit. Se instala en
# el sistema, donde la lee pandoc para citar, y en ~/Documents queda un enlace a ella.
ARG TLCL_VERSION=25.12A
ARG TLCL_SHA256=c6c564db237ea1d5f5758c5a0df5d8c804041ef483585259687d04d9ecf2cd05
ARG BIBLIOTECA_REV=207beeb67e62f4dc771e808f039c93481d89dc55
RUN XDG_CACHE_HOME=/etc/skel/.cache tldr --update --quiet \
    && mkdir -p /usr/local/share/somosaguas && curl -fsSLo /usr/local/share/somosaguas/nuevasomosaguas.bib \
      "https://raw.githubusercontent.com/nuevasomosaguas/nuevasomosaguas.github.io/${BIBLIOTECA_REV}/biblioteca.bib" \
    && cd /etc/skel && mkdir -p Documents Downloads Cursos Biblioteca/almacen_pdf \
    && ln -s /usr/local/share/somosaguas/nuevasomosaguas.bib Documents/nuevasomosaguas.bib \
    && curl -fsSLo Documents/TLCL-${TLCL_VERSION}.pdf \
      "https://sourceforge.net/projects/linuxcommand/files/TLCL/${TLCL_VERSION%A}/TLCL-${TLCL_VERSION}.pdf/download" \
    && echo "${TLCL_SHA256}  Documents/TLCL-${TLCL_VERSION}.pdf" | sha256sum -c --quiet

# El manual de la primera vez, ~/Documents/Bienvenida.pdf, y el de los trabajos,
# ~/Documents/Proyectos.pdf: Markdown compilado aquí con el mismo pandoc, la plantilla
# de Somosaguas y la biblioteca (Bienvenida cita una obra, como ejemplo de cómo se cita).
COPY bienvenida/bienvenida.md proyecto/proyectos.md /tmp/
RUN cd /tmp && XDG_CACHE_HOME=/tmp pandoc --data-dir=/etc/skel/.local/share/pandoc bienvenida.md -o /etc/skel/Documents/Bienvenida.pdf \
    && XDG_CACHE_HOME=/tmp pandoc --data-dir=/etc/skel/.local/share/pandoc proyectos.md -o /etc/skel/Documents/Proyectos.pdf \
    && rm bienvenida.md proyectos.md pandoc-somosaguas.yaml

# alumno recibe la plantilla.
RUN somosaguas-cuenta alumno
USER alumno

# Si falta una herramienta, la imagen no se construye. Julia comprueba además que
# la precompilación del depósito compartido le sirve a una cuenta.
# rserver no admite --version: basta con que exista; ssh la da con -V. Las pruebas de
# pandoc, desde /tmp: el PDF pasa por una carpeta temporal en la carpeta actual.
RUN set -e; for h in julia R Rscript python node npm sqlite3 psql git nano quarto pandoc typst jq fzf buku units rg bat fd xsv tldr htop lazygit rsync yt-dlp uv uvx zellij curl; do \
      "$h" --version > /dev/null; done \
    && command -v rserver > /dev/null && ssh -V 2> /dev/null && tldr --quiet tar > /dev/null \
    && cd /tmp && printf '# Prueba\n\nTexto.[^1]\n\n[^1]: Nota.\n' | pandoc -o /tmp/prueba.pdf 2> /tmp/prueba.err && head -c 4 /tmp/prueba.pdf | grep -q %PDF \
    && ! grep -i 'unknown font' /tmp/prueba.err && typst fonts | grep -qx 'EB Garamond' && rm /tmp/prueba.pdf /tmp/prueba.err \
    && typst init @local/somosaguas:0.1.0 /tmp/plantilla > /dev/null && typst compile /tmp/plantilla/main.typ 2> /tmp/plantilla.err \
    && ! grep -i 'unknown font' /tmp/plantilla.err && rm -r /tmp/plantilla /tmp/plantilla.err \
    && echo '[@plomin2018blueprint]' | pandoc -o /tmp/cita.html && grep -q 'Plomin' /tmp/cita.html && rm /tmp/cita.html \
    && mkdir /tmp/trabajo && cd /tmp/trabajo && echo 'Como se sabe [@plomin2018blueprint].' > texto.md && bibcongelar texto.md \
    && grep -q '^@.*plomin2018blueprint' referencias.bib && pandoc texto.md -o texto.html && grep -q 'Plomin' texto.html && cd /tmp && rm -r /tmp/trabajo \
    && bibsearch --entrada plomin2018blueprint ~/Documents/nuevasomosaguas.bib | grep -q 'Blueprint' \
    && HOME=/tmp/casa FZF_DEFAULT_OPTS='--filter=^wachter2014essential' biblectura > /dev/null \
    && grep -q '^citekey: "wachter2014essential"' /tmp/casa/Notas/Lecturas/wachter2014essential.md && rm -r /tmp/casa \
    && cd /tmp && for d in typst quarto; do nuevo-proyecto proyecto-$d --$d --python > /dev/null \
      && proyecto-$d/construir.sh > /dev/null && head -c 4 proyecto-$d/informe.pdf | grep -q %PDF && rm -r proyecto-$d || exit 1; done \
    && newsboat -x print-unread > /dev/null && grep -q '^@' ~/Documents/nuevasomosaguas.bib \
    && { timeout 2 bash -c '. /etc/default/earlyoom; eval exec earlyoom "$EARLYOOM_ARGS" --dryrun' > /dev/null 2>&1; [ $? -eq 124 ]; } \
    && julia -e 'all(p -> Base.isprecompiled(Base.identify_package(p)), ["CairoMakie", "Agents"]) || error("la caché de Julia no sirvió tras copiarla")' \
    && Rscript -e 'library(somosaguas); library(tidyverse); library(RPostgres); stopifnot(tinytex::is_tinytex())' \
    && python -c 'import polars, duckdb, psycopg'

FROM base AS escritorio
ARG OBSIDIAN_VERSION=1.13.7
ARG AUTO_LINK_TITLE_VERSION=1.5.5
ARG PANDOC_REFERENCE_LIST_VERSION=2.0.25
# El estilo de cita de pandoc (Chicago, autor-fecha) y el idioma, fijados por commit.
ARG CSL_STYLES_REV=1aaf551f864d50e875a617b4faf2bf5da30f3f15
ARG CSL_LOCALES_REV=938c09c164a60b3cfeabe61089f1bf4c3ea6a4ed
ARG MATCHA_VERSION=2025-04-11
ARG PAPIRUS_FOLDERS_VERSION=1.14.0
USER root
# XFCE con Mousepad, Ristretto, Zathura, Foliate, LibreOffice Calc, Obsidian, Brave y mpv.
# El VNC y el noVNC los pone la feature desktop-lite; xstartup hace que arranque
# XFCE en lugar de Fluxbox.
# Obsidian (Electron) no encuentra el sandbox de usuario dentro de un contenedor.
RUN curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
      https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
      > /etc/apt/sources.list.d/brave-browser-release.list \
    && curl -fsSLo /tmp/obsidian.deb "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/obsidian_${OBSIDIAN_VERSION}_amd64.deb" \
    && apt-get update && apt-get install -y --no-install-recommends \
      xfce4 xfce4-terminal xfce4-whiskermenu-plugin xfce4-clipman-plugin xfce4-genmon-plugin xfce4-notifyd xfce4-pulseaudio-plugin pavucontrol dbus-x11 fonts-inter fonts-noto-color-emoji \
      gtk2-engines-murrine papirus-icon-theme librsvg2-common gsettings-desktop-schemas xdg-user-dirs mousepad xournalpp ristretto tumbler xfce4-screenshooter maim xdotool libnotify-bin \
      tesseract-ocr tesseract-ocr-spa hunspell-es foliate zathura zathura-pdf-poppler zathura-djvu xclip poppler-utils djvulibre-bin \
      libreoffice-calc libreoffice-gtk3 libreoffice-l10n-es brave-browser firefox-esr firefox-esr-l10n-es-es mpv \
    && gdebi -n /tmp/obsidian.deb \
    && rm -rf /tmp/obsidian.deb /var/lib/apt/lists/* \
    && sed -i 's|^Exec=/opt/Obsidian/obsidian|& --no-sandbox|' /usr/share/applications/md.obsidian.Obsidian.desktop

# Bibliografía: JabRef para los .bib y Zotero para recoger referencias del navegador.
# Su perfil (zotero/) llega ya creado, sin la página de inicio ni la oferta de instalar
# el complemento de LibreOffice.
# JabRef se queda en la 5.15 estable hasta que salga la 6.0.
ARG JABREF_VERSION=5.15
ARG ZOTERO_VERSION=10.0.3
# Complementos de Zotero, fijados por versión y suma: Better BibTeX (claves de cita
# estables y la exportación continua a ~/Biblioteca/zotero.bib) y ZotMoov (los PDF, a
# ~/Biblioteca/almacen_pdf).
ARG BETTER_BIBTEX_VERSION=9.0.64
ARG BETTER_BIBTEX_SHA256=84c4b5b05ffac9a9c7e2ff79663612486f7781690dd59b12a1e62aecdcfa7c27
ARG ZOTMOOV_VERSION=1.2.32
ARG ZOTMOOV_SHA256=7770dc2c62d2aaab2662fd7402afadd058387bff69578481ac039bfc050ecc2b
RUN curl -fsSLo /tmp/jabref.deb "https://github.com/JabRef/jabref/releases/download/v${JABREF_VERSION}/jabref_${JABREF_VERSION}_amd64.deb" \
    && apt-get update && gdebi -n /tmp/jabref.deb \
    && rm -rf /tmp/jabref.deb /var/lib/apt/lists/* \
    && curl -fsSL "https://download.zotero.org/client/release/${ZOTERO_VERSION}/Zotero-${ZOTERO_VERSION}_linux-x86_64.tar.xz" | tar -xJ -C /opt \
    && mv /opt/Zotero_linux-x86_64 /opt/zotero && /opt/zotero/set_launcher_icon \
    && sed 's|^Exec=.*|Exec=/opt/zotero/zotero -url %U|' /opt/zotero/zotero.desktop > /usr/share/applications/zotero.desktop \
    && ln -s /opt/zotero/zotero /usr/local/bin/zotero
# Brave instala solo el Zotero Connector: el botón que guarda en Zotero lo que se lee.
COPY escritorio/brave-politicas.json /etc/brave/policies/managed/zotero.json
# Firefox, con Zotero Connector y AdGuard y la higiene que haría un user.js, pero para
# todos los perfiles (un user.js solo sirve a un perfil que aún no existe): sin
# telemetría, estudios, Pocket ni patrocinios, rastreadores en bloqueo estricto y la
# caché solo en memoria. La misma página de inicio en los dos navegadores, propuesta y
# no impuesta: `docker build --build-arg PAGINA_INICIO=...` la cambia.
ARG PAGINA_INICIO=https://nuevasomosaguas.github.io
COPY escritorio/firefox-politicas.json escritorio/brave-inicio.json /tmp/
RUN mkdir -p /etc/firefox/policies /etc/brave/policies/recommended \
    && sed "s|@PAGINA_INICIO@|${PAGINA_INICIO}|g" /tmp/firefox-politicas.json > /etc/firefox/policies/policies.json \
    && sed "s|@PAGINA_INICIO@|${PAGINA_INICIO}|g" /tmp/brave-inicio.json > /etc/brave/policies/recommended/inicio.json \
    && rm /tmp/firefox-politicas.json /tmp/brave-inicio.json

# El aspecto de Manjaro: Matcha oscuro y Papirus, en rojo (aliz) en lugar de verde,
# con Inter, EB Garamond y Fira Code. Los ajustes van en /etc/xdg: son los
# predeterminados y cada usuario puede cambiarlos.
RUN curl -fsSL "https://github.com/vinceliuice/Matcha-gtk-theme/archive/refs/tags/${MATCHA_VERSION}.tar.gz" | tar -xz -C /tmp \
    && /tmp/Matcha-gtk-theme-${MATCHA_VERSION}/install.sh -d /usr/share/themes -c dark -t aliz \
    && curl -fsSL "https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-folders/v${PAPIRUS_FOLDERS_VERSION}/papirus-folders" \
      | bash -s -- -C carmine -t Papirus-Dark \
    && rm -rf /tmp/Matcha-gtk-theme-*
COPY escritorio/fonts.conf /etc/fonts/local.conf
# noVNC se instala con la feature, después de la imagen: postCreateCommand copia
# estos ajustes (pantalla a la medida de la ventana y máxima calidad de imagen).
COPY escritorio/novnc.json /usr/local/share/somosaguas/novnc.json
# Las apps de GTK 4 y libadwaita (Foliate) no leen el tema de XFCE: se les da el
# modo oscuro y las mismas letras por GSettings.
# En la distribución, nm-applet no avisa de cada conexión lograda (sí de las perdidas).
# Mousepad guarda siempre la sesión (vuelve con lo abierto tras cerrarse o un fallo),
# ajusta las líneas largas y escribe en Fira Code 12.
RUN printf '%s\n' "[org.gnome.desktop.interface]" "color-scheme='prefer-dark'" \
      "font-name='Inter 10'" "document-font-name='EB Garamond 12'" "monospace-font-name='Fira Code 10'" \
      "[org.gnome.nm-applet]" "disable-connected-notifications=true" "suppress-wireless-networks-available=true" \
      "[org.xfce.mousepad.preferences.file]" "session-restore='always'" \
      "[org.xfce.mousepad.preferences.view]" "word-wrap=true" "use-default-monospace-font=false" "font-name='Fira Code 12'" \
      > /usr/share/glib-2.0/schemas/90_somosaguas.gschema.override \
    && glib-compile-schemas /usr/share/glib-2.0/schemas
# WebKitGTK (el visor de Foliate) no puede abrir su sandbox dentro del contenedor
# ni usar la GPU, que el VNC no tiene.
ENV WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS=1 WEBKIT_DISABLE_DMABUF_RENDERER=1
COPY escritorio/xfce/ /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/
# El fondo: papel con una franja granate y otra de tinta. Ocupa el sitio del fondo
# predeterminado de XFCE (dpkg-divert aparta el original sin que una actualización lo
# devuelva), así sirve en cualquier pantalla sin nombrarla.
COPY escritorio/fondo.svg /usr/share/backgrounds/somosaguas.svg
# El icono de la Nueva Somosaguas (nueva-somosaguas), en el tema del sistema: la marca del
# DAG hasta 48 px, donde el sello no se lee, y el sello a partir de 64. Lo usa el botón
# del menú.
COPY escritorio/iconos/ /usr/share/icons/hicolor/
RUN gtk-update-icon-cache -f /usr/share/icons/hicolor
RUN dpkg-divert --local --rename --divert /usr/share/backgrounds/xfce/xfce-x.svg.xfce \
      --add /usr/share/backgrounds/xfce/xfce-x.svg \
    && ln -s ../somosaguas.svg /usr/share/backgrounds/xfce/xfce-x.svg
# Thunar: Super+Intro abre XFCE Terminal en la carpeta actual.
COPY escritorio/thunar/ /etc/xdg/Thunar/
# En el menú: la sesión de Zellij, RStudio (en el navegador) y Newsboat. Papirus es
# todo SVG: sin librsvg2-common, GTK no dibuja casi ningún icono.
COPY escritorio/aplicaciones/ /usr/local/share/applications/
# Cada programa, con una descripción en el menú que dice para qué sirve aquí; fuera los
# accesos duplicados. describir-menu copia los .desktop de los paquetes a /usr/local.
COPY escritorio/describir-menu escritorio/actualizaciones-seguridad escritorio/captura \
     escritorio/avisos-memoria escritorio/bienvenida escritorio/marcadores/marcadores-web /usr/local/bin/
# lecturas: por dónde va cada PDF de Zathura y cada EPUB de Foliate, con fzf, y en
# ~/Biblioteca/lecturas.tsv, con la clave de la bibliografía de cada archivo.
COPY bib/lecturas /usr/local/bin/
# Los marcadores de buku en el navegador (127.0.0.1:8484), con el aspecto de la web: en el
# menú, en Internet, y en la barra de Firefox y Brave. Arranca con el escritorio.
COPY escritorio/marcadores/index.html /usr/local/share/somosaguas/marcadores/index.html
# Al entrar en el escritorio: los avisos de earlyoom cuando cierra un cálculo, el servidor
# de los marcadores y, la primera vez, el manual de bienvenida en Zathura.
COPY escritorio/autostart/ /etc/xdg/autostart/
# Atajos: capturas con maim (al portapapeles y a ~/Screenshots), el terminal desplegable
# y xfce4-screenshooter. Impr Pant (zona), Mayús+Impr (pantalla) y Alt+Impr (ventana)
# ocupan las teclas que XFCE ya reserva para capturar; se añaden Ctrl+Impr (texto de
# una zona, OCR), Ctrl+Alt+Impr (grabar la pantalla), Super+Mayús+Impr (anotar la
# última captura en Xournal++), Super+Impr (xfce4-screenshooter) y F12 (terminal).
RUN f=/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml \
    && sed -i -e 's|value="xfce4-screenshooter -w"|value="captura ventana"|' \
      -e 's|value="xfce4-screenshooter -r"|value="captura pantalla"|' \
      -e 's|name="Print" type="string" value="xfce4-screenshooter"/>|name="Print" type="string" value="captura zona"/>\
      <property name="\&lt;Primary\&gt;Print" type="string" value="captura ocr"/>\
      <property name="\&lt;Primary\&gt;\&lt;Alt\&gt;Print" type="string" value="captura grabar"/>\
      <property name="\&lt;Shift\&gt;\&lt;Super\&gt;Print" type="string" value="captura anotar"/>\
      <property name="\&lt;Super\&gt;Print" type="string" value="xfce4-screenshooter"/>\
      <property name="F12" type="string" value="xfce4-terminal --drop-down"/>|' "$f" \
    && for k in "captura zona" "captura ocr" "captura grabar" "captura anotar" "captura ventana" \
      "captura pantalla" 'Print" type="string" value="xfce4-screenshooter' "--drop-down"; do \
      grep -qF -- "$k" "$f" || exit 1; done
# El escudo de las actualizaciones de seguridad, a la izquierda del reloj (genmon).
COPY escritorio/panel/ /etc/xdg/xfce4/panel/
COPY escritorio/descripciones.tsv /usr/local/share/somosaguas/
RUN describir-menu

# mpv retoma cada vídeo donde se dejó, también tras un cierre inesperado, y con h
# abre el historial (memo, fijado por commit). Los subtítulos automáticos de YouTube,
# que ruedan línea a línea, salen de dos en dos líneas, quietos (subtitulos-bloques).
ARG MEMO_REV=e0624611438b2e19ef4b7e24f53461c9d0304b07
COPY escritorio/mpv/ /etc/mpv/
COPY escritorio/subtitulos-bloques /usr/local/bin/
RUN curl -fsSLo /etc/mpv/scripts/memo.lua \
      "https://raw.githubusercontent.com/po5/memo/${MEMO_REV}/memo.lua"

# Zathura con los colores de la web (Ctrl+R: modo noche) y predeterminado para PDF;
# C e I copian la página en pantalla como texto o como imagen (copiar-pagina).
COPY escritorio/zathurarc /etc/zathurarc
COPY escritorio/copiar-pagina /usr/local/bin/
COPY escritorio/mimeapps.list /etc/xdg/mimeapps.list

# A la plantilla: la bóveda de Obsidian ~/Notas, ya registrada (imágenes en imagenes/,
# las notas de lectura de biblectura en Lecturas/, con su tabla en Lecturas.base,
# Auto Link Title activo, Pandoc Reference List con la biblioteca de la Nueva Somosaguas
# —al escribir @ propone las entradas, con su título, y la barra lateral muestra las
# referencias de la nota en Chicago, como pandoc; el estilo y el idioma van ya en la
# imagen, sin bajarlos al abrir— y el tema nocturno de Somosaguas), el perfil de Zotero, las
# etiquetas de los iconos del escritorio en tinta (gtk.css), los marcadores de Thunar y
# la carpeta de las capturas. Las rutas absolutas llevan @HOME@: somosaguas-cuenta pone
# la carpeta de cada cuenta.
COPY escritorio/Notas /etc/skel/Notas
COPY escritorio/obsidian.json /etc/skel/.config/obsidian/obsidian.json
COPY escritorio/zotero/ /etc/skel/.zotero/zotero/
COPY escritorio/zotero/user.js escritorio/zotero/prefs.js /etc/skel/.zotero/zotero/somosaguas.default/
# RStudio busca las citas también en el Zotero local, con las claves de Better BibTeX.
COPY escritorio/rstudio-prefs.json /etc/rstudio/rstudio-prefs.json
COPY escritorio/gtk.css /etc/skel/.config/gtk-3.0/gtk.css
COPY escritorio/user-dirs.dirs /etc/skel/.config/user-dirs.dirs
RUN cd /etc/skel && mkdir -p Desktop Notas/imagenes Notas/Lecturas Notas/.obsidian/plugins/obsidian-auto-link-title .vnc .config/xfce4 Screenshots \
    && for f in main.js manifest.json styles.css; do \
      curl -fsSLo Notas/.obsidian/plugins/obsidian-auto-link-title/$f \
        "https://github.com/zolrath/obsidian-auto-link-title/releases/download/${AUTO_LINK_TITLE_VERSION}/$f"; done \
    && for f in main.js manifest.json styles.css; do \
      curl -fsSLo Notas/.obsidian/plugins/obsidian-pandoc-reference-list/$f \
        "https://github.com/community-archive/obsidian-pandoc-reference-list/releases/download/${PANDOC_REFERENCE_LIST_VERSION}/$f"; done \
    && mkdir -p /usr/local/share/somosaguas/csl Notas/.pandoc \
    && curl -fsSLo /usr/local/share/somosaguas/csl/chicago-author-date.csl \
      "https://raw.githubusercontent.com/citation-style-language/styles/${CSL_STYLES_REV}/chicago-author-date.csl" \
    && for l in es-ES en-US; do curl -fsSLo Notas/.pandoc/locales-$l.xml \
      "https://raw.githubusercontent.com/citation-style-language/locales/${CSL_LOCALES_REV}/locales-$l.xml"; done \
    && z=.zotero/zotero/somosaguas.default/extensions && mkdir -p "$z" \
    && curl -fsSLo "$z/better-bibtex@iris-advies.com.xpi" \
      "https://github.com/retorquere/zotero-better-bibtex/releases/download/v${BETTER_BIBTEX_VERSION}/zotero-better-bibtex-${BETTER_BIBTEX_VERSION}.xpi" \
    && curl -fsSLo "$z/zotmoov@wileyy.com.xpi" \
      "https://github.com/wileyyugioh/zotmoov/releases/download/${ZOTMOOV_VERSION}/zotmoov-${ZOTMOOV_VERSION}-fx.xpi" \
    && printf '%s  %s\n' "${BETTER_BIBTEX_SHA256}" "$z/better-bibtex@iris-advies.com.xpi" "${ZOTMOOV_SHA256}" "$z/zotmoov@wileyy.com.xpi" | sha256sum -c --quiet \
    && printf '#!/bin/sh\nexec startxfce4\n' > .vnc/xstartup && chmod +x .vnc/xstartup \
    && printf '[Screenshooter]\nscreenshot_dir=file://@HOME@/Screenshots\n' > .config/xfce4/xfce4-screenshooter \
    && for d in Documents Downloads Biblioteca Notas Cursos Screenshots; do \
      echo "file://@HOME@/$d $d"; done > .config/gtk-3.0/bookmarks \
    && somosaguas-cuenta alumno
USER alumno
RUN brave-browser --version && firefox-esr --version && mpv --version > /dev/null && zathura --version > /dev/null && test -f /usr/lib/x86_64-linux-gnu/zathura/libdjvu.so \
    && test -x /opt/Obsidian/obsidian && for f in /usr/local/bin/marcadores-web /usr/local/bin/lecturas /usr/local/bin/subtitulos-bloques; do python3 -c 'import ast, sys; ast.parse(open(sys.argv[1]).read())' "$f"; done && command -v captura maim tesseract xfce4-screenshooter copiar-pagina xclip pdftotext pdftoppm djvutxt ddjvu mousepad xournalpp ristretto xfce4-clipman startxfce4 foliate localc \
    && test -x /opt/jabref/bin/JabRef && ! LD_LIBRARY_PATH=/opt/zotero ldd /opt/zotero/zotero-bin /opt/zotero/libxul.so | grep "not found" \
    && test -d /usr/share/themes/Matcha-dark-aliz \
    && fc-match serif | grep -q "EB Garamond" && fc-match sans-serif | grep -q Inter && fc-match monospace | grep -q "Fira Code"
