-- battery widget, only used on doubleslap
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
-- has the low power warning been shown yet?
local low_power_warning_shown = false
vicious.register(bat_widget_info, vicious.widgets.bat, function (widget, args)
    -- /!\ GOOD PROGRAMMER ALERT /!\
    -- when power drops below 15%, spawn a notification warning me about it
    -- todo: move this literally anywhere else cos it sure as hell shouldn't be tacked on here
    if args[1] == "-" then
        if args[2] <= 15 and not low_power_warning_shown then
            low_power_warning_shown = true
            naughty.notify({ preset = naughty.config.presets.critical,
                             title = "Warning! Battery Low!",
                             text = args[2] .. "% power remaining" })
        end
    else
        low_power_warning_shown = false
    end
    local icon = args[1] == "-" and "🔋" or "🔌"
    return icon .. " " .. args[2] .. "%"
end, 30, "BAT0")

return bat_widget
