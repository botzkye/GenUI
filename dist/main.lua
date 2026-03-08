--[[
    GenUI v1.1.0 | Full Single-file Bundle
    Fixed & Completed version of your provided source
--]]

local cloneref = (cloneref or clonereference or function(i) return i end)
_G.__GenUI_modules = _G.__GenUI_modules or {}
local _m = _G.__GenUI_modules

-- ── 1. Util.Signal ──────────────────────────────
_m["Util.Signal"] = (function()
    local Signal = {}
    Signal.__index = Signal
    function Signal.new() return setmetatable({_connections = {}}, Signal) end
    function Signal:Connect(callback)
        local id = tostring(callback)
        self._connections[id] = callback
        return {Disconnect = function() self._connections[id] = nil end}
    end
    function Signal:Fire(...) for _, callback in pairs(self._connections) do task.spawn(callback, ...) end end
    function Signal:FireSync(...) for _, callback in pairs(self._connections) do callback(...) end end
    function Signal:Once(callback)
        local conn; conn = self:Connect(function(...) conn.Disconnect(); callback(...) end)
        return conn
    end
    function Signal:DisconnectAll() self._connections = {} end
    function Signal:Destroy() self:DisconnectAll() end
    return Signal
end)()

-- ── 2. Util.Flags ──────────────────────────────
_m["Util.Flags"] = (function()
    local Flags = {_registry = {}}
    function Flags.set(flag, element) if flag and flag ~= "" then Flags._registry[flag] = element end end
    function Flags.get(flag) return Flags._registry[flag] end
    function Flags.all() return Flags._registry end
    function Flags.remove(flag) Flags._registry[flag] = nil end
    function Flags.clear() Flags._registry = {} end
    return Flags
end)()

-- ── 3. Util.Tween ──────────────────────────────
_m["Util.Tween"] = (function()
    local TS = game:GetService("TweenService")
    local Tween = {}
    function Tween.to(inst, props, dur, style, dir)
        local t = TS:Create(inst, TweenInfo.new(dur or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props)
        t:Play(); return t
    end
    function Tween.fade(inst, target, dur) return Tween.to(inst, {BackgroundTransparency = target}, dur) end
    function Tween.open(inst, target, dur) return Tween.to(inst, {Size = target}, dur or 0.25, Enum.EasingStyle.Back) end
    return Tween
end)()

-- ── 4. Util.Util (CLEANED - NO DUPLICATES) ──────────────────────────────
_m["Util.Util"] = (function()
    local Util = {}
    Util.cloneref = cloneref

    function Util.create(className, properties, parent)
        local obj = Instance.new(className)
        for prop, value in pairs(properties or {}) do
            if prop ~= "Parent" then obj[prop] = value end
        end
        obj.Parent = parent
        return obj
    end

    function Util.corner(instance, radius)
        local corner = Instance.new("UICorner", instance)
        corner.CornerRadius = radius or UDim.new(0, 8)
        instance.ClipsDescendants = true
        return corner
    end

    function Util.stroke(instance, color, thickness, trans)
        local s = Instance.new("UIStroke", instance)
        s.Color = color or Color3.fromRGB(255, 255, 255)
        s.Thickness = thickness or 1
        s.Transparency = trans or 0
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.LineJoinMode = Enum.LineJoinMode.Round -- Fix pojokan mulus
        return s
    end

    function Util.padding(instance, top, right, bottom, left)
        local pad = Instance.new("UIPadding", instance)
        pad.PaddingTop, pad.PaddingRight = UDim.new(0, top or 0), UDim.new(0, right or 0)
        pad.PaddingBottom, pad.PaddingLeft = UDim.new(0, bottom or 0), UDim.new(0, left or 0)
        return pad
    end

    function Util.listLayout(instance, options)
        local layout = Instance.new("UIListLayout", instance)
        layout.FillDirection = options.FillDirection or Enum.FillDirection.Vertical
        layout.Padding = options.Padding or UDim.new(0, 0)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        return layout
    end

    function Util.toJSON(t) return game:GetService("HttpService"):JSONEncode(t) end
    function Util.fromJSON(str) local ok, res = pcall(function() return game:GetService("HttpService"):JSONDecode(str) end) return ok and res or {} end
    function Util.getService(name) return cloneref(game:GetService(name)) end

    return Util
end)()

-- ── 5. Systems.Theme ──────────────────────────────
_m["Systems.Theme"] = (function()
    local Theme = {}
    Theme.__index = Theme
    local THEMES = {
        Dark = {
            Background = Color3.fromHex("#0d0d0d"),
            Elevated = Color3.fromHex("#1a1a1a"),
            Border = Color3.fromHex("#222222"),
            Accent = Color3.fromHex("#b8ff57"),
            TextPrimary = Color3.fromHex("#f0f0f0"),
            TextSecondary = Color3.fromHex("#888888"),
            SidebarBg = Color3.fromHex("#0f0f0f"),
        }
    }
    function Theme.new(name)
        local self = setmetatable({_name = name or "Dark", _tokens = THEMES[name] or THEMES.Dark, _tagged = {}}, Theme)
        return self
    end
    function Theme:get(token) return self._tokens[token] or Color3.new(1,0,1) end
    return Theme
end)()

-- ── 6. Systems.Icons ──────────────────────────────
_m["Systems.Icons"] = (function()
    local Icons = {}
    function Icons.resolve(name)
        local map = {settings = "rbxasset://textures/ui/Settings.png", info = "rbxasset://textures/ui/Notification/Info.png"}
        return map[name] or "rbxasset://textures/ui/GuiImagePlaceholder.png"
    end
    function Icons.apply(img, name, color)
        img.Image = Icons.resolve(name)
        if color then img.ImageColor3 = color end
    end
    return Icons
end)()

-- ── 7. Systems.Notification ──────────────────────────────
_m["Systems.Notification"] = (function()
    local Util = _m["Util.Util"]; local Tween = _m["Util.Tween"]; local Icons = _m["Systems.Icons"]
    local Notification = {}
    Notification.__index = Notification
    function Notification.new(gui, theme)
        local self = setmetatable({_theme = theme}, Notification)
        self._container = Util.create("Frame", {
            Name = "NotifRoot", AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -20, 1, -20), Size = UDim2.new(0, 260, 0.8, 0),
            BackgroundTransparency = 1,
        }, gui)
        Util.listLayout(self._container, {VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 8)})
        return self
    end
    function Notification:push(opt)
        local card = Util.create("CanvasGroup", {
            Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = self._theme:get("Elevated"),
            GroupTransparency = 1,
        }, self._container)
        Util.corner(card); Util.stroke(card, self._theme:get("Border"))
        local t = Util.create("TextLabel", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = opt.Content or "", TextColor3 = self._theme:get("TextPrimary"), Font = Enum.Font.Gotham, TextSize = 12}, card)
        Util.padding(t, 0, 10, 0, 10)
        Tween.to(card, {GroupTransparency = 0}, 0.3)
        task.delay(opt.Duration or 3, function()
            Tween.to(card, {GroupTransparency = 1}, 0.3).Completed:Connect(function() card:Destroy() end)
        end)
    end
    return Notification
