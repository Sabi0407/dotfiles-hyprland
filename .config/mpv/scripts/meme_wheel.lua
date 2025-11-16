local mp = require "mp"
local assdraw = require "mp.assdraw"

local wheel_active = false
local bindings = {}

local function clear_osd()
    mp.set_osd_ass(0, 0, "")
end

local function add_binding(key, name, fn)
    mp.add_forced_key_binding(key, name, fn)
    bindings[#bindings + 1] = name
end

local function clear_bindings()
    for _, name in ipairs(bindings) do
        mp.remove_key_binding(name)
    end
    bindings = {}
end

local function hide_wheel()
    if not wheel_active then
        return
    end
    wheel_active = false
    clear_bindings()
    clear_osd()
end

local function show_text(text, duration)
    mp.commandv("show-text", text, tostring(duration or 1500), 0)
end

local function with_restore(delay, fn)
    return mp.add_timeout(delay, fn)
end

local function action_freeze()
    mp.set_property_bool("pause", true)
    show_text("ＴＯ ＢＥ ＣＯＮＴＩＮＵＥＤ…", 2500)
end

local function action_dramatic_zoom()
    local zoom = mp.get_property_number("video-zoom", 0) or 0
    local panx = mp.get_property_number("video-pan-x", 0) or 0
    local pany = mp.get_property_number("video-pan-y", 0) or 0

    mp.set_property_number("video-zoom", zoom + 0.9)
    mp.set_property_number("video-pan-x", panx + 0.18)
    mp.set_property_number("video-pan-y", pany - 0.12)
    show_text("ZOOM DRAMATIQUE !!", 900)

    with_restore(1.2, function()
        mp.set_property_number("video-zoom", zoom)
        mp.set_property_number("video-pan-x", panx)
        mp.set_property_number("video-pan-y", pany)
    end)
end

local function action_vhs_noise()
    local filter_label = "@meme_vhs"
    mp.commandv("vf", "add", filter_label .. ":noise=alls=35:allf=t,format=yuv420p")
    show_text("MODE VHS 🌈", 1000)
    with_restore(2.0, function()
        mp.commandv("vf", "del", filter_label)
    end)
end

local function action_replay()
    mp.commandv("seek", "-3", "relative+exact")
    local previous_speed = mp.get_property_number("speed", 1) or 1
    mp.set_property_number("speed", 0.55)
    show_text("INSTANT REPLAY 🔄", 1200)
    with_restore(3.5, function()
        mp.set_property_number("speed", previous_speed)
    end)
end

local actions = {
    { key = "1", name = "Freeze Frame", desc = "Pause + TO BE CONTINUED", run = action_freeze },
    { key = "2", name = "Zoom dramatique", desc = "Zoom + pan temporaire", run = action_dramatic_zoom },
    { key = "3", name = "VHS Glitch", desc = "Filtre bruit + couleurs", run = action_vhs_noise },
    { key = "4", name = "Instant Replay", desc = "Revenir 3s en vitesse lente", run = action_replay },
}

local function perform_action(idx)
    local action = actions[idx]
    if not action then
        return
    end
    hide_wheel()
    action.run()
end

local function render_wheel()
    local ass = assdraw.ass_new()
    ass:new_event()
    ass:append("{\\an7\\bord2\\1c&HFFFFFF&\\3c&H000000&}{\\fs44\\b1}Meme Wheel\\N")
    ass:append("{\\fs20\\b0 Appuie sur 1‑4 pour déclencher un meme}\\N\\N")
    for i, action in ipairs(actions) do
        ass:append(string.format("{\\fs32\\b1}%s. %s\\N", action.key, action.name))
        ass:append(string.format("{\\fs20\\b0}%s\\N\\N", action.desc))
    end
    ass:append("{\\fs18\\b0}[ESC] pour annuler")
    mp.set_osd_ass(0, 0, ass.text)
end

local function show_wheel()
    if wheel_active then
        hide_wheel()
        return
    end
    wheel_active = true
    render_wheel()
    for idx, action in ipairs(actions) do
        add_binding(action.key, "meme_wheel_select_" .. action.key, function()
            perform_action(idx)
        end)
    end
    add_binding("ESC", "meme_wheel_cancel", hide_wheel)
end

mp.add_key_binding(nil, "meme-wheel", show_wheel)
