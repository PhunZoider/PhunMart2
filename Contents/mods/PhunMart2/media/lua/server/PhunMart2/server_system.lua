if isClient() then
    return
end
require "Map/SGlobalObjectSystem"
local Core = PhunMart
local PL = PhunLib
local Commands = require "PhunMart2/server_commands"
Core.ServerSystem = SGlobalObjectSystem:derive("SPhunMartSystem")
local ServerSystem = Core.ServerSystem

function ServerSystem:new()
    local o = SGlobalObjectSystem.new(self, "phunmart")

    local shops = {"NONE", "GoodPhoods", "PhatPhoods", "PittyTheTool", "FinalAmmendment", "WrentAWreck",
                   "MichellesCrafts", "CarAParts", "TraiterJoes", "CSVPharmacy", "RadioHacks", "Phish4U", "HoesNMoes",
                   "BudgetXPerience", "GiftedXPerience", "LuxuryXPerience", "HardWear", "Collectors", "Travelers",
                   "ShedsAndCommoners"}

    self.spritesToShop = {}
    for i = 1, 3 do
        for i = 1, 63 do

        end
    end

    return o
end

function ServerSystem:removeLuaObject(luaObject)
    Core:removeInstance(luaObject)
    SGlobalObjectSystem.removeLuaObject(self, luaObject)
end

function ServerSystem:removeInvalidInstanceData()

    local checked = {}
    local instanceCount = 0
    for k, v in pairs(Core.instances) do
        checked[k] = true
        instanceCount = instanceCount + 1
    end
    local objectCount = 0
    for i = 1, self:getLuaObjectCount() do
        local obj = self:getLuaObjectByIndex(i)
        checked[obj.x .. "_" .. obj.y .. "_" .. obj.z] = nil
        objectCount = objectCount + 1
    end
    local removed = 0
    for k, v in pairs(checked) do
        Core.instances[k] = nil
        removed = removed + 1
    end
    print("Removed " .. tostring(removed) .. " invalid instances")

end

function ServerSystem.addToWorld(square, shop, direction)
    local index = 4
    if direction == "E" then
        index = 1
    elseif direction == "S" then
        index = 2
    elseif direction == "W" then
        index = 3
    end
    local sprite = Core.shops[shop].sprites[index]
    local isoObject = IsoThumpable.new(square:getCell(), square, sprite, false, {})
    ServerSystem.initializeShopObject(isoObject)
    square:AddSpecialObject(isoObject, -1)
    triggerEvent("OnObjectAdded", isoObject)
    isoObject:transmitCompleteItemToClients()

end

function ServerSystem.initializeShopObject(obj)
    obj:setName("PhunMartVendingMachine")
    local data = {
        type = obj:getSprite():getProperties():Val("CustomName"),
        facing = obj:getSprite():getProperties():Val("Facing"),
        created = GameTime:getInstance():getWorldAgeHours(),
        x = obj:getX(),
        y = obj:getY(),
        z = obj:getZ()
    }
    obj:setModData(data)
    Core:addInstance(data)
end

function ServerSystem:initSystem()
    SGlobalObjectSystem.initSystem(self)
    -- Specify GlobalObjectSystem fields that should be saved.
    self.system:setModDataKeys({})

    -- Specify GlobalObject fields that should be saved.
    -- ids = array of all shop ids that have been generated
    -- chunks = array of all chunk coordinates that have shops?
    self.system:setObjectModDataKeys({'type', 'facing', 'created', 'x', 'y', 'z'})
end

function ServerSystem:isValidIsoObject(isoObject)

    local name = isoObject:getName()
    local texture = isoObject:getTextureName()
    print("*** isValidIsoObject " .. tostring(name) .. " " .. tostring(texture))
    return name == "PhunMartVendingMachine"
end

function ServerSystem:newLuaObjectAt(x, y, z)
    local globalObject = self.system:newObject(x, y, z)
    return self:newLuaObject(globalObject)
end
function ServerSystem:newLuaObject(globalObject)
    print("*** newLuaObjectAt")
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
    local shop2 = self:getIsoObjectAt(location.x, location.y, location.z)

    local fred = type(shop.setType)
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

function ServerSystem:openShop(player, args, forceRestock)
    local shop = self:getLuaObjectAt(args.x, args.y, args.z)
    local shop2 = self:getIsoObjectAt(args.x, args.y, args.z)
    if not shop then
        print("ERROR! shop not found for " .. shop.id)
        self:sendCommand(player, Core.commands.openError, {
            id = shop.id,
            location = shop.location,
            error = "shopNotFound"
        })
        return
    end

    if shop:requiresPower() then
        self:sendCommand(player, Core.commands.openError, {
            id = shop.id,
            location = shop.location,
            error = "requiresPower"
        })
        print("ERROR! shop requires power")
        return
    end

    if shop:requiresRestock() or forceRestock then
        -- restock before sending
        shop:restock()
    end

    if Core.isLocal then
        Core:updateInstanceInventory(shop:getKey(), self:getInventoryForShop(shop))
    else
        sendServerCommand(player, Core.name, Core.commands.requestShop, {
            key = shop:getKey(),
            data = self:getInventoryForShop(shop)
        })
    end

