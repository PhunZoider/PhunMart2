if isServer() then
    return
end

require "ISUI/ISCollapsableWindowJoypad"
local Core = PhunMart

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local BUTTON_HGT = FONT_HGT_SMALL + 6
local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2

local profileName = "PhunMartUIConfigItem"
Core.ui.admin.shop_config_item = ISCollapsableWindowJoypad:derive(profileName);
local UI = Core.ui.admin.shop_config_item
local instances = {}

function UI:setData(data)
    self.data = data
end

function UI.open(player, item)

    local playerIndex = player:getPlayerNum()

    local core = getCore()
    local width = 600 * FONT_SCALE
    local height = 400 * FONT_SCALE

    local x = (core:getScreenWidth() - width) / 2
    local y = (core:getScreenHeight() - height) / 2

    local instance = UI:new(x, y, width, height, player, playerIndex);
    instance.item = item
    instance:initialise();

    ISLayoutManager.RegisterWindow(profileName, UI, instance)

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
    o:setTitle("shop_config_item")
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

function UI:addLabel(text, parent, y)
    local label = ISLabel:new(10, y, FONT_HGT_SMALL, text, 1, 1, 1, 1, UIFont.Small, true);
    label:initialise();
    label:instantiate();
    parent:addChild(label);
    return label;
end

function UI:addTextbox(name, text, tooltip, parent, y)
    local textbox = ISTextEntryBox:new("", 100, y, 100, FONT_HGT_SMALL + 4);
    textbox:initialise();
    textbox:instantiate();
    textbox:setTooltip(tooltip)
    parent:addChild(textbox);
    self.controls[name] = textbox
    return textbox;
end

function UI:addLabeledTextbox(name, text, tooltip, parent, y)
    self:addLabel(text, parent, y)
    return self:addTextbox(name, text, tooltip, parent, y)
end

