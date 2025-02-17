if isServer() then
    return
end

require "TimedActions/ISInventoryTransferAction"
local queue = require "PhunMart2/queue"
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
                if wallet.wallet and (not PW.settings.OnlyPickupOwnWallet or player:getUsername() == wallet.owner) then
                elseif wallet.wallet and PW.settings.OnlyPickupOwnWallet and player:getUsername() ~= wallet.owner then
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
                queue:add(player, k, v, true)
                queue:process()
            end
        end)
    elseif Core.wallet:isCurrency(itemType) then
        action:setOnComplete(function()
            local destType = destContainer:getType()

            if destType ~= "floor" then
                queue:add(player, itemType, 1)
            end
        end)
    end

    return action
end
