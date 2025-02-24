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

Core.ui.admin.propEditor = ISCollapsableWindowJoypad:derive(profileName);
Core.ui.admin.propEditor.instances = {}
local UI = Core.ui.admin.propEditor

local shopProperties = {
    label = {
        type = "string",
        label = "Label",
        tooltip = "The label of the property"
    },
    key = {
        type = "string",
        label = "Key",
        tooltip = "The key of the property",
        disableOnEdit = true
    },
    group = {
        type = "string",
        label = "Group",
        tooltip = "The group of the property"
    },
    price = {
        type = "int",
        label = "Price",
        tooltip = "The price of the property"
    },
    currency = {
        type = "string",
        label = "Currency",
        tooltip = "The currency of the property"
    },
    enabled = {
        type = "boolean",
        label = "Enabled",
        tooltip = "Is the property enabled"
    },
    minFill = {
        type = "int",
        label = "Min Fill",
        tooltip = "The minimum fill of the property"
    },
    maxFill = {
        type = "int",
        label = "Max Fill",
        tooltip = "The maximum fill of the property"
    },
    hoursToRestock = {
        type = "int",
        label = "Hours To Restock",
        tooltip = "The hours to restock of the property"
    },
    minDistance = {
        type = "int",
        label = "Min Distance",
        tooltip = "The minimum distance of the property"
    },
    probability = {
        type = "int",
        label = "Probability",
        tooltip = "The probability of the property"
    },
    requiresPower = {
        type = "boolean",
        label = "Requires Power",
        tooltip = "Does the property require power"
    }
}

function UI.OnOpenPanel(playerObj, data, cb)

    local playerIndex = playerObj:getPlayerNum()

    if not UI.instances[playerIndex] then
        local core = getCore()
        local width = 300 * FONT_SCALE
        local height = 350 * FONT_SCALE

        local x = (core:getScreenWidth() - width) / 2
        local y = (core:getScreenHeight() - height) / 2

        UI.instances[playerIndex] = UI:new(x, y, width, height, playerObj, playerIndex);
        UI.instances[playerIndex]:initialise();
        ISLayoutManager.RegisterWindow(profileName, UI, UI.instances[playerIndex])
    end

    local instance = UI.instances[playerIndex]

    if not data then
        data = {}
    end

    instance:addToUIManager();
    instance:setVisible(true);

    instance.data = {}
    for k, v in pairs(shopProperties) do
        if v.type == "string" or v.type == "int" then
            instance.data[k] = data[k] or ""
            instance.controls[k]:setText(tostring(instance.data[k]))

            if v.disableOnEdit then
                instance.controls["_" .. k]:setName(tostring(instance.data[k]))

                instance.controls[k]:setVisible(false)
                instance.controls["_" .. k]:setVisible(true)
            end

        elseif v.type == "boolean" then
            instance.data[k] = v.trueIsNil and data[k] == nil or data[k] == true
            instance.controls[k]:setSelected(1, instance.data[k] == true)
        end
    end
    instance.title = data.label or "New Shop"
    instance.cb = cb

    return instance;

end

function UI:new(x, y, width, height, options)
    local opts = options or {}
    local o = ISCollapsableWindowJoypad:new(x, y, width, height);
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

    if disableOnEdit then
        local noEdit = ISLabel:new(x + 100, y, h, getTextOrNull(txt) or txt or key, 1, 1, 1, 1, UIFont.Small, true);
        noEdit:initialise();
        noEdit:instantiate();
        self.controls["_" .. key] = noEdit
        self.controls._panel:addChild(noEdit);
    end

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

    ISCollapsableWindowJoypad.createChildren(self)

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

    self.controls._save = ISButton:new(x, self.height - BUTTON_HGT - offset, self.width - offset * 2, BUTTON_HGT,
        getText("UI_btn_save"), self, function()

            local data = {}

            if self.cb then
                self.cb(data)
            end
            self:close()
        end);
    self.controls._save.internal = "SAVE";
    self.controls._save:initialise();
    self:addChild(self.controls._save);

end

function UI:prerender()
    ISCollapsableWindowJoypad.prerender(self)

    local offset = 10
    self.controls._panel:setWidth(self.width - self.scrollwidth - offset * 2)
    self.controls._panel:setHeight(self.controls._save.y - self:titleBarHeight() - offset * 2)
    self.controls._panel:updateScrollbars();
    -- self.controls._save:setX(self.width - self.scrollwidth - 80 - offset)
    self.controls._save:setX(offset)
    self.controls._save:setY(self.height - BUTTON_HGT - offset)
    self.controls._save:setWidth(self.width - offset * 2)

end
