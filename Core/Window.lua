--[[
    GenUI — Core/Window.lua
    Main window object. Owns the sidebar, content panel, and ConfigManager.
--]]

local UserInputService = game:GetService("UserInputService")

local Util          = require(script.Parent.Parent.Util.Util)
local Tween         = require(script.Parent.Parent.Util.Tween)
local Theme         = require(script.Parent.Parent.Systems.Theme)
local Icons         = require(script.Parent.Parent.Systems.Icons)
local ConfigManager = require(script.Parent.Parent.Systems.Config)

local TOPBAR_H  = 44
local SIDEBAR_W = 180
local MIN_W     = 500
local MIN_H     = 380

local Window = {}
Window.__index = Window

-- ── Constructor ───────────────────────────────────────────────────────────────

function Window.new(screenGui, options, notifSystem)
    local self = setmetatable({}, Window)

    options = options or {}

    self._gui        = screenGui
    self._notif      = notifSystem
    self._visible    = true
    self._toggleKey  = options.OpenKey or Enum.KeyCode.RightShift
    self._folder     = options.Folder  or "GenUI"
    self._tabs       = {}
    self._activeTab  = nil
    self._connections = {}

    -- Theme
    self._theme = Theme.new(options.Theme or "Dark")

    -- Config
    self.ConfigManager  = ConfigManager.new(self._folder)
    self.CurrentConfig  = self.ConfigManager:config("default")

    -- Build window
    self:_build(options)

    -- Keyboard toggle
    table.insert(self._connections,
        UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.KeyCode == self._toggleKey then
                self:toggle()
            end
        end)
    )

    -- Auto-load configs
    self.ConfigManager:runAutoLoad()

    return self
end

-- ── Build UI ──────────────────────────────────────────────────────────────────

function Window:_build(options)
    local size = options.Size or UDim2.fromOffset(580, 420)

    -- Root frame
    self._root = Util.create("Frame", {
        Name            = "WindowFrame",
        AnchorPoint     = Vector2.new(0.5, 0.5),
        Position        = UDim2.new(0.5, 0, 0.5, 0),
        Size            = size,
        BackgroundColor3 = self._theme:get("Background"),
        BorderSizePixel = 0,
        ClipsDescendants = false,
    }, self._gui)
    Util.corner(self._root, UDim.new(0, 10))
    Util.stroke(self._root, self._theme:get("Border"), 1)
    self._theme:tag(self._root, "BackgroundColor3", "Background")

    -- Drop shadow (UIGradient trick via extra frame)
    local shadow = Util.create("Frame", {
        Name            = "Shadow",
        AnchorPoint     = Vector2.new(0.5, 0.5),
        Position        = UDim2.new(0.5, 0, 0.5, 4),
        Size            = UDim2.new(1, 12, 1, 12),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.7,
        ZIndex          = self._root.ZIndex - 1,
        BorderSizePixel = 0,
    }, self._gui)
    Util.corner(shadow, UDim.new(0, 14))

    -- Clip inner contents
    local clip = Util.create("Frame", {
        Name             = "ClipFrame",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
    }, self._root)
    Util.corner(clip, UDim.new(0, 10))

    self._clip = clip

    self:_buildTopbar(options)
    self:_buildSidebar(options)
    self:_buildContent()
    self:_makeDraggable()
end

