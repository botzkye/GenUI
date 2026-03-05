--[[
    GenUI — Core/Library.lua
    Root GenUI object. CreateWindow, Notify, Popup, RegisterTheme.
--]]

local Players    = game:GetService("Players")
local cloneref   = (cloneref or clonereference or function(i) return i end)

local Util         = require(script.Parent.Parent.Util.Util)
local Theme        = require(script.Parent.Parent.Systems.Theme)
local Icons        = require(script.Parent.Parent.Systems.Icons)
local Notification = require(script.Parent.Parent.Systems.Notification)
local Window       = require(script.Parent.Window)

local Library = {}
Library.__index = Library

Library.Version = "1.0.0"
Library.Icons   = Icons

-- Ensure ScreenGui exists (or reuse)
local function getScreenGui(folder)
    local player = cloneref(Players).LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local existing = playerGui:FindFirstChild("GenUI_ScreenGui")
    if existing then return existing end

    local gui = Util.create("ScreenGui", {
        Name             = "GenUI_ScreenGui",
        ResetOnSpawn     = false,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
        DisplayOrder     = 999,
    }, playerGui)

    return gui
end

-- ── CreateWindow ──────────────────────────────────────────────────────────────

function Library:CreateWindow(options)
    options = options or {}

    local gui    = getScreenGui(options.Folder)
    local theme  = Theme.new(options.Theme or "Dark")
    local notif  = Notification.new(gui, theme)
    local window = Window.new(gui, options, notif)

    -- Attach notify shortcut on window
    window.Notify = function(_, opts)
        self:Notify(opts)
    end

    self._screenGui = gui
    self._notif     = notif

    return window
end

-- ── Notify ────────────────────────────────────────────────────────────────────

function Library:Notify(options)
    if self._notif then
        self._notif:push(options)
    else
        warn("[GenUI] Notify called before CreateWindow")
    end
end

-- ── Popup ─────────────────────────────────────────────────────────────────────

function Library:Popup(options)
    if not self._screenGui then
        warn("[GenUI] Popup called before CreateWindow")
        return
    end

    options = options or {}
    local theme = Theme.new("Dark")

    -- Overlay
    local overlay = Util.create("Frame", {
        Name             = "PopupOverlay",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.5,
        ZIndex           = 200,
    }, self._screenGui)

    -- Card
    local card = Util.create("Frame", {
        Name             = "PopupCard",
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = UDim2.new(0, 340, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme:get("Elevated"),
        BorderSizePixel  = 0,
        ZIndex           = 201,
    }, overlay)
    Util.corner(card, UDim.new(0, 10))
    Util.stroke(card, theme:get("Border"), 1)
    Util.padding(card, 20, 20, 20, 20)
    Util.listLayout(card, { Padding = UDim.new(0, 10) })

    -- Title
    Util.create("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text             = options.Title or "Dialog",
        TextColor3       = theme:get("TextPrimary"),
        TextSize         = 16,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 202,
    }, card)

    -- Content
    if options.Content then
        Util.create("TextLabel", {
            Size             = UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text             = options.Content,
            TextColor3       = theme:get("TextSecondary"),
            TextSize         = 13,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
            TextWrapped      = true,
            ZIndex           = 202,
        }, card)
    end

    -- Buttons
    if options.Buttons and #options.Buttons > 0 then
        local btnRow = Util.create("Frame", {
            Size             = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1,
            ZIndex           = 202,
        }, card)
        Util.listLayout(btnRow, {
            FillDirection       = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment   = Enum.VerticalAlignment.Center,
            Padding             = UDim.new(0, 8),
        })

        for _, b in ipairs(options.Buttons) do
            local variant = b.Variant or "Secondary"
            local bgColor = variant == "Primary" and theme:get("Accent")
                         or variant == "Danger"  and theme:get("Danger")
                         or theme:get("SurfaceHover")
            local txtColor = variant == "Primary" and theme:get("AccentText")
                          or theme:get("TextPrimary")

            local btn = Util.create("TextButton", {
                Size             = UDim2.new(0, 0, 1, 0),
                AutomaticSize    = Enum.AutomaticSize.X,
                BackgroundColor3 = bgColor,
                Text             = " " .. (b.Title or "OK") .. " ",
                TextColor3       = txtColor,
                TextSize         = 12,
                Font             = Enum.Font.GothamBold,
                AutoButtonColor  = false,
                ZIndex           = 203,
            }, btnRow)
            Util.corner(btn, UDim.new(0, 6))
            Util.padding(btn, 0, 10, 0, 10)

            btn.MouseButton1Click:Connect(function()
                if b.Callback then b.Callback() end
                overlay:Destroy()
            end)
        end
    end

    -- Click overlay to dismiss
    local overlayBtn = Util.create("TextButton", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        ZIndex           = 200,
    }, overlay)
    overlayBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
    end)
end

-- ── RegisterTheme ─────────────────────────────────────────────────────────────

function Library:RegisterTheme(name, tokens)
    Theme.register(name, tokens)
end

return Library
