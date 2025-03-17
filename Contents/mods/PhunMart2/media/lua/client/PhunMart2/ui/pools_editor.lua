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
local profileName = "PhunMartUIPoolsEditor"

Core.ui.admin.poolsEditor = ISPanel:derive(profileName);
Core.ui.admin.poolsEditor.instances = {}
local UI = Core.ui.admin.poolsEditor

function UI:setData(data)

    self.data = data or {}
    if not self.data.pools then
        self.data.pools = {}
    end

    local isNew = data.key == nil

    -- remove all tabviews
    if #self.controls.tabPanel.viewList > 0 then
        for i = #self.controls.tabPanel.viewList, 1, -1 do
            self.controls.tabPanel:removeView(self.controls.tabPanel.viewList[i].view)
        end
    end

    local pools = self.data.pools
    for i, v in ipairs(pools) do
        local p = Core.ui.admin.poolsEditorEntry:new(0, 0, self.controls.tabPanel.width, self.controls.tabPanel.height,
            {
                player = self.player
            })
        p:initialise()
        p:instantiate()
        self.controls.tabPanel:addView(tostring(i), p)
        p:setData(v)
    end

    self.controls.tabPanel:setVisible(#self.controls.tabPanel.viewList > 0)
    self.isDirtyValue = false
end

function UI:getData()
    local pools = {}
    for i, v in ipairs(self.tabPanel.viewList) do
        table.insert(pools, v.view:getData())
    end
    return pools
end

function UI:isValid()

end

function UI:isDirty()
    local isDirty = self.isDirtyValue
    if not isDirty then
        for i, v in ipairs(self.controls.tabPanel.viewList) do
            if v.view:isDirty() then
                isDirty = true
                break
            end
        end
    end
    return isDirty
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

function UI:createChildren()

    ISPanel.createChildren(self)

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

    -- self.controls._panel.backgroundColor = {
    --     r = 0,
    --     g = 1,
    --     b = 0,
    --     a = 1
    -- }

    self:addChild(self.controls._panel);

    self.controls.addPool = ISButton:new(10, 10, 100, BUTTON_HGT, getText("UI_btn_add"), self, self.onAddPool);
    self.controls.addPool:initialise();
    self.controls.addPool:instantiate();
    self.controls.addPool.tooltip = getText("UI_btn_add_tooltip");
    if self.controls.addPool.enableAcceptColor then
        self.controls.addPool:enableAcceptColor()
    end
    self.controls._panel:addChild(self.controls.addPool);

    -- Duplicate pool button
    self.controls.duplicatePool = ISButton:new(230, 10, 100, BUTTON_HGT, getText("UI_btn_duplicate"), self,
        self.onDuplicatePool);
    self.controls.duplicatePool:initialise();
    self.controls.duplicatePool:instantiate();
    self.controls.duplicatePool.tooltip = getText("UI_btn_duplicate_tooltip");
    if self.controls.duplicatePool.enableAcceptColor then
        self.controls.duplicatePool:enableAcceptColor()
    end
    self.controls._panel:addChild(self.controls.duplicatePool);

    self.controls.removePool = ISButton:new(120, 10, 100, BUTTON_HGT, getText("UI_btn_remove"), self, self.onRemovePool);
    self.controls.removePool:initialise();
    self.controls.removePool:instantiate();
    self.controls.removePool.tooltip = getText("UI_btn_remove_tooltip");
    if self.controls.removePool.enableCancelColor then
        self.controls.removePool:enableCancelColor()
    end
    self.controls._panel:addChild(self.controls.removePool);

    self.controls.tabPanel = ISTabPanel:new(x, BUTTON_HGT + 20, w, h - y - offset);
    self.controls.tabPanel:initialise()
    self.controls.tabPanel:instantiate()

    -- self.tabPanel.backgroundColor = {
    --     r = 0,
    --     g = 0,
    --     b = 1,
    --     a = 1.0
    -- }

    self.controls._panel:addChild(self.controls.tabPanel)

    self.controls._panel:setScrollHeight(y + h + 10);
    self.controls._panel:setScrollChildren(true)

end

-- Add pool
function UI:onAddPool()

    if not self.data then
        self.data = {}
    end
    if not self.data.pools then
        self.data.pools = {}
    end

    table.insert(self.data.pools, {
        keys = {}
    })

    self:setData(self.data)

    self.isDirtyValue = true
end

-- Remove pool
function UI:onRemovePool()
    local index = 0
    local view = self.controls.tabPanel.activeView
    for i, v in ipairs(self.controls.tabPanel.viewList) do
        if v == view then
            index = i
            break
        end
    end

    if index > 0 then

        table.remove(self.data.pools, index)

        self:setData(self.data)
        self.isDirtyValue = true
    end
end

-- Duplicate pool
function UI:onDuplicatePool()

    local index = 0
    local view = self.controls.tabPanel.activeView
    local data = view and view.view and view.view:getData() or nil
    if data then
        local copy = PL.table.deepCopy(data)
        table.insert(self.data.pools, copy)
        self:setData(self.data)
        self.isDirtyValue = true
    end

    -- for i, v in ipairs(self.controls.tabPanel.viewList) do
    --     if v == view then
    --         index = i
    --         break
    --     end
    -- end

    -- if index > 0 then
    --     local copy = PL.table.deepCopy(self.data.pools[index])
    --     table.insert(self.data.pools, copy)
    --     self:setData(self.data)
    --     self.isDirtyValue = true
    -- end

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

    self.controls.tabPanel:setX(10)
    self.controls.tabPanel:setWidth(w - 20)
    self.controls.tabPanel:setHeight(h - self.controls.tabPanel.y - HEADER_HGT - 10)

    self.controls.removePool:setX(w - 120)
    self.controls.duplicatePool:setX(w - 230)
    self.controls.addPool:setX(w - 340)

    for _, view in ipairs(self.controls.tabPanel.viewList) do
        view.view:setWidth(self.controls.tabPanel:getWidth())
        view.view:setHeight(self.controls.tabPanel:getHeight())
    end

end
