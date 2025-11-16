local mp = require "mp"

local enabled = true
local pause_delay = 1.5 -- secondes avant mise en pause
local resume_delay = 0.2 -- délai léger pour reprise
local pending_timer
local resume_timer
local paused_by_script = false

local function cancel_timer(timer)
    if timer then
        timer:kill()
    end
    return nil
end

local function set_pause(state)
    mp.set_property_native("pause", state)
end

local function pause_if_needed()
    pending_timer = nil
    if not enabled then
        return
    end
    local focused = mp.get_property_native("focused")
    local pause_state = mp.get_property_native("pause")
    if focused or pause_state then
        return
    end
    set_pause(true)
    paused_by_script = true
    mp.osd_message("Lecture mise en pause (fenêtre inactive)", 1.2)
end

local function resume_if_needed()
    resume_timer = nil
    if not enabled then
        return
    end
    if not paused_by_script then
        return
    end
    paused_by_script = false
    set_pause(false)
    mp.osd_message("Reprise automatique", 0.8)
end

local function on_focus_change(_, focused)
    if not enabled then
        return
    end
    -- cancel timers when focus toggles
    pending_timer = cancel_timer(pending_timer)
    resume_timer = cancel_timer(resume_timer)

    if focused then
        if paused_by_script then
            resume_timer = mp.add_timeout(resume_delay, resume_if_needed)
        end
    else
        pending_timer = mp.add_timeout(pause_delay, pause_if_needed)
    end
end

local function toggle()
    enabled = not enabled
    pending_timer = cancel_timer(pending_timer)
    resume_timer = cancel_timer(resume_timer)
    local msg = enabled and "Auto-pause focus activé" or "Auto-pause focus désactivé"
    mp.osd_message(msg, 1.0)
end

mp.observe_property("focused", "bool", on_focus_change)
mp.add_key_binding(nil, "focuspause-toggle", toggle)
mp.register_script_message("focuspause-toggle", toggle)
