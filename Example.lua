--[[
    ╔═══════════════════════════════════════════════╗
    ║         GenUI Example  —  v1.0.0              ║
    ║    Full demo of all elements & systems        ║
    ╚═══════════════════════════════════════════════╝
--]]

local GenUI

do
    local ok, result = pcall(function()
        return require("./Init")
    end)

    if ok then
        GenUI = result
    else
        if game:GetService("RunService"):IsStudio() then
            GenUI = require(game:GetService("ReplicatedStorage"):WaitForChild("GenUI"):WaitForChild("Init"))
        else
            GenUI = loadstring(game:HttpGet("https://github.com/botzkye/GenUI/blob/main/dist/main.lua"))()
        end
    end
end

-- ── Colors ────────────────────────────────────────────────────────────────────
local Accent  = Color3.fromHex("#b8ff57")
local Blue    = Color3.fromHex("#57b8ff")
local Purple  = Color3.fromHex("#7775F2")
local Red     = Color3.fromHex("#EF4F1D")
local Green   = Color3.fromHex("#10C550")
local Yellow  = Color3.fromHex("#ffb347")
local Muted   = Color3.fromHex("#555555")

-- ═══════════════════════════════════════════════════
--  WINDOW
-- ═══════════════════════════════════════════════════

local Window = GenUI:CreateWindow({
    Title   = "GenUI Example",
    Icon    = "home",
    Folder  = "genui_example",
    Theme   = "Dark",
    OpenKey = Enum.KeyCode.RightShift,
    HideSearchBar = false,
})

-- ═══════════════════════════════════════════════════
--  SECTION: ELEMENTS
-- ═══════════════════════════════════════════════════

local ElementsSection = Window:Section({ Title = "Elements" })

-- ───────────────────────────────────────────────────
--  TAB: OVERVIEW
-- ───────────────────────────────────────────────────

do
    local Tab = ElementsSection:Tab({
        Title = "Overview",
        Icon  = "home",
    })

    Tab:Label({ Title = "GROUP EXAMPLES", TextSize = 10 })
    Tab:Space()

    -- Group 1: two buttons side by side
    local g1 = Tab:Group()
    g1:Button({ Title = "Button A", Icon = "", Justify = "Center", Callback = function()
        print("[GenUI] Button A clicked")
    end })
    g1:Space()
    g1:Button({ Title = "Button B", Icon = "", Justify = "Center", Callback = function()
        print("[GenUI] Button B clicked")
    end })

    Tab:Space()

    -- Group 2: button + toggle + colorpicker
    local g2 = Tab:Group()
    g2:Button({ Title = "Action", Icon = "", Justify = "Center", Callback = function()
        print("[GenUI] Group action")
    end })
    g2:Space()
    g2:Toggle({ Title = "Enable", Callback = function(v)
        print("[GenUI] Group toggle:", v)
    end })
    g2:Space()
    g2:Colorpicker({ Default = Color3.fromHex("#b8ff57"), Callback = function(c)
        print("[GenUI] Group color:", c)
    end })

    Tab:Space()

    -- Sections inside a tab
    Tab:Label({ Title = "SECTION EXAMPLES", TextSize = 10 })
    Tab:Space()

    local s1 = Tab:Section({ Title = "Section Alpha", Collapsible = true, Opened = true })
    s1:Button({ Title = "Inside Section", Icon = "", Justify = "Center", Callback = function()
        print("[GenUI] Section Alpha button")
    end })
    s1:Space()
    s1:Toggle({ Title = "Section Toggle", Callback = function(v)
        print("[GenUI] Section Alpha toggle:", v)
    end })

    local s2 = Tab:Section({ Title = "Section Beta", Collapsible = true, Opened = false })
    s2:Button({ Title = "Hidden by Default", Icon = "", Justify = "Center", Callback = function()
        print("[GenUI] Section Beta button")
    end })
    s2:Space()
    s2:Slider({
        Title = "Volume",
        Value = { Min = 0, Max = 100, Default = 50 },
        Step  = 1,
        Callback = function(v) print("[GenUI] Volume:", v) end,
    })
