--[[
    GenUI — Elements/Slider.lua
--]]

local Util  = require(script.Parent.Parent.Util.Util)
local Tween = require(script.Parent.Parent.Util.Tween)

local Slider = {}
Slider.__index = Slider

function Slider.new(parent, theme, options)
    local self = setmetatable({}, Slider)
    options = options or {}

    local valConfig = options.Value or { Min = 0, Max = 100, Default = 50 }
    self._theme    = theme
    self._min      = valConfig.Min
    self._max      = valConfig.Max
    self._value    = Util.clamp(valConfig.Default or valConfig.Min, valConfig.Min, valConfig.Max)
    self._step     = options.Step or 1
    self._callback = options.Callback or function() end
    self._locked   = options.Locked or false

    local hasTitle = options.Title and options.Title ~= ""
    local hasDesc  = options.Desc  and options.Desc  ~= ""

    self._root = Util.create("Frame", {
        Name             = "Slider",
        Size             = UDim2.new(1, 0, 0, hasTitle and (hasDesc and 64 or 52) or 36),
        BackgroundColor3 = theme:get("Surface"),
        BorderSizePixel  = 0,
    }, parent)
    Util.corner(self._root, UDim.new(0, 6))
    Util.stroke(self._root, theme:get("Border"), 1)
    Util.padding(self._root, 8, 12, 8, 12)
    Util.listLayout(self._root, { Padding = UDim.new(0, 4) })

    -- Title row
    if hasTitle then
        local titleRow = Util.create("Frame", {
            Size             = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
        }, self._root)

        Util.create("TextLabel", {
            Size             = UDim2.new(1, -40, 1, 0),
            BackgroundTransparency = 1,
            Text             = options.Title,
            TextColor3       = theme:get("TextPrimary"),
            TextSize         = 13,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
        }, titleRow)

        -- Value display
        self._valueLabel = Util.create("TextLabel", {
            AnchorPoint      = Vector2.new(1, 0),
            Position         = UDim2.new(1, 0, 0, 0),
            Size             = UDim2.new(0, 40, 1, 0),
            BackgroundTransparency = 1,
            Text             = tostring(self._value),
            TextColor3       = theme:get("Accent"),
            TextSize         = 12,
            Font             = Enum.Font.GothamBold,
            TextXAlignment   = Enum.TextXAlignment.Right,
        }, titleRow)
    end

    if hasDesc then
        Util.create("TextLabel", {
            Size             = UDim2.new(1, 0, 0, 12),
            BackgroundTransparency = 1,
            Text             = options.Desc,
            TextColor3       = theme:get("TextSecondary"),
            TextSize         = 11,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
        }, self._root)
    end

    -- Track
    local trackBg = Util.create("Frame", {
        Size             = UDim2.new(1, 0, 0, 6),
        BackgroundColor3 = theme:get("Border"),
        BorderSizePixel  = 0,
    }, self._root)
    Util.corner(trackBg, UDim.new(1, 0))

    self._fill = Util.create("Frame", {
        Size             = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = theme:get("Accent"),
        BorderSizePixel  = 0,
    }, trackBg)
    Util.corner(self._fill, UDim.new(1, 0))

    -- Knob
    self._knob = Util.create("Frame", {
        Size             = UDim2.new(0, 14, 0, 14),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = theme:get("ToggleKnob"),
        BorderSizePixel  = 0,
        ZIndex           = 3,
    }, trackBg)
    Util.corner(self._knob, UDim.new(1, 0))

    -- Drag logic
    local dragging = false
    local UserInputService = game:GetService("UserInputService")

    local function updateFromX(x)
        local abs = trackBg.AbsolutePosition.X
        local w   = trackBg.AbsoluteSize.X
        local t   = Util.clamp((x - abs) / w, 0, 1)
        local raw = self._min + t * (self._max - self._min)
        local stepped = Util.roundToStep(raw, self._step)
        self:set(stepped)
    end

    self._knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    trackBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromX(input.Position.X)
        end
    end)

    self._track = trackBg
    self:_render()

    return self
end

function Slider:_render()
    local t = (self._value - self._min) / (self._max - self._min)
    local w = self._track.AbsoluteSize.X
    self._fill.Size = UDim2.new(t, 0, 1, 0)
    self._knob.Position = UDim2.new(t, 0, 0.5, 0)
    if self._valueLabel then
        self._valueLabel.Text = tostring(self._value)
    end
end

function Slider:set(value)
    self._value = Util.clamp(Util.roundToStep(value, self._step), self._min, self._max)
    self:_render()
    self._callback(self._value)
end
Slider.Set = Slider.set

function Slider:get()
    return self._value
end
Slider.Get = Slider.get

return Slider
