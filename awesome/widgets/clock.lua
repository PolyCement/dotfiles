-- clock widget
local wibox = require("wibox")
local calendar = require("awful.widget.calendar_popup")
local dpi = require("beautiful.xresources").apply_dpi

return function (screen)
    local clock_widget = wibox.widget {
        {
            {
                {
                    widget = wibox.widget.textbox,
                    text = '\u{e8b5}',
                    font = "Material Symbols Sharp 10"
                },
                widget = wibox.container.margin,
                left = dpi(-1),
                right = dpi(2),
                bottom = dpi(1)
            },
            widget = wibox.container.background,
        },
        {
            {
                widget = wibox.widget.textclock,
                format = "%a %d %b, %H:%M"
            },
            widget = wibox.container.margin,
            bottom = dpi(1)
        },
        layout = wibox.layout.fixed.horizontal
    }

    -- TODO: figure out how to make it so only 1 calendar widget can be open at a time
    local calendar_popup = calendar.month({ screen = screen })
    calendar_popup:attach(clock_widget, "tr")

    return clock_widget
end
