proto = require('luminous.proto')
heap = require('luminous.heap')

local generator = { mt = {} }


function generator:new(...)
    self.max_entries = 15 * 4
    self.result = {}
end


function generator:yield_entry(entry)
    coroutine.yield(entry)
end


function generator:generate_entries(query) end


function generator:fallback_execute(query) end


function generator:get_entries(query)
    local gen_entries = coroutine.wrap(self.generate_entries)
    entry_heap = {}
    while true do
        entry = gen_entries(self, query)
        if not entry then break end
        local score = entry:get_score()
        if type(score) == 'number' then
            heap.push(entry_heap, entry, score)
            if #entry_heap >= self.max_entries then break end
        end
    end
    self.result = {}
    while #entry_heap > 0 do
        local entry = heap.pop(entry_heap)
        table.insert(self.result, entry)
    end
    return self.result
end


function generator.mt:__call(...)
    return proto.new(generator, ...)
end


return setmetatable(generator, generator.mt)
