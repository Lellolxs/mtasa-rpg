Components['Slider'] = [[
    local __Sliders = {};
    local __lastDraggedSlider = nil;

    local __DefaultSliderStyles = {
        default = {
            track_color = tocolor(20, 20, 20),
            thumb_color = tocolor(26, 26, 26),
            thumb_color_hover = tocolor(unpack(exports.sa_core:getColor('server').rgb)),
            
            track_radius = 1, 
            thumb_radius = 1,

            padding = 2,
        },
    };

    local __DefaultSliderSettings = {
        style = 'default',

        min = 0, 
        max = 100,
        value = 0, 

        drag = { height = Vector2(0, 0), index = 0 },
        thumb = {
            __position = Vector2(0, 0),
            size = Vector2(18, 18)
        },

        __events = {},
    };

    function Slider(id, settings)
        if (not id) then return; end 
        if (not settings) then settings = {}; end

        local self = table.merge(settings, __DefaultSliderSettings);

        self.id = id;

        self.render = function(x, y, width, height)
            local style = (type(self.style) ~= 'table')
                            and (__DefaultSliderStyles[self.style] or __DefaultSliderStyles.default) 
                            or self.style;

            if (style.track_radius) then 
                if (not dxDrawRoundedRectangle) then 
                    outputDebugString("Requirezd mar a kurva \"Rectangle\" componentet is...", 1);
                    return;
                end 
                
                dxDrawRoundedRectangle(
                    x, y, width, height, 
                    tocolor(14, 14, 14, 255), 
                    style.track_radius
                );
            else 
                dxDrawRectangle(x, y, width, height, tocolor(14, 14, 14, 255));
            end 

            local thumbX = x + (width * (self.value / self.max)) - self.thumb.size.x / 2; 
            local thumbY = y + height / 2 - self.thumb.size.y / 2;

            local isBarHovered = (
                (__lastDraggedSlider and self.id == __lastDraggedSlider) or 
                isCursorInArea(
                    thumbX, thumbY, self.thumb.size.x, self.thumb.size.y
                )
            );

            if (style.track_radius) then 
                if (not dxDrawRoundedRectangle) then 
                    outputDebugString("Requirezd mar a kurva \"Rectangle\" componentet is...", 1);
                    return;
                end 
                
                dxDrawRoundedRectangle(
                    thumbX, thumbY, 
                    self.thumb.size.x, self.thumb.size.y, 
                    (isBarHovered and style.thumb_color_hover) 
                            and style.thumb_color_hover 
                            or style.thumb_color, 
                    style.track_radius
                );
            else 
                dxDrawRectangle(
                    thumbX, thumbY, 
                    self.thumb.size.x, self.thumb.size.y, 
                    (isBarHovered and style.thumb_color_hover) 
                            and style.thumb_color_hover 
                            or style.thumb_color
                );
            end

            if (__lastDraggedSlider and __lastDraggedSlider == self.id) then 
                local cursorX, cursorY = getCursorPosition();

                local valueDiff = (cursorX - x) / width;
                local newValue = math.floor(self.drag.value + self.max * valueDiff);

                if (newValue ~= self.value) then
                    if (newValue < 0) then newValue = 0; end
                    if (newValue > self.max) then newValue = self.max; end 

                    self.value = newValue;
                    self.__emitEvent('input');
                end 
            end

            self.thumb.__position = Vector2(thumbX, thumbY);
        end 

        self.__emitEvent = function(eventName, ...)
            if (not eventName or not self.__events[eventName]) then 
                return false;
            end 

            for _, handler in ipairs(self.__events[eventName]) do 
                handler(self, ...);
            end 
        end 

        self.on = function(eventName, handler)
            if (not eventName or not handler) then 
                return false;
            end 

            if (not self.__events[eventName]) then 
                self.__events[eventName] = {};
            end 

            table.insert(self.__events[eventName], handler);
        end 

        __Sliders[id] = self;
        return self;
    end 

    addEventHandler('onClientClick', root, function(button, state)
        if (isCursorShowing() and button == 'left' and state == 'down') then 
            for id,v in pairs(__Sliders) do 
                if (isCursorInArea(v.thumb.__position, v.thumb.size)) then 
                    local cursorX, cursorY = getCursorPosition();

                    __lastDraggedSlider = id;
                    v.drag = {
                        width = v.thumb.__position.x, 
                        offset = v.thumb.__position.x - cursorX, 
                        value = v.value
                    };
                end 
            end 
        elseif (button == 'left' and state == 'up' and __lastDraggedSlider) then 
            local box = __Sliders[__lastDraggedSlider];
        
            if (box) then 
                box.drag = { height = Vector2(0, 0), index = 0 };
            end 

            __lastDraggedSlider = nil;
        end 
    end)
]];