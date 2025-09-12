local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")

-- mapping of hostnames to network devices
-- TODO: maybe i should stop putting this config stuff in here....?
local wifi_network_devices = {
    ["doubleslap"] = "wlp2s0",
    ["cometpunch"] = "wlp5s0",
    ["firepunch"] = "wlp1s0",
}

local menu = require("menu")
local spacers = require("widgets.spacers")
local clock = require("widgets.clock")
local bat_widget = nil
if awesome.hostname == "doubleslap" or awesome.hostname == "firepunch" then
     bat_widget = require("widgets.battery")(
    awesome.hostname == "doubleslap" and "BAT0" or "BAT1"
)
end
local vol_widget = require("widgets.volume")
local temp_widget = require("widgets.temperature")(
    awesome.hostname == "cometpunch" and "thermal_zone2" or "thermal_zone0"
)
local fcitx_widget = require("widgets.fcitx")
local wifi_widget = require("widgets.wifi")(
    wifi_network_devices[awesome.hostname]
)
local taglist = require("widgets.taglist")
local tasklist = require("widgets.tasklist")
local layoutbox = require("widgets.layoutbox")
local systray = require("widgets.systray")

local launcher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = menu })

local function left_widgets(s)
    s.mypromptbox = awful.widget.prompt{ prompt = " Run: " }

    return {
        layout = wibox.layout.fixed.horizontal,
        launcher,
        taglist(s),
        s.mypromptbox,
    }
end

-- build right widget table
-- we only want most of these on the primary screen
local function right_widgets(s)
    local right_widgets
    if s == screen.primary then
        right_widgets = {
            layout = wibox.layout.fixed.horizontal,
            spacers.pad_widget,
            systray(s),
            -- systray includes its own spacer so it can be hidden along with the systray itself
            fcitx_widget
        }
        if bat_widget ~= nil then
            gears.table.merge(right_widgets, {
                spacers.div_widget,
                bat_widget
            })
        end
        gears.table.merge(right_widgets, {
            spacers.div_widget,
            temp_widget,
            spacers.div_widget,
            wifi_widget,
            spacers.div_widget,
            vol_widget,
            spacers.div_widget,
            clock(s),
            spacers.pad_widget,
            layoutbox(s),
        })
    else
        right_widgets = {
            layout = wibox.layout.fixed.horizontal,
            spacers.pad_widget,
            clock(s),
            spacers.pad_widget,
            layoutbox(s),
        }
    end
    return right_widgets
end

return function (s)
    local mywibox = awful.wibar({ position = "top", screen = s })
    mywibox:setup {
        layout = wibox.layout.align.horizontal,
        left_widgets(s),
        tasklist(s),
        right_widgets(s)
    }
    return mywibox
end
