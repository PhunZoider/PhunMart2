local allShops = require "PhunMart2/data/shops"

PhunMart = {
    name = "PhunMart",
    inied = false,
    consts = {
        shops = "PhunMart_Shops",
        players = "PhunMart_Players",
        history = "PhunMart_History",
        east = 0,
        south = 1,
        west = 2,
        north = 3,
        unpoweredEast = 4,
        unpoweredSouth = 5,
        unpoweredWest = 6,
        unpoweredNorth = 7
    },
    commands = {},
    events = {
        OnReady = "OnPhunMartOnReady"
    },
    settings = {},
    shops = allShops,
    spriteToShop = {},
    opensquares = {},
    targetSprites = {
        ["location_shop_accessories_01_29"] = "north",
        ["location_shop_accessories_01_31"] = "north",
        ["location_shop_accessories_01_17"] = "south",
        ["location_shop_accessories_01_19"] = "south",
        ["location_shop_accessories_01_16"] = "east",
        ["location_shop_accessories_01_18"] = "east",
        ["location_shop_accessories_01_30"] = "west",
        ["location_shop_accessories_01_28"] = "west",
        ["DylansRandomFurniture02_23"] = "south",
        ["DylansRandomFurniture02_22"] = "east",
        -- LC
        ["LC_Random_20"] = "south",
        ["LC_Random_23"] = "south",
        ["LC_Random_28"] = "south",
        ["LC_Random_32"] = "south",

        ["LC_Random_21"] = "east",
        ["LC_Random_22"] = "east",
        ["LC_Random_29"] = "east",
        ["LC_Random_33"] = "east",

        ["LC_Random_30"] = "north",
        ["LC_Random_34"] = "north",

        ["LC_Random_31"] = "west",
        ["LC_Random_35"] = "west"
    }
}

local Core = PhunMart
Core.isLocal = not isClient() and not isServer() and not isCoopHost()
local sb = SandboxVars
Core.settings = sb["PhunMart"]
Core.settings.ReplacementKey = "PhunMart6"
for _, event in pairs(PhunMart.events) do
    if not Events[event] then
        LuaEventManager.AddEvent(event)
    end
end

for k, v in pairs(Core.shops) do
    for _, sprite in ipairs(v.sprites) do
        Core.spriteToShop[sprite] = k
    end
    for _, sprite in ipairs(v.unpoweredSprites) do
        Core.spriteToShop[sprite] = k
    end
end

function Core:ini()
    self.inied = true
    triggerEvent(self.events.OnReady, self)
end

function Core:getPlayerData(playerObj)
    local key = nil
    if type(playerObj) == "string" then
        key = playerObj
    else
        key = playerObj:getUsername()
    end
    if key and string.len(key) > 0 then
        if not self.players then
            self.players = {}
        end
        if not self.players[key] then
            self.players[key] = {}
        end
        if not self.players[key].purchases then
            self.players[key].purchases = {}
        end
        return self.players[key]
    end
end

function Core.hasPower(square)
    if square and SandboxVars.ElecShutModifier > -1 then
        return square:haveElectricity() or GameTime:getInstance():getNightsSurvived() >
                   getSandboxOptions():getOptionByName("ElecShutModifier"):getValue()
    end
    return false
end
