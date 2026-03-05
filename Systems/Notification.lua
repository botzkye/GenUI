--[[
    GenUI — Systems/Notification.lua
    Toast notification queue.
    Renders stacked cards in the bottom-right of the screen.
--]]

local TweenService = game:GetService("TweenService")
local Util  = require(script.Parent.Parent.Util.Util)
local Tween = require(script.Parent.Parent.Util.Tween)
local Icons = require(script.Parent.Icons)

local Notification = {}
Notification.__index = Notification

local CARD_WIDTH   = 280
local CARD_MIN_H   = 56
local CARD_PADDING = 10
local CARD_GAP     = 8
local EDGE_MARGIN  = 16

-- ── Setup ─────────────────────────────────────────────────────────────────────

function Notification.new(screenGui, theme)
    local self = setmetatable({}, Notification)
    self._gui    = screenGui
    self._theme  = theme
    self._queue  = {}
    self._count  = 0

    -- Container frame (bottom-right anchor)
    self._container = Util.create("Frame", {
        Name              = "NotificationContainer",
        AnchorPoint       = Vector2.new(1, 1),
        Position          = UDim2.new(1, -EDGE_MARGIN, 1, -EDGE_MARGIN),
        Size              = UDim2.new(0, CARD_WIDTH, 1, 0),
        BackgroundTransparency = 1,
        ZIndex            = 100,
    }, screenGui)

    Util.listLayout(self._container, {
        FillDirection      = Enum.FillDirection.Vertical,
        VerticalAlignment  = Enum.VerticalAlignment.Bottom,
        Padding            = UDim.new(0, CARD_GAP),
    })

    return self
end

-- ── Push a notification ───────────────────────────────────────────────────────

function Notification:push(options)
    options = options or {}
    local title    = options.Title    or "Notification"
    local content  = options.Content  or nil
    local icon     = options.Icon     or nil
    local duration = options.Duration or 3
    local canClose = options.CanClose ~= false

    self._count += 1
    local id = self._count

    -- Card frame
    local card = Util.create("Frame", {
        Name              = "Notification_" .. id,
        Size              = UDim2.new(1, 0, 0, 0),
        BackgroundColor3  = self._theme:get("Elevated"),
        BackgroundTransparency = 0,
        ClipsDescendants  = true,
        LayoutOrder       = id,
    }, self._container)
    Util.corner(card, UDim.new(0, 8))
    Util.stroke(card, self._theme:get("Border"), 1)

    -- Inner padding
    local inner = Util.create("Frame", {
        Name             = "Inner",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    }, card)
    Util.padding(inner, 12, 12, 12, 12)
    Util.listLayout(inner, {
        Padding = UDim.new(0, 4),
    })

    -- Top row: icon + title + close button
    local topRow = Util.create("Frame", {
        Name             = "TopRow",
        Size             = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
    }, inner)
    Util.listLayout(topRow, {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
    })

    -- Icon (optional)
    if icon then
        local img = Util.create("ImageLabel", {
            Size             = UDim2.new(0, 16, 0, 16),
            BackgroundTransparency = 1,
            ImageColor3      = self._theme:get("Accent"),
        }, topRow)
        Icons.apply(img, icon, self._theme:get("Accent"))
    end

    -- Title
    local titleLabel = Util.create("TextLabel", {
        Size             = UDim2.new(1, canClose and -22 or 0, 0, 20),
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = self._theme:get("TextPrimary"),
        TextSize         = 13,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextTruncate     = Enum.TextTruncate.AtEnd,
    }, topRow)

    -- Close button (optional)
    if canClose then
        local closeBtn = Util.create("TextButton", {
            Size             = UDim2.new(0, 18, 0, 18),
            BackgroundTransparency = 1,
            Text             = "×",
            TextColor3       = self._theme:get("TextMuted"),
            TextSize         = 16,
            Font             = Enum.Font.GothamBold,
        }, topRow)
        closeBtn.MouseButton1Click:Connect(function()
            self:_dismiss(card)
        end)
    end

    -- Content (optional)
    if content then
        Util.create("TextLabel", {
            Name             = "Content",
            Size             = UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text             = content,
            TextColor3       = self._theme:get("TextSecondary"),
            TextSize         = 12,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
            TextWrapped      = true,
        }, inner)
    end

    -- Accent bottom line
    Util.create("Frame", {
        Name             = "AccentLine",
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = self._theme:get("Accent"),
        BorderSizePixel  = 0,
    }, card)

    -- Animate in
    local targetHeight = CARD_MIN_H + (content and 32 or 0)

    card.Size = UDim2.new(1, 0, 0, 0)
    Tween.to(card, { Size = UDim2.new(1, 0, 0, targetHeight) }, 0.2, Enum.EasingStyle.Back)

    -- Store reference
    table.insert(self._queue, card)

    -- Auto-dismiss
    if duration and duration > 0 then
        task.delay(duration, function()
            self:_dismiss(card)
        end)
    end
end

-- ── Dismiss a card ────────────────────────────────────────────────────────────

function Notification:_dismiss(card)
    if not card or not card.Parent then return end

    local tween = Tween.to(card, { Size = UDim2.new(1, 0, 0, 0) }, 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    tween.Completed:Connect(function()
        if card and card.Parent then
            card:Destroy()
        end
        -- Remove from queue
        for i, c in ipairs(self._queue) do
            if c == card then
                table.remove(self._queue, i)
                break
            end
        end
    end)
end

-- Dismiss all active notifications
function Notification:dismissAll()
    for _, card in ipairs(self._queue) do
        self:_dismiss(card)
    end
end

return Notification
