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

local profileName = "PhunMartUIPoolEditorItems"
PhunMartUIPoolEditorItems = ISCollapsableWindowJoypad:derive(profileName);
local UI = PhunMartUIPoolEditorItems
local instances = {}
Core.ui.poolEditor = UI

function UI.OnOpenPanel(playerObj, pool)

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

        ISLayoutManager.RegisterWindow(profileName, PhunMartUIPoolEditorItems, instance)
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

    y = y + self.controls.pools.height + padding

    self.controls.tabPanel = ISTabPanel:new(x, y, w, h - y);
    self.controls.tabPanel:initialise()
    self:addChild(self.controls.tabPanel)

    self.controls.items = Core.ui.poolEditorGroup:new(0, 100, w, self.controls.tabPanel.height - th, {
        player = self.player
    });

    self.controls.vehicles = Core.ui.poolEditorGroup:new(0, 100, w, self.controls.tabPanel.height - th, {
        player = self.player,
        type = "VEHICLES"
    });

    self.controls.traits = Core.ui.poolEditorGroup:new(0, 100, w, self.controls.tabPanel.height - th, {
        player = self.player,
        type = "TRAITS"
    });

    self.controls.tabPanel:addView("Items", self.controls.items)
    self.controls.tabPanel:addView("Vehicles", self.controls.vehicles)
    self.controls.tabPanel:addView("Traits", self.controls.traits)

    self.controls.ok = ISButton:new(padding, self.height - rh - padding - FONT_HGT_SMALL, 100, FONT_HGT_SMALL + 4, "OK",
        self, UI.onOK);
    self.controls.ok:initialise();
    self.controls.ok:instantiate();
    self:addChild(self.controls.ok);

    self:refreshAll()
end

function UI:setPool(pool)
    local groups = require("PhunMart2/data/groups")
    local group = groups[pool]
    self:setTitle("Pool: " .. pool)

    local items = group.items or {}
    items.categories = items.categories or {}
    items.include = items.include or {}
    items.exclude = items.exclude or {}

    local vehicles = group.vehicles or {}
    vehicles.categories = vehicles.categories or {}
    vehicles.include = vehicles.include or {}
    vehicles.exclude = vehicles.exclude or {}

    local traits = group.traits or {}
    traits.categories = traits.categories or {}
    traits.include = traits.include or {}
    traits.exclude = traits.exclude or {}

    self.controls.items:setData(items)
    self.controls.vehicles:setData(vehicles)
    self.controls.traits:setData(traits)

end

function UI:refreshAll()

    local groups = require("PhunMart2/data/groups")
    self.controls.pools:clear()
    for k, v in pairs(groups) do
        self.controls.pools:addOption(k)
    end

    self.controls.items:refreshAll()
    self.controls.vehicles:refreshAll()
    self.controls.traits:refreshAll()

end

function UI:prerender()

    ISCollapsableWindowJoypad.prerender(self);

    self.controls.ok:setX(self.width - self.controls.ok.width - 10)
    self.controls.ok:setY(self.height - self.controls.ok.height - self:resizeWidgetHeight() - 10)
    self.controls.tabPanel:setWidth(self.width - 20)
    self.controls.tabPanel:setHeight(self.controls.ok.y - self.controls.tabPanel.y - 50)
end

function UI:onOK()
    print("OK")

    local selected = {
        items = self.controls.items:getSelected(),
        vehicles = self.controls.vehicles:getSelected(),
        traits = self.controls.traits:getSelected()
    }

    PhunLib:debug(selected)

end
