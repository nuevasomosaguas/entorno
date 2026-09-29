# La distribución de la Nueva Somosaguas: la imagen del escritorio, tal cual, más lo
# que un sistema operativo necesita y un contenedor no tiene: núcleo, arranque en
# vivo, systemd, gestor de sesiones, servidor gráfico, red, sonido y servicios. El
# software y sus ajustes no se instalan aquí otra vez: la misma receta, sin deriva.
ARG IMAGEN=ghcr.io/nuevasomosaguas/entorno-escritorio:2026.2.1
FROM ${IMAGEN}
USER root
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      linux-image-amd64 firmware-linux-free live-boot systemd-sysv \
      dbus-user-session libpam-systemd polkitd \
      xserver-xorg-core xserver-xorg-input-libinput xauth \
      lightdm lightdm-gtk-greeter light-locker xfce4-power-manager \
      network-manager network-manager-gnome pipewire-audio \
      udisks2 gvfs-backends thunar-volman exfatprogs dosfstools ntfs-3g gnome-disk-utility \
      zram-tools power-profiles-daemon spice-vdagent unattended-upgrades \
      docker.io docker-buildx docker-compose \
    && rm -rf /var/lib/apt/lists/*

# VS Code de escritorio, fijado por versión, con las mismas extensiones y ajustes que
# Codespaces: los lee de .devcontainer/devcontainer.json (vscode.py). En el escritorio
# de Codespaces no hace falta: allí VS Code es el propio navegador.
ARG VSCODE_VERSION=1.139.1-1790309529
COPY --from=repo .devcontainer/devcontainer.json /tmp/devcontainer.json
COPY vscode.py /tmp/vscode.py
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
      > /etc/apt/sources.list.d/vscode.list \
    && apt-get update && apt-get install -y --no-install-recommends "code=${VSCODE_VERSION}" \
    && rm -rf /var/lib/apt/lists/* \
    && extensiones=$(python3 /tmp/vscode.py /tmp/devcontainer.json /home/vscode/.config/Code/User/settings.json) \
    && chown -R vscode:vscode /home/vscode/.config/Code \
    && for e in $extensiones MS-CEINTL.vscode-language-pack-es; do runuser -l vscode -c "code --install-extension $e"; done \
    && printf '{ "locale": "es" }\n' > /home/vscode/.vscode/argv.json && chown vscode:vscode /home/vscode/.vscode/argv.json \
    && rm /tmp/devcontainer.json /tmp/vscode.py \
    && describir-menu

# raiz/ reproduce el árbol del sistema. Sus /etc/hosts y /etc/hostname no llegan por
# aquí: Docker los tapa con archivos vacíos al volcar el contenedor, y construir.sh
# los mete directamente en el squashfs.
COPY raiz/ /
# La verificación del entorno, desde la raíz del repositorio (construir.sh la pasa
# como contexto «repo»): la ISO no trae el repositorio, pero sí la prueba.
COPY --from=repo verificar_entorno.sh /usr/local/bin/verificar_entorno.sh

# Servicios que en el contenedor arranca postStartCommand. RStudio, con su propia
# unidad (como vscode y solo en localhost), en lugar de la del paquete. Con la ruta
# completa: la imagen base pone en /usr/local/bin un systemctl de mentira que, sin
# systemd en marcha, no hace nada. En el sistema arrancado, ese mismo guion cede al
# de verdad. La contraseña de la sesión en vivo desbloquea la pantalla tras suspender.
# Docker, para abrir en local los devcontainers de las asignaturas: vscode entra en el
# grupo docker, que equivale a ser root en esta máquina (es la suya). Y la hora de Madrid.
RUN /usr/bin/systemctl enable postgresql earlyoom rstudio-vscode zramswap NetworkManager lightdm docker \
    && usermod -aG docker vscode \
    && ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime && echo Europe/Madrid > /etc/timezone \
    && /usr/bin/systemctl mask rstudio-server.service \
    && echo 'vscode:somosaguas' | chpasswd \
    && rm -f /.dockerenv /var/lib/dbus/machine-id && : > /etc/machine-id \
    && update-initramfs -u
