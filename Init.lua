--[[
    ╔═══════════════════════════════════════════════╗
    ║           GenUI  —  v1.0.0                    ║
    ║      Dark Minimal Roblox UI Library           ║
    ╚═══════════════════════════════════════════════╝

    Usage:
        local GenUI = require(path.to.GenUI.Init)

        local Window = GenUI:CreateWindow({
            Title  = "My Hub",
            Icon   = "home",
            Folder = "myhub",
        })

        local Tab = Window:Tab({ Title = "Main" })

        Tab:Button({
            Title    = "Click Me",
            Callback = function() print("clicked") end,
        })
--]]

-- Safe cloneref for executor environments
local cloneref = (cloneref or clonereference or function(i) return i end)

-- Resolve module path (works in Roblox Studio + executor)
local function loadModule(path)
    local ok, result = pcall(require, path)
    if ok then return result end
    error("[GenUI] Failed to load module: " .. tostring(path) .. "\n" .. tostring(result))
end

local Library = loadModule(script.Core.Library)

-- Expose version and utils at top level
Library.cloneref = cloneref

return Library
