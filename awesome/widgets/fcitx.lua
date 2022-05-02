-- input method editor (fcitx) widget
local wibox = require("wibox")
local fcitxmon = require("monitors.fcitxmon")

local fcitx_widget_info = wibox.widget.textbox()
local fcitx_widget = wibox.widget {
    {
        {
            widget = wibox.widget.textbox,
            text = "⌨ "
        },
        widget = wibox.container.margin,
        bottom = 1
    },
    {
        {
            widget = fcitx_widget_info
        },
        widget = wibox.container.margin,
        bottom = 1
    },
    widget = wibox.layout.fixed.horizontal
}

fcitxmon.register(fcitx_widget_info, function(state)
    local indicator_char
    if state == 0 then
        indicator_char = "Ｘ"
    elseif state == 1 then
        indicator_char = "ー"
    elseif state == 2 then
        indicator_char = "あ"
    end
    return indicator_char
end)

fcitxmon.start()

return fcitx_widget