end)()

-- ── 8. Systems.Config (COMPLETED) ──────────────────────────────
_m["Systems.Config"] = (function()
    local Util = _m["Util.Util"]; local Flags = _m["Util.Flags"]
    local ConfigEntry = {}
    ConfigEntry.__index = ConfigEntry
    function ConfigEntry.new(manager, name)
        return setmetatable({_manager = manager, _name = name}, ConfigEntry)
    end
    function ConfigEntry:save()
        local data = {}
        for f, el in pairs(Flags.all()) do data[f] = el:Get() end
        writefile(self._manager._folder.."/"..self._name..".json", Util.toJSON(data))
    end
    function ConfigEntry:load()
        local path = self._manager._folder.."/"..self._name..".json"
        if isfile(path) then
            local data = Util.fromJSON(readfile(path))
            for f, v in pairs(data) do if Flags.get(f) then Flags.get(f):Set(v) end end
        end
    end
    
    local ConfigManager = {}
    function ConfigManager.new(folder) return { _folder = folder or "GenUI_Configs" } end
    return ConfigManager
end)()

-- ── 9. MAIN GenUI INTERFACE ──────────────────────────────
local GenUI = {}
function GenUI.CreateWindow(config)
    local Util = _m["Util.Util"]
    local Theme = _m["Systems.Theme"].new()
    local sg = Util.create("ScreenGui", {Name = "GenUI_Interface", ResetOnSpawn = false}, game:GetService("CoreGui"))
    
    local Main = Util.create("Frame", {
        Name = "Main", Size = UDim2.new(0, 520, 0, 340),
        Position = UDim2.new(0.5, -260, 0.5, -170),
        BackgroundColor3 = Theme:get("Background"),
    }, sg)
    Util.corner(Main); Util.stroke(Main, Theme:get("Border"), 1.5)

    -- Sidebar (Permintaan: Di Kiri)
    local Sidebar = Util.create("Frame", {
        Name = "Sidebar", Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = Theme:get("SidebarBg"),
    }, Main)
    Util.corner(Sidebar)
    
    local Notif = _m["Systems.Notification"].new(sg, Theme)
    return {
        Notify = function(msg) Notif:push({Content = msg}) end,
    }
end

-- Test Run
local window = GenUI.CreateWindow({Title = "GenUI Demo"})
window.Notify("GenUI v1.1.0 Loaded!")

return GenUI
-- ── ConfigManager ─────────────────────────────────────────────────────────────

local ConfigManager = {}
ConfigManager.__index = ConfigManager

function ConfigManager.new(folder)
    local self = setmetatable({}, ConfigManager)
    self._folder  = folder
    self._configs = {}

    -- Ensure folder exists
    if makefolder and not isfolder then
        pcall(makefolder, folder)
        pcall(makefolder, folder .. "/configs")
    elseif makefolder and isfolder then
        if not isfolder(folder) then
            makefolder(folder)
        end
        if not isfolder(folder .. "/configs") then
            makefolder(folder .. "/configs")
        end
    end

    return self
end

-- Get or create a config by name
function ConfigManager:config(name)
    name = name or "default"
    if not self._configs[name] then
        self._configs[name] = ConfigEntry.new(self, name)
    end
    return self._configs[name]
end

-- List all saved config names
function ConfigManager:allConfigs()
    local names = {}
    if not listfiles or not isfile then return names end

    local ok, files = pcall(listfiles, self._folder .. "/configs")
    if not ok then return names end

    for _, path in ipairs(files) do
        -- Extract filename without extension
        local name = path:match("([^/\\]+)%.json$")
        if name and name ~= "_autoload" then
            table.insert(names, name)
        end
    end

    table.sort(names)
    return names
end

-- Get raw data of a saved config (without loading it)
function ConfigManager:getConfig(name)
    if not readfile or not isfile then return {} end
    local path = self._folder .. "/configs/" .. name .. ".json"
    if not isfile(path) then return {} end
    local ok, raw = pcall(readfile, path)
    return ok and Util.fromJSON(raw) or {}
end

-- Get the names of configs with AutoLoad enabled
function ConfigManager:getAutoLoadConfigs()
    if not readfile or not isfile then return {} end
    local metaPath = self._folder .. "/configs/_autoload.json"
    if not isfile(metaPath) then return {} end
    local ok, raw = pcall(readfile, metaPath)
    if not ok then return {} end
    local meta = Util.fromJSON(raw)
    local names = {}
    for name, enabled in pairs(meta) do
        if enabled then table.insert(names, name) end
    end
    return names
end

-- Auto-load any configs marked for auto-load
function ConfigManager:runAutoLoad()
    for _, name in ipairs(self:getAutoLoadConfigs()) do
        self:config(name):load()
    end
end

return ConfigManager
end)()

-- ── Elements.Button ──────────────────────────────
_m["Elements.Button"] = (function()
local Util  = _G.__GenUI_modules["Util.Util"]
local Tween = _G.__GenUI_modules["Util.Tween"]
local Icons = _G.__GenUI_modules["Systems.Icons"]

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

    -- Root frame — AutomaticSize so padding top=bottom always equal
    self._root = Util.create("Frame", {
        Name             = "Button",
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme:get("Surface"),
        BorderSizePixel  = 0,
    }, parent)
    Util.corner(self._root, UDim.new(0, 6))
    Util.stroke(self._root, theme:get("Border"), 1)
    Util.padding(self._root, 10, 12, 10, 12)

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
end)()

-- ── Elements.Toggle ──────────────────────────────
_m["Elements.Toggle"] = (function()
local Util  = _G.__GenUI_modules["Util.Util"]
local Tween = _G.__GenUI_modules["Util.Tween"]

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
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme:get("Surface"),
        BorderSizePixel  = 0,
    }, parent)
    Util.corner(self._root, UDim.new(0, 6))
    Util.stroke(self._root, theme:get("Border"), 1)
    Util.padding(self._root, 10, 12, 10, 12)

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
end)()

-- ── Elements.Slider ──────────────────────────────
_m["Elements.Slider"] = (function()
local Util  = _G.__GenUI_modules["Util.Util"]
local Tween = _G.__GenUI_modules["Util.Tween"]

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
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme:get("Surface"),
        BorderSizePixel  = 0,
    }, parent)
    Util.corner(self._root, UDim.new(0, 6))
    Util.stroke(self._root, theme:get("Border"), 1)
    Util.padding(self._root, 10, 12, 10, 12)
    Util.listLayout(self._root, { Padding = UDim.new(0, 8) })

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
end)()

