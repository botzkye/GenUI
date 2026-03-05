--[[
    GenUI — Elements/Dropdown.lua
    Simple strings or advanced object list. Multi-select, Dividers, Refresh.
--]]

local Util  = require(script.Parent.Parent.Util.Util)
local Tween = require(script.Parent.Parent.Util.Tween)
local Icons = require(script.Parent.Parent.Systems.Icons)

local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(parent, theme, options)
    local self = setmetatable({}, Dropdown)
    options = options or {}

    self._theme    = theme
    self._callback = options.Callback or function() end
    self._multi    = options.Multi    or false
    self._allowNone = options.AllowNone or false
    self._locked   = options.Locked   or false
    self._values   = options.Values   or {}
    self._selected = {}
    self._open     = false
    self._advanced = type(self._values[1]) == "table"

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
        local first = self._advanced and self._values[1].Title or tostring(self._values[1])
        self._selected[first] = true
    end

    -- Root
    self._root = Util.create("Frame", {
        Name             = "Dropdown",
        Size             = UDim2.new(1, 0, 0, options.Title and 58 or 36),
        BackgroundColor3 = theme:get("Surface"),
        BorderSizePixel  = 0,
        ClipsDescendants = false,
        ZIndex           = 1,
    }, parent)
    Util.corner(self._root, UDim.new(0, 6))
    Util.stroke(self._root, theme:get("Border"), 1)
    Util.padding(self._root, 8, 10, 8, 10)
    Util.listLayout(self._root, { Padding = UDim.new(0, 5) })

    -- Title
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

    -- Selector button
    local selector = Util.create("Frame", {
        Size             = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = theme:get("Background"),
        BorderSizePixel  = 0,
    }, self._root)
    Util.corner(selector, UDim.new(0, 4))
    Util.stroke(selector, theme:get("Border"), 1)
    Util.padding(selector, 0, 8, 0, 8)

    local selRow = Util.create("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    }, selector)
    Util.listLayout(selRow, {
        FillDirection     = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding           = UDim.new(0, 0),
    })

    self._displayLabel = Util.create("TextLabel", {
        Size             = UDim2.new(1, -20, 1, 0),
        BackgroundTransparency = 1,
        Text             = self:_getDisplayText(),
        TextColor3       = theme:get("TextSecondary"),
        TextSize         = 12,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextTruncate     = Enum.TextTruncate.AtEnd,
    }, selRow)

    -- Chevron
    Util.create("TextLabel", {
        Size             = UDim2.new(0, 16, 1, 0),
        BackgroundTransparency = 1,
        Text             = "▾",
        TextColor3       = theme:get("TextMuted"),
        TextSize         = 11,
        Font             = Enum.Font.GothamBold,
        LayoutOrder      = 99,
    }, selRow)

    -- Clickable
    local btn = Util.create("TextButton", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        ZIndex           = 2,
    }, selector)
    btn.MouseButton1Click:Connect(function()
        if self._locked then return end
        if self._open then self:_closeDropdown() else self:_openDropdown() end
    end)

    self._selector = selector
    self._root.ZIndex = 2

    return self
end

