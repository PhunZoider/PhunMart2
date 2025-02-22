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

local profileName = "PhunMartUIAdminItem"
PhunMartUIAdminItem = ISCollapsableWindowJoypad:derive(profileName);
local UI = PhunMartUIAdminItem
local instances = {}
Core.ui.admin.item = instances

function UI.OnOpenPanel(playerObj, playerIndex, item)

    playerIndex = playerIndex or playerObj:getPlayerNum()
    local instance = instances[playerIndex]

    if not instance then
        local core = getCore()
        local FONT_SCALE = getTextManager():getFontHeight(UIFont.Small) / 14
        local width = 400 * FONT_SCALE
        local height = 590 * FONT_SCALE

        local x = (core:getScreenWidth() - width) / 2
        local y = (core:getScreenHeight() - height) / 2

        instances[playerIndex] = UI:new(x, y, width, height, playerObj, playerIndex);
        instance = instances[playerIndex]
        instance:initialise();
        ISLayoutManager.RegisterWindow(profileName, PhunMartUIAdminItem, instances)
    end

    instance:addToUIManager();
    instance:setVisible(true);
    instance:ensureVisible()

    instance:setData(item)
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
    o:setTitle("Item")
    return o;
end

function UI:RestoreLayout(name, layout)

    ISLayoutManager.DefaultRestoreWindow(self, layout)
    if name == "PhunMartUIAdminItem" then
        ISLayoutManager.DefaultRestoreWindow(self, layout)
        self.userPosition = layout.userPosition == 'true'
    end
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

function UI:prerender()

    ISCollapsableWindowJoypad.prerender(self);
    local xoffset = 10;
    local y = self:titleBarHeight() + 10
    if self.displayTexture then
        self:drawTextureScaledAspect(self.displayTexture, xoffset, y, 32, 32, 1, 1, 1, 1);
        xoffset = xoffset + 36
    end
    self:drawText(self.displayLabel, xoffset, y, 1, 1, 1, 1, UIFont.Medium);

end

function UI:createChildren()

    ISCollapsableWindowJoypad.createChildren(self);

    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()

    local padding = 10
    local x = padding
    local y = th + 100 + padding
    local w = self.width - padding * 2
    local h = self.height - rh - padding

    -- y = y + self.displayTitle.height + padding
    self.tabPanel = ISTabPanel:new(x, y, w, h - y - padding);
    self.tabPanel:initialise()
    self:addChild(self.tabPanel)

    self.properties = PhunMartUIItemProps:new(0, 100, self.tabPanel.width,
        self.tabPanel.height - self.tabPanel.tabHeight, {
            player = self.player
        });
    self.tabPanel:addView("Properties", self.properties)

    self.conditions = PhunMartUIItemProps:new(0, 100, self.tabPanel.width,
        self.tabPanel.height - self.tabPanel.tabHeight, {
            player = self.player
        });
    self.tabPanel:addView("Conditions", self.conditions)

    self.display = PhunMartUIAdminItemDisplay:new(0, 100, self.tabPanel.width,
        self.tabPanel.height - self.tabPanel.tabHeight, {
            player = self.player
        });
    self.tabPanel:addView("Display", self.display)

    self.receive = PhunMartUIAdminItemReceive:new(0, 100, self.tabPanel.width,
        self.tabPanel.height - self.tabPanel.tabHeight, {
            player = self.player
        });
    self.tabPanel:addView("Receive", self.receive)

end

function UI:setData(data)

    self.displayTexture = Core:getTextureFromItem(data.display) or nil
    self.displayLabel = Core:getLabelFromItem(data.display) or "None"
    self:setTitle(self.displayLabel or "Item")

    self.properties:setData(data)

    PhunTools:printTable(data)
end
