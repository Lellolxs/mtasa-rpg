Components['Editbox'] = [[
    -- Nem nyulkapiszka mert eltorom a kezed [(a jó kurva anyádat :D) szkiddaj genyo]
    __Editboxes = {};
    __EditboxOrder = {};
    __SelectedEditbox = nil; 
    __visibilityDiff = 200; -- ms
    __substrFromLength = 128;

    -- Itt nyulkapiszkazhatszmar
    local __DefaultEditboxStyles = {
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

    local __DefaultEditboxSettings = {
        masked = false,
        disabled = false,
        value = '',
        style = 'default',
        font = exports.sa_core:requireFont('opensans-bold', 11),

        numbersAllowed = true, 
        specialsAllowed = false,

        __position = nil, 
        __size = nil, 
        __lastVisible = 0,
        __events = {},
    };

    local __IncludedCharacters = {
        [' '] = true,
    };

    function Editbox(id, settings) 
        if (not id) then return; end
        if (not settings) then settings = {}; end

        local self = table.merge(settings, __DefaultEditboxSettings);

        self.id = id;
        self.style = (type(self.style) ~= 'table')
                        and (__DefaultEditboxStyles[self.style] or __DefaultEditboxStyles.default) 
                        or table.merge(self.style, __DefaultEditboxStyles.default);

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
                        __SelectedEditbox and 
                        __SelectedEditbox == self.id and 
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
                    not __SelectedEditbox or 
                    __SelectedEditbox ~= self.id
                )
            ) then 
                text = self.placeholder or '';
                isPlaceholder = true;
            else 
                if (self.masked) then 
                    text = string.rep("*", string.len(self.value));
                end 
                
                local textSuffix = (
                    __SelectedEditbox and 
                    __SelectedEditbox == self.id and
                    getTickCount() % 1000 <= 500
                ) and "|" or " ";

                text = text .. textSuffix;
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
                tocolor(255, 255, 255, isPlaceholder and 150 or 200), 1, self.font, 
                (textWidth >= (width - padding * 2)) and 'right' or style.align, 'center', 
                true, false
            );

            self.__lastVisible = getTickCount();
            self.__position = Vector2(x, y);
            self.__size = Vector2(width, height);
        end

        self.destroy = function()
            if (
                __SelectedEditbox and
                __SelectedEditbox == self.id
            ) then 
                __SelectedEditbox = nil;
            end 

            if (__Editboxes[self.id]) then
                __Editboxes[self.id] = nil;
            end 

            for i, v in ipairs(__EditboxOrder) do 
                if (v == self.id) then 
                    table.remove(__EditboxOrder, i);
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

        __Editboxes[id] = self;
        table.insert(__EditboxOrder, id);

        return self;
    end 

    -- addEventHandler('onClientClick', root, function(button, state)
    --     if (not isCursorShowing() or button ~= 'left' or state ~= 'down') then return; end

    --     local tick = getTickCount();

    --     for id, v in pairs(__Editboxes) do 
    --         if (
    --             v.__lastVisible and 
    --             (v.__lastVisible + __visibilityDiff) > tick and 
    --             (v.__position ~= nil and v.__size ~= nil) and 
    --             isCursorInArea(v.__position, v.__size) and 
    --             (guiGetInputMode() or 'allow_binds') == 'allow_binds'
    --         ) then
    --             __SelectedEditbox = id;
    --             guiSetInputMode("no_binds");
    --             v.__emitEvent('focus');
    --             return;
    --         end 
    --     end 

    --     guiSetInputMode("allow_binds");
    --     __SelectedEditbox = nil;
    -- end);

    addEventHandler('onClientKey', root, function(key, isPress)
        if (isPress and __SelectedEditbox) then 
            if (key == 'backspace') then 
                if (not __Editboxes[__SelectedEditbox]) then 
                    __SelectedEditbox = nil;
                    return;
                end 

                local box = __Editboxes[__SelectedEditbox];

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
                local index = table.findIndex(__EditboxOrder, function(x) return (__SelectedEditbox == x); end);

                if (not index) then 
                    return;
                end 

                local nextIndex = ((index + 1) > #__EditboxOrder) and 1 or index + 1;
                local nextEditbox = table.find_keytbl(__Editboxes, function(x) return (x.id == __EditboxOrder[nextIndex]); end);
                if (nextEditbox) then 
                    __SelectedEditbox = nextEditbox.id;
                    nextEditbox.__emitEvent('focus');
                end 
            end 
        end 
    end)

    addEventHandler('onClientCharacter', root, function(character)
        if (
            not __SelectedEditbox or 
            not isCursorShowing() or 
            isMTAWindowActive() or
            isConsoleActive()
        ) then 
            return; 
        end 

        if (not __Editboxes[__SelectedEditbox]) then
            __SelectedEditbox = nil;
        end

        local box = __Editboxes[__SelectedEditbox];

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
        if (
            not __SelectedEditbox or 
            not __Editboxes[__SelectedEditbox]
        ) then 
            return;
        end
            
        local editbox = __Editboxes[__SelectedEditbox];

        if (__SelectedEditbox and __Editboxes[__SelectedEditbox]) then 
            editbox.value = editbox.value .. text:gsub("\n", " ");
            editbox.__emitEvent('input');
        end 
    end);
]]