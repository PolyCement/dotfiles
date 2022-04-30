-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
beautiful.init("~/.config/awesome/themes/default/theme.lua")
-- Notification library
local naughty = require("naughty")

local menu = require("menu")
local globalkeys = require("keybinds.global")
local signal_map = require("signals")

-- set this to true to get spammed with debug notifications
local print_debug_info = false
 
-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Startup Error!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Error!",
                         text = tostring(err) })
        local logfile = io.open(".awesome.log", "a")
        logfile:write(tostring(err) .. "\n")
        logfile:close()
        in_error = false
    end)
end
-- }}}

-- start the compositor (it can't run more than one instance, don't worry about it)
awful.spawn.with_shell("xcompmgr &")

-- {{{ Variable definitions

-- make notifications stay on screen longer
naughty.config.defaults.timeout = 10
naughty.config.defaults.position = "bottom_right"
naughty.config.defaults.screen = screen.primary

-- get the hostname so i can turn stuff on or off for different machines
local hostname = awesome.hostname

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- table of layouts to cover with awful.layout.inc
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
}

root.buttons(require("mousebinds.global"))

-- set up taskbars
require("widgets")

-- set keys
root.keys(globalkeys)

-- set rules
awful.rules.rules = require("rules")

-- connect signals
for _, signal in pairs(signal_map) do
    client.connect_signal(table.unpack(signal))
end
