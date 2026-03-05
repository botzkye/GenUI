--[[
    GenUI — Core/Group.lua
    Horizontal flex-row layout. Children are side-by-side.
    :Space() adds a flex spacer.
--]]

local Util  = require(script.Parent.Parent.Util.Util)
local Flags = require(script.Parent.Parent.Util.Flags)

local Group = {}
Group.__index = Group

function Group.new(parent, theme, options)
    local self = setmetatable({}, Group)

    options = options or {}
    self._theme    = theme
    self._elements = {}

    self._frame = Util.create("Frame", {
        Name             = "Group",
        Size             = UDim2.new(1, 0, 0, 36),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    }, parent)

    Util.listLayout(self._frame, {
        FillDirection       = Enum.FillDirection.Horizontal,
        VerticalAlignment   = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding             = UDim.new(0, options.Gap or 6),
    })

    return self
end

-- Insert flex spacer
function Group:space()
    Util.create("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        BackgroundTransparency = 1,
        AutomaticSize    = Enum.AutomaticSize.X,
        LayoutOrder      = 99,
    }, self._frame)
end
Group.Space = Group.space

-- Forward element methods (same as Tab but parent = self._frame)
local function registerFlag(flag, el)
    if flag and flag ~= "" then Flags.set(flag, el) end
end

local elementNames = { "button","toggle","slider","input","dropdown","colorpicker","keybind","label","divider" }
for _, name in ipairs(elementNames) do
    Group[name] = function(self, options)
        local Tab = require(script.Parent.Tab)
        local proxy = setmetatable({ _frame = self._frame, _theme = self._theme, _elements = self._elements }, { __index = Tab })
        return proxy[name](proxy, options)
    end
    Group[name:sub(1,1):upper() .. name:sub(2)] = Group[name]
end

return Group
