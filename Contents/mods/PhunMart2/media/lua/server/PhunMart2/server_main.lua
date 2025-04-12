if isClient() then
    return
end
local Core = PhunMart

Core.instances = {}

function Core:addInstance(instance)
    self.instances[instance.key] = instance
end
function Core:removeInstance(instance)
    self.instances[instance.key] = nil
end

function Core:getInstanceDistancesFrom(x, y)
    local results = {}
    for k, v in pairs(self.shops) do
        if v.enabled ~= false then
            results[k] = 9999999
        end
    end

    for k, v in pairs(self.instances) do
        if results[v.key] then

            local dx = x - v.x
            local dy = y - v.y
            local distance = math.sqrt(dx * dx + dy * dy)
            if distance < results[v.key] then
                results[v.key] = distance
            end
        else
            print("PhunMart Error: No shop with key " .. k)
        end
    end

    return results
end

function Core:ini()
    self.inied = true
    self.instances = ModData.getOrCreate(self.name)
    Core.ServerSystem.instance:removeInvalidInstanceData()
    triggerEvent(self.events.OnReady, self)
end
