--[[
    GenUI — Util/Signal.lua
    Lightweight event emitter (no Roblox dependencies)
--]]

local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({
        _connections = {}
    }, Signal)
end

function Signal:Connect(callback)
    local id = tostring(callback)
    self._connections[id] = callback
    return {
        Disconnect = function()
            self._connections[id] = nil
        end
    }
end

function Signal:Fire(...)
    for _, callback in pairs(self._connections) do
        task.spawn(callback, ...)
    end
end

function Signal:FireSync(...)
    for _, callback in pairs(self._connections) do
        callback(...)
    end
end

function Signal:Once(callback)
    local conn
    conn = self:Connect(function(...)
        conn.Disconnect()
        callback(...)
    end)
    return conn
end

function Signal:DisconnectAll()
    self._connections = {}
end

function Signal:Destroy()
    self:DisconnectAll()
end

return Signal
