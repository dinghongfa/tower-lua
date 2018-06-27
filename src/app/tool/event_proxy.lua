
-- EventProxy = class("EventProxy", function()
--     return display.newNode()
-- end)

-- function EventProxy:ctor(dispatcher, obj)
--     self.dispatcher = dispatcher
--     print('event_proxy >>>>> line = 8', self.dispatcher);
--     self.handles = {}

--     self.remove_all_listen_h = nil
--     if obj and obj.AddEventListener then
--         self.remove_all_listen_h = obj:AddEventListener(GameObjEvent.REMOVE_ALL_LISTEN, function()
--             obj:RemoveEventListener(self.remove_all_listen_h)
--             self:DeleteMe()
--         end)
--     end
-- end

-- function EventProxy:cleanup()
--     print('event_proxy >>>>> line = 21');
--     self:RemoveAllEventListeners()
--     self.handles = {}
--     self.dispatcher = nil
--     self.remove_all_listen_h = nil
-- end

-- function EventProxy:AddEventListener(event_name, listener)
--     print('event_proxy >>>>> line = 27', self.dispatcher);
--     local handle = self.dispatcher:AddEventListener(event_name, listener)
--     self.handles[handle] = handle
--     return handle
-- end

-- function EventProxy:RemoveEventListener(handle)
--     self.dispatcher:RemoveEventListener(handle)
--     self.handles[handle] = nil
-- end

-- function EventProxy:RemoveAllEventListeners()
--     for _, handle in pairs(self.handles) do
--         self.dispatcher:RemoveEventListener(handle)
--     end
--     self.handles = {}
-- end


EventProxy = class("EventProxy")

function EventProxy:ctor(eventDispatcher, view)
    self.eventDispatcher_ = eventDispatcher
    self.handles_ = {}

    if view then
        -- view:addNodeEventListener(cc.NODE_EVENT, function(event)
        --     if event.name == "exit" then
        --         self:removeAllEventListeners()
        --     end
        -- end)
    end
end

function EventProxy:addEventListener(eventName, listener, data)
    local handle = self.eventDispatcher_:addEventListener(eventName, listener, data)
    self.handles_[#self.handles_ + 1] = {eventName, handle}
    return self, handle
end

function EventProxy:removeEventListener(eventHandle)
    self.eventDispatcher_:removeEventListener(eventHandle)
    for index, handle in pairs(self.handles_) do
        if handle[2] == eventHandle then
            table.remove(self.handles_, index)
            break
        end
    end
    return self
end

function EventProxy:removeAllEventListenersForEvent(eventName)
    for key, handle in pairs(self.handles_) do
        if handle[1] == eventName then
            self.eventDispatcher_:removeEventListenersByEvent(eventName)
            self.handles_[key] = nil
        end
    end
    return self
end

function EventProxy:getEventHandle(eventName)
    for key, handle in pairs(self.handles_) do
        if handle[1] == eventName then
            return handle[2]
        end
    end
end

function EventProxy:removeAllEventListeners()
    for _, handle in pairs(self.handles_) do
        self.eventDispatcher_:removeEventListener(handle[2])
    end
    self.handles_ = {}
    return self
end


