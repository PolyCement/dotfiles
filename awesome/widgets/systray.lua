-- systray widget
local wibox = require("wibox")
local spacers = require("widgets.spacers")

local systray = {}

local systray_widget_container

function systray.__call(t, screen)
    local systray_widget = wibox.widget.systray()
    systray_widget:set_screen(screen)
    systray_widget_container = wibox.widget {
        systray_widget,
        spacers.div_widget,
        layout = wibox.layout.align.horizontal
    }
    return systray_widget_container
end

function systray.toggle_systray()
    systray_widget_container.visible = not systray_widget_container.visible
end

-- what does this even do? shit breaks if i get rid of it...
setmetatable(systray, systray)

return systray
