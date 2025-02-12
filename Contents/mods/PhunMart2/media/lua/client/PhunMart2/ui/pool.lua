if isServer() then
    return
end

require "ISUI/ISCollapsableWindowJoypad"
local Core = PhunMart

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2

local profileName = "PhunMartUIPool"
PhunMartUIPool = ISCollapsableWindowJoypad:derive(profileName);
local UI = PhunMartUIPool
local instances = {}
Core.ui.admin.pool = UI

function UI.OnOpenPanel(playerObj)

    local playerIndex = playerObj:getPlayerNum()
    local instance = instances[playerIndex]

    if not instance then
        local core = getCore()
        local width = 400 * FONT_SCALE
        local height = 300 * FONT_SCALE

        local x = (core:getScreenWidth() - width) / 2
        local y = (core:getScreenHeight() - height) / 2

        instances[playerIndex] = UI:new(x, y, width, height, playerObj, playerIndex);
        instance = instances[playerIndex]
        instance:initialise();

        ISLayoutManager.RegisterWindow(profileName, PhunMartUIPool, instance)
    end

    instance:addToUIManager();
    instance:setVisible(true);
    instance:ensureVisible()

    return instance;

end

function UI:new(x, y, width, height, player, playerIndex)
    local o = {};
    o = ISCollapsableWindowJoypad:new(x, y, width, height, player);
    setmetatable(o, self);
    self.__index = self;

    o.variableColor = {
        r = 0.9,
        g = 0.55,
        b = 0.1,
        a = 1
    };
    o.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.8
    };
    o.buttonBorderColor = {
        r = 0.7,
        g = 0.7,
        b = 0.7,
        a = 1
    };
    o.data = {}
    o.moveWithMouse = false;
    o.anchorRight = true
    o.anchorBottom = true
    o.player = player
    o.playerIndex = playerIndex
    o.zOffsetLargeFont = 25;
    o.zOffsetMediumFont = 20;
    o.zOffsetSmallFont = 6;
    o:setWantKeyEvents(true)
    o:setTitle("Pool")
    return o;
end

function UI:RestoreLayout(name, layout)

    -- ISLayoutManager.DefaultRestoreWindow(self, layout)
    -- if name == profileName then
    --     ISLayoutManager.DefaultRestoreWindow(self, layout)
    --     self.userPosition = layout.userPosition == 'true'
    -- end
    self:recalcSize();
end

function UI:SaveLayout(name, layout)
    ISLayoutManager.DefaultSaveWindow(self, layout)
    if self.userPosition then
        layout.userPosition = 'true'
    else
        layout.userPosition = 'false'
    end
end

function UI:close()
    if not self.locked then
        ISCollapsableWindowJoypad.close(self);
    end
end

function UI:refreshItems()
    local cmb = self.types
    local selected = cmb:getOptionData(cmb.selected)
    local data = {}
    if selected.type == "ITEMS" then

    elseif selected.type == "XP" then
        for i = 0, Perks.getMaxIndex() - 1 do
            local perk = PerkFactory.getPerk(Perks.fromIndex(i))
            if perk and perk:getParent() ~= Perks.None then
                local name = perk:getName()
                data[name] = {
                    label = name,
                    cost = perk:getCost(),
                    parent = perk:getParent()
                }
            end
        end
    elseif selected.type == "TRAITS" then
        local traits = TraitFactory.getTraits()
        for i = 0, traits:size() - 1 do
            local trait = traits:get(i)
            local exclusive = trait:getMutuallyExclusiveTraits()
            local exclusives = {}
            for j = 0, exclusive:size() - 1 do
                table.insert(exclusives, exclusive:get(j))
            end
            local cost = trait:getCost()
            local isPositive = true
            if trait:getCost() < 0 then
                isPositive = false
            end
            data[trait:getLabel()] = {
                label = trait:getLabel(),
                cost = cost,
                isPositive = isPositive,
                exclusives = exclusives
            }
        end
    elseif selected.type == "VEHICLES" then
        local scripts = getScriptManager():getAllVehicleScripts()
        for i = 0, scripts:size() - 1 do
            local script = scripts:get(i)
            local name = script:getName()
            local fname = script:getFileName()
            local fullName = script:getFullName()
            local text = "IGUI_VehicleName" .. name
            local label = getText(text)
            data[name] = {
                label = label,
                name = name,
                fname = fname,
                fullName = fullName
            }
        end
    end
    PhunLib:debug(data)