-- ── Elements.Input ──────────────────────────────
_m["Elements.Input"] = (function()
local Util  = _G.__GenUI_modules["Util.Util"]
local Tween = _G.__GenUI_modules["Util.Tween"]

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

    self._root = Util.create("Frame", {
        Name             = "Input",
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme:get("Surface"),
        BorderSizePixel  = 0,
    }, parent)
    Util.corner(self._root, UDim.new(0, 6))
    Util.stroke(self._root, theme:get("Border"), 1)
    Util.padding(self._root, 10, 10, 10, 10)
    Util.listLayout(self._root, { Padding = UDim.new(0, 6) })

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

    -- Focus highlight — reuse one UIStroke
    local stroke = Util.stroke(inputFrame, theme:get("Border"), 1)

    self._box.Focused:Connect(function()
        Tween.color(stroke, "Color", theme:get("Accent"), 0.12)
    end)
    self._box.FocusLost:Connect(function()
        Tween.color(stroke, "Color", theme:get("Border"), 0.12)
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
end)()

-- ── Elements.Dropdown ──────────────────────────────
_m["Elements.Dropdown"] = (function()
local Util  = _G.__GenUI_modules["Util.Util"]
local Tween = _G.__GenUI_modules["Util.Tween"]
local Icons = _G.__GenUI_modules["Systems.Icons"]
local UIS   = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Dropdown = {}
Dropdown.__index = Dropdown

local ITEM_H   = 30
local MAX_H    = 200

function Dropdown.new(parent, theme, options)
    local self    = setmetatable({}, Dropdown)
    options       = options or {}

    self._theme     = theme
    self._callback  = options.Callback  or function() end
    self._multi     = options.Multi     or false
    self._allowNone = options.AllowNone or false
    self._locked    = options.Locked    or false
    self._values    = options.Values    or {}
    self._selected  = {}
    self._open      = false
    self._conn      = nil
    self._popup     = nil

    -- Resolve ScreenGui for popup parenting
    self._gui = Players.LocalPlayer:WaitForChild("PlayerGui")
        :FindFirstChild("GenUI_ScreenGui")

    -- Pre-select
    if options.Value then
        if type(options.Value) == "table" then
            for _, v in ipairs(options.Value) do
                self._selected[tostring(v)] = true
            end
        else
            self._selected[tostring(options.Value)] = true
        end
    elseif not self._allowNone and not self._multi and #self._values > 0 then
        local first = type(self._values[1]) == "table"
            and self._values[1].Title or tostring(self._values[1])
        self._selected[first] = true
    end

    -- ── Root ──────────────────────────────────────────────────────────────────
    self._root = Util.create("Frame", {
        Name             = "Dropdown",
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme:get("Surface"),
        BorderSizePixel  = 0,
    }, parent)
    Util.corner(self._root, UDim.new(0, 6))
    Util.stroke(self._root, theme:get("Border"), 1)
    Util.padding(self._root, 10, 10, 10, 10)
    Util.listLayout(self._root, { Padding = UDim.new(0, 5) })

    -- Title label
    if options.Title then
        Util.create("TextLabel", {
            Size             = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Text             = options.Title,
            TextColor3       = theme:get("TextPrimary"),
            TextSize         = 13,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
        }, self._root)
    end

    -- ── Selector (only this part is clickable) ────────────────────────────────
    self._selector = Util.create("Frame", {
        Name             = "Selector",
        Size             = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = theme:get("Background"),
        BorderSizePixel  = 0,
    }, self._root)
    Util.corner(self._selector, UDim.new(0, 5))
    Util.stroke(self._selector, theme:get("Border"), 1)
    Util.padding(self._selector, 0, 8, 0, 8)

    -- Inner row: label + chevron
    local selRow = Util.create("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    }, self._selector)
    Util.listLayout(selRow, {
        FillDirection     = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })

    self._displayLabel = Util.create("TextLabel", {
        Size             = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1,
        Text             = self:_getText(),
        TextColor3       = theme:get("TextSecondary"),
        TextSize         = 12,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextTruncate     = Enum.TextTruncate.AtEnd,
    }, selRow)

    self._chevronLabel = Util.create("TextLabel", {
        Size             = UDim2.new(0, 20, 1, 0),
        BackgroundTransparency = 1,
        Text             = "▾",
        TextColor3       = theme:get("TextMuted"),
        TextSize         = 12,
        Font             = Enum.Font.GothamBold,
    }, selRow)

    -- Button strictly on selector only
    local btn = Util.create("TextButton", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        ZIndex           = 3,
    }, self._selector)

    btn.MouseEnter:Connect(function()
        if not self._locked then
            Tween.color(self._selector, "BackgroundColor3", theme:get("SurfaceHover"), 0.1)
        end
    end)
    btn.MouseLeave:Connect(function()
        Tween.color(self._selector, "BackgroundColor3", theme:get("Background"), 0.1)
    end)
    btn.MouseButton1Click:Connect(function()
        if self._locked then return end
        if self._open then self:_close() else self:_openPopup() end
    end)

    return self
end

-- ── Helpers ───────────────────────────────────────────────────────────────────

function Dropdown:_getText()
    local keys = {}
    for k in pairs(self._selected) do table.insert(keys, k) end
    if #keys == 0 then return "Select..." end
    table.sort(keys)
    if #keys == 1 then return keys[1] end
    return keys[1] .. "  +" .. (#keys - 1)
end

-- ── Open popup (parented to ScreenGui so it is never clipped) ─────────────────

function Dropdown:_openPopup()
    if self._open then return end
    self._open = true

    -- Calculate world position of selector
    local abs    = self._selector.AbsolutePosition
    local absSize = self._selector.AbsoluteSize

    -- Count items for height
    local rows = 0
    for _, v in ipairs(self._values) do
        rows += (type(v) == "table" and v.Type == "Divider") and 0.3 or 1
    end
    local popupH = math.min(math.ceil(rows) * ITEM_H + 8, MAX_H)
    local popupW = absSize.X

    -- Parent popup to ScreenGui so it renders above everything
    local gui = self._gui
    if not gui then
        -- Fallback: parent to root's ancestor ScreenGui
        local p = self._root
        while p and not p:IsA("ScreenGui") do p = p.Parent end
        gui = p
    end

    local popup = Util.create("Frame", {
        Name             = "GenUI_DropdownPopup",
        Position         = UDim2.fromOffset(abs.X, abs.Y + absSize.Y + 4),
        Size             = UDim2.fromOffset(popupW, 0),
        BackgroundColor3 = self._theme:get("Elevated"),
        BorderSizePixel  = 0,
        ZIndex           = 100,
    }, gui)
    Util.corner(popup, UDim.new(0, 6))
    Util.stroke(popup, self._theme:get("BorderFocus"), 1)

    -- Scrolling list
    local scroll = Util.create("ScrollingFrame", {
        Size               = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel    = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = self._theme:get("ScrollBar"),
        CanvasSize         = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex             = 101,
        ClipsDescendants   = true,
    }, popup)
    Util.padding(scroll, 4, 4, 4, 4)
    Util.listLayout(scroll, { Padding = UDim.new(0, 2) })

    for _, item in ipairs(self._values) do
        if type(item) == "table" and item.Type == "Divider" then
            Util.create("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = self._theme:get("Border"),
                BorderSizePixel  = 0,
                ZIndex           = 102,
            }, scroll)
        else
            local key        = type(item) == "table" and item.Title or tostring(item)
            local isSelected = self._selected[key] == true

            local row = Util.create("TextButton", {
                Name             = "Row_" .. key,
                Size             = UDim2.new(1, 0, 0, ITEM_H),
                BackgroundColor3 = isSelected
                    and self._theme:get("AccentDim")
                    or  self._theme:get("Elevated"),
                Text             = "",
                AutoButtonColor  = false,
                ZIndex           = 102,
            }, scroll)
            Util.corner(row, UDim.new(0, 4))
            Util.padding(row, 0, 8, 0, 8)

            local inner = Util.create("Frame", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ZIndex           = 103,
            }, row)
            Util.listLayout(inner, {
                FillDirection     = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding           = UDim.new(0, 6),
            })

            if type(item) == "table" and item.Icon then
                local img = Util.create("ImageLabel", {
                    Size             = UDim2.new(0, 14, 0, 14),
                    BackgroundTransparency = 1,
                    ZIndex           = 104,
                }, inner)
                Icons.apply(img, item.Icon, self._theme:get("TextSecondary"))
            end

            Util.create("TextLabel", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = key,
                TextColor3       = isSelected
                    and self._theme:get("Accent")
                    or  self._theme:get("TextPrimary"),
                TextSize         = 12,
                Font             = isSelected and Enum.Font.GothamBold or Enum.Font.Gotham,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 104,
            }, inner)

            row.MouseEnter:Connect(function()
                if not isSelected then
                    Tween.color(row, "BackgroundColor3", self._theme:get("SurfaceHover"), 0.08)
                end
            end)
            row.MouseLeave:Connect(function()
                if not isSelected then
                    Tween.color(row, "BackgroundColor3", self._theme:get("Elevated"), 0.08)
                end
            end)
            row.MouseButton1Click:Connect(function()
                if type(item) == "table" and item.Callback then
                    item.Callback()
                    self:_close()
                    return
                end

                if self._multi then
                    if self._selected[key] then
                        self._selected[key] = nil
                    else
                        self._selected[key] = true
                    end
                else
                    self._selected = { [key] = true }
                end

                self._displayLabel.Text = self:_getText()

                if self._multi then
                    local sel = {}
                    for k in pairs(self._selected) do table.insert(sel, k) end
                    self._callback(sel)
                else
                    self._callback(key)
                    self:_close()
                end
            end)
        end
    end

    -- Animate height
    Tween.to(popup, { Size = UDim2.fromOffset(popupW, popupH) }, 0.15, Enum.EasingStyle.Quart)
    self._popup = popup

    -- Click-away listener (fires after a small delay so opening click doesn't close)
    task.delay(0.08, function()
        if not self._open then return end
        self._conn = UIS.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            task.defer(function()
                if not self._open or not self._popup then return end
                local mp  = UIS:GetMouseLocation()
                local pp  = self._popup.AbsolutePosition
                local ps  = self._popup.AbsoluteSize
                local sp  = self._selector.AbsolutePosition
                local ss  = self._selector.AbsoluteSize
                local inPopup   = mp.X >= pp.X and mp.X <= pp.X + ps.X
                              and mp.Y >= pp.Y and mp.Y <= pp.Y + ps.Y
                local inSelect  = mp.X >= sp.X and mp.X <= sp.X + ss.X
                              and mp.Y >= sp.Y and mp.Y <= sp.Y + ss.Y
                if not inPopup and not inSelect then
                    self:_close()
                end
            end)
        end)
    end)
