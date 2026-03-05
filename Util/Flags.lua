--[[
    GenUI — Util/Flags.lua
    Global registry mapping Flag string → Element instance
--]]

local Flags = {}
Flags._registry = {}

-- Register an element with a flag key
function Flags.set(flag, element)
    if not flag or flag == "" then return end
    Flags._registry[flag] = element
end

-- Get element by flag key
function Flags.get(flag)
    return Flags._registry[flag]
end

-- Get all registered flags
function Flags.all()
    return Flags._registry
end

-- Remove a flag
function Flags.remove(flag)
    Flags._registry[flag] = nil
end

-- Clear all flags (on window destroy)
function Flags.clear()
    Flags._registry = {}
end

return Flags
