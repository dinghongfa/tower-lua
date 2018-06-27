local monster_cfg = require("src/app/config/monster_cfg.lua")
local BloodProgressBar = import(".BloodProgressBar")
local Monster = class("Monster", function ()
    return display.newNode()
end)

function Monster:ctor(parent, type, state, route_list, name)
	self.type = type
	self.speed = monster_cfg["monster_" .. type].speed
	self.max = monster_cfg["monster_" .. type].hp
	self.hp = monster_cfg["monster_" .. type].hp
	self.gold = monster_cfg["monster_" .. type].gold
	self.damage = monster_cfg["monster_" .. type].damage
	self.target = monster_cfg["monster_" .. type].target
	self.state = MONSTER_STATE.INVALID
	self.direction = 1
	self.change_dir = false
	self.is_start = true
	self.is_slow = false
	self.slow_speed = 0
	self.point = 1
	self.route_list = route_list
	self.monster = display.newSprite()   
	:move(route_list[1].pos)
	:addTo(self)
	self.last_size = self.monster:getContentSize()
	self:ChangeMonsterState(self.direction)
	GameObject.Extend(self):AddComponent(EventProtocol):exportMethods()

	-- local monster_listener = "monster_" .. name
	-- EventProxy.new(parent, self)
    --     :addEventListener(monster_listener, handler(self, self.OnListener))
	EventProxy.new(parent, self)
        :addEventListener(UPDATE_GAME_STATE, handler(self, self.OnUpdateGameState))
end

function Monster:CreateTimer()
    local scheduler = cc.Director:getInstance():getScheduler()
	self.schedulerID = scheduler:scheduleScriptFunc(function()
		if self.UpdateMaster then 
			self:UpdateMaster()
		end
    end, 0, false)
end

-- 血条
function Monster:CreateHpProgress()
	self.bloodProgressBar = BloodProgressBar:create()
	self.bloodProgressBar:setScale(0.4)
	self.monster:addChild(self.bloodProgressBar)
	local size = self.bloodProgressBar:getSize()
	self.bloodProgressBar:setPosition((self.size.width - size.width * 0.4) / 2, self.size.height)
end

function Monster:CancerTimer()
	if self.schedulerID then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil
	end
end

function Monster:UpdateMaster()
	if nil == self.monster then 
		self:CancerTimer()
		return 
	end
	if self.is_slow then 
		self.time = self.time + 1 / 60
		if self.time > 2 then 
			self.is_slow = false
			self.time = 0
			self.speed = self.speed + self.slow_speed 
			self.slow_speed = 0
		end
	end
	local x, y = self.monster:getPosition()
	local pos = self.route_list[self.point].pos
	if GetPreciseDecimal(x) == GetPreciseDecimal(pos.x) and GetPreciseDecimal(y) == GetPreciseDecimal(pos.y) then
		-- 转弯
		self.point = self.point + 1
		if self.type == 5 and self.point < #self.route_list then 
			self.point = #self.route_list
		end
		if self.point > #self.route_list then 
			self:SetState(MONSTER_STATE.END_PATH)
			self:CancerTimer()
			return 
		end
		self.change_dir = true
		local d_x = pos.x - self.route_list[self.point].pos.x 
		local d_y = pos.y - self.route_list[self.point].pos.y
		if d_x == 0 or d_y == 0 then 
			self.d_xy = 1
		else
			self.d_xy = math.abs(d_x / d_y)
		end
	else
		-- 怪物移动
		self.direction = 1 
		local dire = -1 
		if math.abs(x - pos.x) > math.abs(y - pos.y) * self.d_xy then 
		-- if math.abs((x - pos.x) / (y - pos.y)) < math.abs(self.d_xy) then 
			self.direction = 4
			if pos.x > x then 
				self.direction = 3
				dire = 1
			end
			x = math.abs(x - pos.x) < self.speed and pos.x or x + dire * self.speed
		else 
			self.direction = 2
			if pos.y > y then 
				self.direction = 1
				dire = 1
			end
			y = math.abs(y - pos.y) < self.speed and pos.y or y + dire * self.speed
		end
		if self.change_dir then 
			self:ChangeMonsterState(self.direction)
			self.change_dir = false
		end
		self.monster:setPosition(x, y)
	end
	if self.bloodProgressBar then 
		self.bloodProgressBar:setPercentage(self.hp / self.max * 100)
	end
end

-- 怪物动画
function Monster:GetMosterAnimation(type, direction)
	local spriteFrame = cc.SpriteFrameCache:getInstance()
	local path, res_name, num = Monster.GetAnimaByType(type)
	if direction == 5 then
		num = monster_cfg["monster_" .. type].end_anim
	end
	spriteFrame:addSpriteFrames(path)
	local animation = cc.Animation:create() 
    for i = self.target[direction], self.target[direction] + num do
	    -- local blinkFrame = spriteFrame:getSpriteFrame(string.format("%s_%s_ (%d).png", res_name, targe_name[direction], i))  
		local idx = i
		if i < 10 then 
			idx = "00".. i
		elseif i < 100 then
			idx = "0".. i
		end
	    local blinkFrame = spriteFrame:getSpriteFrame(string.format("%s%s.png", res_name, idx))  
	    animation:addSpriteFrame(blinkFrame)  
	end  
	animation:setDelayPerUnit(1 / 30)--设置每帧的播放间隔  
	animation:setRestoreOriginalFrame(false)--设置播放完成后是否回归最初状态  

	local action = cc.Animate:create(animation)
	return action
end