end

-- ── Close ─────────────────────────────────────────────────────────────────────

function Dropdown:_close()
    if not self._open then return end
    self._open = false

    if self._conn then
        self._conn:Disconnect()
        self._conn = nil
    end

    if self._popup then
        local p = self._popup
        self._popup = nil
        Tween.to(p, { Size = UDim2.fromOffset(p.AbsoluteSize.X, 0) }, 0.1, Enum.EasingStyle.Quart)
        task.delay(0.11, function()
            if p and p.Parent then p:Destroy() end
        end)
    end
end

-- ── Public ────────────────────────────────────────────────────────────────────

function Dropdown:set(value)
    self._selected = {}
    if type(value) == "table" then
        for _, v in ipairs(value) do self._selected[tostring(v)] = true end
    else
        self._selected[tostring(value)] = true
    end
    self._displayLabel.Text = self:_getText()
end
Dropdown.Set = Dropdown.set

function Dropdown:get()
    local keys = {}
    for k in pairs(self._selected) do table.insert(keys, k) end
    return self._multi and keys or keys[1]
end
Dropdown.Get = Dropdown.get

function Dropdown:refresh(newValues)
    self._values = newValues
    if self._open then self:_close() end
end
Dropdown.Refresh = Dropdown.refresh

function Dropdown:select(values) self:set(values) end
Dropdown.Select = Dropdown.select

return Dropdown
end)()

