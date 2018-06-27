local EndAlert = class("EndAlert", function ()
    return display.newNode()
end)

function EndAlert:ctor(is_v)
    cc.Sprite:create("alert_bg.png"):move(display.center):addTo(self)
    self:OnTouchEvent()

    local label = cc.Label:createWithTTF(is_v and "是否进入下一关？" or "是否重新开始？", "fonts/FZZY.ttf", 30)
    :move(display.width / 2, display.height / 2 + 80)
    label:setColor(cc.BLACK)
    self:addChild(label)
    self:CreateMenuBtn(is_v)
end

function EndAlert:CreateMenuBtn(is_v)
    self.returnBtn = self:CreateButton("btn_1_normal.png", "btn_1_pressed.png", cc.p(display.width / 2 - 130, display.height / 2 - 60), "主界面", 1)
        :addTo(self)
    self.okBtn = self:CreateButton("btn_1_normal.png", "btn_1_pressed.png", cc.p(display.width / 2 + 130, display.height / 2 - 60), is_v and "下一关" or "重新开始", is_v and 2 or 3)
        :addTo(self)
end

function EndAlert:OnTouchEvent()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch, event)
            return true--返回true时，该层下面的层的触摸事件都会屏蔽掉
    end,cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function EndAlert:CreateButton(path_1, path_2, position, btnStr, event_type)
    local button = ccui.Button:create(path_1, path_2)
    button:setScale(0.6)
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

function EndAlert:OnButtonClick(event_type)
    if event_type == 1 then 
        self.return_func()
    elseif event_type == 2 then 
        self.next_func()
    elseif event_type == 3 then 
        self.restart_func()
    end
end

function EndAlert:SetRestartCallBack(callback)
    self.restart_func = callback
end

function EndAlert:SetGoNextCallBack(callback)
    self.next_func = callback
end

function EndAlert:SetReturnCallBack(callback)
    self.return_func = callback
end

return EndAlert