-- wifi widget
local wibox = require("wibox")
local vicious = require("vicious")
local awful = require("awful")
local gears = require("gears")

local wifi_widget_info = wibox.widget.textbox()
-- rename to wifi_container?
local wifi_widget = wibox.widget {
    {
        {
            {
                widget = wibox.widget.textbox,
                text = " 📶 ",
                font = "sans 7"
            },
            widget = wibox.container.margin,
            left = -4,
            bottom = 1
        },
        widget = wibox.container.background,
    },
    {
        {
            widget = wifi_widget_info
        },
        widget = wibox.container.margin,
        bottom = 1
    },
    layout = wibox.layout.fixed.horizontal
}

-- define textbox widgets outside the main popup so i can update em individually
local wifi_widget_ssid = wibox.widget.textbox("SSID: Unknown")
local wifi_widget_rate = wibox.widget.textbox("Transfer Rate: Unknown")

-- now make the main popup widget
local wifi_popup = awful.popup {
    widget = {
        {
            {
                widget = wifi_widget_ssid
            },
            {
                widget = wifi_widget_rate
            },
            layout = wibox.layout.fixed.vertical,
        },
        bottom = 5,
        left = 5,
        right = 5,
        widget = wibox.container.margin
    },
    ontop = true,
    visible = false,
    parent = wifi_widget
}

-- show widget on hover
local visibility_locked = false
wifi_widget:connect_signal("mouse::enter", function(c)
    if not visibility_locked then
        -- i don't really get how the placement stuff works but this is good enough for now
        awful.placement.next_to(wifi_popup,
            {
                preferred_positions = { "bottom" },
                preferred_anchors = { "middle" },
            }
        )
        wifi_popup.visible = true
    end
end)
wifi_widget:connect_signal("mouse::leave", function(c)
    if not visibility_locked then
        wifi_popup.visible = false
    end
end)

-- lock visibility state on click (should be functionally identical to how the calendar popup behaves)
local function toggle_visibility_lock()
    if (wifi_popup.visible and not visibility_locked) or not wifi_popup.visible then
        visibility_locked = true
        wifi_popup.visible = true
    else
        visibility_locked = false
        wifi_popup.visible = false
    end
end

wifi_widget:buttons(
    gears.table.join(
        awful.button({}, 1, toggle_visibility_lock)
    )
)

wifi_popup:buttons(
    gears.table.join(
        awful.button({}, 1, toggle_visibility_lock)
    )
)

return function (interface)
    vicious.register(wifi_widget_info, vicious.widgets.wifiiw, function (widget, args)
        -- update popup contents. still havent found a better way to do this,
        wifi_widget_ssid.text = "SSID: " .. args["{ssid}"]
        wifi_widget_rate.text = "Transfer Rate: " .. args["{rate}"] .. "Mb/s"
        return args["{linp}"] .. "%"
    end, 19, interface)
    return wifi_widget
end