function UI:createChildren()

    ISCollapsableWindowJoypad.createChildren(self);
    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()

    local padding = 10
    local x = padding
    local y = th + padding
    local w = self.width - x - padding
    local h = self.height - rh - padding - FONT_HGT_SMALL - 4

    self.controls = {}

    local panel = ISPanel:new(x, y, w - 210, h);
    panel:initialise();
    panel:instantiate();
    self:addChild(panel);
    self.controls._panel = panel;

    self.controls.itemPropsTabs = ISTabPanel:new(0, 0, panel.width, panel.height);
    self.controls.itemPropsTabs:initialise();
    self.controls.itemPropsTabs:instantiate();
    panel:addChild(self.controls.itemPropsTabs);

    local propsPanel = ISPanel:new(x, 0, self.controls.itemPropsTabs.width, self.controls.itemPropsTabs.height);
    propsPanel:initialise();
    propsPanel:instantiate();
    self.controls.itemPropsTabs:addView("Props", propsPanel);

    local row = self:addLabeledTextbox("minPrice", "Min Price", "Min Price", propsPanel, y)
    y = y + row.height + padding

    row = self:addLabeledTextbox("maxPrice", "Max Price", "Max Price", propsPanel, y)
    y = y + row.height + padding

    row = self:addLabeledTextbox("currency", "Currency", "Currency", propsPanel, y)
    y = y + row.height + padding

    row = self:addLabeledTextbox("minInventory", "Min Inventory", "Min Inventory", propsPanel, y)
    y = y + row.height + padding

    row = self:addLabeledTextbox("maxInventory", "Max Inventory", "Max Inventory", propsPanel, y)
    y = y + row.height + padding

    row = self:addLabeledTextbox("probability", "Probability", "Probability", propsPanel, y)
    y = y + row.height + padding

    self.controls.propsSkills = ISScrollingListBox:new(0, HEADER_HGT, self.controls.itemPropsTabs.width,
        self.controls.itemPropsTabs.height - HEADER_HGT);
    self.controls.propsSkills:initialise();
    self.controls.propsSkills:instantiate();
    self.controls.propsSkills.itemheight = FONT_HGT_SMALL + 6 * 2
    self.controls.propsSkills.selected = 0;
    self.controls.propsSkills.joypadParent = self;
    self.controls.propsSkills.font = UIFont.NewSmall;
    self.controls.propsSkills.doDrawItem = self.drawSkillDatas;
    self.controls.propsSkills:setOnMouseDoubleClick(self, function()
        local item = self.controls.propsSkills.items[self.controls.propsSkills.selected].item
        self:promptMinMaxSkills(item)
    end)
    self.controls.propsSkills:addColumn("Skill", 0);
    self.controls.propsSkills:addColumn("Requires", 200);

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
    self.controls.propsBoosts:setOnMouseDoubleClick(self, function()
        local item = self.controls.propsBoosts.items[self.controls.propsBoosts.selected].item
        self:promptMinMaxBoosts(item)
    end)

    self.controls.propsBoosts:addColumn("Boost", 0);
    self.controls.propsBoosts:addColumn("Requires", 200);

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

    self.controls.propsTraits.onRightMouseUp = function(target, x, y, a, b)
        local row = target:rowAt(x, y)
        if row == -1 then
            return
        end
        if target.selected ~= row then
            target.selected = row
            target:ensureVisible(target.selected)
        end
        local item = target.items[target.selected].item

        if item then
            local context = ISContextMenu.get(self.playerIndex, target:getAbsoluteX() + x,
                target:getAbsoluteY() + y + target:getYScroll())
            context:removeFromUIManager()
            context:addToUIManager()

            context:addOption("Required", self, function()
                if self.data.traits == nil then
                    self.data.traits = {}
                end
                self.data.traits[item.type] = true
            end, item)
            context:addOption("Forbidden", self, function()
                if self.data.traits == nil then
                    self.data.traits = {}
                end
                self.data.traits[item.type] = false
            end, item)
            context:addOption("No restriction", self, function()
                if self.data.traits == nil then
                    self.data.traits = {}
                end
                self.data.traits[item.type] = nil
            end, item)
        end
    end
    self.controls.propsTraits:setOnMouseDoubleClick(self, self.toggleTraitRequirement)

    self.controls.propsTraits:addColumn("Trait", 0);
    self.controls.propsTraits:addColumn("Requires", 200);

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

    self.controls.propsProf.onRightMouseUp = function(target, x, y, a, b)
        local row = target:rowAt(x, y)
        if row == -1 then
            return
        end
        if target.selected ~= row then
            target.selected = row
            target:ensureVisible(target.selected)
        end
        local item = target.items[target.selected].item

        if item then
            local context = ISContextMenu.get(self.playerIndex, target:getAbsoluteX() + x,
                target:getAbsoluteY() + y + target:getYScroll())
            context:removeFromUIManager()
            context:addToUIManager()

            context:addOption("Required", self, function()
                if self.data.professions == nil then
                    self.data.professions = {}
                end
                self.data.professions[item.type] = true
            end, item)
            context:addOption("Forbidden", self, function()
                if self.data.professions == nil then
                    self.data.professions = {}
                end
                self.data.professions[item.type] = false
            end, item)
            context:addOption("No restriction", self, function()
                if self.data.professions == nil then
                    self.data.professions = {}
                end
                self.data.professions[item.type] = nil
            end, item)
        end
    end

    self.controls.propsProf:setOnMouseDoubleClick(self, self.toggleProfRequirement)

    self.controls.propsProf:addColumn("Profession", 0);
    self.controls.propsProf:addColumn("Requires", 200);

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

    x = x + self.controls._panel.width + padding
    y = 0
    local infoPanel = ISPanel:new(x, y, self.width - x, h);
    infoPanel:initialise();
    infoPanel:instantiate();
    self:addChild(infoPanel);
    self.controls.infoPanel = infoPanel;

    local previewPanel = nil
    if self.item.source == "vehicles" then
        previewPanel = ISUI3DScene:new(10, 10, 180, 180)
        previewPanel:initialise()
        previewPanel.onMouseMove = function(self, dx, dy)
            if self.mouseDown then
                local vector = self:getRotation()
                local x = vector:x() + dy
                x = x > 90 and 90 or x < -90 and -90 or x
                self:setRotation(x, vector:y() + dx)
            end
        end
        previewPanel.setRotation = function(self, x, y)
            self.javaObject:fromLua3("setViewRotation", x, y, 0)
        end
        previewPanel.getRotation = function(self)
            return self.javaObject:fromLua0("getViewRotation")
        end

    else
        previewPanel = ISPanel:new(10, 10, 180, 180);
        previewPanel:initialise();
        previewPanel:instantiate();

        previewPanel.render = function(self)
            local item = self.parent.parent.item
            if item.texture then
                self:drawTextureScaledAspect(item.texture, 0, 0, self:getWidth(), self:getHeight(), 1)
            end
        end
    end
    infoPanel:addChild(previewPanel);
    self.controls.previewPanel = previewPanel;

    local label = getTextManager():WrapText(UIFont.Medium, self.item.label, infoPanel.width - 20)

    local name = ISLabel:new(10, 200, FONT_HGT_MEDIUM, label, 1, 1, 1, 1, UIFont.Medium, true);
    name:initialise();
    name:instantiate();
    infoPanel:addChild(name);
    self.controls.name = name;

    local category = ISLabel:new(10, name.y + name.height + 10, FONT_HGT_SMALL, self.item.category, 1, 1, 1, 1,
        UIFont.Small, true);
    category:initialise();
    category:instantiate();
    infoPanel:addChild(category);
    self.controls.category = category;

    local save = ISButton:new(previewPanel.x, infoPanel.height - BUTTON_HGT, previewPanel.width, BUTTON_HGT, "Save",
        self, UI.onSave);
    save:initialise();
    save:instantiate();
    if save.enableAcceptColor then
        save:enableAcceptColor()
    end
    save:setAnchorRight(true);
    save:setAnchorBottom(true);
    infoPanel:addChild(save);
    self.controls.save = save;

    local y = category.y + category.height + 10
    local description = ISRichTextPanel:new(previewPanel.x, y, previewPanel.width, save.y - y - 20);
    description:initialise();
    description:instantiate();
    description.borderColor = {
        r = 0.7,
        g = 0.7,
        b = 0.7,
        a = 1
    };
    description.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.8
    };
    description:setMargins(10, 10, 10, 10);
    description:setAnchorRight(true);
    description:setAnchorBottom(true);
    description.autosetheight = false
    description:setText("")
    description:paginate()
    infoPanel:addChild(description);
    self.controls.description = description;

    self:refreshAll()
