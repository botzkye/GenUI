--[[
    GenUI — Systems/Theme.lua
    Token-based theme engine.
    Elements tag GuiObjects with attribute "_themeKey" so Theme:Apply()
    can re-color the entire UI when the theme is switched at runtime.
--]]

local Theme = {}
Theme.__index = Theme

-- ── Built-in themes ──────────────────────────────────────────────────────────

local THEMES = {

    Dark = {
        -- Backgrounds
        Background      = Color3.fromHex("#0d0d0d"),
        Surface         = Color3.fromHex("#141414"),
        SurfaceHover    = Color3.fromHex("#1c1c1c"),
        SurfaceActive   = Color3.fromHex("#202020"),
        Elevated        = Color3.fromHex("#1a1a1a"),

        -- Borders
        Border          = Color3.fromHex("#222222"),
        BorderFocus     = Color3.fromHex("#3a3a3a"),

        -- Accent
        Accent          = Color3.fromHex("#b8ff57"),
        AccentDim       = Color3.fromHex("#2a3a10"),
        AccentText      = Color3.fromHex("#0d0d0d"),

        -- Text
        TextPrimary     = Color3.fromHex("#f0f0f0"),
        TextSecondary   = Color3.fromHex("#888888"),
        TextMuted       = Color3.fromHex("#444444"),
        TextDisabled    = Color3.fromHex("#333333"),

        -- Semantic
        Success         = Color3.fromHex("#10C550"),
        Warning         = Color3.fromHex("#ffb347"),
        Danger          = Color3.fromHex("#EF4F1D"),
        Info            = Color3.fromHex("#57b8ff"),

        -- Scrollbar
        ScrollBar       = Color3.fromHex("#2a2a2a"),
        ScrollBarHover  = Color3.fromHex("#3a3a3a"),

        -- Toggle
        ToggleOn        = Color3.fromHex("#b8ff57"),
        ToggleOff       = Color3.fromHex("#2a2a2a"),
        ToggleKnob      = Color3.fromHex("#f0f0f0"),

        -- Topbar
        TopbarBg        = Color3.fromHex("#0d0d0d"),
        TopbarBorder    = Color3.fromHex("#1e1e1e"),

        -- Sidebar
        SidebarBg       = Color3.fromHex("#0f0f0f"),
        SidebarBorder   = Color3.fromHex("#1a1a1a"),
        TabActive       = Color3.fromHex("#1c1c1c"),
        TabHover        = Color3.fromHex("#161616"),
    },

    Midnight = {
        Background      = Color3.fromHex("#05050f"),
        Surface         = Color3.fromHex("#0c0c1e"),
        SurfaceHover    = Color3.fromHex("#12122a"),
        SurfaceActive   = Color3.fromHex("#16163a"),
        Elevated        = Color3.fromHex("#10102a"),

        Border          = Color3.fromHex("#1a1a38"),
        BorderFocus     = Color3.fromHex("#2a2a58"),

        Accent          = Color3.fromHex("#7775F2"),
        AccentDim       = Color3.fromHex("#12103a"),
        AccentText      = Color3.fromHex("#ffffff"),

        TextPrimary     = Color3.fromHex("#e8e8ff"),
        TextSecondary   = Color3.fromHex("#7070aa"),
        TextMuted       = Color3.fromHex("#383860"),
        TextDisabled    = Color3.fromHex("#2a2a50"),

        Success         = Color3.fromHex("#10C550"),
        Warning         = Color3.fromHex("#ffb347"),
        Danger          = Color3.fromHex("#EF4F1D"),
        Info            = Color3.fromHex("#57b8ff"),

        ScrollBar       = Color3.fromHex("#1a1a38"),
        ScrollBarHover  = Color3.fromHex("#2a2a58"),

        ToggleOn        = Color3.fromHex("#7775F2"),
        ToggleOff       = Color3.fromHex("#1a1a38"),
        ToggleKnob      = Color3.fromHex("#ffffff"),

        TopbarBg        = Color3.fromHex("#05050f"),
        TopbarBorder    = Color3.fromHex("#12122a"),

        SidebarBg       = Color3.fromHex("#08081a"),
        SidebarBorder   = Color3.fromHex("#12122a"),
        TabActive       = Color3.fromHex("#12122a"),
        TabHover        = Color3.fromHex("#0e0e22"),
    },

    Slate = {
        Background      = Color3.fromHex("#0e1015"),
        Surface         = Color3.fromHex("#141820"),
        SurfaceHover    = Color3.fromHex("#1a1e28"),
        SurfaceActive   = Color3.fromHex("#1e2230"),
        Elevated        = Color3.fromHex("#181c26"),

        Border          = Color3.fromHex("#20242e"),
        BorderFocus     = Color3.fromHex("#30384a"),

        Accent          = Color3.fromHex("#57b8ff"),
        AccentDim       = Color3.fromHex("#0e1a28"),
        AccentText      = Color3.fromHex("#0e1015"),

        TextPrimary     = Color3.fromHex("#dce4f0"),
        TextSecondary   = Color3.fromHex("#6878a0"),
        TextMuted       = Color3.fromHex("#30384a"),
        TextDisabled    = Color3.fromHex("#252d3e"),

        Success         = Color3.fromHex("#10C550"),
        Warning         = Color3.fromHex("#ffb347"),
        Danger          = Color3.fromHex("#EF4F1D"),
        Info            = Color3.fromHex("#57b8ff"),

        ScrollBar       = Color3.fromHex("#20242e"),
        ScrollBarHover  = Color3.fromHex("#30384a"),

        ToggleOn        = Color3.fromHex("#57b8ff"),
        ToggleOff       = Color3.fromHex("#20242e"),
        ToggleKnob      = Color3.fromHex("#dce4f0"),

        TopbarBg        = Color3.fromHex("#0e1015"),
        TopbarBorder    = Color3.fromHex("#1a1e28"),

        SidebarBg       = Color3.fromHex("#0c0f14"),
        SidebarBorder   = Color3.fromHex("#181c26"),
        TabActive       = Color3.fromHex("#181c26"),
        TabHover        = Color3.fromHex("#141820"),
    },
}

