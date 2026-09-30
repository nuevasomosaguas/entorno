-- n: el momento del vídeo, al portapapeles, para las notas: un enlace de Markdown que se
-- pega en Obsidian, [Título, 12:30](https://www.youtube.com/watch?v=…&t=750s). En un vídeo
-- de la web, el enlace lo abre en ese minuto; en uno descargado apunta al archivo, que
-- mpv abre donde se dejó, y el minuto queda en el texto.
local utils = require "mp.utils"

mp.add_key_binding("n", "copiar-momento", function()
    local ruta = mp.get_property("path")
    if not ruta then return end
    local t = math.floor(mp.get_property_number("time-pos", 0))
    local minuto = ("%d:%02d"):format(math.floor(t / 60), t % 60)
    if t >= 3600 then minuto = ("%d:%02d:%02d"):format(math.floor(t / 3600), math.floor(t / 60) % 60, t % 60) end
    local enlace
    if ruta:match("^%a[%w+.-]*://") then
        enlace = ruta .. (ruta:find("?", 1, true) and "&" or "?") .. "t=" .. t .. "s"
    else
        enlace = "file://" .. utils.join_path(mp.get_property("working-directory"), ruta):gsub(" ", "%%20")
    end
    local titulo = mp.get_property("media-title", ""):gsub("[%[%]]", "")
    local texto = ("[%s, %s](%s)"):format(titulo, minuto, enlace)
    mp.command_native({name = "subprocess", args = {"xclip", "-selection", "clipboard"},
                       stdin_data = texto, playback_only = false})
    mp.osd_message("Copiado para las notas: " .. titulo .. ", " .. minuto)
end)
