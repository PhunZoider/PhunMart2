if isClient() then
    return
end
require "PhunMart2/core"
local Core = PhunMart

Events.OnServerStarted.Add(function()
    Core:ini()
end)

Events.OnIsoThumpableLoad.Add(function()
    print("PhunMart2 (server): OnIsoThumpableLoad")
end)

Events.OnIsoThumpableLoad.Add(function()
    print("PhunMart2 (server): OnIsoThumpableLoad")
end)

Events.OnDoTileBuilding.Add(function()
    print("PhunMart2 (server): OnDoTileBuilding")
end)

Events.OnDoTileBuilding2.Add(function()
    print("PhunMart2 (server): OnDoTileBuilding2")
end)

Events.OnDoTileBuilding3.Add(function()
    print("PhunMart2 (server): OnDoTileBuilding3")
end)

Events.OnDestroyIsoThumpable.Add(function()
    print("PhunMart2 (server): OnDestroyIsoThumpable")
end)

Events.LoadGridsquare.Add(function(square)
    Core.ServerSystem.instance:loadGridsquare(square)
end)

Events.OnTileRemoved.Add(function()
    print("PhunMart2 (server): OnTileRemoved")
end)

Events.OnRainStart.Add(function()
    print("PhunMart2 (server): OnRainStart")
end)

Events.OnRainStop.Add(function()
    print("PhunMart2 (server): OnRainStop")
end)

Events.OnPlayerMove.Add(function()
    print("PhunMart2 (server): OnPlayerMove")
end)
