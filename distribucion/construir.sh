#!/usr/bin/env bash
# Construye la ISO en vivo de la Nueva Somosaguas: la imagen del sistema (Dockerfile)
# se vuelca a squashfs y arranca con GRUB, en BIOS y en UEFI. Todo corre en Docker;
# en el anfitrión solo queda la ISO, en distribucion/salida/.
# Uso: distribucion/construir.sh [VERSIÓN] [IMAGEN_DEL_ESCRITORIO]
set -euo pipefail
cd "$(dirname "$0")"
version=${1:-2026.2.1}
imagen=${2:-ghcr.io/nuevasomosaguas/entorno-escritorio:$version}
iso=salida/iso
rm -rf "$iso" && mkdir -p "$iso/live" "$iso/boot/grub"

docker build --platform=linux/amd64 --build-arg IMAGEN="$imagen" --build-context repo=.. -t "nueva-somosaguas/sistema:$version" .
cid=$(docker create --platform=linux/amd64 "nueva-somosaguas/sistema:$version")
trap 'docker rm -f "$cid" > /dev/null' EXIT

# El núcleo y el initrd (con live-boot dentro), fuera del squashfs para que GRUB los cargue.
docker cp "$cid:/boot/." salida/boot
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

# volcado.py arregla lo que Docker tapa (hosts, hostname, .dockerenv); sqfstar lee el
# resultado tal cual, con sus dueños y permisos, sin ser root.
docker export "$cid" | herramienta python3 /raiz-construccion/volcado.py /raiz \
  | herramienta sqfstar -comp zstd -quiet /salida/iso/live/filesystem.squashfs
# ISO híbrida (USB y DVD, BIOS y UEFI), con el nivel 3 de ISO 9660, que admite archivos
# de más de 4 GiB (xorriso-nivel3); tras «--», el nombre del volumen.
# Se borra antes la ISO anterior: si una VM la usó, libvirt se quedó con ella.
rm -f "salida/nueva-somosaguas-$version.iso"
herramienta grub-mkrescue --xorriso=/raiz-construccion/xorriso-nivel3 -o "/salida/nueva-somosaguas-$version.iso" /salida/iso -- -volid NUEVA_SOMOSAGUAS
sha256sum "salida/nueva-somosaguas-$version.iso" > "salida/nueva-somosaguas-$version.iso.sha256"
ls -lh "salida/nueva-somosaguas-$version.iso"
