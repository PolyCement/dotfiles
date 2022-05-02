local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")

local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end

local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() and c.first_tag then
                c.first_tag:view_only()
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
        end
    end),
    awful.button({ }, 3, client_menu_toggle_fn()),
    awful.button({ }, 4, function ()
        awful.client.focus.byidx(1)
    end),
    awful.button({ }, 5, function ()
        awful.client.focus.byidx(-1)
    end)
)

return function (screen)
    return awful.widget.tasklist {
        screen  = screen,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        widget_template = {
            {
                {
                    {
                        {
                            id = "icon_role",
                            widget = wibox.widget.imagebox
                        },
                        {
                            {
                                id = "text_role",
                                widget = wibox.widget.textbox
                            },
                            widget = wibox.container.margin,
                            left = 3,
                            bottom = 1
                        },
                        layout = wibox.layout.align.horizontal
                    },
                    widget = wibox.container.margin,
                    margins = 2
                },
                widget = wibox.container.place
            },
            id = "background_role",
            widget = wibox.container.background
        }
    }
end
