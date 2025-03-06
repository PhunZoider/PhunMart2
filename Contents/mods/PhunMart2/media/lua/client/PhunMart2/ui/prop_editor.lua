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

Core.ui.admin.propEditor = ISPanel:derive(profileName);
Core.ui.admin.propEditor.instances = {}
local UI = Core.ui.admin.propEditor

local shopProperties = {
    label = {
        type = "string",
        label = "Label",
        tooltip = "The label of the property",
        default = ""
    },
    key = {
        type = "string",
        label = "Key",
        tooltip = "The key of the property",
        disableOnEdit = true,
        default = ""
    },
    group = {
        type = "string",
        label = "Group",
        tooltip = "The group of the property",
        default = ""
    },
    price = {
        type = "int",
        label = "Price",
        tooltip = "The price of the property",
        default = ""
    },
    currency = {
        type = "string",
        label = "Currency",
        tooltip = "The currency of the property",
        default = ""
    },
    enabled = {
        type = "boolean",
        label = "Enabled",
        tooltip = "Is the property enabled",
        default = true
    },
    minFill = {
        type = "int",
        label = "Min Fill",
        tooltip = "The minimum fill of the property",
        default = ""
    },
    maxFill = {
        type = "int",
        label = "Max Fill",
        tooltip = "The maximum fill of the property",
        default = ""
    },
    hoursToRestock = {
        type = "int",
        label = "Hours To Restock",
        tooltip = "The hours to restock of the property",
        default = ""
    },
    minDistance = {
        type = "int",
        label = "Min Distance",
        tooltip = "The minimum distance of the property",
        default = ""
    },
    probability = {
        type = "int",
        label = "Probability",
        tooltip = "The probability of the property",
        default = ""
    },
    requiresPower = {
        type = "boolean",
        label = "Requires Power",
        tooltip = "Does the property require power",
        default = true
    }
}

function UI:setData(data)
    data = data or {}
    local isNew = data.key == nil

    for k, v in pairs(shopProperties) do
        if v.type == "string" or v.type == "int" then
            self.controls[k]:clear()
            if data[k] == nil then
                if v.default ~= nil then
                    self.controls[k]:setText(tostring(v.default))
                end
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
    self.isDirtyValue = false
end

function UI:getData()

    local data = {}
    for k, v in pairs(shopProperties) do

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
    o.listType = options.type or nil
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

    for k, v in pairs(shopProperties) do

        if v.type == "string" or v.type == "int" then
            self:addTextInput(v.label, k, v.tooltip, v.disableOnEdit)
        elseif v.type == "boolean" then
            self:addBool(v.label, k, v.tooltip)
        end

        y = y + h + 10

    end
    self.controls._panel:setScrollHeight(y + h + 10);
    self.controls._panel:setScrollChildren(true)

    self.controls._panel:setScrollHeight(y + h + 10);
    self.controls._panel:setScrollChildren(true)

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

end
