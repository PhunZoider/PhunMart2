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
    ui = {
        client = {},
        admin = {}
    },
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

local tid = nil
function Core.getCategory(item)
    -- from the awesome BetterSorting mod by Blindcoder,
    -- but modified to return the category rather than just set it

    if tid == nil then
        if TweakItemData then
            tid = TweakItemData
        else
            tid = false
        end
    end
    if tid then
        local test = TweakItemData[item:getFullName()]["DisplayCategory"] or
                         TweakItemData[item:getFullName()]["displaycategory"]
        if test then
            return test
        end
    end

    local category = tostring(item:getDisplayCategory());

    if item:getCanStoreWater() then
        if item:getTypeString() ~= "Drainable" then
            category = "Container";
        else
            category = "FoodB";
        end

    elseif item:getDisplayCategory() == "Water" then
        category = "FoodB";

    elseif item:getTypeString() == "Food" then
        if item:getDaysTotallyRotten() > 0 and item:getDaysTotallyRotten() < 1000000000 then
            category = "FoodP";
        else
            category = "FoodN";
        end

    elseif item:getTypeString() == "Literature" then
        if string.len(item:getSkillTrained()) > 0 then
            category = "LitS";
        elseif item:getTeachedRecipes() and not item:getTeachedRecipes():isEmpty() then
            category = "LitR";
        elseif item:getStressChange() ~= 0 or item:getBoredomChange() ~= 0 or item:getUnhappyChange() ~= 0 then
            category = "LitE";
        else
            category = "LitW";
        end

    elseif item:getTypeString() == "Weapon" then
        if item:getDisplayCategory() == "Explosives" or item:getDisplayCategory() == "Devices" then
            category = "WepBomb";
        end

        -- Tsar's True Music Cassette and Vinyls
    elseif string.find(item:getFullName(), "Tsarcraft.Cassette") or string.find(item:getFullName(), "Tsarcraft.Vinyl") then
        category = "MediaA";

        -- Tsar's True Actions Dance Cards
    elseif item:getTypeString() == "Normal" and item:getModuleName() == "TAD" then
        category = "Misc";
    end

    return category or "Unknown"
end

function Core.getAllItemCategories()

    if Core.itemCategories == nil then
        Core.getAllItems()
    end

    return Core.itemCategories

end

function Core.getAllItems(refresh)

    if Core.itemsAll ~= nil and not refresh then
        return Core.itemsAll
    end
    Core.itemsAll = {}
    Core.itemCategories = {}
    local catMap = {}

    local itemList = getScriptManager():getAllItems()
    for i = 0, itemList:size() - 1 do
        local item = itemList:get(i)
        if not item:getObsolete() and not item:isHidden() then

            local cat = Core.getCategory(item)
            if cat ~= "" and catMap[cat] == nil then
                catMap[cat] = true
                table.insert(Core.itemCategories, {
                    label = cat
                })
            end
            table.insert(Core.itemsAll, {
                type = item:getFullName(),
                label = item:getDisplayName(),
                texture = item:getNormalTexture(),
                category = cat
            })
        end
    end

    table.sort(Core.itemsAll, function(a, b)
        return a.label:lower() < b.label:lower()
    end)
    table.sort(Core.itemCategories, function(a, b)
        return a.label:lower() < b.label:lower()
    end)

    return Core.itemsAll
end

function Core.getAllVehicleCategories()

    if Core.vehicleCategories == nil then
        Core.getAllVehicles()
    end

    return Core.vehicleCategories

end

function Core.getAllVehicles(refresh)

    if Core.vehiclesAll ~= nil and not refresh then
        return Core.vehiclesAll
    end
    Core.vehiclesAll = {}
    Core.vehicleCategories = {}
    local catMap = {}

    local itemList = getScriptManager():getAllVehicleScripts()
    for i = 0, itemList:size() - 1 do
        local item = itemList:get(i)

        local script = itemList:get(i)
        local name = script:getName()
        local fname = script:getFileName()
        local fullName = script:getFullName()
        local text = "IGUI_VehicleName" .. name
        local label = getText(text)
        local cat = "Other"
        if string.contains(name, "Van") then
            cat = "Van"
        elseif string.contains(name, "Truck") then
            cat = "Truck"
        elseif string.contains(name, "Burnt") then
            cat = "Burnt"
        elseif string.contains(name, "Smashed") then
            cat = "Smashed"
        elseif string.contains(name, "Trailer") then
            cat = "Trailer"
        elseif string.contains(name, "Car") then
            cat = "Car"
        end

        if cat ~= "" and catMap[cat] == nil then
            catMap[cat] = true
            table.insert(Core.vehicleCategories, {
                label = cat
            })
        end
        table.insert(Core.vehiclesAll, {
            type = fullName,
            label = label,
            -- texture = item:getNormalTexture(),
            category = cat
        })

    end

    table.sort(Core.vehiclesAll, function(a, b)
        return a.label:lower() < b.label:lower()
    end)
    table.sort(Core.vehicleCategories, function(a, b)
        return a.label:lower() < b.label:lower()
    end)

    return Core.vehiclesAll
end

