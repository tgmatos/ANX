-- segment_request I must handle: cursor, clipboard
-- Events I must handle: registered, preroll, ident, segment_request (cursor, clipboard), message, resized, bridge-x11
resized = 0
local function cursor_event_handler(source, status)
    if status.kind == "registered" then
        mouse_hide()
    elseif status.kind == "resized" then
        resize_image(source, status.width, status.height)
        show_image(source)
    elseif status.kind == "terminated" then
        delete_image(source)
    elseif status.kind == "viewport" then
        move_image(source, status.rel_x, status.rel_y)
        -- show_image(source)
    elseif status.kind == "cursorhint" then
        print("Cursor hinted")
        mouse_switch_cursor(status.cursor)
    else
        for k,v in pairs(status) do
            print(k,v)
        end
    end
end

local function x11_event_handler(x11source, x11status)
    if x11status.kind == "registered" then
        print("registered")
    elseif x11status.kind == "resized" then
        resize_image(x11source, x11status.width, x11status.height)
        show_image(x11source)
    elseif x11status.kind == "terminated" then
        delete_image(x11source)
    elseif x11status.kind == "viewport" then
        -- hide_image(x11source)
        move_image(x11source, x11status.rel_x, x11status.rel_y)
    else
        print("x11 source:", x11status.kind)
    end
end

function client_event_handler(source, status)
    if status.kind == "registered" then
    elseif status.kind == "preroll" then
        target_displayhint(source, VRESW, VRESH, TD_HINT_IGNORE, {ppcm = VPPCM})
        resize_image(source, VRESW, VRESH)
        show_image(source)
    elseif status.kind == "ident" then
    elseif status.kind == "segment_request" then
        if status.segkind == "cursor" then
            local cursor = accept_target(
                status.width,
                status.height,
                cursor_event_handler)

            if valid_vid(cursor) then
                show_image(cursor)
            end
        elseif status.segkind == "bridge-x11" then
            accept_target(source, status.width, status.height, x11_event_handler)
        else
            print(string.format("Segkind: %s", status.segkind))
        end
    elseif status.kind == "message" then
        print(string.format("Name: %s", status.message))
    elseif status.kind == "resized" then
        resize_image(source, status.width, status.height)
    elseif status.kind == "terminated" then
        shutdown()
    else
        print(status.kind)
    end

    if resized == 0 then
        target_displayhint(source, VRESW, VRESH, TD_HINT_IGNORE, WORLDID)
        resized = 1
    end
    XARCAN = source
end

function anx_display_state(status)
    resize_video_canvas(VRESW, VRESH)
    if XARCAN then
        target_displayhint(XARCAN, VRESW, VRESH, TD_HINT_IGNORE, WORLDID)
        resize_image(XARCAN, VRESW, VRESH)
    end
    mouse_querytarget(WORLDID)
end

function anx_clock_pulse()
    mouse_tick(1)
    KEYBOARD:tick()
end

function anx_input(input)
    if not input.keyboard and not input.mouse then
        return
    end

    if input.mouse then
        -- For moviment inputs, translate it to x11
        if input.kind == "analog" then
            local x = input.samples[2]
            local y = input.samples[1]

            translated_input = {
                kind = "analog",
                devid = input.devid or 0,
                subid = input.subid or 2,
                mouse = true,
                samples = {x, 0, y, 0}
            }
            if XARCAN then
                target_input(XARCAN, translated_input)
            end
        else
            -- For button clicks, forward as-is
            if XARCAN then
                target_input(XARCAN, input)
            end
        end
        mouse_iotbl_input(input)
    elseif input.translated then
        KEYBOARD:patch(input)
        if XARCAN then
            target_input(XARCAN, input)
        end
    end
end


function anx(args)
    system_load("builtin/mouse.lua")()
    system_load("builtin/debug.lua")()
    system_load("builtin/string.lua")()
    system_load("builtin/table.lua")()

    KEYBOARD = system_load("builtin/keyboard.lua")()
    KEYBOARD:kbd_repeat()
    KEYBOARD:load_keymap()

    mouse_setup(load_image('cursor.png'), 65535, 1, true, false)
    for _, v in ipairs(list_targets("autorun")) do
        if v == "xarcan" then
            vid = launch_target(v, LAUNCH_INTERNAL, client_event_handler)
        end
    end
end
