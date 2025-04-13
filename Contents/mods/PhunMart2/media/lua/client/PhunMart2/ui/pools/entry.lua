if isServer() then
    return
end

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local FONT_SCALE = FONT_HGT_SMALL / 14
local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2
local BUTTON_HGT = FONT_HGT_SMALL + 6
local LABEL_HGT = FONT_HGT_MEDIUM + 6

local Core = PhunMart
local PL = PhunLib
local profileName = "PhunMartUIPoolsEntry"

Core.ui.pools_entry = ISPanel:derive(profileName);
Core.ui.pools_entry.instances = {}
local UI = Core.ui.pools_entry

-- pools = {{
-- currency = Base.money,
-- price = {min, max},
-- totalItems = {min, max},
-- zones = { difficulty = {3,4}},
-- enabled = false
-- probability = 10
-- when = {months = {}}} 
-- keys = { "clothing_all_hats" }

-- }},
local itemGroupData = require "PhunMart2/data/groups"
local allProps = {
    price = {
        type = "int",
        label = "Base Price",
        tooltip = "Overrides the shops base price",
        default = ""
    },
    currency = {
        type = "string",
        label = "Currency",
        tooltip = "Overrides the shops currency",
        default = ""
    },
    enabled = {
        type = "boolean",
        label = "Enabled",
        tooltip = "Untick to prevent this pool from being used",
        default = true
    },
    minFill = {
        type = "int",
        label = "Min Stock",
        tooltip = "Overrides the shops minimum stock level",
        default = ""
    },
    maxFill = {
        type = "int",
        label = "Max Stock",
        tooltip = "Overrides the shops maximum stock level",
        default = ""
    },
    zoneDifficulty = {
        type = "string",
        label = "Zone Difficulty",
        tooltip = "A CSV of PhunZone difficulties that this pool is valid for. eg 1,4 means that this pool will only be eligible in zones with 1 or 4 as the difficulty",
        isCsv = true,
        default = ""
    },
    whenMonths = {
        type = "string",
        label = "Months valid",
        tooltip = "A CSV of months that this pool is valid for. eg 1,4 means that this pool will only be eligible in January or April",
        isCsv = true,
        default = ""
    },
    probability = {
        type = "int",
        label = "Probability",
        tooltip = "The probability that this pool has of being selected when there are more than 1 pools eligible to be picked",
        default = ""
    }
}

function UI:setData(data)
    data = data or {}
    local isNew = data.key == nil

    for k, v in pairs(allProps) do
        if v.type == "string" or v.type == "int" then
            self.controls[k]:clear()
            if data[k] == nil then
                if v.default ~= nil then
                    self.controls[k]:setText(tostring(v.default))
                end
            elseif type(data[k]) == "table" then
                self.controls[k]:setText(table.concat(data[k], ","))
            else
                self.controls[k]:setText(tostring(data[k]))
            end

        elseif v.type == "boolean" then
            if data[k] == nil then
                self.controls[k]:setSelected(1, v.default == true)
            else
                self.controls[k]:setSelected(1, data[k] == true)
            end

        end
        if v.disableOnEdit then
            self.controls[k]:setEditable(not isNew)
        end
    end

    self.filters = data.filters or {}
    self:refreshItems()

    self.isDirtyValue = false
end

function UI:getData()
    local data = {}
    for k, v in pairs(allProps) do

        if v.type == "string" then

            local str = self.controls[k]:getText():match("^%s*(.-)%s*$")

            if str ~= v.default then
                if v.isCsv then
                    data[k] = {}
                    for i in string.gmatch(str, "([^,]+)") do
                        table.insert(data[k], i)
                    end
                else

                    data[k] = str

                end
            end

        elseif v.type == "int" then
            local str = self.controls[k]:getText():gsub("%D", "")
            if str ~= "" and str ~= v.default then
                data[k] = tonumber(str)
            end
        elseif v.type == "boolean" and v.default ~= self.controls[k]:isSelected(1) then
            data[k] = self.controls[k]:isSelected(1)
        end

    end
    data.filters = self.filters

    return data
end

function UI:isValid()

end

function UI:isDirty()
    return self.isDirtyValue
end

function UI:new(x, y, width, height, options)
    local opts = options or {}
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    o.player = opts.player or getPlayer()
    o.playerIndex = o.player:getPlayerNum()
    o:setWantKeyEvents(true)
    self.instance = o;
    return o;
end

