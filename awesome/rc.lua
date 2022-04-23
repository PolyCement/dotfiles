-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- widget library
local vicious = require("vicious")
-- shows hotkeys for the current client (if available) in the hotkeys popup
require("awful.hotkeys_popup.keys")
local calendar = require("awful.widget.calendar_popup")
-- it's back baby! fcitxmon: the sequel to mozcmon
local fcitxmon = require("fcitxmon")

-- set this to true to get spammed with debug notifications
local print_debug_info = false
 
-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Startup Error!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Error!",
                         text = tostring(err) })
        local logfile = io.open(".awesome.log", "a")
        logfile:write(tostring(err) .. "\n")
        logfile:close()
        in_error = false
    end)
end
-- }}}

-- start the compositor
-- i still don't know if this should be in here honestly
-- like, doesnt this mean that every time i restart awesome wm, i make *another* xcompmgr???
-- seems bad. imo.
awful.spawn.with_shell("xcompmgr &")

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/themes/default/theme.lua")

-- make notifications stay on screen longer
naughty.config.defaults.timeout = 10
naughty.config.defaults.position = "bottom_right"

-- hack to make discord notifications replace each other correctly
-- discord's notifications specify replaces_id, but the id never actually exists
-- this hack checks for replaces_id, then sets the id of the created notification
-- to that id
-- TODO: there's gotta be a better way to do this, one that works for any app
-- known bug: it's possible for the counter to get high enough that a notification is
-- created with the same id as a notification altered by this hack. not sure what'll happen then lol
-- NOTE: i think something changed here... lets go without for a while
--local old_notify = naughty.notify
--function naughty.notify(args)
--    local replaces_id = args.replaces_id
--    notification = old_notify(args)
--    if replaces_id then
--        notification.id = replaces_id
--    end
--    return notification
--end

-- get the hostname so i can turn stuff on or off for different machines
-- NOTE: awesome wm documentation says not to use io.popen because it's blocking
-- i'm using it *because* it's blocking - no further code should run until we have the hostname.
-- an alternative would be to export hostname as a var but... idk. might have to if this way is bad
-- ok so it looks like, at some point, awesome.hostname was added as a way to get the hostname
-- and waiting for the hard drive takes several seconds so lets try using this instead
-- if this works better then just delete this whole block and use awesome.hostname directly i guess
-- local f = io.popen("/bin/hostname")
-- local hostname = f:read("*a") or ""
-- f:close()
-- hostname = string.gsub(hostname, "\n$", "")
local hostname = awesome.hostname

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

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

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}

mysystemmenu = {
    { "suspend", "systemctl suspend" },
    { "shutdown", "shutdown now" },
    { "reboot", "reboot" }
}

-- some of these are specific to one machine,
-- there's gotta be a way to generate it semi-automatically
gamesmenu = {
    { "dolphin", "dolphin-emu" },
    { "ftb", "feedthebeast" },
    { "lutris", "lutris" },
    { "pcsx2", "PCSX2" },
    { "retroarch", "retroarch" },
    { "steam", "steam" },
    { "steam (native)", "steam-native" }
}

devmenu = {
    { "godot", "godot" },
    { "rpg maker mv", "steam-native steam://rungameid/363890" },
    { "tiled", "tiled" },
    { "unity", "unityhub" }
}

graphicsmenu = {
    { "aseprite", "aseprite" },
    { "gimp", "gimp" },
    { "inkscape", "inkscape" },
    { "krita", "krita" }
}

musicmenu = {
    { "jack", "qjackctl" },
    { "reaper", "reaper" },
    { "tenacity", "tenacity" },
}

workmenu = {
    { "slack", "slack" },
    { "zoom", "zoom" },
}

mymainmenu = awful.menu({
    items = {
        { "awesome",  myawesomemenu, beautiful.awesome_icon },
        { "system",   mysystemmenu },
        { "games",    gamesmenu },
        { "game dev", devmenu },
        { "graphics", graphicsmenu },
        { "music", musicmenu },
        { "work", workmenu },
        { "browser",  "firefox" },
        { "email",  "thunderbird" },
        { "chat",     "discord-accelerated" },
        { "terminal", terminal }
    }
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
-- blank space for padding
local pad_widget = wibox.widget.textbox(" ")
local div_widget = wibox.widget {
    {
        text = " | ",
        widget = wibox.widget.textbox
    },
    widget = wibox.container.margin,
    bottom = 4
}

-- textclock widget
local clock_widget = wibox.widget {
    {
        widget = wibox.widget.textclock,
        format = "🕒 %a %d %b, %H:%M"
    },
    widget = wibox.container.margin,
    bottom = 1
}
-- local clock_widget = wibox.widget.textclock("🕒 %m月%d日、%H:%M")

-- battery monitor, only used on doubleslap
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

-- it ain't pretty. but it works.
awful.widget.watch('bash -c "DEFAULT_SINK=$(pactl get-default-sink); pactl get-sink-mute $DEFAULT_SINK; pactl get-sink-volume $DEFAULT_SINK"', 5, function(widget, stdout)
    local mute, vol = stdout:match("Mute: (%a+).*%s(%d+%%).*")
    local icon = mute == "yes" and "🔇" or "🔊"
    widget:set_text(icon .. " " .. vol)
end, vol_widget_info)

-- volume control functions
local function change_volume(percent)
    -- first get the "symbolic name"(???) of the default sink
    local cmd = "pactl get-default-sink"
    awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr, reason, exit_code)
        -- then actually set the volume
        awful.spawn("pactl set-sink-volume " .. stdout .. " " .. percent)
        vicious.force({ vol_widget_info })
    end)
