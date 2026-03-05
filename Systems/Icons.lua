--[[
    GenUI — Systems/Icons.lua
    Icon name → Roblox ImageLabel AssetId resolver.

    Supports:
      "trash"              → default set lookup
      "solar:home-bold"    → named set lookup
      "rbxassetid://123"   → direct asset id passthrough
--]]

local Icons = {}
Icons.__index = Icons

-- ── Default icon set (Lucide-style names → rbxassetid) ───────────────────────
-- Populate with your actual asset IDs.
-- Format: ["icon-name"] = "rbxassetid://XXXX"

local DEFAULT_SET = {
    -- Navigation
    ["home"]              = "rbxassetid://92190299966310",
    ["menu"]              = "rbxassetid://134384554225463",
    ["chevron-down"]      = "rbxassetid://0",
    ["chevron-up"]        = "rbxassetid://0",
    ["chevron-left"]      = "rbxassetid://0",
    ["chevron-right"]     = "rbxassetid://0",
    ["arrow-left"]        = "rbxassetid://0",
    ["arrow-right"]       = "rbxassetid://0",

    -- Actions
    ["search"]            = "rbxassetid://0",
    ["plus"]              = "rbxassetid://0",
    ["minus"]             = "rbxassetid://0",
    ["x"]                 = "rbxassetid://0",
    ["check"]             = "rbxassetid://0",
    ["edit"]              = "rbxassetid://0",
    ["trash"]             = "rbxassetid://0",
    ["copy"]              = "rbxassetid://0",
    ["link"]              = "rbxassetid://0",
    ["download"]          = "rbxassetid://0",
    ["upload"]            = "rbxassetid://0",
    ["refresh"]           = "rbxassetid://0",
    ["lock"]              = "rbxassetid://0",
    ["unlock"]            = "rbxassetid://0",
    ["eye"]               = "rbxassetid://0",
    ["eye-off"]           = "rbxassetid://0",

    -- UI
    ["settings"]          = "rbxassetid://0",
    ["sliders"]           = "rbxassetid://0",
    ["toggle-left"]       = "rbxassetid://0",
    ["toggle-right"]      = "rbxassetid://0",
    ["mouse-pointer"]     = "rbxassetid://0",
    ["keyboard"]          = "rbxassetid://0",
    ["monitor"]           = "rbxassetid://0",

    -- Files
    ["file"]              = "rbxassetid://89294979831077",
    ["file-plus"]         = "rbxassetid://0",
    ["file-text"]         = "rbxassetid://89294979831077",
    ["folder"]            = "rbxassetid://74631950400584",
    ["folder-open"]       = "rbxassetid://0",
    ["save"]              = "rbxassetid://0",

    -- Alerts
    ["bell"]              = "rbxassetid://0",
    ["bell-off"]          = "rbxassetid://0",
    ["alert-circle"]      = "rbxassetid://0",
    ["info"]              = "rbxassetid://119096461016615",
    ["check-circle"]      = "rbxassetid://132438947521974",
    ["x-circle"]          = "rbxassetid://0",

    -- Misc
    ["bird"]              = "rbxassetid://0",
    ["star"]              = "rbxassetid://0",
    ["heart"]             = "rbxassetid://0",
    ["github"]            = "rbxassetid://0",
    ["discord"]           = "rbxassetid://0",
    ["color-swatch"]      = "rbxassetid://0",
    ["sun"]               = "rbxassetid://0",
    ["moon"]              = "rbxassetid://0",
}

-- ── Named icon sets ───────────────────────────────────────────────────────────

local NAMED_SETS = {
    solar = {
        ["home-bold"]               = "rbxassetid://92190299966310",
        ["info-square-bold"]        = "rbxassetid://119096461016615",
        ["check-square-bold"]       = "rbxassetid://132438947521974",
        ["cursor-square-bold"]      = "rbxassetid://120306472146156",
        ["file-text-bold"]          = "rbxassetid://89294979831077",
        ["folder-with-files-bold"]  = "rbxassetid://74631950400584",
        ["hamburger-menu-bold"]     = "rbxassetid://134384554225463",
        ["home-2-bold"]             = "rbxassetid://92190299966310",
        ["password-bold"]           = "rbxassetid://109919668957167",
        ["transfer-horizontal-bold"]= "rbxassetid://125444491429160",
        ["bell-bold"]               = "rbxassetid://0",
        ["folder-2-bold-duotone"]   = "rbxassetid://74631950400584",
    },
}

-- ── Fallback asset (used when icon not found) ─────────────────────────────────
local FALLBACK = "rbxassetid://0"

-- ── API ───────────────────────────────────────────────────────────────────────

-- Resolve an icon name to a Roblox asset string
-- Returns a valid rbxassetid:// string
function Icons.resolve(name)
    if not name or name == "" then
        return FALLBACK
    end

    -- Direct asset passthrough
    if name:sub(1, 13) == "rbxassetid://" then
        return name
    end

    -- Named set: "solar:home-bold"
    if name:find(":") then
        local setName, iconName = name:match("^(.-)%:(.+)$")
        if setName and iconName then
            local set = NAMED_SETS[setName]
            if set then
                return set[iconName] or FALLBACK
            end
        end
        return FALLBACK
    end

    -- Default set lookup
    return DEFAULT_SET[name] or FALLBACK
end

-- Add icons to an existing named set (or create new set)
function Icons.add(setName, iconMap)
    if not NAMED_SETS[setName] then
        NAMED_SETS[setName] = {}
    end
    for name, assetId in pairs(iconMap) do
        NAMED_SETS[setName][name] = assetId
    end
end

-- Add icons to the default set
function Icons.addDefault(iconMap)
    for name, assetId in pairs(iconMap) do
        DEFAULT_SET[name] = assetId
    end
end

-- Check if an icon name resolves to a real asset (not the fallback)
function Icons.exists(name)
    return Icons.resolve(name) ~= FALLBACK
end

-- Apply an icon to an ImageLabel/ImageButton
-- Handles visibility: hides the image if no icon found
function Icons.apply(imageInstance, name, color)
    local asset = Icons.resolve(name)
    imageInstance.Image = asset

    if color then
        imageInstance.ImageColor3 = color
    end

    -- Hide if no real asset
    imageInstance.Visible = (asset ~= FALLBACK and asset ~= "rbxassetid://0")
end

return Icons