function UI:addTextInput(txt, key, tooltip, disableOnEdit)

    local y = self.lastControlY or HEADER_HGT
    local h = FONT_HGT_MEDIUM
    local x = 10

    local label = ISLabel:new(x, y, h, getTextOrNull(txt) or txt or key, 1, 1, 1, 1, UIFont.Small, true);
    label:initialise();
    label:instantiate();
    self.controls["label_" .. key] = label
    self.controls._panel:addChild(label);

    self.controls[key] = ISTextEntryBox:new("", x + 100, y, 200, h);
    self.controls[key]:initialise();
    self.controls[key].tooltip = getTextOrNull(tooltip) or tooltip or ""
    self.controls._panel:addChild(self.controls[key]);

    self.lastControlY = self.controls[key].y + self.controls[key].height + 10
end

function UI:addBool(txt, key, tooltip, disableOnEdit)

    local y = self.lastControlY or HEADER_HGT
    local h = FONT_HGT_MEDIUM
    local x = 10

    self.controls[key] = ISTickBox:new(x, y, BUTTON_HGT, BUTTON_HGT, getTextOrNull(txt) or txt or key, self)
    self.controls[key]:addOption(getTextOrNull(txt) or txt or key, nil)
    self.controls[key]:setSelected(1, true)
    self.controls[key]:setWidthToFit()
    self.controls[key]:setY(y)
    self.controls[key].tooltip = getTextOrNull(tooltip) or tooltip or ""
    self.controls._panel:addChild(self.controls[key])
    self.lastControlY = (self.lastControlY or 0) + h + 10
end

function UI:createChildren()

    ISPanel.createChildren(self)

    local offset = 10
    local x = offset
    local y = HEADER_HGT
    local h = FONT_HGT_MEDIUM

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

    self:addChild(self.controls._panel);

    for k, v in pairs(allProps) do

        if v.type == "string" or v.type == "int" then
            self:addTextInput(v.label, k, v.tooltip, v.disableOnEdit)
        elseif v.type == "boolean" then
            self:addBool(v.label, k, v.tooltip)
        end

        y = y + h + 10

    end

    local label = ISLabel:new(x, y, h, "Items", 1, 1, 1, 1, UIFont.Small, true);
    label:initialise();
    label:instantiate();
    self.controls["label_pools"] = label
    self.controls._panel:addChild(label);

    self.controls.list = ISScrollingListBox:new(110, y + HEADER_HGT, 300, 200);
    self.controls.list:initialise();
    self.controls.list:instantiate();
    self.controls.list.itemheight = FONT_HGT_SMALL + 4 * 2
    self.controls.list.selected = 0;
    self.controls.list.joypadParent = self;
    self.controls.list.font = UIFont.NewSmall;
    self.controls.list.doDrawItem = self.drawDatas;

    self.controls.list:setOnMouseDownFunction(self, function(s, row)
        -- local index = row.index
        -- local key = row.text
        -- local item = self.keys[key]
        -- if item == nil then
        --     return
        -- end
        -- if item == true then
        --     self.keys[key] = false
        -- else
        --     self.keys[key] = true
        -- end
        -- self.isDirtyValue = true
    end)

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

        if item then
            local context = ISContextMenu.get(self.playerIndex, target:getAbsoluteX() + x,
                target:getAbsoluteY() + y + target:getYScroll())
            context:removeFromUIManager()
            context:addToUIManager()

            context:addOption("Properties", self, function()
                self:itemProperties(item)
            end, item)
            context:addOption("Remove " .. item.type, self, function()
                self:promptToExcludeItem(item)
            end, item)
        end
    end

    self.controls.list:setOnMouseDoubleClick(self, self.itemProperties)

    self.controls.list.drawBorder = true;
    self.controls.list:addColumn("Items", 0);
    self.controls._panel:addChild(self.controls.list);

    y = y + self.controls.list.height

    self.controls._panel:setScrollHeight(y + h + 10);
    self.controls._panel:setScrollChildren(true)

    self.controls._panel:setScrollHeight(y + h + 10);
    self.controls._panel:setScrollChildren(true)

    y = y + 10 + HEADER_HGT

    local label = ISLabel:new(x, y, h, "Filter", 1, 1, 1, 1, UIFont.Small, true);
    label:initialise();
    label:instantiate();
    self.controls["label_filter"] = label
    self.controls._panel:addChild(label);

    self.controls.filterText = ISTextEntryBox:new("", 110, y, 215, h);
    self.controls.filterText:initialise();
    self.controls.filterText.onTextChange = function()
        self:refreshItems()
    end
    self.controls._panel:addChild(self.controls.filterText);

    local button = ISButton:new(self.controls.filterText.x + self.controls.filterText.width + 10, y, 75, BUTTON_HGT,
        "...", self, function()
            Core.ui.pools_filters_main.open(self.player, self.filters or {}, function(data)
                local s = self
                s.filters = data
                s:setData(s:getData())
            end)
        end);
    button:initialise();
    button:instantiate();

    self.controls.pool_filter = button
    self.controls._panel:addChild(self.controls.pool_filter)
    self.controls._panel:setScrollHeight(y + h + 20)
