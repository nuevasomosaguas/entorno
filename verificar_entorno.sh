#!/usr/bin/env bash
# Comprueba en unos segundos que el entorno calcula: un DAG en Typst, una
# actualización bayesiana en Julia y una consulta con funciones de ventana en SQLite.
set -euo pipefail
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fallo() { echo "Falla: $1." >&2; exit 1; }

# Typst: el DAG de un confusor, Z → X → Y y Z → Y.
cat > "$tmp/dag.typ" <<'EOF'
#set page(width: 120pt, height: 90pt, margin: 0pt)
#let nodo(x, y, t) = place(dx: x - 10pt, dy: y - 10pt,
  circle(radius: 10pt, stroke: 0.6pt)[#set align(center + horizon); #t])
#let flecha(a, b) = place(line(start: a, end: b, stroke: 0.6pt))
#flecha((60pt, 25pt), (25pt, 65pt))
#flecha((60pt, 25pt), (95pt, 65pt))
#flecha((35pt, 70pt), (85pt, 70pt))
#nodo(60pt, 15pt)[$Z$]
#nodo(25pt, 70pt)[$X$]
#nodo(95pt, 70pt)[$Y$]
EOF
typst compile "$tmp/dag.typ" "$tmp/dag.pdf" 2> /dev/null && test -s "$tmp/dag.pdf" \
  || fallo "Typst no compila el DAG"

# Julia: de una Beta(1, 1) y 7 éxitos en 10 ensayos, la media a posteriori es 8/12.
julia --startup-file=no -e '
  θ = range(0, 1; length = 1001)
  post = θ .^ 7 .* (1 .- θ) .^ 3
  post ./= sum(post)
  abs(sum(θ .* post) - 8 / 12) < 1e-4 || exit(1)' \
  || fallo "Julia no reproduce la actualización bayesiana"

# SQLite: suma acumulada y retardo sobre una serie de tres días.
res=$(sqlite3 :memory: "
  WITH serie(dia, x) AS (VALUES (1, 2), (2, 4), (3, 6))
  SELECT SUM(x) OVER (ORDER BY dia) || ',' || LAG(x) OVER (ORDER BY dia)
  FROM serie ORDER BY dia DESC LIMIT 1;")
[ "$res" = "12,4" ] || fallo "SQLite no resuelve las funciones de ventana"

echo "Entorno calibrado. Comience a calcular."
