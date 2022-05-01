Core = exports.sa_core;
loadstring(Core:require({ "Rectangle" }))();

local __Selects = {};
local __SelectAnimInterval = 400;
local __SelectVisibilityDiff = 250;

local __DefaultSelectStyles = {
    default = {
        bgColor = { 20, 20, 20 },
        thumbColor_false = { 48, 48, 48 },
        thumbColor_true = { 49, 158, 50 },

        padding = 6,
        radius = 1.0, 
    },
};

local __DefaultSelectSettings = {
    value = false,
    options = {},
    style = 'default', 

    __last_change = getTickCount(),
    __events = {},
};

function Select(id, settings)
    local settings = (settings or {});
    local self = table.merge(settings, __DefaultSelectSettings);

    self.id = id;
    self.rt = nil;

    self.render = function(x, y, width, height, listHeight)
        dxDrawRoundedRectangle(x, y, width, height, tocolor(24, 24, 24), 0.5);

        dxDrawRoundedRectangle(x, y + height, width, listHeight, tocolor(24, 24, 24), 0.1);

        for i,v in ipairs(self.options) do 
            local textY = y + height + (i * 36);

            dxDrawText(
                v, x, textY, _, 
                ((textY + 24) < (y + height + listHeight)) and (textY + 24) or (y + height + listHeight), 
                tocolor(200, 200, 200), 1, "arial", "left", "center", true, true
            );
        end 
    end 

    self.updateRT = function()

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

    __Selects[id] = self;
    return self;
end 

local test = Select("geci", { options = { "Kurva", "Anyadat", "Te", "Agyhalott", "Cigany" }, });

addEventHandler('onClientRender', root, function()
    test.render(500, 500, 150, 38, 100);
end);