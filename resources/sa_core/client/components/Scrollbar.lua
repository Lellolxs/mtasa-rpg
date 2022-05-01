Components['Scrollbar'] = [[
    local __Scrollbars = {};
    local __lastDraggedScrollbar = nil;

    local __DefaultScrollbarStyles = {
        default = {
            bgColor = tocolor(20, 20, 20),
            barColor = tocolor(128, 128, 128),
            barColorHover = tocolor(180, 180, 180),
            
            radius = nil, 

            padding = 2,
        },
    };

    local __DefaultScrollbarSettings = {
        style = 'default',

        __index = 1,
        __changeByScroll = nil,

        __click = {
            offset = Vector2(0, 0),
            index = 0, 
        },

        __lastVisible = 0,

        __lastPosition = nil, 
        __lastSize = nil,

        __lastGapHeight = 0,
        __lastTotal = 0, 
        __lastShown = 0, 
    };

    function Scrollbar(id, settings)
        if (not id) then return; end
        if (not settings) then settings = {}; end

        local self = table.merge(settings, __DefaultScrollbarSettings);

        self.id = id;

        self.render = function(x, y, width, height, shown, total)
            local style = (type(self.style) ~= 'table')
                            and (__DefaultScrollbarStyles[self.style] or __DefaultScrollbarStyles.default) 
                            or self.style;

            local visible_factor = math.min(shown / total, 1.0);
            visible_factor = math.max(visible_factor, 0.05);

            local bar_height = height * visible_factor;
            local position = math.min(self.__index / total, 1.0 - visible_factor) * height;

            self.__lastPosition = Vector2(x + style.padding, y + position + style.padding);
            self.__lastSize = Vector2(width - style.padding * 2, bar_height - style.padding * 2);

            local isBarHovered = (
                isCursorInArea(
                    self.__lastPosition, self.__lastSize
                ) or (__lastDraggedScrollbar and self.id == __lastDraggedScrollbar)
            );

            if (style.radius) then 
                if (not dxDrawRoundedRectangle) then 
                    outputDebugString("Requirezd mar a kurva \"Rectangle\" componentet is...", 1);
                    return;
                end 

                dxDrawRoundedRectangle(
                    x, y, width, height, 
                    tocolor(14, 14, 14, 255), 1.0
                );

                if (shown < total) then 
                    dxDrawRoundedRectangle(
                        self.__lastPosition.x, self.__lastPosition.y, 
                        self.__lastSize.x, self.__lastSize.y, 
                        isBarHovered and style.barColorHover or style.barColor, 1.0
                    );
                end 
            else 
                dxDrawRectangle(x, y, width, height, tocolor(14, 14, 14, 255));

                if (shown < total) then 
                    dxDrawRectangle(
                        self.__lastPosition.x, self.__lastPosition.y, 
                        self.__lastSize.x, self.__lastSize.y, 
                        isBarHovered and style.barColorHover or style.barColor
                    );
                end 
            end 

            self.__lastGapHeight = height / total;

            if (__lastDraggedScrollbar and __lastDraggedScrollbar == self.id) then 
                local cursorX, cursorY = getCursorPosition();

                local indexDiff = math.floor(
                    (
                        ((cursorY + self.click.offset) - y) - (self.click.height - y)
                    ) / self.__lastGapHeight
                );

                local newIndex = self.click.index + indexDiff;

                dxDrawText(newIndex .. ' - ' .. self.__lastGapHeight .. ' - ' .. y .. ' - ' .. cursorY .. ' - ' .. self.click.height .. ' - ' .. self.click.offset, cursorX + 20, cursorY, 
                            _, _, _, 1, 'arial', _, _, _, _, true);

                if (newIndex < 0) then newIndex = 0; end
                if (newIndex > (total - shown)) then newIndex = (total - shown); end 

                self.__index = newIndex;
            end 

            if (total ~= self.__lastTotal) then self.__lastTotal = total; end 
            if (total ~= self.__lastShown) then self.__lastShown = shown; end 
        end 

        self.destroy = function()
            if (__lastDraggedScrollbar and __lastDraggedScrollbar == self.id) then 
                __lastDraggedScrollbar = nil;
            end 

            if (__Scrollbars[self.id]) then 
                __Scrollbars[self.id] = nil;
            end 

            self = nil;
        end 

        __Scrollbars[id] = self;

        return self;
    end 

    addEventHandler('onClientClick', root, function(button, state)
        if (isCursorShowing() and button == 'left' and state == 'down') then 
            for id,v in pairs(__Scrollbars) do 
                if (isCursorInArea(v.__lastPosition, v.__lastSize)) then 
                    local cursorX, cursorY = getCursorPosition();

                    __lastDraggedScrollbar = id;
                    v.click = {
                        height = v.__lastPosition.y, 
                        offset = v.__lastPosition.y - cursorY,
                        index = v.__index
                    };
                end 
            end 
        elseif (button == 'left' and state == 'up' and __lastDraggedScrollbar) then 
            local box = __Scrollbars[__lastDraggedScrollbar];
        
            if (box) then 
                box.click = { height = Vector2(0, 0), index = 0 };
            end 

            __lastDraggedScrollbar = nil;
        end 
    end)

    function __onScroll(key)
        for id,v in pairs(__Scrollbars) do 
            local newIndex = v.__index;

            if (key == 'mouse_wheel_up' and v.__index > 0) then 
                newIndex = v.__index - ((not v.__changeByScroll) and v.__lastShown or v.__changeByScroll);
            elseif (key == 'mouse_wheel_down' and v.__index < v.__lastTotal - v.__lastShown) then 
                newIndex = v.__index + ((not v.__changeByScroll) and v.__lastShown or v.__changeByScroll);
            end 

            if (newIndex < 0) then 
                newIndex = 0;
            elseif (newIndex > v.__lastTotal - v.__lastShown) then 
                newIndex = v.__lastTotal - v.__lastShown;
            end 

            v.__index = newIndex;
        end 
    end 
    bindKey('mouse_wheel_up', 'down', __onScroll);
    bindKey('mouse_wheel_down', 'down', __onScroll);
]];