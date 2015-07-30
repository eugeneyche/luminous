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

function entry_list:on_key(modifiers, key, event)
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


function entry_list:update_entries(new_entries)
    self.entry_values = new_entries
end


function entry_list:show()
    local max_entries = 15
    local function update_entry_widgets()
        local function make_entry_widget()
            local tb = wibox.widget.textbox("> ")
            local m = wibox.layout.margin(tb, 4, 4, 4, 4)
            local bgb = wibox.widget.background(m, "#334455")
            
            local entry_ = {
                widget = bgb,
                textbox = tb,
            }
            return entry_
        end
        local num_widgets = 0
        local num_values = 0
        for i,_ in ipairs(self.entry_widgets) do
            num_widgets = num_widgets + 1
        end
        for i,_ in ipairs(self.entry_values) do
            if num_values == max_entries then break end
            num_values = num_values + 1
        end
        if num_widgets ~= num_entries then
            self.layout:reset()
            self.entry_widgets = {}
            for i=1,num_values do
                local new_widget = make_entry_widget()
                table.insert(self.entry_widgets, new_widget)
                self.layout:add(new_widget.widget)
            end
        end
    end
    update_entry_widgets()
    for i, value in ipairs(self.entry_values) do
        local entry_widget = self.entry_widgets[i] 
        if entry_widget then
            entry_widget.textbox:set_markup(value)
        else
            break
        end
    end
end

function entry_list.new(...)
    local la = wibox.layout.fixed.vertical()
    local bgb = wibox.widget.background(la, "#ffff00")
    local entry_list_ = {
        show = entry_list.show,
        update_entries = entry_list.update_entries,
        --private
        entry_values = {},
        entry_widgets = {},
        -- widgets
        layout = la,
        widget = bgb,
        -- handlers
        on_key = entry_list.on_key
    }
    return entry_list_
end

function entry_list.mt:__call(...)
    return entry_list.new(...)
end

return setmetatable(entry_list, entry_list.mt)