function Dropdown:_getDisplayText()
    local keys = {}
    for k in pairs(self._selected) do table.insert(keys, k) end
    if #keys == 0 then return "Select..." end
    if #keys == 1 then return keys[1] end
    return keys[1] .. " +" .. (#keys - 1)
end

function Dropdown:_openDropdown()
    self._open = true

    -- Popup frame
    local popup = Util.create("Frame", {
        Name             = "DropdownPopup",
        Size             = UDim2.new(1, 0, 0, 0),
        Position         = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = self._theme:get("Elevated"),
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        ZIndex           = 10,
    }, self._root)
    Util.corner(popup, UDim.new(0, 6))
    Util.stroke(popup, self._theme:get("Border"), 1)

    local list = Util.create("Frame", {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex           = 10,
    }, popup)
    Util.padding(list, 4, 4, 4, 4)
    Util.listLayout(list, { Padding = UDim.new(0, 2) })

    for _, item in ipairs(self._values) do
        if type(item) == "table" and item.Type == "Divider" then
            -- Divider
            local div = Util.create("Frame", {
                Size             = UDim2.new(1, -8, 0, 1),
                BackgroundColor3 = self._theme:get("Border"),
                BorderSizePixel  = 0,
            }, list)
        else
            local key = type(item) == "table" and item.Title or tostring(item)
            local isSelected = self._selected[key] == true

            local row = Util.create("TextButton", {
                Size             = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = isSelected and self._theme:get("AccentDim") or self._theme:get("Elevated"),
                Text             = "",
                AutoButtonColor  = false,
                ZIndex           = 11,
            }, list)
            Util.corner(row, UDim.new(0, 4))
            Util.padding(row, 0, 8, 0, 8)

            local rowInner = Util.create("Frame", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ZIndex           = 11,
            }, row)
            Util.listLayout(rowInner, {
                FillDirection     = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding           = UDim.new(0, 6),
            })

            -- Icon
            if type(item) == "table" and item.Icon then
                local img = Util.create("ImageLabel", {
                    Size             = UDim2.new(0, 14, 0, 14),
                    BackgroundTransparency = 1,
                    ZIndex           = 12,
                }, rowInner)
                Icons.apply(img, item.Icon, self._theme:get("TextSecondary"))
            end

            Util.create("TextLabel", {
                Size             = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Text             = key,
                TextColor3       = isSelected and self._theme:get("Accent") or self._theme:get("TextPrimary"),
                TextSize         = 12,
                Font             = isSelected and Enum.Font.GothamBold or Enum.Font.Gotham,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 12,
            }, rowInner)

            row.MouseEnter:Connect(function()
                if not (self._selected[key]) then
                    Tween.color(row, "BackgroundColor3", self._theme:get("SurfaceHover"), 0.1)
                end
            end)
            row.MouseLeave:Connect(function()
                if not (self._selected[key]) then
                    Tween.color(row, "BackgroundColor3", self._theme:get("Elevated"), 0.1)
                end
            end)
            row.MouseButton1Click:Connect(function()
                if type(item) == "table" and item.Callback then
                    item.Callback()
                    self:_closeDropdown()
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
                    self:_closeDropdown()
                end

                self._displayLabel.Text = self:_getDisplayText()

                -- Fire callback
                if self._multi then
                    local sel = {}
                    for k in pairs(self._selected) do table.insert(sel, k) end
                    self._callback(sel)
                else
                    self._callback(key)
                end
            end)
        end
    end

    -- Animate open
    local targetH = math.min(#self._values * 34 + 8, 200)
    popup.Size = UDim2.new(1, 0, 0, 0)
    Tween.to(popup, { Size = UDim2.new(1, 0, 0, targetH) }, 0.15)

    self._popup = popup

    -- Click-away to close
    task.spawn(function()
        local conn
        conn = game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                task.defer(function()
                    if self._open then
                        self:_closeDropdown()
                        conn:Disconnect()
                    end
                end)
            end
        end)
    end)
end

function Dropdown:_closeDropdown()
    self._open = false
    if self._popup then
        Tween.to(self._popup, { Size = UDim2.new(1, 0, 0, 0) }, 0.12)
        task.delay(0.13, function()
            if self._popup then
                self._popup:Destroy()
                self._popup = nil
            end
        end)
    end
end

function Dropdown:set(value)
    self._selected = {}
    if type(value) == "table" then
        for _, v in ipairs(value) do self._selected[tostring(v)] = true end
    else
        self._selected[tostring(value)] = true
    end
    self._displayLabel.Text = self:_getDisplayText()
end
Dropdown.Set = Dropdown.set

function Dropdown:get()
    local keys = {}
    for k in pairs(self._selected) do table.insert(keys, k) end
    return self._multi and keys or keys[1]
end
Dropdown.Get = Dropdown.get

function Dropdown:refresh(newValues)
    self._values   = newValues
    self._advanced = type(newValues[1]) == "table"
    if self._open then self:_closeDropdown() end
end
Dropdown.Refresh = Dropdown.refresh

function Dropdown:select(values)
    self:set(values)
end
Dropdown.Select = Dropdown.select

return Dropdown