-- ── Elements.Colorpicker ──────────────────────────────
_m["Elements.Colorpicker"] = (function()
local Util  = _G.__GenUI_modules["Util.Util"]
local Tween = _G.__GenUI_modules["Util.Tween"]

local Colorpicker = {}
Colorpicker.__index = Colorpicker

local SWATCH_W = 44
local SWATCH_H = 22
local PAD      = 10  -- equal padding all sides

function Colorpicker.new(parent, theme, options)
    local self = setmetatable({}, Colorpicker)
    options = options or {}

    self._theme        = theme
    self._color        = options.Default or Color3.fromRGB(255, 255, 255)
    self._transparency = options.Transparency or 0
    self._callback     = options.Callback or function() end
    self._open         = false

    local hasTitle = options.Title ~= nil

    -- Root — AutomaticSize so it grows with picker popup
    self._root = Util.create("Frame", {
        Name             = "Colorpicker",
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme:get("Surface"),
        BorderSizePixel  = 0,
    }, parent)
    Util.corner(self._root, UDim.new(0, 6))
    Util.stroke(self._root, theme:get("Border"), 1)
    Util.padding(self._root, PAD, PAD, PAD, PAD)
    Util.listLayout(self._root, { Padding = UDim.new(0, 6) })

    -- Title
    if hasTitle then
        Util.create("TextLabel", {
            Size             = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            Text             = options.Title,
            TextColor3       = theme:get("TextPrimary"),
            TextSize         = 13,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
        }, self._root)
    end

    -- Swatch row: [color box] [hex label]
    local swatchRow = Util.create("Frame", {
        Size             = UDim2.new(1, 0, 0, SWATCH_H),
        BackgroundTransparency = 1,
    }, self._root)
    Util.listLayout(swatchRow, {
        FillDirection     = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding           = UDim.new(0, 8),
    })

    -- Color swatch button
    self._swatch = Util.create("TextButton", {
        Size             = UDim2.new(0, SWATCH_W, 1, 0),
        BackgroundColor3 = self._color,
        Text             = "",
        AutoButtonColor  = false,
        LayoutOrder      = 0,
    }, swatchRow)
    Util.corner(self._swatch, UDim.new(0, 4))
    Util.stroke(self._swatch, theme:get("Border"), 1)

    -- Hex label
    self._hexLabel = Util.create("TextLabel", {
        Size             = UDim2.new(1, -(SWATCH_W + 8), 1, 0),
        BackgroundTransparency = 1,
        Text             = self:_toHex(),
        TextColor3       = theme:get("TextSecondary"),
        TextSize         = 12,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        LayoutOrder      = 1,
    }, swatchRow)

    self._swatch.MouseButton1Click:Connect(function()
        if self._open then self:_closePicker() else self:_openPicker() end
    end)

    return self
end

function Colorpicker:_toHex()
    return string.format("#%02X%02X%02X",
        math.floor(self._color.R * 255),
        math.floor(self._color.G * 255),
        math.floor(self._color.B * 255))
end

function Colorpicker:_openPicker()
    self._open = true

    -- Picker popup inside root (no clip, has corner)
    self._picker = Util.create("Frame", {
        Name             = "Picker",
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = self._theme:get("Background"),
        BorderSizePixel  = 0,
        ClipsDescendants = false,
    }, self._root)
    Util.corner(self._picker, UDim.new(0, 4))
    Util.stroke(self._picker, self._theme:get("Border"), 1)
    Util.padding(self._picker, 8, 8, 8, 8)
    Util.listLayout(self._picker, { Padding = UDim.new(0, 6) })

    -- HEX label
    Util.create("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 12),
        BackgroundTransparency = 1,
        Text             = "HEX COLOR",
        TextColor3       = self._theme:get("TextMuted"),
        TextSize         = 10,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, self._picker)

    -- Hex input
    local inputFrame = Util.create("Frame", {
        Size             = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = self._theme:get("Surface"),
        BorderSizePixel  = 0,
    }, self._picker)
    Util.corner(inputFrame, UDim.new(0, 4))
    Util.stroke(inputFrame, self._theme:get("Border"), 1)
    Util.padding(inputFrame, 0, 8, 0, 8)

    local hexInput = Util.create("TextBox", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = self:_toHex(),
        TextColor3       = self._theme:get("TextPrimary"),
        PlaceholderText  = "#RRGGBB",
        PlaceholderColor3 = self._theme:get("TextMuted"),
        TextSize         = 13,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    }, inputFrame)

    local stroke = Util.stroke(inputFrame, self._theme:get("Border"), 1)
    hexInput.Focused:Connect(function()
        Tween.color(stroke, "Color", self._theme:get("Accent"), 0.1)
    end)
    hexInput.FocusLost:Connect(function()
        Tween.color(stroke, "Color", self._theme:get("Border"), 0.1)
        local hex = hexInput.Text:gsub("[^%x]", "")
        if #hex == 6 then
            local r = tonumber(hex:sub(1,2), 16) or 0
            local g = tonumber(hex:sub(3,4), 16) or 0
            local b = tonumber(hex:sub(5,6), 16) or 0
            self:set(Color3.fromRGB(r, g, b))
            hexInput.Text = self:_toHex()
        end
    end)
end

function Colorpicker:_closePicker()
    self._open = false
    if self._picker then
        self._picker:Destroy()
        self._picker = nil
    end
end

function Colorpicker:set(color, transparency)
    self._color        = color or self._color
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
end)()

-- ── Elements.Keybind ──────────────────────────────
_m["Elements.Keybind"] = (function()
local Util  = _G.__GenUI_modules["Util.Util"]
local Tween = _G.__GenUI_modules["Util.Tween"]
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
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme:get("Surface"),
        BorderSizePixel  = 0,
    }, parent)
    Util.corner(self._root, UDim.new(0, 6))
    Util.stroke(self._root, theme:get("Border"), 1)
    Util.padding(self._root, 10, 10, 10, 10)
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
end)()

-- ── Elements.Label ──────────────────────────────
_m["Elements.Label"] = (function()
local Util = _G.__GenUI_modules["Util.Util"]

local Label = {}
Label.__index = Label

function Label.new(parent, theme, options)
    local self = setmetatable({}, Label)
    options = options or {}

    self._root = Util.create("TextLabel", {
        Name             = "Label",
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text             = options.Title or "",
        TextColor3       = options.Color or theme:get("TextSecondary"),
        TextSize         = options.TextSize or 12,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = options.Justify == "Center" and Enum.TextXAlignment.Center
                        or options.Justify == "Right"  and Enum.TextXAlignment.Right
                        or Enum.TextXAlignment.Left,
        TextWrapped      = true,
    }, parent)

    return self
end

function Label:setText(text)
    self._root.Text = text
end
Label.SetText = Label.setText

return Label
end)()

-- ── Elements.Divider ──────────────────────────────
_m["Elements.Divider"] = (function()
local Util = _G.__GenUI_modules["Util.Util"]

local Divider = {}
Divider.__index = Divider

function Divider.new(parent, theme)
    local self = setmetatable({}, Divider)

    self._root = Util.create("Frame", {
        Name             = "Divider",
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = theme:get("Border"),
        BorderSizePixel  = 0,
    }, parent)

    return self
end

return Divider
end)()

-- ── Core.Group ──────────────────────────────
_m["Core.Group"] = (function()
local Util  = _G.__GenUI_modules["Util.Util"]
local Flags = _G.__GenUI_modules["Util.Flags"]

local Group = {}
Group.__index = Group

function Group.new(parent, theme, options)
    local self = setmetatable({}, Group)

    options = options or {}
    self._theme    = theme
    self._elements = {}

    -- Wrapper fills full width, auto height
    self._frame = Util.create("Frame", {
        Name             = "Group",
        Size             = UDim2.new(1, 0, 0, 36),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    }, parent)

    -- UIListLayout horizontal
    local layout = Util.listLayout(self._frame, {
        FillDirection       = Enum.FillDirection.Horizontal,
        VerticalAlignment   = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding             = UDim.new(0, options.Gap or 6),
    })

    -- UIFlexItem so children share space equally
    local flex = Instance.new("UIFlexItem")
    flex.FlexMode = Enum.UIFlexMode.Fill
    -- Note: UIFlexItem goes on children, not the layout
    -- We'll handle sizing per-element via _isGroup flag

    self._gap = options.Gap or 6
    return self
end

-- Insert flex spacer
function Group:space()
    Util.create("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        BackgroundTransparency = 1,
        AutomaticSize    = Enum.AutomaticSize.X,
        LayoutOrder      = 99,
    }, self._frame)
