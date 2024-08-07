-- battery widget, only used on doubleslap (for now)
local vicious = require("vicious")
local wibox = require("wibox")
local naughty = require("naughty")

local bat_widget_info = wibox.widget.textbox()
local bat_widget = wibox.widget {
    {
        widget = bat_widget_info
    },
    widget = wibox.container.margin,
    bottom = 1
}

-- value to reset power_at_last_warning to on start and when charging
local INITIAL_POWER = 100
-- give low power warnings at 25%, 15% and 10% battery remaining
-- TODO: i feel like i could probably do something smart with tables to avoid the big if-else below...
local FIRST_THRESHOLD = 25
local SECOND_THRESHOLD = 15
local THIRD_THRESHOLD = 10

-- returns true if it's time to show a low battery warning
-- TODO: update existing notification if it hasn't been dismissed?
local power_at_last_warning = INITIAL_POWER
local function should_warn(bat_power)
    -- if the battery is discharging, check if the power has changed since the last warning
    if bat_power ~= power_at_last_warning then
        -- if it's dropped below a threshold, it's time to show the warning again
        if bat_power <= FIRST_THRESHOLD and power_at_last_warning > FIRST_THRESHOLD then
            return true
        elseif bat_power <= SECOND_THRESHOLD and power_at_last_warning > SECOND_THRESHOLD then
            return true
        -- don't check if we already warned here, just warn on every integer change
        elseif bat_power <= THIRD_THRESHOLD then
            return true
        end
    end
    return false
end

-- spawn a warning notification when battery power is low
local function maybe_show_low_power_warning(bat_state, bat_power)
    if bat_state ~= "-" then
        -- if the battery is charging reset the power at last warning to maximum
        power_at_last_warning = INITIAL_POWER
    else
        -- if it's warning time, record the current power and fire the warning
        if should_warn(bat_power) then
            power_at_last_warning = bat_power
            naughty.notify({ preset = naughty.config.presets.critical,
                             title = "Warning! Battery Low!",
                             text = bat_power .. "% power remaining" })
        end
    end
end

vicious.register(bat_widget_info, vicious.widgets.bat, function (widget, args)
    -- TODO: this really shouldn't be called inside the widget update function, but where else can i call it?
    -- i considered using vicious.call but it's not really any different than just doing this afaik
    maybe_show_low_power_warning(args[1], args[2])
    local icon = args[1] == "-" and "🔋" or "🔌"
    return icon .. " " .. args[2] .. "%"
end, 29, "BAT0")

return bat_widget
