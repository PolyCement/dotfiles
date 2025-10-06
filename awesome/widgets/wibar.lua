local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local utils = require("utils")

-- mapping of hostnames to which of their thermal zones is the cpu
-- TODO: maybe i should stop putting this config stuff in here....?
local cpu_thermal_zones = {
    ["doubleslap"] = "thermal_zone0",
    ["cometpunch"] = "thermal_zone2",
    ["firepunch"] = "thermal_zone3",
}

-- mapping of hostnames to network devices
-- TODO: yeah dont put these here,
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
    cpu_thermal_zones[awesome.hostname]
)
local fcitx_widget = nil
utils.is_installed(
    "fcitx5",
    function (installed) if installed then fcitx_widget = require("widgets.fcitx") end end
)
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
        -- NOTE: systray includes its own spacer so it can be hidden along with
        -- the systray itself
        right_widgets = {
            layout = wibox.layout.fixed.horizontal,
            spacers.pad_widget,
            systray(s),
        }
        if fcitx_widget ~= nil then
            gears.table.merge(right_widgets, {
                fcitx_widget,
                spacers.div_widget,
            })
        end
        if bat_widget ~= nil then
            gears.table.merge(right_widgets, {
                bat_widget,
                spacers.div_widget,
            })
        end
        gears.table.merge(right_widgets, {
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
