-- Guarda cada 30 s dónde va el vídeo, además de al salir: si mpv se cierra de golpe,
-- al volver a abrirlo retoma desde ahí (como mucho, 30 s antes).
mp.add_periodic_timer(30, function()
    if mp.get_property("path") and not mp.get_property_bool("idle-active") then
        mp.command("write-watch-later-config")
    end
end)
