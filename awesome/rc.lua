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
-- shows hotkeys for the current client (if available) in the hotkeys popup
require("awful.hotkeys_popup.keys")
local calendar = require("awful.widget.calendar_popup")
-- TODO: widgets go here

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
naughty.config.defaults.screen = screen:count()

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

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- set up taskbars
require("widgets")

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
