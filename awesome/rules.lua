-- rules
local awful = require("awful")
local beautiful = require("beautiful")
local clientkeys = require("keybinds.client")

-- first, figure out what screen and tag firefox should be put on by default
local browserTag = (screen:count() > 1) and screen[2].tags[1] or screen[1].tags[2]
-- Rules to apply to new clients (through the "manage" signal).
local rules = {
    -- All clients will match this rule.
    {
        rule = { },
        properties = { border_width = beautiful.border_width,
                       border_color = beautiful.border_normal,
                       focus = awful.client.focus.filter,
                       raise = true,
                       keys = clientkeys,
                       buttons = clientbuttons,
                       screen = awful.screen.preferred,
                       placement = awful.placement.no_offscreen+awful.placement.centered
        }
    },

    -- Floating clients.
    {
        rule_any = { class = { "SimpleScreenRecorder", "QjackCtl" }, instance = { "pavucontrol" } },
        properties = { floating = true }
    },

    -- make all unity windows but the main one float (otherwise loading bars etc look weird)
    -- will need to keep an eye out to make sure this doesn't float games made in unity,
    -- TODO: update this, the header text changed!!
    {
        rule = { class = "Unity" },
        except = { name = "Unity %- Unity.+PC, Mac & Linux Standalone.+" },
        properties = { floating = true }
    },

    -- make gimp's toolbox/docks remember their positions and stay on top
    {
        rule_any = { role = { "gimp-toolbox-1", "gimp-dock-1" } },
        properties = { ontop = true, placement = awful.placement.restore }
    },

    -- make tf2 (and presumably other source engine games) run in fullscreen
    -- this seems to screw up games that already fullscreen themselves.....
    {
        rule = { class = "hl2_linux" },
        -- properties = { fullscreen = true }
    },

    -- if we have 2 screens put firefox on s2t1, else s1t2
    {
        rule_any = { class = { "Firefox", "firefox" } },
        properties = { tag = browserTag }
    },

    -- make firefox windows other than the main one float
    {
        rule_any = { class = { "Firefox", "firefox" } },
        except = { instance = "Navigator" },
        properties = { floating = true }
    },

    -- ignore discord's size hints, put it on home tag
    -- TODO: is there any way to force this to always start up on the right?
    {
        rule = { class = "discord" },
        properties = { size_hints_honor = false, tag = screen[1].tags[1] }
    },

    -- godot.....
    -- TODO: make sure this doesn't apply to games made in godot
    {
        rule = { class = "Godot" },
        properties = { floating = true }
    },

    -- steam always goes on tag 3
    {
        rule = { class = "Steam" },
        properties = { tag = screen[1].tags[3] }
    }

    -- Add titlebars to normal clients and dialogs
--     {
--         rule_any = { type = { "normal", "dialog" } },
--         properties = { titlebars_enabled = true }
--     },

}

return rules
