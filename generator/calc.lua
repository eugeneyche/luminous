local wibox = require ('wibox')

local proto = require('luminous.proto')
local generator = require('luminous.generator')
local entry = require('luminous.entry')

local calc = { mt = {} }
local calc_entry = { mt = {} }


function calc_entry:new(input, result, ...)
    proto.super(entry, self, ...)
    self.textbox = wibox.widget.textbox()
    self.base = wibox.layout.margin(self.textbox, 4, 4, 4, 4)
    local widget_markup = ''
    widget_markup = widget_markup .. '<span fgcolor="#ff8800">' .. input .. '</span>'
    widget_markup = widget_markup .. '= '
    widget_markup = widget_markup .. '<span fgcolor="#88ff00">' .. result .. '</span>'
    self.textbox:set_markup(widget_markup)
end


function calc_entry:get_score()
    return 0
end


function calc_entry:get_widget()
    return self.base
end


function calc_entry.mt:__call(...)
    return proto.new(calc_entry, ...)
end


setmetatable(calc_entry, calc_entry.mt)


function calc:new(...)
    proto.super(generator, self, ...)
end


function calc:generate_entries(query)
    local expr = '^(.*)=$'
    local match = string.match(query, expr)
    if match then
        local calc_fun = load('return ' .. match)
        local status, result = pcall(calc_fun)
        if status then
            self:yield_entry(calc_entry(match, tostring(result)))
        end
    end
end


function calc.mt:__call(...)
    return proto.new(calc, ...)
end


return setmetatable(calc, calc.mt)
