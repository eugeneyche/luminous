local fuzzy = { mt = {} }

local decay = 0.05
local max_decay = 0.5

local begin_boost = 1.5
local begin_falloff = 0.5
local begin_max = 2

local end_boost = 0.5
local end_falloff = 0.5
local end_max = 3


function fuzzy.match(str, expr)
    local is_match = false
    local score = 0
    local matches = {}
    local first_match = 0
    local last_match = 0

    local ei = 1
    for i=1,str:len() do
        if ei <= expr:len() and expr:sub(ei, ei) == str:sub(i, i) then
            if first_match == 0 then
                first_match = i
            end
            ei = ei + 1
            last_match = i
            score = score + 1 - math.min(max_decay, decay * i)
            table.insert(matches, i)
        end
    end
    local begin_offset = first_match
    if begin_offset <= begin_max then
        score = score + math.pow(begin_falloff, begin_offset) * begin_boost
    end
    local end_offset = str:len() - last_match
    if end_offset <= end_max then
        score = score + math.pow(end_falloff, end_offset) * end_boost
    end
    if ei > expr:len() then
        return true, score, matches, first_match, last_match
    end
    return false
end


return setmetatable(fuzzy, fuzzy.mt)