end

function UI:refreshCategories()

    local groups = require("PhunMart2/data/groups")
    local group = groups.clothing_jewelry

    local data = group or {}
    data.items = data.items or {}
    data.items.categories = data.items.categories or {}
    data.items.include = data.items.include or {}
    data.items.exclude = data.items.exclude or {}

    data.vehicles = data.vehicles or {}
    data.vehicles.categories = data.vehicles.categories or {}
    data.vehicles.include = data.vehicles.include or {}
    data.vehicles.exclude = data.vehicles.exclude or {}

    data.traits = data.traits or {}
    data.traits.categories = data.traits.categories or {}
    data.traits.include = data.traits.include or {}

    local itemCats = {}
    local itemExcludes = {}
    local itemIncludes = {}

    local vehicleCats = {}
    local vehicleExcludes = {}
    local vehicleIncludes = {}

    local traitCats = {}
    local traitExcludes = {}
    local traitIncludes = {}

    local catMap = {}
    local itemList = getScriptManager():getAllItems()
    for i = 0, itemList:size() - 1 do
        local item = itemList:get(i)
        if not item:getObsolete() and not item:isHidden() then

            local cat = Core.getCategory(item)
            if cat ~= "" and catMap[cat] == nil then
                catMap[cat] = true
                table.insert(itemCats, {
                    label = cat,
                    selected = data.items.categories[cat] ~= nil
                })
            end

            table.insert(itemExcludes, {
                type = item:getFullName(),
                label = item:getDisplayName(),
                texture = item:getNormalTexture(),
                selected = group.exclude[item:getFullName()] ~= nil,
                category = cat
            })
            table.insert(itemIncludes, {
                type = item:getFullName(),
                label = item:getDisplayName(),
                texture = item:getNormalTexture(),
                selected = group.include[item:getFullName()] ~= nil,
                category = cat
            })

        end
    end

    table.sort(itemCats, function(a, b)
        return a.label:lower() < b.label:lower()
    end)
    table.sort(itemExcludes, function(a, b)
        return a.label:lower() < b.label:lower()
    end)
    table.sort(itemIncludes, function(a, b)
        return a.label:lower() < b.label:lower()
    end)

    self.categories:setData(itemCats)
    self.exclusions:setData(itemExcludes)
    self.inclusions:setData(itemIncludes)
    catMap = {}
    local scripts = getScriptManager():getAllVehicleScripts()
    for i = 0, scripts:size() - 1 do
        local script = scripts:get(i)
        local name = script:getName()
        local fname = script:getFileName()
        local fullName = script:getFullName()
        local text = "IGUI_VehicleName" .. name
        local label = getText(text)
        local cat = "Other"
        if string.contains(name, "Van") then
            cat = "Van"
        elseif string.contains(name, "Truck") then
            cat = "Truck"
        elseif string.contains(name, "Burnt") then
            cat = "Burnt"
        elseif string.contains(name, "Smashed") then
            cat = "Smashed"
        elseif string.contains(name, "Trailer") then
            cat = "Trailer"
        elseif string.contains(name, "Car") then
            cat = "Car"
        end
        if not catMap[cat] then
            catMap[cat] = true
            table.insert(vehicleCats, {
                label = cat,
                selected = data.vehicles.categories[cat] ~= nil
            })
        end

        table.insert(vehicleExcludes, {
            label = fullName,
            name = name,
            fname = fname,
            fullName = fullName,
            category = cat
        })

        table.insert(vehicleIncludes, {
            label = fullName,
            name = name,
            fname = fname,
            fullName = fullName,
            category = cat
        })
    end
    table.sort(vehicleCats, function(a, b)
        return a.label:lower() < b.label:lower()
    end)
    self.vehicles:setData(vehicleCats)

    table.sort(vehicleExcludes, function(a, b)
        return a.label:lower() < b.label:lower()
    end)
    self.vehicles:setData(vehicleExcludes)

    table.sort(vehicleIncludes, function(a, b)
        return a.label:lower() < b.label:lower()
    end)
    self.vehicles:setData(vehicleIncludes)

    -- self:refreshItems()
