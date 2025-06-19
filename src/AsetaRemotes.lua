local RunService = game:GetService("RunService")

local runtimeType = RunService:IsServer() and "Server" or "Client"

local passThroughDict = {
    Dependencies = script:WaitForChild("Dependencies"),
    ReliableRemote = script:WaitForChild("MasterRemote"),
    UnreliableRemote = script:WaitForChild("UnreliableMasterRemote")
}

return require(`@self/Runtimes/{runtimeType}`):Load(passThroughDict)
