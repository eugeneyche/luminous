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
local beautiful = require("beautiful")
local math = require("math")


local lighthouse = { mt = {} }

function lighthouse.new_prompt()
	local base = wibox.layout.align.horizontal()
	local prompt = wibox.widget.textbox()
	local input = wibox.widget.textbox()
	prompt:set_text("lighthouse-- ")
	input:set_text("fuck you!")
	base:set_left(prompt)
	base:set_middle(input)
	return base
end

function lighthouse.new_item(name)
	local base = wibox.layout.align.horizontal()
	local label = wibox.widget.textbox()
	label:set_text(name)
	base:set_middle(label)
	return base
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
	_lighthouse.height = 20 * 4 
	local base = wibox.layout.fixed.vertical()
	local widgets = {} 
	table.insert(widgets, lighthouse_input.new())
	table.insert(widgets, lighthouse_item.new("lol"))
	table.insert(widgets, lighthouse_item.new("get"))
	table.insert(widgets, lighthouse_item.new("fucked"))
	for i, item in pairs(widgets) do
		local w, h = item:fit(100, 20)
		item = wibox.layout.margin(item)
		item:set_top((20 - h) / 2)
		item:set_bottom((20 - h) / 2)
		base:add(item)
	end
	_lighthouse:set_widget(base)
	_lighthouse.visible = true
	return _lighthouse
end

function lighthouse.mt:__call(...)
	return lighthouse.new(...)
end

return setmetatable(lighthouse, lighthouse.mt)
