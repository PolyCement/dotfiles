local awful = require("awful")
local beautiful = require("beautiful")
local hotkeys_widget = require("widgets.hotkeys")

-- TODO: pass these in? define em in advance? fuck if i know with this language
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

local myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_widget.show_help end},
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
    { "flashpoint", "/home/freya/games/flashpoint/Flashpoint/start-flashpoint.sh" },
    { "lutris", "lutris" },
    { "openrct2", "openrct2" },
    { "openttd", "openttd" },
    { "pcsx2", "pcsx2-qt" },
    { "retroarch", "retroarch" },
    { "rmg", "RMG" },
    { "steam", "steam" }
}

local devmenu = {
    { "godot", "godot" },
    { "rpg maker mv", "steam-native steam://rungameid/363890" },
    { "tiled", "tiled" },
    { "unity", "unityhub" }
}

local graphicsmenu = {
    { "gimp", "gimp" },
    { "inkscape", "inkscape" },
    { "krita", "krita" }
}

local audiomenu = {
    { "audacity", "audacity" },
    { "easyeffects", "easyeffects" },
    { "qpwgraph", "qpwgraph" },
    { "reaper", "reaper" }
}

local circuitsmenu = {
    { "circuitjs", "circuitjs1-electron" },
    { "diylc", "diylc" }
}

local workmenu = {
    { "penpot", "penpot-desktop" },
    { "postman", "postman" },
    { "slack", "slack" },
    { "zoom", "zoom" }
}

local mymainmenu = awful.menu({
    items = {
        { "awesome",  myawesomemenu, beautiful.awesome_icon },
        { "system",   mysystemmenu },
        { "games",    gamesmenu },
        { "game dev", devmenu },
        { "graphics", graphicsmenu },
        { "audio", audiomenu },
        { "circuits", circuitsmenu },
        { "work", workmenu },
        { "browser",  "firefox" },
        { "email",  "thunderbird" },
        { "chat",     "discord-accelerated" },
        { "terminal", terminal }
    }
})

return mymainmenu
