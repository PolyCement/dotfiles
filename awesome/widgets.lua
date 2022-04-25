local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local spacers = require("splitwidgets.spacers")
local clock_widget = require("splitwidgets.clock")
local bat_widget = nil
if hostname == "doubleslap" then
     bat_widget = require("splitwidgets.battery")
end
local vol_widget = require("splitwidgets.volume")
local temp_widget = require("splitwidgets.temperature")(
    hostname == "cometpunch" and "thermal_zone2" or "thermal_zone0"
)
local fcitx_widget = require("splitwidgets.fcitx")

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

-- {{{ Helper functions
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
-- }}}

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
    end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- list of tags to add to each screen
-- TODO: maybe switch the symbols up, the inner planet ones look a bit shit
-- (on second thought i might just use svgs or something)
local tag_list = {
    {
        { " ☿ ", awful.layout.layouts[2] },
        { " ♀ ", awful.layout.layouts[6] },
        { " ♁ ", awful.layout.layouts[6] },
        { " ♂ ", awful.layout.layouts[6] }
    },
    {
        { " ♃ ", awful.layout.layouts[6] },
        { " ♄ ", awful.layout.layouts[6] },
        { " ♅ ", awful.layout.layouts[6] },
        { " ♆ ", awful.layout.layouts[6] }
    }
}

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

-- create a taglist for the given screen
local function create_taglist(screen)
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

local function create_tasklist(screen)
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

-- build right widget table
-- we only want most of these on 1 screen
local function create_right_widgets(screen, is_last)
    local right_widgets
    if is_last then
        -- for whatever reason the systray has to be told what screen to display on?
        local systray = wibox.widget.systray()
        systray:set_screen(screen)

        right_widgets = {
            layout = wibox.layout.fixed.horizontal,
            spacers.pad_widget,
            systray,
            spacers.div_widget,
            fcitx_widget
        }
        if bat_widget ~= nil then
            gears.table.merge(right_widgets, {
                spacers.div_widget,
                bat_widget
            })
        end
        gears.table.merge(right_widgets, {
            spacers.div_widget,
            temp_widget,
            spacers.div_widget,
            vol_widget,
            spacers.div_widget,
            clock_widget,
            spacers.pad_widget,
            screen.mylayoutbox,
        })
    else
        right_widgets = {
            layout = wibox.layout.fixed.horizontal,
            screen.mylayoutbox,
        }
    end
    return right_widgets
end

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- add tags
    add_tags_to_screen(tag_list[s.index], s)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function () awful.layout.inc( 1) end),
        awful.button({ }, 3, function () awful.layout.inc(-1) end),
        awful.button({ }, 4, function () awful.layout.inc( 1) end),
        awful.button({ }, 5, function () awful.layout.inc(-1) end)
    ))

    -- Create a taglist widget
    local mytaglist = create_taglist(s)

    -- Create a tasklist widget
    local mytasklist = create_tasklist(s)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = 20 }) --, bg = beautiful.bg_minimize })

    -- create right widgets
    -- TODO: figure out how to get the rightmost screen specifically
    -- (indices are not necessarily tied to position)
    local right_widgets = create_right_widgets(s, s.index == screen:count())

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            mytaglist,
            s.mypromptbox,
        },
        mytasklist, -- Middle widget
        right_widgets
    }

    -- disable useless gaps when layout is set to maximized or fullscreen
    -- TODO: should this even be in here?
    awful.tag.attached_connect_signal(s, "property::layout", function(t)
        if t.layout.name == "max" or t.layout.name == "fullscreen" then
            t.gap = 0
        else
            t.gap = beautiful.useless_gap
        end
    end)
end)
