local capi = {
    client = client,
    mouse = mouse,
    screen = screen
}

local setmetatable = setmetatable
local awful = require("awful")
local theme = require("beautiful")
local wibox = require("wibox")
local naughty = require("naughty")

local prompt = { mt = {} }

function prompt:on_key(modifiers, key, event)
    -- check for press
    if event ~= 'press' then return end
    -- check for mod (will change later)
    local mod = {}
    for _, v in ipairs(modifiers) do mod[v] = true end
    if mod.Mod4 or mod.Mod1 then return end
    if mod.Control then
        if key == "a" then
            self.cursor = 1
        end
        if key == "e" then
            self.cursor = self.query:len() + 1
        end
    else
        if key == "Left" then
            self.cursor = math.max(1, self.cursor - 1)
        end
        if key == "Right" then
            self.cursor = math.min(self.query:len() + 1, self.cursor + 1)
        end
        if key == "BackSpace" then
            if self.cursor == 1 then return end
            local new_query = ''
            if self.cursor > 2 then
                new_query = self.query:sub(1, self.cursor - 2)
            end
            if self.cursor <= self.query:len() then
                new_query = new_query .. self.query:sub(self.cursor)
            end
            self.query = new_query
            self.cursor = math.max(1, self.cursor - 1)
            if self.query_change_callback then
                self.query_change_callback(self.query)
            end
        end
        -- basic typing case
        if key:wlen() == 1 then
            local new_query = ''
            if self.cursor > 1 then
                new_query = self.query:sub(1, self.cursor - 1)
            end
            new_query = new_query .. key
            if self.cursor <= self.query:len() then
                new_query = new_query .. self.query:sub(self.cursor)
            end
            self.query = new_query
            self.cursor = math.min(self.query:len() + 1, self.cursor + 1)
            if self.query_change_callback then
                self.query_change_callback(self.query)
            end
        end
    end
    self:show()
end


function prompt:show()
    local prompt_markup = '<span fgcolor="#ffff00">>>> </span>'
    local cursor_char = '_'
    local function cursor_highlight(c)
        return '<span fgcolor="#ff0000">' .. c .. '</span>'
    end
    local query_markup = ''
    if self.cursor > 1 then
        query_markup = self.query:sub(1, self.cursor - 1)
    end
    if self.cursor <= self.query:len() then
        
        if self.query:sub(self.cursor, self.cursor) == ' ' then
            query_markup = query_markup .. cursor_highlight(cursor_char)
        else
            query_markup = query_markup .. cursor_highlight(
                    self.query:sub(self.cursor, self.cursor))
        end
        if self.cursor < self.query:len() then
            query_markup = query_markup .. self.query:sub(self.cursor + 1)
        end
    else
        query_markup = query_markup .. cursor_highlight(cursor_char)
    end
    self.textbox:set_markup(prompt_markup .. query_markup)
end

function prompt.new(...)
    local tb = wibox.widget.textbox()
    local m = wibox.layout.margin(tb, 4, 4, 4, 4)
    local bgb = wibox.widget.background(m)
    local prompt_ = {
        query = "",
        cursor = 1,
        show = prompt.show,
        -- widgets
        textbox = tb,
        widget = bgb,
        -- callbacks
        query_change_callback = nil,
        -- handlers
        on_key = prompt.on_key
    }

    return prompt_
end

function prompt.mt:__call(...)
    return prompt.new(...)
end

return setmetatable(prompt, prompt.mt)
