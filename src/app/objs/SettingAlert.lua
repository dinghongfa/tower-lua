local SettingAlert = class("SettingAlert", function ()
    return display.newNode()
end)

function SettingAlert:ctor()
    local bg = cc.Scale9Sprite:create("setting_bg.png"):addTo(self):move(display.center)
    bg:setContentSize({width = display.width / 2, height = display.height - 20})
    self:OnTouchEvent()
    self:CreateMenuBtn()
end

function SettingAlert:CreateMenuBtn()
    self.MusicBtn = self:CreateButton("btn_1_normal.png", "btn_1_pressed.png", cc.p(display.width / 2, display.height / 6 * 4), is_music and "音乐：关" or "音乐：开", 1)
        :addTo(self)
    self.EffecfBtn = self:CreateButton("btn_1_normal.png", "btn_1_pressed.png", cc.p(display.width / 2, display.height / 6 * 3), is_effect_music and "音效：关" or "音效：开", 2)
        :addTo(self)
    self.returnBtn = self:CreateButton("btn_1_normal.png", "btn_1_pressed.png", cc.p(display.width / 2, display.height / 6 * 2), "返回游戏", 3)
        :addTo(self)
end

function SettingAlert:OnTouchEvent()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch, event)
            return true--返回true时，该层下面的层的触摸事件都会屏蔽掉
    end,cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function SettingAlert:CreateButton(path_1, path_2, position, btnStr, event_type)
    local button = ccui.Button:create(path_1, path_2)
    button:setPosition(position)
    if btnStr and "" ~= btnStr then 
        button:setTitleText(btnStr)
        button:getTitleRenderer():setSystemFontSize(35)
    end
    button:addClickEventListener(function(event)
        self:OnButtonClick(event_type)
    end)
    return button
end

function SettingAlert:OnButtonClick(event_type)
    if event_type == 1 then 
        -- self.music_func()
        is_music = not is_music
        local str = is_music and "音乐：关" or "音乐：开"
        self.MusicBtn:setTitleText(str)
        if is_music then 
            AudioEngine.resumeMusic()
            -- AudioEngine.stopMusic()
        else
            AudioEngine.pauseMusic()
        end
        self.MusicBtn:getTitleRenderer():setSystemFontSize(35)
    elseif event_type == 2 then 
        -- self.effect_func()
        is_effect_music = not is_effect_music
        local str = is_effect_music and "音效：关" or "音效：开"
        self.EffecfBtn:setTitleText(str)
        self.EffecfBtn:getTitleRenderer():setSystemFontSize(35)
    elseif event_type == 3 then 
        self.return_func()
    end
end

function SettingAlert:SetMusiceCallBack(callback)
    self.music_func = callback
end

function SettingAlert:SetEffectCallBack(callback)
    self.effect_func = callback
end

function SettingAlert:SetReturnCallBack(callback)
    self.return_func = callback
end

return SettingAlert