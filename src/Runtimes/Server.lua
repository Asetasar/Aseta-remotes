local serverRuntime = {}

local serverRuntimeHolder = {}
serverRuntimeHolder.__index = serverRuntimeHolder

local KICK_UPON_INVALID_DATA = false

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

function serverRuntimeHolder:FireClient(player, ...)
    self._ReliableRemote:FireClient(player, self._RemoteIndex, ...)
end

function serverRuntimeHolder:FireAllClients(...)
    self._ReliableRemote:FireAllClients(self._RemoteIndex, ...)
end

function serverRuntimeHolder:FireClientUnreliable(player, ...)
    self._UnreliableRemote:FireClient(player, self._RemoteIndex, ...)
end

function serverRuntimeHolder:FireAllClientsUnreliable(...)
    self._UnreliableRemote:FireClient(self._RemoteIndex, ...)
end

function serverRuntime.New(eventIndex)
    _assert.String(eventIndex)

    local _serverRuntimeHolder = setmetatable({}, serverRuntimeHolder)
    _serverRuntimeHolder._RemoteIndex = eventIndex
    _serverRuntimeHolder._ReliableRemote = serverRuntime.ReliableRemote
    _serverRuntimeHolder._UnreliableRemote = serverRuntime.UnreliableRemote

    _serverRuntimeHolder.OnServerEvent = serverRuntime.SignalModule.New()

    serverRuntime.GlobalSignal:Connect(function(_eventIndex, ...)
        if _eventIndex ~= eventIndex then
            return
        end

        _serverRuntimeHolder.OnServerEvent:Fire(...)
    end)

    return _serverRuntimeHolder
end

function serverRuntime:LoadSignalModule()
    self.SignalModule = require(self.Dependencies:WaitForChild("SignalModule"))

    self.GlobalSignal = self.SignalModule.New()
end

function serverRuntime:InitializeRemotes()
    --// In future possible optimization where instead of firing all signals I could have dictionary with string lookup
    local function onServerEvent(player, eventIndex, ...)
        if typeof(eventIndex) ~= "string" then
            warn(`Invalid data structure sent from client, Data:\n{eventIndex}{...}`)

            if KICK_UPON_INVALID_DATA then
                player:Kick("Invalid data structure recieved by server.")
            end

            return
        end

        self.GlobalSignal:Fire(eventIndex, player, ...)
    end

    self.ReliableRemote["OnServerEvent"]:Connect(onServerEvent)
    self.UnreliableRemote["OnServerEvent"]:Connect(onServerEvent)
end

function serverRuntime:Load(dict)
    for index, value in dict do
        self[index] = value
    end

    self:LoadSignalModule()
    self:InitializeRemotes()

    return serverRuntime
end

return serverRuntime