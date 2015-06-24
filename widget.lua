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
        type = "lighthouse" })
    _widget.wibox.x = 100
    _widget.wibox.y = 100
    _widget.wibox.width = 300
    _widget.wibox.height = 300
    _widget.wibox.visible = true
    return _widget
end

function widget.mt:__call(...)
    return widget.new(...)
end

return setmetatable(widget, widget.mt)
