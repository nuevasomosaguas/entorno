-- Las listas, también en streaming: cada vídeo ya vuelve a su minuto (save-position-on-quit),
-- pero una lista («mpv URL-de-la-lista» o una carpeta de ~/Cursos) empezaría otra vez por
-- la primera clase. Esto apunta en ~~state/listas.json por qué clase va cada lista y, al
-- abrirla de nuevo, salta a esa clase, que retoma en su minuto. Una lista de la web deja
-- además su ficha en ~/Cursos (guardar-curso): curso.m3u, sin los vídeos.
local utils = require "mp.utils"

local archivo = mp.command_native({"expand-path", "~~state/listas.json"})
local listas, abiertas = {}, {}
local f = io.open(archivo)
if f then listas = utils.parse_json(f:read("*a")) or {}; f:close() end

-- Una carpeta o un archivo, con su ruta completa y sin la barra final: la misma lista
-- abierta desde otra carpeta («mpv Curso/» o «mpv ~/Cursos/Curso») es la misma.
local function absoluta(ruta)
    if not ruta or ruta == "" or ruta:match("^%a[%w+.-]*://") then return ruta end
    return (utils.join_path(mp.get_property("working-directory"), ruta):gsub("(.)/$", "%1"))
end

-- La lista por la que se la reconoce: la ficha de un curso (curso.m3u) es su dirección en
-- la web, la de su línea «# Fuente:», y así las dos siguen por la misma clase.
local function clave(ruta)
    ruta = absoluta(ruta)
    local g = ruta and ruta:match("%.m3u8?$") and io.open(ruta)
    if not g then return ruta end
    for _ = 1, 5 do
        local linea = g:read("*l")
        local fuente = linea and linea:match("^# Fuente: (%S+)")
        if fuente or not linea then g:close(); return fuente or ruta end
    end
    g:close()
    return ruta
end

-- Al empezar la primera clase de una lista, la que tocaba; si es de la web, su ficha.
mp.register_event("start-file", function()
    local lista = clave(mp.get_property("playlist-path"))
    if not lista or lista == "" or abiertas[lista] then return end
    abiertas[lista] = true
    if lista:match("^https?://") then
        -- Al acabar, en pantalla: dónde quedó la ficha o por qué no se pudo (sin conexión,
        -- yt-dlp desfasado…); si no, el fallo pasaría sin que nadie lo viera.
        mp.command_native_async({name = "subprocess", args = {"guardar-curso", lista}, playback_only = false,
                                 capture_stdout = true, capture_stderr = true}, function(_, r)
            if r and r.status == 0 and r.stdout ~= "" then
                local ficha, casa = r.stdout:gsub("\n$", ""), os.getenv("HOME") or ""
                if casa ~= "" and ficha:sub(1, #casa) == casa then ficha = "~" .. ficha:sub(#casa + 1) end
                mp.osd_message("Ficha del curso: " .. ficha, 4)
            elseif r and r.status ~= 0 then
                local motivo = (r.stderr or ""):gsub("%s+$", ""):match("[^\n]*$")
                mp.msg.warn(r.stderr or "")
                mp.osd_message("No se pudo guardar la ficha del curso: " .. (motivo ~= "" and motivo or "guardar-curso falló"), 6)
            end
        end)
    end
    local clase = listas[lista]
    if not clase or clase == absoluta(mp.get_property("path")) then return end
    for i = 0, mp.get_property_number("playlist-count", 0) - 1 do
        if absoluta(mp.get_property(("playlist/%d/filename"):format(i))) == clase then
            mp.set_property_number("playlist-pos", i)
            return
        end
    end
end)

-- Cada clase que llega a abrirse queda como la última de su lista.
mp.register_event("file-loaded", function()
    local lista = clave(mp.get_property("playlist-path"))
    if not lista or lista == "" then return end
    listas[lista] = absoluta(mp.get_property("path"))
    mp.command_native({name = "subprocess", args = {"mkdir", "-p", archivo:match("^(.*)/")}, playback_only = false})
    local g = io.open(archivo, "w")
    if g then g:write(utils.format_json(listas)); g:close() end
end)