end

function ServerSystem:getInventoryForShop(shop)

    local key = shop:getKey()
    return {
        key = key,
        items = 1
    }
end

function ServerSystem:getLoadedObjects()
    local result = {}
    for i = 1, self:getLuaObjectCount() do
        local obj = self:getLuaObjectByIndex(i)
        if obj and obj.key then
            table.insert(result, obj)
        end
    end
    return result
end

function ServerSystem:closestShopKeysTo(x, y)

    local shops = {}
    for k, v in pairs(Core.shops) do
        if Core.settings["ShopProbability" .. k] > 0 then
            -- set default distance to max per group
            shops[k] = 9999999
        end
    end

    for i = 1, self.system:getObjectCount() do
        local obj = self.system:getObjectByIndex(i)
        if obj then
            local data = obj:getModData()
            local dx = x - obj.x
            local dy = y - obj.y
            local distance = math.sqrt(dx * dx + dy * dy)
            local shop = Core.shops[data.key]
            if distance < shops[data.key] then
                shops[data.key] = distance
            end
        end
    end
    return shops

end

-- returns a random shop key based on x,y location based on its probability
-- it will omit shops that are disabled and whose group/type would be too close to one another
function ServerSystem:getRandomShop(x, y)

    local options = Core:getInstanceDistancesFrom(x, y)
    local candidates = {}

    local shops = Core.shops
    local totalProbability = 0
    -- remove options that are too close to each other
    for k, v in pairs(options) do
        if shops[k].enabled ~= false and Core.settings["ShopProbability" .. k] > 0 then
            local key = "MinDistance" .. k
            local sets = Core.settings
            print("Checking " .. k .. " " .. tostring(v) .. " " .. tostring(sets[key]) .. " " ..
                      tostring(sets[key] <= v))
            if Core.settings["MinDistance" .. k] <= v then
                table.insert(candidates, {
                    shop = k,
                    p = Core.settings["ShopProbability" .. k]
                })
                totalProbability = totalProbability + Core.settings["ShopProbability" .. k]
            end

        end
    end

    if #candidates == 0 then
        return nil
    end

    local r = ZombRand(totalProbability) + 1
    local sum = 0
    for _, v in ipairs(candidates) do
        sum = sum + v.p
        if sum >= r then
            return v.shop
        end
    end

end

function ServerSystem:getShopList()
    local shops = {}
    for k, v in pairs(Core.shops) do
        table.insert(shops, {
            key = k,
            label = getTextOrNull("IGUI_PhunMart_Shop_" .. k) or k,
            group = v.group or "NONE",
            enabled = v.enabled == false and "false" or "true"
        })
    end
end

function ServerSystem:getShopData(key)

    local shop = Core.shops[key]
    if not shop then
        return nil
    end
    return PL.table.deepCopy(shop)
end

function ServerSystem:updateShopData(data)

    local shop = Core.shops[data.key]
    if not shop then
        return
    end
    for k, v in pairs(data) do
        shop[k] = v
    end

end

function ServerSystem:checkObjectAdded(obj)
    if obj and obj.getSprite then
        local customName = obj:getSprite():getProperties():Val("CustomName")
        if customName and Core.shops[customName] then
            if not self:isValidIsoObject(obj) then
                -- is a shop sprite but not an instance?
                self.initializeShopObject(obj)
            end
        end
    end
end

function ServerSystem:loadGridsquare(square)

    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        -- is this sprite a shop
        local customName = obj:getSprite():getProperties():Val("CustomName")

        if customName and Core.shops[customName] then
            -- registered already, but check if it is valid?
            if not self:isValidIsoObject(obj) then
                -- not valid, remove it
                local facing = obj:getSprite():getProperties():Val("Facing")
                square:transmitRemoveItemFromSquare(obj)
                self.addToWorld(square, customName, facing)

            end
        elseif customName == "Machine" then
            -- this could be a vendinng machine we want to convert?
            local type = obj:getSprite():getProperties():Val("container")
            if type == "vendingpop" or type == "vendingsnack" then
                -- has it already been tested?
                local modData = obj:getModData()
                if not modData.PhunMart then
                    modData.PhunMart = {}
                end
                if modData.PhunMart.replacementKey ~= Core.settings.ReplacementKey then
                    modData.PhunMart.replacementKey = Core.settings.ReplacementKey
                    if Core.settings.ChanceToConvertVanillaMachines > 0 then
                        local chance = ZombRand(100)
                        if chance <= Core.settings.ChanceToConvertVanillaMachines then
                            local shopname = self:getRandomShop(square:getX(), square:getY())
                            if shopname then
                                local facing = obj:getSprite():getProperties():Val("Facing")
                                square:transmitRemoveItemFromSquare(obj)
                                self.addToWorld(square, shopname, facing)
                            end
                        end
                    end
                end
            end
        end
    end
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
