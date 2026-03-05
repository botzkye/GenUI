--[[
    GenUI — Elements/Input.lua
--]]

local Util  = require(script.Parent.Parent.Util.Util)
local Tween = require(script.Parent.Parent.Util.Tween)

local Input = {}
Input.__index = Input

function Input.new(parent, theme, options)
    local self = setmetatable({}, Input)
    options = options or {}

    self._theme    = theme
    self._value    = options.Value or ""
    self._callback = options.Callback or function() end
    self._locked   = options.Locked or false
    self._type     = options.Type or "Input"

    local isTextarea = self._type == "Textarea"
    local baseH = isTextarea and 80 or (options.Desc and 68 or 52)

    self._root = Util.create("Frame", {
        Name             = "Input",
        Size             = UDim2.new(1, 0, 0, baseH),
        BackgroundColor3 = theme:get("Surface"),
        BorderSizePixel  = 0,
    }, parent)
    Util.corner(self._root, UDim.new(0, 6))
    Util.stroke(self._root, theme:get("Border"), 1)
    Util.padding(self._root, 8, 10, 8, 10)
    Util.listLayout(self._root, { Padding = UDim.new(0, 5) })

    -- Title
    if options.Title then
        local row = Util.create("Frame", {
            Size             = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
        }, self._root)

        Util.create("TextLabel", {
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text             = options.Title,
            TextColor3       = theme:get("TextPrimary"),
            TextSize         = 13,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
        }, row)
    end

    if options.Desc then
        Util.create("TextLabel", {
            Size             = UDim2.new(1, 0, 0, 13),
            BackgroundTransparency = 1,
            Text             = options.Desc,
            TextColor3       = theme:get("TextSecondary"),
            TextSize         = 11,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
        }, self._root)
    end

    -- Input box
    local inputFrame = Util.create("Frame", {
        Size             = UDim2.new(1, 0, 0, isTextarea and 44 or 26),
        BackgroundColor3 = theme:get("Background"),
        BorderSizePixel  = 0,
    }, self._root)
    Util.corner(inputFrame, UDim.new(0, 4))
    Util.stroke(inputFrame, theme:get("Border"), 1)
    Util.padding(inputFrame, 0, 8, 0, 8)

    self._box = Util.create("TextBox", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = self._value,
        PlaceholderText  = options.Placeholder or "Enter text...",
        TextColor3       = theme:get("TextPrimary"),
        PlaceholderColor3 = theme:get("TextMuted"),
        TextSize         = 12,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = isTextarea,
        MultiLine        = isTextarea,
        ClearTextOnFocus = false,
        TextEditable     = not self._locked,
    }, inputFrame)

    -- Focus highlight
    self._box.Focused:Connect(function()
        Util.stroke(inputFrame, theme:get("Accent"), 1)
    end)
    self._box.FocusLost:Connect(function()
        Util.stroke(inputFrame, theme:get("Border"), 1)
        self._value = self._box.Text
        self._callback(self._value)
    end)

    return self
end

function Input:set(value)
    self._value = tostring(value)
    self._box.Text = self._value
end
Input.Set = Input.set

function Input:get()
    return self._box.Text
end
Input.Get = Input.get

function Input:clear()
    self:set("")
end
Input.Clear = Input.clear

return Input
