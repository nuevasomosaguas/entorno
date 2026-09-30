---
title: Aprender de un curso
subtitle: Cómo tomar notas de las clases en vídeo y practicar lo que enseñan
author: Nueva Somosaguas
abstract: |
  Ver una clase da la sensación de aprender: todo se entiende mientras el profesor lo explica. Esa sensación engaña. Se aprende lo que uno consigue sacar de la memoria sin mirar y usar sin ayuda, y eso solo se entrena haciéndolo. Estas páginas cuentan cómo seguir un curso con mpv, cómo anotar cada concepto en Obsidian y cómo practicarlo hasta que sea tuyo.
---

## Antes: el curso, a mano

**En streaming.** Basta darle a mpv la dirección de la lista de reproducción:

```bash
mpv "https://www.youtube.com/playlist?list=…"
```

Al cerrarlo y volver a lanzar la misma orden, sigue en la clase en la que ibas y en el minuto donde la dejaste. `h` abre el historial de lo visto, con el punto de cada vídeo. Sin bajar nada, el curso deja su ficha en `Cursos/Nombre del curso/curso.m3u`, con sus clases: un doble clic lo reabre donde ibas, y `lecturas`, en el terminal, lo lista con tus libros y te dice por qué clase vas.

**Descargado**, para verlo sin conexión o a salvo de que lo retiren:

```bash
yt-dlp "https://www.youtube.com/playlist?list=…"
mpv ~/Cursos/Nombre-del-curso/
```

yt-dlp deja cada lista en su carpeta de `Cursos`, con las clases numeradas, los capítulos y los subtítulos en inglés. Volver a lanzarlo solo baja las clases nuevas. La carpeta se abre en mpv como una lista, y también retoma; `lecturas` la lista igual, marcada como descargada.

**Una nota por curso**, en Obsidian: `Notas/Cursos/Nombre del curso.md`, con la dirección, para qué lo haces (una frase: qué quieres saber hacer al acabar) y una línea por clase vista, con la fecha. Quien sabe para qué estudia, sabe también qué puede saltarse.

## Mientras: ver con el lápiz en la mano

| Tecla | Qué hace |
| :--- | :--- |
| `Espacio` | Pausa |
| `←` `→` · `↑` `↓` | 5 segundos atrás o adelante · un minuto |
| `[` `]` · `Retroceso` | Más despacio o más deprisa · velocidad normal |
| `AvPág` `RePág` | Capítulo anterior o siguiente |
| `v` · `j` | Mostrar u ocultar los subtítulos · cambiar de pista |
| `n` | Copia el momento, como enlace para las notas |
| `s` | Guarda el fotograma en `Screenshots`, con el título y el minuto en el nombre |
| `h` · `q` | El historial · salir, guardando dónde vas |

**Pausa en cada idea y escríbela sin mirar.** Con tus palabras, no con las del profesor: copiar lo que dice no obliga a entenderlo. Si no sabes escribirla sin volver atrás, no la has entendido todavía; `←` y otra vez. Esa es la señal más útil de toda la clase.

**Una nota por concepto.** Su título es la idea, dicha como una afirmación («La transformada de Laplace convierte derivadas en productos») o como una pregunta. Dentro, la explicación en tres o cuatro líneas, un ejemplo y el enlace al momento de la clase: `n` lo copia y basta pegarlo, `[Título, 12:30](…)`, que abre el vídeo en ese minuto. La captura (`s`), solo cuando la figura es la idea: se arrastra desde `Screenshots` a la nota. Enlaza cada concepto con los que ya tenías (`[[` en Obsidian): aprender es, sobre todo, colgar lo nuevo de lo que ya sabes.

**Apunta las dudas** con un `?` al principio de la línea. Al final de la clase, las que siguen abiertas van a la nota del curso.

**La velocidad, según lo que se ve.** Una charla admite `]` hasta 1,5; una demostración o un código que se escribe en pantalla, 1 o menos. Terminar antes no es aprender antes.

## Después: sacarlo de la memoria

**Nada más acabar, cinco minutos sin mirar.** Cierra el vídeo y las notas y escribe en una hoja, o en Xournal++, las tres ideas principales de la clase. Después compara con tus notas. Lo que no salió es lo que hay que repasar; lo que salió, se ha fijado un poco más solo por recordarlo.

**Preguntas, no resúmenes.** Al final de cada nota de concepto, una sección `## Preguntas` con dos o tres preguntas cuya respuesta sea el concepto: «¿Por qué la transformada de Laplace simplifica una ecuación diferencial?». Releer un resumen se siente como estudiar; contestar una pregunta sin mirar es estudiar.

**Repasos espaciados.** Cada nota lleva arriba su próximo repaso, `repaso: 2026-10-07`: al día siguiente, a la semana, al mes. Ese día contestas sus preguntas sin mirar y solo después compruebas; si fallas, el siguiente repaso vuelve a estar cerca. Buscar `repaso: 2026-10` en Obsidian da los de este mes. Mezcla en cada sesión preguntas de temas distintos: cuesta más y se recuerda mejor.

**Explícalo.** Como si se lo contaras a alguien de primero, por escrito y sin tecnicismos que no puedas definir. Donde la explicación se atasca está lo que aún no entiendes.

## Practicar: hacer, no releer

- **Antes de que el profesor resuelva un ejemplo, pausa e intenta resolverlo tú.** Aunque falles: el intento hace que la solución, cuando llega, se quede.
- **Rehaz cada ejemplo desde cero, sin el vídeo.** El código, en Julia, R o Python; la demostración, en papel o en Xournal++. Copiarlo mientras se ve no cuenta.
- **Cambia una cosa y predice antes de ejecutar.** Otros datos, otro parámetro, un caso límite. Escribe lo que esperas; si sale otra cosa, ahí hay algo que aprender.
- **Los ejercicios del curso, antes de mirar la solución.** Y los fallos, a una lista: qué salió mal y por qué. Cada fallo es una pregunta nueva para los repasos.
- **Un proyecto propio por bloque.** Aplica lo del curso a unos datos que te interesen: `nuevo-proyecto` crea la carpeta, con sus pruebas y su informe (lo cuenta `Documents/Proyectos.pdf`). Saber hacerlo con tus datos, y no con los del profesor, es la prueba de que lo sabes.

## Un día de curso

| Tiempo | Qué |
| :--- | :--- |
| 10 minutos | Los repasos que tocan hoy: preguntas sin mirar |
| Una clase | Verla con pausas, escribiendo cada idea |
| 5 minutos | Las tres ideas, sin mirar; completar las notas |
| El doble de la clase | Practicar: los ejemplos desde cero, los ejercicios, el proyecto |

Una o dos clases por sesión, no una tarde entera: una maratón de vídeos da la sensación de avanzar y deja poco. Mejor sesiones cortas, a diario y sin el móvil al lado. La concentración sostenida es un oficio que también se entrena [@newport2016deep]; aprender a aprender, el más rentable de todos [@hamming1997art].

## Lo que parece estudiar y no lo es

- Volver a ver la clase entera en lugar de intentar recordarla.
- Transcribir, subrayar o copiar el código de la pantalla.
- Pasar a la clase siguiente con las dudas de la anterior abiertas.
- Dejar la práctica para el final del curso.

Este manual está siempre en `Documents/Aprender.pdf`.

## Referencias
