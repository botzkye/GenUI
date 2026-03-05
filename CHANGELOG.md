# GenUI Changelog

## v1.0.0 — Initial Release

### Core
- `GenUI:CreateWindow()` — main window dengan sidebar + content panel
- `GenUI:Notify()` — toast notification queue
- `GenUI:Popup()` — modal popup dialog
- `GenUI:RegisterTheme()` — custom theme registration
- `Window:Tab()`, `Window:Section()` — navigasi
- `Window:SetTheme()`, `Window:SetUIScale()`, `Window:SetToggleKey()`
- Draggable window via topbar
- Keyboard toggle (default: RightShift)

### Elements
- **Button** — color accent, icon, justify, highlight, lock/unlock
- **Toggle** — Switch & Checkbox type, animated
- **Slider** — step, tooltip, icons, drag interaction
- **Input** — single line & Textarea, focus highlight
- **Dropdown** — simple & advanced mode, multi-select, divider, refresh
- **Colorpicker** — hex input, swatch preview
- **Keybind** — click-to-capture key input
- **Label** — static text, configurable size/color/align
- **Divider** — horizontal separator
- **Space** — vertical spacing helper

### Systems
- **Theme** — token-based, 3 built-in themes (Dark, Midnight, Slate)
- **Icons** — named set resolver, custom set support
- **Notification** — animated toast queue, auto-dismiss
- **Config** — save/load Flag states as JSON, AutoLoad support

### Util
- **Signal** — lightweight event emitter
- **Tween** — TweenService wrapper with UI presets
- **Flags** — global element registry
- **Util** — helpers: create, corner, padding, listLayout, stroke, JSON
