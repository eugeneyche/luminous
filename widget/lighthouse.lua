local capi = {
    awesome = awesome,
    screen = screen,
    client = client
}
local base = require("wibox.widget.base")

local setmetatable = setmetatable
local error = error
local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")
local math = require("math")

local keygrabber = require("awful.keygrabber")

local lighthouse = { mt = {} }

function lighthouse.decorate(item)
    local wrapper  = wibox.layout.margin(item, 2, 2, 2, 2, "#ff0000")
    for k, v in pairs(item) do
        if not wrapper[k] then
            wrapper[k] = v
        end
    end
    return wrapper
end

function lighthouse.prompt_new()
	local base = wibox.layout.align.horizontal()
	base._prompt = wibox.widget.textbox()
	base._input = wibox.widget.textbox()
	base._prompt:set_text("-- ")
	base:set_left(base._prompt)
	base:set_middle(base._input)
    function base:grab()
        grabber = keygrabber.run(function(mod, key, ev)
            if ev ~= "press" then return end
            if key == "BackSpace" and string.len(self._input._layout.text) > 0 then

                self._input:set_text(string.sub(self._input._layout.text,0, string.len(self._input._layout.text) - 1))
            end
            if key == "Escape" then
                keygrabber.stop(grabber)
            end
            if key:wlen() == 1 then
                self._input:set_text(self._input._layout.text .. key)
            end
        end)
    end
	return lighthouse.decorate(base)
end

function lighthouse.item_new(name)
	local base = wibox.layout.align.horizontal()
	local label = wibox.widget.textbox() 
    label:set_text(name) 
    base:set_middle(label) 
	return lighthouse.decorate(base)
end 

function lighthouse.new(args)
	local _lighthouse = wibox({
		ontop = true,
		fg = "#ffffff",
		bg = "#000000",
		border_color = "#ffffff",
		border_width = 2,
		type = "popup_menu" })
	_lighthouse.x = 100
	_lighthouse.y = 100
	_lighthouse.width = 300
	local base = wibox.layout.fixed.vertical()
	local widgets = {} 
    local prompt = lighthouse.prompt_new()
	table.insert(widgets, prompt)
	table.insert(widgets, lighthouse.item_new("lol"))
	table.insert(widgets, lighthouse.item_new("get"))
	table.insert(widgets, lighthouse.item_new("fucked"))
    local total_height = 0
	for i, item in pairs(widgets) do
		local w, h = item:fit(100, 20)
        base:add(item)
        total_height = total_height + h
	end 
    _lighthouse.height = total_height
	_lighthouse:set_widget(base)
	_lighthouse.visible = true
    prompt:grab()
	return _lighthouse
end

function lighthouse.mt:__call(...)
	return lighthouse.new(...)
end

return setmetatable(lighthouse, lighthouse.mt)
