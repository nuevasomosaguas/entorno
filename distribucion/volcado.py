#!/usr/bin/env python3
"""Arregla el árbol del sistema (tar por la entrada estándar) antes del squashfs.

Docker tapa /etc/hosts, /etc/hostname y /etc/resolv.conf en cada RUN con los del
contenedor, y en la imagen quedan vacíos o no están. Aquí hosts y hostname se ponen
(o se sustituyen) con los de raiz/, de root, y se quita /.dockerenv si lo hay;
resolv.conf lo escribe NetworkManager al arrancar. El resto pasa tal
cual, con sus dueños y permisos. Sin «localhost» en /etc/hosts, PostgreSQL no abre
su socket.
"""
import io
import sys
import tarfile

RAIZ = sys.argv[1] if len(sys.argv) > 1 else "/raiz"
PROPIOS = ("etc/hosts", "etc/hostname")



def propio(miembro, nombre):
    with open(f"{RAIZ}/{nombre}", "rb") as f:
        datos = f.read()
    miembro.type, miembro.linkname = tarfile.REGTYPE, ""
    miembro.size, miembro.uid, miembro.gid, miembro.mode = len(datos), 0, 0, 0o644
    miembro.uname = miembro.gname = "root"
    salida.addfile(miembro, io.BytesIO(datos))


entrada = tarfile.open(fileobj=sys.stdin.buffer, mode="r|")
salida = tarfile.open(fileobj=sys.stdout.buffer, mode="w|", format=tarfile.PAX_FORMAT)
faltan = set(PROPIOS)
for miembro in entrada:
    nombre = miembro.name.removeprefix("./")
    if nombre == ".dockerenv":
        continue
    if nombre in PROPIOS:
        faltan.discard(nombre)
        propio(miembro, nombre)
    else:
        salida.addfile(miembro, entrada.extractfile(miembro) if miembro.isreg() else None)
# /etc ya pasó: los que no venían van al final, y sqfstar los pone en su sitio.
for nombre in sorted(faltan):
    propio(tarfile.TarInfo(nombre), nombre)
salida.close()
