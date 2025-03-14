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

local profileName = "PhunMartUIPoolItems"
PhunMartUIPoolItems = ISCollapsableWindowJoypad:derive(profileName);
local UI = PhunMartUIPoolItems
local instances = {}
Core.ui.admin.poolItems = UI

function UI:setData(data)

end

function UI.OnOpenPanel(playerObj, pool)

    local playerIndex = playerObj:getPlayerNum()
    local instance = instances[playerIndex]

    if not instance then
        local core = getCore()
        local width = 500 * FONT_SCALE
        local height = 400 * FONT_SCALE

        local x = (core:getScreenWidth() - width) / 2
        local y = (core:getScreenHeight() - height) / 2

        instances[playerIndex] = UI:new(x, y, width, height, playerObj, playerIndex);
        instance = instances[playerIndex]
        instance:initialise();

        ISLayoutManager.RegisterWindow(profileName, PhunMartUIPoolItems, instance)
    end

    instance.pool = pool or {}

    instance:addToUIManager();
    instance:setVisible(true);
    instance:ensureVisible()
    instance:refreshAll()
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
    o.controls = {}
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
    o:setTitle("Items")
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

function UI:refreshAll()
    local groups = require("PhunMart2/data/groups")
    self.controls.pools:clear()
    for k, v in pairs(groups) do
        self.controls.pools:addOption(k)
    end
end

