local clientRuntime = {}

local clientRuntimeHolder = {}
clientRuntimeHolder.__index = clientRuntimeHolder

local _assert = {
    String = function(value)
        local valTypeOf = typeof(value)

        if valTypeOf ~= "string" then
            error(`String expected, got {valTypeOf}.`)
        end
    end,
    Function = function(value)
        local valTypeOf = typeof(value)

        if valTypeOf ~= "function" then
            error(`Function expected, got {valTypeOf}.`)
        end
    end
}

function clientRuntimeHolder:FireServer(...)
    self._ReliableRemote:FireServer(self.RemoteIndex, ...)
end

function clientRuntimeHolder:FireServerUnreliable(...)
    self._UnreliableRemote:FireServer(self.RemoteIndex, ...)
end

function clientRuntimeHolder:FireSelf(...)
    self.OnClientEvent:Fire(...)
end

--// Aseta-remote has cool "feature" where it doesn't even need to know if said remote exists,
--// Because server and client will recieve data they want to recieve while ignoring unwanted ones.

--// There is also the fact that any kind of data can be used for eventIndex, meaning for performance-intensive
--// Remotes number could be used, while for clarity string can be used, eventIndex could possibly be used for lookup table.
function clientRuntime.New(eventIndex)
    _assert.String(eventIndex)

    local _clientRuntimeHolder = setmetatable({}, clientRuntimeHolder)
    _clientRuntimeHolder._RemoteIndex = eventIndex
    _clientRuntimeHolder._ReliableRemote = clientRuntime.ReliableRemote
    _clientRuntimeHolder._UnreliableRemote = clientRuntime.UnreliableRemote

    _clientRuntimeHolder.OnClientEvent = clientRuntime.SignalModule.New()

    clientRuntime.GlobalSignal:Connect(function(_eventIndex, ...)
        if _eventIndex ~= eventIndex then
            return
        end

        _clientRuntimeHolder.OnClientEvent:Fire(...)
    end)

    return _clientRuntimeHolder
end

function clientRuntime:LoadSignalModule()
    self.SignalModule = require(self.Dependencies:WaitForChild("SignalModule"))

    self.GlobalSignal = self.SignalModule.New()
end

function clientRuntime:InitializeRemotes()
    --// In future possible optimization where instead of firing all signals I could have dictionary with string lookup
    local function onClientEvent(eventIndex, ...)
        if typeof(eventIndex) ~= "string" then
            warn(`Invalid data structure sent from server, Data:\n{eventIndex}{...}`)

            return
        end

        self.GlobalSignal:Fire(eventIndex, ...)
    end

    self.ReliableRemote["OnClientEvent"]:Connect(onClientEvent)
    self.UnreliableRemote["OnClientEvent"]:Connect(onClientEvent)
end

function clientRuntime:Load(dict)
    for index, value in dict do
        self[index] = value
    end

    self:LoadSignalModule()
    self:InitializeRemotes()

    return clientRuntime
end

return clientRuntime