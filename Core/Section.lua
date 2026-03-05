--[[
    GenUI — Core/Section.lua
    Collapsible named container. Can host elements or act as a tab group.
--]]

local Util  = require(script.Parent.Parent.Util.Util)
local Tween = require(script.Parent.Parent.Util.Tween)
local Flags = require(script.Parent.Parent.Util.Flags)

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
            LetterSpacing    = 2,
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

-- Forward element methods to content frame
local function registerFlag(flag, el)
    if flag and flag ~= "" then Flags.set(flag, el) end
end

local methods = { "button","toggle","slider","input","dropdown","colorpicker","keybind","label","divider","space","section","group" }
for _, name in ipairs(methods) do
    Section[name] = function(self, options)
        local Tab = require(script.Parent.Tab)
        local proxy = setmetatable({ _frame = self._content, _theme = self._theme, _elements = self._elements }, { __index = Tab })
        return proxy[name](proxy, options)
    end
    Section[name:sub(1,1):upper() .. name:sub(2)] = Section[name]
end

return Section
