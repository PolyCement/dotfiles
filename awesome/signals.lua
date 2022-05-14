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

            -- some apps handle borderless fullscreen by setting the min/max dimensions
            -- of the client to the screen size and letting the wm sort it out.
            -- awesome won't do that by default, so here i'm doing it manually
            -- NOTE: i'm fairly sure this can't be handled with rules, but maybe i'm wrong
            local borderless_fullscreen =
                (not c.fullscreen)
                and c.size_hints.min_width == c.size_hints.max_width
                and c.size_hints.min_height == c.size_hints.max_height
                and c.size_hints.min_width == c.screen.geometry.width
                and c.size_hints.min_height == c.screen.geometry.height
            if print_debug_info then
                naughty.notify({
                    preset = naughty.config.presets.critical,
                    title = "Borderless Fullscreen Monitor",
                    text = (c.name or "<Unnamed Client>") .. " borderless fullscreen: " .. (borderless_fullscreen and "True" or "False")
                })
            end
            if borderless_fullscreen then
                c.borderless_fullscreen_hack = true
                c.fullscreen = true
                c:raise()
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

    {
        "property::fullscreen",
        function (c)
            if print_debug_info then
                naughty.notify({
                    preset = naughty.config.presets.critical,
                    title = "Fullscreen Monitor",
                    text = (c.name or "<Unnamed Client>") .. " fullscreen: " .. (c.fullscreen and "True" or "False")
                })
            end
            -- some borderless fullscreen clients like to misbehave,
            -- if they try to disable fullscreen, tell them to fuck off!
            if (not c.fullscreen) and c.borderless_fullscreen_hack then
                c.fullscreen = true
            end
            -- make sure fullscreen clients are aligned properly,
            if c.fullscreen then
                -- delaying the call makes sure the geometry is set *after* the client gets fullscreened
                gears.timer.delayed_call(function ()
                    if c.valid then
                        c:geometry(c.screen.geometry)
                    end
                end)
            end
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

    -- enable sloppy focus (ie. focus the client under the mouse cursor)
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
