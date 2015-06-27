local capi = {
    awesome = awesome,
    screen = screen,
    client = client
}
local setmetatable = setmetatable
local error = error
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local widget = { mt = {} }

local function load_theme(a, b)
    a = a or {}
    b = b or {}
    local ret = {
        background = beautiful.bg_normal    
    }
    return ret
end

function widget.new(args)
    local args = args or {}
    local _widget = {
    }
    _widget.wibox = wibox({
        ontop = true,
        fg = "#ffff00",
        bg = "#ff0000",
        border_color = "#0000ff",
        border_width = 10,
        type = "popup_menu" })
    _widget.wibox.x = 100
    _widget.wibox.y = 100
    _widget.wibox.width = 300
    _widget.wibox.height = 300
    _widget.wibox.visible = true
	local layout = wibox.layout.fixed.vertical()
	local textbox1 = wibox.widget.textbox()
	local textbox2 = wibox.widget.textbox()
	local edit_textbox = wibox.widget.textbox()
	local entered_text = "text: "
	local function grabber(mod, key, event)
		if event ~= "press" then return end
		entered_text = entered_text .. key
		edit_textbox:set_text(entered_text)
	end
	_widget.wibox:connect_signal("mouse::enter", function () _widget.wibox:set_bg("#FF8800") end)
	_widget.wibox:connect_signal("mouse::leave", function () _widget.wibox:set_bg("#FF0000") end)
	textbox1:set_text("ayy lmao1")
	textbox2:set_text("ayy lmao2")
	layout:add(textbox1)
	layout:add(textbox2)
	layout:add(edit_textbox)
	_widget.wibox:set_widget(layout)
	keygrabber.run(grabber)
    return _widget
end

function widget.mt:__call(...)
    return widget.new(...)
end

return setmetatable(widget, widget.mt)