end

-- ───────────────────────────────────────────────────
--  TAB: BUTTON
-- ───────────────────────────────────────────────────

do
    local Tab = ElementsSection:Tab({
        Title = "Button",
        Icon  = "mouse-pointer",
    })

    -- Default
    Tab:Button({
        Title    = "Default Button",
        Callback = function() print("[GenUI] Default button") end,
    })

    Tab:Space()

    -- With description
    Tab:Button({
        Title    = "Button with Description",
        Desc     = "This is a subtitle line",
        Callback = function() print("[GenUI] Button with desc") end,
    })

    Tab:Space()

    -- Colored accent
    Tab:Button({
        Title    = "Blue Accent",
        Color    = Blue,
        Icon     = "",
        Justify  = "Center",
        Callback = function() print("[GenUI] Blue button") end,
    })

    Tab:Space()

    Tab:Button({
        Title    = "Green Accent",
        Color    = Green,
        Icon     = "",
        Justify  = "Center",
        Callback = function() print("[GenUI] Green button") end,
    })

    Tab:Space()

    Tab:Button({
        Title    = "Red / Danger",
        Color    = Red,
        Icon     = "",
        Justify  = "Center",
        Callback = function() print("[GenUI] Red button") end,
    })

    Tab:Space()

    -- Highlight demo
    local highlightBtn
    highlightBtn = Tab:Button({
        Title    = "Highlight on Click",
        Callback = function()
            highlightBtn:Highlight()
            print("[GenUI] Highlighted!")
        end,
    })

    Tab:Space()

    -- Notify trigger
    Tab:Button({
        Title    = "Send Notification",
        Callback = function()
            GenUI:Notify({
                Title   = "Hello from GenUI!",
                Content = "This is a notification example.",
                Icon    = "check-circle",
                Duration = 4,
            })
        end,
    })

    Tab:Space()

    -- Popup trigger
    Tab:Button({
        Title    = "Open Popup",
        Callback = function()
            GenUI:Popup({
                Title   = "Confirm Action",
                Content = "Are you sure you want to proceed with this action?",
                Buttons = {
                    {
                        Title    = "Confirm",
                        Variant  = "Primary",
                        Callback = function()
                            GenUI:Notify({ Title = "Confirmed!", Duration = 2 })
                        end,
                    },
                    {
                        Title    = "Cancel",
                        Variant  = "Secondary",
                        Callback = function() end,
                    },
                }
            })
        end,
    })

    Tab:Space()

    -- Locked
    Tab:Button({
        Title       = "Locked Button",
        Locked      = true,
        LockedTitle = "This feature is unavailable",
        Callback    = function() end,
    })
end

-- ───────────────────────────────────────────────────
--  TAB: TOGGLE
-- ───────────────────────────────────────────────────

do
    local Tab = ElementsSection:Tab({
        Title = "Toggle",
        Icon  = "toggle-right",
    })

    -- Switch type
    Tab:Toggle({
        Title    = "Switch (default)",
        Value    = false,
        Callback = function(v) print("[GenUI] Switch:", v) end,
    })

    Tab:Space()

    Tab:Toggle({
        Title    = "Switch with Description",
        Desc     = "Toggle this to enable the feature",
        Value    = true,
        Callback = function(v) print("[GenUI] Switch + desc:", v) end,
    })

    Tab:Space()

    -- Checkbox type
    Tab:Toggle({
        Title    = "Checkbox",
        Type     = "Checkbox",
        Value    = false,
        Callback = function(v) print("[GenUI] Checkbox:", v) end,
    })

    Tab:Space()

    Tab:Toggle({
        Title    = "Checkbox with Description",
        Desc     = "Check to agree to terms",
        Type     = "Checkbox",
        Value    = true,
        Callback = function(v) print("[GenUI] Checkbox + desc:", v) end,
    })

    Tab:Space()

    -- Group of toggles
    Tab:Label({ Title = "TOGGLE GROUP", TextSize = 10 })
    Tab:Space()

    local g = Tab:Group()
    g:Toggle({ Title = "Option 1", Callback = function(v) print("[GenUI] Option 1:", v) end })
    g:Space()
    g:Toggle({ Title = "Option 2", Callback = function(v) print("[GenUI] Option 2:", v) end })

    Tab:Space()

    -- Locked
    Tab:Toggle({
        Title       = "Locked Toggle",
        Locked      = true,
        LockedTitle = "This toggle is locked",
        Callback    = function() end,
    })