end

local function toggle_mute()
    -- more or less the same as above, but mute instead
    local cmd = "pactl get-default-sink"
    awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr, reason, exit_code)
        awful.spawn("pactl set-sink-mute " .. stdout .. " toggle")
        vicious.force({ vol_widget_info })
    end)
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

-- core temp widget
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

-- set up fcitx widget
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

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- add tags
    for i, d in ipairs(tag_list[s.index]) do
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

    s.mytaglist = awful.widget.taglist {
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
                -- not super happy about forcing a width like this, is there another way?
                forced_width = 26
            },
            widget = wibox.container.background,
            create_callback = update_tag,
            update_callback = update_tag
        }
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
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

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = 20 }) --, bg = beautiful.bg_minimize })

    -- build right widget table
    -- we only want most of these on 1 screen
    -- TODO: figure out how to get the rightmost screen specifically
    -- (indices are not necessarily tied to position)
    -- TODO: make this a function or something? it kinda sucks
    local right_widgets
    if s.index == screen:count() then
        -- for whatever reason the systray has to be told what screen to display on?
        local systray = wibox.widget.systray()
        systray:set_screen(s)

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
            s.mylayoutbox,
        })
    else
        right_widgets = {
            layout = wibox.layout.fixed.horizontal,
            s.mylayoutbox,
        }
    end

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        right_widgets
    }

    -- disable useless gaps when layout is set to maximized or fullscreen
    awful.tag.attached_connect_signal(s, "property::layout", function(t)
        if t.layout.name == "max" or t.layout.name == "fullscreen" then
            t.gap = 0
        else
            t.gap = beautiful.useless_gap
        end
    end)
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- brightness controls
    -- these are very basic and don't *really* work in a "normal" way
    -- brightness down applies redshift, brightness up removes it
    -- TODO: think of something better
    awful.key({ }, "XF86MonBrightnessUp", function()
        awful.spawn("redshift -x")
    end),
    awful.key({ }, "XF86MonBrightnessDown", function()
        awful.spawn("redshift -O 2700")
    end),

    -- volume controls
    awful.key({ }, "XF86AudioLowerVolume", function()
        change_volume("-5%")
    end),
    awful.key({ }, "XF86AudioRaiseVolume", function()
        change_volume("+5%")
    end),
    awful.key({ }, "XF86AudioMute", function()
        toggle_mute()
    end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = gears.filesystem.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    -- awful.key({ modkey }, "p", function() menubar.show() end,
    --        {description = "show the menubar", group = "launcher"}),
    -- screenshot all screens
    awful.key({ }, "Print", function()
        local timestamp = os.date("%y%m%d-%H%M%S")
        awful.spawn.with_shell("maim -u ~/pictures/screenshots/" .. timestamp .. ".png")
    end),
    -- screenshot only the current screen (ie. the one the cursor is over)
    awful.key({ "Shift" }, "Print", function()
        local geo = awful.screen.focused().geometry
        local geo_string = string.format("%sx%s+%s+%s", geo.width, geo.height, geo.x, geo.y)
        local timestamp = os.date("%y%m%d-%H%M%S")
        awful.spawn.with_shell(
            "maim -g " .. geo_string .. " -u ~/pictures/screenshots/" .. timestamp .. ".png"
        )
    end),
    -- screenshot a selected area (or window if you click instead of dragging)
    awful.key({ "Mod1" }, "Print", function()
        local timestamp = os.date("%y%m%d-%H%M%S")
        awful.spawn.with_shell("maim -u -s ~/pictures/screenshots/" .. timestamp .. ".png")
    end),
    awful.key({ modkey, "Shift" }, "o",
        function ()
            -- TODO: this is getting disgusting, maybe i should boot it to a bash script
            -- get the default sink
            local cmd_sink = "pactl get-default-sink"
            awful.spawn.easy_async_with_shell(cmd_sink, function(stdout, stderr, reason, exit_code)
                local default_sink = stdout:gsub("%s+", "")
                -- this command takes the output of pactl, cuts it down to only
                -- the default sink's info, then grabs the active port
                local cmd_port = "pactl list sinks | sed -n -e '/^\\s*Name: "
                                 .. default_sink .. "$/,/^$/s/^\\s*Active Port: //p'"
                awful.spawn.easy_async_with_shell(cmd_port, function(stdout, stderr, reason, exit_code)
                    if stdout:gsub("%s+", "") == "analog-output-lineout" then
                        awful.spawn("pactl set-sink-port " .. default_sink .. " analog-output-headphones")
                    else
                        awful.spawn("pactl set-sink-port " .. default_sink .. " analog-output-lineout")
                    end
                end)
            end)
        end,
         {description = "toggle output device", group = "audio"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
-- TODO: figure out something better for this with 2 displays
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- first, figure out what screen and tag firefox should be put on by default
local browserTag = (screen:count() > 1) and screen[2].tags[1] or screen[1].tags[2]
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = { },
        properties = { border_width = beautiful.border_width,
                       border_color = beautiful.border_normal,
                       focus = awful.client.focus.filter,
                       raise = true,
                       keys = clientkeys,
                       buttons = clientbuttons,
                       screen = awful.screen.preferred,
                       placement = awful.placement.no_offscreen+awful.placement.centered
        }
    },

    -- Floating clients.
    {
        rule_any = { class = { "SimpleScreenRecorder", "QjackCtl" }, instance = { "pavucontrol" } },
        properties = { floating = true }
    },

    -- make all unity windows but the main one float (otherwise loading bars etc look weird)
    -- will need to keep an eye out to make sure this doesn't float games made in unity,
    -- TODO: update this, the header text changed!!
    {
        rule = { class = "Unity" },
        except = { name = "Unity %- Unity.+PC, Mac & Linux Standalone.+" },
        properties = { floating = true }
    },

    -- make gimp's toolbox/docks remember their positions and stay on top
    {
        rule_any = { role = { "gimp-toolbox-1", "gimp-dock-1" } },
        properties = { ontop = true, placement = awful.placement.restore }
    },

    -- make tf2 (and presumably other source engine games) run in fullscreen
    -- this seems to screw up games that already fullscreen themselves.....
    {
        rule = { class = "hl2_linux" },
        -- properties = { fullscreen = true }
    },

    -- if we have 2 screens put firefox on s2t1, else s1t2
    {
        rule_any = { class = { "Firefox", "firefox" } },
        properties = { tag = browserTag }
    },

    -- make firefox windows other than the main one float
    {
        rule_any = { class = { "Firefox", "firefox" } },
        except = { instance = "Navigator" },
        properties = { floating = true }
    },

    -- ignore discord's size hints, put it on home tag
    -- TODO: is there any way to force this to always start up on the right?
    {
        rule = { class = "discord" },
        properties = { size_hints_honor = false, tag = screen[1].tags[1] }
    },

    -- godot.....
    -- TODO: make sure this doesn't apply to games made in godot
    {
        rule = { class = "Godot" },
        properties = { floating = true }
    },

    -- steam always goes on tag 3
    {
        rule = { class = "Steam" },
        properties = { tag = screen[1].tags[3] }
    }

    -- Add titlebars to normal clients and dialogs
--     {
--         rule_any = { type = { "normal", "dialog" } },
--         properties = { titlebars_enabled = true }
--     },

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end

    -- for whatever reason, fullscreen apps end up kinda shoved off the screen
    -- this just shoves em back into the right position
    -- i feel like it's probably not the *right* solution. but it works,
    if c.fullscreen then
        c.x = 0
        c.y = 0
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
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
-- TODO: maybe figure out if there's a way to add just the close button on floating clients
-- a lot of apps like to just not have them on dialogues etc and then i have to roll the dice on
-- whether ctrl+meta+c will close just the selected client or the entire fucking app
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
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
end)

-- godot uses a single client from the splash screen through the project manager, all the way to the main editor view
-- this hack stops godot from maximising itself on the way there (and toggles floating off, since that's set above)
-- the second splash screen will still maximise itself but it's there for like 1 second so w/e
-- the godot_hack variable stops this from triggering more than once per client, allowing it to be maximised manually
client.connect_signal("property::name", function(c)
    if c.class == "Godot" and not c.godot_hack then
        if c.name and c.name:find("Godot Engine - ") and not c.name:find("Project Manager") then
            c.maximized = false
            c.floating = false
            c.godot_hack = true
        end
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal("mouse::enter", function(c)
--     if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
--         and awful.client.focus.filter(c) then
--         client.focus = c
--     end
-- end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
