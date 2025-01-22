if isClient() then
    return
end
require "Map/SGlobalObjectSystem"
local Core = PhunMart
local Commands = require "PhunMart2/server_commands"
Core.ServerSystem = SGlobalObjectSystem:derive("SPhunMartSystem")
local ServerSystem = Core.ServerSystem

function ServerSystem:new()
    local o = SGlobalObjectSystem.new(self, "phunmart")
    return o
end

function ServerSystem.addToWorld(square, shop, direction)

    direction = direction or "south"
    shop.id = square:getX() .. "_" .. square:getY() .. "_" .. square:getZ()
    local isoObject = IsoThumpable.new(square:getCell(), square, "phunmart_01_1", false, {})

    shop.direction = direction
    isoObject:setModData(shop)
    isoObject:setName("PhunMartShop")
    square:AddSpecialObject(isoObject, -1)
    triggerEvent("OnObjectAdded", isoObject)
    isoObject:transmitCompleteItemToClients()

end

function ServerSystem:initSystem()
    SGlobalObjectSystem.initSystem(self)
    -- Specify GlobalObjectSystem fields that should be saved.
    self.system:setModDataKeys({})

    -- Specify GlobalObject fields that should be saved.
    -- ids = array of all shop ids that have been generated
    -- chunks = array of all chunk coordinates that have shops?
    self.system:setObjectModDataKeys({'ids', 'chunks'})
end

function ServerSystem:newLuaObjectAt(x, y, z)
    local globalObject = self.system:newObject(x, y, z)
    return self:newLuaObject(globalObject)
end
function ServerSystem:newLuaObject(globalObject)
    return Core.ServerObject:new(self, globalObject)
end

function ServerSystem:generateRandomShopOnSquare(square, direction)
    direction = direction or "south"
    local shop = Core:generateShop(square)
    if shop ~= nil then
        square:transmitRemoveItemFromSquare(true)
        self.addToWorld(square, shop, direction)
    end
end

function ServerSystem:reroll(location, target, ignoreDistance)

    local shopObj = self:getLuaObjectAt(location.x, location.y, location.z)
    local shop = Core:generateShop(location, target, ignoreDistance == true)
    shopObj:setType(shop.type)

end

function ServerSystem:rerollAll()
    for i = 1, self:getLuaObjectCount() do
        local obj = self:getLuaObjectByIndex(i)
        if obj then
            self:reroll(obj.location)
        end
    end
end

function ServerSystem:purchase(playerObj, item, location)
    local shop = self:getLuaObjectAt(location.x, location.y, location.z)
    local success, reason = shop:purchase(playerObj, item)
    if success then
        Core:addToPurchaseHistory(playerObj, item)
        sendServerCommand(playerObj, Core.name, Core.commands.buy, {
            playerIndex = playerObj:getUsername(),
            success = true,
            item = item,
            location = location

        })
    else
        -- notify user that this failed
    end
end

function ServerSystem:requestShop(playerObj, location, forceRestock)
    local shop = self:getLuaObjectAt(location.x, location.y, location.z)
    if not shop then
        print("ERROR! shop not found for " .. shop.id)
        return
    end

    if shop.lockedBy and shop.lockedBy ~= playerObj:getUsername() then
        print("ERROR! shop locked by " .. shop.lockedBy)
        return
    end

    if shop:requiresPower() then
        print("ERROR! shop requires power")
        return
    end

    if shop:requiresRestock() or forceRestock then
        -- restock before sending
        shop:restock()
    end

    shop:lock(playerObj)

    -- transmit data to client?
    -- sendServerCommand(playerObj, PM.name, PM.commands.updateShop, {
    --     id = shop.id,
    --     location = shop.location
    -- })
end

function ServerSystem:OnClientCommand(command, playerObj, args)
    if Commands[command] ~= nil then
        Commands[command](playerObj, args)
    end
end

function ServerSystem:receiveCommand(playerObj, command, args)
    Commands[command](playerObj, args)
end

SGlobalObjectSystem.RegisterSystemClass(ServerSystem)