end

-- ───────────────────────────────────────────────────
--  TAB: SLIDER
-- ───────────────────────────────────────────────────

do
    local Tab = ElementsSection:Tab({
        Title = "Slider",
        Icon  = "sliders",
    })

    Tab:Slider({
        Title    = "Speed",
        Desc     = "Player movement speed (default 16)",
        Value    = { Min = 0, Max = 100, Default = 16 },
        Step     = 1,
        IsTooltip = true,
        Callback = function(v) print("[GenUI] Speed:", v) end,
    })

    Tab:Space()

    Tab:Slider({
        Title    = "Jump Power",
        Value    = { Min = 0, Max = 200, Default = 50 },
        Step     = 5,
        Callback = function(v) print("[GenUI] Jump power:", v) end,
    })

    Tab:Space()

    Tab:Slider({
        Title    = "FOV",
        Value    = { Min = 40, Max = 120, Default = 70 },
        Step     = 1,
        IsTooltip = true,
        Callback = function(v)
            -- workspace.CurrentCamera.FieldOfView = v
            print("[GenUI] FOV:", v)
        end,
    })

    Tab:Space()

    -- No title, just icons
    Tab:Label({ Title = "ICON SLIDERS", TextSize = 10 })
    Tab:Space()

    Tab:Slider({
        Value    = { Min = 0, Max = 100, Default = 60 },
        Step     = 1,
        IsTooltip = true,
        Icons    = { From = "sun", To = "sun" },
        Callback = function(v) print("[GenUI] Brightness:", v) end,
    })

    Tab:Space()

    -- Locked
    Tab:Slider({
        Title       = "Locked Slider",
        Value       = { Min = 0, Max = 100, Default = 50 },
        Step        = 1,
        Locked      = true,
        LockedTitle = "This slider is locked",
        Callback    = function() end,
    })
end

-- ───────────────────────────────────────────────────
--  TAB: INPUT
-- ───────────────────────────────────────────────────

do
    local Tab = ElementsSection:Tab({
        Title = "Input",
        Icon  = "keyboard",
    })

    Tab:Input({
        Title       = "Username",
        Placeholder = "Enter username...",
        Callback    = function(v) print("[GenUI] Username:", v) end,
    })

    Tab:Space()

    Tab:Input({
        Title       = "Password",
        Placeholder = "Enter password...",
        Desc        = "Used for authentication",
        Callback    = function(v) print("[GenUI] Password:", v) end,
    })

    Tab:Space()

    Tab:Input({
        Title       = "Script Textarea",
        Type        = "Textarea",
        Placeholder = "Paste your script here...",
        Callback    = function(v) print("[GenUI] Script:", v) end,
    })

    Tab:Space()

    Tab:Input({
        Title       = "Notes",
        Type        = "Textarea",
        Desc        = "Write anything",
        Placeholder = "Type a note...",
        Callback    = function(v) print("[GenUI] Note:", v) end,
    })

    Tab:Space()

    Tab:Input({
        Title       = "Locked Input",
        Locked      = true,
        LockedTitle = "Input is read-only",
        Callback    = function() end,
    })
end

-- ───────────────────────────────────────────────────
--  TAB: DROPDOWN
-- ───────────────────────────────────────────────────

