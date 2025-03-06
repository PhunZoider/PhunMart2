if isServer() then
    return
end

require "ISUI/ISCollapsableWindowJoypad"
local Core = PhunMart
local PL = PhunLib

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2
local BUTTON_HGT = FONT_HGT_SMALL + 6

local profileName = "PhunMartUIAdminShops"
PhunMartUIAdminShops = ISCollapsableWindowJoypad:derive(profileName);
local UI = PhunMartUIAdminShops
local instances = {}
Core.ui.admin.shops = UI

function UI.OnOpenPanel(playerObj)

    local playerIndex = playerObj:getPlayerNum()
    local instance = instances[playerIndex]

    if not instance then
        local core = getCore()
        local FONT_SCALE = getTextManager():getFontHeight(UIFont.Small) / 14
        local width = 450 * FONT_SCALE
        local height = 590 * FONT_SCALE

        local x = (core:getScreenWidth() - width) / 2
        local y = (core:getScreenHeight() - height) / 2

        instances[playerIndex] = UI:new(x, y, width, height, playerObj, playerIndex);
        instance = instances[playerIndex]
        instance:initialise();

        ISLayoutManager.RegisterWindow(profileName, PhunMartUIAdminShops, instance)
    end

    instance:addToUIManager();
    instance:setVisible(true);
    instance:ensureVisible()
    instance:refreshShops()
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
    o:setTitle("PhunMart")
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

function UI:setSelected(item)
    self.controls.list.selected = item
end

function UI:createChildren()

    ISCollapsableWindowJoypad.createChildren(self);

    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()

    local padding = 10
    local x = padding
    local y = th + padding
    local w = self.width - padding * 2
    local h = self.height - y - rh - padding

    self.controls = {}

    self.controls.list = ISScrollingListBox:new(x, y + HEADER_HGT, 200, self.height - HEADER_HGT - 100);
    self.controls.list:initialise();
    self.controls.list:instantiate();
    self.controls.list.itemheight = FONT_HGT_SMALL + 4 * 2
    self.controls.list.selected = 0;
    self.controls.list.joypadParent = self;
    self.controls.list.font = UIFont.NewSmall;
    self.controls.list.doDrawItem = self.drawDatas;

    self.controls.list.onRightMouseUp = function(target, x, y, a, b)
        local row = target:rowAt(x, y)
        if row == -1 then
            return
        end
        if target.selected ~= row then
            target.selected = row
            target:ensureVisible(target.selected)
        end
        local item = target.items[target.selected].item

    end

    self.controls.list:setOnMouseDownFunction(self, function()

        if self.controls.list.selected ~= self.lastSelected then
            -- prompt to save changes if isDirty
            local propsIsDirty = self.controls.props:isDirty()
            local poolsIsDirty = self.controls.pools:isDirty()
            if propsIsDirty or poolsIsDirty then
                local w = 300 * FONT_SCALE
                local h = 200 * FONT_SCALE
                local modal = ISModalDialog:new(getCore():getScreenWidth() / 2 - w / 2,
                    getCore():getScreenHeight() / 2 - h / 2, w, h, getText("IGUI_Confirmation"), true, self,
                    self.onSaveChanges);
                modal:initialise();
                modal:addToUIManager();
                modal:setAlwaysOnTop(true);
                return
            end
        end

        local selectedIndex = self.controls.list.selected
        if selectedIndex == nil or selectedIndex < 0 then
            return
        end

        -- if self.controls.props:isDirty() or self.controls.pools:isDirty() then
        --     local w = 300 * FONT_SCALE
        --     local h = 200 * FONT_SCALE
        --     local modal = ISModalDialog:new(getCore():getScreenWidth() / 2 - w / 2,
        --         getCore():getScreenHeight() / 2 - h / 2, w, h, getText("IGUI_Confirmation"), true, self,
        --         self.onSaveChanges);
        --     modal:initialise();
        --     modal:addToUIManager();
        --     modal:setAlwaysOnTop(true);
        --     return
        -- end

        local selectedItem = self.controls.list.items[selectedIndex]
        if selectedItem then

            local props = PL.table.deepCopy(Core.shops[selectedItem.item.key])
            if not props.key then
                props.key = selectedItem.item.key
            end
            if not props.group then
                props.group = "NONE"
            end

            self.controls.props:setData(props)
            self.controls.pools:setData(props)
        else
            self.controls.props:setData(nil)
            self.controls.pools:setData(nil)
        end
    end)

    self.controls.list.drawBorder = true;
    self.controls.list:addColumn("Shop", 0);
    self.controls.list:addColumn("Group", 140);
    self:addChild(self.controls.list);

    x = self.controls.list.x + self.controls.list.width + padding

    self.tabPanel = ISTabPanel:new(x, y, w, h - y - padding - 45);
    self.tabPanel:initialise()
    self:addChild(self.tabPanel)

    self.controls.props = Core.ui.admin.propEditor:new(0, 100, self.tabPanel.width,
        self.tabPanel.height - self.tabPanel.tabHeight, {
            player = self.player
        });
    self.controls.props:initialise()
    self.tabPanel:addView("Properties", self.controls.props)

    self.controls.pools = Core.ui.admin.poolsEditor:new(0, 100, self.tabPanel.width,
        self.tabPanel.height - self.tabPanel.tabHeight, {
            player = self.player
        });
    self.controls.pools:initialise()
    self.tabPanel:addView("Pools", self.controls.pools)

    self.locations = PhunMartUIAdminLocations:new(0, 100, self.tabPanel.width,
        self.tabPanel.height - self.tabPanel.tabHeight, {
            player = self.player
        });

    self.tabPanel:addView("Instances", self.locations)

    -- self.pools = PhunMartUIAdminPools:new(0, 100, self.tabPanel.width, self.tabPanel.height - self.tabPanel.tabHeight, {
    --     player = self.player
    -- });
    -- self.tabPanel:addView("Pools", self.pools)

    -- self.sprites = PhunMartUIShopSprites:new(0, 100, self.tabPanel.width,
    --     self.tabPanel.height - self.tabPanel.tabHeight, {
    --         player = self.player
    --     });
    -- self.tabPanel:addView("Sprites", self.sprites)

    -- save button

    self.save = ISButton:new(self.width - padding - 100, self.height - rh - padding - 35, 100, 35,
        getText("UI_btn_save"), self, self.onSaveChanges);
    self.save.internal = "SAVE";
    self.save:initialise();
    self.save:instantiate();
    if self.save.enableAcceptColor then
        self.save:enableAcceptColor()
    end
    self:addChild(self.save);

