require "ISUI/ISCollapsableWindowJoypad"
local Core = PhunMart

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2

local profileName = "PhunMartUIPoolEditorItems"
PhunMartUIPoolEditorItems = ISPanelJoypad:derive(profileName);
local UI = PhunMartUIPoolEditorItems
local instances = {}
Core.ui.poolEditorItems = UI

function UI.OnOpenPanel(playerObj, data)

    local playerIndex = playerObj:getPlayerNum()
    local instance = instances[playerIndex]

    if not instance then
        local core = getCore()
        local width = 450 * FONT_SCALE
        local height = 400 * FONT_SCALE

        local x = (core:getScreenWidth() - width) / 2
        local y = (core:getScreenHeight() - height) / 2

        instances[playerIndex] = UI:new(x, y, width, height, playerObj, playerIndex);
        instance = instances[playerIndex]
        instance:initialise();

    end

    instance.data = data or {}
    instance:refreshAll()

    instance:addToUIManager();
    instance:setVisible(true);
    instance:ensureVisible()

    return instance;

end

function UI:new(x, y, width, height, data)
    local o = {};
    o = ISPanelJoypad:new(x, y, width, height, data.player);
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
    o.listType = data.type or nil
    o.moveWithMouse = false;
    o.anchorRight = true
    o.anchorBottom = true
    o.player = data.player
    o.playerIndex = o.player:getPlayerNum()
    o.zOffsetLargeFont = 25;
    o.zOffsetMediumFont = 20;
    o.zOffsetSmallFont = 6;
    o:setWantKeyEvents(true)
    return o;
end

function UI:createChildren()
    ISPanelJoypad.createChildren(self);

    local padding = 10
    local x = padding
    local y = 50
    local w = self.width - x - padding

    local h = self.height - y

    self.tabPanel = ISTabPanel:new(x, y, w, h - y);
    self.tabPanel:initialise()
    self:addChild(self.tabPanel)

    self.categories = PhunMartUIItemCats:new(0, y, w, self.tabPanel.height, {
        player = self.player,
        type = self.listType
    });

    self.exclusions = PhunMartUIItemList:new(0, y, w, self.tabPanel.height, {
        player = self.player,
        type = self.listType
    });

    self.inclusions = PhunMartUIItemList:new(0, y, w, self.tabPanel.height, {
        player = self.player,
        type = self.listType
    });

    self.tabPanel:addView("Categories", self.categories)
    self.tabPanel:addView("Inclusions", self.inclusions)
    self.tabPanel:addView("Exclusions", self.exclusions)

    self.ok =
        ISButton:new(padding, self.height - padding - FONT_HGT_SMALL, 100, FONT_HGT_SMALL + 4, "OK", self, UI.onOK);
    self.ok:initialise();
    self.ok:instantiate();
    self:addChild(self.ok);

end

function UI:refreshAll()

    -- self.categories.list:clear()
    -- self.inclusions.list:clear()
    -- self.exclusions.list:clear()

    -- local categories = Core.getAllItemCategories()
    -- local inclusions = Core.getAllItems()
    -- local exclusions = Core.getAllItems()

    -- for i = 1, #categories do
    --     local category = categories[i]
    --     self.categories.list:addItem(category.label, {
    --         data = category,
    --         selected = self.data and self.data.categories and self.data.categories[category.label]
    --     })
    -- end

    self.categories:setData(self.data.categories)
    self.inclusions:setData(self.data.include)
    self.exclusions:setData(self.data.exclude)

    -- for i = 1, #inclusions do
    --     local inclusion = inclusions[i]
    --     self.inclusions.list:addItem(inclusion.label, {
    --         data = inclusion,
    --         selected = self.data and self.data.include and self.data.include[inclusion.type]
    --     })
    -- end

    -- for i = 1, #exclusions do
    --     local exclusion = exclusions[i]
    --     self.exclusions.list:addItem(exclusion.label, {
    --         data = exclusion,
    --         selected = self.data and self.data.exclude and self.data.exclude[exclusion.type]
    --     })
    -- end

end