end

function UI:instantiate()
    ISCollapsableWindowJoypad.instantiate(self);
    local previewPanel = self.controls.previewPanel
    previewPanel.initialized = true
    previewPanel.javaObject:fromLua1("setDrawGrid", false)
    previewPanel.javaObject:fromLua1("createVehicle", "vehicle")
    previewPanel.javaObject:fromLua3("setViewRotation", 45 / 2, 45, 0)
    previewPanel.javaObject:fromLua1("setView", "UserDefined")
    previewPanel.javaObject:fromLua2("dragView", 0, 30)
    previewPanel.javaObject:fromLua1("setZoom", 6)
    previewPanel.vehicleName = self.item.type
    previewPanel.javaObject:fromLua2("setVehicleScript", "vehicle", previewPanel.vehicleName)

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

function UI:promptMinMaxSkills(item)

    local list = self.controls.propsSkills
    if self.data.skills == nil then
        self.data.skills = {}
    end
    local data = {}
    if self.data.skills[item.type] then
        data = self.data.skills[item.type]
    end
    Core.ui.admin.minmax.open(self.player, item, {
        minMin = 0,
        maxMax = 10
    }, function(data)
        local s = self
        if self.data.skills == nil then
            self.data.skills = {}
        end
        if data.min or data.max then
            self.data.skills[item.type] = data
        else
            self.data.skills[item.type] = nil
        end
    end)
end

function UI:promptMinMaxBoosts(item)

    local list = self.controls.propsboosts
    if self.data.boosts == nil then
        self.data.boosts = {}
    end
    local data = {}
    if self.data.boosts[item.type] then
        data = self.data.boosts[item.type]
    end
    Core.ui.admin.minmax.open(self.player, data, {
        minMin = 0,
        maxMax = 3
    }, function(data)
        local s = self
        if self.data.boosts == nil then
            self.data.boosts = {}
        end
        if data.min or data.max then
            self.data.boosts[item.type] = data
        else
            self.data.boosts[item.type] = nil
        end
    end)
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

    local value = ""
    local data = self.parent.parent.parent.data
    if data.skills and data.skills[item.item.type] then
        if data.skills[item.item.type].min and data.skills[item.item.type].max then
            value = "Min: " .. data.skills[item.item.type].min .. " Max: " .. data.skills[item.item.type].max
        elseif data.skills[item.item.type].min then
            value = "Min: " .. data.skills[item.item.type].min
        elseif data.skills[item.item.type].max then
            value = "Max: " .. data.skills[item.item.type].max
        end
    end

    local cw = self.columns[2].size
    self:drawText(value, cw + 10, y + 4, 1, 1, 1, a, self.font);
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

    local value = ""
    local data = self.parent.parent.parent.data
    if data.boosts and data.boosts[item.item.type] then
        if data.boosts[item.item.type].min and data.boosts[item.item.type].max then
            value = "Min: " .. data.boosts[item.item.type].min .. " Max: " .. data.boosts[item.item.type].max
        elseif data.boosts[item.item.type].min then
            value = "Min: " .. data.boosts[item.item.type].min
        elseif data.boosts[item.item.type].max then
            value = "Max: " .. data.boosts[item.item.type].max
        end
    end

    local cw = self.columns[2].size
    self:drawText(value, cw + 10, y + 4, 1, 1, 1, a, self.font);
    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end

function UI:drawTraitDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local value = nil
    local data = self.parent.parent.parent.data.traits
    if data and data[item.item.type] ~= nil then
        if data[item.item.type] then
            value = "Required"
            self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.4, 0, 0.7, 0.15);
        else
            value = "Forbidden"
            self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.4, 1, 0, 0.15);
        end
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

    local cw = self.columns[2].size
    self:drawText(value or "", cw + 4, y + 4, 1, 1, 1, a, self.font);
    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end

