if isClient() then
    return
end

require "Map/SGlobalObject"
require "PhunMart2/server_system"
local Core = PhunMart
local ServerSystem = Core.ServerSystem
Core.ServerObject = SGlobalObject:derive("SPhunMartObject")
local ServerObject = Core.ServerObject

-- all valid property and default values
local fields = {
    type = {
        -- a unique key to identify this shop type (eg shop-good-phoods)
        type = "string",
        default = "default"
    },
    label = {
        -- textual name of shop
        type = "string",
        default = "PhunMart Shop"
    },
    id = {
        -- a unique key to identify this instance (eg 0_0_0)
        type = "string",
        default = "default"
    },
    group = {
        -- a name to group this type of shop. eg. FOODS or TOOLS which is used by distance property
        type = "string",
        default = "default"
    },
    distance = {
        -- minimum distance from another shop of the same group
        type = "number",
        default = 100
    },

    probability = {
        -- probability of this shop spawning
        type = "number",
        default = 15
    },
    filters = {
        -- array of filters to apply to qualifying this shop
        type = "array",
        default = {}
    },
    reroll = {
        -- number of ingame days between rerolling type of shop
        type = "number",
        default = 0
    },
    created = {
        -- ingame date and time of instantiation
        type = "number",
        default = 0
    },
    fills = {
        -- number of items to stock
        type = "range",
        default = {
            min = 5,
            max = 10
        }
    },

    powered = {
        -- does this shop require power
        type = "bool",
        default = false
    },
    restock = {
        -- number of ingame days between regenerating inventory
        type = "number",
        default = 48
    },
    lastRestocked = {
        -- the last time this shop was stocked (ingame days)
        type = "number",
        default = 0
    },
    items = {
        -- array of items currently in inventory
        type = "array",
        default = {}
    },
    pools = {
        -- array of pools to generate inventory from
        type = "array",
        default = {}
    },

    currency = {
        -- default type of currency if none is specified
        type = "string",
        default = "Base.Money"
    },
    basePrice = {
        -- default price for items
        type = "number",
        default = 1
    },
    image = {
        -- background image for the shop
        type = "string",
        default = "machine-none.png"
    },
    sprites = {"phunmart_01_0", -- east
    "phunmart_01_1", -- south
    "phunmart_01_2", -- west
    "phunmart_01_3", -- north
    "phunmart_01_4", -- unpowered east
    "phunmart_01_5", -- unpowered south
    "phunmart_01_6", -- unpowered west
    "phunmart_01_7" -- unpowered north
    }

}

function ServerObject:new(luaSystem, globalObject)
    local o = ServerObject.new(self, luaSystem, globalObject)
    return o
end

function ServerObject:initNew()
    for k, v in pairs(fields) do
        self[k] = v.default
    end
end

-- init modData with default values
function ServerObject.initModData(modData)
    for k, v in pairs(fields) do
        if modData[k] == nil and self[k] == nil then
            modData[k] = v.default
        end
    end
end

function ServerObject:fromModData(modData)
    for k, v in pairs(modData) do
        if fields[k] then
            self[k] = fields[k].type == "number" and tonumber(v) or v
        end
    end
end

function ServerObject:stateFromIsoObject(isoObject)
    self:initNew() -- initialize with default values
    self:fromModData(isoObject:getModData()) -- populate with objects modData
    self:updateSprite() -- update sprite if needed
    isoObject:transmitModData() -- send to clients
end

function ServerObject:unlock()
    self.lockedBy = false
    self:saveData()
    Core.ServerSystem.instance:removeShopIdLockData(self)
end

function ServerObject:lock(player)
    self.lockedBy = player:getUsername()
    self:saveData()
end

function ServerObject:requiresPower()
    local isOk = true
    if self.powered then
        isOk = self:getSquare():haveElectricity()
        if not isOk then
            return SandboxVars.ElecShutModifier > -1 and GameTime:getInstance():getNightsSurvived() <
                       SandboxVars.ElecShutModifier
        end
    end
    return isOk
end

function ServerObject:updateSprite(force)

    local isoObject = self:getIsoObject()
    if not isoObject then
        return
    end

    local def = PM.defs.shops[self.key]
    local hasPower = true
    local spriteKey = "working"

    if self.powered then
        hasPower = self:getSquare():haveElectricity()
        if not hasPower then
            hasPower = SandboxVars.ElecShutModifier > -1 and GameTime:getInstance():getNightsSurvived() <
                           SandboxVars.ElecShutModifier
            if not hasPower then
                spriteKey = "nopower"
            end
        end
    end

    local current = isoObject:getSprite()
    -- default to north
    local now = self.sprites[spriteKey].north
    if self.direction == 0 then
        -- east
        now = self.sprites[spriteKey].east
    elseif self.direction == 1 then
        -- south
        now = self.sprites[spriteKey].south
    elseif self.direction == 2 then
        -- west
        now = self.sprites[spriteKey].west
    end

    if current ~= now then
        isoObject:setSprite(now)
        isoObject:transmitUpdatedSpriteToClients()
    end

end

function ServerObject:setType(type)
    -- generate from definitions
    self:changeSprite(true)
    self:saveData()

end

function ServerObject:requiresRestock()
    local lastRestocked = self.lastRestock or 0
    local frequency = self.restock or 24
    local now = GameTime:getInstance():getWorldAgeHours()
    local hoursSinceLastRestock = now - lastRestocked
    local times = math.floor(hoursSinceLastRestock / frequency)
    local newRestock = lastRestocked + (times * frequency)
    if now > (lastRestocked * frequency) then
        return false
    end
    return true
end

-- regenerate inventory
function ServerObject:restock()

    local lastRestocked = self.lastRestock or 0
    local frequency = self.restock or 24
    local now = GameTime:getInstance():getWorldAgeHours()
    local hoursSinceLastRestock = now - lastRestocked
    local times = math.floor(hoursSinceLastRestock / frequency)
    local newRestock = lastRestocked + (times * frequency)
    self.lastRestocked = newRestock
    self:saveData()
end

-- check to ensure we are setup correctly and restock if needed
function ServerObject:validate()

end

function ServerObject:purchase(playerObj, item, qty)

    qty = qty or 1

    if self.lockedBy ~= playerObj:getUsername() then
        return false, "Shop is locked by someone else"
    end

    if self:requiresPower() then
        return false, "Shop is out of power"
    end

    if not self.items[item] then
        return false, "Shop does not have item"
    end

    if not self.items[item].inventory ~= false then
        if self.items[item].inventory < qty then
            return false, "Shop does not have enough inventory"
        end
    end

    self.items[item].inventory = self.items[item].inventory - qty
    self:saveData()
    return true, "Purchase successful"

end