function UI:setPool(pool)
    local groups = require("PhunMart2/data/groups")
    local group = groups[pool]

    local items = {}

    local allItems = Core.getAllItems()
    local allCars = Core.getAllVehicles()
    local allTraits = Core.getAllTraits()
    local allXp = Core.getAllXp()
    local allBoosts = Core.getAllBoosts()

    for _, v in ipairs(allItems) do
        if not group.exclude[v.type] then
            if group.include[v.type] or group.categories[v.category] then
                table.insert(items, {
                    type = v.type,
                    label = v.label,
                    category = v.category,
                    texture = v.texture
                })
            end
        end
    end

    for _, v in ipairs(allCars) do
        if not group.exclude[v.type] then
            if group.include[v.type] or group.categories[v.category] then
                table.insert(items, {
                    type = v.type,
                    label = v.label,
                    category = v.category
                })
            end
        end
    end

    for _, v in ipairs(allCars) do
        if not group.exclude[v.type] then
            if group.include[v.type] or group.categories[v.category] then
                table.insert(items, {
                    type = v.type,
                    label = v.label,
                    category = v.category
                })
            end
        end
    end

    for _, v in ipairs(allXp) do
        if not group.exclude[v.type] then
            if group.include[v.type] or group.categories[v.category] then
                table.insert(items, {
                    type = v.type,
                    label = v.label,
                    category = v.category
                })
            end
        end
    end

    for _, v in ipairs(allBoosts) do
        if not group.exclude[v.type] then
            if group.include[v.type] or group.categories[v.category] then
                table.insert(items, {
                    type = v.type,
                    label = v.label,
                    category = v.category
                })
            end
        end
    end

    table.sort(items, function(a, b)
        return a.label:lower() < b.label:lower()
    end)

    self.data = items
    self.list:clear()
    for _, v in ipairs(items) do
        self.list:addItem(v.label, v)
    end

    self:setTitle("Pool: " .. pool .. " (" .. #items .. " items)")
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

    self.controls.pools = ISComboBox:new(self.width - 210, y, 200, FONT_HGT_SMALL + 4, self, function()
        self:setPool(self.controls.pools:getOptionText(self.controls.pools.selected))
    end);
    self.controls.pools:initialise();
    self.controls.pools:instantiate();
    self.controls.pools:setAnchorRight(true);
    self:addChild(self.controls.pools);

    local txt = "Pool"
    self.controls.poolsLabel = ISLabel:new(self.controls.pools.x - 10 - getTextManager():MeasureStringX(self.font, txt),
        y, FONT_HGT_SMALL, txt, 1, 1, 1, 1, UIFont.Small, true);
    self.controls.poolsLabel:initialise();
    self.controls.poolsLabel:instantiate();
    self:addChild(self.controls.poolsLabel);

    y = y + self.controls.pools.height + padding + HEADER_HGT

    self.list = ISScrollingListBox:new(0, y, 300, 300);
    self.list:initialise();
    self.list:instantiate();
    self.list.itemheight = FONT_HGT_SMALL + 6 * 2
    self.list.selected = 0;
    self.list.joypadParent = self;
    self.list.font = UIFont.NewSmall;
    self.list.doDrawItem = self.drawDatas;
    self.list.onMouseUp = function(list, x, y)
        self.selectedProperty = nil
        local row = list:rowAt(x, y)
        if row == nil or row == -1 then
            return
        end
        list:ensureVisible(row)
        local item = list.items[row].item

        self:setSelectedItem()

        -- remember last selected for range select
        self.lastSelected = row
    end

    self.list.onRightMouseUp = function(target, x, y, a, b)
        local row = self.list:rowAt(x, y)
        if row == -1 then
            return
        end
        if self.selected ~= row then
            self.selected = row
            self.list.selected = row
            self.list:ensureVisible(self.list.selected)
        end
        local item = self.list.items[self.list.selected].item

    end
    self.list.drawBorder = true;
    self.list.onMouseMove = self.doOnMouseMove
    self.list.onMouseMoveOutside = self.doOnMouseMoveOutside

    self.list:addColumn("Item", 0);
    self.list:addColumn("Category", 200);
    self:addChild(self.list);

    self.controls.itemProps = ISPanel:new(self.list.x + self.list.width + padding, y - HEADER_HGT,
        self.width - self.list.width - padding * 3, self.height - y - padding - rh - HEADER_HGT);
    self.controls.itemProps:initialise();
    self.controls.itemProps:instantiate();
    self:addChild(self.controls.itemProps);

    self.controls.itemPropsTabs = ISTabPanel:new(0, 0, self.controls.itemProps.width, self.controls.itemProps.height);
    self.controls.itemPropsTabs:initialise();
    self.controls.itemPropsTabs:instantiate();
    self.controls.itemProps:addChild(self.controls.itemPropsTabs);

    self.controls.propsSkills = ISScrollingListBox:new(0, HEADER_HGT, self.controls.itemPropsTabs.width,
        self.controls.itemPropsTabs.height - HEADER_HGT);
    self.controls.propsSkills:initialise();
    self.controls.propsSkills:instantiate();
    self.controls.propsSkills.itemheight = FONT_HGT_SMALL + 6 * 2
    self.controls.propsSkills.selected = 0;
    self.controls.propsSkills.joypadParent = self;
    self.controls.propsSkills.font = UIFont.NewSmall;
    self.controls.propsSkills.doDrawItem = self.drawSkillDatas;

    self.controls.propsSkills:addColumn("Skill", 0);
    self.controls.propsSkills:addColumn("Requires", 100);

    self.controls.itemPropsTabs:addView("Skills", self.controls.propsSkills);

    self.controls.propsBoosts = ISScrollingListBox:new(0, HEADER_HGT, self.controls.itemPropsTabs.width,
        self.controls.itemPropsTabs.height - HEADER_HGT);
    self.controls.propsBoosts:initialise();
    self.controls.propsBoosts:instantiate();
    self.controls.propsBoosts.itemheight = FONT_HGT_SMALL + 6 * 2
    self.controls.propsBoosts.selected = 0;
    self.controls.propsBoosts.joypadParent = self;
    self.controls.propsBoosts.font = UIFont.NewSmall;
    self.controls.propsBoosts.doDrawItem = self.drawBoostsDatas;

    self.controls.propsBoosts:addColumn("Boost", 0);
    self.controls.propsBoosts:addColumn("Requires", 100);

    self.controls.itemPropsTabs:addView("Boosts", self.controls.propsBoosts);

    self.controls.propsTraits = ISScrollingListBox:new(0, HEADER_HGT, self.controls.itemPropsTabs.width,
        self.controls.itemPropsTabs.height - HEADER_HGT);
    self.controls.propsTraits:initialise();
    self.controls.propsTraits:instantiate();
    self.controls.propsTraits.itemheight = FONT_HGT_SMALL + 6 * 2
    self.controls.propsTraits.selected = 0;
    self.controls.propsTraits.joypadParent = self;
    self.controls.propsTraits.font = UIFont.NewSmall;
    self.controls.propsTraits.doDrawItem = self.drawTraitDatas;

    self.controls.propsTraits:addColumn("Trait", 0);
    self.controls.propsTraits:addColumn("Requires", 100);

    self.controls.itemPropsTabs:addView("Traits", self.controls.propsTraits);

    self.controls.propsProf = ISScrollingListBox:new(0, HEADER_HGT, self.controls.itemPropsTabs.width,
        self.controls.itemPropsTabs.height - HEADER_HGT);
    self.controls.propsProf:initialise();
    self.controls.propsProf:instantiate();
    self.controls.propsProf.itemheight = FONT_HGT_SMALL + 6 * 2
    self.controls.propsProf.selected = 0;
    self.controls.propsProf.joypadParent = self;
    self.controls.propsProf.font = UIFont.NewSmall;
    self.controls.propsProf.doDrawItem = self.drawProfDatas;

    self.controls.propsProf:addColumn("Trait", 0);
    self.controls.propsProf:addColumn("Requires", 100);

    self.controls.itemPropsTabs:addView("Professions", self.controls.propsProf);

    self.controls.purchaseLimitsPanel = ISPanel:new(0, 0, self.controls.itemPropsTabs.width,
        self.controls.itemPropsTabs.height);
    self.controls.purchaseLimitsPanel:initialise();
    self.controls.purchaseLimitsPanel:instantiate();
    self.controls.itemPropsTabs:addView("Purchase Limits", self.controls.purchaseLimitsPanel);

    self.controls.maxPurchasesLabel = ISLabel:new(10, 10, FONT_HGT_SMALL, "Max Purchases", 1, 1, 1, 1, UIFont.Small,
        true);
    self.controls.maxPurchasesLabel:initialise();
    self.controls.maxPurchasesLabel:instantiate();
    self.controls.purchaseLimitsPanel:addChild(self.controls.maxPurchasesLabel);

    self.controls.maxPurchases = ISTextEntryBox:new("0", 10, 30, 100, FONT_HGT_SMALL + 4);
    self.controls.maxPurchases:initialise();
    self.controls.maxPurchases:instantiate();
    self.controls.purchaseLimitsPanel:addChild(self.controls.maxPurchases);

    self.controls.maxPurchasesAllCharsLabel = ISLabel:new(10, 60, FONT_HGT_SMALL, "Max Purchases All Chars", 1, 1, 1, 1,
        UIFont.Small, true);
    self.controls.maxPurchasesAllCharsLabel:initialise();
    self.controls.maxPurchasesAllCharsLabel:instantiate();
    self.controls.purchaseLimitsPanel:addChild(self.controls.maxPurchasesAllCharsLabel);

    self.controls.maxPurchasesAllChars = ISTextEntryBox:new("0", 10, 80, 100, FONT_HGT_SMALL + 4);
    self.controls.maxPurchasesAllChars:initialise();
    self.controls.maxPurchasesAllChars:instantiate();
    self.controls.purchaseLimitsPanel:addChild(self.controls.maxPurchasesAllChars);

    self.controls.minTimeLabel = ISLabel:new(10, 110, FONT_HGT_SMALL, "Min Time", 1, 1, 1, 1, UIFont.Small, true);
    self.controls.minTimeLabel:initialise();
    self.controls.minTimeLabel:instantiate();
    self.controls.purchaseLimitsPanel:addChild(self.controls.minTimeLabel);

    self.controls.minTime = ISTextEntryBox:new("0", 10, 130, 100, FONT_HGT_SMALL + 4);
    self.controls.minTime:initialise();
    self.controls.minTime:instantiate();
    self.controls.purchaseLimitsPanel:addChild(self.controls.minTime);

    self.controls.minCharTimeLabel = ISLabel:new(10, 110, FONT_HGT_SMALL, "Min Char Time", 1, 1, 1, 1, UIFont.Small,
        true);
    self.controls.minCharTimeLabel:initialise();
    self.controls.minCharTimeLabel:instantiate();
    self.controls.purchaseLimitsPanel:addChild(self.controls.minCharTimeLabel);

    self.controls.minCharTime = ISTextEntryBox:new("0", 10, 130, 100, FONT_HGT_SMALL + 4);
    self.controls.minCharTime:initialise();
    self.controls.minCharTime:instantiate();
    self.controls.purchaseLimitsPanel:addChild(self.controls.minCharTime);

    self:refreshAll()
end

function UI:setSelectedItem()

    local item = self.list.items[self.list.selected].item
    local data = self.data[self.list.selected]

    self.controls.propsSkills:clear()
    for _, v in ipairs(Core.getAllSkills()) do
        self.controls.propsSkills:addItem(v.label, v)
    end

    self.controls.propsBoosts:clear()
    for _, v in ipairs(Core.getAllSkills()) do
        self.controls.propsBoosts:addItem(v.label, v)
    end

    self.controls.propsTraits:clear()
    for _, v in ipairs(Core.getAllTraits()) do
        self.controls.propsTraits:addItem(v.label, v)
    end

    self.controls.propsProf:clear()
    for _, v in ipairs(Core.getAllProfessions()) do
        self.controls.propsProf:addItem(v.label, v)
    end

end

function UI:drawDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9;

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.2, 0.6, 0.5, 0.5);
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b);

    local iconX = 4
    local iconSize = FONT_HGT_SMALL;
    local xoffset = 10;

    local clipX = self.columns[1].size
    local clipX2 = self.columns[2].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    if item.item.texture then
        local textured = self:drawTextureScaledAspect2(item.item.texture, xoffset, y, self.itemheight - 4,
            self.itemheight - 4, 1, 1, 1, 1)
        xoffset = xoffset + self.itemheight + 4
    end

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.text, xoffset, y + 4, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    local value = item.item.category

    local valueWidth = getTextManager():MeasureStringX(self.font, value)
    local w = self.width
    local cw = self.columns[2].size
    self:drawText(value, w - valueWidth - xoffset - 4, y + 4, 1, 1, 1, a, self.font);
    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end

