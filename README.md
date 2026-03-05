# GenUI
> Dark minimal Roblox UI Library for Script Hubs · v1.0.0

---

## Quick Start

```lua
local GenUI = loadstring(game:HttpGet("YOUR_CDN_URL/dist/main.lua"))()

local Window = GenUI:CreateWindow({
    Title  = "My Hub",
    Icon   = "home",
    Folder = "myhub",
    Theme  = "Dark",
})

local Tab = Window:Tab({ Title = "Main" })

Tab:Button({
    Title    = "Click Me",
    Callback = function() print("clicked") end,
})
```

---

## Themes

| Name | Description |
|------|-------------|
| `Dark` | Default — deep black, green accent |
| `Midnight` | Dark blue, purple accent |
| `Slate` | Dark blue-grey, sky blue accent |

```lua
Window:SetTheme("Midnight")

-- Custom theme
GenUI:RegisterTheme("MyTheme", {
    Accent = Color3.fromHex("#ff6b6b"),
})
```

---

## Elements

| Element | Method |
|---------|--------|
| Button | `Tab:Button({})` |
| Toggle | `Tab:Toggle({})` |
| Slider | `Tab:Slider({})` |
| Input | `Tab:Input({})` |
| Dropdown | `Tab:Dropdown({})` |
| Colorpicker | `Tab:Colorpicker({})` |
| Keybind | `Tab:Keybind({})` |
| Label | `Tab:Label({})` |
| Divider | `Tab:Divider()` |

---

## Config System

Add `Flag` to any element to make it saveable:

```lua
Tab:Toggle({
    Flag     = "esp_enabled",
    Title    = "Enable ESP",
    Value    = false,
    Callback = function(v) end,
})

-- Save / Load
Window.ConfigManager:config("default"):save()
Window.ConfigManager:config("default"):load()
```

---

## File Structure

```
GenUI/
├── Init.lua
├── Example.lua
├── Core/        Library, Window, Tab, Section, Group
├── Elements/    Button, Toggle, Slider, Input, Dropdown,
│                Colorpicker, Keybind, Label, Divider
├── Systems/     Theme, Icons, Notification, Config
└── Util/        Signal, Tween, Flags, Util
```
