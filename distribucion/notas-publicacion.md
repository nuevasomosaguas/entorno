La distribución de la Nueva Somosaguas, **@VERSION@**: Debian 13 con el entorno completo, para arrancar en vivo desde un USB o un DVD, en BIOS y en UEFI.

La ISO va en trozos porque GitHub no admite archivos de más de 2 GiB. Se juntan y se comprueban así:

```bash
cat nueva-somosaguas-@VERSION@.iso.parte* > nueva-somosaguas-@VERSION@.iso
sha256sum -c nueva-somosaguas-@VERSION@.iso.sha256
```

En Windows: `copy /b nueva-somosaguas-@VERSION@.iso.parte* nueva-somosaguas-@VERSION@.iso`, y `certutil -hashfile nueva-somosaguas-@VERSION@.iso SHA256` para la suma. Luego se graba en un USB con `dd`, balenaEtcher o Rufus (en modo DD).

La sesión en vivo entra sola con el usuario `alumno`; su contraseña, para desbloquear la pantalla, es `somosaguas`. Construida desde el commit @COMMIT@: la receta es [`distribucion/`](https://github.com/nuevasomosaguas/entorno/tree/@COMMIT@/distribucion).
