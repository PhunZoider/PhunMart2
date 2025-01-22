require "PhunMart2/core"
require "PhunLib/core"
local Core = PhunMart
local PL = PhunLib
local fileTools = PL.file
local tableTools = PL.table

local itemGroupData = require "PhunMart2/data/groups"
local poolsData = require "PhunMart2/data/pools"
local blacklistData = require "PhunMart2/data/blacklist"
local shopsData = require "PhunMart2/data/shops"

local function formatShop(data)

    local fills = {
        min = 1,
        max = 10
    }

    if data.fills then
        if type(data.fills) == "number" then
            fills.min = data.fills
            fills.max = data.fills
        else
            if data.fills.min then
                fills.min = data.fills.min
            end
            if data.fills.max then
                fills.max = data.fills.max
            end
        end
    end

    local result = {
        type = data.type,
        label = data.label,
        group = data.group or "NONE",
        distance = data.distance or 100,
        probability = data.probability or 15,
        filters = data.filters or {},
        reroll = data.reroll or 0,
        powered = data.powered == true,
        restock = data.restock or 48,
        currency = data.currency or "base.money",
        basePrice = data.basePrice or 1,
        fills = fills,
        groups = data.groups or {},
        image = data.image or "machine-none.png",
        sprites = data.sprites or {"phunmart_01_0", -- east
        "phunmart_01_1", -- south
        "phunmart_01_2", -- west
        "phunmart_01_3" -- north
        }
    }

    return result
end

local function formatPool(data)

    local result = {}
    for k, v in pairs(data) do
        result[k] = {

            items = v.items or {},
            categories = v.categories or {},
            include = v.include or {},
            exclude = v.exclude or {},
            blacklist = v.blacklist or {}
        }
    end

end

local function formatGroup(data)

    local result = {
        categories = data.categories or {},
        include = data.include or {},
        exclude = data.exclude or {}
    }

end

local function getShops()

    local result = {}
    for k, v in pairs(shopsData) do
        result[k] = formatShop(v)
    end

    return result
end
