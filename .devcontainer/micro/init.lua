-- Fragmentos para Markdown y Quarto. Ctrl+Alt+I: un bloque de código, con el cursor
-- tras las comillas para escribir el lenguaje. Ctrl+Alt+Y: la cabecera YAML, siempre
-- al principio del archivo, con el cursor en el título. Ctrl+I es Tab para la terminal,
-- así que Ctrl+Alt+I llega como Alt+Tab: bindings.json enlaza las dos. En otros archivos
-- no hacen nada.
local buffer = import("micro/buffer")

local function markdown(bp)
    return bp.Buf:FileType() == "markdown" or bp.Buf.Path:match("%.qmd$") ~= nil
end

local function insertar(bp, loc, texto, fila, col)
    bp.Buf:Insert(loc, texto)
    bp.Cursor:GotoLoc(buffer.Loc(col, loc.Y + fila))
    bp:Relocate()
    return true
end

function codigo(bp)
    if not markdown(bp) then return false end
    local c = bp.Cursor
    return insertar(bp, buffer.Loc(c.X, c.Y), "```\n\n```\n", 0, c.X + 3)
end

function cabecera(bp)
    if not markdown(bp) then return false end
    local yaml = '---\ntitle: ""\nauthor: ""\ndate: ' .. os.date("%Y-%m-%d") .. '\nlang: es\n---\n\n'
    return insertar(bp, buffer.Loc(0, 0), yaml, 1, 8)
end
