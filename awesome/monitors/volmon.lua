-- volmon.lua
-- an awesome wm plugin that uses pactl subscribe to watch for changes to the default sink state
-- this allows the volume widget to update as volume changes instead of relying on a timer
local awful = require("awful")

-- tracking for registered widgets
local registered_widgets = {}

local volmon = {}

-- get the volume info, then run the callback
local cmd = "DEFAULT_SINK=$(pactl get-default-sink); "
            .. "pactl get-sink-mute $DEFAULT_SINK; pactl get-sink-volume $DEFAULT_SINK"
local with_volume_info = function (callback)
    awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr, reason, exit_code)
        local mute, vol = stdout:match("Mute: (%a+).*%s(%d+)%%.*")
        callback(tonumber(vol), mute == "yes")
    end)
end

local update_all_widgets = function ()
    with_volume_info(function (mute, vol)
        for widget, format in pairs(registered_widgets) do
            widget:set_text(format(mute, vol))
        end
    end)
end

-- register a widget to be updated by volmon
volmon.register = function (w, format)
    registered_widgets[w] = format or "%s"
end

-- call this to start listening
volmon.start = function ()
    -- monitor pactl for change events and update whenever one happens
    awful.spawn.with_line_callback("pactl subscribe", {
        stdout = function (line)
            -- this will trigger on change events for *any* sink,
            -- but checking it's the default one requires an extra call so i'd rather not
            if not (line:find("Event 'change' on sink #") == nil) then
                update_all_widgets()
            end
        end
    })

    -- gotta run it one time to set its initial value
    with_volume_info(function (mute, vol)
        update_all_widgets()
    end)
end

-- volume control functions for convenience
volmon.change_volume = function (percent)
    awful.spawn.with_shell("pactl set-sink-volume $(pactl get-default-sink) " .. percent)
end

volmon.toggle_mute = function ()
    awful.spawn.with_shell("pactl set-sink-mute $(pactl get-default-sink) toggle")
end

return volmon
