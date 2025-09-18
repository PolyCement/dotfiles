-- global keybinds
local gears = require("gears")
local awful = require("awful")
local menu = require("menu")
local hotkeys_widget = require("widgets.hotkeys")
local volmon = require("monitors.volmon")
local systray = require("widgets.systray")

modkey = "Mod4"

-- function for taking screenshots. maybe move it somewhere else?
local function screenshot(maim_args)
    local maim_args = maim_args or ""
    local directory = "~/pictures/screenshots/" .. os.date("%y-%m")
    local filepath = directory .. "/" .. os.date("%y%m%d-%H%M%S") .. ".png"
    awful.spawn.with_shell("mkdir -p " .. directory .. "; maim -u " .. maim_args .. " " .. filepath)
end

-- define a function for switching default audio sink port (or just sink on cometpunch)
-- TODO: clean this up somehow,
-- TODO: the scarlett's name keeps changing whenever i update, work out a fix...?
local speakers_sink = "alsa_output.pci-0000_00_1b.0.analog-stereo"
local headphones_sink =
    "alsa_output.usb-Focusrite_Scarlett_2i4_USB-00.HiFi__Line1__sink"
    -- "alsa_output.usb-Focusrite_Scarlett_2i4_USB-00.HiFi__scarlett2i_stereo_out_USB_0_0_1__sink"
local toggle_headphones

if awesome.hostname == "cometpunch" then
    -- define toggle_headphones() to switch sink
    -- easyeffects will switch preset automatically, so i don't have to handle that here anymore
    toggle_headphones = function ()
        -- get the current default sink
        awful.spawn.easy_async_with_shell(
            "pactl get-default-sink",
            function (stdout, stderr, reason, exit_code)
                -- now switch to whatever sink isn't currently the default
                if stdout:gsub("%s+", "") == speakers_sink then
                    awful.spawn("pactl set-default-sink " .. headphones_sink)
                else
                    awful.spawn("pactl set-default-sink " .. speakers_sink)
                end
            end
        )
    end
else
    -- define toggle_headphones() to switch port
    -- easyeffects won't switch preset automatically based on active port so i still gotta do it manually,
    -- TODO: is there really no way to switch preset automatically based on ports?? maybe i should open an issue,
    -- TODO: check this works on firepunch? it should be fine...
    toggle_headphones = function ()
        awful.spawn.easy_async_with_shell(
            "pactl list sinks | sed -n -e '/^\\s*Name: " .. speakers_sink .. "$/,/^$/s/^\\s*Active Port: //p'",
            function (stdout, stderr, reason, exit_code)
                if stdout:gsub("%s+", "") == "analog-output-speaker" then
                    awful.spawn("pactl set-sink-port " .. speakers_sink .. " analog-output-headphones")
                    awful.spawn("easyeffects -l Headphones")
                else
                    awful.spawn("pactl set-sink-port " .. speakers_sink .. " analog-output-speaker")
                    -- also enable easyeffects global bypass
                    awful.spawn("easyeffects -l Speakers")
                end
            end
        )
    end
end

-- new stuff for backlights
local change_brightness
if awesome.hostname == "doubleslap" or awesome.hostname == "firepunch" then
    local brightness_path
    local max_brightness_path
    -- NOTE: the user needs write permissions on the brightness file for this to work
    -- TODO: add the udev thing that does that to the repo?
    if awesome.hostname == "firepunch" then
        brightness_path = "/sys/class/backlight/amdgpu_bl1/brightness"
        max_brightness_path = "/sys/class/backlight/amdgpu_bl1/max_brightness"
    else
        brightness_path = "/sys/class/backlight/intel_backlight/brightness"
        max_brightness_path = "/sys/class/backlight/intel_backlight/max_brightness"
    end

    -- reads brightness from the given file, then passes it to the callback function
    local function with_brightness (brightness_file_path, callback)
        awful.spawn.easy_async_with_shell(
            "cat " .. brightness_file_path,
            function (stdout, stderr, reason, exit_code) callback(tonumber(stdout)) end
        )
    end

    -- initialise max (and min) brightness. min brightness is 20% (for now)
    -- there's no guarantee this will finish running before change_brightness is called, but it's pretty low risk
    -- and it saves me having to read max brightness again each time...
    -- TODO: maybe i should still add a warning if change_brightness runs without these being set though,
    local max_brightness
    local min_brightness

    with_brightness(max_brightness_path, function (brightness)
        max_brightness = brightness
        min_brightness = max_brightness // 20
    end)

    -- reads the current brightness and changes it by the given percentage of the max brightness
    -- TODO: maybe add some kind of exponential (log?) scale so it feels smoother? idk
    change_brightness = function (percentage_amount)
        local amount = tonumber((percentage_amount:gsub("%%$", "")))
        with_brightness(
            brightness_path,
            function (brightness)
                local new_brightness = brightness + max_brightness // 100 * amount
                local clamped_brightness = math.min(math.max(new_brightness, min_brightness), max_brightness)
                awful.spawn.with_shell("echo " .. clamped_brightness .. " > " .. brightness_path)
            end
        )
    end
