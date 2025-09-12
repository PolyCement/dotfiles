-- widgets for spacing and dividers
local wibox = require("wibox")
local dpi = require("beautiful.xresources").apply_dpi

local pad_widget = wibox.widget.textbox(" ")
local div_widget = wibox.widget {
    {
        text = " | ",
        widget = wibox.widget.textbox
    },
    widget = wibox.container.margin,
    left = dpi(-1),
    right = dpi(-1),
    bottom = dpi(3)
}

return {
    pad_widget = pad_widget,
    div_widget = div_widget
}