do
    local Tab = ElementsSection:Tab({
        Title = "Dropdown",
        Icon  = "menu",
    })

    -- Simple dropdown
    Tab:Dropdown({
        Title    = "Game Mode",
        Values   = { "Normal", "Hardcore", "Creative", "Spectator" },
        Value    = "Normal",
        Callback = function(v) print("[GenUI] Game mode:", v) end,
    })

    Tab:Space()

    -- Multi-select
    Tab:Dropdown({
        Title     = "Active Modules (multi)",
        Values    = { "Aimbot", "ESP", "Speedhack", "Fly", "Noclip" },
        Multi     = true,
        AllowNone = true,
        Callback  = function(selected)
            print("[GenUI] Modules:", table.concat(selected or {}, ", "))
        end,
    })

    Tab:Space()

    -- Advanced (object) dropdown
    Tab:Dropdown({
        Title  = "File Actions (advanced)",
        Values = {
            { Title = "New File",    Icon = "file",      Callback = function() print("New file") end },
            { Title = "Open File",   Icon = "folder",    Callback = function() print("Open file") end },
            { Title = "Save",        Icon = "save",      Callback = function() print("Saved") end },
            { Type  = "Divider" },
            { Title = "Delete",      Icon = "trash",     Callback = function() print("Delete") end },
        }
    })

    Tab:Space()

    -- Linked dropdowns (refresh example)
    Tab:Label({ Title = "LINKED DROPDOWNS", TextSize = 10 })
    Tab:Space()

    local subDropdown

    Tab:Dropdown({
        Title    = "Category",
        Values   = { "Weapons", "Tools", "Vehicles" },
        Value    = "Weapons",
        Callback = function(v)
            local map = {
                Weapons  = { "Sword", "Gun", "Bow" },
                Tools    = { "Hammer", "Wrench", "Saw" },
                Vehicles = { "Car", "Bike", "Boat" },
            }
            if subDropdown then
                subDropdown:Refresh(map[v] or {})
            end
            print("[GenUI] Category:", v)
        end,
    })

    subDropdown = Tab:Dropdown({
        Title    = "Item",
        Values   = { "Sword", "Gun", "Bow" },
        Value    = "Sword",
        Callback = function(v) print("[GenUI] Item:", v) end,
    })
end

-- ───────────────────────────────────────────────────
--  TAB: COLORPICKER
-- ───────────────────────────────────────────────────

do
    local Tab = ElementsSection:Tab({
        Title = "Color",
        Icon  = "color-swatch",
    })

    Tab:Colorpicker({
        Title    = "Accent Color",
        Default  = Color3.fromHex("#b8ff57"),
        Callback = function(color, alpha)
            print("[GenUI] Accent color:", color, "alpha:", alpha)
        end,
    })

    Tab:Space()

    Tab:Colorpicker({
        Title        = "Background Color",
        Desc         = "Main UI background",
        Default      = Color3.fromHex("#0d0d0d"),
        Transparency = 0,
        Callback     = function(color, alpha)
            print("[GenUI] Background:", color)
        end,
    })

    Tab:Space()

    -- Group: two colorpickers side by side
    Tab:Label({ Title = "COLOR GROUP", TextSize = 10 })
    Tab:Space()

    local cg = Tab:Group()
    cg:Colorpicker({
        Title    = "Primary",
        Default  = Color3.fromHex("#7775F2"),
        Callback = function(c) print("[GenUI] Primary:", c) end,
    })
    cg:Space()
    cg:Colorpicker({
        Title    = "Secondary",
        Default  = Color3.fromHex("#57b8ff"),
        Callback = function(c) print("[GenUI] Secondary:", c) end,
    })
end

-- ───────────────────────────────────────────────────
--  TAB: KEYBIND
-- ───────────────────────────────────────────────────

