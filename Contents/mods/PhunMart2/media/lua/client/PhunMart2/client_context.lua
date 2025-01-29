if isServer() then
    return
end
local Core = PhunMart
Core.contexts = {}

Core.contexts.open = function(player, context, worldobjects, test)
    local obj
    for _, wObj in ipairs(worldobjects) do -- find object to interact with; code support for controllers
        obj = Core.ClientSystem.instance:getLuaObjectOnSquare(wObj:getSquare())
        if obj then
            local text = getText("IGUI_PhunMart_Open_X", getText("IGUI_PhunMart_Shop_" .. obj.key))
            local desc = getText("IGUI_PhunMart_Shop_" .. obj.key .. "_tooltip")
            local disabled = false
            if obj.lockedBy ~= false then
                desc = getText("IGUI_PhunMart_Open_X_locked_tooltip", obj.lockedBy,
                    getText("IGUI_PhunMart_Shop_" .. obj.key))
                disabled = true
            elseif obj.powered then
                if not obj:getSquare():haveElectricity() and SandboxVars.ElecShutModifier > -1 and
                    GameTime:getInstance():getNightsSurvived() > SandboxVars.ElecShutModifier then
                    desc = getText("IGUI_PhunMart_Open_X_nopower_tooltip", getText("IGUI_PhunMart_Shop_" .. obj.key))
                    disabled = true
                end
            end
            local option = context:addOptionOnTop(text, getSpecificPlayer(player), function()
                print("Open shop")
            end)
            local toolTip = ISToolTip:new();
            toolTip:setVisible(false);
            toolTip:setName(getText("IGUI_PhunMart_Shop_" .. obj.key));
            toolTip.description = desc;
            option.notAvailable = disabled
            option.toolTip = toolTip;
        end
        break
    end

    if isAdmin() or isDebugEnabled() then
        local adminOption = context:addOption("PhunMart", worldobjects, nil)
        local adminSubMenu = ISContextMenu:getNew(context)

        adminSubMenu:addOption("Pool Editor", player, function()
            Core.ui.admin.pool.OnOpenPanel(getSpecificPlayer(player))
        end)

        adminSubMenu:addOption("Locations", player, function()

        end)

        if obj then
            adminSubMenu:addOption("Reroll", player, function()

            end)
        end

        adminSubMenu:addOption("Convert", player, function()

        end)

        context:addSubMenu(adminOption, adminSubMenu)
    end
end
