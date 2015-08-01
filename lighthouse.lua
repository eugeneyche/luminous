local capi = {
    client = client,
    mouse = mouse,
    screen = screen
}

local awful = require('awful')
local common = require('awful.widget.common')
local theme = require('beautiful')
local wibox = require ('wibox')
local keygrabber = require('awful.keygrabber')

local utils = require('luminous.utils')

local prompt = require('luminous.prompt')
local entry_list = require('luminous.entry_list')

local lighthouse = { mt = {} }


function lighthouse:new(...)
    self.prompt = prompt()
    self.entry_list = entry_list()
    local layout = wibox.layout.fixed.vertical()
    layout:add(self.prompt.base)
    layout:add(self.entry_list.base)
    self.grabber = nil
    self.wibox = wibox({
        ontop=true,
        border_width=1,
        border_color='#ff0000'
    })
    self.wibox:set_widget(layout)
    self.prompt:on_query_change(function(...)
        self:update_entry_list()
    end)
    self.entry_list:on_resize(function(...)
        self:resize()
    end)
end


function lighthouse:show()
    self.prompt:show()
    self.entry_list:show()
    self:resize()
    self.wibox.visible = true
end


function lighthouse:resize()
    local scr = capi.mouse.screen 
    local scrgeom = capi.screen[scr].workarea
    local fixed_width = 600
    local fixed_offset = 200
    local remaining_height = scrgeom.height - fixed_offset
    local _, prompt_height = self.prompt.base:fit(
            fixed_width, remaining_height)
    remaining_height = remaining_height - prompt_height
    local _, entry_list_height = self.entry_list.base:fit(
            fixed_width, remaining_height)
    local geom = {
        x = scrgeom.x + scrgeom.width / 2 - fixed_width / 2,
        y = scrgeom.y + fixed_offset,
        width = fixed_width,
        height = prompt_height + entry_list_height
    }
    self.wibox:geometry(geom)
end


function lighthouse:run()
    self:show()
    if self.grabber then
        keygrabber.stop(self.grabber)
    end
    self.grabber = keygrabber.run(
        function(modifiers, key, event)
            self:on_key(modifiers, key, event)
        end)
end


function lighthouse:on_key(modifiers, key, event)
    if event ~= 'press' then return end
    local mod = {}
    for k, v in ipairs(modifiers) do mod[v] = true end
    if (mod.Control and (key == 'c' or key == 'g')) or 
            (not mod.Control and key == 'Escape') then
        keygrabber.stop(self.grabber)
        self.grabber = nil
        self.wibox.visible = false
    elseif key == 'Left' or 
            (mod.Control and key == 'b') then
        self.prompt:cursor_left()
    elseif key == 'Right' or 
            (mod.Control and key == 'f') then
        self.prompt:cursor_right()
    elseif mod.Control and key == 'a' then
        self.prompt:cursor_home()
    elseif mod.Control and key == 'e' then
        self.prompt:cursor_end()
    elseif key == 'BackSpace' then
        self.prompt:backspace()
    elseif not mod.Control then
        if key:wlen() == 1 then
            self.prompt:type_key(key)
        end
    elseif mod.Control and key == 'j' then
        self.entry_list:cursor_down()
    elseif mod.Control and key == 'k' then
        self.entry_list:cursor_up()
    end
end


function lighthouse:update_entry_list()
    local new_entries = {}
    for token in string.gmatch(self.prompt.query, '[^%s]+') do
        table.insert(new_entries, token)
    end
    self.entry_list:update_entries(new_entries)
    self:show()
end


function lighthouse.fuzzy_match(query, str)
    local function match_highlight(c)
        return '<span fgcolor="#00ffff">' .. c .. '</span>'
    end
    repr = ''
    local qi = 1
    for i=1,str:len() do
        local char_at_i = str:sub(i, i)
        if qi <= query:len() and query:sub(qi, qi) == char_at_i then
            qi = qi + 1
            repr = repr .. match_highlight(char_at_i)
        else
            repr = repr .. char_at_i
        end
    end
    if qi > query:len() then
        return repr
    else
        return nil
    end
end


function lighthouse.mt:__call(...)
    return utils.create(lighthouse, ...)
end


return setmetatable(lighthouse, lighthouse.mt)
