-- signals
-- returns a mapping of signal names to callback functions
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")

-- Signal function to execute when a new client appears.
local signals = {
    {
        "manage",
        function (c)
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
        end
    },

    -- Add a titlebar if titlebars_enabled is set to true in the rules.
    -- TODO: maybe figure out if there's a way to add just the close button on floating clients
    -- a lot of apps like to just not have them on dialogues etc and then i have to roll the dice on
    -- whether ctrl+meta+c will close just the selected client or the entire fucking app
    -- in any case, this is currently unused
    {
        "request::titlebars",
            function (c)
            -- buttons for the titlebar
            local buttons = gears.table.join(
                awful.button({ }, 1, function ()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function ()
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
        end
    },

    -- TODO: boot up godot for the first time in years and check if this is still relevant
    -- godot uses a single client from the splash screen through the project manager,
    -- all the way to the main editor view
    -- this hack stops godot from maximising itself on the way there (and toggles floating off, since that's set above)
    -- the second splash screen will still maximise itself but it's there for like 1 second so w/e
    -- the godot_hack variable stops this from triggering more than once per client,
    -- allowing it to be maximised manually
    {
        "property::name",
        function (c)
            if c.class == "Godot" and not c.godot_hack then
                if c.name and c.name:find("Godot Engine - ") and not c.name:find("Project Manager") then
                    c.maximized = false
                    c.floating = false
                    c.godot_hack = true
                end
            end
        end
    },

    -- TODO: try this out, might be useful now i have multiple monitors
    -- would need to be paired with something to hide the cursor if it stays still, though
    -- Enable sloppy focus, so that focus follows mouse.
    {
        "mouse::enter",
        function (c)
            if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
                and awful.client.focus.filter(c) then
                client.focus = c
            end
        end
    },

    -- add/remove borders on focused clients
    { "focus", function (c) c.border_color = beautiful.border_focus end },
    { "unfocus", function (c) c.border_color = beautiful.border_normal end }
}

return signals
