--[[
    GenUI — Util/Util.lua
    Miscellaneous helper functions
--]]

local Util = {}

-- Safe cloneref (executor environments may provide this)
Util.cloneref = (cloneref or clonereference or function(i) return i end)

-- Deep copy a table
function Util.deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = Util.deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Merge two tables (b overwrites a)
function Util.merge(a, b)
    local result = Util.deepCopy(a)
    for k, v in pairs(b) do
        result[k] = v
    end
    return result
end

-- Check if table contains a value
function Util.contains(t, value)
    for _, v in ipairs(t) do
        if v == value then return true end
    end
    return false
end

-- Clamp a number between min and max
function Util.clamp(n, min, max)
    return math.max(min, math.min(max, n))
end

-- Round to nearest step
function Util.roundToStep(n, step)
    if step <= 0 then return n end
    return math.round(n / step) * step
end

-- Map a value from one range to another
function Util.map(value, inMin, inMax, outMin, outMax)
    return outMin + (outMax - outMin) * ((value - inMin) / (inMax - inMin))
end

-- Safely get a service using cloneref
function Util.getService(name)
    return Util.cloneref(game:GetService(name))
end

-- Create a GuiObject with properties applied
function Util.create(className, properties, parent)
    local obj = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        obj[prop] = value
    end
    if parent then
        obj.Parent = parent
    end
    return obj
end

-- Apply a table of properties to an existing instance
function Util.apply(instance, properties)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

-- Add a UICorner to a GuiObject
function Util.corner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 6)
    corner.Parent = instance
    return corner
end

-- Add a UIPadding to a GuiObject
function Util.padding(instance, top, right, bottom, left)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop    = UDim.new(0, top    or 0)
    pad.PaddingRight  = UDim.new(0, right  or 0)
    pad.PaddingBottom = UDim.new(0, bottom or 0)
    pad.PaddingLeft   = UDim.new(0, left   or 0)
    pad.Parent = instance
    return pad
end

-- Add a UIListLayout to a GuiObject
function Util.listLayout(instance, options)
    options = options or {}
    local layout = Instance.new("UIListLayout")
    layout.FillDirection       = options.FillDirection       or Enum.FillDirection.Vertical
    layout.HorizontalAlignment = options.HorizontalAlignment or Enum.HorizontalAlignment.Left
    layout.VerticalAlignment   = options.VerticalAlignment   or Enum.VerticalAlignment.Top
    layout.SortOrder           = options.SortOrder           or Enum.SortOrder.LayoutOrder
    layout.Padding             = options.Padding             or UDim.new(0, 0)
    layout.Parent = instance
    return layout
end

-- Add UIStroke to a GuiObject
function Util.stroke(instance, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color        = color        or Color3.fromHex("#2a2a2a")
    s.Thickness    = thickness    or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = instance
    return s
end

-- Encode a table to JSON string (basic, for configs)
function Util.toJSON(t, indent, level)
    indent = indent or 2
    level  = level  or 0
    local pad  = string.rep(" ", level * indent)
    local pad2 = string.rep(" ", (level + 1) * indent)
    local tp = type(t)

    if tp == "table" then
        local isArray = #t > 0
        local parts = {}

        if isArray then
            for _, v in ipairs(t) do
                table.insert(parts, pad2 .. Util.toJSON(v, indent, level + 1))
            end
            return "[\n" .. table.concat(parts, ",\n") .. "\n" .. pad .. "]"
        else
            for k, v in pairs(t) do
                local key = '"' .. tostring(k) .. '"'
                table.insert(parts, pad2 .. key .. ": " .. Util.toJSON(v, indent, level + 1))
            end
            table.sort(parts)
            return "{\n" .. table.concat(parts, ",\n") .. "\n" .. pad .. "}"
        end
    elseif tp == "string" then
        return '"' .. t:gsub('\\','\\\\'):gsub('"','\\"'):gsub('\n','\\n') .. '"'
    elseif tp == "number" or tp == "boolean" then
        return tostring(t)
    elseif tp == "nil" then
        return "null"
    else
        return '"[' .. tp .. ']"'
    end
end

-- Decode JSON string to table (basic)
function Util.fromJSON(str)
    local HttpService = Util.getService("HttpService")
    local ok, result = pcall(function()
        return HttpService:JSONDecode(str)
    end)
    return ok and result or {}
end

return Util
