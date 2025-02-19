require "PhunMart2/core"
local Core = PhunMart
local PL = PhunLib
local queue = require "PhunMart2/queue"

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
    return wallet.currencies[item] ~= nil
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
function wallet:setCurrent(player, item, amount)
    wallet:getCurrent(player)[item] = amount
end
function wallet:setBound(player, item, amount)
    wallet:getBound(player)[item] = amount
end
function wallet:reset(player)

    local name = type(player) == "string" and player or player:getUsername()

    if isClient() then
        sendClientCommand(Core.name, Core.commands.resetWallet, {
            username = name
        })
    end

    local w = wallet:get(name)

    for k, v in pairs(wallet.currencies) do

        local current = wallet.getCurrent(player)[k] or 0
        if (w.current[k] or 0) > 0 then
            -- deduct current amount
            PL.file.logTo("wallet.log", name, k, 0 - w.current[k])
            w.current[k] = 0
        end

        if v.bound then
            -- add bound amount
            current = wallet.getBound(player)[k] or 0
            if (w.bound[k] or 0) > 0 then
                w.current[k] = w.bound[k]
                PL.file.logTo("wallet.log", name, k, w.current[k])
            end
        end

    end

end
function wallet:adjust(player, item, amount)
    local name = type(player) == "string" and player or player:getUsername()
    print("Adjusting wallet for ", tostring(name), tostring(item), tostring(amount))
    local w = self:get(name)
    if w then

        w.current[item] = (w.current[item] or 0) + (amount or 1)
        -- TODO: If bound, adjust bound wallet
        if self.currencies[item].bound then
            w.bound[item] = (w.bound[item] or 0) + (amount or 1)
        end
        if isClient() then
            queue:add(player, item, amount or 1)
        else
            PL.file.logTo("wallet.log", name, item, amount or 1)
        end
    end
end
function wallet:canAfford(player, item, price)
    local wallet = wallet:get(player)
    if wallet then
        return wallet.current[item] or 0 >= price
    end
end

return wallet
