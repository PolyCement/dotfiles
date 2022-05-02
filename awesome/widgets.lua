local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local spacers = require("splitwidgets.spacers")
local clock = require("splitwidgets.clock")
local bat_widget = nil
if hostname == "doubleslap" then
     bat_widget = require("splitwidgets.battery")
end
local vol_widget = require("splitwidgets.volume")
local temp_widget = require("splitwidgets.temperature")(
    hostname == "cometpunch" and "thermal_zone2" or "thermal_zone0"
)
local fcitx_widget = require("splitwidgets.fcitx")
local taglist = require("splitwidgets.taglist")
local tasklist = require("splitwidgets.tasklist")
local layoutbox = require("splitwidgets.layoutbox")

local menu = require("menu")

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

local mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = menu })

-- build right widget table
-- we only want most of these on the primary screen
local function create_right_widgets(s)
    local right_widgets
    if s == screen.primary then
        -- for whatever reason the systray has to be told what screen to display on?
        local systray = wibox.widget.systray()
        systray:set_screen(s)

        right_widgets = {
            layout = wibox.layout.fixed.horizontal,
            spacers.pad_widget,
            systray,
            spacers.div_widget,
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
            vol_widget,
            spacers.div_widget,
            clock(s),
            spacers.pad_widget,
            layoutbox(s),
        })
    else
        right_widgets = {
            layout = wibox.layout.fixed.horizontal,
            layoutbox(s),
        }
    end
    return right_widgets
end

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create the wibox
    local mywibox = awful.wibar({ position = "top", screen = s, height = 20 })

    -- create right widgets
    -- TODO: figure out how to get the rightmost screen specifically
    -- (indices are not necessarily tied to position)
    local right_widgets = create_right_widgets(s)

    -- Add widgets to the wibox
    mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            taglist(s),
            s.mypromptbox,
        },
        tasklist(s),
        right_widgets
    }

    -- disable useless gaps when layout is set to maximized or fullscreen
    -- TODO: should this even be in here?
    awful.tag.attached_connect_signal(s, "property::layout", function(t)
        if t.layout.name == "max" or t.layout.name == "fullscreen" then
            t.gap = 0
        else
            t.gap = beautiful.useless_gap
        end
    end)
end)