end

function UI:createChildren()

    ISCollapsableWindowJoypad.createChildren(self);

    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()

    local padding = 10
    local x = padding
    local y = th + padding
    local w = self.width - x - padding
    -- local h = self.height - y - rh - padding
    local h = self.height - rh - padding - FONT_HGT_SMALL - 4

    self.tabPanel = ISTabPanel:new(x, y, w, h - y);
    self.tabPanel:initialise()
    self:addChild(self.tabPanel)

    self.categories = PhunMartUIItemCats:new(0, 100, w, self.tabPanel.height - th, {
        player = self.player
    });

    self.exclusions = PhunMartUIItemList:new(0, 100, w, self.tabPanel.height - th, {
        player = self.player
    });

    self.inclusions = PhunMartUIItemList:new(0, 100, w, self.tabPanel.height - th, {
        player = self.player
    });

    self.vehicles = PhunMartUIItemList:new(0, 100, w, self.tabPanel.height - th, {
        player = self.player
    });

    self.tabPanel:addView("Item Categories", self.categories)
    self.tabPanel:addView("Item Inclusions", self.inclusions)
    self.tabPanel:addView("Item Exclusions", self.exclusions)
    self.tabPanel:addView("Vehicles", self.vehicles)

    self.ok = ISButton:new(padding, self.height - rh - padding - FONT_HGT_SMALL, 100, FONT_HGT_SMALL + 4, "OK", self,
        UI.onOK);
    self.ok:initialise();
    self.ok:instantiate();
    self:addChild(self.ok);

    self:refreshCategories()
end

function UI:onOK()
    print("OK")

    local selected = {
        categories = {},
        include = {},
        exclude = {},
        vehicles = {}
    }

    for _, v in ipairs(self.categories.list.items) do
        if v.item.selected then
            selected.categories[v.item.label] = true
        end
    end
    for _, v in ipairs(self.exclusions.data) do
        if v.selected then
            selected.exclude[v.type] = true
        end
    end
    for _, v in ipairs(self.inclusions.data) do
        if v.selected then
            selected.include[v.type] = true
        end
    end
    for _, v in ipairs(self.inclusions.data) do
        if v.selected then
            selected.include[v.type] = true
        end
    end
    for _, v in ipairs(self.vehicles.data) do
        if v.selected then
            selected.vehicles[v.name] = true
        end
    end
    PhunLib:debug(selected)

end

function UI:prerender()

    ISCollapsableWindowJoypad.prerender(self);

    self.ok:setX(self.width - self.ok.width - 10)
    self.ok:setY(self.height - self.ok.height - self:resizeWidgetHeight() - 10)
    self.tabPanel:setWidth(self.width - 20)
    self.tabPanel:setHeight(self.ok.y - self.tabPanel.y - 50)
end

function UI:refreshShops(shops)
    self.page:clear()
    local data = {}
    for k, v in pairs(shops) do
        if v.abstract ~= true then
            table.insert(data, v)
        end
    end
    table.sort(data, function(a, b)
        return a.label < b.label
    end)
    self.page:addOption(" -- SHOP -- ")
    for _, v in ipairs(data) do
        if v.abstract ~= true then
            self.page:addOptionWithData(v.label .. " (" .. v.key .. ")", v)
        end
    end
end

local zones = nil

function UI:refreshLocations(instances)
    self.locations:setData(instances)
end

