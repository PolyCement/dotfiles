local awful = require("awful")
local beautiful = require("beautiful")
local hotkeys_widget = require("widgets.hotkeys")

-- TODO: pass these in? define em in advance? fuck if i know with this language
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- checks if the given command is installed
local function is_installed(command, callback)
    awful.spawn.easy_async_with_shell("command -v " .. command, function (stdout, stderr, reason, exit_code)
        callback(exit_code == 0)
    end)
end

-- append the given entry to the given table if the given command is installed
local function append_if_installed(t, entry, command)
    is_installed(command, function (installed) if installed then table.insert(t, entry) end end)
end

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

-- populate app menus
local gamesmenu = {}

append_if_installed(gamesmenu, { "dolphin", "dolphin-emu" }, "dolphin-emu")
-- TODO: this ends up in the wrong place, i guess test runs faster than command?
-- maybe i should put a sort on the insert...
awful.spawn.easy_async_with_shell(
    "test -e /home/freya/games/flashpoint/Flashpoint/start-flashpoint.sh",
    function (stdout, stderr, reason, exit_code)
        if exit_code == 0 then
            table.insert(
                gamesmenu,
                { "flashpoint", "/home/freya/games/flashpoint/Flashpoint/start-flashpoint.sh" }
            )
        end
    end
)
append_if_installed(gamesmenu, { "lutris", "lutris" }, "lutris")
append_if_installed(gamesmenu, { "openrct2", "openrct2" }, "openrct2")
append_if_installed(gamesmenu, { "openttd", "openttd" }, "openttd")
append_if_installed(gamesmenu, { "pcsx2", "pcsx2-qt" }, "pcsx2-qt")
append_if_installed(gamesmenu, { "retroarch", "retroarch" }, "retroarch")
append_if_installed(gamesmenu, { "rmg", "RMG" }, "RMG")
append_if_installed(gamesmenu, { "steam", "steam" }, "steam")

local devmenu = {}

append_if_installed(devmenu, { "godot", "godot" }, "godot")
append_if_installed(devmenu, { "rpg maker mv", "steam steam://rungameid/363890" }, "steam")
append_if_installed(devmenu, { "tiled", "tiled" }, "tiled")
append_if_installed(devmenu, { "unity", "unityhub" }, "unityhub")

local graphicsmenu = {}

append_if_installed(graphicsmenu, { "gimp", "gimp" }, "gimp")
append_if_installed(graphicsmenu, { "inkscape", "inkscape" }, "inkscape")
append_if_installed(graphicsmenu, { "krita", "krita" }, "krita")

local audiomenu = {}

append_if_installed(audiomenu, { "audacity", "audacity" }, "audacity")
append_if_installed(audiomenu, { "easyeffects", "easyeffects" }, "easyeffects")
append_if_installed(audiomenu, { "qpwgraph", "qpwgraph" }, "qpwgraph")
append_if_installed(audiomenu, { "reaper", "reaper" }, "reaper")

local circuitsmenu = {}

append_if_installed(circuitsmenu, { "circuitjs", "circuitjs1-electron" }, "circuitjs1-electron")
append_if_installed(circuitsmenu, { "diylc", "diylc" }, "diylc")

local workmenu = {}

append_if_installed(workmenu, { "penpot", "penpot-desktop" }, "penpot-desktop")
append_if_installed(workmenu, { "postman", "postman" }, "postman")
append_if_installed(workmenu, { "slack", "slack" }, "slack")
append_if_installed(workmenu, { "zoom", "zoom" }, "zoom")

-- TODO: it seems like inserting into the tables after awful.menu is called works fine but idk...
-- keep an eye on it i guess
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
