local isPlaying = false -- 播放标识                                                                                                      ①  
local size =cc.Director:getInstance():getWinSize()  
   
… …  
   
-- create layer  
function GameScene:createLayer()  
   
   local layer = cc.Layer:create()  
   
   local spriteFrame  = cc.SpriteFrameCache:getInstance()  
   spriteFrame:addSpriteFramesWithFile("run.plist")  
   
   local function OnAction(menuItemSender)  
   
       if not isPlaying then  
   
            --///////////////动画开始//////////////////////  
            local animation =cc.Animation:create()          
            for i=1,4 do  
                local frameName =string.format("h%d.png",i) 
                cclog("frameName =%s",frameName)  
                local spriteFrame = spriteFrame:getSpriteFrameByName(frameName) 
               animation:addSpriteFrame(spriteFrame)        
            end  
   
           animation:setDelayPerUnit(0.15)          --设置两个帧播放时间                      ⑥  
           animation:setRestoreOriginalFrame(true)    --动画执行后还原初始状态           ⑦  
   
            local action =cc.Animate:create(animation)      
            sprite:runAction(cc.RepeatForever:create(action))
            --//////////////////动画结束///////////////////  
            isPlaying = true  
       else  
            sprite:stopAllActions()                          
            isPlaying = false  
       end  
   end  
   toggleMenuItem:registerScriptTapHandler(OnAction)  
   
   return layer  
end  
   
return GameScene  