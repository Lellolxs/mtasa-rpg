Components['Select'] = [[
    -- Nem nyulkapiszka mert eltorom a kezed [(a jó kurva anyádat :D) szkiddaj genyo]
    __Selects = {};
    __visibilityDiff = 200; -- ms

    -- Itt nyulkapiszkazhatszmar
    local __DefaultSelectStyles = {
        default = {
            background = tocolor(20, 20, 20),
            background_active = nil, 

            padding = 6,
            align = 'left',

            radius = 0.2, 
            border = 0.035, 
            borderColor = tocolor(26, 26, 26),
            borderColor_active = tocolor(unpack(exports.sa_core:getColor('server').rgb)),
        },

        transparent = {
            background = tocolor(0, 0, 0, 0),

            padding = 5,

            radius = 0.3, 
            border = 0.035, 
            borderColor = tocolor(0, 0, 0, 0),
        },
    };

    local __DefaultSelectSettings = {
        selected = false, 
        options = { },
        disabled = false,
        style = 'default',
        font = exports.sa_core:requireFont('opensans-bold', 11),
        iconFont = exports.sa_core:requireFont('fontawesome', 11),

        numbersAllowed = true, 
        specialsAllowed = false,

        __position = nil, 
        __size = nil, 
        __lastVisible = 0,
    };

    local __IncludedCharacters = {
        [' '] = true,
    };

    function Select(id, settings) 
        if (not id) then return; end
        if (not settings) then settings = {}; end

        local self = table.merge(settings, __DefaultSelectSettings);

        self.id = id;
        self.style = (type(self.style) ~= 'table')
                        and (__DefaultSelectStyles[self.style] or __DefaultSelectStyles.default) 
                        or table.merge(self.style, __DefaultSelectStyles.default);

        self.render = function(x, y, width, height)
            if (not isElement(self.font)) then 
                return;
            end 

            local style = self.style;
            local padding = style.padding;

            if (style.radius ~= nil) then 
                if (not dxDrawRoundedRectangle) then 
                    outputDebugString("Requirezd mar a kurva \"Rectangle\" componentet is...", 1);
                    return;
                end 

                dxDrawRoundedRectangle(
                    x, y, width, height, 
                    style.background, style.radius, 
                    true, nil, true
                );

                if (style.border ~= nil) then 
                    padding = padding + style.border * 80;

                    local color = self.open and style.borderColor_active or style.borderColor;

                    dxDrawRoundedRectangle(
                        x, y, width, height, 
                        color, style.radius, 
                        false, style.border, 
                        true
                    );
                end 
            else 
                dxDrawRectangle(x, y, width, height, style.background, true);
            end 

            if (self.open) then 
                for i, v in ipairs(self.options) do 
                    if (style.radius ~= nil) then 
                        if (not dxDrawRoundedRectangle) then 
                            return;
                        end 
        
                        dxDrawRoundedRectangle(
                            x, y + (height * i), width, height, 
                            style.background, style.radius, 
                            true, nil, true
                        );
        
                        if (
                            style.border ~= nil and 
                            self.selected == i
                        ) then 
                            -- padding = padding + style.border * 80;
        
                            dxDrawRoundedRectangle(
                                x, y + (height * i), width, height, 
                                style.borderColor_active, style.radius, 
                                false, style.border, true
                            );
                        end 
                    else 
                        dxDrawRectangle(x, y + (height * i), width, height, style.background, true);
                    end

                    dxDrawText(
                        self.options[i], 
                        x + padding, y + (height * i), 
                        x + width + padding, height + y + (height * i), 
                        tocolor(200, 200, 200), 1, self.font, 
                        'left', 'center', false, false, true
                    );
                end 
            end 

            local text = "";
            local isPlaceholder = false;

            if (self.selected and self.options[self.selected]) then 
                text = self.selected and self.options[self.selected];
            else 
                text = (self.placeholder or "");
                isPlaceholder = true;
            end 

            local textWidth = dxGetTextWidth(text, 1, self.font);

            local textLength = string.len(text);
            text = (textLength > __substrFromLength)
                        and string.sub(text, textLength - __substrFromLength, textLenght)
                        or text;

            dxDrawText(
                text, 
                x + padding, y, 
                x + (width - padding), y + height, 
                tocolor(255, 255, 255, isPlaceholder and 100 or 200), 1, self.font, 
                (textWidth >= (width - padding * 2)) and 'right' or 'left', 'center', 
                true, false, true
            );

            dxDrawText(
                self.open and "" or "", 
                x + padding, y, 
                x + (width - padding), y + height, 
                tocolor(200, 200, 200),
                1, self.iconFont, 'right', 'center', 
                false, false, true
            );

            self.__lastVisible = getTickCount();
            self.__position = Vector2(x, y);
            self.__size = Vector2(width, height);
        end

        self.destroy = function()
            if (__Selects[self.id]) then
                __Selects[self.id] = nil;
            end 

            self = nil;
        end

        __Selects[id] = self;
        return self;
    end 

    addEventHandler('onClientClick', root, function(button, state)
        if (not isCursorShowing() or button ~= 'left' or state ~= 'down') then return; end

        local tick = getTickCount();

        for id, v in pairs(__Selects) do 
            if (
                v.__lastVisible and 
                (v.__lastVisible + __visibilityDiff) > tick and 
                (v.__position ~= nil and v.__size ~= nil) and 
                isCursorInArea(v.__position, v.__size) 
            ) then
                v.open = not v.open;
                return;
            end 

            local x, y = v.__position.x, v.__position.y;
            local width, height = v.__size.x, v.__size.y;

            if (v.open) then
                for optionIndex, _ in ipairs(v.options) do 
                    if (
                        v.__lastVisible and 
                        (v.__lastVisible + __visibilityDiff) > tick and 
                        (v.__position ~= nil and v.__size ~= nil) and 
                        isCursorInArea(x, y + (height * optionIndex), width, height)
                    ) then 
                        v.selected = optionIndex;
                        return;
                    end 
                end 
            end 
        end 
    end);
]]