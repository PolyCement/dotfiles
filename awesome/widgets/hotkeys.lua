-- wrapper for the hotkeys popup widget
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- shows hotkeys for the current client in the hotkeys popup, if available
-- i'm not really sure if this needs to be a straight require like this? docs aren't great on it
-- hopefully there's another way, i'd like to keep the split out parts of the config as modular as possible...
require("awful.hotkeys_popup.keys")

return hotkeys_popup
