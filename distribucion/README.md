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
| Editores | VS Code Server y RStudio Server en el navegador | VS Code de escritorio (en español); RStudio Server, solo en localhost, en el navegador |
| *Sandbox* | Desactivado (Obsidian `--no-sandbox`, WebKitGTK) | Activo en WebKitGTK; Obsidian conserva `--no-sandbox` (pendiente) |
| Núcleo y memoria | earlyoom; zram y `sysctl` son del anfitrión | earlyoom, zram y los ajustes de [El núcleo y la memoria](#el-núcleo-y-la-memoria) |
| Usuarios | Uno, `alumno` | En vivo, `alumno` (contraseña: `somosaguas`); instalado, la cuenta que se cree, o varias, todas desde la misma plantilla |
| Docker | No: la imagen se reconstruye | Docker, buildx y compose, para abrir en local los devcontainers |
| Disco | Efímero salvo `/workspaces` | Persistente y **cifrado con LUKS** (obligatorio en los portátiles de la facultad) |
| Hardware | Ninguno | Firmware, Wi-Fi, suspensión, impresoras y, opcionalmente, GPU NVIDIA para CUDA |
| Actualizaciones | Se reconstruye la imagen | Parches de seguridad de Debian automáticos; la pila de cálculo, congelada por semestre |

## Cómo se construye

**Desde la imagen del escritorio, sin volver a instalar nada.** [`Dockerfile`](Dockerfile) parte de `ghcr.io/nuevasomosaguas/entorno-escritorio` y solo añade lo que un sistema operativo necesita y un contenedor no tiene: núcleo y firmware (también el de la sección `non-free-firmware`, como las ISO de Debian: Wi-Fi de Intel y Realtek, sonido, gráficas de AMD y el microcódigo de los procesadores), arranque en vivo (live-boot), systemd, LightDM y el servidor gráfico, red y sonido, VS Code de escritorio, Docker y los servicios. Julia, R, Python, las herramientas y cada ajuste llegan ya hechos y comprobados en la imagen: la receta es una sola y no puede haber deriva entre niveles.

```bash
distribucion/construir.sh 2026.2.2                               # desde la imagen publicada
distribucion/construir.sh 2026.2.2 nueva-somosaguas/escritorio  # desde una construida en local
```

[`construir.sh`](construir.sh) hace cuatro cosas, todas dentro de Docker y sin root; en el anfitrión solo queda `salida/nueva-somosaguas-VERSIÓN.iso`, con su suma SHA-256:

1. Construye la imagen del sistema y vuelca su árbol de archivos (`docker export`).
2. [`volcado.py`](volcado.py) corrige ese volcado y `sqfstar` lo convierte en `live/filesystem.squashfs`, con dueños y permisos intactos.
3. Saca el núcleo y el initrd (con live-boot dentro) para que GRUB los cargue.
4. `grub-mkrescue` monta una ISO híbrida que arranca en BIOS y en UEFI, desde un USB o un DVD, con el menú de [`grub.cfg`](grub.cfg). [`xorriso-nivel3`](xorriso-nivel3) le añade el nivel 3 de ISO 9660: el squashfs pasa de 4 GiB.

```
distribucion/
├── Dockerfile        la capa del sistema operativo sobre la imagen del escritorio
├── raiz/             sus ajustes, con el mismo árbol que el sistema: /etc/sysctl.d, /etc/default, systemd, LightDM, XFCE…
├── construir.sh      imagen → squashfs → ISO
├── volcado.py        lo que Docker tapa en el volcado
├── vscode.py         extensiones y ajustes de VS Code, leídos de .devcontainer/devcontainer.json
├── xorriso-nivel3    ISO de nivel 3
└── grub.cfg          el menú de arranque
```

**Lo que un contenedor esconde**, y cómo se resuelve aquí:

* **`systemctl` de mentira.** La imagen base trae en `/usr/local/bin` un `systemctl` que, sin systemd en marcha, no hace nada: los servicios se activan con `/usr/bin/systemctl`.
* **Archivos tapados.** Al volcar, Docker deja vacíos `/etc/hosts` y `/etc/hostname` (y sin «localhost» PostgreSQL no arranca) y añade `/.dockerenv`: `volcado.py` los arregla antes del squashfs.
* **`ENV` no viaja.** Lo que el Dockerfile del contenedor pone con `ENV` (el `PATH` de uv y de `/opt/venv`, el español, la zona horaria) se escribe aquí en `/etc/default/locale`, `/etc/profile.d`, `/etc/X11/Xsession.d` y `/etc/localtime`.
* **Excepciones del contenedor.** Sin `ENV`, WebKitGTK vuelve a usar su sandbox; RStudio Server escucha solo en localhost, porque aquí la red es de verdad.

**Las cuentas.** Todo lo de cada cuenta vive en la plantilla, `/etc/skel`: los ajustes, la bóveda de Obsidian, el perfil de Zotero, los marcadores, el manual y la biblioteca, TinyTeX (unos 250 MB, para que cada cuenta instale los paquetes de LaTeX que le falten) y las extensiones de VS Code. Lo pesado se comparte: los paquetes de Julia, ya compilados, están en `/opt/julia/depot`, de solo lectura, detrás del `~/.julia` de cada cuenta (`JULIA_DEPOT_PATH=":/opt/julia/depot"`). `alumno`, en vivo, sale de esa plantilla, y cualquier cuenta que cree el instalador o `adduser` nace igual. Las pocas rutas absolutas llevan `@HOME@`, y `somosaguas-cuenta` pone la carpeta de cada cuenta al abrir su sesión. Al arrancar, `somosaguas-cuentas` le da a cada cuenta su base de PostgreSQL; RStudio es un servicio de cada cuenta (`systemctl --user`), solo en localhost.

**El instalador.** El icono *Instalar la Nueva Somosaguas* del escritorio en vivo abre **Calamares** con los ajustes de Debian (`calamares-settings-debian`) y los de [`raiz/etc/calamares/`](raiz/etc/calamares/): el nombre y los colores de la Nueva Somosaguas, «alumno» como nombre de cuenta propuesto (se puede cambiar), el grupo `docker`, sin swap en disco por omisión (la da zram) y más de 40 GB de disco. Quita la cuenta en vivo antes de crear la nueva, con su sudo sin contraseña y su entrada automática, y también `live-boot` y el propio instalador. GRUB (UEFI o BIOS) y `cryptsetup-initramfs` salen del repositorio de la ISO (`dists/` y `pool/`, como en las de Debian), sin red; y el sistema instalado arranca con los parámetros del núcleo de `raiz/etc/default/grub.d/`. Pide la contraseña de `alumno`, `somosaguas`.

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

## Dispositivos y discos

Enchufar un USB, una tarjeta o un móvil tiene que funcionar a la primera, sin comprometer los datos. Por omisión, XFCE no hace nada: thunar-volman trae el montaje automático desactivado, y el USB solo aparece en el panel lateral de Thunar. La distribución lo deja así:

```
# XFCE (xfconf, canal thunar-volman), como predeterminado del sistema
/automount-drives/enabled=true
/automount-media/enabled=true
/autobrowse/enabled=true
/autorun/enabled=false
/autoopen/enabled=false

# /etc/udisks2/mount_options.conf
[defaults]
ntfs_drivers=ntfs,ntfs3
```

* **Se monta y se abre; nunca se ejecuta.** Un USB o una tarjeta se montan al enchufarlos y Thunar abre su carpeta. Nada se ejecuta solo (`autorun` y `autoopen`, apagados): un pendrive ajeno no puede lanzar nada.
* **Solo lo del usuario y sin privilegios.** udisks2 monta en `/media/<usuario>`, siempre con `nosuid` y `nodev`, y la política de polkit permite montar medios extraíbles al usuario de la sesión, sin contraseña. Los discos internos y los de otros usuarios siguen pidiendo la de administrador.
* **Los formatos de siempre.** FAT y exFAT (`exfatprogs`, `dosfstools`) para intercambiar con Windows y macOS; NTFS con **ntfs-3g**, el controlador veterano, antes que el `ntfs3` del núcleo, más joven y menos probado (udisks 2.10 los prueba en el orden contrario).
* **Sacar un USB sin perder datos.** Hay que expulsarlo desde Thunar, que avisa cuando es seguro retirarlo. Los FAT se montan con `flush` y escriben enseguida; los exFAT no, pero el tope de 256 MB de escrituras pendientes (`vm.dirty_bytes`, en [El núcleo y la memoria](#el-núcleo-y-la-memoria)) acorta la espera.
* **Microdatos, solo en USB cifrado.** El RGPD que obliga a cifrar el disco del portátil alcanza también a las copias. *Discos* (`gnome-disk-utility`) formatea un pendrive con LUKS en dos clics; al enchufarlo, Thunar pide la frase de paso y lo monta.
* **Móviles, cámaras y la red de la facultad.** `gvfs-backends` da acceso por MTP a los Android, por AFC a los iPhone, por PTP a las cámaras y por SMB a las carpetas compartidas del servidor (`smb://` en Thunar), sin montar nada a mano.
* **El SSD interno.** El volumen LUKS se abre con `discard` y `fstrim.timer` recorta una vez por semana los bloques libres, para que el SSD no pierda velocidad. El precio: desde fuera se ve qué bloques están vacíos, no qué contienen.

Paquetes explícitos, porque Thunar solo los recomienda: `udisks2`, `gvfs-backends`, `thunar-volman`, `exfatprogs`, `dosfstools`, `ntfs-3g`, `gnome-disk-utility` y `xfce4-notifyd` (los avisos de expulsión).

## El cifrado

En la facultad presencial, los portátiles asignados se instalan **siempre** con el disco cifrado: si un equipo se pierde, los microdatos que contiene siguen protegidos, como exige el RGPD. Dos caminos:

* **Portátiles de la facultad** (pendiente): instalación desatendida con un archivo de *preseed* que impone el esquema cifrado; el alumno solo elige su frase de paso. Es el único camino que lo garantiza: Calamares 3.3 ofrece el cifrado, pero no permite dejarlo marcado de antemano.
* **Equipos propios:** Calamares, con la casilla *Cifrar el sistema* al borrar el disco. Usa LUKS1, porque GRUB tiene que abrir `/boot` cifrado y no admite LUKS2 con Argon2; el *preseed*, con `/boot` aparte, puede usar LUKS2.

## Actualizaciones sin romper la reproducibilidad

Dos ritmos, separados:

* **El sistema** recibe los parches de seguridad de Debian con `unattended-upgrades`. Debian estable no cambia de versión mayor sus paquetes a mitad de ciclo: corrige, no renueva.
* **La pila de cálculo** (Julia, los paquetes de R, Python, Quarto, Typst) no la toca apt, salvo R y sus bibliotecas de sistema. Cambia una vez por semestre, con la ISO nueva, igual que la imagen del contenedor.

Una ISO publicada no se borra nunca, como las etiquetas de la imagen: un laboratorio de 2026 se reabre en 2036 arrancando la ISO `2026.2`.

## Publicación

La construye GitHub Actions a petición ([`distribucion.yml`](../.github/workflows/distribucion.yml), *Run workflow*), una vez cerrada la configuración del semestre: la distribución es la versión del semestre, `2026.2`, sin los arreglos intermedios de las imágenes. Parte del commit elegido, construye la imagen del escritorio y la ISO, y publica `distribucion-2026.2`, una etiqueta aparte de las de las imágenes. Dos cuestiones, resueltas:

* **Tamaño.** La ISO pesa unos 4,6 GB, y GitHub no admite archivos de publicación de más de 2 GiB, aunque sí publicaciones de cualquier tamaño total y sin límite de descargas. Va en trozos de 1900 MiB con la suma SHA-256 de la ISO entera; `cat nueva-somosaguas-2026.2.iso.parte* > nueva-somosaguas-2026.2.iso` los junta y `sha256sum -c` lo comprueba (en Windows, `copy /b`).
* **Privilegios.** Ninguno: `construir.sh` solo necesita Docker, que el *runner* de Actions ya trae.

## Pasos

1. ~~Sacar los pasos comunes del Dockerfile a guiones compartidos~~: ya no hace falta, la distribución parte de la imagen.
2. **Hecho:** ISO en vivo, en BIOS y en UEFI; abre XFCE con el tema de Somosaguas y pasa `verificar_entorno.sh`.
3. **Hecho, salvo en el disco instalado:** PostgreSQL, earlyoom (con avisos en el escritorio), zram, `power-profiles-daemon`, `unattended-upgrades`, los `sysctl`, los parámetros del núcleo (en el menú de arranque en vivo), la tapa y el bloqueo, el montaje de dispositivos y Docker. Falta la línea de GRUB del sistema instalado, que llegará con el instalador.
4. **Hecho:** plantilla de cuenta (`/etc/skel`, con Julia compartido en `/opt`) y Calamares. Falta el *preseed* de los portátiles de la facultad, con el cifrado obligatorio.
5. **Hecho:** construcción en GitHub Actions y publicación en GitHub, en trozos de menos de 2 GiB.
6. Prueba en hardware real: al menos un portátil de la facultad, uno antiguo y uno con pantalla HiDPI, con la batería de pruebas de [Suspensión e hibernación](#suspensión-e-hibernación).

## Preguntas abiertas

* **¿Arranque seguro (Secure Boot) en todos los equipos?** La propuesta es sí en los de la facultad, a costa de la hibernación (ver [Suspensión e hibernación](#suspensión-e-hibernación)). Queda por resolver el caso de NVIDIA: con Secure Boot, sus módulos han de ir firmados con una clave propia inscrita en el firmware (MOK).
* **¿USBGuard en las salas de datos restringidos?** Permitiría solo los dispositivos USB autorizados. Es excesivo para un portátil de alumno, pero puede tener sentido en los equipos que abren microdatos bajo contrato.
* **¿Wayland?** XFCE 4.20 aún lo trata como experimental; X11 es la opción segura para 2026.
