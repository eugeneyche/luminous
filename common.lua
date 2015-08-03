local wibox = require ('wibox')

local proto = require('luminous.proto')
local entry = require('luminous.entry')

local text_entry = { mt = {} }


function text_entry:new(text, ...)
    proto.super(entry, self, ...)
    self.textbox = wibox.widget.textbox(text)
    self.base = wibox.layout.margin(self.textbox, 4, 4, 4, 4)
end


function text_entry:get_widget()
    return self.base
end


function text_entry.mt:__call(...)
    proto.new(text_entry, ...)
end


setmetatable(text_entry, text_entry.mt)


local common = { 
    text_entry = text_entry
}


return common
