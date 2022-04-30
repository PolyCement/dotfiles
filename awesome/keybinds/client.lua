-- client keybinds
local gears = require("gears")
local awful = require("awful")

local clientkeys = gears.table.join(
    awful.key(
        { modkey }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        { description = "toggle fullscreen", group = "client" }
    ),
    -- NOTE: i didn't realise this was actually part of awesomewm til now,
    awful.key(
        { modkey, "Shift" }, "c",
        function (c) c:kill() end,
        { description = "close", group = "client" }
    ),
    awful.key(
        { modkey, "Control" }, "space",
        awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }
    ),
    -- NOTE: "move to master" means make this client the master client
    -- i'd never used this because i didn't understand what it did, but it's actually pretty useful!
    awful.key(
        { modkey, "Control" }, "Return",
        function (c) c:swap(awful.client.getmaster()) end,
        { description = "move to master", group = "client" }
    ),
    awful.key(
        { modkey }, "o",
        function (c) c:move_to_screen() end,
        { description = "move to screen", group = "client" }
    ),
    awful.key(
        { modkey }, "t",
        function (c) c.ontop = not c.ontop end,
        { description = "toggle keep on top", group = "client" }
    ),
    -- NOTE: minimized clients can't be focused, so no reason to toggle here
    awful.key(
        { modkey }, "n",
        function (c) c.minimized = true end,
        { description = "minimize", group = "client" }
    ),
    awful.key(
        { modkey }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end,
        { description = "maximize", group = "client" }
    )
)

return clientkeys
