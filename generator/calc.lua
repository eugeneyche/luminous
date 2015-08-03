local wibox = require ('wibox')

local proto = require('luminous.proto')
local generator = require('luminous.generator')
local entry = require('luminous.entry')

local common = require('luminous.common')


local calc = { mt = {} }
local calc_entry = { mt = {} }


function calc_entry:new(calc, input, result,...)
    local widget_markup = ''
    widget_markup = widget_markup .. '<span fgcolor="#ff8800">' .. input .. '</span>'
    widget_markup = widget_markup .. '\n= '
    widget_markup = widget_markup .. '<span fgcolor="#88ff00">' .. result .. '</span>'
    proto.super(common.text_entry, self, widget_markup, ...)
    self.calc = calc
    self.result = result
end


function calc_entry:hint_prompt()
    return self.result
end


function calc_entry:execute()
    self.calc:save_entry(self)
end


function calc_entry.mt:__call(...)
    return proto.new(calc_entry, ...)
end


setmetatable(calc_entry, calc_entry.mt)


function calc:new(...)
    proto.super(generator, self, ...)
    self.max_history = 10
    self.history = {}
end


function calc:save_entry(entry)
    table.insert(self.history, entry)
    if #self.history > self.max_history then
        self.history = self.history:sub(#self.history - max_history + 1)
    end
end


function calc:generate_entries(query)
    for i,entry in ipairs(self.history) do
        self:yield_entry(entry, i)
    end
    local calc_fun = load('return ' .. query)
    local status, result = pcall(calc_fun)
    if status and type(result) == 'number' then
        self:yield_entry(calc_entry(self, query, tostring(result)), #self.history + 1)
    end
end


function calc.mt:__call(...)
    return proto.new(calc, ...)
end


return setmetatable(calc, calc.mt)
