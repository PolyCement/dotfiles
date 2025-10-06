local awful = require("awful")

local function is_installed(command, callback)
    awful.spawn.easy_async_with_shell("command -v " .. command, function (stdout, stderr, reason, exit_code)
        callback(exit_code == 0)
    end)
end

return { is_installed = is_installed }
