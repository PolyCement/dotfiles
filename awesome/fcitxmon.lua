-- fcitxmon.lua
-- an awesome wm plugin that monitors dbus for changes to fcitx's input method
-- you can register a textbox widget with this plugin and it'll update whenever input method changes
-- unlike mozcmon this doesn't piggyback off someone else's code
-- as such, it was a total bitch to figure out lol

-- === widget notes ===
-- this one makes less assumptions than mozcmon did, so is much simpler
-- it takes a function which will be passed a value corresponding to
-- the output of fcitx-remote when called with no args, ie.:
-- 0 - fcitx closed (fcitx *says* it returns this, but actually returns "Not get reply" lmao
-- 1 - fcitx open, but inactive
-- 2 - fcitx open and active
-- the return value of the function will be set as the widget text

-- lua libraries:
-- we're using lgi to listen for dbus signals (it's a dependency of awesomewm, so you have it installed)
-- awful is so we can call fcitx-remote to get the current state
-- naughty is just for the error notifications, so it's not *strictly* necessary
local glib = require("lgi").GLib
local gio = require("lgi").Gio
local awful = require("awful")
local naughty = require("naughty")

-- tracking for registered widgets
local registered_widgets = {}

local fcitxmon = {}

-- register a widget to be updated by fcitxmon
fcitxmon.register = function (w, format)
    table.insert(registered_widgets, { w, format or "%s" })
end

-- call this to start listening to dbus
fcitxmon.start = function ()
    -- define the callback function (this actually gets a bunch of args but we don't care of em)
    on_signal_received = function()
        -- frustratingly, fcitx doesn't actually send state info in its dbus signals
        -- so whenever we get a signal, just call fcitx-remote to read the current state
        -- NOTE: idk if this command can fail, so i'll leave dealing with error handling til it does
        awful.spawn.easy_async_with_shell("fcitx-remote", function(stdout, stderr, reason, exit_code)
            for _, row in pairs(registered_widgets) do
                local widget, format = table.unpack(row)
                widget:set_text(format(tonumber(stdout) or 0))
            end
        end)
    end

    -- get the session bus and subscribe to fcitx input method signals
    local bus = gio.bus_get_sync(gio.BusType.SESSION)
    local sub_id = bus:signal_subscribe(
        "org.fcitx.Fcitx",
        "org.freedesktop.DBus.Properties",
        "PropertiesChanged",
        "/inputmethod",
        "org.fcitx.Fcitx.InputMethod",
        gio.DBusSignalFlags.NONE,
        on_signal_received
    )

    -- call the callback manually one time to get the initial state
    on_signal_received()

    return true
end

return fcitxmon
