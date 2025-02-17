require "PhunMart2/core"
local Core = PhunMart

function Core:canAffords(player, itemsAndPrice)

    local result, resultText = {}, ""

    for i, price in ipairs(itemsAndPrice or {}) do
        if not Core:canAfford(player, price[1], price[2]) then
            result = false
            table.insert(resultText, "You can't afford " .. price[1] .. " for " .. price[2])
        end
    end

    return result, resultText

end

function Core:canAfford(player, item, price)
    if Core.wallet.isCurrency(item) then
        return Core.wallet.getCurrent(player)[item] >= price
    else
        return player:getInventory():getItemCountRecursive(item) >= price
    end
end
