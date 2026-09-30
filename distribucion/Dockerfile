# La distribución de la Nueva Somosaguas: la imagen del escritorio, tal cual, más lo
# que un sistema operativo necesita y un contenedor no tiene: núcleo, arranque en
# vivo, systemd, gestor de sesiones, servidor gráfico, red, sonido y servicios. El
# software y sus ajustes no se instalan aquí otra vez: la misma receta, sin deriva.
ARG IMAGEN=ghcr.io/nuevasomosaguas/entorno-escritorio:2026.2.2
FROM ${IMAGEN} AS sistema
USER root
ENV DEBIAN_FRONTEND=noninteractive

# El firmware que no es libre pero hace falta en portátiles reales (Wi-Fi de Intel y
# Realtek, sonido de los Intel recientes, gráficas de AMD y demás) y el microcódigo de
# los procesadores, que el initrd carga al arrancar; como en las ISO de Debian:
# vive en la sección non-free-firmware, que se activa en las fuentes de apt.
# wpasupplicant, explícito: NetworkManager solo lo recomienda y, sin él, el Wi-Fi se
# detecta pero queda «unavailable». lspci, lsusb y rfkill, para diagnosticar el hardware.
# Transmission, el cliente de BitTorrent (ISO, conjuntos de datos, cursos): como
# LocalSend, en la distribución, porque las descargas van al disco del alumno.
# KeePassXC, el gestor de contraseñas (la versión full: la de la integración con el
# navegador): aquí y no en los contenedores, que no son sitio para una bóveda.
# btrfs-progs y Snapper: el disco instalado es btrfs, con una instantánea al día de / y
# de /home, y otra antes y después de cada apt (somosaguas-instantaneas).
# python3-gi y x11-utils (xprop), para somosaguas-sin-bloqueo: la pantalla no se bloquea
# mientras suena un vídeo o una ventana está a pantalla completa.
RUN sed -i 's/^Components: main$/Components: main non-free-firmware/' /etc/apt/sources.list.d/debian.sources \
    && apt-get update && apt-get install -y --no-install-recommends \
      linux-image-amd64 firmware-linux-free live-boot systemd-sysv \
      firmware-misc-nonfree firmware-iwlwifi firmware-realtek firmware-sof-signed \
      firmware-amd-graphics amd64-microcode intel-microcode \
      dbus-user-session libpam-systemd polkitd \
      xserver-xorg-core xserver-xorg-input-libinput xauth \
      lightdm lightdm-gtk-greeter light-locker xfce4-power-manager \
      network-manager wpasupplicant network-manager-gnome pipewire-audio \
      udisks2 gvfs-backends thunar-volman exfatprogs dosfstools ntfs-3g gnome-disk-utility \
      zram-tools power-profiles-daemon spice-vdagent unattended-upgrades pciutils usbutils rfkill transmission-gtk keepassxc-full \
      btrfs-progs snapper python3-gi x11-utils \
      docker.io docker-cli docker-buildx docker-compose calamares calamares-settings-debian mate-polkit \
    && rm -rf /var/lib/apt/lists/*

# LocalSend, para pasar archivos por la red local a otros ordenadores y al móvil, sin
# cuentas ni nube. En la distribución y no en Codespaces, que no tiene red local.
ARG LOCALSEND_VERSION=1.18.2
ARG LOCALSEND_SHA256=cc42a4f3eacdcb25ec31f0016b1272acb003145ab30484db8965450e20c72cd2
RUN curl -fsSLo /tmp/localsend.deb "https://github.com/localsend/localsend/releases/download/v${LOCALSEND_VERSION}/LocalSend-${LOCALSEND_VERSION}-linux-x86-64.deb" \
    && echo "${LOCALSEND_SHA256}  /tmp/localsend.deb" | sha256sum -c - \
    && apt-get update && apt-get install -y --no-install-recommends /tmp/localsend.deb \
    && rm -rf /tmp/localsend.deb /var/lib/apt/lists/*

# VS Code de escritorio, fijado por versión, con las mismas extensiones y ajustes que
# Codespaces: los lee de .devcontainer/devcontainer.json (vscode.py). En el escritorio
# de Codespaces no hace falta: allí VS Code es el propio navegador. Se instala para
# alumno y se copia a la plantilla, con @HOME@ en las rutas de sus extensiones y de la
# biblioteca propia (~/Biblioteca/zotero.bib).
ARG VSCODE_VERSION=1.139.1-1790309529
COPY --from=repo .devcontainer/devcontainer.json /tmp/devcontainer.json
COPY vscode.py /tmp/vscode.py
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
      > /etc/apt/sources.list.d/vscode.list \
    && apt-get update && apt-get install -y --no-install-recommends "code=${VSCODE_VERSION}" \
    && rm -rf /var/lib/apt/lists/* \
    && extensiones=$(python3 /tmp/vscode.py /tmp/devcontainer.json /home/alumno/.config/Code/User/settings.json) \
    && chown -R alumno:alumno /home/alumno/.config/Code \
    && for e in $extensiones MS-CEINTL.vscode-language-pack-es; do runuser -l alumno -c "code --install-extension $e"; done \
    && s=/etc/skel/.vscode-server/extensions && e=$(jq -r '.[0].relativeLocation' $s/extensions.json) \
    && cp -r "$s/$e" /home/alumno/.vscode/extensions/ && chown -R alumno:alumno "/home/alumno/.vscode/extensions/$e" \
    && jq --slurpfile n $s/extensions.json '. + $n[0]' /home/alumno/.vscode/extensions/extensions.json > /tmp/extensiones.json \
    && mv /tmp/extensiones.json /home/alumno/.vscode/extensions/extensions.json && chown alumno:alumno /home/alumno/.vscode/extensions/extensions.json \
    && printf '{ "locale": "es" }\n' > /home/alumno/.vscode/argv.json && chown alumno:alumno /home/alumno/.vscode/argv.json \
    && cp -a /home/alumno/.vscode /etc/skel/ && mkdir -p /etc/skel/.config && cp -a /home/alumno/.config/Code /etc/skel/.config/ \
    && sed -i 's|/home/alumno|@HOME@|g' /etc/skel/.vscode/extensions/extensions.json /etc/skel/.config/Code/User/settings.json \
    && chown -R root:root /etc/skel/.vscode /etc/skel/.config/Code \
    && rm /tmp/devcontainer.json /tmp/vscode.py \
    && describir-menu

# KeePassXC-Browser, impuesta en Firefox y en Brave junto a las demás extensiones. La
# plantilla de cada cuenta trae la integración con el navegador activada y los dos
# manifiestos de mensajería nativa que la conectan con keepassxc-proxy.
RUN f=/etc/firefox/policies/policies.json b=/etc/brave/policies/managed/zotero.json \
    && jq '.policies.ExtensionSettings["keepassxc-browser@keepassxc.org"] = {installation_mode: "force_installed", install_url: "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi", default_area: "navbar"}' "$f" > "$f.nuevo" && mv "$f.nuevo" "$f" \
    && jq '.ExtensionInstallForcelist += ["oboonakemofpalcgghocfoadofidjkkk;https://clients2.google.com/service/update2/crx"]' "$b" > "$b.nuevo" && mv "$b.nuevo" "$b"

# raiz/ reproduce el árbol del sistema. Sus /etc/hosts y /etc/hostname no llegan por
# aquí: Docker los tapa con archivos vacíos al volcar el contenedor, y construir.sh
# los mete directamente en el squashfs.
COPY raiz/ /
# La verificación del entorno, desde la raíz del repositorio (construir.sh la pasa
# como contexto «repo»): la ISO no trae el repositorio, pero sí la prueba.
COPY --from=repo verificar_entorno.sh /usr/local/bin/verificar_entorno.sh

# Servicios que en el contenedor arranca postStartCommand: PostgreSQL (con la base de
# cada cuenta, somosaguas-cuentas), earlyoom, zram, la red, LightDM y Docker. RStudio,
# como servicio de cada cuenta (systemctl --user), en lugar del del paquete. Con la ruta
# completa: la imagen base pone en /usr/local/bin un systemctl de mentira que, sin
# systemd en marcha, no hace nada; en el sistema arrancado, ese guion cede al de verdad.
# Docker, para abrir en local los devcontainers de las asignaturas (docker.io es solo el
# servicio; la orden docker está en docker-cli). alumno entra en los grupos docker (que
# equivale a ser root en esta máquina) y sudo (para abrir el instalador: pide su
# contraseña, somosaguas, que también desbloquea la pantalla tras suspender). La hora de
# Madrid, y el idioma también en /etc/locale.conf: systemd, y con él LightDM y la sesión,
# solo lee ese archivo.
# El instalador, con el nombre y los colores de la Nueva Somosaguas sobre las imágenes de
# Debian, y RStudio de cada cuenta con su base de datos en su carpeta (plantilla). El
# fragmento de Typst de la extensión de VS Code importa la versión instalada de la plantilla.
RUN /usr/bin/systemctl enable postgresql somosaguas-cuentas somosaguas-vivo earlyoom zramswap NetworkManager lightdm docker \
      snapper-timeline.timer snapper-cleanup.timer \
    && /usr/bin/systemctl --global enable rstudio-somosaguas.service \
    && /usr/bin/systemctl mask rstudio-server.service \
    && usermod -aG docker,sudo alumno \
    && ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime && echo Europe/Madrid > /etc/timezone \
    && ln -sf default/locale /etc/locale.conf \
    && cp -n /etc/calamares/branding/debian/*.png /etc/calamares/branding/debian/show.qml /etc/calamares/branding/somosaguas/ \
    && sed -i -e '/^Name\[/d' -e '/^Comment\[/d' -e 's/^Name=.*/Name=Instalar la Nueva Somosaguas/' \
      -e 's/^Comment=.*/Comment=Instala en el disco el sistema de esta sesión, con cifrado si se marca/' \
      -e 's/^Icon=.*/Icon=nueva-somosaguas/' \
      /usr/share/applications/calamares-install-debian.desktop \
    && mkdir -p /etc/skel/.config/rstudio-server \
    && printf 'provider=sqlite\ndirectory=@HOME@/.local/share/rstudio-server\n' > /etc/skel/.config/rstudio-server/dbconf.conf \
    && v=$(ls /etc/skel/.local/share/typst/packages/local/somosaguas) \
    && grep -qF "@local/somosaguas:$v" /usr/local/share/somosaguas/vscode/snippets/typst.json \
    && /usr/bin/python3 -c 'import ast, sys; ast.parse(open(sys.argv[1]).read()); from gi.repository import Gio, GLib' /usr/local/bin/somosaguas-sin-bloqueo \
    && command -v xprop pw-dump > /dev/null && test -x /usr/local/bin/somosaguas-sin-bloqueo \
    && somosaguas-cuenta alumno \
    && echo 'alumno:somosaguas' | chpasswd \
    && rm -f /.dockerenv /var/lib/dbus/machine-id && : > /etc/machine-id \
    && update-initramfs -u

# El repositorio de la ISO (dists/ y pool/), como en las de Debian: el instalador toma
# de ahí, sin red, lo que depende de cada máquina. GRUB para UEFI o para BIOS, con lo
# que recomiendan (shim firmado para el arranque seguro), y cryptsetup-initramfs si el
# disco va cifrado. Solo lo que falte en el sistema: se descarga contra él.
FROM sistema AS pool
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils \
    && for p in grub-efi grub-pc cryptsetup-initramfs; do apt-get install -y --download-only "$p"; done \
    && mkdir -p /repo/pool/main /repo/dists/trixie/main/binary-amd64 \
    && mv /var/cache/apt/archives/*.deb /repo/pool/main/ \
    && cd /repo && apt-ftparchive packages pool > dists/trixie/main/binary-amd64/Packages \
    && gzip -k dists/trixie/main/binary-amd64/Packages \
    && apt-ftparchive -o APT::FTPArchive::Release::Suite=trixie -o APT::FTPArchive::Release::Codename=trixie \
      -o APT::FTPArchive::Release::Components=main -o APT::FTPArchive::Release::Architectures=amd64 \
      release dists/trixie > dists/trixie/Release
