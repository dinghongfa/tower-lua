local checkpoint_cfg = require("src/app/config/checkpoint_cfg.lua")
local Menu = import("..objs.Menu")
local PauseMenu = import("..objs.PauseMenu")
local EndAlert = import("..objs.EndAlert")
local Block = import("..objs.Block")
local Bullet = import("..objs.Bullet")
local Monster = import("..objs.Monster")
local Tower = import("..objs.Tower")
local GameScene = class("GameScene", cc.load("mvc").ViewBase)

math.randomseed(os.time())

function GameScene:onCreate()
    self.checkpoint_label = cc.Label:createWithTTF("关卡:1", "fonts/FZZY.ttf", 30)
    :move(50, display.height - 20)
    -- self.checkpoint_label:setAlignment(cc.TEXT_ALIGNMENT_LEFT)
    self.checkpoint_label:setColor(cc.BLACK)

    self.coin_label = cc.Label:createWithTTF("50", "fonts/FZZY.ttf", 30)
    :move(200, display.height - 20)
    -- self.coin_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
    self.coin_label:setColor(cc.BLACK)
    
    self.score_label = cc.Label:createWithTTF("Score:100", "fonts/FZZY.ttf", 30)
    :move(350, display.height - 20)
    -- self.score_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
    self.score_label:setColor(cc.BLACK)
    self:CreatButtonChangeOne("play_searchpai.png", "pause_searchpai.png")
    self:InitData()
    local gold_img = display.newSprite("gold.png", 150, display.height -20)
    self:addChild(self.checkpoint_label, 666)
    self:addChild(self.coin_label, 666)
    self:addChild(self.score_label, 666)
    self:addChild(gold_img, 666)
    GameObject.Extend(self):AddComponent(EventProtocol):exportMethods()

end

function GameScene:InitData()
    self.blocks = {}
    self.is_start = false
    self.start_button:setVisible(true)
    self.push_button:setVisible(false)
    self.level, self.coin, self.score = 1, 50, 100
    local f = io.open("src/role.lua", "r")
    if nil ~= f then
        f:close()
        package.loaded["src/role"] = nil
        data = require("src/role")
        -- self.level, self.score = tonumber(data[1] or 1) , tonumber(data[2] or 10)
        self.level, self.coin, self.score = data[1] or 1, data[2] or 50, data[3] or 100
    end
    print('GameScene >>>>> line = 51', self.score);
    self.checkpoint_label:setString("关卡:" .. self.level)
    self.coin_label:setString(self.coin)
    self.score_label:setString("Score:" .. self.score)
    local list = require("src/app/config/map_cfg.lua")["checkpoint_"..self.level]
    self.route_list = {}
    self.route_point = 1
    self.width = display.width / #list[1]
    self.height = display.height / #list
    for i,v in ipairs(list) do
        for j,v1 in ipairs(v) do
            local block = Block.new(v1, self.width, self.height)
            local pos = cc.p(self.width * (j - 1), self.height * (i - 1))
            if v1 > 100 then 
                local i1, j1 = i, j
                if i == 1 then 
                    i1 = i - 1
                elseif i == #list then
                    i1 = i + 1
                elseif j == 1 then
                    j1 = j - 1
                elseif j == #v then
                    j1 = j + 1
                end
                table.insert(self.route_list, {type = v1, pos = cc.p(self.width * (j1 - 0.5), self.height * (i1 - 0.5))})
            end
            block:setPosition(pos)
            self:addChild(block)
            table.insert(self.blocks, block)
        end
    end
    table.sort(self.route_list, function (a, b)
        return a.type < b.type
    end)
    self:SetTouchEvent()

    self.monster_list = {}
    self.tower_list = {}
    self.time = 0
    self.wave_time = checkpoint_cfg["checkpoint_" .. self.level].dt
    self.monster_wave = checkpoint_cfg["checkpoint_" .. self.level].waves
    self.wave = 1
    self.monster_count = 0
    self.wave_count = 0
    self.next_wave = true
    self.tower_count = 0
    self.pause_menu = nil
end

function GameScene:DeleteData()
    -- local monster_len = #self.monster_list
    -- local tower_len = #self.tower_list
    -- local block_len = #self.blocks
    for k,v in pairs(self.monster_list) do
        self.monster_list[k]:CancerTimer()
        self.monster_list[k]:removeSelf(true)
    end
    for k,v in pairs(self.tower_list) do
        self.tower_list[k]:CancerTimer()
        self.tower_list[k]:removeSelf(true)
    end
    for k,v in pairs(self.blocks) do
        -- self.blocks[k]:CancerTimer()
        self.blocks[k]:removeSelf(true)
    end
    self.monster_list = nil
    self.tower_list = nil
    self.blocks = nil
    -- for i = 1, monster_len do
    --     self.monster_list[i]:CreateTimer()
    --     self.monster_list[i]:removeSelf(true)
    -- end
    -- for i = 1, tower_len do
    --     self.tower_list[i]:removeSelf(true)
    -- end
    -- for i = 1, block_len do
    --     self.blocks[i]:removeSelf(true)
    -- end
