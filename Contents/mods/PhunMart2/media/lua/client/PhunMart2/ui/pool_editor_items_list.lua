if isServer() then
    return
end

local sandbox = SandboxVars.PhunMart

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2
local BUTTON_HGT = FONT_HGT_SMALL + 6
local LABEL_HGT = FONT_HGT_MEDIUM + 6

local Core = PhunMart
local profileName = "PhunMartUIItemList"
PhunMartUIItemList = ISPanelJoypad:derive(profileName);
local UI = PhunMartUIItemList

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

function UI:createChildren()
    ISPanelJoypad.createChildren(self)

    local padding = 10
    local x = padding
    local y = HEADER_HGT - 1

    self.list = ISScrollingListBox:new(0, y, self:getWidth(), 300);
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

        -- range select
        if isShiftKeyDown() and self.lastSelected then
            local start = math.min(row, self.lastSelected)
            local finish = math.max(row, self.lastSelected)
            for i = start, finish do
                data[list.items[i].item.type] = data[item.type]
            end
        end

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
    self.list:addColumn("Item", 0);
    self.list:addColumn("Category", 300);
    self:addChild(self.list);

    self.filters = ISPanel:new(0, 200, self.width, 100);
    self.filters.drawBorder = false
    self.filters:initialise();
    self.filters:instantiate();
    self:addChild(self.filters);

    self.filter = ISTextEntryBox:new("", x, y, self.width, BUTTON_HGT);
    self.filter.onTextChange = function()
        self:refreshData()
    end
    self.filter:initialise();
    self.filter:instantiate();
    self.filters:addChild(self.filter);

    self.filterCategory = ISComboBox:new(x, y, self.width - x - padding, FONT_HGT_MEDIUM, self, function()
        self:refreshData()
    end);
    self.filterCategory:initialise();
    self.filterCategory:instantiate();
    self.filters:addChild(self.filterCategory);

    self.data = {
        selected = {}
    }
    if not self.listType then
        self.data.categories = Core.getAllItemCategories()
        self.data.items = Core.getAllItems()
    elseif self.listType == "VEHICLES" then
        self.data.categories = Core.getAllVehicleCategories()
        self.data.items = Core.getAllVehicles()
    end

    local catMap = {}
    local categories = {}
    self.filterCategory:clear()
    self.filterCategory:addOption("")
    for _, item in ipairs(self.data.items) do
        if not catMap[item.category] then
            catMap[item.category] = true
            table.insert(categories, item.category)
        end
    end

    table.sort(categories, function(a, b)
        return a:lower() < b:lower()
    end)

    for _, category in ipairs(categories) do
        self.filterCategory:addOption(category)
    end

    self:refreshData()
end

function UI:prerender()
    ISPanelJoypad.prerender(self)
    local padding = 10
    local maxWidth = self.parent.activeView.view.width
    local maxHeight = self.parent.height - HEADER_HGT -- BUTTON_HGT - padding * 2
    self:setWidth(maxWidth)
    self:setHeight(maxHeight)
    self.filters:setWidth(self.width)
    self.filters:setY(self.height - self.filters.height)

    self.filter:setWidth(self.list.columns[2].size - (padding / 2))
    self.filterCategory:setX(self.filter:getX() + self.filter.width + (padding / 2))
    self.filterCategory:setWidth(self.width - self.filter.width - padding * 2)

    self.list:setHeight(self.filters:getY() - self.list.y)
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

function UI:setData(data)

    self.data.selected = {}
    for k, item in ipairs(data or {}) do
        self.data.selected[k] = true
    end
    self:refreshData()

end

function UI:refreshData()
    self.list:clear();
    self.lastSelected = nil
    local filter = self.filter:getInternalText():lower()
    local category = self.filterCategory:getOptionText(self.filterCategory.selected)
    for _, item in ipairs(self.data.items) do
        if (filter == "" or string.match(item.label:lower(), filter)) and (category == "" or item.category == category) then
            self.list:addItem(item.label, item);
        end
    end
end
