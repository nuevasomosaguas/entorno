-- Guarda cada 30 s dónde va el vídeo, además de al salir: si mpv se cierra de golpe,
-- al volver a abrirlo retoma desde ahí (como mucho, 30 s antes). En silencio: cada
-- guardado escribe «Saving state.» en la terminal, y llenaría la pantalla.
mp.add_periodic_timer(30, function()
    if mp.get_property("path") and not mp.get_property_bool("idle-active") then
        local nivel = mp.get_property("msg-level")
        mp.set_property("msg-level", (nivel ~= "" and nivel .. "," or "") .. "cplayer=warn")
        mp.command("write-watch-later-config")
        mp.set_property("msg-level", nivel)
    end
end)
