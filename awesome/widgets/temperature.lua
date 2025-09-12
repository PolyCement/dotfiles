-- temp widget (only monitors cpu since that's where my cooling is usually weakest)
local wibox = require("wibox")
local vicious = require("vicious")
local dpi = require("beautiful.xresources").apply_dpi

local temp_widget_info = wibox.widget.textbox()
-- rename to temp_container or some shit idk
local temp_widget = wibox.widget {
    {
        {
            {
                widget = wibox.widget.textbox,
                text = '\u{e1ff}',
                font = "Material Symbols Sharp 11"
            },
            widget = wibox.container.margin,
            left = dpi(-4),
            bottom = dpi(1)
        },
        widget = wibox.container.background,
    },
    {
        {
            widget = temp_widget_info
        },
        widget = wibox.container.margin,
        bottom = dpi(1)
    },
    layout = wibox.layout.fixed.horizontal
}

-- TODO: this is gross but there'll probably be a better way once i ditch vicious and roll my own monitor
return function (thermal_zone)
    vicious.register(temp_widget_info, vicious.widgets.thermal, "$1°C", 19, thermal_zone)
    return temp_widget
end
