-- clock widget
local wibox = require("wibox")
local calendar = require("awful.widget.calendar_popup")

return function (screen)
    local clock_widget = wibox.widget {
        {
            widget = wibox.widget.textclock,
            format = "🕒 %a %d %b, %H:%M"
        },
        widget = wibox.container.margin,
        bottom = 1
    }
    -- TODO: figure out how to make it so only 1 calendar widget can be open at a time
    local calendar_popup = calendar.month({ screen = screen })
    calendar_popup:attach(clock_widget, "tr")
    return clock_widget
end