end

function GameScene:Restart()
    -- self:dispatchEvent({name = RESTART, is_start = self.is_start})
    self.pause_menu:removeSelf(true)
    self:DeleteData()
    self:InitData()
end

function GameScene:ContinueGame()
    self.is_start = true
    self.pause_menu:removeSelf(true)
    self.pause_menu = nil
    self:CreateTimer()
    self.start_button:setVisible(false)
    self.push_button:setVisible(true)
    self:dispatchEvent({name = UPDATE_GAME_STATE, is_start = self.is_start})
end

function GameScene:CreatButtonChangeOne(path_1, path_2)
    --增加放置显示
    local menu
    local function menuCallback(tag, menuItem)
        if tag == 1 then
            self.is_start = true
            self:CreateTimer()
            self.start_button:setVisible(false)
            self.push_button:setVisible(true)
        elseif tag == 2 then 
            self.is_start = false
            self:CancerTimer()
            self.start_button:setVisible(true)
            self.push_button:setVisible(false)
            if nil == self.pause_menu then 
                self.pause_menu = PauseMenu.new(self)
                self:addChild(self.pause_menu, 888)
            end
        end
        self:dispatchEvent({name = UPDATE_GAME_STATE, is_start = self.is_start})
    end

    self.start_button = cc.MenuItemImage:create(path_1, path_1)
    self.start_button:setTag(1)
    
    self.push_button = cc.MenuItemImage:create(path_2, path_2)
    self.push_button:setTag(2)
    self.push_button:setVisible(false)

    menu = cc.Menu:create(self.start_button, self.push_button)
    menu:setPosition(display.width - 50, display.height - 50)
    self:addChild(menu,600)

    self.start_button:registerScriptTapHandler(menuCallback)
    self.push_button:registerScriptTapHandler(menuCallback)
end

function GameScene:CreateTimer()
    local scheduler = cc.Director:getInstance():getScheduler()
    self.schedulerID = scheduler:scheduleScriptFunc(function()  
        self:UpdateMaster()
    end, 0, false)
end

function GameScene:CancerTimer()
    if self.schedulerID then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
	end
end

-- 创建tower
function GameScene:OnBuildTower(event)
    print('GameScene >>>>> line = 85', event.name, event.type);
    self.menu:removeSelf(true)
    self.menu = nil
    self.is_build = true
    if self.coin >= TOWER_CFG["tower_" .. event.type].cost[1] then 
        self:CreateTower(event.type, event.block)
        self.coin = self.coin - TOWER_CFG["tower_" .. event.type].cost[1]
        self.coin_label:setString(self.coin)
    end
end

-- 出售tower
function GameScene:OnSellTower(event)
    print('GameScene >>>>> line = 92', event.name, event.block);
    local block = event.block
    local tower = block:GetTower()
    self.coin = self.coin + TOWER_CFG["tower_" .. tower:GetTowerType()].sell[tower:GetTowerLevel()]
    self.coin_label:setString(self.coin)
    tower:SellTower()
    -- tower:removeSelf(true)
    for k,v in pairs(self.tower_list) do
        if v:GetTowerState() == TOWER_STATE.SELL then 
            v = nil
        end
    end
    block:RemoveTower()
    tower = nil
    self.is_build = true
    self.menu:removeSelf(true)
    self.menu = nil
end

-- 升级tower
function GameScene:OnUpLevelTower(event)
    print('GameScene >>>>> line = 100', event.name, event.block);
    local block = event.block
    local tower = block:GetTower()
    local tower_cfg = TOWER_CFG["tower_" .. tower:GetTowerType()]
    local tower_lv = tower:GetTowerLevel()
    if tower_lv < #tower_cfg.cost and self.coin >= tower_cfg.cost[tower_lv + 1] then
        self.coin = self.coin - tower_cfg.cost[tower_lv + 1]
        self.coin_label:setString(self.coin)
        tower:UpTowerLevel()
    end
    self.menu:removeSelf(true)
    self.menu = nil
    self.is_build = true
end 

