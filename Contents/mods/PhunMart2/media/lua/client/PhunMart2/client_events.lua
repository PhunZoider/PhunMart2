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

Events.OnCharacterDeath.Add(function(playerObj)
    if instanceof(playerObj, "IsoPlayer") and playerObj:isLocalPlayer() then

        local wallet = Core.wallet:get(playerObj).current or {}
        local toAdd = {}

        if Core.settings.WalletDropOnDeath then
            local doAdd = false
            for k, v in pairs(wallet) do
                local currency = Core.wallet.currencies[k]
                -- skip bound entries
                if not Core.wallet.currencies[k].bound then
                    local rate = 100
                    if currency.returnRate then
                        rate = currency.returnRate
                    elseif Core.settings.WalletReturnRate then
                        rate = Core.settings.DefaultReturnRate
                    end
                    table.insert(toAdd, {
                        item = k,
                        amount = math.floor(v * (rate / 100))
                    })
                end
            end

            if #toAdd > 0 then
                local item = playerObj:getInventory():AddItem("PhunMart.DroppedWallet")
                item:setName(getText("IGUI_PhunMart_Wallet_CharsWallet", playerObj:getUsername()))
                item:getModData().PhunWallet = {
                    owner = playerObj:getUsername(),
                    wallet = toAdd
                }
            end
        end

    end
end)
