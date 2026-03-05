--[[ GenUI — Elements/Divider.lua --]]
local Util = require(script.Parent.Parent.Util.Util)

local Divider = {}
Divider.__index = Divider

function Divider.new(parent, theme)
    local self = setmetatable({}, Divider)

    self._root = Util.create("Frame", {
        Name             = "Divider",
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = theme:get("Border"),
        BorderSizePixel  = 0,
    }, parent)

    return self
end

return Divider
