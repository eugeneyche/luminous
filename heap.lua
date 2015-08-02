local heap = { mt = {} }


function heap.push(heap, item, value)
    local pair = {item = item, value = value }
    table.insert(heap, pair)
    local it = #heap
    while it > 1 do
        local parent = it // 2
        if heap[parent].value >= heap[it].value then
            break
        end
        heap[it], heap[parent] = heap[parent], heap[it]
        it = parent
    end
end


function heap.pop(h)
    if #h == 0 then
        return nil
    end
    local result = h[1].item
    h[1] = nil
    if #h > 1 then
        h[1] = h[#h]
    end
    table.remove(h, #h)
    if #h > 1 then
        local it = 1
        while h[2 * it] do
            local lhs = 2 * it
            local rhs = 2 * it + 1
            local swap = it
            if h[lhs] and h[lhs].value > h[swap].value then
                swap = lhs
            end
            if h[rhs] and h[rhs].value > h[swap].value then
                swap = rhs
            end
            if swap == it then
                break
            end
            h[it], h[swap] = h[swap], h[it]
            it = swap
        end
    end
    return result
end


function heap.show(h)
    buffer = ''
    level = 0
    for i,v in ipairs(h) do
        nlevel = math.floor(math.log(i, 2))
        if nlevel ~= level then
            print(buffer)
            level = nlevel
            buffer = ''
        end
        buffer = buffer .. ' -- ' ..
              "( i: " .. tostring(v.item) .. 
              " v: " .. tostring(v.value) ..
              " )"
              
    end
    if buffer:len() > 0 then
        print(buffer)
    end
end


return setmetatable(heap, heap.mt)
