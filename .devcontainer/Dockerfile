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
# Paquetes del entorno global del usuario, ya precompilados: Pluto, CSV,
# DataFrames, CairoMakie, Agents y somosaguas-makie, con las versiones exactas
# del Manifest.toml. Cada asignatura trae el suyo; este solo ahorra la primera espera.
# Para subir versiones: `julia --project=.devcontainer/julia -e 'using Pkg; Pkg.update()'`.
USER vscode
COPY julia/ /tmp/entorno-julia/
RUN mkdir -p ~/.julia/environments \
    && cp -r /tmp/entorno-julia ~/.julia/environments/"v${JULIA_VERSION%.*}" \
    && /opt/julia/bin/julia -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'

FROM mcr.microsoft.com/devcontainers/base:trixie AS base

ARG QUARTO_VERSION=1.10.18
ARG TYPST_VERSION=0.15.1
ARG RSTUDIO_VERSION=2026.09.0-174
ARG XSV_VERSION=0.13.0
ARG ZELLIJ_VERSION=0.45.1
# Tema de ggplot2 de Somosaguas, fijado por commit (el de Makie, en julia/Manifest.toml).
ARG SOMOSAGUAS_GGPLOT2_REV=2e92406c850bb03e9cfeaebbeac33041f8d6ee01
# Instantánea de CRAN (Posit Package Manager): reconstruir la imagen en 2036
# instala los mismos paquetes de R. Python y Julia se fijan con sus lockfiles.
ARG SNAPSHOT=2026-09-01

ENV DEBIAN_FRONTEND=noninteractive

