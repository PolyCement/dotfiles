-- systray widget
local wibox = require("wibox")

local systray = {}

local systray_widget

function systray.__call(t, screen)
    systray_widget = wibox.widget.systray()
    systray_widget:set_screen(screen)
    systray_widget.visible = false
    return systray_widget
end

function systray.toggle_systray()
    systray_widget.visible = not systray_widget.visible
end

-- what does this even do? shit breaks if i get rid of it...
setmetatable(systray, systray)

return systray
