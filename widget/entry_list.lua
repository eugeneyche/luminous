local capi = {
    client = client,
    mouse = mouse,
    screen = screen
}

local setmetatable = setmetatable
local awful = require("awful")
local theme = require("beautiful")
local wibox = require("wibox")
local naughty = require("naughty")

local entry_list = { mt = {} }

function entry_list:update(modifiers, key, event)
    -- check for press
    if event ~= 'press' then return end
    -- check for mod (will change later)
    local mod = {}
    for _, v in ipairs(modifiers) do mod[v] = true end
    if mod.Mod4 or mod.Mod1 then return end
    if mod.Control then
        if key == "j" then
            self.cursor = 1
        end
        if key == "k" then
            self.cursor = self.query:len() + 1
        end
    end
    self:show()
end


function entry_list:show()
    function make_entry(value)
        local tb = wibox.widget.textbox(value)
        local m = wibox.layout.margin(tb, 4, 4, 4, 4)
        local bgb = wibox.widget.background(m, "#443355")
        local entry_ = {
            widget = bgb
        }
        return entry_
    end
    self.layout:reset()
    for _, v in pairs(self.entry_values) do
        self.layout:add(make_entry(v).widget)
    end
end

function entry_list.new(...)
    local la = wibox.layout.fixed.vertical()
    local bgb = wibox.widget.background(la, "#ffff00")
    local entry_list_ = {
        entry_values = {},
        show = entry_list.show,
        update = entry_list.update,
        -- widgets
        layout = la,
        widget = bgb,
        -- callbacks
    }
    return entry_list_
end

function entry_list.mt:__call(...)
    return entry_list.new(...)
end

return setmetatable(entry_list, entry_list.mt)

