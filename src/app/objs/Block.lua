local Menu = import(".Menu")
local Block = class("Block", function ()
    return display.newNode()
end)

Block.TYPE_COLOR = {
    [1] = COLOR4B.GREEN_D_S,
    [2] = COLOR4B.GRAY,
    [3] = COLOR4B.GRAY,
    [4] = COLOR4B.BLUE,
    [5] = COLOR4B.RED,
    [6] = COLOR4B.YELLOW,
    [101] = COLOR4B.WHITE,
    [102] = COLOR4B.WHITE,
    [103] = COLOR4B.WHITE,
}

function Block:ctor(type, width, height)
	local color = Block.TYPE_COLOR[type < 100 and type or 2]
	self.type = type
	-- local sp = cc.LayerColor:create(color, width, height)
	local sp = cc.Sprite:create("white_bg.png")
	sp:setAnchorPoint(0,0)
	sp:setColor(color)
	self:addChild(sp)
	local size = sp:getContentSize()
	sp:setScale(width / size.width, height / size.height)
	self:setContentSize({width = width, height = height})
	self:SetTouchListener()
	self.width = width
	self.height = height
	self.tower = nil
end

function Block:SetTower(tower)
	self.tower = tower
end

function Block:RemoveTower()
	self.tower = nil
end

function Block:GetBlockType()
	return self.type
end

function Block:GetTower()
	return self.tower
end

function Block:SetTouchListener()
	-- local function onTouchBegin(touch, event)
	-- 	-- local locationInNode = self:convertToNodeSpace(touch:getLocation())
	-- 	print('Block >>>>> line = 48', self.type);
    --     return true
    -- end
    -- local listener = cc.EventListenerTouchOneByOne:create();
    -- -- listener:setSwallowTouches(true);
    -- listener:registerScriptHandler(onTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN);
    -- local eventDispatcher = self:getEventDispatcher()
    -- eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.layerCol);
end

function Block:OnClickLitenner()
	if 1 == self.type then 
		-- print('Block >>>>> line = 43');
		-- local menu = Menu.new(1, 1)
		-- self:addChild(menu)
		-- menu:setPosition(display.width / 2, display.height / 2)
		-- local draw = cc.DrawNode:create()
		-- self:addChild(draw, 10)
		-- draw:setPosition(cc.p(self.width / 2, self.height / 2))
		-- draw:drawCircle(cc.p(10, 10), self.height / 2, 360, 100, false, cc.c4f(1,1,0,1))
		-- -- draw:setAnchorPoint(0.5, 0.5)
		-- print('Menu >>>>> line = 9');
		-- local myDrawNode=cc.DrawNode:create()  
		-- self:addChild(myDrawNode, 10)  
		-- myDrawNode:setPosition(cc.p(10,10))  
		-- myDrawNode:drawSolidRect(cc.p(10,10), cc.p(20,20), cc.c4f(1,1,0,1)) 
	end
end

return Block