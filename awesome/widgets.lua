local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local calendar = require("awful.widget.calendar_popup")
-- widget library i'm slowly replacing with my own custom code
local vicious = require("vicious")
-- custom monitors for events i want to update based on events rather than timers
local fcitxmon = require("monitors.fcitxmon")
local volmon = require("monitors.volmon")

-- widgets for spacing and dividers
local pad_widget = wibox.widget.textbox(" ")
local div_widget = wibox.widget {
    {
        text = " | ",
        widget = wibox.widget.textbox
    },
    widget = wibox.container.margin,
    bottom = 4
}

-- clock widget
local clock_widget = wibox.widget {
    {
        widget = wibox.widget.textclock,
        format = "🕒 %a %d %b, %H:%M"
    },
    widget = wibox.container.margin,
    bottom = 1
}

-- battery widget, only used on doubleslap
-- TODO: make sure the margin looks right on doubleslap
local bat_widget = nil
if hostname == "doubleslap" then
    local bat_widget_info = wibox.widget.textbox()
    bat_widget = wibox.widget {
        {
            widget = bat_widget_info
        },
        widget = wibox.container.margin,
        bottom = 1
    }
    -- has the low power warning been shown yet?
    local low_power_warning_shown = false
    vicious.register(bat_widget_info, vicious.widgets.bat, function (widget, args)
        -- /!\ GOOD PROGRAMMER ALERT /!\
        -- when power drops below 15%, spawn a notification warning me about it
        -- todo: move this literally anywhere else cos it sure as hell shouldn't be tacked on here
        if args[1] == "-" then
            if args[2] <= 15 and not low_power_warning_shown then
                low_power_warning_shown = true
                naughty.notify({ preset = naughty.config.presets.critical,
                                 title = "Warning! Battery Low!",
                                 text = args[2] .. "% power remaining" })
            end
        else
            low_power_warning_shown = false
        end
        local icon = args[1] == "-" and "🔋" or "🔌"
        return icon .. " " .. args[2] .. "%"
    end, 30, "BAT0")
end

-- volume widget
local vol_widget_info = wibox.widget.textbox()
local vol_widget = wibox.widget {
    {
        widget = vol_widget_info
    },
    widget = wibox.container.margin,
    bottom = 1
}
volmon.register(vol_widget_info, function(vol, mute)
    local icon = mute and "🔇" or "🔊"
    return icon .. " " .. vol .. "%"
end)
volmon.start()

-- volume control functions
local function change_volume(percent)
    awful.spawn.with_shell("pactl set-sink-volume $(pactl get-default-sink) " .. percent)
end

local function toggle_mute()
    awful.spawn.with_shell("pactl set-sink-mute $(pactl get-default-sink) toggle")
end

vol_widget:buttons(gears.table.join(
    awful.button({ }, 1, function()
        awful.spawn("pavucontrol")
    end),
    awful.button({ }, 3, function()
        toggle_mute()
    end),
    awful.button({ }, 4, function()
        change_volume("+5%")
    end),
    awful.button({ }, 5, function()
        change_volume("-5%")
    end)
))

-- temp widget (only monitors cpu since that's where my cooling is usually weakest)
local temp_widget_info = wibox.widget.textbox()
-- rename to temp_container or some shit idk
local temp_widget = wibox.widget {
    {
        {
            {
                widget = wibox.widget.textbox,
                text = "🌡",
                font = "sans 6",
                valign = "center"
            },
            widget = wibox.container.place,
            valign = "bottom"
        },
        widget = wibox.container.background,
    },
    {
        {
            widget = temp_widget_info
        },
        widget = wibox.container.margin,
        bottom = 1
    },
    layout = wibox.layout.fixed.horizontal
}
local thermal_zone = hostname == "cometpunch" and "thermal_zone2" or "thermal_zone0"
vicious.register(temp_widget_info, vicious.widgets.thermal, " $1°C", 19, thermal_zone)

-- input method editor (fcitx) widget
local fcitx_widget_info = wibox.widget.textbox()
local fcitx_widget = wibox.widget {
    {
        {
            widget = wibox.widget.textbox,
            text = "⌨ "
        },
        widget = wibox.container.margin,
        bottom = 1
    },
    {
        {
            widget = fcitx_widget_info
        },
        widget = wibox.container.margin,
        bottom = 1
    },
    widget = wibox.layout.fixed.horizontal
}
fcitxmon.register(fcitx_widget_info, function(state)
    local indicator_char
    if state == 0 then
        indicator_char = "Ｘ"
    elseif state == 1 then
        indicator_char = "ー"
    elseif state == 2 then
        indicator_char = "あ"
    end
    return indicator_char
end)
fcitxmon.start()

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

        -- this has to be defined here because we need to tell it what screen to show up on,
        local calendar_popup = calendar.month({ screen = s })
        calendar_popup:attach(clock_widget, "tr")

        right_widgets = {
            layout = wibox.layout.fixed.horizontal,
            pad_widget,
            systray,
            div_widget,
            fcitx_widget
        }
        if bat_widget ~= nil then
            gears.table.merge(right_widgets, {
                div_widget,
                bat_widget
            })
        end
        gears.table.merge(right_widgets, {
            div_widget,
            temp_widget,
            div_widget,
            vol_widget,
            div_widget,
            clock_widget,
            pad_widget,
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