# Terminal, SQL, R, Python y tipografías del estándar gráfico. Node y npm los
# pide la extensión SQLTools para instalar su driver de SQLite.
RUN apt-get update && apt-get install -y --no-install-recommends \
      jq ripgrep bat fd-find tealdeer newsboat htop lazygit earlyoom curl wget parallel less nano git openssh-client rsync ffmpeg \
      sqlite3 postgresql \
      r-base r-base-dev libcurl4-openssl-dev libssl-dev libxml2-dev libpq-dev \
      libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype-dev \
      libpng-dev libtiff-dev libjpeg-dev libwebp-dev \
      python3 python3-venv nodejs npm \
      fonts-ebgaramond fonts-firacode gdebi-core \
    && ln -s /usr/bin/batcat /usr/local/bin/bat \
    && ln -s /usr/bin/fdfind /usr/local/bin/fd \
    && rm -rf /var/lib/apt/lists/*

# Binarios sueltos. Zellij, sin su servidor web: el terminal no se abre al navegador.
RUN curl -fsSLo /tmp/quarto.deb "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" \
    && curl -fsSLo /tmp/rstudio.deb "https://download2.rstudio.org/server/jammy/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb" \
    && apt-get update && gdebi -n /tmp/quarto.deb && gdebi -n /tmp/rstudio.deb \
    && rm -rf /tmp/*.deb /var/lib/apt/lists/* \
    && curl -fsSL "https://github.com/typst/typst/releases/download/v${TYPST_VERSION}/typst-x86_64-unknown-linux-musl.tar.xz" \
      | tar -xJ -C /usr/local/bin --strip-components=1 typst-x86_64-unknown-linux-musl/typst \
    && curl -fsSL "https://github.com/BurntSushi/xsv/releases/download/${XSV_VERSION}/xsv-${XSV_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
      | tar -xz -C /usr/local/bin xsv \
    && curl -fsSL "https://github.com/zellij-org/zellij/releases/download/v${ZELLIJ_VERSION}/zellij-no-web-x86_64-unknown-linux-musl.tar.gz" \
      | tar -xz -C /usr/local/bin zellij

# RStudio Server en modo de un solo usuario, sin contraseña: el puerto solo
# se reenvía a localhost o, en Codespaces, es privado para su dueño.
RUN ln -s /usr/lib/rstudio-server/bin/rserver /usr/local/bin/rserver \
    && mkdir -p /var/lib/rstudio-server-vscode \
    && printf 'provider=sqlite\ndirectory=/var/lib/rstudio-server-vscode\n' > /var/lib/rstudio-server-vscode/dbconf.conf \
    && chown -R vscode:vscode /var/lib/rstudio-server-vscode \
    && printf '%s\n' server-user=vscode auth-none=1 \
      server-data-dir=/var/lib/rstudio-server-vscode \
      database-config-file=/var/lib/rstudio-server-vscode/dbconf.conf > /etc/rstudio/rserver.conf

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
# con uv en su proyecto o en ~/.local/bin, que va antes en el PATH.
COPY --from=ghcr.io/astral-sh/uv:0.12.20 /uv /uvx /usr/local/bin/
COPY python/ /opt/entorno-python/
ENV PATH=/home/vscode/.local/bin:/opt/venv/bin:$PATH
RUN UV_PROJECT_ENVIRONMENT=/opt/venv UV_PYTHON_DOWNLOADS=never \
      uv sync --frozen --no-cache --python /usr/bin/python3 --project /opt/entorno-python

# earlyoom: cierra el cálculo que agota la memoria antes de que la máquina se congele,
# sin tocar el editor ni el escritorio (ajustes y motivos en earlyoom/earlyoom).
# postStartCommand lo arranca, como a PostgreSQL. La swap comprimida (zram) y los
# sysctl de memoria son del kernel del anfitrión: un contenedor no puede cambiarlos.
COPY earlyoom/earlyoom /etc/default/earlyoom

# PostgreSQL: el usuario vscode es superusuario con su propia base, así `psql` entra sin más.
RUN service postgresql start \
    && su postgres -c "createuser -s vscode && createdb -O vscode vscode" \
    && service postgresql stop

# Newsboat con las revistas y preprints de la frontera ya suscritos: `,p` sobre un
# artículo baja su PDF (leer-pdf) y el resto de enlaces van al navegador (abrir-enlace).
# La lista de la facultad es de root; /usr/local/bin/newsboat le suma las fuentes del
# alumno (mis-fuentes), siempre bajo la etiqueta "Fuentes propias".
COPY newsboat/newsboat newsboat/abrir-enlace newsboat/leer-pdf /usr/local/bin/
COPY newsboat/urls /usr/local/share/somosaguas/newsboat/urls
COPY --chown=vscode:vscode newsboat/config newsboat/mis-fuentes /home/vscode/.config/newsboat/
# Zellij abre con la sesión del alumno: terminal, git (lazygit), Julia, R, SQL,
# lecturas (Newsboat) y sistema (htop).
COPY --chown=vscode:vscode zellij/ /home/vscode/.config/zellij/
COPY --chown=vscode:vscode lazygit/ /home/vscode/.config/lazygit/
COPY --chown=vscode:vscode htop/ /home/vscode/.config/htop/

# Pluto en el puerto 1234, accesible desde el reenvío de Codespaces.
RUN printf '#!/bin/sh\nexec julia -e "using Pluto; Pluto.run(host=\\"0.0.0.0\\", port=1234, launch_browser=false)"\n' \
      > /usr/local/bin/pluto && chmod +x /usr/local/bin/pluto

# Julia y su depósito precompilado, desde la etapa julia.
COPY --from=julia /opt/julia /opt/julia
COPY --from=julia --chown=vscode:vscode /home/vscode/.julia /home/vscode/.julia
RUN ln -s /opt/julia/bin/julia /usr/local/bin/julia
USER vscode

# TinyTeX, de reserva para los PDF con LaTeX desde RStudio (y Quarto), fijado en la
# versión del mes de SNAPSHOT. Vive en ~/.TinyTeX para que tinytex instale solo los
# paquetes de LaTeX que falten sin tocar el sistema.
# ponytail: tlmgr baja esos paquetes del CTAN actual, que solo sirve hasta que salga
# el TeX Live siguiente (abril); luego, apuntar tlmgr al archivo histórico del año.
ARG TINYTEX_VERSION=2026.09
RUN Rscript -e 'tinytex::install_tinytex(version = "'"${TINYTEX_VERSION}"'", bundle = "TinyTeX-1")'

# Chuletas de tldr (tealdeer), ya descargadas, y el manual de la terminal: The Linux
# Command Line, de William Shotts (CC BY-NC-ND 3.0), fijado por su suma SHA-256.
ARG TLCL_VERSION=25.12A
ARG TLCL_SHA256=c6c564db237ea1d5f5758c5a0df5d8c804041ef483585259687d04d9ecf2cd05
RUN tldr --update --quiet \
    && mkdir -p ~/Documents \
    && curl -fsSLo ~/Documents/TLCL-${TLCL_VERSION}.pdf \
      "https://sourceforge.net/projects/linuxcommand/files/TLCL/${TLCL_VERSION%A}/TLCL-${TLCL_VERSION}.pdf/download" \
    && echo "${TLCL_SHA256}  $HOME/Documents/TLCL-${TLCL_VERSION}.pdf" | sha256sum -c --quiet

# Si falta una herramienta, la imagen no se construye. Julia comprueba además que
# la precompilación copiada de la etapa julia sigue siendo válida.
# rserver no admite --version: basta con que exista; ssh la da con -V.
RUN set -e; for h in julia R Rscript python node npm sqlite3 psql git nano quarto typst jq rg bat fd xsv tldr htop lazygit rsync yt-dlp uv uvx zellij curl; do \
      "$h" --version > /dev/null; done \
    && command -v rserver > /dev/null && ssh -V 2> /dev/null && tldr --quiet tar > /dev/null \
    && newsboat -x print-unread > /dev/null \
    && { timeout 2 bash -c '. /etc/default/earlyoom; eval exec earlyoom "$EARLYOOM_ARGS" --dryrun' > /dev/null 2>&1; [ $? -eq 124 ]; } \
    && julia -e 'all(p -> Base.isprecompiled(Base.identify_package(p)), ["CairoMakie", "Agents"]) || error("la caché de Julia no sirvió tras copiarla")' \
    && Rscript -e 'library(somosaguas); library(tidyverse); library(RPostgres); stopifnot(tinytex::is_tinytex())' \
    && python -c 'import polars, duckdb, psycopg'

FROM base AS escritorio
ARG OBSIDIAN_VERSION=1.13.7
ARG AUTO_LINK_TITLE_VERSION=1.5.5
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
      xfce4 xfce4-terminal xfce4-whiskermenu-plugin xfce4-clipman-plugin dbus-x11 fonts-inter fonts-noto-color-emoji \
      gtk2-engines-murrine papirus-icon-theme gsettings-desktop-schemas mousepad ristretto tumbler foliate zathura zathura-pdf-poppler zathura-djvu xclip poppler-utils djvulibre-bin \
      libreoffice-calc libreoffice-gtk3 brave-browser mpv \
    && gdebi -n /tmp/obsidian.deb \
    && rm -rf /tmp/obsidian.deb /var/lib/apt/lists/* \
    && sed -i 's|^Exec=/opt/Obsidian/obsidian|& --no-sandbox|' /usr/share/applications/md.obsidian.Obsidian.desktop

# Bibliografía: JabRef para los .bib y Zotero para recoger referencias del navegador.
# JabRef se queda en la 5.15 estable hasta que salga la 6.0.
ARG JABREF_VERSION=5.15
ARG ZOTERO_VERSION=10.0.3
RUN curl -fsSLo /tmp/jabref.deb "https://github.com/JabRef/jabref/releases/download/v${JABREF_VERSION}/jabref_${JABREF_VERSION}_amd64.deb" \
    && apt-get update && gdebi -n /tmp/jabref.deb \
    && rm -rf /tmp/jabref.deb /var/lib/apt/lists/* \
    && curl -fsSL "https://download.zotero.org/client/release/${ZOTERO_VERSION}/Zotero-${ZOTERO_VERSION}_linux-x86_64.tar.xz" | tar -xJ -C /opt \
    && mv /opt/Zotero_linux-x86_64 /opt/zotero && /opt/zotero/set_launcher_icon \
    && sed 's|^Exec=.*|Exec=/opt/zotero/zotero -url %U|' /opt/zotero/zotero.desktop > /usr/share/applications/zotero.desktop \
    && ln -s /opt/zotero/zotero /usr/local/bin/zotero
# Brave instala solo el Zotero Connector: el botón que guarda en Zotero lo que se lee.
COPY escritorio/brave-politicas.json /etc/brave/policies/managed/zotero.json

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
RUN printf '%s\n' "[org.gnome.desktop.interface]" "color-scheme='prefer-dark'" \
      "font-name='Inter 10'" "document-font-name='EB Garamond 12'" "monospace-font-name='Fira Code 10'" \
      > /usr/share/glib-2.0/schemas/90_somosaguas.gschema.override \
    && glib-compile-schemas /usr/share/glib-2.0/schemas
# WebKitGTK (el visor de Foliate) no puede abrir su sandbox dentro del contenedor
# ni usar la GPU, que el VNC no tiene.
ENV WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS=1 WEBKIT_DISABLE_DMABUF_RENDERER=1
COPY escritorio/xfce/ /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/
# Thunar: Super+Intro abre XFCE Terminal en la carpeta actual.
COPY escritorio/thunar/ /etc/xdg/Thunar/

# Zathura con los colores de la web (Ctrl+R: modo noche) y predeterminado para PDF;
# C e I copian la página en pantalla como texto o como imagen (copiar-pagina).
COPY escritorio/zathurarc /etc/zathurarc
COPY escritorio/copiar-pagina /usr/local/bin/
COPY escritorio/mimeapps.list /etc/xdg/mimeapps.list

# La bóveda de Obsidian ~/Notas, ya registrada: imágenes en imagenes/,
# Auto Link Title activo y el tema nocturno de Somosaguas.
COPY --chown=vscode:vscode escritorio/Notas /home/vscode/Notas
COPY --chown=vscode:vscode escritorio/obsidian.json /home/vscode/.config/obsidian/obsidian.json
USER vscode
RUN mkdir -p ~/Notas/imagenes ~/Notas/.obsidian/plugins/obsidian-auto-link-title ~/.vnc \
    && for f in main.js manifest.json styles.css; do \
      curl -fsSLo ~/Notas/.obsidian/plugins/obsidian-auto-link-title/$f \
        "https://github.com/zolrath/obsidian-auto-link-title/releases/download/${AUTO_LINK_TITLE_VERSION}/$f"; done \
    && printf '#!/bin/sh\nexec startxfce4\n' > ~/.vnc/xstartup && chmod +x ~/.vnc/xstartup \
    && brave-browser --version && mpv --version > /dev/null && zathura --version > /dev/null && test -f /usr/lib/x86_64-linux-gnu/zathura/libdjvu.so \
    && test -x /opt/Obsidian/obsidian && command -v copiar-pagina xclip pdftotext pdftoppm djvutxt ddjvu mousepad ristretto xfce4-clipman startxfce4 foliate localc \
    && test -x /opt/jabref/bin/JabRef && ! LD_LIBRARY_PATH=/opt/zotero ldd /opt/zotero/zotero-bin /opt/zotero/libxul.so | grep "not found" \
    && test -d /usr/share/themes/Matcha-dark-aliz \
    && fc-match serif | grep -q "EB Garamond" && fc-match sans-serif | grep -q Inter && fc-match monospace | grep -q "Fira Code"
