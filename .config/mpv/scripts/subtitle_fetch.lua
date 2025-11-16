local mp = require "mp"
local utils = require "mp.utils"

local config = {
    binary = "subliminal",
    languages = {"fr", "en"},
}

local function show(msg, duration)
    mp.osd_message(msg, duration or 1.5)
end

local function build_args(path)
    local args = {config.binary, "download"}
    for _, lang in ipairs(config.languages) do
        table.insert(args, "-l")
        table.insert(args, lang)
    end
    table.insert(args, "--")
    table.insert(args, path)
    return args
end

local function fetch_subtitles()
    local path = mp.get_property("path")
    if not path then
        show("Impossible d'obtenir le chemin du fichier", 1.5)
        return
    end
    if path:match("^https?://") then
        show("Téléchargement non supporté pour les flux en ligne", 2)
        return
    end
    local args = build_args(path)
    show("Téléchargement des sous-titres…", 1.0)
    mp.command_native_async({
        name = "subprocess",
        playback_only = false,
        capture_stdout = true,
        capture_stderr = true,
        args = args,
    }, function(success, result)
        if not success or result.status ~= 0 then
            local err = (result and result.stderr) or ""
            show("Échec du téléchargement des sous-titres", 2.5)
            if err ~= "" then
                print("[subtitle-fetch] " .. err)
            end
            return
        end
        show("Sous-titres récupérés", 1.2)
        mp.commandv("rescan_external_files")
        mp.commandv("sub-reload")
    end)
end

local function toggle_language_cycle()
    local langs = table.concat(config.languages, ", ")
    show("Langues suivies : " .. langs, 1.2)
end

mp.add_key_binding(nil, "subfetch", fetch_subtitles)
mp.add_key_binding(nil, "subfetch-langs", toggle_language_cycle)
mp.register_script_message("subfetch", fetch_subtitles)