end

function UI:prerender()

    ISCollapsableWindowJoypad.prerender(self);

    local x = self.controls.list.x + self.controls.list.width + 10
    local y = self.controls.list.y - HEADER_HGT
    local w = self.width - x - 10
    local h = self.height - y - (10 * 2) - HEADER_HGT

    self.controls.list:setHeight(h)

    self.tabPanel:setWidth(w)
    self.tabPanel:setHeight(h - 45)
    self.tabPanel:setX(x)
    self.tabPanel:setY(y)

    self.tabPanel.activeView.view:setWidth(w)
    self.tabPanel.activeView.view:setHeight(h - 45)

    self.save:setX(self.width - 100 - 10)
    self.save:setY(self.height - self:resizeWidgetHeight() - 35 - 10)
end

function UI:refreshShops()

    self.controls.list:clear()
    for k, v in pairs(Core.shops) do
        self.controls.list:addItem(getTextOrNull("IGUI_PhunMart_Shop_" .. k) or k, {
            key = k,
            group = v.group or "NONE"
        })
    end

end

function UI:drawDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9;

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.7, 0.35, 0.15);
    end

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.6, 0.5, 0.5);
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

    self:setStencilRect(clipX, clipY, clipX2 - clipX, clipY2 - clipY)
    self:drawText(item.text, xoffset, y + 4, 1, 1, 1, a, self.font);
    self:clearStencilRect()

    local value = item.item.group

    local valueWidth = getTextManager():MeasureStringX(self.font, value)
    local w = self.width
    local cw = self.columns[2].size
    self:drawText(value, cw + 4, y + 4, 1, 1, 1, a, self.font);

    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end

local zones = nil

function UI:refreshLocations(instances)
    self.locations:setData(instances)
end

function UI:refreshItems(items)
    self.pools:setItems(items)
end

function UI:onSaveChanges(a, b)

    local data = self.controls.props:getData()
    local pools = self.controls.pools:getData()
    data.pools = pools

    PL.debug("data", data, "----")

    print(tostring(a) .. " " .. tostring(b))
end
