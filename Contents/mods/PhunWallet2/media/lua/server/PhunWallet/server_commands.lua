if isClient() then
    return
end
local Core = PhunWallet
local Commands = {}

Commands[Core.commands.addToWallet] = function(_, args)
    for k, v in pairs(args.wallet) do
        for kk, vv in pairs(v) do
            Core.wallet:adjust(k, kk, vv)
        end
    end
end

Commands[Core.commands.resetWallet] = function(playerObj, args)
    print("Resetting wallet for ", playerObj:getUsername())
    Core.wallet:reset(playerObj)
end

Commands[Core.commands.playerSetup] = function(playerObj, args)
    local wallet = Core.wallet:get(playerObj)
    sendServerCommand(playerObj, Core.name, Core.commands.getWallet, {
        username = playerObj:getUsername(),
        wallet = wallet
    })
end

Commands[Core.commands.getPlayerList] = function(args)
    if PW.ui.admin.instances then
        for _, instance in pairs(PW.ui.admin.instances) do
            instance:setPlayers(args.players)
        end
    end
end

Commands[Core.commands.getPlayersWallet] = function(args)
    if PW.ui.admin.instances then
        for _, instance in pairs(PW.ui.admin.instances) do
            instance:setWallet(args.wallet)
        end
    end
end

return Commands