function Window:_buildTopbar(options)
    local bar = Util.create("Frame", {
        Name            = "Topbar",
        Size            = UDim2.new(1, 0, 0, TOPBAR_H),
        BackgroundColor3 = self._theme:get("TopbarBg"),
        BorderSizePixel = 0,
        ZIndex          = 3,
    }, self._clip)
    Util.stroke(bar, self._theme:get("TopbarBorder"), 1)
    self._theme:tag(bar, "BackgroundColor3", "TopbarBg")

    Util.padding(bar, 0, 12, 0, 14)

    -- Title row
    local row = Util.create("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    }, bar)
    Util.listLayout(row, {
        FillDirection     = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding           = UDim.new(0, 8),
    })

    -- Window icon
    if options.Icon then
        local icon = Util.create("ImageLabel", {
            Size             = UDim2.new(0, 18, 0, 18),
            BackgroundTransparency = 1,
            ImageColor3      = self._theme:get("Accent"),
        }, row)
        Icons.apply(icon, options.Icon, self._theme:get("Accent"))
        self._theme:tag(icon, "ImageColor3", "Accent")
    end

    -- Title
    Util.create("TextLabel", {
        Size             = UDim2.new(1, -80, 1, 0),
        BackgroundTransparency = 1,
        Text             = options.Title or "GenUI",
        TextColor3       = self._theme:get("TextPrimary"),
        TextSize         = 13,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextTruncate     = Enum.TextTruncate.AtEnd,
    }, row)

    -- Control buttons (close / minimize)
    local controls = Util.create("Frame", {
        Size             = UDim2.new(0, 56, 0, 20),
        BackgroundTransparency = 1,
        LayoutOrder      = 99,
    }, bar)
    controls.AnchorPoint = Vector2.new(1, 0.5)
    controls.Position    = UDim2.new(1, 0, 0.5, 0)

    Util.listLayout(controls, {
        FillDirection     = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding           = UDim.new(0, 6),
    })

    -- Minimize
    self:_makeControlBtn(controls, "–", self._theme:get("Warning"), function()
        self:_minimize()
    end)

    -- Close
    self:_makeControlBtn(controls, "×", self._theme:get("Danger"), function()
        self:toggle()
    end)

    self._topbar = bar
end

function Window:_makeControlBtn(parent, symbol, color, callback)
    local btn = Util.create("TextButton", {
        Size             = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = self._theme:get("SurfaceHover"),
        Text             = symbol,
        TextColor3       = color,
        TextSize         = 13,
        Font             = Enum.Font.GothamBold,
    }, parent)
    Util.corner(btn, UDim.new(1, 0))

    btn.MouseEnter:Connect(function()
        Tween.color(btn, "BackgroundColor3", self._theme:get("SurfaceActive"), 0.12)
    end)
    btn.MouseLeave:Connect(function()
        Tween.color(btn, "BackgroundColor3", self._theme:get("SurfaceHover"), 0.12)
    end)
    btn.MouseButton1Click:Connect(callback)

    return btn
end

function Window:_buildSidebar(options)
    local sidebar = Util.create("Frame", {
        Name            = "Sidebar",
        Position        = UDim2.new(0, 0, 0, TOPBAR_H),
        Size            = UDim2.new(0, SIDEBAR_W, 1, -TOPBAR_H),
        BackgroundColor3 = self._theme:get("SidebarBg"),
        BorderSizePixel = 0,
    }, self._clip)
    self._theme:tag(sidebar, "BackgroundColor3", "SidebarBg")

    -- Right border
    Util.create("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = self._theme:get("SidebarBorder"),
        BorderSizePixel  = 0,
    }, sidebar)

    -- Search bar
    local searchFrame
    if not options.HideSearchBar then
        searchFrame = Util.create("Frame", {
            Size             = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
        }, sidebar)
        Util.padding(searchFrame, 8, 8, 4, 8)

        local searchBox = Util.create("Frame", {
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = self._theme:get("Surface"),
            BorderSizePixel  = 0,
        }, searchFrame)
        Util.corner(searchBox, UDim.new(0, 6))
        Util.stroke(searchBox, self._theme:get("Border"), 1)
        Util.padding(searchBox, 0, 8, 0, 8)

        local searchInput = Util.create("TextBox", {
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text             = "",
            PlaceholderText  = "Search...",
            TextColor3       = self._theme:get("TextPrimary"),
            PlaceholderColor3 = self._theme:get("TextMuted"),
            TextSize         = 12,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
        }, searchBox)

        -- Filter tabs on search
        searchInput:GetPropertyChangedSignal("Text"):Connect(function()
            self:_filterTabs(searchInput.Text)
        end)

        self._searchInput = searchInput
    end

    -- Tab list (scrollable)
    local scrollFrame = Util.create("ScrollingFrame", {
        Name             = "TabList",
        Position         = UDim2.new(0, 0, 0, searchFrame and 40 or 0),
        Size             = UDim2.new(1, 0, 1, -(searchFrame and 40 or 0)),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize        = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, sidebar)
    Util.padding(scrollFrame, 6, 6, 6, 6)
    Util.listLayout(scrollFrame, { Padding = UDim.new(0, 2) })

    self._sidebar    = sidebar
    self._tabList    = scrollFrame
end

function Window:_buildContent()
    self._content = Util.create("Frame", {
        Name            = "ContentPanel",
        Position        = UDim2.new(0, SIDEBAR_W, 0, TOPBAR_H),
        Size            = UDim2.new(1, -SIDEBAR_W, 1, -TOPBAR_H),
        BackgroundColor3 = self._theme:get("Background"),
        BorderSizePixel = 0,
    }, self._clip)
    self._theme:tag(self._content, "BackgroundColor3", "Background")
end

-- ── Dragging ──────────────────────────────────────────────────────────────────

function Window:_makeDraggable()
    local dragging, startPos, startMouse = false, nil, nil

    self._topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            startPos  = self._root.Position
            startMouse = input.Position
        end
    end)

    self._topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startMouse
            self._root.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ── Tab management ────────────────────────────────────────────────────────────

