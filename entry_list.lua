local capi = {
    client = client,
    mouse = mouse,
    screen = screen
}

local theme = require("beautiful")
local wibox = require("wibox")
local naughty = require("naughty")

local utils = require('luminous.utils')

local entry_list = { mt = {} }

local entries_per_page = 15

function entry_list:new(...)
    local la = wibox.layout.fixed.vertical()
    local bgb = wibox.widget.background(la, "#ffff00")
    self.cursor = 0
    self.entry_values = {}
    self.entry_widgets = {}
    self.layout = la
    self.base = bgb

    self.resize_listeners = {}
end


function entry_list:on_resize(callback)
    table.insert(self.resize_listeners, callback)
end


function entry_list:emit_resize()
    for _,callback in ipairs(self.resize_listeners) do
        callback()
    end
end


function entry_list:update_entries(new_entries)
    self.entry_values = new_entries
    self:show()
end


function entry_list:_check_cursor()
    self.cursor = math.max(0, self.cursor)
    self.cursor = math.min(#self.entry_values, self.cursor)
end


function entry_list:cursor_up()
    self.cursor = self.cursor - 1
    self:_check_cursor()
    self:show()
end


function entry_list:cursor_down()
    self.cursor = self.cursor + 1
    self:_check_cursor()
    self:show()
end


function entry_list:_make_entry_widget()
    local tb = wibox.widget.textbox('> ')
    local m = wibox.layout.margin(tb, 4, 4, 4, 4)
    local bgb = wibox.widget.background(m, '#334455')
    local _entry = {
        base = bgb,
        textbox = tb,
    }
    return _entry
end

function entry_list:show()
    local page = 0 
    if self.cursor > 0 then
        page = (self.cursor - 1) // entries_per_page
    end
    local skipped_entries = page * entries_per_page
    local shown_entries = math.min(entries_per_page, 
        #self.entry_values - skipped_entries)

    print(#self.entry_values)

    local resized = #self.entry_widgets ~= shown_entries 

    if #self.entry_widgets > shown_entries then
        self.layout:reset()
        self.entry_widgets = {}
        self:_check_cursor()
    end
    while #self.entry_widgets < shown_entries do
        local new_widget = self:_make_entry_widget()
        table.insert(self.entry_widgets, new_widget)
        self.layout:add(new_widget.base)
    end
    local focus_entry = nil
    if self.cursor > 0 then
        focus_entry = self.cursor - skipped_entries
    end
    for i=1,shown_entries do
        local entry_value = self.entry_values[skipped_entries + i]
        self.entry_widgets[i].textbox:set_markup(entry_value)
        if focus_entry and focus_entry == i then
            self.entry_widgets[i].base:set_bg('#556677')
        else
            self.entry_widgets[i].base:set_bg('#334455')
        end
    end
    if resized then
        self:emit_resize()
    end

end
    

function entry_list.mt:__call(...)
    return utils.create(entry_list, ...)
end

return setmetatable(entry_list, entry_list.mt)

