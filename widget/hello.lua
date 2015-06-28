local capi = {
    awesome = awesome,
    screen = screen,
    client = client
}
local setmetatable = setmetatable
local error = error
local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")

local custom = { mt = {} }

function custom.new(args)
    local args = args or {}
    local _custom = {
    }
    _custom.wibox = wibox({
        ontop = true,
        fg = "#ffff00",
        bg = "#ff0000",
        border_color = "#0000ff",
        border_width = 10,
        type = "popup_menu" })
    _custom.wibox.x = 100
    _custom.wibox.y = 100
    _custom.wibox.width = 300
    _custom.wibox.height = 300
	local layout = wibox.layout.fixed.vertical()
	local textbox1 = wibox.widget.textbox()
	local textbox2 = wibox.widget.textbox()
	local edit_textbox = wibox.widget.textbox()
	local entered_text = "text: "
	textbox1:set_text("ayy lmao1")
	textbox2:set_text("ayy lmao2")
	layout:add(textbox1)
	layout:add(textbox2)
	layout:add(edit_textbox)
	_custom.wibox:set_widget(layout)
    _custom.wibox.visible = true
    return _custom
end

function custom.mt:__call(...)
    return custom.new(...)
end

return setmetatable(custom, custom.mt)
