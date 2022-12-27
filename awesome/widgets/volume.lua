-- volume widget
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local volmon = require("monitors.volmon")

local vol_widget_info = wibox.widget.textbox()
local vol_widget = wibox.widget {
    {
        widget = vol_widget_info
    },
    widget = wibox.container.margin,
    bottom = 1
}

volmon.register(vol_widget_info, function(vol, mute)
    local icon = mute and "🔇" or "🔊"
    return icon .. " " .. vol .. "%"
end)

volmon.start()

vol_widget:buttons(gears.table.join(
    awful.button({ }, 1, function()
        awful.spawn("pavucontrol")
    end),
    awful.button({ }, 3, function()
        volmon.toggle_mute()
    end),
    awful.button({ }, 4, function()
        volmon.change_volume("+5%")
    end),
    awful.button({ }, 5, function()
        volmon.change_volume("-5%")
    end)
))

return vol_widget
