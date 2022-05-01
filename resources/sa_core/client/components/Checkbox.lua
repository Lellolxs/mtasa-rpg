Components['Checkbox'] = [[
    local __Checkboxes = {};

    local __DefaultCheckboxStyles = {
        default = {
            bgColor = { 20, 20, 20 },
            hoverColor = { 24, 24, 24 },

            iconColor = { 6, 108, 205 }, 

            font = exports.sa_core:requireFont('opensans-bold', 11),
                
            radius = 0.5, 
        },
    };

    local __DefaultCheckboxSettings = {
        value = true, 
        style = 'default',
        iconSize = 8, 
    };

    function Checkbox(id, settings)
        local settings = (settings or {});
        local self = table.merge((settings or { }), __DefaultCheckboxSettings);

        self.id = id;
        self.__events = {};
        self.__font = exports.sa_core:requireFont('fontawesome', self.iconSize);

        self.render = function(x, y, width, height)
            local style = (type(self.style) ~= 'table')
                            and (__DefaultCheckboxStyles[self.style] or __DefaultCheckboxStyles.default) 
                            or self.style;

            local background = isCursorInArea(x, y, width, height) 
                                and tocolor(unpack(style.hoverColor))
                                or tocolor(unpack(style.bgColor));

            if (style.radius ~= nil) then 
                if (not dxDrawRoundedRectangle) then 
                    outputDebugString("Requirezd mar a kurva \"Rectangle\" componentet is...", 1);
                    return;
                end 

                dxDrawRoundedRectangle(
                    x, y, width, height, 
                    background, 
                    style.radius
                );
            else 
                dxDrawRectangle(
                    x, y, 
                    width, height, 
                    background
                );
            end 
                                
            dxDrawText(
                self.value and "" or "", 
                x, y, x + width, y + height, 
                tocolor(unpack(style.iconColor)), 
                1, self.__font, 
                'center', 'center'
            );

            self.__lastVisible = getTickCount();
            self.__position = Vector2(x, y);
            self.__size = Vector2(width, height);
        end 

        self.__emitEvent = function(eventName, ...)
            if (self.__events[eventName]) then 
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

        __Checkboxes[id] = self;
        return self;
    end 

    addEventHandler('onClientClick', root, function(button, state)
        if (not isCursorShowing() or button ~= 'left' or state ~= 'down') then return; end

        local tick = getTickCount();

        for id, v in pairs(__Checkboxes) do 
            if (
                v.__lastVisible and 
                (v.__lastVisible + __visibilityDiff) > tick and 
                (v.__position ~= nil and v.__size ~= nil) and 
                isCursorInArea(v.__position, v.__size) 
            ) then
                v.value = not v.value;
                v.__emitEvent('input');
            end 
        end 
    end);
]]