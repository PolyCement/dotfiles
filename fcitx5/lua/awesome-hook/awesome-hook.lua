local fcitx = require('fcitx')

-- simple fcitx plugin for tracking im state and updating my fcitx widget in awesomewm
-- ideally i'd be able to just watch for dbus events like i did with the old version of fcitx,
-- but fcitx5 doesn't output dbus events reliably (no event fires when i change im in a terminal, for example)

-- figure out which input method is active
-- i'd just use fcitx.currentInputMethod() for this, but when no im is active it returns whichever
-- one was last active instead. tracking it internally lets me work around that,
local im_states = {}
function determineActiveIM()
    local active_im = 'none'
    for key, value in pairs(im_states) do
        if value then
            active_im = key
        end
    end
    return active_im
end

-- update the awm widget
-- TODO: can i just make this like, put out events on dbus or something instead of directly calling a function,
-- (really not happy about directly calling a function...)
-- TODO: the handlers often get called a bunch of times in succession - maybe track the previous state
-- and only update if the state actually changed? or maybe debounce it??
function updateWidget(active_im)
    local file = io.popen(
        [[echo -e 'update_fcitx_widget("]] .. active_im .. [[")' | awesome-client]], 'r'
    )
    local output = file:read('*all')
    file:close()
end

-- event handlers
local function inputMethodStateChangeHandler(im_name, state)
    im_states[im_name] = state
    updateWidget(determineActiveIM())
    return false
end

-- NOTE: these have to be public or fcitx can't access them (why can't watchEvent() take a function directly??)
function inputMethodActivatedHandler(im_name)
    inputMethodStateChangeHandler(im_name, true)
end

function inputMethodDeactivatedHandler(im_name)
    inputMethodStateChangeHandler(im_name, false)
end

-- hook the handlers into fcitx
fcitx.watchEvent(fcitx.EventType.InputMethodActivated, 'inputMethodActivatedHandler')
fcitx.watchEvent(fcitx.EventType.InputMethodDeactivated, 'inputMethodDeactivatedHandler')
