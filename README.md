# GenUI
> Dark minimal Roblox UI Library · v1.1.0

---

## Quick Start

```lua
local GenUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/botzkye/GenUI/main/dist/main.lua"
))()

local Window = GenUI:CreateWindow({
    Title  = "My Hub",
    Icon   = "rbxassetid://YOUR_ASSET_ID",  -- atau nama icon: "home", "settings", dll
    Folder = "myhub",
    Theme  = "Dark",
})

local Tab = Window:Tab({ Title = "Main", Icon = "home" })

Tab:Button({
    Title    = "Click Me",
    Callback = function() print("clicked") end,
})
```

---

## CreateWindow Options

| Option | Type | Default | Keterangan |
|--------|------|---------|-----------|
| `Title` | string | `"GenUI"` | Judul window |
| `Icon` | string | — | Asset ID atau nama icon |
| `Folder` | string | `"GenUI"` | Folder config di writefile |
| `Theme` | string | `"Dark"` | Nama theme |
| `Size` | UDim2 | `580×420` | Ukuran window |
| `OpenKey` | KeyCode | `RightShift` | Keyboard toggle |
| `HideSearchBar` | bool | `false` | Sembunyikan search di sidebar |

---

## Window Methods

```lua
Window:Tab({ Title, Icon })         -- buat tab baru
Window:SetTheme("Midnight")         -- ganti theme
Window:SetUIScale(1.2)              -- scale UI
Window:SetToggleKey(KeyCode.F5)     -- ganti toggle key
Window:Open()                       -- buka window
Window:toggle()                     -- toggle buka/tutup
Window:destroy()                    -- hapus window
```

---

## Elements

### Button
```lua
Tab:Button({
    Title    = "Teleport",
    Icon     = "home",
    Color    = "accent",       -- "accent" | "danger" | "success" | Color3
    Locked   = false,
    Callback = function() end,
})
```

### Toggle
```lua
Tab:Toggle({
    Title    = "Enable ESP",
    Flag     = "esp_enabled",
    Value    = false,
    Type     = "Switch",       -- "Switch" | "Checkbox"
    Desc     = "Keterangan",
    Callback = function(v) end,
})
```

### Slider
```lua
Tab:Slider({
    Title    = "FOV",
    Flag     = "aimbot_fov",
    Min      = 1,
    Max      = 180,
    Value    = 90,
    Step     = 1,
    Callback = function(v) end,
})
```

### Input
```lua
Tab:Input({
    Title       = "Username",
    Placeholder = "Enter name...",
    Flag        = "username",
    Type        = "Input",     -- "Input" | "Textarea"
    Desc        = "Keterangan",
    Callback    = function(v) end,
})
```

### Dropdown
```lua
Tab:Dropdown({
    Title    = "Target Part",
    Flag     = "target_part",
    Values   = { "Head", "Torso", "Left Arm" },
    Value    = "Head",
    Multi    = false,
    Callback = function(v) end,
})
```

### Colorpicker
```lua
Tab:Colorpicker({
    Title    = "ESP Color",
    Flag     = "esp_color",
    Default  = Color3.fromRGB(184, 255, 87),
    Callback = function(color) end,
})
```

### Keybind
```lua
Tab:Keybind({
    Title    = "Toggle Key",
    Flag     = "esp_key",
    Value    = Enum.KeyCode.Z,
    Callback = function(key) end,
})
```

### Group (horizontal layout)
```lua
local Group = Tab:Group({ Title = "COLOR GROUP" })
Group:Colorpicker({ Title = "Primary", ... })
Group:Colorpicker({ Title = "Secondary", ... })
```

### Label / Divider / Space
```lua
Tab:Label({ Title = "Info text", Size = 12 })
Tab:Divider()
Tab:Space(10)
```

---

## Config System

```lua
-- Flag di element → otomatis tersimpan
Tab:Toggle({ Flag = "esp_enabled", ... })

-- Simpan & load manual
Window.ConfigManager:config("default"):save()
Window.ConfigManager:config("default"):load()
```

---

## Themes

| Name | Warna |
|------|-------|
| `Dark` | Background hitam, accent hijau `#b8ff57` |
| `Midnight` | Background biru gelap, accent ungu |
| `Slate` | Background abu gelap, accent biru |

```lua
-- Custom theme
GenUI:RegisterTheme("MyTheme", {
    Accent     = Color3.fromHex("#ff6b6b"),
    Background = Color3.fromHex("#0a0a0a"),
})
Window:SetTheme("MyTheme")
```

---

## Ganti Icon Window

1. Upload gambar ke Roblox → dapat Asset ID
2. Set di `CreateWindow`:
```lua
Icon = "rbxassetid://1234567890"
```

---

## File Structure

```
GenUI/
├── dist/main.lua       ← bundle siap pakai (HttpGet ini)
├── Init.lua
├── Example.lua
├── Core/               Library, Window, Tab, Section, Group
├── Elements/           Button, Toggle, Slider, Input, Dropdown,
│                       Colorpicker, Keybind, Label, Divider
├── Systems/            Theme, Icons, Notification, Config
└── Util/               Signal, Tween, Flags, Util
```

---

## License
MIT — bebas dipakai untuk script hub pribadi maupun publik.