do
    local Tab = ElementsSection:Tab({
        Title = "Keybind",
        Icon  = "keyboard",
    })

    Tab:Keybind({
        Title    = "Toggle UI",
        Desc     = "Press to show/hide the window",
        Value    = "RightShift",
        Callback = function(key)
            Window:SetToggleKey(Enum.KeyCode[key])
            print("[GenUI] Toggle key changed to:", key)
        end,
    })

    Tab:Space()

    Tab:Keybind({
        Title    = "Fly Key",
        Value    = "F",
        Callback = function(key)
            print("[GenUI] Fly key:", key)
        end,
    })

    Tab:Space()

    Tab:Keybind({
        Title    = "Sprint Key",
        Value    = "LeftShift",
        Callback = function(key)
            print("[GenUI] Sprint key:", key)
        end,
    })
end

-- ═══════════════════════════════════════════════════
--  SECTION: CONFIG
-- ═══════════════════════════════════════════════════

local ConfigSection = Window:Section({ Title = "Config" })

do
    -- Elements with flags (these get saved/loaded)
    local FlagsTab = ConfigSection:Tab({
        Title = "Flagged Elements",
        Icon  = "save",
    })

    FlagsTab:Toggle({
        Flag     = "aimbot_enabled",
        Title    = "Enable Aimbot",
        Value    = false,
        Callback = function(v) print("[GenUI] Aimbot:", v) end,
    })

    FlagsTab:Space()

    FlagsTab:Slider({
        Flag     = "aimbot_fov",
        Title    = "Aimbot FOV",
        Value    = { Min = 10, Max = 500, Default = 120 },
        Step     = 5,
        Callback = function(v) print("[GenUI] FOV:", v) end,
    })

    FlagsTab:Space()

    FlagsTab:Dropdown({
        Flag     = "aimbot_target",
        Title    = "Target Part",
        Values   = { "Head", "Torso", "HumanoidRootPart" },
        Value    = "Head",
        Callback = function(v) print("[GenUI] Target:", v) end,
    })

    FlagsTab:Space()

    FlagsTab:Input({
        Flag        = "player_name",
        Title       = "Player Filter",
        Placeholder = "Enter player name...",
        Callback    = function(v) print("[GenUI] Filter:", v) end,
    })

    FlagsTab:Space()

    FlagsTab:Colorpicker({
        Flag     = "esp_color",
        Title    = "ESP Color",
        Default  = Color3.fromHex("#b8ff57"),
        Callback = function(c) print("[GenUI] ESP color:", c) end,
    })

    FlagsTab:Space()

    FlagsTab:Keybind({
        Flag     = "esp_toggle_key",
        Title    = "ESP Toggle Key",
        Value    = "Z",
        Callback = function(k) print("[GenUI] ESP key:", k) end,
    })
end

do
    -- Config panel
    local ConfigTab = ConfigSection:Tab({
        Title = "Config Manager",
        Icon  = "folder",
    })

    local Manager    = Window.ConfigManager
    local configName = "default"

    local nameInput = ConfigTab:Input({
        Title       = "Config Name",
        Value       = configName,
        Placeholder = "e.g. default, pvp, build",
        Callback    = function(v) configName = v end,
    })

    ConfigTab:Space()

    -- Existing configs list
    local allConfigs = Manager:allConfigs()
    if #allConfigs > 0 then
        local configDropdown = ConfigTab:Dropdown({
            Title    = "Saved Configs",
            Values   = allConfigs,
            AllowNone = true,
            Callback = function(v)
                if v then
                    configName = v
                    nameInput:Set(v)
                end
            end,
        })

        ConfigTab:Space()
    end

    ConfigTab:Button({
        Title    = "💾  Save Config",
        Color    = Green,
        Justify  = "Center",
        Icon     = "",
        Callback = function()
            local cfg = Manager:config(configName)
            if cfg:save() then
                GenUI:Notify({
                    Title   = "Config Saved",
                    Content = "'" .. configName .. "' has been saved.",
                    Icon    = "check-circle",
                    Duration = 3,
                })
            end
        end,
    })

    ConfigTab:Space()

    ConfigTab:Button({
        Title    = "📂  Load Config",
        Color    = Blue,
        Justify  = "Center",
        Icon     = "",
        Callback = function()
            local cfg = Manager:config(configName)
            if cfg:load() then
                GenUI:Notify({
                    Title   = "Config Loaded",
                    Content = "'" .. configName .. "' has been applied.",
                    Icon    = "check-circle",
                    Duration = 3,
                })
            else
                GenUI:Notify({
                    Title   = "Load Failed",
                    Content = "Config '" .. configName .. "' not found.",
                    Duration = 3,
                })
            end
        end,
    })

    ConfigTab:Space()

    ConfigTab:Button({
        Title    = "🗑  Delete Config",
        Color    = Red,
        Justify  = "Center",
        Icon     = "",
        Callback = function()
            Manager:config(configName):delete()
            GenUI:Notify({
                Title   = "Config Deleted",
                Content = "'" .. configName .. "' removed.",
                Duration = 3,
            })
        end,
    })
