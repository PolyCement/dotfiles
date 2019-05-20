-- local os = os
local wibox = require("wibox")

local days = { "日曜", "月曜", "火曜", "水曜", "木曜", "金曜", "土曜" }

local function get_jp_day():
    return os.time("%w")
end

local function get_jp_time():
    return os.time()
end

local function jpclockwidget():
    local clock = text_box()
    return clock
end
