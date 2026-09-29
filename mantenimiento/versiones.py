#!/usr/bin/env python3
"""Las versiones fijadas del entorno, frente a las últimas publicadas.

    python3 mantenimiento/versiones.py              # informe, en Markdown
    python3 mantenimiento/versiones.py --actualizar # además, sube los ARG y sus sumas
    python3 mantenimiento/versiones.py --actualizar --solo ZOTERO_VERSION   # solo una

Lee cada ARG fijado de los Dockerfile (y la revisión de somosaguas-makie en
julia/Project.toml), pregunta a su fuente cuál es la última versión y escribe una
tabla. Con --actualizar las sube en los archivos, vuelve a calcular las sumas SHA-256
de lo que se descarga con suma, y deja el resto a quien revise: la construcción de la
imagen comprueba cada herramienta, y lo que no se comprueba lo mira una persona.

Retenidas: Julia solo cambia de versión menor en septiembre (--septiembre), para que un
curso anual no cambie de Julia a mitad de año. El salto de Debian y la instantánea de
CRAN (SNAPSHOT) van en la lista del README, no aquí: SNAPSHOT se mueve con --actualizar
a la fecha del día.
"""
import datetime
import gzip
import hashlib
import json
import os
import re
import sys
import urllib.request
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
BASE = RAIZ / ".devcontainer/Dockerfile"
DISTRO = RAIZ / "distribucion/Dockerfile"
JULIA_PROYECTO = RAIZ / ".devcontainer/julia/Project.toml"


def leer(url, cabeceras=None):
    peticion = urllib.request.Request(url, headers={"User-Agent": "nueva-somosaguas", **(cabeceras or {})})
    with urllib.request.urlopen(peticion, timeout=60) as r:
        datos = r.read()
        return gzip.decompress(datos) if url.endswith(".gz") else datos


def github(ruta):
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    cabeceras = {"Accept": "application/vnd.github+json"}
    if token:
        cabeceras["Authorization"] = f"Bearer {token}"
    return json.loads(leer(f"https://api.github.com/{ruta}", cabeceras))


def publicada(repo):
    return github(f"repos/{repo}/releases/latest")["tag_name"].removeprefix("v")


def commit(repo, ruta=None):
    q = f"?path={ruta}&per_page=1" if ruta else "?per_page=1"
    return github(f"repos/{repo}/commits{q}")[0]["sha"]


def julia(actual, septiembre):
    versiones = [v for v, d in json.loads(leer("https://julialang-s3.julialang.org/bin/versions.json")).items() if d["stable"]]
    if not septiembre:  # la misma versión menor: solo arreglos
        menor = actual.rsplit(".", 1)[0] + "."
        versiones = [v for v in versiones if v.startswith(menor)]
    return max(versiones, key=lambda v: tuple(int(p) for p in v.split(".")))


def rstudio():  # «2026.09.0+174.pro3» → «2026.09.0-174», como en el nombre del .deb
    v = leer("https://download2.rstudio.org/current.ver").decode().strip()
    return re.sub(r"\.pro\d+$", "", v).replace("+", "-")


def zotero():
    peticion = urllib.request.Request("https://www.zotero.org/download/client/dl?channel=release&platform=linux-x86_64", method="HEAD")
    with urllib.request.urlopen(peticion, timeout=60) as r:
        return re.search(r"/release/([^/]+)/", r.url).group(1)


def vscode():
    paquetes = leer("https://packages.microsoft.com/repos/code/dists/stable/main/binary-amd64/Packages.gz").decode()
    versiones = re.findall(r"^Package: code\n(?:.+\n)*?Version: (\S+)", paquetes, re.M)
    return max(versiones, key=lambda v: [int(p) for p in re.split(r"[.-]", v)])


def tlcl():
    rss = leer("https://sourceforge.net/projects/linuxcommand/rss?path=/TLCL").decode()
    return max(set(re.findall(r"TLCL-(\d+\.\d+[A-Z]?)\.pdf", rss)), key=lambda v: (tuple(map(int, re.findall(r"\d+", v))), v))


