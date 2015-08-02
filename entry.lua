local proto = require('luminous.proto')


entry = { mt = {} }


function entry:new()
end


function entry:get_score()
    return nil
end


function entry:get_widget() 
    return nil
end


function entry:hint_prompt()
    return nil
end


function entry:hover() end


function entry:unhover() end


function entry:execute() end


function entry.mt:__call(...)
    return proto.new(entry, ...)
end


return setmetatable(entry, entry.mt)