end
Group.Space = Group.space

-- Forward element methods - wrap each in a flex cell
local elementNames = { "button","toggle","slider","input","dropdown","colorpicker","keybind","label","divider" }
for _, name in ipairs(elementNames) do
    Group[name] = function(self, options)
        local Tab = _G.__GenUI_modules and _G.__GenUI_modules["Core.Tab"]
                 or _G.__GenUI_modules["Core.Tab"]

        -- Each child gets a flex cell that grows to fill available space
        local cell = Util.create("Frame", {
            Size             = UDim2.new(0, 100, 0, 36),  -- base size, flex will override
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
        }, self._frame)

        -- UIFlexItem makes the cell grow/shrink to fill the group
        local flexItem = Instance.new("UIFlexItem")
        flexItem.FlexMode       = Enum.UIFlexMode.Fill
        flexItem.GrowRatio      = 1
        flexItem.ShrinkRatio    = 1
        flexItem.Parent         = cell

        local proxy = {}
        proxy._frame    = cell
        proxy._theme    = self._theme
        proxy._elements = self._elements
        setmetatable(proxy, { __index = Tab })
        local el = Tab[name](proxy, options)

        -- Make inner element fill its cell
        if el and el._root then
            el._root.Size = UDim2.new(1, 0, 0, el._root.Size.Y.Offset)
        end

        table.insert(self._elements, el)
        return el
    end
    Group[name:sub(1,1):upper() .. name:sub(2)] = Group[name]
end

return Group
end)()

-- ── Core.Section ──────────────────────────────
_m["Core.Section"] = (function()
local Util  = _G.__GenUI_modules["Util.Util"]
local Tween = _G.__GenUI_modules["Util.Tween"]
local Flags = _G.__GenUI_modules["Util.Flags"]

local Section = {}
Section.__index = Section

function Section.new(parent, theme, options)
    local self = setmetatable({}, Section)

    options = options or {}
    self._theme       = theme
    self._title       = options.Title or ""
    self._collapsible = options.Collapsible or false
    self._opened      = options.Opened ~= false
    self._elements    = {}

    -- Wrapper
    self._root = Util.create("Frame", {
        Name             = "Section_" .. self._title,
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    }, parent)
    Util.listLayout(self._root, { Padding = UDim.new(0, 4) })

    -- Header (only if has title)
    if self._title ~= "" then
        local header = Util.create("Frame", {
            Size             = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
        }, self._root)

        -- Section title
        Util.create("TextLabel", {
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text             = self._title:upper(),
            TextColor3       = theme:get("TextMuted"),
            TextSize         = 10,
            Font             = Enum.Font.GothamBold,
            TextXAlignment   = Enum.TextXAlignment.Left,

        }, header)

        -- Collapse button
        if self._collapsible then
            local collapseBtn = Util.create("TextButton", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = "",
                AutoButtonColor  = false,
            }, header)
            collapseBtn.MouseButton1Click:Connect(function()
                if self._opened then self:close() else self:open() end
            end)
        end
    end

    -- Content frame
    self._content = Util.create("Frame", {
        Name             = "SectionContent",
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    }, self._root)
    Util.listLayout(self._content, { Padding = UDim.new(0, 6) })

    if not self._opened then
        self._content.Visible = false
    end

    return self
end

function Section:open()
    self._opened = true
    self._content.Visible = true
end

function Section:close()
    self._opened = false
    self._content.Visible = false
end

-- Forward all element methods to self._content (which is a real Frame Instance)
local elementNames = {
    "button","toggle","slider","input","dropdown",
    "colorpicker","keybind","label","divider","space","group"
}

for _, name in ipairs(elementNames) do
    Section[name] = function(self, options)
        local Tab = _G.__GenUI_modules and _G.__GenUI_modules["Core.Tab"]
                 or _G.__GenUI_modules["Core.Tab"]
        -- Create a minimal tab-like proxy with a real Instance as _frame
        local proxy = {}
        proxy._frame    = self._content   -- real GuiObject Instance
        proxy._theme    = self._theme
        proxy._elements = self._elements
        setmetatable(proxy, { __index = Tab })
        return Tab[name](proxy, options)
    end
    -- PascalCase alias
    local pascal = name:sub(1,1):upper() .. name:sub(2)
    Section[pascal] = Section[name]
end

-- Nested section
function Section:section(options)
    return Section.new(self._content, self._theme, options)
end
Section.Section = Section.section

return Section
end)()