function UI:drawProfDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local value = nil
    local data = self.parent.parent.parent.data.professions
    if data and data[item.item.type] ~= nil then
        if data[item.item.type] then
            value = "Required"
            self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.4, 0, 0.7, 0.15);
        else
            value = "Forbidden"
            self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.4, 1, 0, 0.15);
        end
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

    local cw = self.columns[2].size
    self:drawText(value or "", cw + 4, y + 4, 1, 1, 1, a, self.font);
    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end

function UI:prerender()
    ISCollapsableWindowJoypad.prerender(self);

    local padding = 0
    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()
    local w = self.width - 200 - padding
    local h = self.height - rh - th
    local x = padding
    local y = padding + th

    local panel = self.controls._panel

    panel:setX(x)
    panel:setY(y)
    panel:setWidth(w)
    panel:setHeight(h)
    panel:updateScrollbars();

    local itemPropsTabs = self.controls.itemPropsTabs
    itemPropsTabs:setX(0)
    itemPropsTabs:setY(10)
    itemPropsTabs:setWidth(itemPropsTabs.parent.width)
    itemPropsTabs:setHeight(itemPropsTabs.parent.height)

    local viewY = y + HEADER_HGT + 4
    local viewH = itemPropsTabs.height - viewY

    local propsSkills = self.controls.propsSkills
    propsSkills:setX(x)
    propsSkills:setY(viewY)
    propsSkills:setWidth(w)
    propsSkills:setHeight(viewH)

    local propsBoosts = self.controls.propsBoosts
    propsBoosts:setX(x)
    propsBoosts:setY(viewY)
    propsBoosts:setWidth(w)
    propsBoosts:setHeight(viewH)

    local propsTraits = self.controls.propsTraits
    propsTraits:setX(x)
    propsTraits:setY(viewY)
    propsTraits:setWidth(w)
    propsTraits:setHeight(viewH)

    local propsProf = self.controls.propsProf
    propsProf:setX(x)
    propsProf:setY(viewY)
    propsProf:setWidth(w)
    propsProf:setHeight(viewH)

    local purchaseLimitsPanel = self.controls.purchaseLimitsPanel
    purchaseLimitsPanel:setX(x)
    purchaseLimitsPanel:setY(y)
    purchaseLimitsPanel:setWidth(w)
    purchaseLimitsPanel:setHeight(h)

    local infoPanel = self.controls.infoPanel
    infoPanel:setX(self.width - infoPanel.width + 10)
    infoPanel:setY(y)
    infoPanel:setHeight(h)

    if self.lastActiveViewName ~= itemPropsTabs.activeView.name then
        self.lastActiveViewName = itemPropsTabs.activeView.name
        local txt = ""
        if itemPropsTabs.activeView.name == "Skills" then
            txt =
                "Skills: Double click to set min/max levels required to purchase this item. Leave the value blank to ignore."
        elseif itemPropsTabs.activeView.name == "Boosts" then
            txt =
                "Boosts: Double click to set min/max levels required to purchase this item. Leave the value blank to ignore."
        elseif itemPropsTabs.activeView.name == "Traits" then
            txt =
                "Traits: Right click to set if the trait is required, forbidden or no restriction. You can also toggle between states by double clicking"
        elseif itemPropsTabs.activeView.name == "Professions" then
            txt =
                "Professions: Right click to set if the profession is required, forbidden or no restriction. You can also toggle between states by double clicking"
        elseif itemPropsTabs.activeView.name == "Purchase Limits" then
            txt =
                "Purchase Limits: Set the limits to how many times this item can be purchased. Leave the value blank to ignore."
        elseif itemPropsTabs.activeView.name == "Props" then
            txt =
                "Props: Set the min/max price, currency, inventory and probability of this item. Leave blank to use defaults"
        end

        self.controls.description:setText(txt)
        self.controls.description:paginate()
        self.controls.description.textDirty = true;

    end

    self.controls.save:setHeight(BUTTON_HGT)
    self.controls.save:setY(infoPanel.height - BUTTON_HGT - 10)
end

function UI:toggleTraitRequirement(item)
    self:toggleRequirement("traits", item)
end

function UI:toggleProfRequirement(item)
    self:toggleRequirement("professions", item)
end

function UI:toggleRequirement(source, item)

    if not self.data[source] then
        self.data[source] = {}
    end

    if self.data[source][item.type] == nil then
        self.data[source][item.type] = true
    elseif self.data[source][item.type] == true then
        self.data[source][item.type] = false
    else
        self.data[source][item.type] = nil
    end
end