-- 怪物状态跟新
function Monster:ChangeMonsterState(direction)
	self.monster:stopAllActions()
	local action = self:GetMosterAnimation(self.type, direction)
	self.monster:setFlippedX(direction == 4)
	self.monster:runAction(cc.RepeatForever:create(action))
	local size = self.monster:getContentSize()
	if (size.height ~= self.last_size.height and size.width ~= self.last_size.width) and nil == self.size then 
		self.size = size
		self:CreateHpProgress(self.size)
	end
end

function Monster:OnListener(event)
	self:SetState(event.data)
end

-- 是否暂停更新
function Monster:OnUpdateGameState(event)
	self.is_start = event.is_start
	if nil == self.monster then 
		return
	end
	if self.is_start then 
		self:ChangeMonsterState(self.direction)
		self:CreateTimer()
	else
		self.monster:stopAllActions()
		self:CancerTimer()
	end
end

function Monster:SetState(state)
	if self.state == state then 
		return 
	end
	local end_callbak = cc.CallFunc:create(function ()
		self.monster:removeSelf(true)
		self.bloodProgressBar:setVisible(false)
		self.monster = nil
	end)
	if MONSTER_STATE.RUNNING == state then 
		if self.state ~= MONSTER_STATE.INVALID then 
			return
		end
		self:CreateTimer()
	elseif MONSTER_STATE.DEAD == state then 
		self:CancerTimer()
		self.bloodProgressBar:setPercentage(0)
		self.monster:stopAllActions()
		self.monster:runAction(cc.Sequence:create(self:GetMosterAnimation(self.type, 5), cc.FadeOut:create(0.5), end_callbak))
	elseif MONSTER_STATE.END_PATH == state then 
		self:CancerTimer()
		self.monster:stopAllActions()
		self.monster:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), end_callbak))
		self:dispatchEvent({name = MONSTER_END_PATH, damage = self.damage})
	end
	self.state = state
end

-- 受到攻击状态改变
function Monster:BeAttacked(damage, slow)
	self.hp = self.hp - damage
	if not self.is_slow and slow and slow > 0 then 
		self.is_slow = true
		self.slow_speed = slow
		self.time = 0
		self.speed = self.speed - self.slow_speed 
	end
	if self.hp <= 0 then 
		self.hp = 0
		self:SetState(MONSTER_STATE.DEAD)
	end
end

-- 设置击中动画
function Monster:SetBulletHit(x, y, type, degrees)
	local num = HIT_ANIM[type]
	local anim = self:HitAnimation(type)
	local bullet = cc.Sprite:create()
	
	if num == 0 then 
		return
	elseif num == 1 then
		self.monster:addChild(bullet)
		bullet:setSpriteFrame(cc.Sprite:create(anim):getSpriteFrame());
		bullet:setColor(COLOR4B.RED)
		if degrees then 
			bullet:setRotation(degrees)
		end
		local size = self.monster:getContentSize()
		bullet:setPosition(x * 2 + size.width / 2, y * 2 + size.height / 2)
	else
		self.monster:addChild(bullet)
		bullet:runAction(cc.Animate:create(anim))
		local size = self.monster:getContentSize()
		bullet:setPosition(x * 2 + size.width / 2, y * 2 + size.height / 2)
	end
	bullet:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.FadeOut:create(0.5)))
end

function Monster:HitAnimation(type)
	local num = HIT_ANIM[type]
	if num == 0 then 
		return nil
	elseif num == 1 then
		return string.format("bullet/bullet_hit_%d.png", type)
	else
		local animation = cc.Animation:create()  
		if animation then  
			for i = 1, num do  
				local frameName = string.format("bullet/bullet_hit_%d_%d.png", type, i)
				animation:addSpriteFrameWithFile(frameName)  
			end  
			animation:setDelayPerUnit(1 / 12)  
			animation:setRestoreOriginalFrame(false)
			return animation
		end  
	end
end

function Monster:GetBoundingBox()
	local box = self.monster:getBoundingBox()
	box.height = box.height / 2
	box.width = box.width / 2
	return box
end

function Monster:GetPos()
	return cc.p(self.monster:getPosition())
end

function Monster:GetSize()
	return self.monster:getContentSize()
end

function Monster:GetAwardCoin()
	return self.gold
end

function Monster:GetMonsterDamage()
	return self.damage
end

function Monster:GetMonsterState()
	return self.state
end

function Monster:GetMonsterType()
	return self.type
end

function Monster:GetDirection()
	return self.direction
end

function Monster:GetSpeed()
	return self.speed
end

function Monster:GetPoint()
	return self.point
end

function Monster:GetRouteList()
	return self.route_list
end

function Monster:IsLiving()
	return self.monster and self.hp > 0
end

function Monster:IsDead()
	return self.hp <= 0
end

function Monster.GetAnimaByType(type)
    local name = ""
    local num = 5
	if type == 1 then
        plist = "monster/elves_woods_2_enemies-hd.plist"
        name = "gnoll_burner_0"
        num = 21
	elseif type == 2 then
		plist = "monster/elves_woods_2_enemies-hd.plist"
        name = "gnoll_blighter_0"
        num = 26
	elseif type == 3 then
		plist = "monster/elves_woods_2_enemies-hd.plist"
        name = "gnoll_reaver_0"
        num = 21
	elseif type == 4 then
		plist = "monster/elves_woods_enemies-hd.plist"
        name = "hyena_0"
        num = 9
	elseif type == 5 then
		plist = "monster/elves_woods_enemies-hd.plist"
        name = "perython_0"
        num = 13
	elseif type == 6 then
		plist = "monster/elves_woods_2_enemies-hd.plist"
        name = "gnoll_gnawer_0"
        num = 18
	end
	-- return string.format("%s.plist", name), name, num
	return plist, name, num
end

return Monster
