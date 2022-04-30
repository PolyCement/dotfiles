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
-- TODO: widgets go here
local menu = require("menu")
local globalkeys = require("keybinds.global")

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

-- start the compositor
-- i still don't know if this should be in here honestly
-- like, doesnt this mean that every time i restart awesome wm, i make *another* xcompmgr???
-- seems bad. imo.
awful.spawn.with_shell("xcompmgr &")

-- {{{ Variable definitions

-- make notifications stay on screen longer
naughty.config.defaults.timeout = 10
naughty.config.defaults.position = "bottom_right"
naughty.config.defaults.screen = screen:count()

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

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () menu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- set up taskbars
require("widgets")

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- add rules
awful.rules.rules = require("rules")

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end

    -- for whatever reason, fullscreen apps end up kinda shoved off the screen
    -- this just shoves em back into the right position
    -- i feel like it's probably not the *right* solution. but it works,
    if c.fullscreen then
        c.x = 0
        c.y = 0
    end

    -- if a new client has a parent (ie. transient_for), move it to the same tag as the parent
    local parent = c.transient_for
    if print_debug_info then
        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Transient record",
            text = (c.name or "<Unnamed Client>") .. " → " .. (parent and parent.name or "No parent")
        })
    end
    if parent then
        local tag = parent.first_tag
        if print_debug_info then
            naughty.notify({
                preset = naughty.config.presets.critical,
                title = "Shifting client to parent tag",
                text = "Shifting " .. (c.name or "<Unnamed Client>")
                    .. " to screen " .. tag.screen.index .. " tag " .. tag.index
            })
        end
        c:move_to_tag(tag)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
-- TODO: maybe figure out if there's a way to add just the close button on floating clients
-- a lot of apps like to just not have them on dialogues etc and then i have to roll the dice on
-- whether ctrl+meta+c will close just the selected client or the entire fucking app
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- godot uses a single client from the splash screen through the project manager, all the way to the main editor view
-- this hack stops godot from maximising itself on the way there (and toggles floating off, since that's set above)
-- the second splash screen will still maximise itself but it's there for like 1 second so w/e
-- the godot_hack variable stops this from triggering more than once per client, allowing it to be maximised manually
client.connect_signal("property::name", function(c)
    if c.class == "Godot" and not c.godot_hack then
        if c.name and c.name:find("Godot Engine - ") and not c.name:find("Project Manager") then
            c.maximized = false
            c.floating = false
            c.godot_hack = true
        end
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal("mouse::enter", function(c)
--     if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
--         and awful.client.focus.filter(c) then
--         client.focus = c
--     end
-- end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
