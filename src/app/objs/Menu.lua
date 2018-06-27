local Menu = class("Menu", function ()
    return display.newNode()
end)

function Menu:ctor(block, off_w, off_h)
    -- if nil == self.own_draw then 
    --     self.own_draw = cc.DrawNode:create()
    --     self:addChild(self.own_draw, 10)
    --     print('GameScene >>>>> line = 71');
    --     self.own_draw:setAnchorPoint(1, 1)
    --     self.own_draw:drawSolidCircle(cc.p(self.width / 2, self.height / 2), self.width, 360, 100, cc.c4f(0.65, 0.65, 0.65, 0.5))
    -- end
    -- self.own_draw:setPosition(v:getPosition())
    self.block = block
    local x, y = self.block:getPosition()
    self.menu = display.newSprite("menu_bg.png")
	:move(x + off_w / 2, y + off_h / 2)
    :addTo(self)
    Menu.Instance = self
    self:SetTouchEvent()
    self.tower_menu = {}
    -- self:setContentSize(self.menu:getContentSize())
    self:CreateChooseMenu()

    GameObject.Extend(self):AddComponent(EventProtocol):exportMethods()
end

function Menu:CreateChooseMenu()
    local tower = self.block:GetTower()
    if tower then 
        self:CreateTowerUpdate(tower)
    else 
        self:CreateTowerMenu()
    end
end

function Menu:CreateTowerUpdate(tower)
    local box = self.menu:getBoundingBox()
    self.sell_t = display.newSprite("bg.png")
    self.sell_t:setScale(0.8)
    local size = self.sell_t:getContentSize()
    local sell_label = cc.Label:createWithSystemFont("SELL", "Arial", 20)
    :addTo(self.sell_t)
    :move(size.width / 2, size.height / 2)
    self:addChild(self.sell_t)
    self.sell_t:setAnchorPoint(0.5, 0.5)
    self.sell_t:setPosition(box.x + box.width / 2 + size.width * 0.8, box.y + box.height / 2 - 5)
    if tower:GetTowerLevel() < 3 then 
        self.up_level = display.newSprite("bg.png")
        self.up_level:setScale(0.8)
        self:addChild(self.up_level)
        local update_label = cc.Label:createWithSystemFont("UP", "Arial", 20)
        :addTo(self.up_level)
        :move(size.width / 2, size.height / 2)
        self.up_level:setAnchorPoint(0.5, 0.5)
        self.up_level:setPosition(box.x + box.width / 2 - size.width * 0.8, box.y + box.height / 2 - 5)
    end
end

local scale_num = {
    [1] = 0.8,
    [2] = 0.6,
    [3] = 0.7,
    [4] = 0.6,
    [5] = 0.7,
}

function Menu:CreateTowerMenu()
    local box = self.menu:getBoundingBox()
    for i = 1, 5 do
        local bg = display.newSprite("bg.png")
        local tower = display.newSprite(string.format("tower/menu_tower_%d.png", i))
        tower:setScale(scale_num[i])
        bg:setScale(0.8)
        local dire = cc.pForAngle(math.rad(72 * (i - 1) + 90))
        self:addChild(bg)
        self:addChild(tower)
        bg:setPosition(cc.pAdd(cc.p(box.x + box.width / 2, box.y + box.height / 2), cc.pMul(dire, 50)))
        tower:setAnchorPoint(0.5, 0.5)
        tower:setPosition(cc.pAdd(cc.p(box.x + box.width / 2, box.y + box.height / 2), cc.pMul(dire, 50)))
        table.insert(self.tower_menu, tower)
    end
end

function Menu:GetMenuInstance(type, x, y)
    if nil == Menu.Instance then 
        Menu.new(type, x, y)
    end
    Menu.Instance:setVisible(true)
    return Menu.Instance
end

function Menu:GetBoundingBox()
    return self.menu:getBoundingBox()
end

function Menu:SetTouchEvent()
    local function onTouchBegin(touch, event)
        local locationInNode = self:convertToNodeSpace(touch:getLocation())
        self:OnBlockClick(locationInNode)
        return true
    end
    local listener = cc.EventListenerTouchOneByOne:create();
    -- listener:setSwallowTouches(true);
    listener:registerScriptHandler(onTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN);
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.menu);
end

function Menu:OnBlockClick(locationInNode)
    if cc.rectContainsPoint(self.menu:getBoundingBox(), locationInNode) then 
        if self.tower_menu[1] then
            for k,v in pairs(self.tower_menu) do
                if cc.rectContainsPoint(v:getBoundingBox(), locationInNode) then
                    self:dispatchEvent({name = BUILD_TOWER, type = k, block = self.block})
                    return
                end
            end
        else
            if self.sell_t and cc.rectContainsPoint(self.sell_t:getBoundingBox(), locationInNode) then
                self:dispatchEvent({name = SELL_TOWER, block = self.block})
                return
            end
            if self.up_level and cc.rectContainsPoint(self.up_level:getBoundingBox(), locationInNode) then
                self:dispatchEvent({name = UP_LEVEL_TOWER, block = self.block})
                return
            end
        end
    end
end


return Menu