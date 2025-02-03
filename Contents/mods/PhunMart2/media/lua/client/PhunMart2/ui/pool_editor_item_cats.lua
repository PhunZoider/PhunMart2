if isServer() then
    return
end

local sandbox = SandboxVars.PhunMart

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2

local Core = PhunMart
local profileName = "PhunMartUIItemCats"
PhunMartUIItemCats = ISPanelJoypad:derive(profileName);
local UI = PhunMartUIItemCats

function UI:new(x, y, width, height, options)
    local opts = options or {}
    local o = ISPanelJoypad:new(x, y, width, height);
    setmetatable(o, self);
    o.player = opts.player or getPlayer()
    o.playerIndex = o.player:getPlayerNum()
    o.listType = options.type or nil
    o.lastSelected = nil
    self.instance = o;
    return o;
end

function UI:prerender()
    ISPanelJoypad.prerender(self)
    local padding = 10
    local maxWidth = self.parent.activeView.view.width
    local maxHeight = self.parent.height - HEADER_HGT -- BUTTON_HGT - padding * 2
    self:setWidth(maxWidth)
    self:setHeight(maxHeight)
    self.list:setHeight(maxHeight - HEADER_HGT)
end

function UI:createChildren()
    ISPanelJoypad.createChildren(self)

    local padding = 10
    local x = 0
    local y = HEADER_HGT - 1

    self.list = ISScrollingListBox:new(x, y, self:getWidth(), self.height - HEADER_HGT);
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
        local data = list.parent.data.selected
        data[item.type] = data[item.type] == nil and true or nil

        if isShiftKeyDown() and self.lastSelected then
            local start = math.min(row, self.lastSelected)
            local finish = math.max(row, self.lastSelected)
            for i = start, finish do
                data[list.items[i].item.type] = data[item.type]
            end
        end
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
    self.list:addColumn("Category", 0);
    self:addChild(self.list);

    self.data = {
        selected = {}
    }
    if not self.listType then
        self.data.categories = Core.getAllItemCategories()
    elseif self.listType == "VEHICLES" then
        self.data.categories = Core.getAllVehicleCategories()
    end

end

function UI:drawDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9;

    if self.parent.data.selected[item.item.type] then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.4, 0.7, 0.35, 0.15);
    end

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.2, 0.6, 0.5, 0.5);
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b);

    local iconX = 4
    local iconSize = FONT_HGT_SMALL;
    local xoffset = 10;

    self:drawText(item.text, xoffset, y + 4, 1, 1, 1, a, self.font);

    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end

function UI:setData(data)

    self.list:clear();
    self.lastSelected = nil

    self.data.selected = {}
    for k, item in ipairs(data or {}) do
        self.data.selected[k] = true
    end

    for _, item in ipairs(self.data.categories or {}) do
        self.list:addItem(item.label, item);
    end
end
