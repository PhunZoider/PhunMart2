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

function ClientObject:getFrontSquare()
    local front = {
        x = self.x,
        y = self.y,
        z = self.z
    }

    if self.facing == "N" then
        front.y = front.y - 1
    elseif self.facing == "W" then
        front.x = front.x - 1
    elseif self.facing == "S" then
        front.y = front.y + 1
    elseif self.facing == "E" then
        front.x = front.x + 1
    end

    return getSquare(front.x, front.y, front.z)

end

