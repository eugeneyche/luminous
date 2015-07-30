local capi = {
    client = client,
    mouse = mouse,
    screen = screen
}
local setmetatable = setmetatable
local awful = require("awful")
local common = require("awful.widget.common")
local theme = require("beautiful")
local wibox = require ("wibox")
local keygrabber = require("awful.keygrabber")

local naughty = require("naughty")

local prompt = require("luminous.widget.prompt")
local entry_list = require("luminous.widget.entry_list")

local lighthouse = { mt = {} }
-- TODO(eugeneyche): create actual generator
-- The actual generator should return a string attached to
-- a command, but I'm too lazy so I'll only return a string
-- name.

-- Updates what is currently displayed in the lighthouse 
-- with the new user query

function lighthouse.load_commands()
    local commands = {}
    c, err = io.popen('compgen -ca')
    if c then 
        for command in c:lines() do
            table.insert(commands, command)
        end
        c:close()
    end
    return commands
end

function lighthouse:show()
    self.prompt:show()
    self.entry_list:show()
    local scr = capi.mouse.screen 
    local scrgeom = capi.screen[scr].workarea
    local fixed_width = 600
    local fixed_offset = 200
    local remaining_height = scrgeom.height - fixed_offset
    local _, prompt_height = self.prompt.widget:fit(
            fixed_width, remaining_height)
    remaining_height = remaining_height - prompt_height
    local _, entry_list_height = self.entry_list.widget:fit(
            fixed_width, remaining_height)
    local geom = {
        x = scrgeom.x + scrgeom.width / 2 - fixed_width / 2,
        y = scrgeom.y + fixed_offset,
        width = fixed_width,
        height = prompt_height + entry_list_height
    }
    self.wibox:geometry(geom)
    self.wibox.visible = true
end

-- Specifications
-- Very stupic class that simply takes on 
-- the form of the actual lighthouse
-- Very little logic should go into this object.
function lighthouse.new_wibox(...)
    wibox_ = wibox({
        ontop=true,
        border_width=1,
        border_color="#ff0000"
    })
    return wibox_
end

-- Specifications
-- Will display entries given to it
-- Will handle pagination
-- Will do nothing else
-- Puppeted by main lighthouse
function lighthouse.new_entry_list()
    local result = wibox.widget.textbox(">>> google chrome_")
    return result
end

-- Specifications
-- Will be used to generate the queries
-- Will determine cursor mechanics and allow updating
-- when user navigates list
-- Puppetted by main lighthouse
function lighthouse.new_prompt()
    local result = wibox.widget.textbox(">>> google chrome_")
    return result
end

function lighthouse:grab()
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
    if event ~= "press" then return end
    -- Convert index array to hash table
    local mod = {}
    for k, v in ipairs(modifiers) do mod[v] = true end

    -- Call the user specified callback. If it returns true as
    -- the first result then return from the function. Treat the
    -- second and third results as a new command and new prompt
    -- to be set (if provided)

    -- Get out cases
    if (mod.Control and (key == "c" or key == "g"))
        or (not mod.Control and key == "Escape") then
        keygrabber.stop(self.grabber)
        self.grabber = nil
        self.wibox.visible = false
    end
    self.prompt:on_key(modifiers, key, event)
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

-- Specifications
-- Will handle events that the prompt throws
-- Will handle events that entries throw
-- Will handle all key events (yay!)
-- BASICALLY -> Key types without Ctrl modifier directed to prompt
-- Key types with Ctrl modifier directed to entries
function lighthouse.new(...)
    local lighthouse_ = {
        -- public
        grab = lighthouse.grab,
        show = lighthouse.show,
        update = lighthouse.update,
        -- private
        grabber = nil,
        -- widgets
        wibox = lighthouse.new_wibox(),
        prompt = prompt(),
        entry_list = entry_list(),
        all_commands = lighthouse.load_commands(),
        -- callbacks
        -- handlers
        on_key = lighthouse.on_key
    }
    lighthouse_.prompt.query_change_callback = function(query)
        if query:len() == 0 then
            lighthouse_.entry_list:update_entries({})
        else
            local filtered_commands = {}
            for _,command in ipairs(lighthouse_.all_commands) do
                if query:len() <= command:len() then
                    match = lighthouse.fuzzy_match(query, command)
                    if match then
                        table.insert(filtered_commands, match)
                    end
                end
            end
            lighthouse_.entry_list:update_entries(filtered_commands)
        end
        lighthouse_:show()
    end
    local layout = wibox.layout.fixed.vertical()
    layout:add(lighthouse_.prompt.widget)
    layout:add(lighthouse_.entry_list.widget)
    lighthouse_.wibox:set_widget(layout)
    return lighthouse_
end

function lighthouse.mt:__call(...)
    return lighthouse.new(...)
end

return setmetatable(lighthouse, lighthouse.mt)