function GameScene:CheckpointFinsh()
    local res = ""
    local is_victory
    if self.score > 0 then 
        res = "anim/victory_%d.png"
        is_victory = true
    else 
        res = "anim/lose_%d.png"
        is_victory = false
    end
    local sp_1 = cc.Sprite:create(string.format(res, 1));  
    sp_1:setPosition(display.center);  
    self:addChild(sp_1);
    local end_callback = cc.CallFunc:create(function ()
        local alert = EndAlert.new(is_victory)
        self:addChild(alert)
        alert:SetRestartCallBack(function ()
            -- print('GameScene >>>>> line = 251 restart');
            self:InitData()
            self:DeleteData()
            alert:removeSelf(true)
        end)
        alert:SetGoNextCallBack(function ()
            -- print('GameScene >>>>> line = 254 go next');
            self:InitData()
            self:DeleteData()
            alert:removeSelf(true)
        end)
        alert:SetReturnCallBack(function ()
            -- print('GameScene >>>>> line = 257 return');
            self:DeleteData()
            local scene = self:getApp():getSceneWithName("MainScene")
            cc.Director:getInstance():replaceScene(scene)
            alert:removeSelf(true)
        end)
    end)
    local animation = cc.Animation:create()
    if animation then  
        for i = 1, 17 do  
            local frameName = string.format(res, i)
            animation:addSpriteFrameWithFile(frameName)  
        end  
        animation:setDelayPerUnit(1 / 12)  
        animation:setRestoreOriginalFrame(false)  
        sp_1:stopAllActions()  
        sp_1:runAction(cc.Sequence:create(cc.Animate:create(animation), cc.FadeOut:create(0.2), end_callback))  
    end
    self.is_start = false
    self:dispatchEvent({name = UPDATE_GAME_STATE, is_start = self.is_start})
    self:CancerTimer()
end

function GameScene:UpdateMaster()
    if not self.is_start then 
        return
    end
    self.time = self.time + 0.5
    if self.wave <= #self.monster_wave then  -- 释放怪物
        if self.wave_count < self.monster_wave[self.wave].count then 
            if self.next_wave then 
                if self.time / 15 >= self.wave_time then 
                    self.next_wave = false
                    self.time = 0
                    -- self.monster_count = self.monster_count + 1
                    -- self:CreateMonster(self.monster_wave[self.wave].type)
                    
                end
            else 
                if self.time / 15 >= self.monster_wave[self.wave].dt then 
                    self.monster_count = self.monster_count + 1
                    self.wave_count = self.wave_count + 1
                    self.time = 0
                    self:CreateMonster(self.monster_wave[self.wave].type)
                end
            end
        else
            -- 放完一波怪物
            self.time = 0
            self.wave = self.wave + 1
            -- self.monster_count = 0
            self.wave_count = 0
            self.next_wave = true
        end
    else 
        local has_monster = false
        for k,v in pairs(self.monster_list) do
            if v:GetMonsterState() == MONSTER_STATE.RUNNING then 
                has_monster = true
                break
            end
        end
        if not has_monster and self.score > 0 then 
            -- 通关
            self:CheckpointFinsh()
            local f = io.open("src/role.lua", "w")
            local str = string.format("return {%d, %d, %d}", self.level, self.coin, self.score)
            f:write(str)
            f:close()
            return
        end
    end
    for i, tower in pairs(self.tower_list) do
        if tower and tower:IsFree() then 
            for j, monster in pairs(self.monster_list) do
                if monster then 
                    if monster:IsLiving() then -- 锁定怪物
                        tower:SetMonster(monster)
                    elseif monster:IsDead() then  -- 怪物死亡
                        self.coin = self.coin + monster:GetAwardCoin()
                        self.coin_label:setString(self.coin)
                        self.monster_list[j] = nil
                    end
                end
            end
        end
    end
end

function GameScene:CreateMonster(type)
    local monster = Monster.new(self, type, 1, self.route_list, self.monster_count)
    self:addChild(monster)
    table.insert(self.monster_list, monster)
    -- self:dispatchEvent({name = "monster_" .. self.monster_count, data = MONSTER_STATE.RUNNING})
    monster:SetState(MONSTER_STATE.RUNNING)
    EventProxy.new(monster, self)
        :addEventListener(MONSTER_END_PATH, handler(self, self.OnRunToEnd))
end

