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

local profileName = "PhunMartUIShopItemsList"
PhunMartUIShopItemsList = ISPanelJoypad:derive(profileName);
local UI = PhunMartUIShopItemsList
local instances = {}
Core.ui.client.shopItemsList = UI

function UI:setData(data)

end

function UI:getData()

end

function UI:isValid()

end

function UI:isDirty()
    local isDirty = self.isDirtyValue

    return isDirty
end

function UI:new(x, y, width, height, options)
    local opts = options or {}
    local o = ISPanelJoypad:new(x, y, width, height);
    setmetatable(o, self);
    o.player = opts.player or getPlayer()
    o.playerIndex = o.player:getPlayerNum()
    o:setWantKeyEvents(true)
    self.instance = o;
    return o;
end

function UI:createChildren()

    ISPanelJoypad.createChildren(self)

    local offset = 10
    local x = offset
    local y = HEADER_HGT
    local h = FONT_HGT_MEDIUM
    local w = self.width - offset * 2

    self.controls = {}
    self.controls._panel = ISPanel:new(x, y, self.width - self.scrollwidth - offset * 2,
        self.height - y - 10 - BUTTON_HGT - offset);
    self.controls._panel:initialise();
    self.controls._panel:instantiate();
    self.controls._panel:setAnchorRight(true)
    self.controls._panel:setAnchorLeft(true)
    self.controls._panel:setAnchorTop(true)
    self.controls._panel:setAnchorBottom(true)
    self.controls._panel:addScrollBars()
    self.controls._panel.vscroll:setVisible(true)

    self.controls._panel.prerender = function(s)
        s:setStencilRect(0, 0, s.width, s.height);
        ISPanel.prerender(s)
    end
    self.controls._panel.render = function(s)
        ISPanel.render(s)
        s:clearStencilRect()
    end
    self.controls._panel.onMouseWheel = function(s, del)
        if s:getScrollHeight() > 0 then
            s:setYScroll(s:getYScroll() - (del * 40))
            return true
        end
        return false
    end

    self.controls._panel.backgroundColor = {
        r = 0,
        g = 1,
        b = 0,
        a = 0.7
    }

    self:addChild(self.controls._panel);

    self.controls.tabPanel = ISTabPanel:new(x, 100, w, h - y - offset);
    self.controls.tabPanel:initialise()
    self.controls.tabPanel:instantiate()

    self.controls._panel:addChild(self.controls.tabPanel)

    self.controls._panel:setScrollHeight(y + h + 10);
    self.controls._panel:setScrollChildren(true)

    self.controls._panel:setScrollHeight(y + h + 10);
    self.controls._panel:setScrollChildren(true)

    self.tooltip = ISToolTip:new();
    self.tooltip:initialise();
    self.tooltip:setVisible(false);
    -- self.tooltip:setName("Summary");
    self.tooltip:setAlwaysOnTop(true)
    self.tooltip.description = "";
    self.tooltip:setOwner(self.tabPanel)

    local itemInstance = getScriptManager():getItem("Base.Money")
    local invItem = instanceItem("Base.Money")
    self.invTooltip = ISToolTipInv:new(invItem);
    self.invTooltip:initialise()
    self.invTooltip:addToUIManager()
    self.invTooltip:setVisible(true)
    self.invTooltip:setOwner(self.tabPanel)
    self.invTooltip:setCharacter(self.viewer)

end

function UI:doDrawItem(y, row, alt)

    local shop = self.parent.parent.shop
    if not shop then
        return
    end
    local item = shop.items[row.text]
    if not item then
        return y
    end
    local display = row.item or {}

    local inventoryVal = 0
    local itemAlpha = 1
    local textAlpha = 0.5
    local isOutOfStock = false
    local isInfiniteInventory = item.inventory == false
    if isInfiniteInventory then
        inventoryVal = " - "
    elseif item.inventory == 0 then
        inventoryVal = "out of stock"
        itemAlpha = 0.5
        isOutOfStock = true
    else
        inventoryVal = PL.string.formatWholeNumber(item.inventory)
    end

    self:drawRectBorder(0, y, self:getWidth(), row.height, 0.5, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)

    if self.selected == row.index then
        self:drawRect(0, (y), self:getWidth(), row.height - 1, 0.3, 0.7, 0.35, 0.15);
    end

    local x = self.itemPadY
    local x2 = self.itemPadY

    if display.textureVal then
        local textured = self:drawTextureScaledAspect2(display.textureVal, x, y + 10, self.textureHeight,
            self.textureHeight, itemAlpha, 1, 1, 1)
    end
    if display.overlayVal then
        local textured = self:drawTextureScaledAspect2(display.overlayVal, x, y + 10, self.textureHeight,
            self.textureHeight, itemAlpha, 1, 1, 1)

    end

    if display.hasBeenReadVal then
        local th = self.textureHeight * .5
        if display.hasBeenReadVal.status then
            local textured = self:drawTextureScaledAspect2(display.hasBeenReadVal.status, x,
                y + self.textureHeight - 10, th, th, itemAlpha, 1, 1, 1)
        end
        if display.hasBeenReadVal.marking then
            local textured = self:drawTextureScaledAspect2(display.hasBeenReadVal.marking, x + 20,
                y + self.textureHeight - 10, th, th, itemAlpha, 1, 1, 1)
        end
        if display.hasBeenReadVal.current then
            local textured = self:drawTextureScaledAspect2(display.hasBeenReadVal.current, x, y + 10,
                self.textureHeight, self.textureHeight, itemAlpha, 1, 1, 1)
        end
    end

    x = x + self.itemPadY + self.textureHeight
    x2 = x

    local txt = nil

    txt = getText("IGUI_PhunMartInventoryAmount", inventoryVal)
    self:drawText(txt, x, (y + FONT_HGT_MEDIUM + 3 * FONT_SCALE) + 10, 0.7, 0.7, 0.7, 1.0, UIFont.Small)
    x = x + getTextManager():MeasureStringX(UIFont.Small, txt)

    x = x2
    self:drawText(display.labelVal, x, y + 10, 0.7, 0.7, 0.7, 1.0, self.font)

    return y + row.height
end

function UI:prerender()

    ISPanelJoypad.prerender(self)

end
