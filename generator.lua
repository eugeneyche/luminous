utils = require('luminous.utils')

local generator = { mt = {} }


function generator:new(...)
    
end


function generator.mt:__call(...)
    return utils.create(generator, ...)
end

return setmetatable(generator, generator.mt)
