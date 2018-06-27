local BloodProgressBar = class("BloodProgressBar", function (  )  
    return cc.Node:create()  
end)  
  
function BloodProgressBar:create()  
    local bloodProgressBar = BloodProgressBar:new()  
    bloodProgressBar:getViews()  
    return bloodProgressBar  
end  

function BloodProgressBar:ctor()  
end  

function BloodProgressBar:getSize()
    return self.size
end

function BloodProgressBar:setPercentage(per)
    if self.progress then
        self.progress:setPercentage(per)
    end
end
  
function BloodProgressBar:getViews()  
      
    --血条背景  
    local bloodEmptyBg = cc.Sprite:create("progress_bar_bg.png")  
    bloodEmptyBg:setAnchorPoint(cc.p(0.5,0.5))  
    local bloodEmptyBgSize = bloodEmptyBg:getContentSize()  
    bloodEmptyBg:setPosition(cc.p(bloodEmptyBgSize.width/2,bloodEmptyBgSize.height/2))  
    self:addChild(bloodEmptyBg)  
  
    --血条  
    local bloodBody = cc.Sprite:create("progress_bar_red.png")  
  
    --创建进度条  
    local bloodProgress = cc.ProgressTimer:create(bloodBody)  
    bloodProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR) --设置为条形 type:cc.PROGRESS_TIMER_TYPE_RADIAL
    bloodProgress:setMidpoint(cc.p(0,0)) --设置起点为条形坐下方  
    -- bloodProgress:setBarChangeRate(cc.p(0,1))  --设置为竖直方向  
    bloodProgress:setBarChangeRate(cc.p(1,0))  --设置为竖直方向  
    bloodProgress:setPercentage(50) -- 设置初始进度为30  
    bloodProgress:setPosition(cc.p(bloodEmptyBgSize.width/2,bloodEmptyBgSize.height/2))  
    bloodProgress:setAnchorPoint(cc.p(0.5,0.5)) 
    self.size = bloodEmptyBgSize
    self.progress = bloodProgress
    self:addChild(bloodProgress)  
  
    --让进度条一直从0--100重复的act  
    -- local progressTo = cc.ProgressTo:create(5,100)  
    -- local clear = cc.CallFunc:create(function (  )  
    --     bloodProgress:setPercentage(0)  
    -- end)  
    -- local seq = cc.Sequence:create(progressTo,clear)  
    -- bloodProgress:runAction(cc.RepeatForever:create(seq))  
end  
  
return BloodProgressBar