-- ── Core.Tab ──────────────────────────────
_m["Core.Tab"] = (function()
local Util  = _G.__GenUI_modules["Util.Util"]
local Flags = _G.__GenUI_modules["Util.Flags"]

local Tab = {}
Tab.__index = Tab

function Tab.new(contentPanel, theme, options)
    local self = setmetatable({}, Tab)

    options = options or {}

    self._theme   = theme
    self._title   = options.Title or "Tab"
    self._icon    = options.Icon
    self._desc    = options.Desc
    self._elements = {}

    -- Scroll frame
    self._frame = Util.create("ScrollingFrame", {
        Name              = "TabContent_" .. self._title,
        Size              = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme:get("ScrollBar"),
        CanvasSize        = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BorderSizePixel   = 0,
        Visible           = false,
    }, contentPanel)

    Util.padding(self._frame, 10, 10, 10, 10)
    Util.listLayout(self._frame, {
        Padding = UDim.new(0, 6),
    })

    return self
end

-- ── Element factory helpers ───────────────────────────────────────────────────

-- Register a flag if provided
local function registerFlag(flag, element)
    if flag and flag ~= "" then
        Flags.set(flag, element)
    end
end

-- ── Elements ──────────────────────────────────────────────────────────────────

function Tab:button(options)
    local Button = _G.__GenUI_modules["Elements.Button"]
    local el = Button.new(self._frame, self._theme, options)
    table.insert(self._elements, el)
    return el
end
Tab.Button = Tab.button

function Tab:toggle(options)
    local Toggle = _G.__GenUI_modules["Elements.Toggle"]
    local el = Toggle.new(self._frame, self._theme, options)
    registerFlag(options and options.Flag, el)
    table.insert(self._elements, el)
    return el
end
Tab.Toggle = Tab.toggle

function Tab:slider(options)
    local Slider = _G.__GenUI_modules["Elements.Slider"]
    local el = Slider.new(self._frame, self._theme, options)
    registerFlag(options and options.Flag, el)
    table.insert(self._elements, el)
    return el
end
Tab.Slider = Tab.slider

function Tab:input(options)
    local Input = _G.__GenUI_modules["Elements.Input"]
    local el = Input.new(self._frame, self._theme, options)
    registerFlag(options and options.Flag, el)
    table.insert(self._elements, el)
    return el
end
Tab.Input = Tab.input

function Tab:dropdown(options)
    local Dropdown = _G.__GenUI_modules["Elements.Dropdown"]
    local el = Dropdown.new(self._frame, self._theme, options)
    registerFlag(options and options.Flag, el)
    table.insert(self._elements, el)
    return el
end
Tab.Dropdown = Tab.dropdown

function Tab:colorpicker(options)
    local Colorpicker = _G.__GenUI_modules["Elements.Colorpicker"]
    local el = Colorpicker.new(self._frame, self._theme, options)
    registerFlag(options and options.Flag, el)
    table.insert(self._elements, el)
    return el
end
Tab.Colorpicker = Tab.colorpicker

function Tab:keybind(options)
    local Keybind = _G.__GenUI_modules["Elements.Keybind"]
    local el = Keybind.new(self._frame, self._theme, options)
    registerFlag(options and options.Flag, el)
    table.insert(self._elements, el)
    return el
end
Tab.Keybind = Tab.keybind

function Tab:label(options)
    local Label = _G.__GenUI_modules["Elements.Label"]
    local el = Label.new(self._frame, self._theme, options)
    table.insert(self._elements, el)
    return el
end
Tab.Label = Tab.label

function Tab:divider()
    local Divider = _G.__GenUI_modules["Elements.Divider"]
    local el = Divider.new(self._frame, self._theme)
    table.insert(self._elements, el)
    return el
end
Tab.Divider = Tab.divider

function Tab:space(options)
    options = options or {}
    local height = options.Height or 8
    Util.create("Frame", {
        Size             = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1,
    }, self._frame)
end
Tab.Space = Tab.space

function Tab:section(options)
    local Section = _G.__GenUI_modules["Core.Section"]
    local s = Section.new(self._frame, self._theme, options)
    table.insert(self._elements, s)
    return s
end
Tab.Section = Tab.section

function Tab:group(options)
    local Group = _G.__GenUI_modules["Core.Group"]
    local g = Group.new(self._frame, self._theme, options)
    table.insert(self._elements, g)
    return g
end
Tab.Group = Tab.group

return Tab
end)()