function Window:_makeTabButton(tab)
    local btn = Util.create("TextButton", {
        Name             = "TabBtn_" .. tab._title,
        Size             = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        Text             = "",
        AutoButtonColor  = false,
    }, self._tabList)
    Util.corner(btn, UDim.new(0, 6))
    Util.padding(btn, 0, 8, 0, 8)

    local row = Util.create("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    }, btn)
    Util.listLayout(row, {
        FillDirection     = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding           = UDim.new(0, 7),
    })

    -- Icon
    if tab._icon then
        local icon = Util.create("ImageLabel", {
            Size             = UDim2.new(0, 14, 0, 14),
            BackgroundTransparency = 1,
            ImageColor3      = self._theme:get("TextMuted"),
        }, row)
        Icons.apply(icon, tab._icon, self._theme:get("TextMuted"))
        tab._iconImg = icon
    end

    -- Label
    local label = Util.create("TextLabel", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = tab._title,
        TextColor3       = self._theme:get("TextSecondary"),
        TextSize         = 12,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, row)
    tab._btnLabel = label

    -- Hover / click
    btn.MouseEnter:Connect(function()
        if self._activeTab ~= tab then
            Tween.color(btn, "BackgroundColor3", self._theme:get("TabHover"), 0.12)
        end
    end)
    btn.MouseLeave:Connect(function()
        if self._activeTab ~= tab then
            Tween.to(btn, { BackgroundTransparency = 1 }, 0.12)
        end
    end)
    btn.MouseButton1Click:Connect(function()
        self:_selectTab(tab)
    end)

    tab._btn = btn
    return btn
end

function Window:_selectTab(tab)
    -- Deactivate old
    if self._activeTab then
        local old = self._activeTab
        old._frame.Visible = false
        Tween.to(old._btn, { BackgroundTransparency = 1 }, 0.12)
        if old._btnLabel then
            Tween.color(old._btn, "TextColor3", self._theme:get("TextSecondary"), 0.12)
            old._btnLabel.TextColor3 = self._theme:get("TextSecondary")
            old._btnLabel.Font = Enum.Font.Gotham
        end
        if old._iconImg then
            old._iconImg.ImageColor3 = self._theme:get("TextMuted")
        end
    end

    -- Activate new
    self._activeTab = tab
    tab._frame.Visible = true
    Tween.color(tab._btn, "BackgroundColor3", self._theme:get("TabActive"), 0.12)
    tab._btn.BackgroundTransparency = 0
    if tab._btnLabel then
        tab._btnLabel.TextColor3 = self._theme:get("TextPrimary")
        tab._btnLabel.Font = Enum.Font.GothamBold
    end
    if tab._iconImg then
        tab._iconImg.ImageColor3 = self._theme:get("Accent")
    end
end

function Window:_filterTabs(query)
    query = query:lower()
    for _, tab in ipairs(self._tabs) do
        local match = tab._title:lower():find(query, 1, true) ~= nil
        tab._btn.Visible = match
    end
end

-- ── Public API ────────────────────────────────────────────────────────────────

-- Create a Tab directly on this window
function Window:tab(options)
    local Tab = require(script.Parent.Tab)
    local t = Tab.new(self._content, self._theme, options)
    t._frame.Visible = false

    self:_makeTabButton(t)
    table.insert(self._tabs, t)

    -- Auto-select first tab
    if #self._tabs == 1 then
        self:_selectTab(t)
    end

    return t
end

-- Alias (WindUI compatibility)
Window.Tab = Window.tab

-- Create a Section (tab group) on the sidebar
function Window:section(options)
    local Section = require(script.Parent.Section)
    return Section.new(self, options)
end
Window.Section = Window.section

-- Toggle window visibility
function Window:toggle()
    self._visible = not self._visible
    if self._visible then
        self._root.Visible = true
        Tween.to(self._root, { Size = self._root.Size }, 0.2, Enum.EasingStyle.Back)
    else
        local s = self._root.Size
        Tween.to(self._root, { Size = UDim2.new(s.X.Scale, s.X.Offset, 0, 0) }, 0.18)
        task.delay(0.2, function()
            if not self._visible then
                self._root.Visible = false
            end
        end)
    end
end

-- Minimize (same as toggle for now)
function Window:_minimize()
    self:toggle()
end

-- Switch theme
function Window:setTheme(name)
    self._theme:switch(name)
end
Window.SetTheme = Window.setTheme

-- Scale the entire UI
function Window:setUIScale(scale)
    local uiScale = self._root:FindFirstChildOfClass("UIScale")
    if not uiScale then
        uiScale = Instance.new("UIScale")
        uiScale.Parent = self._root
    end
    uiScale.Scale = scale
end
Window.SetUIScale = Window.setUIScale

-- Change toggle key
function Window:setToggleKey(key)
    self._toggleKey = key
end
Window.SetToggleKey = Window.setToggleKey

-- Destroy window and cleanup
function Window:destroy()
    for _, conn in ipairs(self._connections) do
        conn:Disconnect()
    end
    if self._root then self._root:Destroy() end
end
Window.Destroy = Window.destroy

return Window
