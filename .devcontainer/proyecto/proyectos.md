---
title: Un trabajo, de principio a fin
subtitle: Cómo se monta un proyecto en la Nueva Somosaguas
author: Nueva Somosaguas
abstract: |
  Un trabajo no es un PDF: es la carpeta de la que sale. Los datos, el código que los analiza, las pruebas de ese código y el informe, todo junto y en Git, y una sola orden que lo rehace desde cero. Quien lo corrige, o tú dentro de dos años, clona la carpeta, escribe esa orden y obtiene el mismo informe con las mismas cifras. Estas páginas cuentan cómo empezar uno y qué va en cada sitio.
---

## Empezar

En un terminal, desde `Documents`:

```bash
nuevo-proyecto mortalidad
cd mortalidad
./construir.sh
```

La carpeta nace con un ejemplo que ya funciona: la mortalidad por edad en Virginia en 1940. `./construir.sh` lo analiza, pasa las pruebas y compila `informe.pdf`. Se abre, se mira cómo está hecho y se cambia, pieza a pieza, por el trabajo propio.

Por omisión, el informe se escribe en Typst y el análisis en Julia. Se cambian con dos opciones:

| Opción | Qué da |
| :--- | :--- |
| `--typst` o `--quarto` | El informe en Typst (`informe.typ`) o en Quarto (`informe.qmd`) |
| `--julia`, `--r` o `--python` | El análisis en Julia o en R, con una figura, o en Python, con una tabla |

Por ejemplo, `nuevo-proyecto paro --quarto --r`. Python queda para limpiar y preparar datos; el análisis estadístico va en Julia o en R.

## Qué va en cada sitio

| | |
| :--- | :--- |
| `datos/` | Los datos, tal como llegaron, y `LEEME.md`, con la procedencia de cada archivo |
| `codigo/` | `funciones` (las piezas del análisis) y `analisis` (el guion que las usa) |
| `pruebas/` | Las pruebas de las funciones |
| `informe.typ` o `.qmd` | El informe, con la plantilla de la Nueva Somosaguas |
| `referencias.bib` | Las referencias citadas, y solo esas |
| `construir.sh` | La orden que lo rehace todo |

`resultados/`, `figuras/` e `informe.pdf` no se guardan en Git: salen de lo demás, y se guarda cómo se hacen.

## Las cinco reglas

**1. Los datos no se tocan.** Lo que llega va a `datos/` tal cual, y se anota en `datos/LEEME.md` de dónde sale, cuándo se bajó y con qué licencia. Limpiar es un paso del código, no una edición a mano en una hoja de cálculo. Los microdatos con personas van a `datos/privados/`, que Git ignora: nunca a un repositorio.

**2. Ninguna cifra se copia a mano.** El análisis escribe las cifras que cita el informe en `resultados/cifras.yml`, y el informe las lee de ahí: `#cifras.razon` en Typst, `{{< meta razon >}}` en Quarto. Si los datos cambian, el texto cambia con ellos.

**3. Las pruebas las escribes tú.** Cada función de `codigo/funciones` merece una prueba con un caso que sepas resolver a mano: dos grupos iguales dan una razón de 1. Una prueba escrita por otro, o por una máquina, no demuestra que entiendas qué debe devolver tu código ni cuándo falla.

**4. El azar, con semilla.** El análisis fija la semilla al principio. Una simulación o un remuestreo salen idénticos cada vez.

**5. Las versiones, congeladas.** En Julia, `Project.toml` y `Manifest.toml` guardan la versión exacta de cada paquete; se trabaja con `julia --project=.` y `] add Paquete` los pone al día. En Python, `pyproject.toml` y `uv.lock`, con `uv add paquete`. R usa los paquetes de la imagen, fijados por semestre. Nada de `sudo` ni de `pip install`.

## El día a día

1. Cambiar el código o el texto.
2. `./construir.sh`. Si algo falla, se para y dice dónde.
3. Guardar el paso en Git con un mensaje que diga qué cambió: `lazygit`, o `git add -A && git commit -m "…"`.

En VS Code, el informe en Typst se previsualiza mientras se escribe, y `@` propone las referencias de la biblioteca. `construir.sh` escribe `referencias.bib` con lo citado (`bibcongelar`), así que basta citar.

Para trabajar en un proyecto con Zellij, `zellij attach -c nombre` desde su carpeta abre la sesión con Julia, R y Git ya en ella.

## Entregar

Antes de entregar, la prueba de verdad: clonar el repositorio en otra carpeta y construirlo desde cero.

```bash
git clone mortalidad /tmp/comprobacion
cd /tmp/comprobacion && ./construir.sh
```

Si ahí sale el mismo `informe.pdf`, el trabajo es reproducible. Si falla, falta algo en Git: un dato, un paquete sin fijar, una ruta de tu carpeta personal.

## Si algo va mal

- **Un cálculo se cierra solo** y aparece un aviso de memoria: el sistema lo ha parado antes de que se congele la máquina. Trabaja con menos datos a la vez, o lee solo las columnas que necesitas.
- **«Sin entrada en ninguna bibliografía»:** la clave citada no está ni en tu Zotero ni en la biblioteca de la Nueva Somosaguas. `bibsearch` la busca.
- **En Python, «uv.lock needs to be updated»:** has cambiado `pyproject.toml` a mano. `uv lock` lo pone al día.

Este manual está siempre en `Documents/Proyectos.pdf`.
