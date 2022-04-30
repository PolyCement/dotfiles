local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local beautiful = require("beautiful")
require("awful.hotkeys_popup.keys")

-- TODO: pass these in? define em in advance? fuck if i know with this language
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

local myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end},
    { "manual", terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end}
}

local mysystemmenu = {
    { "suspend", "systemctl suspend" },
    { "shutdown", "shutdown now" },
    { "reboot", "reboot" }
}

-- some of these are specific to one machine,
-- there's gotta be a way to generate it semi-automatically
local gamesmenu = {
    { "dolphin", "dolphin-emu" },
    { "ftb", "feedthebeast" },
    { "lutris", "lutris" },
    { "pcsx2", "PCSX2" },
    { "retroarch", "retroarch" },
    { "steam", "steam" },
    { "steam (native)", "steam-native" }
}

local devmenu = {
    { "godot", "godot" },
    { "rpg maker mv", "steam-native steam://rungameid/363890" },
    { "tiled", "tiled" },
    { "unity", "unityhub" }
}

local graphicsmenu = {
    { "aseprite", "aseprite" },
    { "gimp", "gimp" },
    { "inkscape", "inkscape" },
    { "krita", "krita" }
}

local musicmenu = {
    { "jack", "qjackctl" },
    { "reaper", "reaper" },
    { "tenacity", "tenacity" },
}

local workmenu = {
    { "slack", "slack" },
    { "zoom", "zoom" },
}

local mymainmenu = awful.menu({
    items = {
        { "awesome",  myawesomemenu, beautiful.awesome_icon },
        { "system",   mysystemmenu },
        { "games",    gamesmenu },
        { "game dev", devmenu },
        { "graphics", graphicsmenu },
        { "music", musicmenu },
        { "work", workmenu },
        { "browser",  "firefox" },
        { "email",  "thunderbird" },
        { "chat",     "discord-accelerated" },
        { "terminal", terminal }
    }
})

return mymainmenu