end

-- ═══════════════════════════════════════════════════
--  SECTION: SETTINGS
-- ═══════════════════════════════════════════════════

local SettingsSection = Window:Section({ Title = "Settings" })

do
    local Tab = SettingsSection:Tab({
        Title = "Appearance",
        Icon  = "settings",
    })

    Tab:Dropdown({
        Title    = "Theme",
        Values   = { "Dark", "Midnight", "Slate" },
        Value    = "Dark",
        Callback = function(v)
            Window:SetTheme(v)
            print("[GenUI] Theme:", v)
        end,
    })

    Tab:Space()

    Tab:Slider({
        Title    = "UI Scale",
        Value    = { Min = 50, Max = 150, Default = 100 },
        Step     = 5,
        IsTooltip = true,
        Callback = function(v)
            Window:SetUIScale(v / 100)
        end,
    })

    Tab:Space()

    Tab:Toggle({
        Title    = "Show Notifications",
        Value    = true,
        Callback = function(v)
            print("[GenUI] Notifications:", v)
        end,
    })

    Tab:Space()

    Tab:Button({
        Title    = "Close Window",
        Color    = Red,
        Justify  = "Center",
        Icon     = "",
        Callback = function()
            Window:Destroy()
        end,
    })
end

do
    local Tab = SettingsSection:Tab({
        Title = "About",
        Icon  = "info",
    })

    Tab:Label({ Title = "GenUI  ·  v1.0.0", TextSize = 18 })
    Tab:Space()
    Tab:Label({
        Title    = "A dark, minimal UI library for Roblox script hubs.\nBuilt with a clean architecture and token-based theming.",
        TextSize = 12,
    })
    Tab:Space()
    Tab:Divider()
    Tab:Space()
    Tab:Label({ Title = "FEATURES", TextSize = 10 })
    Tab:Space()
    Tab:Label({ Title = "· Window system with sidebar navigation", TextSize = 12 })
    Tab:Label({ Title = "· Button, Toggle, Slider, Input, Dropdown", TextSize = 12 })
    Tab:Label({ Title = "· Colorpicker, Keybind, Label, Divider", TextSize = 12 })
    Tab:Label({ Title = "· Config save/load system via Flags", TextSize = 12 })
    Tab:Label({ Title = "· Token-based theming (Dark / Midnight / Slate)", TextSize = 12 })
    Tab:Label({ Title = "· Notifications & Popup dialogs", TextSize = 12 })
    Tab:Space()
    Tab:Divider()
    Tab:Space()

    Tab:Button({
        Title    = "Send Test Notification",
        Justify  = "Center",
        Icon     = "",
        Callback = function()
            GenUI:Notify({
                Title    = "GenUI",
                Content  = "Everything is working correctly ✓",
                Icon     = "check-circle",
                Duration = 4,
            })
        end,
    })
end

print("[GenUI] Example loaded successfully!")
