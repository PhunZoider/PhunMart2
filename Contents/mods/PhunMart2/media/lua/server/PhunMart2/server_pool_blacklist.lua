if isClient() then
    return
end
require "PhunMart2/core"
require "PhunLib/core"
local blacklistData = require "PhunMart2/data/blacklist"
local Core = PhunMart
local PL = PhunLib
local fileTools = PL.file

function Core.getBlacklist(refresh)
    if refresh then
        blacklistData = fileTools.loadTable("blacklist.lua")
    end
    return blacklistData
end

function Core.setBlacklist(data)
    blacklistData = data or {}
    fileTools.saveTable("blacklist.lua", blacklistData)
end

