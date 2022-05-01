Core = exports.sa_core;
loadstring(Core:require({ "Rectangle" }))();

local __Switches = {};
local __SwitchAnimInterval = 400;
local __SwitchVisibilityDiff = 250;

local __DefaultSwitchStyles = {
    default = {
        bgColor = { 20, 20, 20 },
        thumbColor_false = { 48, 48, 48 },
        thumbColor_true = { 49, 158, 50 },

        padding = 6,
        radius = 1.0, 
    },
};

local __DefaultSwitchSettings = {
    value = true, 
    style = 'default', 
    __last_change = getTickCount(),
};

function Switch(id, settings)
    local settings = (settings or {});
    local self = table.merge(settings, __DefaultSwitchSettings);

    self.id = id;
    self.__events = {};

    self.render = function(x, y, width, height, alpha)
        local tick = getTickCount();

        local style = (type(self.style) ~= 'table')
                        and (__DefaultSwitchStyles[self.style] or __DefaultSwitchStyles.default) 
                        or self.style;
        
        local bgColor = style.bgColor;
        bgColor[4] = alpha;

        if (style.radius ~= nil) then 
            if (not dxDrawRoundedRectangle) then 
                outputDebugString("Requirezd mar a kurva \"Rectangle\" componentet is...", 1);
                return;
            end 

            dxDrawRoundedRectangle(
                x, y, width, height, 
                tocolor(unpack(bgColor)), 
                style.radius
            );
        else 
            dxDrawRectangle(
                x, y, 
                width, height, 
                tocolor(unpack(bgColor))
            );
        end 

        local thumbSize = (width > height) and (height - style.padding) or (width - style.padding);
        local btnX, btnY = interpolateBetween(
            (self.value and (x + style.padding / 2) or (x + width - thumbSize - style.padding / 2)), 0, 0,
            (self.value and (x + width - thumbSize - style.padding / 2) or (x + style.padding / 2)), 0, 0,
            (tick - self.__last_change) / __SwitchAnimInterval, "InOutQuad"
        ), (y + height / 2) - (thumbSize / 2);


        local thumbColor = {interpolateBetween(
            style['thumbColor_' .. tostring(not self.value)][1], style['thumbColor_' .. tostring(not self.value)][2], style['thumbColor_' .. tostring(not self.value)][3], 
            style['thumbColor_' .. tostring(self.value)][1], style['thumbColor_' .. tostring(self.value)][2], style['thumbColor_' .. tostring(self.value)][3],
            (tick - self.__last_change) / __SwitchAnimInterval, "InOutQuad"
        )};
        thumbColor[4] = alpha;
        if (style.radius ~= nil) then 
            if (not dxDrawRoundedRectangle) then 
                outputDebugString("Requirezd mar a kurva \"Rectangle\" componentet is...", 1);
                return;
            end 

            dxDrawRoundedRectangle(
                btnX, btnY, thumbSize, thumbSize, 
                tocolor(unpack(thumbColor)), 
                style.radius
            );
        else 
            dxDrawRectangle(
                btnX, btnY, 
                thumbSize, thumbSize, 
                tocolor(unpack(thumbColor))
            );
        end 

        self.__position = Vector2(x, y);
        self.__size = Vector2(width, height);
        self.__lastVisible = tick;
    end

    self.__emitEvent = function(event, ...)
        if (event and self.__events[event]) then 
            for _, handler in ipairs(self.__events[event]) do 
                handler(self, ...);
            end 
        end 
    end 

    self.on = function(event, handler)
        if (not event or not handler) then return; end 

        if (not self.__events[event]) then 
            self.__events[event] = {};
        end 

        table.insert(self.__events[event], handler);
    end 

    __Switches[id] = self;
    return self;
end 

addEventHandler('onClientClick', root, function(button, state)
    if (button ~= 'left' and state ~= 'down') then 
        return;
    end 

    local tick = getTickCount();
    local cursorX, cursorY = getCursorPosition();
    for id, v in pairs(__Switches) do 
        if (
            isCursorInArea(v.__position.x, v.__position.y, v.__size.x, v.__size.y) and 
            v.__last_change + __SwitchAnimInterval < tick and -- nem kattintgatja kurvagyorsan
            tick < v.__lastVisible + __SwitchVisibilityDiff -- latszodik egyaltalan
        ) then 
            v.__last_change = tick;
            v.value = not v.value;
            v.__emitEvent('input');
        end 
    end 
end);

local test = Switch('fasz', { });

iprint(test);

addEventHandler('onClientRender', root, function()
    test.render(500, 500, 40, 24, 255);
end);