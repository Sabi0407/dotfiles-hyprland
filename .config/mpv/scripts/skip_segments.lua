local mp = require "mp"

-- Règles personnalisées : adapter/ajouter vos séries ici.
-- pattern = motif Lua appliqué au chemin (mettre en minuscules !)
local rules = {
    { pattern = "one_piece", intro = 90, outro = 130 },
    { pattern = "demon_slayer", intro = 70, outro = 120 },
    { pattern = "myhero", intro = 75, outro = 90 },
}

local fallback = { intro = 0, outro = 0 }

local enabled = true
local active_rule = nil
local intro_skipped = false
local outro_skipped = false

local function match_rule(path)
    if not path then
        return nil
    end
    local lower = path:lower()
    for _, rule in ipairs(rules) do
        if lower:find(rule.pattern, 1, true) then
            return rule
        end
    end
    if (fallback.intro or 0) > 0 or (fallback.outro or 0) > 0 then
        return fallback
    end
    return nil
end

local function format_time(seconds)
    if not seconds or seconds <= 0 then
        return "0s"
    end
    return string.format("%ds", math.floor(seconds + 0.5))
end

local function announce(rule)
    if not rule then
        return
    end
    local intro = rule.intro or 0
    local outro = rule.outro or 0
    local msg = string.format("Skip génériques : intro %s / outro %s", format_time(intro), format_time(outro))
    mp.osd_message(msg, 2.0)
end

local function on_file_loaded()
    intro_skipped = false
    outro_skipped = false
    local path = mp.get_property("path")
    active_rule = match_rule(path)
    if enabled and active_rule then
        announce(active_rule)
    end
end

local function skip_intro()
    if not active_rule or intro_skipped or not enabled then
        return
    end
    local intro_end = active_rule.intro or 0
    if intro_end <= 0 then
        return
    end
    local pos = mp.get_property_number("time-pos", 0)
    if not pos or pos <= 0 then
        return
    end
    if pos >= intro_end - 0.5 then
        return
    end
    intro_skipped = true
    mp.commandv("seek", tostring(intro_end), "absolute+exact")
    mp.osd_message(string.format("Générique sauté → %ds", intro_end), 1.0)
end

local function skip_outro()
    if not active_rule or outro_skipped or not enabled then
        return
    end
    local outro_len = active_rule.outro or 0
    if outro_len <= 0 then
        return
    end
    local remaining = mp.get_property_number("time-remaining", 0)
    if not remaining or remaining > outro_len then
        return
    end
    local duration = mp.get_property_number("duration", 0)
    if not duration or duration <= 0 then
        return
    end
    outro_skipped = true
    local target = math.max(duration - 1, 0)
    mp.commandv("seek", tostring(target), "absolute+exact")
    mp.osd_message("Fin de générique ignorée", 1.0)
end

mp.register_event("file-loaded", on_file_loaded)
mp.observe_property("time-pos", "number", function()
    if intro_skipped then
        return
    end
    skip_intro()
end)
mp.observe_property("time-remaining", "number", function()
    if outro_skipped then
        return
    end
    skip_outro()
end)

local function toggle()
    enabled = not enabled
    local msg = enabled and "Skip génériques activé" or "Skip génériques désactivé"
    mp.osd_message(msg, 1.2)
end

mp.add_key_binding(nil, "skipsegments-toggle", toggle)
mp.register_script_message("skipsegments-toggle", toggle)