# ARG, archivo, cómo saber la última y, si se descarga con suma, el ARG de la suma y su URL.
PIEZAS = [
    ("JULIA_VERSION", BASE, lambda a, s: julia(a, s), None),
    ("QUARTO_VERSION", BASE, lambda a, s: publicada("quarto-dev/quarto-cli"), None),
    ("PANDOC_VERSION", BASE, lambda a, s: publicada("jgm/pandoc"), None),
    ("TYPST_VERSION", BASE, lambda a, s: publicada("typst/typst"), None),
    ("RSTUDIO_VERSION", BASE, lambda a, s: rstudio(), None),
    ("XSV_VERSION", BASE, lambda a, s: publicada("BurntSushi/xsv"), None),
    ("ZELLIJ_VERSION", BASE, lambda a, s: publicada("zellij-org/zellij"), None),
    ("SOMOSAGUAS_QUARTO_REV", BASE, lambda a, s: commit("nuevasomosaguas/somosaguas-quarto-theme"), None),
    ("SOMOSAGUAS_GGPLOT2_REV", BASE, lambda a, s: commit("nuevasomosaguas/somosaguas-ggplot2"), None),
    ("TINYTEX_VERSION", BASE, lambda a, s: publicada("rstudio/tinytex-releases"), None),
    ("TLCL_VERSION", BASE, lambda a, s: tlcl(),
     ("TLCL_SHA256", "https://sourceforge.net/projects/linuxcommand/files/TLCL/{menor}/TLCL-{v}.pdf/download")),
    ("BIBLIOTECA_REV", BASE, lambda a, s: commit("nuevasomosaguas/nuevasomosaguas.github.io", "biblioteca.bib"), None),
    ("OBSIDIAN_VERSION", BASE, lambda a, s: publicada("obsidianmd/obsidian-releases"), None),
    ("AUTO_LINK_TITLE_VERSION", BASE, lambda a, s: publicada("zolrath/obsidian-auto-link-title"), None),
    ("CITATIONS_VERSION", BASE, lambda a, s: publicada("hans/obsidian-citation-plugin"), None),
    ("MATCHA_VERSION", BASE, lambda a, s: publicada("vinceliuice/Matcha-gtk-theme"), None),
    ("PAPIRUS_FOLDERS_VERSION", BASE, lambda a, s: publicada("PapirusDevelopmentTeam/papirus-folders"), None),
    ("JABREF_VERSION", BASE, lambda a, s: publicada("JabRef/jabref"), None),
    ("ZOTERO_VERSION", BASE, lambda a, s: zotero(), None),
    ("BETTER_BIBTEX_VERSION", BASE, lambda a, s: publicada("retorquere/zotero-better-bibtex"),
     ("BETTER_BIBTEX_SHA256", "https://github.com/retorquere/zotero-better-bibtex/releases/download/v{v}/zotero-better-bibtex-{v}.xpi")),
    ("ZOTMOOV_VERSION", BASE, lambda a, s: publicada("wileyyugioh/zotmoov"),
     ("ZOTMOOV_SHA256", "https://github.com/wileyyugioh/zotmoov/releases/download/{v}/zotmoov-{v}-fx.xpi")),
    ("MEMO_REV", BASE, lambda a, s: commit("po5/memo"), None),
    ("LOCALSEND_VERSION", DISTRO, lambda a, s: publicada("localsend/localsend"),
     ("LOCALSEND_SHA256", "https://github.com/localsend/localsend/releases/download/v{v}/LocalSend-{v}-linux-x86-64.deb")),
    ("VSCODE_VERSION", DISTRO, lambda a, s: vscode(), None),
]


def arg(archivo, nombre):
    return re.search(rf"^ARG {nombre}=(.*)$", archivo.read_text(), re.M).group(1)


def fijar(archivo, nombre, valor):
    texto = archivo.read_text()
    archivo.write_text(re.sub(rf"^ARG {nombre}=.*$", f"ARG {nombre}={valor}", texto, count=1, flags=re.M))


def corto(v):
    return v[:10] if re.fullmatch(r"[0-9a-f]{40}", v) else v


def main():
    actualizar = "--actualizar" in sys.argv
    septiembre = "--septiembre" in sys.argv or datetime.date.today().month in (8, 9)
    solo = sys.argv[sys.argv.index("--solo") + 1] if "--solo" in sys.argv else None
    filas, fallos = [], 0

    for nombre, archivo, ultima, suma in PIEZAS:
        if solo and nombre != solo:
            continue
        actual = arg(archivo, nombre)
        try:
            nueva = ultima(actual, septiembre)
        except Exception as e:  # una fuente caída no para el informe
            filas.append((nombre, actual, "?", f"sin respuesta ({type(e).__name__})"))
            fallos += 1
            continue
        if nueva == actual:
            filas.append((nombre, actual, nueva, "al día"))
            continue
        estado = "nueva"
        if actualizar:
            fijar(archivo, nombre, nueva)
            if suma:
                url = suma[1].format(v=nueva, menor=re.sub(r"[A-Z]$", "", nueva))
                fijar(archivo, suma[0], hashlib.sha256(leer(url)).hexdigest())
            estado = "subida"
        filas.append((nombre, actual, nueva, estado))

    if solo:
        return imprimir(filas, fallos, septiembre)

    # somosaguas-makie, fijada por revisión en julia/Project.toml: al cambiarla hay que
    # volver a resolver el Manifest (el flujo de GitHub Actions lo hace).
    proyecto = JULIA_PROYECTO.read_text()
    actual = re.search(r'Somosaguas = \{rev = "([0-9a-f]{40})"', proyecto).group(1)
    nueva = commit("nuevasomosaguas/somosaguas-makie")
    if nueva != actual and actualizar:
        JULIA_PROYECTO.write_text(proyecto.replace(actual, nueva))
    filas.append(("somosaguas-makie (Project.toml)", actual, nueva,
                  "al día" if nueva == actual else ("subida" if actualizar else "nueva")))

    hoy = datetime.date.today()
    snapshot = arg(BASE, "SNAPSHOT")
    edad = (hoy - datetime.date.fromisoformat(snapshot)).days
    if actualizar:
        fijar(BASE, "SNAPSHOT", hoy.isoformat())
    filas.append(("SNAPSHOT (CRAN)", snapshot, hoy.isoformat() if actualizar else f"hace {edad} días",
                  "subida" if actualizar else ("al día" if edad < 120 else "vieja")))
    imprimir(filas, fallos, septiembre)


def imprimir(filas, fallos, septiembre):
    hoy = datetime.date.today()
    print(f"Versiones del entorno, {hoy.isoformat()}"
          + (" (con cambios de versión menor de Julia: septiembre)" if septiembre else "") + "\n")
    print("| Pieza | Fijada | Última | Estado |\n| :--- | :--- | :--- | :--- |")
    for f in filas:
        print(f"| `{f[0]}` | {corto(f[1])} | {corto(f[2])} | {f[3]} |")
    pendientes = sum(1 for f in filas if f[3] in ("nueva", "vieja"))
    print(f"\n{pendientes} por subir, {fallos} fuentes sin respuesta.")


if __name__ == "__main__":
    main()
