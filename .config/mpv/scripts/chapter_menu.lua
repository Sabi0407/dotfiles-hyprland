local mp = require "mp"
local assdraw = require "mp.assdraw"

local menu_active = false
local chapters = {}
local cursor = 1
local bindings = {}

local function clear_overlay()
    mp.set_osd_ass(0, 0, "")
end

local function add_binding(key, name, fn, flags)
    mp.add_forced_key_binding(key, name, fn, flags)
    table.insert(bindings, name)
end

local function clear_bindings()
    for _, name in ipairs(bindings) do
        mp.remove_key_binding(name)
    end
    bindings = {}
end

local function render_menu()
    local ass = assdraw.ass_new()
    ass:new_event()
    ass:append("{\\an7\\bord2\\1c&HFFFFFF&\\3c&H000000&}{\\fs42\\b1}Chapitres\\N")
    ass:append("{\\fs20\\b0 Naviguer avec ↑/↓, Entrée pour valider, ESC pour fermer}\\N\\N")
    for i, chapter in ipairs(chapters) do
        local title = chapter.title or string.format("Chapitre %d", i)
        local time = chapter.time or 0
        local line = string.format("[%02d] %s (%.0fs)", i, title, time)
        if i == cursor then
            ass:append("{\\fs30\\b1\\1c&H0FF0FF&}" .. line .. "\\N")
        else
            ass:append("{\\fs26\\b0\\1c&HFFFFFF&}" .. line .. "\\N")
        end
    end
    mp.set_osd_ass(0, 0, ass.text)
end

local function close_menu()
    if not menu_active then
        return
    end
    menu_active = false
    clear_bindings()
    clear_overlay()
end

local function jump_to_cursor()
    local chapter = chapters[cursor]
    if chapter and chapter.time then
        mp.set_property_number("chapter", cursor - 1)
        mp.commandv("seek", tostring(chapter.time), "absolute+exact")
    end
    close_menu()
end

local function move_cursor(delta)
    if #chapters == 0 then
        return
    end
    cursor = cursor + delta
    if cursor < 1 then
        cursor = #chapters
    elseif cursor > #chapters then
        cursor = 1
    end
    render_menu()
end

local function open_menu()
    if menu_active then
        close_menu()
        return
    end
    chapters = mp.get_property_native("chapter-list") or {}
    if #chapters == 0 then
        mp.osd_message("Aucun chapitre disponible", 1.5)
        return
    end
    cursor = mp.get_property_number("chapter", 0) + 1
    if cursor < 1 or cursor > #chapters then
        cursor = 1
    end
    menu_active = true
    render_menu()
    add_binding("UP", "chapmenu-up", function() move_cursor(-1) end, {repeatable = true})
    add_binding("DOWN", "chapmenu-down", function() move_cursor(1) end, {repeatable = true})
    add_binding("ENTER", "chapmenu-enter", jump_to_cursor)
    add_binding("BS", "chapmenu-back", close_menu)
    add_binding("ESC", "chapmenu-close", close_menu)
end

mp.add_key_binding(nil, "chapter-menu", open_menu)
