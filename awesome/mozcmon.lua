-- mozcmon.lua
-- an awesome wm plugin that reads mozc's current input mode from uim
-- you can register a textbox widget with this plugin and it'll update whenever input mode changes
-- heavily based on uim.lua (https://github.com/kiike/dotfiles/blob/master/awesome/uim.lua)
-- original credits: psychon, Enric Morales
-- hammered into a terrible new form by: polycement

-- === widget notes ===
-- format strings work kinda like vicious - $1, $2 and $3 will be replaced as follows:
-- $1 - mode name in english (eg. jp_direct, jp_hiragana, etc)
-- $2 - character representation of the current mode (eg. -, あ, ア, etc)
-- $3 - mode name in japanese (eg. 直接入力, ひらがな, etc)
-- a function can be passed instead, which will receive the 3 values above as a table, "args"
-- in this case, the returned string will be set as the widget text

-- lua libraries:
-- awesome wm already requires lgi, so we might as well use it for reading sockets in here
-- naughty is just for the error notifications, so it's not *strictly* necessary
local glib = require("lgi").GLib
local gio = require("lgi").Gio
local naughty = require("naughty")

-- tracking for registered widgets
local registered_widgets = {}

local mozcmon = {}

-- register a widget to be updated by mozcmon
mozcmon.register = function (w, format)
    table.insert(registered_widgets, { w, format or "%s" })
end

-- call this to start listening to the socket
mozcmon.start = function ()
    local runtime_dir = os.getenv("XDG_RUNTIME_DIR")
    local socket_path = string.format("%s/uim/socket/uim-helper", runtime_dir)

    local socket = gio.Socket.new(gio.SocketFamily.UNIX, gio.SocketType.STREAM, gio.SocketProtocol.DEFAULT)

    -- connect to the socket, returning false indicates failure
    local success = socket:connect(gio.UnixSocketAddress.new(socket_path))
    if not success then
        return false
    end

    local fd = socket:get_fd()
    local stream = gio.DataInputStream.new(gio.UnixInputStream.new(fd, false))
    local start_read, finish_read

    -- listen for uim to broadcast a mode switch, then...
    start_read = function()
        stream:read_line_async(glib.PRIORITY_DEFAULT, nil, finish_read)
    end

    -- ...take the string and use it to update the widget text
    -- NOTE: this runs once per line of output, but only one line will (should!) match the regex
    -- so it should still only update once. i think.
    finish_read = function(obj, res)
        local line, length = obj:read_line_finish(res)
        if type(length) ~= "number" then
            -- error messages (these are holdovers from uim.lua)
            naughty.notify({title="mozcmon", text="Read Error: " .. tostring(length)})
            stream:close()
            socket:shutdown(true, true)
        elseif #line ~= length then
            naughty.notify({title="mozcmon", text="Read Error: End of file"})
            stream:close()
            socket:shutdown(true, true)
        else
            local b_name, b_char, b_jp = string.match(line, "branch%s+([^%s]+)%s+([^%s]+)%s+([^%s]+)")
            if b_name then
                for _, r in pairs(registered_widgets) do
                    local widget, format = unpack(r)
                    if type(format) == "string" then
                        -- swap out placeholders for args
                        -- simplistic, but anything more would be overcomplication
                        local formatted = string.gsub(format, "$1", b_name)
                        formatted = string.gsub(formatted, "$2", b_char)
                        formatted = string.gsub(formatted, "$3", b_jp)
                        widget:set_text(formatted)
                    elseif type(format) == "function" then
                        -- i'm kinda mimicking how vicious does this, not sure it needs to be so similar tho
                        widget:set_text(format({ b_name, b_char, b_jp }))
                    end
                end
            end
            -- continue the loop
            start_read()
        end
    end

    -- start looping
    start_read()

    return true
end

return mozcmon