function UI:drawSkillDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9;

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.2, 0.6, 0.5, 0.5);
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b);

    local iconX = 4
    local iconSize = FONT_HGT_SMALL;
    local xoffset = 10;

    local clipX = self.columns[1].size
    local clipX2 = self.columns[2].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    if item.item.texture then
        local textured = self:drawTextureScaledAspect2(item.item.texture, xoffset, y, self.itemheight - 4,
            self.itemheight - 4, 1, 1, 1, 1)
        xoffset = xoffset + self.itemheight + 4
    end

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.item.label or item.item.type, xoffset, y + 4, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    local value = item.item.category

    local valueWidth = getTextManager():MeasureStringX(self.font, value)
    local w = self.width
    local cw = self.columns[2].size
    self:drawText(value, w - valueWidth - xoffset - 4, y + 4, 1, 1, 1, a, self.font);
    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end

function UI:drawBoostsDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9;

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.2, 0.6, 0.5, 0.5);
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b);

    local iconX = 4
    local iconSize = FONT_HGT_SMALL;
    local xoffset = 10;

    local clipX = self.columns[1].size
    local clipX2 = self.columns[2].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    if item.item.texture then
        local textured = self:drawTextureScaledAspect2(item.item.texture, xoffset, y, self.itemheight - 4,
            self.itemheight - 4, 1, 1, 1, 1)
        xoffset = xoffset + self.itemheight + 4
    end

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.item.label or item.item.type, xoffset, y + 4, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    local value = item.item.category

    local valueWidth = getTextManager():MeasureStringX(self.font, value)
    local w = self.width
    local cw = self.columns[2].size
    self:drawText(value, w - valueWidth - xoffset - 4, y + 4, 1, 1, 1, a, self.font);
    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end

