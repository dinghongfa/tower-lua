
local SettingAlert = import("..objs.SettingAlert")
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

cc.exports.is_music = true
cc.exports.is_effect_music = true
function MainScene:onCreate()
    self.bg = display.newSprite("background_1.jpg")
        :move(display.center)
        :addTo(self)
    self.setting = self:CreateButton("tips.png", "", display.right_top, "", 5)
        :addTo(self)
    self:CreateMenuBtn()
    if not IS_START then 
        IS_START = true
        AudioEngine.playMusic("sound/bgm.mp3", true)
        self:CreateFadeAction()
    else
        local icon_size = self.setting:getContentSize()
        self.setting:setPosition(cc.p(display.width - icon_size.width - 5, display.height - icon_size.height - 5))
    end
    self.player = nil
    self.animation = nil
end

function MainScene:CreateMenuBtn()
    self.enterBtn = self:CreateButton("btn_1_normal.png", "btn_1_pressed.png", cc.p(display.width / 2, display.height / 6 * 4), "开始游戏", 1)
        :addTo(self)
    self.continueBtn = self:CreateButton("btn_1_normal.png", "btn_1_pressed.png", cc.p(display.width / 2, display.height / 6 * 3), "继续游戏", 2)
        :addTo(self)
    self.setttingBtn = self:CreateButton("btn_1_normal.png", "btn_1_pressed.png", cc.p(display.width / 2, display.height / 6 * 2), "游戏设置", 3)
        :addTo(self)
    self.exitBtn = self:CreateButton("btn_1_normal.png", "btn_1_pressed.png", cc.p(display.width / 2, display.height / 6 * 1), "退出游戏", 4)
        :addTo(self)
end

function MainScene:CreateButton(path_1, path_2, position, btnStr, event_type)
    local button = ccui.Button:create(path_1, path_2)
    button:setPosition(position)
    if btnStr and "" ~= btnStr then 
        button:setTitleText(btnStr)
        button:getTitleRenderer():setSystemFontSize(30)
    end
    button:addClickEventListener(function(event)
        self:OnButtonClick(event_type)
    end)
    return button
end

function MainScene:OnButtonClick(type)
    local scene = self:getApp():getSceneWithName("GameScene")  
    if 1 == type then
        local f = io.open("src/role.lua", "w")
        local str = "return {1, 100, 100}"
        f:write(str)
        f:close()
        cc.Director:getInstance():replaceScene(scene)
    elseif 2 == type then 
        cc.Director:getInstance():replaceScene(scene)
    elseif 3 == type then 
        print('MainScene >>>>> line = 56 setting');
        local settingAlert = SettingAlert.new()
        settingAlert:SetReturnCallBack(function ()
            print('MainScene >>>>> line = 77');
            settingAlert:removeSelf(true)
        end)
        self:addChild(settingAlert)
    elseif 4 == type then 
        cc.Director:getInstance():endToLua() 
    elseif 5 == type then 
        self:PalyAnimation()
    end
end

function MainScene:CreateFadeAction()
    local layout = cc.LayerColor:create(cc.WHITE, display.width, display.height):addTo(self)
    local label = cc.Label:createWithSystemFont("广州某不知名不知道啥类型的公司\n\n             Auther:某某某", "Arial", 30)
        :move(display.cx, display.cy)
        :addTo(layout)
        :setTextColor(cc.BLACK)
    label:setOpacity(0)
    local fade_in = cc.FadeIn:create(0.6)
    local fade_out = cc.FadeOut:create(0.6)
    local delay = cc.DelayTime:create(0.6)
    local delay_1 = cc.DelayTime:create(1.6)
    local fade_out_2 = cc.FadeOut:create(0.6)
    local end_callBack = cc.CallFunc:create(function()
        self:DropEffect()
        layout:removeFromParent()
    end)
    self:OnTouchEvent(layout)
    label:runAction(cc.Sequence:create(fade_in, delay, fade_out))
    layout:runAction(cc.Sequence:create(delay_1, fade_out_2, end_callBack))
end

function MainScene:OnTouchEvent(node)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch, event)
            return true--返回true时，该层下面的层的触摸事件都会屏蔽掉
    end,cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end

function MainScene:PalyAnimation()
    self.player = cc.Sprite:create(string.format("anim/player_%d.png", 1))
    self.player:setPosition(display.width / 2, display.height - self.player:getContentSize().height);  
    self:addChild(self.player);
    local animation = cc.Animation:create()
    if animation then  
        for i = 1, 6 do  
            local frameName = string.format("anim/player_%d.png", i)
            animation:addSpriteFrameWithFile(frameName)  
        end  
        animation:setDelayPerUnit(1 / 10)  
        animation:setRestoreOriginalFrame(false)  
    end
    local end_callback = cc.CallFunc:create(function ()
        self.player:removeSelf(true)
        self.player = nil
    end)
    -- self.player:stopAllActions()  
    self.player:runAction(cc.Sequence:create(cc.Animate:create(animation), cc.FadeOut:create(0.2), end_callback))
end

function MainScene:JitterEffect()
    local rotate_1 = cc.RotateTo:create(0.15, 0.5)
    local scale_1 = cc.ScaleTo:create(0.3, 0.99)
    local rotate_2 = cc.RotateTo:create(0.15, -1)
    local spawn_1 = cc.Spawn:create(cc.Sequence:create(rotate_1, rotate_2), scale_1)
    
    local rotate_3 = cc.RotateTo:create(0.07, 0.25)
    local rotate_4 = cc.RotateTo:create(0.07, -0.25)
    local scale_2 = cc.ScaleTo:create(0.14, 1.01)
    local spawn_2 = cc.Spawn:create(cc.Sequence:create(rotate_3, rotate_4), scale_2)
    
    local rotate_5 = cc.RotateTo:create(0.03, 0)
    local scale_3 = cc.ScaleTo:create(0.03, 1)
    local spawn_3 = cc.Spawn:create(rotate_5, scale_3)
    self:runAction(cc.Sequence:create(spawn_1, spawn_2, spawn_3))
end

function MainScene:DropEffect()
    self.setting:setScale(2)
    local icon_size = self.setting:getContentSize()
    local move = cc.MoveTo:create(0.2, cc.p(display.width - icon_size.width - 5, display.height - icon_size.height - 5))
    local scale = cc.ScaleTo:create(0.2, 1)
    local end_callback = cc.CallFunc:create(function()
        self:JitterEffect()
    end)
    self.setting:runAction(cc.Sequence:create(cc.Spawn:create(move, scale), end_callback))
end

return MainScene
