Components['Button'] = [[
    local __Buttons = {};
    local __ButtonTransitionIncrease = 6.5;

    local __DefaultButtonStyles = {
        default = {
            bgColor = { 20, 20, 20, 255 },
            hoverColor = { 6, 108, 205, 255 },

            textColor = { 255, 255, 255, 255 }, 
            textHoverColor = { 14, 14, 14, 255 },

            radius = 0.5, 
            border = nil, 
        },
    };

    local __DefaultButtonSettings = {
        masked = false,
        disabled = false,
        style = 'default',
        font = exports.sa_core:requireFont('opensans-bold', 11),

        __value = 0, 
        __lastVisible = 0,
        __lastPosition = nil, 
        __lastSize = nil,
        __hovering = false,
        __events = {},
    };

    function Button(id, settings)
        if (not id) then return; end
        if (not settings) then settings = {}; end

        local self = table.merge(settings, __DefaultButtonSettings);

        self.id = id;
        self.style = (type(self.style) ~= 'table')
                            and (__DefaultButtonStyles[self.style] or __DefaultButtonStyles.default) 
                            or table.merge(self.style, __DefaultButtonStyles.default);

        self.render = function(text, x, y, width, height)
            local style = self.style;

            local r, g, b = interpolateBetween(
                style.bgColor[1], style.bgColor[2], style.bgColor[3], 
                style.hoverColor[1], style.hoverColor[2], style.hoverColor[3], 
                self.__value / 100, "InQuad"
            );
            local alpha = interpolateBetween(style.bgColor[4], 0, 0, style.hoverColor[4], 0, 0, self.__value / 100, "InQuad");

            local tR, tG, tB = interpolateBetween(
                style.textColor[1], style.textColor[2], style.textColor[3], 
                style.textHoverColor[1], style.textHoverColor[2], style.textHoverColor[3], 
                self.__value / 100, "InQuad"
            );
            local tAlpha = interpolateBetween(style.textColor[4], 0, 0, style.textHoverColor[4], 0, 0, self.__value / 100, "InQuad");

            if (style.radius) then 
                if (not dxDrawRoundedRectangle) then 
                    outputDebugString("Requirezd mar a kurva \"Rectangle\" componentet is...", 1);
                    return;
                end 

                dxDrawRoundedRectangle(
                    x, y, width, height, 
                    tocolor(r, g, b, alpha), 
                    style.radius
                );
            else 
                dxDrawRectangle(
                    x, y, width, height, 
                    tocolor(r, g, b, alpha)
                )
            end 

            dxDrawText(
                text, 
                x, y, x + width, y + height, 
                tocolor(tR, tG, tB, tAlpha), 
                1, self.font, 'center', 'center'
            );

            self.__lastPosition = Vector2(x, y);
            self.__lastSize = Vector2(width, height);

            local insideArea = isCursorInArea(self.__lastPosition, self.__lastSize);
            if (insideArea and self.__value < 100) then 
                self.__value = (self.__value + __ButtonTransitionIncrease > 100) and 100 or (self.__value + __ButtonTransitionIncrease);
            elseif (not insideArea and self.__value > 0) then 
                self.__value = (self.__value - __ButtonTransitionIncrease < 0) and 0 or (self.__value - __ButtonTransitionIncrease);
            end 

            if (self.__hovering ~= insideArea) then 
                self.__emitEvent('hover', insideArea);
                self.__hovering = insideArea;
            end 

            self.__lastVisible = getTickCount();
        end 

        self.destroy = function()
            __Buttons[self.id] = nil;
            self = nil;
        end 

        self.__emitEvent = function(eventName, ...)
            if (eventName and self.__events[eventName]) then
                for _, handler in ipairs(self.__events[eventName]) do 
                    handler(self, ...);
                end 
            end 
        end

        self.on = function(eventName, handler)
            if (not self.__events[eventName]) then 
                self.__events[eventName] = {};
            end 

            table.insert(self.__events[eventName], handler);
        end 

        __Buttons[id] = self;

        return self;
    end 

    addEventHandler('onClientClick', root, function(button, state)
        if (isCursorShowing()) then 
            local tick = getTickCount();

            for id, v in pairs(__Buttons) do 
                if (
                    isCursorInArea(v.__lastPosition, v.__lastSize) and 
                    v.__lastVisible and 
                    v.__lastVisible + 500 > tick and 
                    v.__events.click
                ) then 
                    for _, handler in ipairs(v.__events.click) do 
                        handler(v, button, state);
                    end 
                end 
            end 
        end 
    end);
]]