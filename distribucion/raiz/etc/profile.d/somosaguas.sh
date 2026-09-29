# Lo que el contenedor pone con ENV: las herramientas del alumno (uv tool), TinyTeX y el
# Python de la imagen; Julia, con el depósito compartido detrás del de la cuenta. Y la
# cuenta al día con la plantilla (somosaguas-cuenta).
export PATH="$HOME/.local/bin:$HOME/.TinyTeX/bin/x86_64-linux:/opt/venv/bin:$PATH"
export JULIA_DEPOT_PATH=":/opt/julia/depot"
somosaguas-cuenta 2> /dev/null || true