end

local globalkeys = gears.table.join(
    -- meta stuff
    awful.key(
        { modkey }, "s",
        hotkeys_widget.show_help,
        { description = "show help", group = "awesome" }
    ),
    awful.key(
        { modkey }, "w",
        function () menu:show() end,
        { description = "show main menu", group = "awesome" }
    ),
    awful.key(
        { modkey }, "Return",
        function () awful.spawn(terminal) end,
        { description = "open a terminal", group = "launcher" }
    ),
    awful.key(
        { modkey, "Control" }, "r",
        awesome.restart,
        { description = "reload awesome", group = "awesome" }
    ),
    awful.key(
        { modkey, "Shift" }, "q",
        awesome.quit,
        { description = "quit awesome", group = "awesome" }
    ),
    -- toggle systray visibility
    awful.key(
        { modkey }, "=",
        systray.toggle_systray,
        { description = "toggle systray", group = "awesome" }
    ),

    -- tag switching
    awful.key(
        { modkey }, "Left",
        awful.tag.viewprev,
        { description = "view previous", group = "tag" }
    ),
    awful.key(
        { modkey }, "Right",
        awful.tag.viewnext,
        { description = "view next", group = "tag" }
    ),
    awful.key(
        { modkey }, "Escape",
        awful.tag.history.restore,
        { description = "go back", group = "tag" }
    ),

    -- client manipulation
    awful.key(
        { modkey }, "j",
        function () awful.client.focus.byidx(1) end,
        { description = "focus next by index", group = "client" }
    ),
    awful.key(
        { modkey }, "k",
        function () awful.client.focus.byidx(-1) end,
        { description = "focus previous by index", group = "client" }
    ),
    awful.key(
        { modkey, "Shift" }, "j",
        function () awful.client.swap.byidx(1) end,
        { description = "swap with next client by index", group = "client" }
    ),
    awful.key(
        { modkey, "Shift" }, "k",
        function () awful.client.swap.byidx(-1) end,
        { description = "swap with previous client by index", group = "client" }
    ),
    awful.key(
        { modkey }, "u",
        awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }
    ),
    awful.key(
        { modkey }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "go back", group = "client" }
    ),
    awful.key(
        { modkey, "Control" }, "n",
        function ()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                client.focus = c
                c:raise()
            end
        end,
        { description = "restore minimized", group = "client" }
    ),

    -- screen switching
    -- TODO: is there some way i can add screen swapping like there is for clients?
    -- TODO: turns out this does actually swap screen focus even when there's no clients
    -- is there some way to like. indicate what screen has focus in that case?
    -- (maybe the non-focused screens have a darker bg colour for their active tag?)
    awful.key(
        { modkey, "Control" }, "j",
        function () awful.screen.focus_relative(1) end,
        { description = "focus the next screen", group = "screen" }
    ),
    awful.key(
        { modkey, "Control" }, "k",
        function () awful.screen.focus_relative(-1) end,
        { description = "focus the previous screen", group = "screen" }
    ),

    -- layout manipulation
    awful.key(
        { modkey }, "l",
        function () awful.tag.incmwfact(0.05) end,
        { description = "increase master width factor", group = "layout" }
    ),
    awful.key(
        { modkey }, "h",
        function () awful.tag.incmwfact(-0.05) end,
        { description = "decrease master width factor", group = "layout" }
    ),
    awful.key(
        { modkey, "Shift" }, "h",
        function () awful.tag.incnmaster(1, nil, true) end,
        { description = "increase the number of master clients", group = "layout" }
    ),
    awful.key(
        { modkey, "Shift" }, "l",
        function () awful.tag.incnmaster(-1, nil, true) end,
        { description = "decrease the number of master clients", group = "layout" }
    ),
    awful.key(
        { modkey, "Control" }, "h",
        function () awful.tag.incncol(1, nil, true) end,
        { description = "increase the number of columns", group = "layout" }
    ),
    awful.key(
        { modkey, "Control" }, "l",
        function () awful.tag.incncol(-1, nil, true) end,
        { description = "decrease the number of columns", group = "layout" }
    ),
    awful.key(
        { modkey }, "space",
        function () awful.layout.inc(1) end,
        { description = "select next", group = "layout" }
    ),
    awful.key(
        { modkey, "Shift" }, "space",
        function () awful.layout.inc(-1) end,
        { description = "select previous", group = "layout" }
    ),

    -- prompt
    awful.key(
        { modkey }, "r",
        function () awful.screen.focused().mypromptbox:run() end,
        { description = "run prompt", group = "launcher" }
    ),
    -- NOTE: i don't think i've ever used this even once,
    awful.key(
        { modkey }, "x",
        function ()
            awful.prompt.run {
              prompt       = " Run Lua code: ",
              textbox      = awful.screen.focused().mypromptbox.widget,
              exe_callback = awful.util.eval,
              history_path = gears.filesystem.get_cache_dir() .. "/history_eval"
            }
        end,
        { description = "lua execute prompt", group = "awesome" }
    ),

    -- screenshots
    -- screenshot all screens
    awful.key({ }, "Print", screenshot),
    -- screenshot only the current screen (ie. the one the cursor is over)
    awful.key({ "Shift" }, "Print", function ()
        local geo = awful.screen.focused().geometry
        local geo_string = string.format("%sx%s+%s+%s", geo.width, geo.height, geo.x, geo.y)
        screenshot("-g " .. geo_string)
    end),
    -- screenshot a selected area (or window if you click instead of dragging)
    awful.key({ "Mod1" }, "Print", function () screenshot("-s -n 1") end),

    -- switch default audio sink
    awful.key(
        { modkey, "Shift" }, "o",
        toggle_headphones,
        { description = "toggle output device", group = "audio" }
    )
)

