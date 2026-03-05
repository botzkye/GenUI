--[[ GenUI — Elements/Keybind.lua --]]
local Util  = require(script.Parent.Parent.Util.Util)
local Tween = require(script.Parent.Parent.Util.Tween)
local UserInputService = game:GetService("UserInputService")

local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(parent, theme, options)
    local self = setmetatable({}, Keybind)
    options = options or {}

    self._theme    = theme
    self._value    = options.Value or "None"
    self._callback = options.Callback or function() end
    self._listening = false

    self._root = Util.create("Frame", {
        Name             = "Keybind",
        Size             = UDim2.new(1, 0, 0, options.Title and 52 or 36),
        BackgroundColor3 = theme:get("Surface"),
        BorderSizePixel  = 0,
    }, parent)
    Util.corner(self._root, UDim.new(0, 6))
    Util.stroke(self._root, theme:get("Border"), 1)
    Util.padding(self._root, 8, 10, 8, 10)
    Util.listLayout(self._root, { Padding = UDim.new(0, 4) })

    if options.Title then
        local row = Util.create("Frame", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
        }, self._root)

        Util.create("TextLabel", {
            Size             = UDim2.new(1, -60, 1, 0),
            BackgroundTransparency = 1,
            Text             = options.Title,
            TextColor3       = theme:get("TextPrimary"),
            TextSize         = 13,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
        }, row)
    end

    -- Key pill
    local pill = Util.create("TextButton", {
        Size             = UDim2.new(0, 0, 0, 22),
        AutomaticSize    = Enum.AutomaticSize.X,
        BackgroundColor3 = theme:get("SurfaceHover"),
        Text             = " " .. self._value .. " ",
        TextColor3       = theme:get("Accent"),
        TextSize         = 11,
        Font             = Enum.Font.GothamBold,
        AutoButtonColor  = false,
    }, self._root)
    Util.corner(pill, UDim.new(0, 4))
    Util.padding(pill, 0, 8, 0, 8)

    self._pill = pill

    pill.MouseButton1Click:Connect(function()
        if self._listening then return end
        self._listening = true
        pill.Text = " ... "
        pill.TextColor3 = theme:get("TextMuted")

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                self:set(input.KeyCode.Name)
                conn:Disconnect()
                self._listening = false
            end
        end)
    end)

    return self
end

function Keybind:set(keyName)
    self._value = keyName
    self._pill.Text = " " .. keyName .. " "
    self._pill.TextColor3 = self._theme:get("Accent")
    self._callback(keyName)
end
Keybind.Set = Keybind.set

function Keybind:get()
    return self._value
end
Keybind.Get = Keybind.get

return Keybind
