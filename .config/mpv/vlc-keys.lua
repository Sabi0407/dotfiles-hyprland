-- Script Lua pour mpv reproduisant les raccourcis clavier de VLC
-- Placez ce fichier dans ~/.config/mpv/scripts/ ou ~/.config/mpv/

-- Fonction pour afficher des messages à l'écran
local function show_message(text, duration)
    mp.osd_message(text, duration or 2)
end

-- Raccourcis de lecture/pause
mp.add_key_binding("SPACE", "toggle-pause", function()
    mp.commandv("cycle", "pause")
    if mp.get_property_bool("pause") then
        show_message("⏸️ Pause")
    else
        show_message("▶️ Lecture")
    end
end)

-- Arrêt
mp.add_key_binding("s", "stop", function()
    mp.commandv("stop")
    show_message("⏹️ Arrêt")
end)

-- Navigation temporelle
mp.add_key_binding("RIGHT", "seek-forward-10", function()
    mp.commandv("seek", "10")
    show_message("⏩ +10s")
end)

mp.add_key_binding("LEFT", "seek-backward-10", function()
    mp.commandv("seek", "-10")
    show_message("⏪ -10s")
end)

mp.add_key_binding("UP", "seek-forward-60", function()
    mp.commandv("seek", "60")
    show_message("⏩ +1min")
end)

mp.add_key_binding("DOWN", "seek-backward-60", function()
    mp.commandv("seek", "-60")
    show_message("⏪ -1min")
end)

-- Navigation rapide (Ctrl + flèches)
mp.add_key_binding("Ctrl+RIGHT", "seek-forward-300", function()
    mp.commandv("seek", "300")
    show_message("⏩ +5min")
end)

mp.add_key_binding("Ctrl+LEFT", "seek-backward-300", function()
    mp.commandv("seek", "-300")
    show_message("⏪ -5min")
end)

-- Contrôle du volume
mp.add_key_binding("Ctrl+UP", "volume-up", function()
    mp.commandv("add", "volume", "5")
    local volume = mp.get_property_number("volume")
    show_message("🔊 Volume: " .. math.floor(volume) .. "%")
end)

mp.add_key_binding("Ctrl+DOWN", "volume-down", function()
    mp.commandv("add", "volume", "-5")
    local volume = mp.get_property_number("volume")
    show_message("🔉 Volume: " .. math.floor(volume) .. "%")
end)

-- Mute/Unmute
mp.add_key_binding("m", "mute", function()
    mp.commandv("cycle", "mute")
    if mp.get_property_bool("mute") then
        show_message("🔇 Son coupé")
    else
        show_message("🔊 Son activé")
    end
end)

-- Plein écran
mp.add_key_binding("f", "fullscreen", function()
    mp.commandv("cycle", "fullscreen")
    if mp.get_property_bool("fullscreen") then
        show_message("🖥️ Plein écran")
    else
        show_message("🪟 Fenêtré")
    end
end)

-- Vitesse de lecture
mp.add_key_binding("=", "speed-up", function()
    mp.commandv("multiply", "speed", "1.1")
    local speed = mp.get_property_number("speed")
    show_message("⚡ Vitesse: " .. string.format("%.1f", speed) .. "x")
end)

mp.add_key_binding("-", "speed-down", function()
    mp.commandv("multiply", "speed", "0.9")
    local speed = mp.get_property_number("speed")
    show_message("🐌 Vitesse: " .. string.format("%.1f", speed) .. "x")
end)

mp.add_key_binding("1", "speed-normal", function()
    mp.set_property("speed", 1.0)
    show_message("⚡ Vitesse normale: 1.0x")
end)

-- Navigation dans la playlist
mp.add_key_binding("n", "playlist-next", function()
    mp.commandv("playlist-next")
    show_message("⏭️ Suivant")
end)

mp.add_key_binding("p", "playlist-prev", function()
    mp.commandv("playlist-prev")
    show_message("⏮️ Précédent")
end)

-- Sous-titres
mp.add_key_binding("v", "cycle-sub", function()
    mp.commandv("cycle", "sub")
    local sub_id = mp.get_property("sid")
    if sub_id == "no" or sub_id == nil then
        show_message("📝 Sous-titres: Désactivés")
    else
        show_message("📝 Sous-titres: Piste " .. sub_id)
    end
end)

-- Pistes audio
mp.add_key_binding("b", "cycle-audio", function()
    mp.commandv("cycle", "aid")
    local aid = mp.get_property("aid")
    if aid == "no" or aid == nil then
        show_message("🔊 Audio: Désactivé")
    else
        show_message("🔊 Audio: Piste " .. aid)
    end
end)

-- Informations sur le fichier
mp.add_key_binding("i", "show-info", function()
    local filename = mp.get_property("filename")
    local duration = mp.get_property("duration")
    local position = mp.get_property("time-pos")
    
    if filename and duration and position then
        local info = string.format("📁 %s\n⏱️ %s / %s", 
            filename,
            mp.format_time(position),
            mp.format_time(duration))
        show_message(info, 4)
    end
end)

-- Capture d'écran
mp.add_key_binding("Shift+s", "screenshot", function()
    mp.commandv("screenshot")
    show_message("📸 Capture d'écran sauvegardée")
end)

-- Rotation de l'image
mp.add_key_binding("r", "rotate", function()
    local rotation = mp.get_property_number("video-rotate") or 0
    rotation = (rotation + 90) % 360
    mp.set_property("video-rotate", rotation)
    show_message("🔄 Rotation: " .. rotation .. "°")
end)

-- Aspect ratio
mp.add_key_binding("a", "cycle-aspect", function()
    mp.commandv("cycle-values", "video-aspect-override", "16:9", "4:3", "2.35:1", "-1")
    local aspect = mp.get_property("video-aspect-override")
    if aspect == "-1" then
        show_message("📐 Aspect: Original")
    else
        show_message("📐 Aspect: " .. aspect)
    end
end)

-- Zoom
mp.add_key_binding("z", "zoom-in", function()
    mp.commandv("add", "video-zoom", "0.1")
    local zoom = mp.get_property_number("video-zoom")
    show_message("🔍 Zoom: " .. string.format("%.1f", zoom))
end)

mp.add_key_binding("Shift+z", "zoom-out", function()
    mp.commandv("add", "video-zoom", "-0.1")
    local zoom = mp.get_property_number("video-zoom")
    show_message("🔍 Zoom: " .. string.format("%.1f", zoom))
end)

-- Reset zoom
mp.add_key_binding("Ctrl+z", "zoom-reset", function()
    mp.set_property("video-zoom", 0)
    mp.set_property("video-pan-x", 0)
    mp.set_property("video-pan-y", 0)
    show_message("🔍 Zoom réinitialisé")
end)

-- Quitter
mp.add_key_binding("q", "quit", function()
    mp.commandv("quit")
end)

mp.add_key_binding("Ctrl+q", "quit-watch-later", function()
    mp.commandv("quit-watch-later")
    show_message("💾 Position sauvegardée")
end)

-- Message de bienvenue
mp.register_event("file-loaded", function()
    show_message("🎬 Script VLC-keys chargé !", 3)
end)

print("Script VLC-keys pour mpv chargé avec succès !")
