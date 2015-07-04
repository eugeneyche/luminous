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

local custom = { mt = {} }

function custom:draw(wibox, cr, width, height)
	cr:save()

	cr:set_source(gears.color("#ffff00"))
	cr:arc(200, 200, 100, 0, 2 * math.pi)
	cr:fill()

	cr:restore()
	cr:save()

	cr:set_source(gears.color("#000000"))
	cr:translate(150, 170)
	cr:scale(0.5, 1.0)
	cr:arc(0, 0, 20, 0, 2 * math.pi)
	cr:fill()

	cr:restore()
	cr:save()

	cr:set_source(gears.color("#000000"))
	cr:translate(250, 170)
	cr:scale(0.5, 1.0)
	cr:arc(0, 0, 20, 0, 2 * math.pi)
	cr:fill()

	cr:restore()
	cr:save()

	cr:set_source(gears.color("#000000"))
	cr:translate(200, 220)
	cr:scale(1.0, 0.8)
	cr:arc(0, 0, 50, 0, math.pi)
	cr:stroke()

	cr:restore()

end

function custom:fit(width, height)
	return width, height
end


function custom.new_widget(args)
	local ret = base.make_widget()	
	ret.draw = custom.draw
	ret.fit = custom.fit
	ret.visible = true
	return ret
end

function custom.new(args)
	local _custom = wibox({
        ontop = true,
        fg = "#ffff00",
        bg = "#ff0000",
        border_color = "#0000ff",
        border_width = 10,
        type = "popup_menu" })
    _custom.x = 100
    _custom.y = 100
    _custom.width = 400
    _custom.height = 400
	_custom:set_widget(custom.new_widget(args))
    _custom.visible = true
	return _custom
end

function custom.mt:__call(...)
    return custom.new(...)
end

return setmetatable(custom, custom.mt)
