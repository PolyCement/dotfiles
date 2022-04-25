-- clock widget
local wibox = require("wibox")
local calendar = require("awful.widget.calendar_popup")

local clock_widget = wibox.widget {
    {
        widget = wibox.widget.textclock,
        format = "🕒 %a %d %b, %H:%M"
    },
    widget = wibox.container.margin,
    bottom = 1
}

return function (screen)
    local calendar_popup = calendar.month({ screen = screen })
    calendar_popup:attach(clock_widget, "tr")
    return clock_widget
end
