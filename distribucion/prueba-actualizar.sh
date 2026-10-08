#!/usr/bin/env bash
# La prueba de somosaguas-actualizar, en Docker y en pequeño: un Debian «instalado» con
# una cuenta, ana, y otro «nuevo» en /nuevo con lo que trae una versión; se actualiza con
# --desde y se comprueba cada regla: paquetes de apt y rehechos con dpkg-repack, archivos
# fuera de los paquetes, /opt en espejo, lo propio de la máquina intacto y los ajustes de
# la cuenta, renovados solo si no los había tocado, y sus carpetas nuevas (Aprender…),
# sin tocar las que ya tenía con ese nombre.
# Uso: distribucion/prueba-actualizar.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# El contexto, solo los dos guiones: el repositorio entero arrastraría la ISO de salida/.
ctx=$(mktemp -d) && trap 'rm -rf "$ctx"' EXIT
cp .devcontainer/somosaguas-cuenta distribucion/raiz/usr/local/sbin/somosaguas-actualizar "$ctx/"
docker build -q -t nueva-somosaguas/prueba-actualizar -f - "$ctx" <<'DOCKERFILE' > /dev/null
FROM debian:trixie AS nuevo
RUN apt-get update && apt-get install -y --no-install-recommends hello && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /tmp/p/DEBIAN /tmp/p/usr/share/somosaguas-prueba \
    && echo hola > /tmp/p/usr/share/somosaguas-prueba/hola \
    && printf 'Package: somosaguas-prueba\nVersion: 1.0\nArchitecture: all\nMaintainer: x <x@x>\nDescription: prueba\n' > /tmp/p/DEBIAN/control \
    && dpkg-deb -b /tmp/p /tmp/p.deb > /dev/null && dpkg -i /tmp/p.deb && rm -rf /tmp/p /tmp/p.deb \
    && mkdir -p /opt/herramienta/v2 /etc/skel/.config/gtk-3.0 /etc/lightdm/lightdm.conf.d \
    && echo nuevo > /usr/local/bin/nuevo-guion \
    && echo nuevo > /etc/skel/.config/a && echo "nuevo b" > /etc/skel/.config/b \
    && echo nuevo > /etc/skel/.config/c && echo "ruta @HOME@ nueva" > /etc/skel/.config/gtk-3.0/bookmarks \
    && mkdir -p /etc/skel/Aprender /etc/skel/Cursos && echo plantilla > /etc/skel/Aprender/LEEME \
    && printf '[Seat:*]\nautologin-user=alumno\n' > /etc/lightdm/lightdm.conf.d/50-somosaguas.conf \
    && echo imagen > /etc/timezone && echo 2026.2.9 > /etc/somosaguas-version \
    && mkdir -p /etc/ssl/private /etc/postgresql/17/main \
    && echo imagen > /etc/ssl/private/ssl-cert-snakeoil.key && echo imagen > /etc/postgresql/17/main/pg_hba.conf

