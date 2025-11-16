local mp = require "mp"

local pip_active = false
local previous = {}

local tracked_props = {
    "ontop",
    "border",
    "window-scale",
    "window-maximized",
    "fullscreen",
    "window-pos"
}

local config = {
    scale = 0.28,
    position = "-24:32", -- x:y (négatif = depuis la droite/bas)
    ontop = "yes",
    border = "no",
    apply_delay = 0.06 -- secondes pour laisser mpv sortir du plein écran
}

local function safe_get(prop)
    local ok, value = pcall(mp.get_property_native, prop)
    if ok then
        return value
    end
    return nil
end

local function format_value(value)
    if type(value) == "boolean" then
        return value and "yes" or "no"
    elseif type(value) == "number" then
        return string.format("%0.4f", value)
    end
    return value
end

local function safe_set(prop, value)
    if value == nil then
        return
    end
    local formatted = format_value(value)
    local ok = pcall(mp.commandv, "no-osd", "set", prop, formatted)
    if not ok then
        pcall(mp.set_property_native, prop, value)
    end
end

local function save_state()
    previous = {}
    for _, prop in ipairs(tracked_props) do
        previous[prop] = safe_get(prop)
    end
end

local function restore_state()
    for prop, value in pairs(previous) do
        safe_set(prop, value)
    end
    previous = {}
end

local function enable_pip()
    save_state()
    safe_set("fullscreen", false)
    safe_set("window-maximized", false)
    safe_set("ontop", config.ontop)
    safe_set("border", config.border)
    local function finalize()
        safe_set("window-scale", config.scale)
        if config.position then
            safe_set("window-pos", config.position)
        end
        pip_active = true
        mp.osd_message("Picture-in-Picture activé", 1.5)
    end
    mp.add_timeout(config.apply_delay or 0.05, finalize)
end

local function disable_pip()
    restore_state()
    pip_active = false
    mp.osd_message("Picture-in-Picture désactivé", 1.5)
end

local function toggle_pip()
    if pip_active then
        disable_pip()
    else
        enable_pip()
    end
end

mp.add_key_binding(nil, "toggle-pip", toggle_pip)
mp.register_script_message("toggle-pip", toggle_pip)
