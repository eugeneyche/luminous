local wibox = require ('wibox')

local proto = require('luminous.proto')
local generator = require('luminous.generator')
local entry = require('luminous.entry')


local multiplex = { mt = {} }
local multiplex_entry = { mt = {} }


function multiplex_entry:new(mode, expanded, subentry, ...)
    proto.super(entry, self, ...)
    self.mode = mode
    self.expanded = expanded
    self.subentry = subentry
end


function multiplex_entry:get_score()
    if not self.expanded then
        return 0
    end
    return self.subentry:get_score()
end


function multiplex_entry:get_widget()
    if not self.expanded then
        return self.mode.base
    end
    return self.subentry:get_widget()
end


function multiplex_entry:hint_prompt()
    if not self.expanded then
        return self.mode.name
    end
    local hint = self.subentry:hint_prompt()
    if hint then
        return self.mode.name .. ' ' .. hint
    end
    return nil
end


function multiplex_entry:execute()
    if not self.expanded then return end
    self.subentry:execute()
end


function multiplex_entry.mt:__call(...)
    return proto.new(multiplex_entry, ...)
end


setmetatable(multiplex_entry, multiplex_entry.mt)


function multiplex:new(...)
    proto.super(generator, self, ...)
    self.modes = {}
end


function multiplex:add_mode(name, generator)
    
    local mode = {
        name = name,
        generator = generator,
    }
    mode.textbox = wibox.widget.textbox(name)
    mode.base = wibox.layout.margin(mode.textbox, 4, 4, 4, 4)
    table.insert(self.modes, mode)
end


function multiplex:generate_entries(query)
    local enabled_mode = nil
    local subquery = nil
    for _,mode in ipairs(self.modes) do
        local expr = '^' .. mode.name .. ' (.*)$'
        local match = string.match(query, expr)
        if match then
            subquery = match
            enabled_mode = mode
            break
        end
    end
    if enabled_mode then
        local generator = enabled_mode.generator
        local gen_entries = coroutine.wrap(generator.generate_entries)
        while true do
            subentry = gen_entries(generator, subquery)
            if not subentry then break end
            self:yield_entry(multiplex_entry(enabled_mode, true, subentry))
        end
    else
        for _,mode in ipairs(self.modes) do
            self:yield_entry(multiplex_entry(mode, false))
        end
    end
end


function multiplex:fallback_execute(query) 
    local enabled_mode = nil
    local subquery = nil
    for _,mode in ipairs(self.modes) do
        local expr = '^' .. mode.name .. ' (.*)$'
        local match = string.match(query, expr)
        if match then
            subquery = match
            enabled_mode = mode
            break
        end
    end
    if enabled_mode and subquery then
        local generator = enabled_mode.generator
        generator:fallback_execute(subquery)
    end
end


function multiplex.mt:__call(...)
    return proto.new(multiplex, ...)
end


return setmetatable(multiplex, multiplex.mt)
