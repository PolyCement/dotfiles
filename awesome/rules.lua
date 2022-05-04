-- rules
local awful = require("awful")
local beautiful = require("beautiful")
local clientkeys = require("keybinds.client")
local clientbuttons = require("mousebinds.client")

-- since i use this config with both 1 and 2 displays, we gotta do a little math to make sure
-- everything goes where i want it. the gist of it is, if i have 1 screen, i want certain clients
-- to appear on certain tags (standard stuff). but if i have 2, i want the clients that would've
-- been on tag 1 to be on the secondary screen's tag 1, and everything else on the primary screen,
-- but 1 tag lower. for example, firefox should be on tag 2 with 1 display, but on primary screen
-- tag 1 with 2 displays.
-- NOTE: this setup will almost certainly not handle displays being added and removed.
-- that's not something i ever plan to do, but if it comes up i can just have rules be recalculated
-- when the "list" signal is fired

-- first, determine primary and secondary screen
local num_screens = screen:count()
local primary = screen.primary
local secondary
if num_screens == 1 then
    -- shouldn't really come up, but just in case,
    secondary = screen.primary
else
    -- it's unclear if the primary display will always be at index 1, so here's this.
    -- also, this will need changed if i ever somehow end up with 3 displays...
    secondary = screen[screen.primary.index % num_screens + 1]
end

-- next, we need a function to figure out what tag we should put things on
-- tag_index should be a number from 1 to however many tags i currently have per screen, or it'll break
local function get_tag(tag_index)
    if num_screens == 1 then
        return primary.tags[tag_index]
    else
        if tag_index == 1 then
            return secondary.tags[1]
        else
            return primary.tags[tag_index - 1]
        end
    end
end

-- and finally, the rules (applied through the "manage" signal)
-- TODO: check if all these are still relevant, it's been years since i wrote some of these
local rules = {
    -- all clients
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_offscreen+awful.placement.centered
        }
    },

    -- clients that should float
    -- TODO: do i really want qjackctl to float? hell, do i even use it anymore?
    {
        rule_any = {
            class = { "SimpleScreenRecorder", "QjackCtl" },
            instance = { "pavucontrol" }
        },
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

    -- firefox and thunderbird go on tag 2
    {
        rule_any = { class = { "Firefox", "firefox", "Thunderbird" } },
        properties = { tag = get_tag(2) }
    },

    -- make firefox windows other than the main one float
    {
        rule_any = { class = { "Firefox", "firefox" } },
        except = { instance = "Navigator" },
        properties = { floating = true }
    },

    -- ignore discord's size hints, put it on home tag
    -- TODO: is there any way to force this to always start up on the right?
    -- probably could be done by setting it as master
    {
        rule = { class = "discord" },
        properties = { size_hints_honor = false, tag = get_tag(1) }
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
        properties = { tag = get_tag(3) }
    }

    -- Add titlebars to normal clients and dialogs
    -- TODO: might wanna experiment with this for floating clients/dialogs
    -- {
    --     rule_any = { type = { "normal", "dialog" } },
    --     properties = { titlebars_enabled = true }
    -- }
}

return rules
