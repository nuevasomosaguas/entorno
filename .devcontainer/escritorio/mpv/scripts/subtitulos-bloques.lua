-- Los subtítulos automáticos de YouTube, de dos en dos líneas y quietos, en lugar de
-- rodar línea a línea: al elegir una pista externa (la de YouTube en streaming o el .srt
-- que yt-dlp deja junto al vídeo), subtitulos-bloques la reescribe y la cambia por la
-- nueva. Solo la pista elegida, y una vez; los subtítulos hechos a mano se quedan igual.
local utils = require "mp.utils"

local vistas = {}
local carpeta = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
local creados = {}

local function revisar(_, pista)
    if not pista or not pista.external or not pista["external-filename"] then return end
    local origen = pista["external-filename"]
    if vistas[origen] then return end
    vistas[origen] = true
    local salida = utils.join_path(carpeta, ("mpv-subtitulos-%d-%d.srt"):format(utils.getpid(), #creados + 1))
    mp.command_native_async({
        name = "subprocess", playback_only = false,
        args = {"subtitulos-bloques", origen, salida},
    }, function(_, r)
        if not r or r.status ~= 0 then return end
        creados[#creados + 1] = salida
        vistas[salida] = true
        mp.commandv("sub-add", salida, "select", pista.title or "", pista.lang or "")
        mp.commandv("sub-remove", tostring(pista.id))
    end)
end

mp.observe_property("current-tracks/sub", "native", revisar)
mp.register_event("shutdown", function()
    for _, f in ipairs(creados) do os.remove(f) end
end)
