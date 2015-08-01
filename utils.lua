local utils = { mt = {} }


function utils.create(cls, ...)
    local inst_ = { cls = cls }
    for k, v in pairs(cls) do
        inst_[k] = v
    end
    if inst_.new then
        inst_:new(...)
    end
    return inst_
end

function utils.debug(message)
    require('naughty').notify({text=message})
end


return utils