function UI:drawTraitDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9;

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.2, 0.6, 0.5, 0.5);
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b);

    local iconX = 4
    local iconSize = FONT_HGT_SMALL;
    local xoffset = 10;

    local clipX = self.columns[1].size
    local clipX2 = self.columns[2].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    if item.item.texture then
        local textured = self:drawTextureScaledAspect2(item.item.texture, xoffset, y, self.itemheight - 4,
            self.itemheight - 4, 1, 1, 1, 1)
        xoffset = xoffset + self.itemheight + 4
    end

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.item.label or item.item.type, xoffset, y + 4, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    local value = item.item.category

    local valueWidth = getTextManager():MeasureStringX(self.font, value)
    local w = self.width
    local cw = self.columns[2].size
    self:drawText(value, w - valueWidth - xoffset - 4, y + 4, 1, 1, 1, a, self.font);
    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end

function UI:drawProfDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9;

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.2, 0.6, 0.5, 0.5);
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b);

    local iconX = 4
    local iconSize = FONT_HGT_SMALL;
    local xoffset = 10;

    local clipX = self.columns[1].size
    local clipX2 = self.columns[2].size
    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    if item.item.texture then
        local textured = self:drawTextureScaledAspect2(item.item.texture, xoffset, y, self.itemheight - 4,
            self.itemheight - 4, 1, 1, 1, 1)
        xoffset = xoffset + self.itemheight + 4
    end

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.item.label or item.item.type, xoffset, y + 4, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    local value = item.item.category

    local valueWidth = getTextManager():MeasureStringX(self.font, value)
    local w = self.width
    local cw = self.columns[2].size
    self:drawText(value, w - valueWidth - xoffset - 4, y + 4, 1, 1, 1, a, self.font);
    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end
