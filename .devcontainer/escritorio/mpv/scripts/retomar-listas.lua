-- Las listas, también en streaming: cada vídeo ya vuelve a su minuto (save-position-on-quit),
-- pero una lista («mpv URL-de-la-lista» o una carpeta de ~/Cursos) empezaría otra vez por
-- la primera clase. Esto apunta en ~~state/listas.json por qué clase va cada lista y, al
-- abrirla de nuevo, salta a esa clase, que retoma en su minuto.
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

-- Al empezar la primera clase de una lista, la que tocaba.
mp.register_event("start-file", function()
    local lista = absoluta(mp.get_property("playlist-path"))
    if not lista or lista == "" or abiertas[lista] then return end
    abiertas[lista] = true
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
    local lista = absoluta(mp.get_property("playlist-path"))
    if not lista or lista == "" then return end
    listas[lista] = absoluta(mp.get_property("path"))
    mp.command_native({name = "subprocess", args = {"mkdir", "-p", archivo:match("^(.*)/")}, playback_only = false})
    local g = io.open(archivo, "w")
    if g then g:write(utils.format_json(listas)); g:close() end
end)
