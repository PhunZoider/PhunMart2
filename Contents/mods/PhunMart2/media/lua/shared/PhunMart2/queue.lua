require "PhunMart2/core"
local Core = PhunMart

local queue = {
    isPaused = false,
    counter = 0,
    items = {}
}

local processing = {}

function queue:add(player, item, qty)
    local name = type(player) == "string" and player or player:getUsername()
    if not self.items[name] then
        self.items[name] = {}
    end
    if self.items[name][item] then
        self.items[name][item] = self.items[name][item] + qty
    else
        self.items[name][item] = qty
    end
    self.counter = self.counter + 1
end

function queue:send()
    local toSend = {}
    for k, v in pairs(queue.items) do
        table.insert(toSend, {k, v})
    end
    table.insert(processing, toSend)
    sendClientCommand(Core.name, Core.commands.addToWallet, {
        processing = processing[#processing],
        index = #processing
    })
    queue.items = {}
    queue.counter = 0
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

function queue:bulkSetValues(player, values)
    -- set all the values at once (Eg wallet pickup)
end

return queue
