local Tower = class("Tower", function()
    return display.newNode()
end)


function Tower:ctor(parent, type, x, y)
    self.tower_level = 1;
    self.state = TOWER_STATE.LIVING
    self.type = type;
    self:UpdateTowerCfg()
    self.current_shoot_dts = 0;
    self.is_start = true

    self.tower = display.newSprite(string.format("tower/tower_%d_%d.png", type, self.tower_level))
    :addTo(self)
    local size = self.tower:getContentSize()
	self.tower:setPosition(x + size.width / 2, y + size.height / 2)
    self.tower:setAnchorPoint(X_ANCHOR[type][1], X_ANCHOR[type][2])

    self.monster = nil
    self:CreateTimer()

    GameObject.Extend(self):AddComponent(EventProtocol):exportMethods()
    EventProxy.new(parent, self)
        :addEventListener(UPDATE_GAME_STATE, handler(self, self.OnUpdateGameState))
        :addEventListener(RESTART, handler(self, self.OnRestartGame))
end

function Tower:CreateTimer()
    local scheduler = cc.Director:getInstance():getScheduler()
    self.schedulerID = scheduler:scheduleScriptFunc(function()  
        self:UpdateTower()
    end, 0, false)
end

function Tower:CancerTimer()
	if self.schedulerID then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
	end
end

function Tower:cleanup()
    -- body
end

-- 更新是否暂停
function Tower:OnUpdateGameState(event)
    self.is_start = event.is_start
end

function Tower:OnRestartGame(event)
    self:CancerTimer()
    self.tower:removeSelf(true)
end

function Tower:UpdateTower()
    if not self.is_start then 
        return
    end
    if self.monster then 
        self.current_shoot_dts = self.current_shoot_dts + 1
        local monster_pos = self.monster:GetPos()
        local tower_pos = cc.p(self.tower:getPosition())
        -- 一定时间间隔发射子弹
        if self.current_shoot_dts / 50 == self.shoot_dts then 
            self.current_shoot_dts = 0
            self:ShootBullet(tower_pos, self.monster)
        end

        -- 可转动tower
        if self.type == 1 then 
            local r_pos = cc.pSub(tower_pos, monster_pos)
            local angle = cc.pToAngleSelf(r_pos) * - 180 / math.pi - 90
            self.tower:setRotation(angle)
        end 
        local distance = cc.pGetDistance(monster_pos, tower_pos)
        -- 怪物死亡或跑出视野或到终点
        if distance > self.attack_ranges or not self.monster:IsLiving() or self.monster:GetMonsterState() == MONSTER_STATE.END_PATH then 
            self.monster = nil
        end
    end
end

-- 锁定进入视野的怪物
function Tower:SetMonster(monster)
    if self.tower and nil == self.monster and monster:GetMonsterState() ~= MONSTER_STATE.END_PATH then
        if (monster:GetMonsterType() == 5 and self.type ~= 5) or 
            (monster:GetMonsterType() ~= 5 and self.type == 5) then 
            return
        end
        local monster_pos = monster:GetPos()
        local tower_pos = cc.p(self.tower:getPosition())
        local distance = cc.pGetDistance(monster_pos, tower_pos)
        if distance <= self.attack_ranges then 
            self.monster = monster
        end
    end
end

function Tower:IsFree()
    return nil == self.monster
end

-- 升级tower
function Tower:UpTowerLevel()
    if self.tower_level < 3 then 
        self.tower_level = self.tower_level + 1
        self.tower:setSpriteFrame(cc.Sprite:create(string.format("tower/tower_%d_%d.png", self.type, self.tower_level)):getSpriteFrame())
    end
    self:UpdateTowerCfg()
end

-- 更新tower数据
function Tower:UpdateTowerCfg()
    self.current_damage = TOWER_CFG["tower_" .. self.type].damages[self.tower_level]
    self.slow_speed = TOWER_CFG["tower_" .. self.type].slow_speed[self.tower_level]
    self.attack_ranges = TOWER_CFG["tower_" .. self.type].attack_ranges[self.tower_level]
    self.cost = TOWER_CFG["tower_" .. self.type].cost[self.tower_level]
    self.shoot_dts = TOWER_CFG["tower_" .. self.type].shoot_dts[self.tower_level]
end

function Tower:GetTowerLevel()
    return self.tower_level
end

function Tower:SetTowerState(state)
    if self.state == state then 
        return 
    end
    self.state = state
end

function Tower:SellTower()
    self:SetTowerState(TOWER_STATE.SELL)
    self:CancerTimer()
    self.tower:removeSelf(true)
    self.tower = nil
end

function Tower:GetTowerState()
    return self.state
end

function Tower:GetTowerType()
    return self.state
end

function Tower:ShootBullet(tower_pos, monster)
    self:dispatchEvent({name = SHOOT_BULLET, tower_type = self.type, damage = self.current_damage, slow_speed = self.slow_speed, tower_level = self.tower_level, tower_pos = tower_pos, monster = monster})
end

return Tower