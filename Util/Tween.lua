--[[
    GenUI — Util/Tween.lua
    TweenService wrapper with sensible UI animation presets
--]]

local TweenService = game:GetService("TweenService")

local Tween = {}

-- Default easing
local DEFAULT_TIME  = 0.2
local DEFAULT_STYLE = Enum.EasingStyle.Quart
local DEFAULT_DIR   = Enum.EasingDirection.Out

-- Core tween function
function Tween.to(instance, properties, duration, style, direction)
    duration  = duration  or DEFAULT_TIME
    style     = style     or DEFAULT_STYLE
    direction = direction or DEFAULT_DIR

    local info = TweenInfo.new(duration, style, direction)
    local t = TweenService:Create(instance, info, properties)
    t:Play()
    return t
end

-- Fade an element in or out
function Tween.fade(instance, targetAlpha, duration)
    return Tween.to(instance, { BackgroundTransparency = targetAlpha }, duration)
end

-- Fade a TextLabel/TextButton
function Tween.fadeText(instance, targetAlpha, duration)
    return Tween.to(instance, { TextTransparency = targetAlpha }, duration)
end

-- Slide: move to a new position
function Tween.slide(instance, targetPos, duration, style)
    return Tween.to(instance, { Position = targetPos }, duration, style)
end

-- Scale: resize to a new size
function Tween.scale(instance, targetSize, duration, style)
    return Tween.to(instance, { Size = targetSize }, duration, style)
end

-- Color transition
function Tween.color(instance, property, targetColor, duration)
    return Tween.to(instance, { [property] = targetColor }, duration)
end

-- Spring-like open animation (size from 0 to target)
function Tween.open(instance, targetSize, duration)
    return Tween.to(
        instance,
        { Size = targetSize },
        duration or 0.25,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    )
end

-- Quick close animation
function Tween.close(instance, duration)
    local current = instance.Size
    return Tween.to(
        instance,
        { Size = UDim2.new(current.X.Scale, current.X.Offset, 0, 0) },
        duration or 0.18,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.In
    )
end

-- Highlight flash (briefly change BackgroundColor3, then restore)
function Tween.highlight(instance, flashColor, duration)
    local original = instance.BackgroundColor3
    duration = duration or 0.12
    Tween.color(instance, "BackgroundColor3", flashColor, duration)
    task.delay(duration, function()
        Tween.color(instance, "BackgroundColor3", original, duration)
    end)
end

return Tween
