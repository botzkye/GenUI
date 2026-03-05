--[[
    GenUI — Elements/Toggle.lua
    Switch or Checkbox toggle. Config-saveable via Flag.
--]]

local Util  = require(script.Parent.Parent.Util.Util)
local Tween = require(script.Parent.Parent.Util.Tween)

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(parent, theme, options)
    local self = setmetatable({}, Toggle)
    options = options or {}

    self._theme    = theme
    self._value    = options.Value or false
    self._callback = options.Callback or function() end
    self._locked   = options.Locked or false
    self._type     = options.Type or "Switch"

    -- Root
    self._root = Util.create("Frame", {
        Name             = "Toggle",
        Size             = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = theme:get("Surface"),
        BorderSizePixel  = 0,
    }, parent)
    Util.corner(self._root, UDim.new(0, 6))
    Util.stroke(self._root, theme:get("Border"), 1)
    Util.padding(self._root, 0, 12, 0, 12)

    -- Row
    local row = Util.create("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    }, self._root)
    Util.listLayout(row, {
        FillDirection     = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding           = UDim.new(0, 8),
    })

    -- Text stack
    local textStack = Util.create("Frame", {
        Size             = UDim2.new(1, -50, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder      = 0,
    }, row)
    Util.listLayout(textStack, { Padding = UDim.new(0, 1) })

    if options.Title and options.Title ~= "" then
        Util.create("TextLabel", {
            Size             = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text             = options.Title,
            TextColor3       = theme:get("TextPrimary"),
            TextSize         = 13,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
        }, textStack)

        if options.Desc then
            self._root.Size = UDim2.new(1, 0, 0, 52)
            Util.create("TextLabel", {
                Size             = UDim2.new(1, 0, 0, 14),
                BackgroundTransparency = 1,
                Text             = options.Desc,
                TextColor3       = theme:get("TextSecondary"),
                TextSize         = 11,
                Font             = Enum.Font.Gotham,
                TextXAlignment   = Enum.TextXAlignment.Left,
            }, textStack)
        end
    end

    -- Switch or Checkbox
    if self._type == "Checkbox" then
        self:_buildCheckbox(row)
    else
        self:_buildSwitch(row)
    end

    -- Clickable overlay
    local btn = Util.create("TextButton", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        AutoButtonColor  = false,
        ZIndex           = 2,
    }, self._root)

    btn.MouseEnter:Connect(function()
        if not self._locked then
            Tween.color(self._root, "BackgroundColor3", theme:get("SurfaceHover"), 0.12)
        end
    end)
    btn.MouseLeave:Connect(function()
        Tween.color(self._root, "BackgroundColor3", theme:get("Surface"), 0.12)
    end)
    btn.MouseButton1Click:Connect(function()
        if self._locked then return end
        self:set(not self._value)
    end)

    -- Apply initial state
    self:_render(false)

    return self
end

function Toggle:_buildSwitch(parent)
    local track = Util.create("Frame", {
        Size             = UDim2.new(0, 36, 0, 20),
        BackgroundColor3 = self._theme:get("ToggleOff"),
        BorderSizePixel  = 0,
        LayoutOrder      = 99,
    }, parent)
    Util.corner(track, UDim.new(1, 0))

    local knob = Util.create("Frame", {
        Size             = UDim2.new(0, 14, 0, 14),
        Position         = UDim2.new(0, 3, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
        BackgroundColor3 = self._theme:get("ToggleKnob"),
        BorderSizePixel  = 0,
    }, track)
    Util.corner(knob, UDim.new(1, 0))

    self._track = track
    self._knob  = knob
end

function Toggle:_buildCheckbox(parent)
    local box = Util.create("Frame", {
        Size             = UDim2.new(0, 18, 0, 18),
        BackgroundColor3 = self._theme:get("ToggleOff"),
        BorderSizePixel  = 0,
        LayoutOrder      = 99,
    }, parent)
    Util.corner(box, UDim.new(0, 4))
    Util.stroke(box, self._theme:get("Border"), 1)

    local check = Util.create("TextLabel", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "✓",
        TextColor3       = self._theme:get("AccentText"),
        TextSize         = 12,
        Font             = Enum.Font.GothamBold,
        TextTransparency = 1,
    }, box)

    self._checkBox   = box
    self._checkMark  = check
end

function Toggle:_render(animate)
    local dur = animate and 0.15 or 0

    if self._type == "Checkbox" then
        if self._value then
            Tween.color(self._checkBox, "BackgroundColor3", self._theme:get("Accent"), dur)
            Tween.to(self._checkMark, { TextTransparency = 0 }, dur)
        else
            Tween.color(self._checkBox, "BackgroundColor3", self._theme:get("ToggleOff"), dur)
            Tween.to(self._checkMark, { TextTransparency = 1 }, dur)
        end
    else
        if self._value then
            Tween.color(self._track, "BackgroundColor3", self._theme:get("ToggleOn"), dur)
            Tween.to(self._knob, { Position = UDim2.new(1, -17, 0.5, 0) }, dur, Enum.EasingStyle.Back)
        else
            Tween.color(self._track, "BackgroundColor3", self._theme:get("ToggleOff"), dur)
            Tween.to(self._knob, { Position = UDim2.new(0, 3, 0.5, 0) }, dur, Enum.EasingStyle.Back)
        end
    end
end

function Toggle:set(value)
    self._value = value
    self:_render(true)
    self._callback(value)
end
Toggle.Set = Toggle.set

function Toggle:get()
    return self._value
end
Toggle.Get = Toggle.get

return Toggle