-- laptop-specific keybinds
-- TODO: might be nice to have some way to just do like "is this a laptop"...?
if awesome.hostname == "doubleslap" or awesome.hostname == "firepunch" then
    globalkeys = gears.table.join(
        globalkeys,

        -- brightness controls
        awful.key(
            {}, "XF86MonBrightnessUp",
            function () change_brightness("20%") end,
            { description = "increase brightness", group = "monitor" }
        ),
        awful.key(
            {}, "XF86MonBrightnessDown",
            function () change_brightness("-20%") end,
            { description = "decrease brightness", group = "monitor" }
        ),

        -- volume controls
        awful.key(
            {}, "XF86AudioLowerVolume",
            function () volmon.change_volume("-5%") end,
            { description = "increase volume", group = "audio" }
        ),
        awful.key(
            {}, "XF86AudioRaiseVolume",
            function () volmon.change_volume("+5%") end,
            { description = "decrease volume", group = "audio" }
        ),
        awful.key(
            {}, "XF86AudioMute",
            function () volmon.toggle_mute() end,
            { description = "toggle mute", group = "audio" }
        ),

        -- media controls
        awful.key(
            {}, "XF86AudioPlay",
            function () awful.spawn.with_shell("playerctl play-pause") end,
            { description = "play/pause media", group = "media" }
        ),
        awful.key(
            {}, "XF86AudioNext",
            function () awful.spawn.with_shell("playerctl next") end,
            { description = "next media item", group = "media" }
        ),
        awful.key(
            {}, "XF86AudioPrev",
            function () awful.spawn.with_shell("playerctl previous") end,
            { description = "previous media item", group = "media" }
        )
    )
end

-- bind key numbers to tags
-- the default config says "Be careful: we use keycodes to make it works on any keyboard layout."
-- but i have no idea what the fuck that means. these don't map to any keycodes i know of
-- TODO: figure out something better for this with 2 displays
-- also see if there's a way to make 1-4 map to screen 1's tags and 5-8 map to screen 2's tags?
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- show only this tag
        -- don't think i've ever used this (or at least, not on purpose lmao)
        awful.key(
            { modkey }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                   tag:view_only()
                end
            end,
            { description = "view tag #"..i, group = "tag" }
        ),
        -- show this tag
        awful.key(
            { modkey, "Control" }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                   awful.tag.viewtoggle(tag)
                end
            end,
            { description = "toggle tag #" .. i, group = "tag" }
        ),
        -- move focused client to this tag
        awful.key(
            { modkey, "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
               end
            end,
            { description = "move focused client to tag #"..i, group = "tag" }
        ),
        -- put focused client on this tag as well (ie. make it exist on both)
        -- haven't ever used this one either,
        awful.key(
            { modkey, "Control", "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            { description = "toggle focused client on tag #" .. i, group = "tag" }
        )
    )
end

return globalkeys
