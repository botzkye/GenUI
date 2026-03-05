--[[
    GenUI — Elements/Button.lua
--]]

local Util  = require(script.Parent.Parent.Util.Util)
local Tween = require(script.Parent.Parent.Util.Tween)
local Icons = require(script.Parent.Parent.Systems.Icons)

local Button = {}
Button.__index = Button

local HEIGHT = 36

function Button.new(parent, theme, options)
    local self = setmetatable({}, Button)
    options = options or {}

    self._theme    = theme
    self._callback = options.Callback or function() end
    self._locked   = options.Locked or false
    self._lockedMsg = options.LockedTitle or "Locked"

    local accentColor = options.Color or theme:get("Surface")
    local justify     = options.Justify or "Left"
    local iconAlign   = options.IconAlign or "Left"

    -- Root frame
    self._root = Util.create("Frame", {
        Name             = "Button",
        Size             = UDim2.new(1, 0, 0, HEIGHT),
        BackgroundColor3 = theme:get("Surface"),
        BorderSizePixel  = 0,
    }, parent)
    Util.corner(self._root, UDim.new(0, 6))
    Util.stroke(self._root, theme:get("Border"), 1)
    Util.padding(self._root, 0, 12, 0, 12)

    -- Clickable button overlay
    local btn = Util.create("TextButton", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        AutoButtonColor  = false,
        ZIndex           = 2,
    }, self._root)

    -- Content row
    local row = Util.create("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    }, self._root)
    Util.listLayout(row, {
        FillDirection     = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = justify == "Center" and Enum.HorizontalAlignment.Center
                           or justify == "Right"  and Enum.HorizontalAlignment.Right
                           or Enum.HorizontalAlignment.Left,
        Padding           = UDim.new(0, 7),
    })

    -- Icon
    local hasIcon = options.Icon and options.Icon ~= ""
    if hasIcon and iconAlign == "Left" then
        local img = Util.create("ImageLabel", {
            Size             = UDim2.new(0, 14, 0, 14),
            BackgroundTransparency = 1,
            LayoutOrder      = 0,
        }, row)
        Icons.apply(img, options.Icon, theme:get("TextSecondary"))
    end

    -- Title + Desc stack
    local textStack = Util.create("Frame", {
        Size             = UDim2.new(0, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        LayoutOrder      = 1,
    }, row)
    Util.listLayout(textStack, { Padding = UDim.new(0, 1) })

    Util.create("TextLabel", {
        Size             = UDim2.new(0, 0, 0, 18),
        AutomaticSize    = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text             = options.Title or "Button",
        TextColor3       = theme:get("TextPrimary"),
        TextSize         = 13,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, textStack)

    if options.Desc then
        Util.create("TextLabel", {
            Size             = UDim2.new(0, 0, 0, 14),
            AutomaticSize    = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text             = options.Desc,
            TextColor3       = theme:get("TextSecondary"),
            TextSize         = 11,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
        }, textStack)
        self._root.Size = UDim2.new(1, 0, 0, HEIGHT + 16)
    end

    -- Right icon
    if hasIcon and iconAlign == "Right" then
        local img = Util.create("ImageLabel", {
            Size             = UDim2.new(0, 14, 0, 14),
            BackgroundTransparency = 1,
            LayoutOrder      = 99,
        }, row)
        Icons.apply(img, options.Icon, theme:get("TextSecondary"))
    end

    -- Accent left bar (if custom color provided)
    if options.Color then
        local bar = Util.create("Frame", {
            Size             = UDim2.new(0, 3, 1, -8),
            Position         = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint      = Vector2.new(0, 0.5),
            BackgroundColor3 = accentColor,
            BorderSizePixel  = 0,
        }, self._root)
        Util.corner(bar, UDim.new(1, 0))
    end

    -- Hover / press
    btn.MouseEnter:Connect(function()
        if not self._locked then
            Tween.color(self._root, "BackgroundColor3", theme:get("SurfaceHover"), 0.12)
        end
    end)
    btn.MouseLeave:Connect(function()
        Tween.color(self._root, "BackgroundColor3", theme:get("Surface"), 0.12)
    end)
    btn.MouseButton1Down:Connect(function()
        if not self._locked then
            Tween.color(self._root, "BackgroundColor3", theme:get("SurfaceActive"), 0.08)
        end
    end)
    btn.MouseButton1Click:Connect(function()
        if self._locked then return end
        self._callback()
    end)

    self._btn = btn
    return self
end

function Button:highlight()
    Tween.highlight(self._root, self._theme:get("Accent"), 0.15)
end
Button.Highlight = Button.highlight

function Button:lock(msg)
    self._locked = true
    self._lockedMsg = msg or self._lockedMsg
    self._root.BackgroundTransparency = 0.4
end
Button.Lock = Button.lock

function Button:unlock()
    self._locked = false
    self._root.BackgroundTransparency = 0
end
Button.Unlock = Button.unlock

return Button
