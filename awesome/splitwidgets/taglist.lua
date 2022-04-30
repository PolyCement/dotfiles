local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- list of tags to add to each screen
-- TODO: maybe switch the symbols up, the inner planet ones look a bit shit
-- (on second thought i might just use svgs or something)
local tag_list = {
    left = {
        { " ☿ ", awful.layout.layouts[2] },
        { " ♀ ", awful.layout.layouts[6] },
        { " ♁ ", awful.layout.layouts[6] },
        { " ♂ ", awful.layout.layouts[6] }
    },
    right = {
        { " ♃ ", awful.layout.layouts[6] },
        { " ♄ ", awful.layout.layouts[6] },
        { " ♅ ", awful.layout.layouts[6] },
        { " ♆ ", awful.layout.layouts[6] }
    }
}

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

-- function to call when creating/updating taglist widgets
local function update_tag(self, t, index, objects)
    local bg_color, square
    -- NOTE: tag.urgent isnt really documented? but it's real and it's my friend
    if t.urgent then
        bg_color = beautiful.bg_urgent
    elseif t.selected then
        bg_color = beautiful.bg_focus
    else
        bg_color = beautiful.bg_normal
    end
    self.bg = bg_color

    if #t:clients() > 0 then
        if t.selected then
            square = beautiful.taglist_squares_sel
        else
            square = beautiful.taglist_squares_unsel
        end
        if not (t.selected or t.urgent) then
            square = gears.color.recolor_image(square, beautiful.fg_normal)
        end
    end
    self:get_children_by_id("square_role")[1].image = square
end

local function add_tags_to_screen(tags, screen)
    for i, d in ipairs(tags) do
        local name, layout = table.unpack(d)
        local selected = i == 1 and true or false
        local gap_size = beautiful.useless_gap
        if layout.name == "max" or layout.name == "fullscreen" then
            gap_size = 0
        end
        awful.tag.add(name, {
            layout = layout,
            selected = selected,
            gap = gap_size,
            screen = screen,
        })
    end
end

-- create a taglist for the given screen
return function (screen)
    -- add tags
    add_tags_to_screen(tag_list[screen.position], screen)

    return awful.widget.taglist {
        screen  = screen,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
        widget_template = {
            {
                {
                    {
                        {
                            id = "text_role",
                            widget = wibox.widget.textbox
                        },
                        widget = wibox.container.margin,
                        bottom = 1
                    },
                    widget = wibox.container.place
                },
                {
                    {
                        id = "square_role",
                        widget = wibox.widget.imagebox,
                        resize = false
                    },
                    widget = wibox.container.place,
                    content_fill_vertical = true
                },
                layout = wibox.layout.stack,
                -- TODO: not super happy about forcing a width like this, is there another way?
                forced_width = 26
            },
            widget = wibox.container.background,
            create_callback = update_tag,
            update_callback = update_tag
        }
    }
end