end

function UI:promptToExcludeItem(item)
    local message = "Are you sure you want to exclude this item from the list?"
    local w = 300 * FONT_SCALE
    local h = 200 * FONT_SCALE
    local modal = ISModalDialog:new(getCore():getScreenWidth() / 2 - w / 2, getCore():getScreenHeight() / 2 - h / 2, w,
        h, message, true, self, function(s, button)
            if button.internal == "YES" then
                self.filters[item.source].exclude[item.type] = true
                self:refreshItems()
            end
        end, nil);
    modal:initialise()
    modal:addToUIManager()
end

function UI:itemProperties(item)
    Core.ui.shop_config_item.open(self.player, item, function(data)
        self:refreshItems()
    end)
end

function UI:refreshItems()
    self.controls.list:clear();
    self.lastSelected = nil
    self.data = self:getData()
    local filterText = self.controls.filterText:getInternalText():lower()
    local filters = self.data.filters or {}
    local results = {}

    if filters.items then
        local allItems = Core.getAllItems()
        for _, v in ipairs(allItems) do
            if not filters.items.exclude[v.type] then
                if filters.items.include[v.type] or filters.items.categories[v.category] then
                    table.insert(results, {
                        type = v.type,
                        label = v.label,
                        category = v.category,
                        texture = v.texture,
                        source = "items"
                    })
                end
            end
        end
    end

    if filters.vehicles then
        local allCars = Core.getAllVehicles()
        for _, v in ipairs(allCars) do
            if not filters.vehicles.exclude[v.type] then
                if filters.vehicles.include[v.type] or filters.vehicles.categories[v.category] then
                    table.insert(results, {
                        type = v.type,
                        label = v.label,
                        category = v.category,

                        source = "vehicles"
                    })
                end
            end
        end
    end

    if filters.traits then
        local allTraits = Core.getAllTraits()
        for _, v in ipairs(allTraits) do
            if not filters.traits.exclude[v.type] then
                if filters.traits.include[v.type] or filters.traits.categories[v.category] then
                    table.insert(results, {
                        type = v.type,
                        label = v.label,
                        category = v.category,
                        texture = v.texture,
                        source = "traits"
                    })
                end
            end
        end
    end

    if filters.xp then
        local allXp = Core.getAllXp()
        for _, v in ipairs(allXp) do
            if not filters.xp.exclude[v.type] then
                if filters.xp.include[v.type] or filters.xp.categories[v.category] then
                    table.insert(results, {
                        type = v.type,
                        label = v.label,
                        category = v.category,
                        texture = v.texture,
                        source = "xp"
                    })
                end
            end
        end
    end

    if filters.boosts then
        local allBoosts = Core.getAllBoosts()
        for _, v in ipairs(allBoosts) do
            if not filters.boosts.exclude[v.type] then
                if filters.boosts.include[v.type] or filters.boosts.categories[v.category] then
                    table.insert(results, {
                        type = v.type,
                        label = v.label,
                        category = v.category,
                        texture = v.texture,
                        source = "boosts"
                    })
                end
            end
        end
    end

    table.sort(results, function(a, b)
        return a.label:lower() < b.label:lower()
    end)

    self.itemlist = results
    self.controls.list:clear()
    for _, v in ipairs(results) do
        if (filterText == "" or string.match(v.label:lower(), filterText)) then
            self.controls.list:addItem(v.label, v);
        end
    end

    if #results == 0 then
        self.controls.list.columns[1].name = "No items set"
    elseif #results ~= #self.controls.list.items then
        self.controls.list.columns[1].name = "Items: " .. PL.string.formatWholeNumber(#self.controls.list.items) ..
                                                 " of " .. PL.string.formatWholeNumber(#results)
    else
        self.controls.list.columns[1].name = "Items: " .. PL.string.formatWholeNumber(#results)
    end

end

function UI:drawDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9;

    if item.index == self.selected then
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

    local clipX = 0
    local clipX2 = self.width
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

    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end

function UI:prerender()
    ISPanel.prerender(self)

    local offset = 0
    local w = self.parent.width
    local h = self.parent.height
    local x = offset
    local y = offset

    local panel = self.controls._panel

    panel:setX(x)
    panel:setY(y)
    panel:setWidth(w)
    panel:setHeight(h)
    panel:updateScrollbars();

end
