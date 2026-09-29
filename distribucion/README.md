# Nivel 3: la distribución de la Nueva Somosaguas

Los niveles 1 y 2 (Codespaces y el devcontainer) son **contenedores**: comparten el núcleo de otra máquina, arrancan sin *init*, no ven el hardware y se dibujan por VNC. El nivel 3 es un **sistema operativo completo**: Debian 13 instalado en el disco de un portátil, o arrancado desde un USB, con su propio núcleo, su arranque y su escritorio sobre la pantalla real.

Por eso no puede ser la misma imagen. Lo que sí puede ser es **la misma receta**: las mismas versiones, los mismos paquetes, los mismos ajustes y la misma verificación. Un laboratorio escrito en un Codespace da los mismos números en un portátil de la facultad, porque Julia, R y Python salen de los mismos lockfiles; lo que cambia es todo lo que rodea al cálculo.

## Lo que comparten

Una sola fuente de verdad, en este repositorio. La distribución no copia nada a mano: lee los mismos archivos que el Dockerfile.

| Pieza | Fuente común |
| :--- | :--- |
| Paquetes de Julia | `.devcontainer/julia/Manifest.toml` |
| Paquetes de Python | `.devcontainer/python/uv.lock` |
| Paquetes de R | La instantánea de CRAN (`SNAPSHOT`) y el mismo `SOMOSAGUAS_GGPLOT2_REV` |
| Versiones de las herramientas | Los `ARG` del Dockerfile: Julia, Quarto, Typst, Zellij, TinyTeX, Obsidian, Zotero, JabRef… |
| Ajustes | `zathurarc`, `fonts.conf`, XFCE (`escritorio/xfce/`), Obsidian (`Notas/`), Newsboat, Zellij, lazygit, htop |
| Verificación | `verificar_entorno.sh` y las comprobaciones finales de cada etapa |
| Versión | La misma etiqueta de calendario: la imagen `2026.2` y la ISO `2026.2` son el mismo semestre |

## Lo que cambia

