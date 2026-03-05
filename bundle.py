import re, os

SRC  = "/home/claude/GenUI"
DIST = os.path.join(SRC, "dist")

ORDER = [
    ("Util/Signal",         "Util.Signal"),
    ("Util/Flags",          "Util.Flags"),
    ("Util/Tween",          "Util.Tween"),
    ("Util/Util",           "Util.Util"),
    ("Systems/Theme",       "Systems.Theme"),
    ("Systems/Icons",       "Systems.Icons"),
    ("Systems/Notification","Systems.Notification"),
    ("Systems/Config",      "Systems.Config"),
    ("Elements/Button",     "Elements.Button"),
    ("Elements/Toggle",     "Elements.Toggle"),
    ("Elements/Slider",     "Elements.Slider"),
    ("Elements/Input",      "Elements.Input"),
    ("Elements/Dropdown",   "Elements.Dropdown"),
    ("Elements/Colorpicker","Elements.Colorpicker"),
    ("Elements/Keybind",    "Elements.Keybind"),
    ("Elements/Label",      "Elements.Label"),
    ("Elements/Divider",    "Elements.Divider"),
    ("Core/Group",          "Core.Group"),
    ("Core/Section",        "Core.Section"),
    ("Core/Tab",            "Core.Tab"),
    ("Core/Window",         "Core.Window"),
    ("Core/Library",        "Core.Library"),
]

# Map short name -> full key (for resolving ambiguous requires)
SHORT_TO_FULL = {
    "Signal":       "Util.Signal",
    "Flags":        "Util.Flags",
    "Tween":        "Util.Tween",
    "Util":         "Util.Util",
    "Theme":        "Systems.Theme",
    "Icons":        "Systems.Icons",
    "Notification": "Systems.Notification",
    "Config":       "Systems.Config",
    "Button":       "Elements.Button",
    "Toggle":       "Elements.Toggle",
    "Slider":       "Elements.Slider",
    "Input":        "Elements.Input",
    "Dropdown":     "Elements.Dropdown",
    "Colorpicker":  "Elements.Colorpicker",
    "Keybind":      "Elements.Keybind",
    "Label":        "Elements.Label",
    "Divider":      "Elements.Divider",
    "Group":        "Core.Group",
    "Section":      "Core.Section",
    "Tab":          "Core.Tab",
    "Window":       "Core.Window",
    "Library":      "Core.Library",
}

def read(path):
    with open(os.path.join(SRC, path + ".lua"), "r") as f:
        return f.read()

def strip_header(src):
    return re.sub(r'^--\[\[.*?\]\]\n\n?', '', src, flags=re.DOTALL).strip()

def rewrite_requires(src):
    def replacer(m):
        arg = m.group(1)
        parts = arg.split(".")
        # Drop script.Parent.Parent... prefix
        clean = [p for i, p in enumerate(parts)
                 if not (p in {"script", "Parent"} and i < 4)]
        key = ".".join(clean)
        # Resolve short keys
        if key in SHORT_TO_FULL:
            key = SHORT_TO_FULL[key]
        # Ensure proper namespace
        for short, full in SHORT_TO_FULL.items():
            if key == short:
                key = full
                break
        return f'_G.__GenUI_modules["{key}"]'

    return re.sub(r'require\((script(?:\.\w+)+)\)', replacer, src)

os.makedirs(DIST, exist_ok=True)

lines = [
    '-- GenUI v1.0.0 | Single-file bundle',
    '-- https://github.com/yourusername/GenUI',
    '-- Usage: local GenUI = loadstring(game:HttpGet("RAW_URL/dist/main.lua"))()',
    '',
    'local cloneref = (cloneref or clonereference or function(i) return i end)',
    '_G.__GenUI_modules = _G.__GenUI_modules or {}',
    'local _m = _G.__GenUI_modules',
    '',
]

for path, key in ORDER:
    src = read(path)
    src = strip_header(src)
    src = rewrite_requires(src)
    lines += [
        f'-- ── {key} ──────────────────────────────',
        f'_m["{key}"] = (function()',
        src,
        'end)()',
        '',
    ]

lines += [
    '-- ── Entry Point ──────────────────────────────',
    'local Library = _m["Core.Library"]',
    'Library.cloneref = cloneref',
    'return Library',
]

output = "\n".join(lines)

out_path = os.path.join(DIST, "main.lua")
with open(out_path, "w") as f:
    f.write(output)

# Verify no bad refs remain
bad = re.findall(r'_G\.__GenUI_modules\["([^"]+)"\]', output)
namespaced = {k for _, k in ORDER}
wrong = [b for b in bad if b not in namespaced]
if wrong:
    print(f"⚠ Unresolved refs: {set(wrong)}")
else:
    print("✓ All module refs resolved correctly")

print(f"✓ Output: {out_path}")
print(f"✓ Lines:  {len(lines)}")
print(f"✓ Size:   {len(output)//1024} KB")
