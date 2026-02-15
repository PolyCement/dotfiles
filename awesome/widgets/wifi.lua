-- wifi widget
local wibox = require("wibox")
local vicious = require("vicious")
local awful = require("awful")
local gears = require("gears")
local dpi = require("beautiful.xresources").apply_dpi

local wifi_widget_info = wibox.widget.textbox()
-- rename to wifi_container?
local wifi_widget = wibox.widget {
    {
        {
            {
                widget = wibox.widget.textbox,
                text = '\u{ef10}',
                font = "Material Symbols Sharp 10"
            },
            widget = wibox.container.margin,
            right = dpi(3),
            bottom = dpi(2)
        },
        widget = wibox.container.background,
    },
    {
        {
            widget = wifi_widget_info
        },
        widget = wibox.container.margin,
        bottom = dpi(1)
    },
    layout = wibox.layout.fixed.horizontal
}

-- define textbox widgets outside the main popup so i can update em individually
local wifi_widget_ssid = wibox.widget.textbox("SSID: Unknown")
local wifi_widget_rate = wibox.widget.textbox("Transfer Rate: Unknown")
local vpn_widget_status = wibox.widget.textbox("Status: Unknown")
local vpn_widget_relay = wibox.widget.textbox("Relay: Unknown")
local vpn_widget_location = wibox.widget.textbox("Location: Unknown")

-- now make the main popup widget
local wifi_popup = awful.popup {
    widget = {
        {
            {
                {
                    widget = wibox.widget.textbox("<b>Local Network</b>")
                },
                {
                    widget = wifi_widget_ssid
                },
                {
                    widget = wifi_widget_rate
                },
                layout = wibox.layout.fixed.vertical,
            },
            {
                {
                    widget = wibox.widget.textbox("<b>VPN</b>")
                },
                {
                    widget = vpn_widget_status
                },
                {
                    widget = vpn_widget_relay
                },
                {
                    widget = vpn_widget_location
                },
                layout = wibox.layout.fixed.vertical,
            },
            layout = wibox.layout.fixed.vertical,
            spacing = dpi(5),
        },
        bottom = dpi(5),
        left = dpi(5),
        right = dpi(5),
        widget = wibox.container.margin
    },
    ontop = true,
    visible = false,
    parent = wifi_widget
}

-- reconnect the vpn
local reconnect_vpn = function ()
    awful.spawn.with_shell("mullvad reconnect")
end

-- update vpn status. only gonna call it when the window is shown (for now)
-- TODO: maybe this and the reconnect function should go in a monitor module?
local get_vpn_status = function ()
    awful.spawn.easy_async_with_shell(
        "mullvad status",
        function (stdout, stderr, reason, exit_code)
            -- gotta use 2 separate matches cos afaik lua regex doesn't have optional
            -- capture groups :/
            local connected =
                stdout:match("(%a+).*")
            local relay, location =
                stdout:match(".*Relay:*%s*(%S+).*Visible location:%s*([^%.]+)%..*")

            -- set relay and location to "N/A" if they come back nil
            if relay == nil then
                relay = "N/A"
            end

            if location == nil then
                location = "N/A"
            end

            -- update widget text
            -- TODO: should probably do it with callbacks instead,
            vpn_widget_status.text = "Status: " .. connected
            vpn_widget_relay.text = "Relay: " .. relay
            vpn_widget_location.text = "Location: " .. location
        end
    )
end

-- show widget on hover
local visibility_locked = false
wifi_widget:connect_signal("mouse::enter", function(c)
    if not visibility_locked then
        -- update vpn status
        get_vpn_status()

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
        awful.button({}, 1, toggle_visibility_lock),
        awful.button({}, 3, reconnect_vpn)
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