| | Contenedor (niveles 1 y 2) | Distribución (nivel 3) |
| :--- | :--- | :--- |
| Núcleo y arranque | Los del anfitrión; sin *init* | Núcleo de Debian, GRUB y systemd |
| Servicios | `postStartCommand` arranca PostgreSQL, RStudio y earlyoom | Unidades de systemd, activas desde el arranque |
| Escritorio | XFCE por VNC y noVNC, a 24 bits en el navegador | XFCE sobre la pantalla, con LightDM como gestor de sesiones |
| Suavizado de letra | Grises, porque el VNC reescala | Grises igualmente: sirve en cualquier pantalla y en HiDPI |
| Editores | VS Code Server y RStudio Server en el navegador | VS Code y RStudio de escritorio |
| *Sandbox* | Desactivado (Obsidian `--no-sandbox`, WebKitGTK) | Activo: fuera las excepciones del contenedor |
| Núcleo y memoria | earlyoom; zram y `sysctl` son del anfitrión | earlyoom, zram y los ajustes de [El núcleo y la memoria](#el-núcleo-y-la-memoria) |
| Usuarios | Uno, `vscode` | Los de la máquina: el depósito de Julia y TinyTeX, compartidos para todos |
| Disco | Efímero salvo `/workspaces` | Persistente y **cifrado con LUKS** por omisión |
| Hardware | Ninguno | Firmware, Wi-Fi, suspensión, impresoras y, opcionalmente, GPU NVIDIA para CUDA |
| Actualizaciones | Se reconstruye la imagen | Parches de seguridad de Debian automáticos; la pila de cálculo, congelada por semestre |

## Cómo se construye

Con **live-build**, la herramienta con la que Debian hace sus propias imágenes en vivo. Produce una ISO híbrida que sirve para las dos cosas que promete el nivel 3:

* **USB en vivo.** Se graba en un pendrive, arranca en cualquier portátil y se prueba sin tocar el disco. Opcionalmente, con persistencia cifrada para llevar el trabajo encima.
* **Instalador.** Desde la misma sesión en vivo, **Calamares** (con los ajustes de Debian) instala el sistema en el disco, con la casilla de cifrado marcada de serie.

La propuesta de estructura:

```
distribucion/
├── README.md                  este documento
├── auto/config                las opciones de lb config: trixie, amd64, non-free-firmware
├── config/package-lists/      los paquetes de apt, los mismos que en el Dockerfile
├── config/hooks/normal/       lo que no es apt: Julia, R, Python, TinyTeX, Quarto, Zotero…
├── config/includes.chroot/    los ajustes comunes, copiados de .devcontainer en la construcción
└── construir.sh               lb clean && lb config && lb build, con la versión de calendario
```

**El riesgo principal es la deriva**: si los pasos de instalación viven a la vez en el Dockerfile y en los *hooks* de live-build, tarde o temprano dirán cosas distintas. El remedio es sacar del Dockerfile cada paso que no dependa del contenedor (instalar Julia desde el Manifest, R desde la instantánea, Python desde `uv.lock`, TinyTeX, los binarios sueltos) a un guion en `.devcontainer/instalar/`. El Dockerfile ejecuta esos guiones con `RUN`, y los *hooks* de live-build ejecutan los mismos. Lo exclusivo de cada nivel queda aparte y a la vista: VNC y noVNC en el contenedor; systemd, LightDM, LUKS y zram en la distribución.

## El núcleo y la memoria

Un contenedor no puede tocar el núcleo, pero la distribución sí. Los ajustes se limitan a lo que cambia algo en el núcleo 6.12 de trixie; lo que ya viene bien de fábrica no se repite.

```
# /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet transparent_hugepage=madvise zswap.enabled=0"

# /etc/sysctl.d/99-somosaguas.conf
vm.swappiness = 100
vm.vfs_cache_pressure = 50
vm.dirty_background_bytes = 67108864
vm.dirty_bytes = 268435456
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 1024
```

A esto se suman **earlyoom** como servicio de systemd, con la misma configuración que el contenedor, y **zram** (`zram-tools`): swap comprimida con `zstd` en la mitad de la RAM, con prioridad sobre cualquier swap en disco.

* **`transparent_hugepage=madvise`.** trixie trae las páginas gigantes transparentes en modo `always`: el núcleo fusiona páginas por su cuenta y provoca picos de latencia en PostgreSQL y en los recolectores de basura de Julia y R. En `madvise` solo las usa quien las pide.
* **`zswap.enabled=0`.** Con zram, zswap comprimiría dos veces. Debian ya lo trae apagado; escribirlo protege de un cambio futuro de ese valor.
* **`vm.swappiness = 100`.** Con la swap en RAM comprimida, mandar allí la memoria fría sale barato, y es mejor que vaciar la caché de disco. (Sin zram, con swap en disco, lo sensato sería 10.)
* **`vm.vfs_cache_pressure = 50`.** Conserva en memoria los directorios y metadatos del disco, que `git status`, `rg` y `fd` recorren una y otra vez. El efecto es modesto.
* **`vm.dirty_*_bytes`.** Escrituras pendientes en tandas de 64 MB, con un tope de 256 MB. En bytes y no en porcentaje: el 10 % de 32 GB serían 3 GB sin escribir, y el sistema se atascaría al volcarlos de golpe al guardar un CSV o un Parquet enorme.
* **`fs.inotify.*`.** En 6.12, el límite de archivos vigilados es el 1 % de la RAM entre el coste de cada vigilancia (unas 130 000 con 16 GB) y el de instancias, 128. VS Code, Obsidian, Pluto y `quarto preview` los agotan, y entonces dejan de ver los cambios sin avisar.

Lo que **no** se toca, y por qué:

* **`psi=1`.** PSI ya está activo en el núcleo de Debian. earlyoom, además, no lo usa: lee `/proc/meminfo`. Quien lo usa es `systemd-oomd`, que no debe convivir con earlyoom.
* **`split_lock_mitigate`.** No es un parámetro de arranque, sino un `sysctl`, y desactivarlo expone la máquina a que un proceso frene a los demás. El código numérico bien alineado apenas produce *split locks*.
* **`vm.overcommit_memory = 0` y `vm.overcommit_ratio`.** El primero ya es el valor por omisión, y el segundo solo cuenta con `overcommit_memory = 2`.
* **`fs.file-max`.** systemd ya lo sube al máximo posible; fijarlo lo bajaría. El límite que importa es el de cada proceso (`RLIMIT_NOFILE`), que systemd también ajusta.
* **El gobernador de la CPU.** En los portátiles modernos mandan `intel_pstate` o `amd-pstate`, que solo ofrecen `performance` y `powersave` (que, pese al nombre, se adapta a la carga): escribir `schedutil` falla. En su lugar, `power-profiles-daemon`: `powerprofilesctl set performance` para una tanda de cálculo con el cargador conectado, y el perfil equilibrado el resto del tiempo. Una regla de udev puede hacer el cambio sola al enchufar y desenchufar.

## Suspensión e hibernación

El mal endémico de Linux en portátiles: la tapa que no suspende, el equipo que se despierta en la mochila, la batería que amanece vacía o la sesión que vuelve sin bloquear, con microdatos en pantalla. Cuatro reglas lo evitan.

**1. Un solo responsable de la tapa: systemd-logind.** El gestor de energía de XFCE (4.20) se queda por omisión con la tapa y, al cerrarla, solo bloquea la pantalla: el portátil sigue encendido dentro de la mochila. Además, fuera de la sesión (en la pantalla de inicio de LightDM) no actúa nadie. En la distribución, XFCE cede la tapa y las teclas de energía a logind, que funciona siempre, y se limita a bloquear la pantalla antes de dormir:

```
# /etc/systemd/logind.conf.d/somosaguas.conf
[Login]
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=suspend
HandleLidSwitchDocked=ignore

# XFCE (xfconf, canal xfce4-power-manager), como predeterminado del sistema
logind-handle-lid-switch=true
logind-handle-power-key=true
logind-handle-suspend-key=true
logind-handle-hibernate-key=true
lock-screen-suspend-hibernate=true
```

El bloqueo lo pone **light-locker**, que se apoya en LightDM: al despertar, la sesión pide la contraseña.

**2. El modo de suspensión, el que ofrezca el firmware.** Los portátiles recientes solo traen `s2idle` (el *Modern Standby* de Windows), que gasta algo más de batería dormido; algunos ThinkPad ofrecen aún en la BIOS el modo S3 (`deep`), que gasta menos. No se fuerza `mem_sleep_default=deep` a ciegas: se prueba modelo a modelo y se fija solo donde funciona.

**3. Hibernación o arranque seguro: hay que elegir.** El núcleo de Debian se bloquea (*lockdown*) cuando arranca con Secure Boot, y un núcleo bloqueado no permite hibernar: la imagen de la memoria podría alterarse en el disco sin que nadie lo comprobara.

* **Portátiles de la facultad: Secure Boot, sin hibernación.** Protege el arranque contra manipulaciones, y la hibernación es la mayor fuente de fallos de energía en Linux. Suspender basta; con la batería crítica, UPower apaga el equipo (su orden es suspensión híbrida, luego hibernación, luego apagado: toma el primero disponible), y el disco queda cifrado.
* **Equipos propios que quieran hibernar: sin Secure Boot.** La swap de disco va **dentro del volumen cifrado** y tiene al menos tanto espacio como la RAM: la imagen de la memoria, con los microdatos abiertos, nunca toca el disco en claro. Al volver, el arranque pide la frase de LUKS antes de restaurar la sesión. Esa swap convive con zram con menos prioridad: zram atiende el día a día y el disco solo recibe la hibernación. Con hibernación, la tapa pasa a `suspend-then-hibernate`: suspende y, pasadas dos horas (`HibernateDelaySec=2h`), hiberna, así la batería no se agota en un fin de semana.

**4. Lo que despierta al equipo, revisado por modelo.** Si un portátil se despierta solo, `/proc/acpi/wakeup` dice quién ha sido (a menudo el controlador USB o el teclado); una regla de udev desactiva ese despertador en ese modelo, no en todos. Con GPU NVIDIA, se activan los servicios de suspensión y reanudación del propio controlador, que guardan la memoria de vídeo.

La prueba en hardware real incluye, por modelo: veinte ciclos de suspender y despertar con la tapa, una noche dormido con la batería (cuánto gasta), el Wi-Fi y el monitor externo tras despertar, y, donde se hiberne, cinco hibernaciones con su frase de LUKS.

## El cifrado

En la facultad presencial, los portátiles asignados se instalan **siempre** con el disco cifrado (LUKS2): si un equipo se pierde, los microdatos que contiene siguen protegidos, como exige el RGPD. Dos caminos:

* **Portátiles de la facultad:** instalación desatendida con el instalador de Debian y un archivo de *preseed* que impone el esquema cifrado; el alumno solo elige su frase de paso.
* **Equipos propios:** Calamares, con el cifrado marcado por omisión y la advertencia de que desmarcarlo deja los datos expuestos.

## Actualizaciones sin romper la reproducibilidad

Dos ritmos, separados:

* **El sistema** recibe los parches de seguridad de Debian con `unattended-upgrades`. Debian estable no cambia de versión mayor sus paquetes a mitad de ciclo: corrige, no renueva.
* **La pila de cálculo** (Julia, los paquetes de R, Python, Quarto, Typst) no la toca apt, salvo R y sus bibliotecas de sistema. Cambia una vez por semestre, con la ISO nueva, igual que la imagen del contenedor.

Una ISO publicada no se borra nunca, como las etiquetas de la imagen: un laboratorio de 2026 se reabre en 2036 arrancando la ISO `2026.2`.

## Publicación

La ISO la construye GitHub Actions al empujar la etiqueta del semestre, igual que las imágenes. Dos límites a resolver:

* **Tamaño.** Con el depósito de Julia precompilado, R, TinyTeX y el escritorio, la ISO pasará previsiblemente de los 2 GiB, y GitHub no admite archivos de publicación mayores. Hará falta alojarla en otro sitio (un servidor de la facultad o un almacenamiento de objetos), con su suma SHA-256 y su firma publicadas en GitHub junto a la versión.
* **Privilegios.** live-build necesita root y dispositivos de bucle; en Actions se ejecuta con `sudo` en el propio *runner*, no dentro de un contenedor sin privilegios.

## Pasos

1. Sacar los pasos comunes del Dockerfile a `.devcontainer/instalar/` y comprobar que la imagen sigue construyéndose igual.
2. Primera ISO en vivo, sin instalador: arranca, abre XFCE con el tema de Somosaguas y pasa `verificar_entorno.sh`.
3. Servicios de systemd y núcleo: PostgreSQL, earlyoom, zram, `power-profiles-daemon`, la línea de GRUB y los `sysctl` de [El núcleo y la memoria](#el-núcleo-y-la-memoria), y la tapa, el bloqueo y la suspensión de [Suspensión e hibernación](#suspensión-e-hibernación).
4. Calamares con cifrado por omisión, y el *preseed* de los portátiles de la facultad.
5. Construcción en GitHub Actions y publicación de la ISO fuera de GitHub.
6. Prueba en hardware real: al menos un portátil de la facultad, uno antiguo y uno con pantalla HiDPI, con la batería de pruebas de [Suspensión e hibernación](#suspensión-e-hibernación).

## Preguntas abiertas

* **¿Arranque seguro (Secure Boot) en todos los equipos?** La propuesta es sí en los de la facultad, a costa de la hibernación (ver [Suspensión e hibernación](#suspensión-e-hibernación)). Queda por resolver el caso de NVIDIA: con Secure Boot, sus módulos han de ir firmados con una clave propia inscrita en el firmware (MOK).
* **¿Un usuario o varios por portátil?** Decide si el depósito de Julia y TinyTeX se comparten en `/opt` o se copian a cada usuario.
* **¿Wayland?** XFCE 4.20 aún lo trata como experimental; X11 es la opción segura para 2026.
