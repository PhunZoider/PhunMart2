if isServer() then
    return
end

require "TimedActions/ISInventoryTransferAction"
local Core = PhunMart

-- Hook the original New Inventory Transfer Method
local originalNewInventoryTransaferAction = ISInventoryTransferAction.new
function ISInventoryTransferAction:new(player, item, srcContainer, destContainer, time)

    local itemType = item:getFullType()
    local wallet = nil

    if srcContainer and instanceof(srcContainer:getParent(), "IsoDeadBody") then
        if itemType == "PhunMart.DroppedWallet" then
            -- picking up a players wallet
            wallet = item:getModData().PhunWallet
            if wallet then
                if wallet.wallet and (not Core.settings.OnlyPickupOwnWallet or player:getUsername() == wallet.owner) then
                elseif wallet.wallet and Core.settings.OnlyPickupOwnWallet and player:getUsername() ~= wallet.owner then
                    return {
                        ignoreAction = true
                    }
                end
            end
        end
    end

    local action = originalNewInventoryTransaferAction(self, player, item, srcContainer, destContainer, time)

    if wallet and wallet.wallet then
        action:setOnComplete(function()
            -- add the items in the dropped wallet to the player
            for k, v in pairs(wallet.wallet.current or {}) do
                Core.wallet:adjust(player, k, v, true)
            end
        end)
    elseif Core.wallet:isCurrency(itemType) then
        action:setOnComplete(function()
            local destType = destContainer:getType()
            if destType ~= "floor" then
                Core.wallet:adjust(player, itemType, 1)
                destContainer:DoRemoveItem(item)
            end
        end)
    end

    return action
end
