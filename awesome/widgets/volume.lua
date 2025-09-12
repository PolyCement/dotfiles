-- volume widget
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local volmon = require("monitors.volmon")
local dpi = require("beautiful.xresources").apply_dpi

local vol_widget_icon = wibox.widget.textbox()
local vol_widget_info = wibox.widget.textbox()
local vol_widget = wibox.widget {
    {
        {
            {
                widget = vol_widget_icon,
                font = "Material Symbols Sharp 11"
            },
            widget = wibox.container.margin,
            left = dpi(-2),
            right = dpi(2),
            bottom = dpi(1)
        },
        widget = wibox.container.background,
    },
    {
        {
            widget = vol_widget_info
        },
        widget = wibox.container.margin,
        bottom = dpi(1)
    },
    layout = wibox.layout.fixed.horizontal
}

volmon.register(vol_widget_info, function(vol, mute)
    vol_widget_icon:set_text(mute and '\u{e04f}' or '\u{e050}')
    return vol .. "%"
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