function GameScene:CreateTower(type, block)
    self.tower_count = self.tower_count + 1
    local tower = Tower.new(self, type, block:getPosition())
    block:SetTower(tower)
    self:addChild(tower)
    table.insert(self.tower_list, tower)
    EventProxy.new(tower, self)
        :addEventListener(SHOOT_BULLET, handler(self, self.FireBullet))
    -- print('GameScene >>>>> line = 104', #self.tower_list);
    -- self:dispatchEvent({name = "monster_" .. self.tower_count, data = 1})
end

function GameScene:OnMonsterDead(event)
    -- body
end

function GameScene:FireBullet(event)
    local bullet = Bullet.new(self, event.tower_type, event.tower_type, event.damage, event.slow_speed, event.tower_pos, event.monster, self.route_list, self.monster_list)
    self:addChild(bullet)
end

function GameScene:OnRunToEnd(event)
    self.score = self.score - event.damage
    self.score_label:setString("Score:" .. self.score)
    if self.score <= 0 then 
        self:CheckpointFinsh()
    end
end

function GameScene:SetTouchEvent()
    local layer = display.newNode()
    layer:setContentSize(display.width, display.height)
    
    local function onTouchBegin(touch, event)
        local locationInNode = self:convertToNodeSpace(touch:getLocation())
        self:OnBlockClick(locationInNode)
        return true
    end
    local listener = cc.EventListenerTouchOneByOne:create();
    listener:setSwallowTouches(true);
    listener:registerScriptHandler(onTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN);
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer);
    
    self:addChild(layer)
end

function GameScene:OnBlockClick(locationInNode)
    for k,v in pairs(self.blocks) do
        if v:GetBlockType() == 1 and cc.rectContainsPoint(v:getBoundingBox(), locationInNode) then 
            if self.is_build then
                self.is_build = false
                return
            end
            if nil == self.menu then 
                -- local x, y = v:getPosition()
                self.menu = Menu.new(v, self.width, self.height)
                self:addChild(self.menu)
                EventProxy.new(self.menu, self)
                    :addEventListener(BUILD_TOWER, handler(self, self.OnBuildTower))
                EventProxy.new(self.menu, self)
                    :addEventListener(SELL_TOWER, handler(self, self.OnSellTower))
                EventProxy.new(self.menu, self)
                    :addEventListener(UP_LEVEL_TOWER, handler(self, self.OnUpLevelTower))
            end
            if self.menu and not cc.rectContainsPoint(self.menu:GetBoundingBox(), locationInNode) then
                self.menu:removeSelf(true)
                self.menu = nil
            end
            -- self:CreateTower(3, v:getPosition())
            return 
        end
    end
end




-- function GameScene:MasterRun()
--     self.master = display.newSprite("pause_searchpai.png")   
--         :move(self.route_list[1].pos)
--         :addTo(self)
--     self:ChangeState(1, false)
--     self:RunAct()
-- end

-- function GameScene:RunAct()
--     local befor = self.route_list[self.route_point].pos
--     local last = self.route_list[self.route_point + 1].pos
--     local state = math.abs(befor.x - last.x) > math.abs(befor.y - last.y) and 1 or 3
--     local time = state == 1 and (befor.x - last.x) / self.width or (befor.y - last.y) / self.height
--     self.route_point = self.route_point + 1
--     local move = cc.MoveTo:create(math.abs(time * 0.8), self.route_list[self.route_point].pos)
--     local end_callBack = cc.CallFunc:create(function ()
--         if self.route_point == #self.route_list then 
--             return 
--         end
--         local is_slip = false
--         if time < 0 then 
--             if state == 3 then 
--                 is_slip = false
--             else 
--                 state = state + 1
--             end
--         end
--         self:ChangeState(state, is_slip)
--         self:RunAct()
--     end)
--     self.master:runAction(cc.Sequence:create(move, end_callBack))
-- end

-- local targe_name = {
-- 	[1] = "up",
-- 	[2] = "down",
-- 	[3] = "row",
-- }

-- function GameScene.GetMosterAnimation(targe)
-- 	local spriteFrame = cc.SpriteFrameCache:getInstance()
-- 	local path, res_name = "moster_1.plist", "moster_1"
-- 	spriteFrame:addSpriteFrames(path)
-- 	local animation = cc.Animation:create() 
-- 	-- local num = game_cfg.moster[type].act_num[targe] or 1
--     for i=1, 5 do  
--         -- print('GameScene >>>>> line = 125', string.format( "%s_%s_ (%d).png", res_name, targe_name[targe], i));
-- 	    local blinkFrame = spriteFrame:getSpriteFrame(string.format("%s_%s_ (%d).png", res_name, targe_name[targe], i))  
-- 	    animation:addSpriteFrame(blinkFrame)  
-- 	end  
-- 	animation:setDelayPerUnit(1 / 15)--设置每帧的播放间隔  
-- 	animation:setRestoreOriginalFrame(true)--设置播放完成后是否回归最初状态  
-- 	local action = cc.Animate:create(animation)
-- 	return action
-- end

-- function GameScene:ChangeState(state, is_slip)
-- 	self.master:stopAllActions()
-- 	local action = self.GetMosterAnimation(state)
-- 	self.master:setFlippedX(is_slip)
-- 	self.master:runAction(cc.RepeatForever:create(action))
-- end


return GameScene