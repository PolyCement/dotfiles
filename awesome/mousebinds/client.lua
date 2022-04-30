-- client mouse bindings
local gears = require("gears")
local awful = require("awful")

client_mousebinds = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)

return client_mousebinds
