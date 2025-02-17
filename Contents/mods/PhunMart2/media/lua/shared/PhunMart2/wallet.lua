require "PhunMart2/core"
local Core = PhunMart

local wallets = nil
local wallet = {
    data = nil,
    currencies = {
        ["PhunMart.QuarterCoin"] = {},
        ["PhunMart.SilverDollar"] = {},
        ["PhunMart.TraiterToken"] = {
            bound = true
        }
    }
}

function wallet:isCurrency(item)
    return wallet.currencies[item].bound == true
end

function wallet:get(player)
    local key = nil
    if wallet.data == nil then
        wallet.data = ModData.getOrCreate("PhunMart_Wallets")
    end

    if type(player) == "string" then
        key = player
    else
        key = player:getUsername()
    end
    if key and string.len(key) > 0 then
        if not wallet.data[key] then
            wallet.data[key] = {
                current = {},
                bound = {},
                purchases = {}
            }
        end
        return wallet.data[key]
    end
end

function wallet.getCurrent(player)
    return wallet:get(player).current
end
function wallet.getBound(player)
    return wallet:get(player).bound
end
function wallet.getPurchases(player)
    return wallet:get(player).purchases
end
function wallet.getPurchase(player, id)
    return wallet:get(player).purchases[id]
end
function wallet:adjust(player, item, amount)
    local wallet = wallet:get(player)
    if wallet then
        wallet.current[item] = wallet.current[item] + amount
        -- TODO: If bound, adjust bound wallet
    end
end
function wallet:canAfford(player, item, price)
    local wallet = wallet:get(player)
    if wallet then
        return wallet.current[item] or 0 >= price
    end
end

return wallet
