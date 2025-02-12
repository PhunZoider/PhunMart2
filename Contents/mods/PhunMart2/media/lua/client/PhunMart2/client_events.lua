if isServer() then
    return
end
local Core = PhunMart

Events.OnIsoThumpableLoad.Add(function()
    print("PhunMart2: OnIsoThumpableLoad")
end)

Events.OnDoTileBuilding.Add(function()
    print("PhunMart2: OnDoTileBuilding")
end)

Events.OnDoTileBuilding2.Add(function()
    print("PhunMart2: OnDoTileBuilding2")
end)

Events.OnDoTileBuilding3.Add(function()
    print("PhunMart2: OnDoTileBuilding3")
end)

Events.OnDestroyIsoThumpable.Add(function()
    print("PhunMart2: OnDestroyIsoThumpable")
end)

Events.LoadGridsquare.Add(function(square)

end)

Events.OnTileRemoved.Add(function()
    print("PhunMart2: OnTileRemoved")
end)

Events.OnRainStart.Add(function()
    print("PhunMart2: OnRainStart")
end)

Events.OnRainStop.Add(function()
    print("PhunMart2: OnRainStop")
end)

Events.OnPreFillWorldObjectContextMenu.Add(function(playerObj, context, worldobjects, test)
    Core.contexts.open(playerObj, context, worldobjects, test)
end)
