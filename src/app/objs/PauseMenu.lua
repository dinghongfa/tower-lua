local PauseMenu = class("PauseMenu", function ()
    return display.newNode()
end)

function PauseMenu:ctor(parent)
    self.parent = parent
    cc.LayerColor:create(COLOR4B.GRAY_A, display.width, display.height)
        -- :move(display.center)
        -- :addTo(self)
    local bg = cc.Scale9Sprite:create("setting_bg.png"):addTo(self):move(display.center)
    bg:setContentSize({width = display.width / 2, height = display.height - 20})

    self:CreateMenuBtn()
    self:OnTouchEvent()
    -- self:setOpacity(0)
    -- self.is_open = true
end

function PauseMenu:OnTouchEvent()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch, event)
            return true--返回true时，该层下面的层的触摸事件都会屏蔽掉
    end,cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function PauseMenu:CreateMenuBtn()
    self.MusicBtn = self:CreateButton("btn_1_normal.png", "btn_1_pressed.png", cc.p(display.width / 2, display.height / 6 * 4), "音乐：开", 1)
        :addTo(self)
    self.MianBtn = self:CreateButton("btn_1_normal.png", "btn_1_pressed.png", cc.p(display.width / 2, display.height / 6 * 3), "主界面", 2)
        :addTo(self)
    self.returnBtn = self:CreateButton("btn_1_normal.png", "btn_1_pressed.png", cc.p(display.width / 2, display.height / 6 * 2), "重新开始", 3)
        :addTo(self)
    self.exitBtn = self:CreateButton("btn_1_normal.png", "btn_1_pressed.png", cc.p(display.width / 2, display.height / 6 * 1), "返回游戏", 4)
        :addTo(self)
end

function PauseMenu:CreateButton(path_1, path_2, position, btnStr, event_type)
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

function PauseMenu:OnButtonClick(type)
    if 1 == type then
        is_music = not is_music
        local str = is_music and "音乐：关" or "音乐：开"
        self.MusicBtn:setTitleText(str)
        if is_music then 
            AudioEngine.resumeMusic()
        else
            AudioEngine.pauseMusic()
        end
        self.MusicBtn:getTitleRenderer():setSystemFontSize(30)
    elseif 2 == type then
        self.parent:DeleteData()
        local scene = self.parent:getApp():getSceneWithName("MainScene")
        cc.Director:getInstance():replaceScene(scene)
    elseif 3 == type then
        -- local scene = self:getApp():getSceneWithName("GameScene")
        -- -- cc.Director:getInstance():replaceScene(scene)
        -- cc.Director:getInstance():popScene()
        self.parent:Restart()
    elseif 4 == type then 
        self.parent:ContinueGame()
        -- cc.Director:getInstance():endToLua() 
    end
end

return PauseMenu