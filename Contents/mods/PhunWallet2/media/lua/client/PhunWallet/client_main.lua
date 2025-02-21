if isServer() then
    return
end

local Core = PhunWallet

function Core:drop(player)

    local wallet = self.wallet:get(player).current or {}
    local toAdd = {}

    if self.settings.WalletDropOnDeath then
        local doAdd = false
        for k, v in pairs(wallet) do
            local currency = self.wallet.currencies[k]
            -- skip bound entries
            if not self.wallet.currencies[k].bound then
                local rate = 100
                if currency.returnRate then
                    rate = currency.returnRate
                elseif self.settings.WalletReturnRate ~= nil then
                    rate = self.settings.WalletReturnRate
                end
                if rate > 0 then
                    table.insert(toAdd, {
                        item = k,
                        amount = math.floor(v * (rate / 100))
                    })
                end
            end
        end

        if #toAdd > 0 then
            -- drop the wallet
            local square = player:getSquare()
            local worldItem = square:AddWorldInventoryItem("PhunMart.DroppedWallet", ZombRand(0.1, 0.5),
                ZombRand(0.1, 0.5), 0)
            if worldItem then
                worldItem:setName(getText("IGUI_PhunMart_Wallet_CharsWallet", player:getUsername()))
                worldItem:getWorldItem():setIgnoreRemoveSandbox(true); -- avoid the item to be removed by the SandboxOption WorldItemRemovalList
                worldItem:getModData().PhunWallet = {
                    owner = player:getUsername(),
                    wallet = toAdd
                }
                worldItem:getWorldItem():transmitCompleteItemToServer();
            end
        end
    end
end
