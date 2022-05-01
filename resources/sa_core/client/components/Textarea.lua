Components['Textarea'] = [[
    -- Nem nyulkapiszka mert eltorom a kezed [(a jó kurva anyádat :D) szkiddaj genyo]
    __Textareas = {};
    __TextareaOrder = {};
    __SelectedTextarea = nil; 
    __visibilityDiff = 200; -- ms
    __substrFromLength = 128;

    -- Itt nyulkapiszkazhatszmar
    local __DefaultTextareaStyles = {
        default = {
            background = tocolor(20, 20, 20),
            background_active = nil, 

            padding = 8,
            align = 'left',

            radius = 1.0, 
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

    local __DefaultTextareaSettings = {
        masked = false,
        disabled = false,
        value = '',
        style = 'default',
        font = exports.sa_core:requireFont('opensans-bold', 10),

        numbersAllowed = true, 
        specialsAllowed = false,

        __events = {},
        __position = nil, 
        __size = nil, 
        __lastVisible = 0,
    };

    local __IncludedCharacters = {
        [' '] = true,
    };

    function Textarea(id, settings) 
        if (not id) then return; end
        if (not settings) then settings = {}; end

        local self = table.merge(settings, __DefaultTextareaSettings);

        self.id = id;
        self.style = (type(self.style) ~= 'table')
                        and (__DefaultTextareaStyles[self.style] or __DefaultTextareaStyles.default) 
                        or table.merge(self.style, __DefaultTextareaStyles.default);

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
                    style.background, style.radius
                );

                if (style.border ~= nil) then 
                    padding = padding + style.border * 80;

                    local color = (
                        __SelectedTextarea and 
                        __SelectedTextarea == self.id and 
                        style.borderColor_active ~= nil
                    ) and style.borderColor_active or style.borderColor;

                    dxDrawRoundedRectangle(
                        x, y, width, height, 
                        color, style.radius, 
                        false, style.border
                    );
                end 
            else 
                dxDrawRectangle(x, y, width, height, style.background);
            end 

            local text = self.value;
            local isPlaceholder = false;
            if (
                text == '' and
                (
                    not __SelectedTextarea or 
                    __SelectedTextarea ~= self.id
                )
            ) then 
                text = self.placeholder or '';
                isPlaceholder = true;
            else 
                if (self.masked) then 
                    text = string.rep("*", string.len(self.value));
                end 
                
                local textSuffix = (
                    __SelectedTextarea and 
                    __SelectedTextarea == self.id and
                    getTickCount() % 1000 <= 500
                ) and "|" or " ";

                text = text .. textSuffix;
            end 

            local textWidth = dxGetTextWidth(text, 1, self.font);
            local textHeight = dxGetFontHeight(1, self.font);
            local textLines = dxGetTextHeight(text, self.font, 1, (width - padding));
                        
            dxDrawText(
                text, 
                x + padding, y + padding, 
                x + (width - padding), y + (height - padding), 
                tocolor(255, 255, 255, isPlaceholder and 150 or 200), 1, self.font, 
                'left', (math.floor(height / textHeight) > textLines) and 'top' or 'bottom',
                true, true
            );

            self.__lastVisible = getTickCount();
            self.__position = Vector2(x, y);
            self.__size = Vector2(width, height);
        end

        self.destroy = function()
            if (
                __SelectedTextarea and
                __SelectedTextarea == self.id
            ) then 
                __SelectedTextarea = nil;
            end 

            if (__Textareas[self.id]) then
                __Textareas[self.id] = nil;
            end 

            for i, v in ipairs(__TextareaOrder) do 
                if (v == self.id) then 
                    table.remove(__TextareaOrder, i);
                end 
            end 

            self = nil;
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

        __Textareas[id] = self;
        table.insert(__TextareaOrder, id);

        return self;
    end 

    addEventHandler('onClientKey', root, function(key, isPress)
        if (isPress and __SelectedTextarea) then 
            if (key == 'backspace') then 
                if (not __Textareas[__SelectedTextarea]) then 
                    __SelectedTextarea = nil;
                    return;
                end 

                local box = __Textareas[__SelectedTextarea];

                if (box.disabled) then 
                    return;
                end 

                if (isTimer(box.backpaceTimer)) then 
                    return;
                end 

                box.value = box.value:sub(1, -2);
                box.__emitEvent('input');

                -- Kicsi callbackhell, hogy a szerverhez melto legyen!
                setTimer(function()
                    if (getKeyState('backspace') and not isTimer(box.backpaceTimer)) then 
                        box.backpaceTimer = setTimer(function()
                            if (
                                getKeyState('backspace') and 
                                box and 
                                isTimer(box.backpaceTimer) and 
                                box.value ~= '' and 
                                not box.disabled
                            ) then 
                                box.value = box.value:sub(1, -2);
                                box.__emitEvent('input');
                            else 
                                killTimer(box.backpaceTimer);
                            end 
                        end, 30, 0);
                    end 
                end, 500, 1);
            elseif (key == 'tab') then 
                local index = table.findIndex(__TextareaOrder, function(x) return (__SelectedTextarea == x); end);

                if (not index) then 
                    return;
                end 

                local nextIndex = ((index + 1) > #__TextareaOrder) and 1 or index + 1;
                local nextTextarea = table.find_keytbl(__Textareas, function(x) return (x.id == __TextareaOrder[nextIndex]); end);
                if (nextTextarea) then 
                    __SelectedTextarea = nextTextarea.id;
                end 
            end 
        end 
    end)

    addEventHandler('onClientCharacter', root, function(character)
        if (
            not __SelectedTextarea or 
            not isCursorShowing() or 
            isMTAWindowActive() or
            isConsoleActive()
        ) then 
            return; 
        end 

        if (not __Textareas[__SelectedTextarea]) then
            __SelectedTextarea = nil;
        end

        local box = __Textareas[__SelectedTextarea];

        if (
            box.disabled or 
            (not box.numbersAllowed and tonumber(character))
        ) then 
            return;
        end 

        -- aaaaaa miez
        local byte = string.byte(character);
        if (
            not box.specialsAllowed and 
            (
                not (
                    (byte >= 65 and byte <= 90) or 
                    (byte >= 97 and byte <= 122) or 
                    (byte >= 48 and byte <= 57)
                ) and not __IncludedCharacters[character]
            )
        ) then 
            return;
        end 

        if (isTimer(box.backpaceTimer)) then 
            return;
        end 

        box.value = box.value .. character;
        box.__emitEvent('input');
    end);

    addEventHandler('onClientPaste', root, function(text)
        if (__SelectedTextarea and __Textareas[__SelectedTextarea]) then 
            __Textareas[__SelectedTextarea].value = __Textareas[__SelectedTextarea].value .. text:gsub("\n", " ");
            __Textareas[__SelectedTextarea].__emitEvent('input');
        end 
    end);
]]