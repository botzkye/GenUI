--[[
    GenUI — Core/Tab.lua
    Tab object. Scroll content frame + element factory methods.
--]]

local Util  = require(script.Parent.Parent.Util.Util)
local Flags = require(script.Parent.Parent.Util.Flags)

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
    local Button = require(script.Parent.Parent.Elements.Button)
    local el = Button.new(self._frame, self._theme, options)
    table.insert(self._elements, el)
    return el
end
Tab.Button = Tab.button

function Tab:toggle(options)
    local Toggle = require(script.Parent.Parent.Elements.Toggle)
    local el = Toggle.new(self._frame, self._theme, options)
    registerFlag(options and options.Flag, el)
    table.insert(self._elements, el)
    return el
end
Tab.Toggle = Tab.toggle

function Tab:slider(options)
    local Slider = require(script.Parent.Parent.Elements.Slider)
    local el = Slider.new(self._frame, self._theme, options)
    registerFlag(options and options.Flag, el)
    table.insert(self._elements, el)
    return el
end
Tab.Slider = Tab.slider

function Tab:input(options)
    local Input = require(script.Parent.Parent.Elements.Input)
    local el = Input.new(self._frame, self._theme, options)
    registerFlag(options and options.Flag, el)
    table.insert(self._elements, el)
    return el
end
Tab.Input = Tab.input

function Tab:dropdown(options)
    local Dropdown = require(script.Parent.Parent.Elements.Dropdown)
    local el = Dropdown.new(self._frame, self._theme, options)
    registerFlag(options and options.Flag, el)
    table.insert(self._elements, el)
    return el
end
Tab.Dropdown = Tab.dropdown

function Tab:colorpicker(options)
    local Colorpicker = require(script.Parent.Parent.Elements.Colorpicker)
    local el = Colorpicker.new(self._frame, self._theme, options)
    registerFlag(options and options.Flag, el)
    table.insert(self._elements, el)
    return el
end
Tab.Colorpicker = Tab.colorpicker

function Tab:keybind(options)
    local Keybind = require(script.Parent.Parent.Elements.Keybind)
    local el = Keybind.new(self._frame, self._theme, options)
    registerFlag(options and options.Flag, el)
    table.insert(self._elements, el)
    return el
end
Tab.Keybind = Tab.keybind

function Tab:label(options)
    local Label = require(script.Parent.Parent.Elements.Label)
    local el = Label.new(self._frame, self._theme, options)
    table.insert(self._elements, el)
    return el
end
Tab.Label = Tab.label

function Tab:divider()
    local Divider = require(script.Parent.Parent.Elements.Divider)
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
    local Section = require(script.Parent.Section)
    local s = Section.new(self._frame, self._theme, options)
    table.insert(self._elements, s)
    return s
end
Tab.Section = Tab.section

function Tab:group(options)
    local Group = require(script.Parent.Group)
    local g = Group.new(self._frame, self._theme, options)
    table.insert(self._elements, g)
    return g
end
Tab.Group = Tab.group

return Tab
