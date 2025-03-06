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
local profileName = "PhunMartUIPropEditor"

Core.ui.admin.poolsEditorEntry = ISPanel:derive(profileName);
Core.ui.admin.poolsEditorEntry.instances = {}
local UI = Core.ui.admin.poolsEditorEntry

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

    self.keys = {}

    local keys = {}
    for k, v in pairs(itemGroupData or {}) do
        self.keys[k] = false
        table.insert(keys, k)
    end

    table.sort(keys, function(a, b)
        return a:lower() < b:lower()
    end)
    self.controls.keys:clear()
    for i, v in ipairs(keys) do
        self.controls.keys:addItem(v, {
            text = v,
            index = i
        })
    end

    for _, v in ipairs(data.keys or {}) do
        self.keys[v] = true
    end

    -- select the first entry
    for i, v in ipairs(keys) do
        if self.keys[v] == true then
            self.controls.keys:ensureVisible(i)
            break
        end
    end

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

    data.keys = {}
    for k, v in pairs(self.keys) do
        if v == true then
            table.insert(data.keys, k)
        end
    end

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

    local label = ISLabel:new(x, y, h, "Groups", 1, 1, 1, 1, UIFont.Small, true);
    label:initialise();
    label:instantiate();
    self.controls["label_pools"] = label
    self.controls._panel:addChild(label);

    self.controls.keys = ISScrollingListBox:new(110, y + HEADER_HGT, 200, 50);
    self.controls.keys:initialise();
    self.controls.keys:instantiate();
    self.controls.keys.itemheight = FONT_HGT_SMALL + 4 * 2
    self.controls.keys.selected = 0;
    self.controls.keys.joypadParent = self;
    self.controls.keys.font = UIFont.NewSmall;
    self.controls.keys.doDrawItem = self.drawDatas;

    self.controls.keys:setOnMouseDownFunction(self, function(s, row)
        local index = row.index
        local key = row.text
        local item = self.keys[key]
        if item == nil then
            return
        end
        if item == true then
            self.keys[key] = false
        else
            self.keys[key] = true
        end
        self.isDirtyValue = true
    end)

    self.controls.keys.drawBorder = true;
    self.controls.keys:addColumn("Groups", 0);
    self.controls._panel:addChild(self.controls.keys);

    y = y + self.controls.keys.height

    self.controls._panel:setScrollHeight(y + h + 10);
    self.controls._panel:setScrollChildren(true)

    self.controls._panel:setScrollHeight(y + h + 10);
    self.controls._panel:setScrollChildren(true)

end

function UI:drawDatas(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end

    local a = 0.9;

    if self.parent.parent.keys[item.item.text] == true then
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

    self.controls._panel:setX(x)
    self.controls._panel:setY(y)
    self.controls._panel:setWidth(w)
    self.controls._panel:setHeight(h)
    self.controls._panel:updateScrollbars();

    if self.controls.keys.y < (self.controls._panel.height - 10) then
        -- resize
        self.controls.keys:setHeight(self.controls._panel.height - self.controls.keys.y - 10)
    else

    end

end
