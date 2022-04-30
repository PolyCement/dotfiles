-- global mouse bindings
local gears = require("gears")
local awful = require("awful")

global_mousebinds = gears.table.join(
    awful.button({ }, 3, function () menu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
)

return global_mousebinds