-- ── Theme object ─────────────────────────────────────────────────────────────

function Theme.new(name)
    local self = setmetatable({}, Theme)
    self._name   = name or "Dark"
    self._tokens = THEMES[self._name] or THEMES.Dark
    self._tagged = {} -- { [instance] = true }
    return self
end

-- Register a custom theme
function Theme.register(name, tokens)
    assert(type(name) == "string", "Theme name must be a string")
    assert(type(tokens) == "table", "Theme tokens must be a table")
    -- Fill missing keys from Dark theme as fallback
    local merged = {}
    for k, v in pairs(THEMES.Dark) do
        merged[k] = tokens[k] or v
    end
    THEMES[name] = merged
end

-- Get a color token value
function Theme:get(token)
    return self._tokens[token] or Color3.new(1, 0, 1) -- magenta = missing token
end

-- Tag a GuiObject so Apply() can re-color it
-- property: the instance property to set (e.g. "BackgroundColor3")
-- token:    the theme token key (e.g. "Surface")
function Theme:tag(instance, property, token)
    instance:SetAttribute("_themeKey_" .. property, token)
    table.insert(self._tagged, instance)
    -- Apply immediately
    instance[property] = self:get(token)
end

-- Re-apply all tokens to all tagged instances (called on theme switch)
function Theme:apply()
    for _, instance in ipairs(self._tagged) do
        if instance and instance.Parent then
            for _, attr in ipairs(instance:GetAttributes()) do
                if attr:sub(1, 10) == "_themeKey_" then
                    local property = attr:sub(11)
                    local token    = instance:GetAttribute(attr)
                    local ok, err = pcall(function()
                        instance[property] = self:get(token)
                    end)
                    if not ok then
                        warn("[GenUI:Theme] Failed to apply token '" .. token .. "' to " .. property .. ": " .. tostring(err))
                    end
                end
            end
        end
    end
end

-- Switch to a different theme
function Theme:switch(name)
    local tokens = THEMES[name]
    if not tokens then
        warn("[GenUI:Theme] Unknown theme: " .. tostring(name))
        return
    end
    self._name   = name
    self._tokens = tokens
    self:apply()
end

-- Get current theme name
function Theme:getName()
    return self._name
end

-- Get list of available theme names
function Theme.list()
    local names = {}
    for k in pairs(THEMES) do
        table.insert(names, k)
    end
    table.sort(names)
    return names
end

return Theme
