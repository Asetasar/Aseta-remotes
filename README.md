# Aseta-remotes

Simple yet powerful remote wrapper into master remote structure with emphasis on ease of use.

### Why?

* This module was created as part of [Asetasar framework](https://github.com/Asetasar/Asetasar-Framework) where it is one of the recommended ways to approach networking.
* Roblox development is filled with nonsensical, overcomplicated systems for very marginal improvement on performance, with its only performance mainly being able to spam thousands of events in the remote optimization scene.
* Roblox handles usage of multiple remotes badly.
* I wanted my own module where I know that the quality of code won't hinder rest of the project.

### Benefits from usage of this module

* **No complicated setup**: Aseta remotes are used the same way as normal remoteEvents are, syntax matches roblox's default syntax, meaning replacing existing remotes is as difficult as requiring the module and doing .New instead of WaitForChild.
* **Easy use of URE**: Usage of unreliable remote events in Aseta-remotes is as simple as instead of calling methods :FireServer(), :FireServerUnreliable().
* **Optimized signal handling**: Aseta remotes uses optimized [Aseta signals](https://github.com/Asetasar/Aseta-signals) which is generally more consistent that implementation from roblox and has no restriction on who can :Fire it.
* **FireSelf**: Option in which you can essentially fire remote events from client-side to client-side and vise-versa with server, being able to achieve cross-script communication even without the use of Asetasar framework.
* **Dynamic approach to event indexes**: Because of Aseta remotes masterRemote approach, event indexes are a must and the type of index which is necessary is not specified, meaning you can use integers with small size where heavy traffic happens, while being able to use strings where readibility matters.
* **Simplicity**: Everything has been achieved with least amount of code and without implementing any unnecessary bloatware

### Future plans

* Add data compression for fun, because it is not really necessary but I want to create my own algorythms for compression.
* Add additional debugging features

## How to use

*Creation of class*

```lua
local remoteEvent = asetaRemoteModule.New("Combat") : dictionary


--// Returns OOP class dictionary
```

*Essential usage*

*Client*

```lua
local remoteEvent = asetaRemoteModule.New("Combat")

--// Connections >

local function onClientEvent(damageRecieved, doVisualDamage)
--// Processing!
end

remoteEvent["OnClientEvent"]:Connect(onClientEvent)

--// Firing to server >

remoteEvent:FireServer(321, true)
remoteEvent:FireServerUnreliable(Vector.one * 6)

--// Firing self

remoteEvent:FireSelf(321, false)
--// Triggers OnClientEvent connection.

```
*Server*

```lua
local remoteEvent = asetaRemoteModule.New("Combat")

--// Connections >

local function onServerEvent(player, damageRecieved, doVisualDamage)
--// Processing!
end

remoteEvent["OnServerEvent"]:Connect(onClientEvent)

--// Firing to server >

remoteEvent:FireAllClients(324, true)
remoteEvent:FireAllClientsUnreliable(Vector.one * 2)

--// Firing self

remoteEvent:FireSelf(_, 321, true)
--// Triggers OnServerEvent connection.


```