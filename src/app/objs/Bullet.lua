local Bullet = class("Bullet", function ()  
    return cc.Node:create()  
end)  

function Bullet:ctor(parent, type, level, damage, slow_speed, tower_pos, monster, next_pos, monster_list)
    self.type = type
    self.damage = damage
    self.slow_speed = slow_speed
    self.target = monster
    self.monster_list = monster_list
    self.bullet = cc.Sprite:create(string.format("bullet/bullet_%d.png", type))
    self.direction = cc.pNormalize(cc.pSub(monster:GetPos(), tower_pos))
    self.bullet:setPosition(cc.pAdd(tower_pos, cc.pMul(self.direction, 15)))
    -- self.bullet:setPosition(tower_pos)
    self:addChild(self.bullet)
    self.is_start = true
    self.time_ = 0
    self:InitData()

    local r_pos = cc.pSub(tower_pos, monster:GetPos())
    local angle = cc.pToAngleSelf(r_pos) * - 180 / math.pi - 90
    self.bullet:setRotation(angle)
    self:CreateTimer()

    GameObject.Extend(self):AddComponent(EventProtocol):exportMethods()
    EventProxy.new(parent, self)
        :addEventListener(UPDATE_GAME_STATE, handler(self, self.OnUpdateGameState))
end  

function Bullet:CreateTimer()
    local scheduler = cc.Director:getInstance():getScheduler()
    self.schedulerID = scheduler:scheduleScriptFunc(function()  
        self:UpdateBullet()
    end, 0, false)
end

function Bullet:CancerTimer()
	if self.schedulerID then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
	end
end

function Bullet:OnUpdateGameState(event)
    self.is_start = event.is_start
end

function Bullet:InitData()
    -- 子弹会落在目标中心点的一定范围内
    if nil == self.target then 
        return 
    end
    local size = self.target:GetSize()
    local targetX, targetY = self.target:GetPos().x, self.target:GetPos().y
    local direction = self.target:GetDirection()
    local point = self.target:GetPoint()
    local route = self.target:GetRouteList()
    self.flyTime_ = math.random(70, 85) / 100
    self.g_ = -500
    self.timeOffset_ = 0.2
    self.startX_, self.startY_ = self.bullet:getPosition()
    self.prevX_   = self.startX_
    self.prevY_   = self.startY_
    local move_len = self.target:GetSpeed() * 10 * (self.flyTime_ + self.timeOffset_)
    if self.target:IsLiving() then
        targetX = targetX + DIRECTION[direction][1] * move_len
        targetY = targetY + DIRECTION[direction][2] * move_len
        if route[point] then
            if IsInRange(route[point].pos.x, self.target:GetPos().x, targetX) then
                local d_x = math.abs(targetX - route[point].pos.x)
                targetX = route[point].pos.x
                if point < #route then 
                    targetY = targetY + (route[point + 1].pos.y > targetY and 1 or -1) * d_x
                end
            elseif IsInRange(route[point].pos.y, self.target:GetPos().y, targetY) then
                local d_y = math.abs(targetY - route[point].pos.y)
                targetY = route[point].pos.y
                if point < #route then 
                    targetX = targetX + (route[point + 1].pos.x > targetX and 1 or -1) * d_y
                end
            end
        end
    end
    targetY = targetY - 15

    local radius = size.width / 4
    self.offset_x = radius * (math.random(0, 70) / 100) * 0.2
    self.offset_x = (math.random(1, 2) % 2 == 0 and 1 or -1) * self.offset_x
    targetX = targetX + self.offset_x
    
    self.offset_y = radius * (math.random(0, 70) / 100) * 0.2
    self.offset_y = (math.random(1, 2) % 2 == 0 and 1 or -1) * self.offset_y
    targetY = targetY + self.offset_y

    self.offsetX_  = (targetX - self.startX_) / self.flyTime_
    self.offsetY_  = ((targetY - self.startY_) - ((self.g_ * self.flyTime_) * (self.flyTime_ / 2))) / self.flyTime_
end

function Bullet:UpdateBullet()
    if not self.is_start then 
        return
    end
    if self.bullet then
        if self.type == 1 or self.type == 3 or self.type == 5 then 
            -- 不为抛物线子弹
            self.bullet:setPosition(cc.pAdd(cc.p(self.bullet:getPosition()), cc.pMul(self.direction, 5)))
            for k, monster in pairs(self.monster_list) do
                if monster and monster:IsLiving() then 
                    -- local distance = cc.pGetDistance(cc.p(self.bullet:getPosition()), cc.p(monster:getPosition()))
                    if cc.rectIntersectsRect(self.bullet:getBoundingBox(), monster:GetBoundingBox()) then 
                        if not (self.type ~= monster:GetMonsterType() and (self.type == 5 or monster:GetMonsterType() == 5)) then 
                            self:HitEnd(monster)
                            return
                        end
                    end
                end
            end
        else
            -- 抛物线子弹
            self.time_ = self.time_ + 1 / 60
            local time = self.time_ - self.timeOffset_
            local x = self.startX_ + self.time_ * self.offsetX_
            local y = self.startY_ + self.time_ * self.offsetY_ + self.g_ * time * time / 2
            self.bullet:setPosition(x, y)

            local degrees = math.atan2(y - self.prevY_, x - self.prevX_) * - 180 / math.pi
            self.prevX_, self.prevY_ = x, y
            self.bullet:setRotation(degrees)
            if time >= self.flyTime_ then
                self:HitEnd(self.target, degrees)
                return
            end
        end
    end 
end


function Bullet:HitEnd(monster, degrees)
    monster:SetBulletHit(self.offset_x, self.offset_y, self.type, degrees)
    monster:BeAttacked(self.damage, self.slow_speed)
    self:CancerTimer()
    self.bullet:setVisible(false)
    self:removeSelf(true)
    self.bullet = nil
    if is_effect_music then 
        print("cd>>>>updateBullet")
        AudioEngine.playEffect("sound/skill_sound_2.wav", false)
    end
end

function Bullet:GetSize()
    return self.size
end
  
return Bullet
