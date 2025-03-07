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
local profileName = "PhunMartUIInstancesPanel"

Core.ui.admin.instancesPanel = ISPanel:derive(profileName);
Core.ui.admin.instancesPanel.instances = {}
local UI = Core.ui.admin.instancesPanel

local phunZone = nil

function UI:setData(data)

    if phunZone == nil then
        if PhunZones then
            phunZone = PhunZones
        else
            phunZone = false
        end
    end

    local d
    if type(data) == "table" then
        d = data
    else
        d = {}
        table.insert(d, data)
    end

    -- get all instances

    self.shops = {}
    self.data = {}
    for _, v in ipairs(d or {}) do
        self.shops[v] = true
    end

    local px, py = self.player:getX(), self.player:getY()

    for k, v in pairs(Core.instances) do
        if self.shops[v.key] then
            local copy = PL.table.deepCopy(v)
            if phunZone then
                copy.location = phunZone:getLocation(v.x, v.y).title
            end
            copy.distance = math.sqrt((copy.x - px) ^ 2 + (copy.y - py) ^ 2)
            table.insert(self.data, copy)
        end
    end

    table.sort(self.data, function(a, b)
        return a.distance < b.distance
    end)

    self.controls.list:clear()
    for _, v in ipairs(self.data) do
        if #d == 1 then

            if v.location then
                self.controls.list:addItem(v.location .. " (" .. tostring(v.x) .. ", " .. tostring(v.y) .. ", " ..
                                               tostring(v.z) .. ")", v)
            else
                self.controls.list:addItem(tostring(v.x) .. ", " .. tostring(v.y) .. ", " .. tostring(v.z), v)
            end

        else
            self.controls.list:addItem(v.shop, v)
        end
    end

    self.isDirtyValue = false
end

function UI:new(x, y, width, height, options)
    local opts = options or {}
    local o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    o.player = opts.player or getPlayer()
    o.playerIndex = o.player:getPlayerNum()
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

    self.controls.list = ISScrollingListBox:new(x, y, self:getWidth(), self.height - HEADER_HGT - 45);
    self.controls.list:initialise();
    self.controls.list:instantiate();
    self.controls.list.itemheight = FONT_HGT_SMALL + 4 * 2
    self.controls.list.selected = 0;
    self.controls.list.joypadParent = self;
    self.controls.list.font = UIFont.NewSmall;
    self.controls.list.doDrawItem = self.drawDatas;

    self.controls.list.onRightMouseUp = function(target, x, y, a, b)
        local row = self.controls.list:rowAt(x, y)
        if row == -1 then
            return
        end
        if self.selected ~= row then
            self.selected = row
            self.controls.list.selected = row
            self.controls.list:ensureVisible(self.controls.list.selected)
        end
        local item = self.controls.list.items[self.controls.list.selected].item

    end
    self.controls.list.drawBorder = true;
    self.controls.list:addColumn("Location", 0);
    self.controls.list:addColumn("Distance", 199);
    self.controls._panel:addChild(self.controls.list);

    y = self.controls.list.y + self.controls.list.height + offset

    self.controls.btnPort = ISButton:new(self.width - offset - 100, y, 100, 25, "Port", self, function()
        if self.controls.list.selected and self.controls.list.selected > 0 and
            self.controls.list.items[self.controls.list.selected] then
            local item = self.controls.list.items[self.controls.list.selected].item
            self:doPort(item.x, item.y, item.z or 0)
        end
    end);
    self.controls.btnPort:initialise();
    self.controls.btnPort:instantiate();
    self.controls._panel:addChild(self.controls.btnPort);

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

    local value = PL.string.formatWholeNumber(tonumber(item.item.distance)) .. "m"

    local valueWidth = getTextManager():MeasureStringX(self.font, value)
    local w = self.width
    local cw = self.columns[2].size
    self:drawText(value, w - valueWidth - xoffset - 4, y + 4, 1, 1, 1, a, self.font);
    self.itemsHeight = y + self.itemheight;
    return self.itemsHeight;
end

function UI:doPort(destinationX, destinationY, destinationZ)

    local player = self.player
    player:setX(destinationX)
    player:setY(destinationY)
    player:setZ(destinationZ)
    if player.setLx then
        player:setLx(destinationX)
        player:setLy(destinationY)
        player:setLz(destinationZ)
    end
    local retries = 100
    local playerPorting
    playerPorting = function()
        -- wait for square to load
        local square = player:getCurrentSquare()
        if square == nil then
            return
        end
        retries = retries - 1
        if retries <= 0 then
            player:Say("Failed to port")
            Events.OnPlayerUpdate.Remove(playerPorting)
            return
        end

        local free = AdjacentFreeTileFinder.FindClosest(square, player)
        if free then
            player:setX(free:getX())
            player:setY(free:getY())
            player:setZ(free:getZ())
            if player.setLx then
                player:setLx(free:getX())
                player:setLy(free:getY())
                player:setLz(free:getZ())
            end
            Events.OnPlayerUpdate.Remove(playerPorting)
        end

    end
    Events.OnPlayerUpdate.Add(playerPorting)
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

    self.controls.list:setX(offset)
    self.controls.list:setY(offset + HEADER_HGT - 1)
    self.controls.list:setWidth(w - offset * 2)
    self.controls.list:setHeight(h - self.controls.btnPort.height - 45)

    self.controls.btnPort:setX(w - 110)
    self.controls.btnPort:setY(h - 35)

end
