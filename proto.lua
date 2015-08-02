proto = { mt = {} }

function proto.super(cls, inst, ...)
    for k, v in pairs(cls) do
        if not inst[k] then
            inst[k] = v
        end
    end
    if cls.new then
        cls.new(inst, ...)
    end
    return inst
end


function proto.new(cls, ...)
    local inst = { cls = cls }
    return proto.super(cls, inst, ...)
end


return setmetatable(proto, proto.mt)
