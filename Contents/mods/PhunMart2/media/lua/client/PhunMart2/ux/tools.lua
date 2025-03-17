if isServer() then
    return
end

local Core = PhunMart
local tools = {}
local getTextManager = getTextManager
local UIFont = UIFont
local ISLabel = ISLabel
local ISTextEntryBox = ISTextEntryBox
local ISPanel = ISPanel
local ISScrollingListBox = ISScrollingListBox
local ipairs = ipairs

tools.FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
tools.FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
tools.FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
tools.BUTTON_HGT = tools.FONT_HGT_SMALL + 6
tools.FONT_SCALE = tools.FONT_HGT_SMALL / 14
tools.HEADER_HGT = tools.FONT_HGT_MEDIUM + 2 * 2

function tools.getLabel(text, x, y)
    local label = ISLabel:new(x, y, tools.FONT_HGT_SMALL, text, 1, 1, 1, 1, UIFont.Small, true);
    label:initialise();
    label:instantiate();
    return label;
end

function tools.getTextbox(name, text, tooltip, y)
    local textbox = ISTextEntryBox:new("", 120, y, 100, tools.FONT_HGT_SMALL + 4);
    textbox:initialise();
    textbox:instantiate();
    textbox:setTooltip(tooltip)
    self.controls[name] = textbox
    return textbox;
end

function tools.addLabeledTextbox(name, text, tooltip, parent, y)
    self:addLabel(text, parent, y)
    return self:addTextbox(name, text, tooltip, parent, y)
end

function tools.getListbox(x, y, w, h, columns, fns)

    local y = tools.HEADER_HGT
    local f = fns or {}

    local box = ISScrollingListBox:new(0, y, w, h - y);
    box:initialise();
    box:instantiate();
    box.doDrawItem = f.draw or box.doDrawItem;
    box.onMouseUp = f.click or box.onMouseUp;
    box.onRightMouseUp = f.rightClick or box.onRightMouseUp;
    box.itemheight = tools.FONT_HGT_SMALL + 6 * 2
    box.selected = 0;
    box.joypadParent = self;
    box.font = UIFont.NewSmall;
    box:setAnchorRight(true);
    box:setAnchorBottom(true);
    box:setAnchorTop(true);
    box:setAnchorLeft(true);

    for i, v in ipairs(columns) do
        box:addColumn(v, (i - 1) * 200);
    end

    -- box.prerender = function()
    --     -- ISScrollingListBox.prerender(box);
    -- end

    return box;
end

return tools
