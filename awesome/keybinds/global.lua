-- global keybinds
local gears = require("gears")
local awful = require("awful")
local menu = require("menu")
local hotkeys_widget = require("widgets.hotkeys")

modkey = "Mod4"

local globalkeys = gears.table.join(
    -- meta stuff
    awful.key(
        { modkey }, "s",
        hotkeys_widget.show_help,
        { description = "show help", group = "awesome" }
    ),
    awful.key(
        { modkey }, "w",
        function () menu:show() end,
        { description = "show main menu", group = "awesome" }
    ),
    awful.key(
        { modkey }, "Return",
        function () awful.spawn(terminal) end,
        { description = "open a terminal", group = "launcher" }
    ),
    awful.key(
        { modkey, "Control" }, "r",
        awesome.restart,
        { description = "reload awesome", group = "awesome" }
    ),
    awful.key(
        { modkey, "Shift" }, "q",
        awesome.quit,
        { description = "quit awesome", group = "awesome" }
    ),

    -- tag switching
    awful.key(
        { modkey }, "Left",
        awful.tag.viewprev,
        { description = "view previous", group = "tag" }
    ),
    awful.key(
        { modkey }, "Right",
        awful.tag.viewnext,
        { description = "view next", group = "tag" }
    ),
    awful.key(
        { modkey }, "Escape",
        awful.tag.history.restore,
        { description = "go back", group = "tag" }
    ),

    -- client manipulation
    awful.key(
        { modkey }, "j",
        function () awful.client.focus.byidx(1) end,
        { description = "focus next by index", group = "client" }
    ),
    awful.key(
        { modkey }, "k",
        function () awful.client.focus.byidx(-1) end,
        { description = "focus previous by index", group = "client" }
    ),
    awful.key(
        { modkey, "Shift" }, "j",
        function () awful.client.swap.byidx(1) end,
        { description = "swap with next client by index", group = "client" }
    ),
    awful.key(
        { modkey, "Shift" }, "k",
        function () awful.client.swap.byidx(-1) end,
        { description = "swap with previous client by index", group = "client" }
    ),
    awful.key(
        { modkey }, "u",
        awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }
    ),
    awful.key(
        { modkey }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "go back", group = "client" }
    ),
    awful.key(
        { modkey, "Control" }, "n",
        function ()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                client.focus = c
                c:raise()
            end
        end,
        { description = "restore minimized", group = "client" }
    ),

    -- screen switching
    -- TODO: is there some way i can add screen swapping like there is for clients?
    awful.key(
        { modkey, "Control" }, "j",
        function () awful.screen.focus_relative(1) end,
        { description = "focus the next screen", group = "screen" }
    ),
    awful.key(
        { modkey, "Control" }, "k",
        function () awful.screen.focus_relative(-1) end,
        { description = "focus the previous screen", group = "screen" }
    ),

    -- layout manipulation
    awful.key(
        { modkey }, "l",
        function () awful.tag.incmwfact(0.05) end,
        { description = "increase master width factor", group = "layout" }
    ),
    awful.key(
        { modkey }, "h",
        function () awful.tag.incmwfact(-0.05) end,
        { description = "decrease master width factor", group = "layout" }
    ),
    awful.key(
        { modkey, "Shift" }, "h",
        function () awful.tag.incnmaster(1, nil, true) end,
        { description = "increase the number of master clients", group = "layout" }
    ),
    awful.key(
        { modkey, "Shift" }, "l",
        function () awful.tag.incnmaster(-1, nil, true) end,
        { description = "decrease the number of master clients", group = "layout" }
    ),
    awful.key(
        { modkey, "Control" }, "h",
        function () awful.tag.incncol(1, nil, true) end,
        { description = "increase the number of columns", group = "layout" }
    ),
    awful.key(
        { modkey, "Control" }, "l",
        function () awful.tag.incncol(-1, nil, true) end,
        { description = "decrease the number of columns", group = "layout" }
    ),
    awful.key(
        { modkey }, "space",
        function () awful.layout.inc(1) end,
        { description = "select next", group = "layout" }
    ),
    awful.key(
        { modkey, "Shift" }, "space",
        function () awful.layout.inc(-1) end,
        { description = "select previous", group = "layout" }
    ),

    -- laptop-specific keybinds
    -- TODO: only do these on doubleslap, also add descriptions
    -- brightness controls
    -- these are very basic and don't *really* work in a "normal" way
    -- brightness down applies redshift, brightness up removes it
    -- TODO: think of something better
    awful.key(
        {}, "XF86MonBrightnessUp",
        function () awful.spawn("redshift -x") end
    ),
    awful.key(
        {}, "XF86MonBrightnessDown",
        function () awful.spawn("redshift -O 2700") end
    ),

    -- volume controls
    awful.key(
        {}, "XF86AudioLowerVolume",
        function () change_volume("-5%") end
    ),
    awful.key(
        {}, "XF86AudioRaiseVolume",
        function () change_volume("+5%") end
    ),
    awful.key(
        {}, "XF86AudioMute",
        function () toggle_mute() end
    ),

    -- prompt
    awful.key(
        { modkey }, "r",
        function () awful.screen.focused().mypromptbox:run() end,
        { description = "run prompt", group = "launcher" }
    ),
    -- NOTE: i don't think i've ever used this even once,
    awful.key(
        { modkey }, "x",
        function ()
            awful.prompt.run {
              prompt       = "Run Lua code: ",
              textbox      = awful.screen.focused().mypromptbox.widget,
              exe_callback = awful.util.eval,
              history_path = gears.filesystem.get_cache_dir() .. "/history_eval"
            }
        end,
        { description = "lua execute prompt", group = "awesome" }
    ),

    -- screenshots
    -- screenshot all screens
    awful.key({ }, "Print", function ()
        local timestamp = os.date("%y%m%d-%H%M%S")
        awful.spawn.with_shell("maim -u ~/pictures/screenshots/" .. timestamp .. ".png")
    end),
    -- screenshot only the current screen (ie. the one the cursor is over)
    awful.key({ "Shift" }, "Print", function ()
        local geo = awful.screen.focused().geometry
        local geo_string = string.format("%sx%s+%s+%s", geo.width, geo.height, geo.x, geo.y)
        local timestamp = os.date("%y%m%d-%H%M%S")
        awful.spawn.with_shell(
            "maim -g " .. geo_string .. " -u ~/pictures/screenshots/" .. timestamp .. ".png"
        )
    end),
    -- screenshot a selected area (or window if you click instead of dragging)
    awful.key({ "Mod1" }, "Print", function ()
        local timestamp = os.date("%y%m%d-%H%M%S")
        awful.spawn.with_shell("maim -u -s ~/pictures/screenshots/" .. timestamp .. ".png")
    end),

    -- switch default audio sink
    -- TODO: this is pretty disgusting, maybe i should boot it to a bash script
    -- alternatively, it might be cleaner if i slot it into volmon and use the helpers there
    awful.key(
        { modkey, "Shift" }, "o",
        function ()
            -- get the default sink
            local cmd_sink = "pactl get-default-sink"
            awful.spawn.easy_async_with_shell(cmd_sink, function (stdout, stderr, reason, exit_code)
                local default_sink = stdout:gsub("%s+", "")
                -- this command takes the output of pactl, cuts it down to only
                -- the default sink's info, then grabs the active port
                local cmd_port = "pactl list sinks | sed -n -e '/^\\s*Name: "
                                 .. default_sink .. "$/,/^$/s/^\\s*Active Port: //p'"
                awful.spawn.easy_async_with_shell(cmd_port, function (stdout, stderr, reason, exit_code)
                    if stdout:gsub("%s+", "") == "analog-output-lineout" then
                        awful.spawn("pactl set-sink-port " .. default_sink .. " analog-output-headphones")
                        -- also disable easyeffects global bypass
                        awful.spawn("easyeffects -b 2")
                    else
                        awful.spawn("pactl set-sink-port " .. default_sink .. " analog-output-lineout")
                        -- also enable easyeffects global bypass
                        awful.spawn("easyeffects -b 1")
                    end
                end)
            end)
        end,
        { description = "toggle output device", group = "audio" }
    )
)

-- bind key numbers to tags
-- the default config says "Be careful: we use keycodes to make it works on any keyboard layout."
-- but i have no idea what the fuck that means. these don't map to any keycodes i know of
-- TODO: figure out something better for this with 2 displays
-- also see if there's a way to make 1-4 map to screen 1's tags and 5-8 map to screen 2's tags?
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- show only this tag
        -- don't think i've ever used this (or at least, not on purpose lmao)
        awful.key(
            { modkey }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                   tag:view_only()
                end
            end,
            { description = "view tag #"..i, group = "tag" }
        ),
        -- show this tag
        awful.key(
            { modkey, "Control" }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                   awful.tag.viewtoggle(tag)
                end
            end,
            { description = "toggle tag #" .. i, group = "tag" }
        ),
        -- move focused client to this tag
        awful.key(
            { modkey, "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
               end
            end,
            { description = "move focused client to tag #"..i, group = "tag" }
        ),
        -- put focused client on this tag as well (ie. make it exist on both)
        -- haven't ever used this one either,
        awful.key(
            { modkey, "Control", "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            { description = "toggle focused client on tag #" .. i, group = "tag" }
        )
    )
end

return globalkeys
