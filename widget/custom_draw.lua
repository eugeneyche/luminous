local capi = {
    awesome = awesome,
    screen = screen,
    client = client
}
local base = require("wibox.widget.base")

local setmetatable = setmetatable
local error = error
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local custom = { mt = {} }

function custom:draw(wibox, cr, width, height)
	cr:update_layout(self._layout)
end


function custom.new(args)
	local ret = base.make_widget()	
	ret.draw = custom.draw
	return ret
end
