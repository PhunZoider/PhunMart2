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

Core.ui.admin.poolsEditor = ISPanel:derive(profileName);
Core.ui.admin.poolsEditor.instances = {}
local UI = Core.ui.admin.poolsEditor

function UI:setData(data)
    data = data or {}
    local isNew = data.key == nil

    -- remove all tabviews
    if #self.tabPanel.viewList > 0 then
        for i = #self.tabPanel.viewList, 1, -1 do
            self.tabPanel:removeView(self.tabPanel.viewList[i].view)
        end
    end

    local pools = data.pools or {}
    for i, v in ipairs(pools) do
        local p = Core.ui.admin.poolsEditorEntry:new(0, 0, self.tabPanel.width, self.tabPanel.height, {
            player = self.player
        })
        p:initialise()
        p:instantiate()
        self.tabPanel:addView(tostring(i), p)
        p:setData(v)
    end

    self.isDirty = false
end

function UI:getData()

end

function UI:isValid()

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

    self:addChild(self.controls._panel);

    self.tabPanel = ISTabPanel:new(x, 100, w, h - y - offset);
    self.tabPanel:initialise()
    self.tabPanel:instantiate()
    self.tabPanel.backgroundColor = {
        r = 0,
        g = 1,
        b = 0,
        a = 0.5
    }
    self.controls._panel:addChild(self.tabPanel)

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

    self.tabPanel:setX(10)
    self.tabPanel:setY(100)
    self.tabPanel:setWidth(w - 20)
    self.tabPanel:setHeight(h - 130)

end
