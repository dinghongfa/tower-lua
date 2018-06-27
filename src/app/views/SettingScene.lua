local SettingScene = class("SettingScene", cc.load("mvc").ViewBase)

function SettingScene:onCreate( ... )
    cc.LayerColor:create(COLOR4B.GRAY, display.width, display.height)
        -- :move(display.center)
        :addTo(self)
    local bg = cc.Scale9Sprite:create("setting_bg.png"):addTo(self):move(display.center)
    bg:setContentSize({width = display.width / 2, height = display.height - 20})

    self:CreateMenuBtn()
    self:setOpacity(0)
    self.is_open = true
end

function SettingScene:CreateMenuBtn()
    self.MusicBtn = self:CreateButton("btn_1_normal.png", "btn_1_pressed.png", cc.p(display.width / 2, display.height / 6 * 4), "音乐：开", 1)
        :addTo(self)
    self.MianBtn = self:CreateButton("btn_1_normal.png", "btn_1_pressed.png", cc.p(display.width / 2, display.height / 6 * 3), "主界面", 2)
        :addTo(self)
    self.returnBtn = self:CreateButton("btn_1_normal.png", "btn_1_pressed.png", cc.p(display.width / 2, display.height / 6 * 2), "返回游戏", 3)
        :addTo(self)
    self.exitBtn = self:CreateButton("btn_1_normal.png", "btn_1_pressed.png", cc.p(display.width / 2, display.height / 6 * 1), "退出游戏", 4)
        :addTo(self)
end

function SettingScene:CreateButton(path_1, path_2, position, btnStr, event_type)
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

function SettingScene:OnButtonClick(type)
    if 1 == type then
        self.is_open = not self.is_open
        if self.is_open then 
            self.MusicBtn:setTitleText("音乐：开")
        else
            self.MusicBtn:setTitleText("音乐：关")
        end
        self.MusicBtn:getTitleRenderer():setSystemFontSize(30)
    elseif 2 == type then
        local scene = self:getApp():getSceneWithName("MainScene")
        cc.Director:getInstance():replaceScene(scene)
    elseif 3 == type then
        local scene = self:getApp():getSceneWithName("GameScene")
        -- cc.Director:getInstance():replaceScene(scene)
        cc.Director:getInstance():popScene()
    elseif 4 == type then 
        cc.Director:getInstance():endToLua() 
    end
end

return SettingScene