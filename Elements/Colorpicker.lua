--[[ GenUI — Elements/Colorpicker.lua --]]
local Util  = require(script.Parent.Parent.Util.Util)
local Tween = require(script.Parent.Parent.Util.Tween)

local Colorpicker = {}
Colorpicker.__index = Colorpicker

function Colorpicker.new(parent, theme, options)
    local self = setmetatable({}, Colorpicker)
    options = options or {}

    self._theme        = theme
    self._color        = options.Default or Color3.fromRGB(255, 255, 255)
    self._transparency = options.Transparency or 0
    self._callback     = options.Callback or function() end
    self._open         = false

    self._root = Util.create("Frame", {
        Name             = "Colorpicker",
        Size             = UDim2.new(1, 0, 0, options.Title and 52 or 36),
        BackgroundColor3 = theme:get("Surface"),
        BorderSizePixel  = 0,
    }, parent)
    Util.corner(self._root, UDim.new(0, 6))
    Util.stroke(self._root, theme:get("Border"), 1)
    Util.padding(self._root, 8, 10, 8, 10)
    Util.listLayout(self._root, { Padding = UDim.new(0, 5) })

    if options.Title then
        Util.create("TextLabel", {
            Size             = UDim2.new(1, -36, 0, 16),
            BackgroundTransparency = 1,
            Text             = options.Title,
            TextColor3       = theme:get("TextPrimary"),
            TextSize         = 13,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
        }, self._root)
    end

    -- Swatch row
    local swatchRow = Util.create("Frame", {
        Size             = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
    }, self._root)

    -- Color swatch preview
    self._swatch = Util.create("TextButton", {
        Size             = UDim2.new(0, 50, 1, 0),
        BackgroundColor3 = self._color,
        Text             = "",
        AutoButtonColor  = false,
    }, swatchRow)
    Util.corner(self._swatch, UDim.new(0, 4))
    Util.stroke(self._swatch, theme:get("Border"), 1)

    -- Hex label
    self._hexLabel = Util.create("TextLabel", {
        Position         = UDim2.new(0, 58, 0, 0),
        Size             = UDim2.new(1, -58, 1, 0),
        BackgroundTransparency = 1,
        Text             = self:_toHex(),
        TextColor3       = theme:get("TextSecondary"),
        TextSize         = 11,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, swatchRow)

    -- Click swatch to open basic hex input (simplified picker)
    self._swatch.MouseButton1Click:Connect(function()
        self:_togglePicker()
    end)

    return self
end

function Colorpicker:_toHex()
    local r = math.floor(self._color.R * 255)
    local g = math.floor(self._color.G * 255)
    local b = math.floor(self._color.B * 255)
    return string.format("#%02X%02X%02X", r, g, b)
end

function Colorpicker:_togglePicker()
    if self._open then
        self:_closePicker()
    else
        self:_openPicker()
    end
end

function Colorpicker:_openPicker()
    self._open = true

    local picker = Util.create("Frame", {
        Name             = "ColorPickerPopup",
        Size             = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = self._theme:get("Elevated"),
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        ZIndex           = 10,
    }, self._root)
    Util.corner(picker, UDim.new(0, 6))
    Util.stroke(picker, self._theme:get("Border"), 1)
    Util.padding(picker, 8, 8, 8, 8)
    Util.listLayout(picker, { Padding = UDim.new(0, 6) })

    -- Hex input
    Util.create("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text             = "HEX",
        TextColor3       = self._theme:get("TextMuted"),
        TextSize         = 10,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, picker)

    local hexInput = Util.create("TextBox", {
        Size             = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = self._theme:get("Background"),
        Text             = self:_toHex(),
        TextColor3       = self._theme:get("TextPrimary"),
        TextSize         = 12,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Center,
        ClearTextOnFocus = false,
    }, picker)
    Util.corner(hexInput, UDim.new(0, 4))
    Util.stroke(hexInput, self._theme:get("Border"), 1)

    hexInput.FocusLost:Connect(function()
        local hex = hexInput.Text:gsub("#", "")
        if #hex == 6 then
            local r = tonumber(hex:sub(1,2), 16) or 0
            local g = tonumber(hex:sub(3,4), 16) or 0
            local b = tonumber(hex:sub(5,6), 16) or 0
            self:set(Color3.fromRGB(r, g, b))
        end
    end)

    Tween.to(picker, { Size = UDim2.new(1, 0, 0, 72) }, 0.15)
    self._picker = picker
end

function Colorpicker:_closePicker()
    self._open = false
    if self._picker then
        Tween.to(self._picker, { Size = UDim2.new(1, 0, 0, 0) }, 0.12)
        task.delay(0.13, function()
            if self._picker then self._picker:Destroy(); self._picker = nil end
        end)
    end
end

function Colorpicker:set(color, transparency)
    self._color = color or self._color
    self._transparency = transparency or self._transparency
    self._swatch.BackgroundColor3 = self._color
    self._hexLabel.Text = self:_toHex()
    self._callback(self._color, self._transparency)
end
Colorpicker.Set = Colorpicker.set

function Colorpicker:get()
    return { Color = self._color, Transparency = self._transparency }
end
Colorpicker.Get = Colorpicker.get

return Colorpicker
