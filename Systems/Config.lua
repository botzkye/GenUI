--[[
    GenUI — Systems/Config.lua
    Save and load element states via Flag keys.
    Files stored at: [Folder]/GenUI/configs/[name].json
--]]

local Util  = require(script.Parent.Parent.Util.Util)
local Flags = require(script.Parent.Parent.Util.Flags)

-- ── ConfigEntry ───────────────────────────────────────────────────────────────

local ConfigEntry = {}
ConfigEntry.__index = ConfigEntry

function ConfigEntry.new(manager, name)
    return setmetatable({
        _manager  = manager,
        _name     = name,
        AutoLoad  = false,
    }, ConfigEntry)
end

function ConfigEntry:_path()
    return self._manager._folder .. "/configs/" .. self._name .. ".json"
end

-- Save current flag states to file
function ConfigEntry:save()
    if not writefile then
        warn("[GenUI:Config] writefile not available")
        return false
    end

    local data = {}
    for flag, element in pairs(Flags.all()) do
        local ok, value = pcall(function() return element:Get() end)
        if ok then
            -- Serialize Color3 specially
            if typeof(value) == "Color3" then
                data[flag] = {
                    _type = "Color3",
                    r = value.R, g = value.G, b = value.B
                }
            else
                data[flag] = value
            end
        end
    end

    local ok, err = pcall(function()
        writefile(self:_path(), Util.toJSON(data))
    end)

    if not ok then
        warn("[GenUI:Config] Failed to save '" .. self._name .. "': " .. tostring(err))
        return false
    end

    return true
end

-- Load flag states from file and apply to elements
function ConfigEntry:load()
    if not readfile or not isfile then
        warn("[GenUI:Config] readfile/isfile not available")
        return false
    end

    if not isfile(self:_path()) then
        warn("[GenUI:Config] Config '" .. self._name .. "' not found")
        return false
    end

    local raw
    local ok, err = pcall(function()
        raw = readfile(self:_path())
    end)

    if not ok then
        warn("[GenUI:Config] Failed to read '" .. self._name .. "': " .. tostring(err))
        return false
    end

    local data = Util.fromJSON(raw)

    for flag, value in pairs(data) do
        local element = Flags.get(flag)
        if element then
            -- Deserialize Color3
            if type(value) == "table" and value._type == "Color3" then
                value = Color3.new(value.r, value.g, value.b)
            end

            local setOk, setErr = pcall(function()
                element:Set(value)
            end)

            if not setOk then
                warn("[GenUI:Config] Failed to apply flag '" .. flag .. "': " .. tostring(setErr))
            end
        end
    end

    return true
end

-- Delete this config file
function ConfigEntry:delete()
    if not delfile or not isfile then return false end
    if isfile(self:_path()) then
        pcall(delfile, self:_path())
    end
    return true
end

-- Set auto-load for this config
function ConfigEntry:setAutoLoad(enabled)
    self.AutoLoad = enabled
    -- Persist auto-load preference in a meta file
    if writefile then
        local metaPath = self._manager._folder .. "/configs/_autoload.json"
        local meta = {}

        if isfile and isfile(metaPath) then
            local ok, raw = pcall(readfile, metaPath)
            if ok then meta = Util.fromJSON(raw) end
        end

        meta[self._name] = enabled

        pcall(writefile, metaPath, Util.toJSON(meta))
    end
end

-- ── ConfigManager ─────────────────────────────────────────────────────────────

local ConfigManager = {}
ConfigManager.__index = ConfigManager

function ConfigManager.new(folder)
    local self = setmetatable({}, ConfigManager)
    self._folder  = folder
    self._configs = {}

    -- Ensure folder exists
    if makefolder and not isfolder then
        pcall(makefolder, folder)
        pcall(makefolder, folder .. "/configs")
    elseif makefolder and isfolder then
        if not isfolder(folder) then
            makefolder(folder)
        end
        if not isfolder(folder .. "/configs") then
            makefolder(folder .. "/configs")
        end
    end

    return self
end

-- Get or create a config by name
function ConfigManager:config(name)
    name = name or "default"
    if not self._configs[name] then
        self._configs[name] = ConfigEntry.new(self, name)
    end
    return self._configs[name]
end

-- List all saved config names
function ConfigManager:allConfigs()
    local names = {}
    if not listfiles or not isfile then return names end

    local ok, files = pcall(listfiles, self._folder .. "/configs")
    if not ok then return names end

    for _, path in ipairs(files) do
        -- Extract filename without extension
        local name = path:match("([^/\\]+)%.json$")
        if name and name ~= "_autoload" then
            table.insert(names, name)
        end
    end

    table.sort(names)
    return names
end

-- Get raw data of a saved config (without loading it)
function ConfigManager:getConfig(name)
    if not readfile or not isfile then return {} end
    local path = self._folder .. "/configs/" .. name .. ".json"
    if not isfile(path) then return {} end
    local ok, raw = pcall(readfile, path)
    return ok and Util.fromJSON(raw) or {}
end

-- Get the names of configs with AutoLoad enabled
function ConfigManager:getAutoLoadConfigs()
    if not readfile or not isfile then return {} end
    local metaPath = self._folder .. "/configs/_autoload.json"
    if not isfile(metaPath) then return {} end
    local ok, raw = pcall(readfile, metaPath)
    if not ok then return {} end
    local meta = Util.fromJSON(raw)
    local names = {}
    for name, enabled in pairs(meta) do
        if enabled then table.insert(names, name) end
    end
    return names
end

-- Auto-load any configs marked for auto-load
function ConfigManager:runAutoLoad()
    for _, name in ipairs(self:getAutoLoadConfigs()) do
        self:config(name):load()
    end
end

return ConfigManager
