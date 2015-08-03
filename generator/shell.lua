local wibox = require ('wibox')

local awful = require('awful')

local proto = require('luminous.proto')
local generator = require('luminous.generator')
local entry = require('luminous.entry')
local fuzzy = require('luminous.fuzzy')

local common = require('luminous.common')


local shell = { mt = {} }
local shell_entry = { mt = {} }


function shell_entry:new(command_name, ...)
    proto.super(common.text_entry, self, command_name, ...)
    self.command_name = command_name
end


function shell_entry:process(query)
    local is_match, score, _, _, last_match = fuzzy.match(self.command_name, query)
    if is_match then
        local widget_markup = ''
        if last_match > 0 then
            widget_markup = widget_markup .. '<span fgcolor="#00ffff">'
            widget_markup = widget_markup .. self.command_name:sub(1, last_match)
            widget_markup = widget_markup .. '</span>'
        end
        if last_match < self.command_name:len() then
            widget_markup = widget_markup .. self.command_name:sub(last_match + 1)
        end
        self.textbox:set_markup(widget_markup)
    end
    return score
end


function shell_entry:hint_prompt()
    return self.command_name
end


function shell_entry:execute()
    awful.util.spawn(self.command_name)
end


function shell_entry.mt:__call(...)
    return proto.new(shell_entry, ...)
end


setmetatable(shell_entry, shell_entry.mt)


function shell:new(...)
    proto.super(generator, self, ...)
    self.entries = {}
    proc, err =  io.popen('compgen -c')
    if proc then
        for command_name in proc:lines() do
            local entry = shell_entry(command_name)
            table.insert(self.entries, entry)
        end
        proc.close()
    end
end


function shell:generate_entries(query)
    for _,entry in ipairs(self.entries) do
        local score = entry:process(query)
        if score then
            self:yield_entry(entry, score)
        end
    end
end


function generator:fallback_execute(query) 
    awful.util.spawn(query)
end


function shell.mt:__call(...)
    return proto.new(shell, ...)
end


return setmetatable(shell, shell.mt)
