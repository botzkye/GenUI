# GenUI Changelog

## v1.1.0 — Bug Fix & Polish Update

### Bug Fixes
- **Window corners** — semua 4 sudut window sekarang melengkung dengan benar menggunakan teknik fix-frame
- **Dropdown** — popup di-parent ke ScreenGui langsung sehingga tidak ter-clip; klik area kosong tidak lagi membuka dropdown; click-away berfungsi dengan benar
- **Layar hitam transparan** — shadow frame yang salah ter-parent ke ScreenGui sudah dihapus
- **Search bar tertutup** — ZIndex dinaikkan agar tidak tertutup fix-frame
- **Input focus stroke** — UIStroke tidak lagi dibuat ulang setiap focus, sekarang reuse dan di-tween warnanya
- **Padding tidak presisi** — semua element sekarang pakai `AutomaticSize.Y` dengan padding equal atas/bawah
- **Stroke frame** — UIStroke window dipindah ke frame sibling agar tidak ter-clip oleh root
- **Drag ghost** — strokeFrame sekarang ikut bergerak saat window di-drag

### New Features
- **Minimize → Icon Button** — klik tombol minimize sekarang menyembunyikan window dan memunculkan tombol ikon kecil yang bisa di-drag, klik untuk buka kembali
- `Window:Open()` — method baru untuk buka window secara programmatic

### Visual
- TopbarBg sedikit lebih terang dari Background agar fix-frame bekerja
- Control buttons (minimize/close) sekarang fill warna saat hover

---

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
