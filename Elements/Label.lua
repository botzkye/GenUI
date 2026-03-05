--[[  GenUI — Elements/Label.lua  --]]
local Util = require(script.Parent.Parent.Util.Util)

local Label = {}
Label.__index = Label

function Label.new(parent, theme, options)
    local self = setmetatable({}, Label)
    options = options or {}

    self._root = Util.create("TextLabel", {
        Name             = "Label",
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text             = options.Title or "",
        TextColor3       = options.Color or theme:get("TextSecondary"),
        TextSize         = options.TextSize or 12,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = options.Justify == "Center" and Enum.TextXAlignment.Center
                        or options.Justify == "Right"  and Enum.TextXAlignment.Right
                        or Enum.TextXAlignment.Left,
        TextWrapped      = true,
    }, parent)

    return self
end

function Label:setText(text)
    self._root.Text = text
end
Label.SetText = Label.setText

return Label
