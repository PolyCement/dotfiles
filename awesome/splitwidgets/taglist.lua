local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- more stuff for handling 1 or 2 monitors. again, will need changing if i ever end up with 3

-- tag layouts for each screen. "single" will be used when there's only one monitor
local tag_layouts = {
    single = {
        awful.layout.layouts[2],
        awful.layout.layouts[6],
        awful.layout.layouts[6],
        awful.layout.layouts[6]
    },
    primary = {
        awful.layout.layouts[6],
        awful.layout.layouts[6],
        awful.layout.layouts[6],
        awful.layout.layouts[6]
    },
    secondary = {
        awful.layout.layouts[2],
        awful.layout.layouts[6],
        awful.layout.layouts[6],
        awful.layout.layouts[6]
    }
}

-- icons for each screen, from left to right
-- TODO: use svgs or something? the characters for the inner planets display badly with the font i use
-- (especially venus and earth, which seem taller and have weird baselines)
local tag_icons = {
    { " ☿ ", " ♀ ", " ♁ ", " ♂ " },
    { " ♃ ", " ♄ ", " ♅ ", " ♆ " }
}

-- buttons for each taglist
local taglist_buttons = gears.table.join(
    -- view only this tag
    awful.button({}, 1, function (t) t:view_only() end),
    -- move client to tag (i didn't know this was a thing!)
    awful.button({ modkey }, 1, function (t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    -- view this tag as well
    awful.button({}, 3, awful.tag.viewtoggle),
    -- put client on this tag as well
    awful.button({ modkey }, 3, function (t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    -- scroll through tags
    awful.button({}, 4, function (t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function (t) awful.tag.viewprev(t.screen) end)
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

    -- TODO: i'm pretty sure "square" is a holdover from the default config,
    -- i've been using triangles for years, so maybe change the names up here and in theme.lua?
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

-- create and add tags to the screen based on the given table of { icon, layout } tables
local function add_tags_to_screen(tags, s)
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
            screen = s,
        })
    end
end

-- returns a table of { icon, layout } tables defining the icon and layout for each tag, based on:
--   - the number of screens,
--   - the screen's position (ie. left or right), and
--   - whether the screen is primary or not
local function get_tag_defs_for_screen(s)
    -- figure out which icons to use, based on position
    local icons = tag_icons[1]
    if s:get_next_in_direction("left") then
        icons = tag_icons[2]
    end

    -- then figure out which default layouts to use, based on screen count and primary status
    local layouts = tag_layouts.single
    if screen:count() > 1 then
        if s == screen.primary then
            layouts = tag_layouts.primary
        else
            layouts = tag_layouts.secondary
        end
    end

    -- and zip em up
    local defs = {}
    for idx, icon in ipairs(icons) do
        table.insert(defs, { icon, layouts[idx] })
    end

    return defs
end

-- create a taglist for the given screen
return function (s)
    -- add tags
    add_tags_to_screen(get_tag_defs_for_screen(s), s)

    return awful.widget.taglist {
        screen  = s,
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
