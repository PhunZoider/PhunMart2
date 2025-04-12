if isServer() then
    return
end

require "ISUI/ISCollapsableWindowJoypad"
local tools = require "PhunMart2/ux/tools"
local Core = PhunMart
local PL = PhunLib
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2
local BUTTON_HGT = FONT_HGT_SMALL + 6

local profileName = "PhunMartUIShopConfig"

Core.ui.shop_config = ISCollapsableWindowJoypad:derive(profileName);
local UI = Core.ui.shop_config
local instances = {}

function UI:refreshAll()

end

function UI.open(player, shopKey)

    local playerIndex = player:getPlayerNum()

    local core = getCore()
    local width = 600 * FONT_SCALE
    local height = 400 * FONT_SCALE

    local x = (core:getScreenWidth() - width) / 2
    local y = (core:getScreenHeight() - height) / 2

    local instance = UI:new(x, y, width, height, player, playerIndex, shopKey);
    instance:initialise();

    ISLayoutManager.RegisterWindow(profileName, UI, instance)

    instance.shopKey = shopKey or nil
    instance:addToUIManager();
    instance:setVisible(true);
    instance:ensureVisible()
    instance:refreshAll()
    return instance;
end

function UI:new(x, y, width, height, player, playerIndex, shopKey)
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
    o.shopKey = shopKey
    o.zOffsetLargeFont = 25;
    o.zOffsetMediumFont = 20;
    o.zOffsetSmallFont = 6;
    o:setWantKeyEvents(true)
    local title = getTextOrNull("IGUI_PhunMart_Shop_" .. shopKey) or shopKey or "Locations"
    o:setTitle(title)
    return o;
end

function UI:RestoreLayout(name, layout)

    ISLayoutManager.DefaultRestoreWindow(self, layout)
    if name == profileName then
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

function UI:onResize()
    ISCollapsableWindowJoypad.onResize(self)
    local tabPanel = self.controls.tabPanel
    local padding = 10
    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()
    tabPanel:setX(padding)
    tabPanel:setY(th)
    tabPanel:setWidth(self.width - padding * 2)
    tabPanel:setHeight(self.height - th - rh)
    for _, view in ipairs(tabPanel.viewList) do
        view.view:setWidth(tabPanel.width)
        view.view:setHeight(tabPanel.height - tabPanel.tabHeight)
    end
end

function UI:createChildren()

    ISCollapsableWindowJoypad.createChildren(self);

    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()

    local padding = 10
    local x = 0
    local y = th
    local w = self.width
    local h = self.height - rh - th

    self.controls = {}

    local tabPanel = tools.getTabPanel(x, y, w, h)

    self.controls.tabPanel = tabPanel
    self:addChild(tabPanel)

    local props = Core.ui.propEditor:new(0, 0, w, h, {
        player = self.player
    })
    self.controls.props = props
    self.controls.tabPanel:addView("Props", props)

    local pools = Core.ui.pools:new(0, 100, tabPanel.width, tabPanel.height - tabPanel.tabHeight, {
        player = self.player
    });
    pools:initialise()
    self.controls.pools = pools
    self.controls.tabPanel:addView("Pools", self.controls.pools)

    self:refreshAll()
    self:bringToTop()
end

function UI:isKeyConsumed(key)
    return key == Keyboard.KEY_ESCAPE
end

function UI:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        self:close()
    end
end
