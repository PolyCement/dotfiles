-- widgets for spacing and dividers
local wibox = require("wibox")

local pad_widget = wibox.widget.textbox(" ")
local div_widget = wibox.widget {
    {
        text = " | ",
        widget = wibox.widget.textbox
    },
    widget = wibox.container.margin,
    bottom = 4
}

return {
    pad_widget = pad_widget,
    div_widget = div_widget
}
