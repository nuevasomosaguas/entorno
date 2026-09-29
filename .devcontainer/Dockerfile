# Imagen del entorno de la Nueva Somosaguas: Debian 13 (trixie) estable.
# Cada versión se fija aquí; la imagen publicada lleva etiqueta de calendario (2026.2).
# Dos etapas: `base` es el devcontainer local, sin aplicaciones gráficas;
# `escritorio` le añade Brave y mpv para Codespaces.
# ponytail: solo amd64 (RStudio Server y xsv no publican binarios arm64 para Linux);
# en Mac con Apple Silicon, Docker la ejecuta con Rosetta.
FROM mcr.microsoft.com/devcontainers/base:trixie AS base

ARG JULIA_VERSION=1.13.1
ARG QUARTO_VERSION=1.10.18
ARG TYPST_VERSION=0.15.1
ARG RSTUDIO_VERSION=2026.09.0-174
ARG XSV_VERSION=0.13.0
# Temas gráficos de Somosaguas, fijados por commit.
ARG SOMOSAGUAS_GGPLOT2_REV=2e92406c850bb03e9cfeaebbeac33041f8d6ee01
ARG SOMOSAGUAS_MAKIE_REV=9138e2a2d6c3c1fb265037a46123e417d500b513
# Instantánea común de CRAN (Posit Package Manager) y PyPI (uv --exclude-newer):
# reconstruir la imagen en 2036 instala los mismos paquetes de R y Python.
ARG SNAPSHOT=2026-09-01

ENV DEBIAN_FRONTEND=noninteractive

# Terminal, SQL, R, Python y tipografías del estándar gráfico. Node y npm los
# pide la extensión SQLTools para instalar su driver de SQLite.
RUN apt-get update && apt-get install -y --no-install-recommends \
      jq ripgrep bat fd-find curl wget parallel less nano git ffmpeg \
      sqlite3 postgresql \
      r-base r-base-dev libcurl4-openssl-dev libssl-dev libxml2-dev libpq-dev \
      libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype-dev \
      libpng-dev libtiff-dev libjpeg-dev libwebp-dev \
      python3 python3-venv nodejs npm \
      fonts-ebgaramond fonts-firacode gdebi-core \
    && ln -s /usr/bin/batcat /usr/local/bin/bat \
    && ln -s /usr/bin/fdfind /usr/local/bin/fd \
    && rm -rf /var/lib/apt/lists/*

# Binarios sueltos.
RUN curl -fsSL "https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION%.*}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz" \
      | tar -xz -C /opt && ln -s "/opt/julia-${JULIA_VERSION}/bin/julia" /usr/local/bin/julia \
    && curl -fsSLo /tmp/quarto.deb "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" \
    && curl -fsSLo /tmp/rstudio.deb "https://download2.rstudio.org/server/jammy/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb" \
    && apt-get update && gdebi -n /tmp/quarto.deb && gdebi -n /tmp/rstudio.deb \
    && rm -rf /tmp/*.deb /var/lib/apt/lists/* \
    && curl -fsSL "https://github.com/typst/typst/releases/download/v${TYPST_VERSION}/typst-x86_64-unknown-linux-musl.tar.xz" \
      | tar -xJ -C /usr/local/bin --strip-components=1 typst-x86_64-unknown-linux-musl/typst \
    && curl -fsSL "https://github.com/BurntSushi/xsv/releases/download/${XSV_VERSION}/xsv-${XSV_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
      | tar -xz -C /usr/local/bin xsv

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

# Python: uv y un entorno en /opt/venv, congelado en la misma fecha y del
# usuario vscode. yt-dlp va aquí y no por apt: caduca en cuanto YouTube cambia
# su web, y así cada alumno lo pone al día con `pip install -U yt-dlp`.
COPY --from=ghcr.io/astral-sh/uv:0.12.20 /uv /usr/local/bin/uv
ENV VIRTUAL_ENV=/opt/venv PATH=/opt/venv/bin:$PATH
RUN uv venv --seed /opt/venv \
    && uv pip install --exclude-newer "${SNAPSHOT}" \
      ipykernel pandas polars pyarrow duckdb "psycopg[binary]" ruff "yt-dlp[default]" \
    && chown -R vscode:vscode /opt/venv

# PostgreSQL: el usuario vscode es superusuario con su propia base, así `psql` entra sin más.
RUN service postgresql start \
    && su postgres -c "createuser -s vscode && createdb -O vscode vscode" \
    && service postgresql stop

# Pluto en el puerto 1234, accesible desde el reenvío de Codespaces.
RUN printf '#!/bin/sh\nexec julia -e "using Pluto; Pluto.run(host=\\"0.0.0.0\\", port=1234, launch_browser=false)"\n' \
      > /usr/local/bin/pluto && chmod +x /usr/local/bin/pluto

# Julia: paquetes del entorno global del usuario, ya precompilados. Cada
# asignatura trae su Manifest.toml; este entorno solo ahorra la primera espera.
USER vscode
RUN julia -e 'using Pkg; \
      Pkg.add(["Pluto", "CSV", "DataFrames", "CairoMakie"]); \
      Pkg.add(url = "https://github.com/nuevasomosaguas/somosaguas-makie", rev = "'"${SOMOSAGUAS_MAKIE_REV}"'"); \
      Pkg.precompile()'

# Si falta una herramienta, la imagen no se construye.
# rserver no admite --version: basta con que exista.
RUN set -e; for h in julia R Rscript python node npm sqlite3 psql git nano quarto typst jq rg bat fd xsv yt-dlp curl; do \
      "$h" --version > /dev/null; done \
    && command -v rserver > /dev/null \
    && Rscript -e 'library(somosaguas); library(tidyverse); library(RPostgres)' \
    && python -c 'import polars, duckdb, psycopg'

FROM base AS escritorio
ARG OBSIDIAN_VERSION=1.13.7
ARG AUTO_LINK_TITLE_VERSION=1.5.5
USER root
# XFCE con Mousepad, Zathura, Obsidian, Brave y mpv. El VNC y el noVNC los pone
# la feature desktop-lite; xstartup hace que arranque XFCE en lugar de Fluxbox.
# Obsidian (Electron) no encuentra el sandbox de usuario dentro de un contenedor.
RUN curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
      https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
      > /etc/apt/sources.list.d/brave-browser-release.list \
    && curl -fsSLo /tmp/obsidian.deb "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/obsidian_${OBSIDIAN_VERSION}_amd64.deb" \
    && apt-get update && apt-get install -y --no-install-recommends \
      xfce4 xfce4-terminal dbus-x11 fonts-inter mousepad zathura zathura-pdf-poppler brave-browser mpv \
    && gdebi -n /tmp/obsidian.deb \
    && rm -rf /tmp/obsidian.deb /var/lib/apt/lists/* \
    && sed -i 's|^Exec=/opt/Obsidian/obsidian|& --no-sandbox|' /usr/share/applications/obsidian.desktop

# Zathura con los colores de la web (Ctrl+R: modo noche) y predeterminado para PDF.
COPY escritorio/zathurarc /etc/zathurarc
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
    && brave-browser --version && mpv --version > /dev/null && zathura --version > /dev/null \
    && test -x /opt/Obsidian/obsidian && command -v mousepad startxfce4
