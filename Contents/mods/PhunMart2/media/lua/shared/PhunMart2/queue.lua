local Core = nil

local queue = {
    isPaused = false,
    updated = 0,
    modified = 0,
    items = {}
}

local processing = {}

local function sendQueue()
    queue:send()
end

function queue:add(player, item, qty)

    Events.EveryOneMinute.Remove(sendQueue)
    local name = type(player) == "string" and player or player:getUsername()

    if not self.items[name] then
        self.items[name] = {}
    end

    self.items[name][item] = (self.items[name][item] or 0) + qty

    Events.EveryOneMinute.Add(sendQueue)
end

function queue:resetWallet(player)

end

function queue:send()
    Events.EveryOneMinute.Remove(sendQueue)
    print("Sending Queue")
    if Core == nil then
        Core = PhunMart
    end
    local c = Core
    sendClientCommand(c.name, c.commands.addToWallet, {
        wallet = self.items
    })
    queue.items = {}
end

function queue:complete(index)

    local toSend = processing[index]
    for i, v in ipairs(toSend) do
        local player = v[1]
        local items = v[2]
        for item, qty in pairs(items) do
            Core.wallet:adjust(player, item, qty)
        end
    end
    table.remove(processing, index)

end

return queue
