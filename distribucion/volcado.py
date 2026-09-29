#!/usr/bin/env python3
"""Arregla el volcado de Docker (tar por la entrada estándar) antes del squashfs.

Docker tapa /etc/hosts, /etc/hostname y /etc/resolv.conf con archivos vacíos y añade
/.dockerenv. Aquí se quita .dockerenv y hosts y hostname se sustituyen por los de
raiz/, de root; resolv.conf lo escribe NetworkManager al arrancar. El resto pasa tal
cual, con sus dueños y permisos. Sin «localhost» en /etc/hosts, PostgreSQL no abre
su socket.
"""
import io
import sys
import tarfile

RAIZ = sys.argv[1] if len(sys.argv) > 1 else "/raiz"
PROPIOS = ("etc/hosts", "etc/hostname")

entrada = tarfile.open(fileobj=sys.stdin.buffer, mode="r|")
salida = tarfile.open(fileobj=sys.stdout.buffer, mode="w|", format=tarfile.PAX_FORMAT)
for miembro in entrada:
    nombre = miembro.name.removeprefix("./")
    if nombre == ".dockerenv":
        continue
    if nombre in PROPIOS:
        with open(f"{RAIZ}/{nombre}", "rb") as f:
            datos = f.read()
        miembro.size, miembro.uid, miembro.gid, miembro.mode = len(datos), 0, 0, 0o644
        miembro.uname = miembro.gname = "root"
        salida.addfile(miembro, io.BytesIO(datos))
    else:
        salida.addfile(miembro, entrada.extractfile(miembro) if miembro.isreg() else None)
salida.close()