FROM debian:trixie
RUN apt-get update && apt-get install -y --no-install-recommends rsync fontconfig && rm -rf /var/lib/apt/lists/* \
    && for c in update-initramfs update-grub; do printf '#!/bin/sh\n' > /usr/local/bin/$c; chmod +x /usr/local/bin/$c; done \
    && printf '#!/bin/sh\n' > /usr/bin/systemctl && chmod +x /usr/bin/systemctl \
    && mkdir -p /opt/herramienta/v1 /etc/skel/.config/gtk-3.0 /etc/lightdm/lightdm.conf.d \
    && echo viejo > /etc/skel/.config/a && echo "viejo b" > /etc/skel/.config/b \
    && echo "ruta @HOME@ vieja" > /etc/skel/.config/gtk-3.0/bookmarks \
    && printf '[Seat:*]\nautologin-user=alumno\n' > /etc/lightdm/lightdm.conf.d/50-somosaguas.conf \
    && echo maquina > /etc/timezone && echo 2026.2.1 > /etc/somosaguas-version \
    && mkdir -p /etc/ssl/private /etc/postgresql/17/main \
    && echo maquina > /etc/ssl/private/ssl-cert-snakeoil.key && echo maquina > /etc/postgresql/17/main/pg_hba.conf \
    && useradd -m -u 1000 ana && mkdir -p /home/ana/.config/gtk-3.0 \
    && echo viejo > /home/ana/.config/a && echo "mío" > /home/ana/.config/b \
    && echo "ruta /home/ana vieja" > /home/ana/.config/gtk-3.0/bookmarks \
    && mkdir /home/ana/Aprender && echo mío > /home/ana/Aprender/LEEME && echo mío > /home/ana/Aprender/calculo.jl \
    && chown -R ana:ana /home/ana
COPY --from=nuevo / /nuevo
COPY somosaguas-cuenta /usr/local/bin/
COPY somosaguas-actualizar /usr/local/sbin/
DOCKERFILE

docker run --rm nueva-somosaguas/prueba-actualizar sh -euc '
  somosaguas-actualizar --desde /nuevo > /tmp/salida 2>&1 || { cat /tmp/salida; exit 1; }
  ok() { if eval "$2"; then echo "bien: $1"; else echo "MAL: $1"; fallos=1; fi; }
  fallos=0
  ok "paquete de apt que faltaba" "dpkg -s hello > /dev/null 2>&1"
  ok "paquete sin repositorio, rehecho" "dpkg -s somosaguas-prueba | grep -qx \"Version: 1.0\" && [ -f /usr/share/somosaguas-prueba/hola ]"
  ok "archivo fuera de los paquetes" "[ -f /usr/local/bin/nuevo-guion ]"
  ok "/opt en espejo" "[ -d /opt/herramienta/v2 ] && [ ! -e /opt/herramienta/v1 ]"
  ok "lo de la máquina, intacto" "[ \"\$(cat /etc/timezone)\" = maquina ] && getent passwd ana > /dev/null"
  ok "la clave y PostgreSQL, de la máquina" "[ \"\$(cat /etc/ssl/private/ssl-cert-snakeoil.key)\" = maquina ] && [ \"\$(cat /etc/postgresql/17/main/pg_hba.conf)\" = maquina ]"
  ok "sin entrada automática" "! grep -q autologin /etc/lightdm/lightdm.conf.d/50-somosaguas.conf"
  ok "versión apuntada" "[ \"\$(cat /etc/somosaguas-version)\" = 2026.2.9 ]"
  ok "ajuste sin tocar, renovado" "[ \"\$(cat /home/ana/.config/a)\" = nuevo ]"
  ok "ajuste tocado, se queda" "[ \"\$(cat /home/ana/.config/b)\" = mío ]"
  ok "ajuste tocado, la versión nueva al lado" "[ \"\$(cat /home/ana/.config/b.nueva)\" = \"nuevo b\" ] && [ \"\$(stat -c %U /home/ana/.config/b.nueva)\" = ana ] && grep -q /home/ana/.config/b.nueva /tmp/salida"
  ok "ajuste nuevo, de ana" "[ \"\$(stat -c %U /home/ana/.config/c)\" = ana ]"
  ok "ajuste con @HOME@, renovado con su ruta" "[ \"\$(cat /home/ana/.config/gtk-3.0/bookmarks)\" = \"ruta /home/ana nueva\" ]"
  ok "carpeta nueva de la plantilla, de ana" "[ -d /home/ana/Cursos ] && [ \"\$(stat -c %U /home/ana/Cursos)\" = ana ]"
  ok "carpeta que ana ya tenía, intacta" "[ \"\$(cat /home/ana/Aprender/LEEME)\" = mío ] && [ \"\$(cat /home/ana/Aprender/calculo.jl)\" = mío ]"
  [ "$fallos" = 0 ] || { echo; cat /tmp/salida; exit 1; }
'
