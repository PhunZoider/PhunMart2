if isServer() then
    return
end

require "Map/SGlobalObject"
require "PhunMart2/client_system"
local Core = PhunMart
local ClientSystem = Core.ClientSystem
Core.ClientObject = CGlobalObject:derive("CPhunMartObject")
local ClientObject = Core.ClientObject

function ClientObject:new(luaSystem, globalObject)
    local o = CGlobalObject.new(self, luaSystem, globalObject)
    return o
end

function ClientObject:fromModData(modData)
    for k, v in pairs(modData) do
        self[k] = v
    end
end

function ClientObject:getObject()
    return self:getIsoObject()
end

function ClientObject:restock()
    ClientSystem.instance:restock(self)
end

function ClientObject:reroll(target)
    ClientSystem.instance:reroll(self, target)
end

