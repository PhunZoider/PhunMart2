if isClient() then
    return
end

local Core = PhunMart
local PL = PhunLib
local Commands = {}

Commands[Core.commands.getBlackList] = function(args)
    local player = PL.getPlayerByUsername(args.username)
    if player then
        Core.ui.poolBlacklist.OnOpenPanel(player, args.data)
    end
end

Commands[Core.commands.serverPurchaseFailed] = function(arguments)
    local player = getSpecificPlayer(arguments.playerIndex)
    local name = player:getUsername()
    local w = 300
    local h = 150
    local message = getTextOrNull("IGUI_PhunMart.Error." .. arguments.message) or arguments.message
    local modal = ISModalDialog:new(getCore():getScreenWidth() / 2 - w / 2, getCore():getScreenHeight() / 2 - h / 2, w,
        h, message, false, nil, nil, nil);
    modal:initialise()
    modal:addToUIManager()

end

Commands[Core.commands.requestLock] = function(arguments)
    local shop = Core.ClientSystem.instance:getLuaObjectAt(arguments.location.x, arguments.location.y,
        arguments.location.z)
    shop:updateFromIsoObject()
end

Commands[Core.commands.updateHistory] = function(arguments)
    local player = getSpecificPlayer(arguments.playerIndex)
    Core.players[player:getUsername()] = arguments.history
end

Commands[Core.commands.buy] = function(arguments)
    Core:completeTransaction(arguments)
end

Commands[Core.commands.payWithInventory] = function(arguments)
    local player = getSpecificPlayer(arguments.playerIndex)
    for _, v in ipairs(arguments.items) do
        local item = getScriptManager():getItem(v.name)
        for i = 1, v.value do
            local inv = player:getInventory()
            local target = inv:getItemFromTypeRecurse(v.name)
            target:getContainer():DoRemoveItem(target)
        end
    end
end

Commands[Core.commands.closeAllShops] = function()
    for _, v in pairs(PhunMartShopWindow.instances) do
        v:close()
    end
end

Commands[Core.commands.closeShop] = function(arguments)
    for _, v in pairs(PhunMartShopWindow.instances) do
        if v.shopObj.id == arguments.shopId then
            v:close()
        end
    end
end

Commands[Core.commands.updateShop] = function(arguments)
    CPhunMartSystem.instance:updateShop(arguments.location)
end

Commands[Core.commands.modifyTraits] = function(arguments)
    local player = getSpecificPlayer(arguments.playerIndex)
    for _, v in ipairs(arguments.items) do
        local item = getScriptManager():getItem(v.name)
        for i = 1, v.value do
            local inv = player:getInventory()
            local target = inv:getItemFromTypeRecurse(v.name)
            target:getContainer():DoRemoveItem(target)
        end
    end
end

Commands[Core.commands.requestShopDefs] = function(arguments)
    Core.defs.shops = arguments.shops
    triggerEvent(Core.events.OnShopDefsReloaded, arguments.shops)
end

Commands[Core.commands.requestItemDefs] = function(arguments)

    print("Receiving ", arguments.row, " of ", arguments.totalRows)

    if arguments.firstSend then
        Core.defs.items = arguments.items
    else
        for k, v in pairs(arguments.items) do
            Core.defs.items[k] = v
        end
    end

    if arguments.completed then
        triggerEvent(Core.events.OnShopItemDefsReloaded, Core.defs.items)
        print("Received all item defs")
    end
end

Commands[Core.commands.requestLocations] = function(args)
    triggerEvent(Core.events.OnShopLocationsReceived, args.locations)
end

return Commands
