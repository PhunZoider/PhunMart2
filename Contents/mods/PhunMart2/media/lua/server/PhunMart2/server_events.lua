require "PhunMart2/core"
local Core = PhunMart

Events.OnServerStarted.Add(function()
    Core:ini()
end)
