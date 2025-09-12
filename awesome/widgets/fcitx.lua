-- input method editor (fcitx) widget
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local dpi = require("beautiful.xresources").apply_dpi

local fcitx_widget_info = wibox.widget.textbox()
local fcitx_widget = wibox.widget {
    {
        {
            widget = wibox.widget.textbox,
            text = '\u{f028}',
            font = "Material Symbols Sharp 11"
        },
        widget = wibox.container.margin,
        left = dpi(1),
        right = dpi(1),
        bottom = dpi(1)
    },
    {
        {
            widget = fcitx_widget_info,
            text = "Ｘ"
        },
        widget = wibox.container.margin,
        bottom = dpi(1)
    },
    widget = wibox.layout.fixed.horizontal
}

-- this function is left public for the fcitx plugin to use
-- TODO: there's gotta be a better way to do this than leaving a function public...
function update_fcitx_widget(active_im)
    local indicator_char
    if active_im == 'keyboard-gb' then
        indicator_char = "ー"
    elseif active_im == 'mozc' then
        indicator_char = "あ"
    else
        indicator_char = "Ｘ"
    end
    fcitx_widget_info.text = indicator_char
end

fcitx_widget:buttons(gears.table.join(
    awful.button({ }, 1, function()
        awful.spawn("fcitx5-configtool")
    end)
))

return fcitx_widget
