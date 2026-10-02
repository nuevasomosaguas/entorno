#!/usr/bin/env bash
# Construye la ISO en vivo de la Nueva Somosaguas: la imagen del sistema (Dockerfile)
# se vuelca a squashfs y arranca con GRUB, en BIOS y en UEFI. Todo corre en Docker;
# en el anfitrión solo queda la ISO, en distribucion/salida/.
# Uso: distribucion/construir.sh [VERSIÓN] [IMAGEN_DEL_ESCRITORIO]
set -euo pipefail
cd "$(dirname "$0")"
version=${1:-2026.2}
imagen=${2:-ghcr.io/nuevasomosaguas/entorno-escritorio:$version}
iso=salida/iso
rm -rf "$iso" salida/boot

# El sistema no se guarda como imagen: cada --output saca de la construcción lo que hace
# falta, sin exportar sus capas (varios GB), y las tres comparten la caché.
construir() { docker build --platform=linux/amd64 --build-arg IMAGEN="$imagen" --build-arg VERSION="$version" --build-arg REVISION="$(git rev-parse HEAD)" --build-context repo=.. "$@" .; }

# El repositorio del instalador (dists/ y pool/), en la raíz de la ISO, donde lo buscan
# las ayudas de Calamares de Debian.
construir --target repositorio --output "type=local,dest=$iso"
mkdir -p "$iso/live" "$iso/boot/grub"

# El núcleo y el initrd (con live-boot dentro), fuera del squashfs para que GRUB los cargue.
construir --target arranque --output type=local,dest=salida/boot
cp salida/boot/vmlinuz-* "$iso/live/vmlinuz"
cp salida/boot/initrd.img-* "$iso/live/initrd.img"
rm -rf salida/boot
sed "s/@VERSION@/$version/" grub.cfg > "$iso/boot/grub/grub.cfg"

# Las herramientas de la ISO, en un Debian aparte y con el usuario del anfitrión.
docker build -q -t nueva-somosaguas/constructor - > /dev/null <<'DOCKERFILE'
FROM debian:trixie
RUN apt-get update && apt-get install -y --no-install-recommends \
      squashfs-tools grub-pc-bin grub-efi-amd64-bin grub-common mtools xorriso python3 \
    && rm -rf /var/lib/apt/lists/*
DOCKERFILE
herramienta() { docker run --rm -i --user "$(id -u):$(id -g)" -v "$PWD/salida:/salida" -v "$PWD/raiz:/raiz:ro" -v "$PWD:/raiz-construccion:ro" nueva-somosaguas/constructor "$@"; }

# El árbol del sistema, como tar por la tubería: volcado.py pone lo que Docker tapa
# (hosts, hostname) y sqfstar lo lee tal cual, con sus dueños y permisos, sin ser root.
construir --target sistema --output type=tar,dest=- | herramienta python3 /raiz-construccion/volcado.py /raiz \
  | herramienta sqfstar -comp zstd -quiet /salida/iso/live/filesystem.squashfs
# ISO híbrida (USB y DVD, BIOS y UEFI), con el nivel 3 de ISO 9660, que admite archivos
# de más de 4 GiB (xorriso-nivel3); tras «--», el nombre del volumen.
# Se borra antes la ISO anterior: si una VM la usó, libvirt se quedó con ella.
rm -f "salida/nueva-somosaguas-$version.iso"
herramienta grub-mkrescue --xorriso=/raiz-construccion/xorriso-nivel3 -o "/salida/nueva-somosaguas-$version.iso" /salida/iso -- -volid NUEVA_SOMOSAGUAS
# La suma, con el nombre suelto, para comprobarla donde se descargue: sha256sum -c.
(cd salida && sha256sum "nueva-somosaguas-$version.iso" > "nueva-somosaguas-$version.iso.sha256")

# Solo quedan la ISO y la caché de construcción: fuera la imagen de las herramientas y
# las que quedan sin etiqueta. La del escritorio, que es la de entrada, se conserva.
docker rmi nueva-somosaguas/constructor > /dev/null
docker image prune -f > /dev/null
ls -lh "salida/nueva-somosaguas-$version.iso"