-- ── Core.Window ──────────────────────────────
_m["Core.Window"] = (function()
local UserInputService = game:GetService("UserInputService")

local Util          = _G.__GenUI_modules["Util.Util"]
local Tween         = _G.__GenUI_modules["Util.Tween"]
local Theme         = _G.__GenUI_modules["Systems.Theme"]
local Icons         = _G.__GenUI_modules["Systems.Icons"]
local ConfigManager = _G.__GenUI_modules["Systems.Config"]

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
    self._windowIcon  = options.Icon

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
    self._fullSize  = size
    self._minimized = false

    -- Root — ClipsDescendants FALSE so UICorner stays visible
    self._root = Util.create("Frame", {
        Name             = "WindowFrame",
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = size,
        BackgroundColor3 = self._theme:get("Background"),
        BorderSizePixel  = 0,
        ClipsDescendants = false,
    }, self._gui)
    Util.corner(self._root, UDim.new(0, 10))
    self._theme:tag(self._root, "BackgroundColor3", "Background")

    -- Stroke frame as sibling (not child) so it renders on top without clipping
    self._strokeFrame = Util.create("Frame", {
        Name             = "WindowStroke",
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = size,
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 50,
    }, self._gui)
    Util.corner(self._strokeFrame, UDim.new(0, 10))
    Util.stroke(self._strokeFrame, self._theme:get("Border"), 1)

    self._clip = self._root

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
    Util.corner(bar, UDim.new(0, 10))
    self._theme:tag(bar, "BackgroundColor3", "TopbarBg")

    -- Fix: cover bottom half to make bottom corners square
    local fix = Util.create("Frame", {
        Size             = UDim2.new(1, 0, 0, 12),
        Position         = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = self._theme:get("TopbarBg"),
        BorderSizePixel  = 0,
        ZIndex           = 4,
    }, bar)
    self._theme:tag(fix, "BackgroundColor3", "TopbarBg")

    -- Bottom border
    Util.create("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = self._theme:get("Border"),
        BorderSizePixel  = 0,
        ZIndex           = 5,
    }, bar)

    Util.padding(bar, 0, 14, 0, 14)

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

    -- Title row content

    -- Window icon
    if options.Icon then
        local icon = Util.create("ImageLabel", {
            Size             = UDim2.new(0, 16, 0, 16),
            BackgroundTransparency = 1,
            ImageColor3      = self._theme:get("Accent"),
            LayoutOrder      = 0,
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
        LayoutOrder      = 1,
    }, row)

    -- Control buttons pinned to right
    local controls = Util.create("Frame", {
        Name             = "Controls",
        AnchorPoint      = Vector2.new(1, 0.5),
        Position         = UDim2.new(1, -14, 0.5, 0),
        Size             = UDim2.new(0, 50, 0, 22),
        BackgroundTransparency = 1,
    }, bar)
    Util.listLayout(controls, {
        FillDirection       = Enum.FillDirection.Horizontal,
        VerticalAlignment   = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding             = UDim.new(0, 6),
    })

    -- Minimize button
    self:_makeControlBtn(controls, "–", self._theme:get("Warning"), function()
        self:_minimize()
    end)

    -- Close button
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
        TextSize         = 14,
        Font             = Enum.Font.GothamBold,
        AutoButtonColor  = false,
    }, parent)
    Util.corner(btn, UDim.new(1, 0))

    btn.MouseEnter:Connect(function()
        Tween.color(btn, "BackgroundColor3", color, 0.12)
        Tween.color(btn, "TextColor3", Color3.new(0,0,0), 0.12)
    end)
    btn.MouseLeave:Connect(function()
        Tween.color(btn, "BackgroundColor3", self._theme:get("SurfaceHover"), 0.12)
        Tween.color(btn, "TextColor3", color, 0.12)
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
    Util.corner(sidebar, UDim.new(0, 10))
    self._theme:tag(sidebar, "BackgroundColor3", "SidebarBg")

    -- Fix top corners (make square)
    local topFix = Util.create("Frame", {
        Size             = UDim2.new(1, 0, 0, 12),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = self._theme:get("SidebarBg"),
        BorderSizePixel  = 0,
        ZIndex           = 2,
    }, sidebar)
    self._theme:tag(topFix, "BackgroundColor3", "SidebarBg")

    -- Fix right corners (make square)
    local rightFix = Util.create("Frame", {
        Size             = UDim2.new(0, 12, 1, 0),
        Position         = UDim2.new(1, -12, 0, 0),
        BackgroundColor3 = self._theme:get("SidebarBg"),
        BorderSizePixel  = 0,
        ZIndex           = 2,
    }, sidebar)
    self._theme:tag(rightFix, "BackgroundColor3", "SidebarBg")

    -- Right border line
    Util.create("Frame", {
        Name             = "RightBorder",
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = self._theme:get("Border"),
        BorderSizePixel  = 0,
        ZIndex           = 3,
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
        Name             = "ContentPanel",
        Position         = UDim2.new(0, SIDEBAR_W, 0, TOPBAR_H),
        Size             = UDim2.new(1, -SIDEBAR_W, 1, -TOPBAR_H),
        BackgroundColor3 = self._theme:get("Background"),
        BorderSizePixel  = 0,
        ClipsDescendants = true,
    }, self._clip)
    self._theme:tag(self._content, "BackgroundColor3", "Background")
    -- No UICorner on content — ClipsDescendants already clips it rectangular
    -- The root frame's UICorner handles the visual rounding of bottom-right corner
end

-- ── Dragging ──────────────────────────────────────────────────────────────────

function Window:_makeDraggable()
    local dragging, startPos, startMouse = false, nil, nil

    self._topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging   = true
            startPos   = self._root.Position
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
            local newPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            self._root.Position = newPos
            -- strokeFrame must follow root exactly
            if self._strokeFrame then
                self._strokeFrame.Position = newPos
            end
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
    local Tab = _G.__GenUI_modules["Core.Tab"]
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

-- Create a Section (tab group label) on the sidebar
function Window:section(options)
    options = options or {}

    if options.Title and options.Title ~= "" then
        -- Top spacing before section label (except first)
        if #self._tabs > 0 then
            Util.create("Frame", {
                Size             = UDim2.new(1, 0, 0, 6),
                BackgroundTransparency = 1,
            }, self._tabList)
        end

        -- Section label
        Util.create("TextLabel", {
            Name             = "SectionLabel_" .. options.Title,
            Size             = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text             = options.Title:upper(),
            TextColor3       = self._theme:get("TextMuted"),
            TextSize         = 9,
            Font             = Enum.Font.GothamBold,
            TextXAlignment   = Enum.TextXAlignment.Left,
        }, self._tabList)
    end

    -- Return a proxy that forwards :Tab() back to this Window
    local window = self
    local proxy = setmetatable({}, {
        __index = function(_, key)
            if key == "Tab" or key == "tab" then
                return function(_, tabOptions)
                    return window:tab(tabOptions)
                end
            end
            return window[key]
        end
    })
    return proxy
end
Window.Section = Window.section

function Window:toggle()
    self._visible = not self._visible
    if self._visible then
        self._root.Visible = true
        if self._strokeFrame then self._strokeFrame.Visible = true end
        if self._iconBtn then self._iconBtn.Visible = false end
        Tween.to(self._root, { Size = self._fullSize }, 0.22, Enum.EasingStyle.Back)
        if self._strokeFrame then
            Tween.to(self._strokeFrame, { Size = self._fullSize }, 0.22, Enum.EasingStyle.Back)
        end
    else
        Tween.to(self._root, { Size = UDim2.fromOffset(self._fullSize.X.Offset, 0) }, 0.18)
        task.delay(0.2, function()
            if not self._visible then
                self._root.Visible = false
                if self._strokeFrame then self._strokeFrame.Visible = false end
            end
        end)
    end
end

function Window:Open()
    self._visible = true
    self._root.Visible = true
    if self._strokeFrame then self._strokeFrame.Visible = true end
    if self._iconBtn then self._iconBtn.Visible = false end
    self._root.Size = UDim2.fromOffset(self._fullSize.X.Offset, 0)
    Tween.to(self._root, { Size = self._fullSize }, 0.22, Enum.EasingStyle.Back)
    if self._strokeFrame then
        self._strokeFrame.Size = UDim2.fromOffset(self._fullSize.X.Offset, 0)
        Tween.to(self._strokeFrame, { Size = self._fullSize }, 0.22, Enum.EasingStyle.Back)
    end
end
Window.open = Window.Open

-- Minimize → hide window, show draggable icon button
function Window:_minimize()
    -- Hide window
    self._root.Visible = false
    if self._strokeFrame then self._strokeFrame.Visible = false end
    self._visible = false

    -- Create icon button if not exists
    if not self._iconBtn then
        self:_createIconBtn()
    end
    self._iconBtn.Visible = true
end

function Window:_createIconBtn()
    local btn = Util.create("ImageButton", {
        Name             = "GenUI_IconBtn",
        Size             = UDim2.fromOffset(46, 46),
        Position         = UDim2.new(0, 20, 0.5, -23),
        BackgroundColor3 = self._theme:get("Surface"),
        BorderSizePixel  = 0,
        AutoButtonColor  = false,
        Draggable        = true,
        ZIndex           = 10,
    }, self._gui)
    Util.corner(btn, UDim.new(0, 12))
    Util.stroke(btn, self._theme:get("Accent"), 2)

    -- Icon image (window icon or default)
    local img = Util.create("ImageLabel", {
        Size             = UDim2.new(0, 26, 0, 26),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1,
        ImageColor3      = self._theme:get("Accent"),
    }, btn)
    if self._windowIcon then
        Icons.apply(img, self._windowIcon, self._theme:get("Accent"))
    else
        img.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    end

    -- Hover effect
    btn.MouseEnter:Connect(function()
        Tween.to(btn, { Size = UDim2.fromOffset(52, 52) }, 0.15, Enum.EasingStyle.Back)
    end)
    btn.MouseLeave:Connect(function()
        Tween.to(btn, { Size = UDim2.fromOffset(46, 46) }, 0.15)
    end)

    -- Click → open window
    btn.MouseButton1Click:Connect(function()
        self:Open()
    end)

    self._iconBtn = btn
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
    for _, conn in ipairs(self._connections) do conn:Disconnect() end
    if self._root       then self._root:Destroy() end
    if self._strokeFrame then self._strokeFrame:Destroy() end
    if self._iconBtn    then self._iconBtn:Destroy() end
end
Window.Destroy = Window.destroy

return Window
end)()

-- ── Core.Library ──────────────────────────────
_m["Core.Library"] = (function()
local Players    = game:GetService("Players")
local cloneref   = (cloneref or clonereference or function(i) return i end)

local Util         = _G.__GenUI_modules["Util.Util"]
local Theme        = _G.__GenUI_modules["Systems.Theme"]
local Icons        = _G.__GenUI_modules["Systems.Icons"]
local Notification = _G.__GenUI_modules["Systems.Notification"]
local Window       = _G.__GenUI_modules["Core.Window"]

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
end)()

-- ── Entry Point ──────────────────────────────
local Library = _m["Core.Library"]
Library.cloneref = cloneref
return Library
