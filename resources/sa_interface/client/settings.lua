-- local x, y = ScreenWidth / 2 - width / 2, ScreenHeight / 2 - height / 2;

local elementLabel;
local uiCache;

local MaxHeight = 425 * getResp();
local WidthPerColumn = 250 * getResp();

local TotalColumns;
local TotalWidth;
local TotalHeight;

local Settings = {
    windowPadding = Vector2(8.0 * getResp(), 8.0 * getResp()),
    elementPadding = Vector2(12.0 * getResp(), 8.0 * getResp()), 
    paddingFromTop = 24 * getResp(),
};

local Components = {
    header = { height = 24, component_construtor = nil },
    switch = { height = 22 * getResp(), component_construtor = Switch },
};

local function rootRender()
    local x, y = ScreenWidth / 2 - TotalWidth / 2, ScreenHeight / 2 - TotalHeight / 2 - Settings.paddingFromTop / 2;

    dxDrawRectangle(
        x - Settings.windowPadding.x, 
        y - Settings.windowPadding.y, 
        TotalWidth + Settings.windowPadding.x * 2, 
        TotalHeight + Settings.windowPadding.y * 2, 
        tocolor(22, 22, 22, 255)
    );

    dxDrawText(
        elementLabel .. " beállításai", 
        x, y, TotalWidth, Settings.paddingFromTop * 0.75, 
        tocolor(200, 200, 200), 
        12, "opensans-bold", 
        "left", "center"
    );

    for i,v in ipairs(uiCache) do
        dxDrawRectangle(
            v.pos.x, v.pos.y, v.size.x, v.size.y, 
            (v.type ~= "header") and tocolor(32, 32, 32, 255) or tocolor(26, 26, 26, 255)
        );
        
        if (v.type == "header") then 
            dxDrawText("- " .. v.label, v.pos.x, v.pos.y, v.size.x, v.size.y, tocolor(200, 200, 200), 12, "opensans", "left", "center");
        elseif (v.type == "switch") then 
            dxDrawText(v.label, v.pos.x + v.size.x * 0.025, v.pos.y, v.size.x * 0.5, v.size.y, tocolor(200, 200, 200), 12, "opensans", "left", "center");

            if (v.__elem ~= nil) then 
                v.__elem.render(v.pos.x + v.size.x * 0.85, v.pos.y, v.size.x * 0.15, v.size.y);
            end 
        end 
    end 
end 

local function onCloseKey(key, press)
    if (press and key == "escape" or key == "backspace") then 
        cancelEvent();
        toggleElementSettings(false);
        EditElementSettings = nil;
    end 
end 

function toggleElementSettings(state, element)
    if (state and not uiCache) then 
        elementLabel = element.label;
        uiCache = {};
    
        local totalHeight = table.reduce(element.options, function(total, x, i)
            return (total + Components[x.type].height + ((i == #element.options) and 0 or Settings.elementPadding.y));
        end);

        TotalColumns = math.ceil(totalHeight / MaxHeight);
        TotalWidth = TotalColumns * WidthPerColumn + ((TotalColumns - 1) * Settings.elementPadding.x);
        TotalHeight = ((totalHeight > MaxHeight) and MaxHeight or totalHeight);

        local x, y = ScreenWidth / 2 - TotalWidth / 2, ScreenHeight / 2 - TotalHeight / 2;

        local column = 0;
        local height = 0;
        for i,v in ipairs(element.options) do 
            if (height + Components[v.type].height > TotalHeight) then 
                column = column + 1;
                height = 0;
            end 

            local ui = table.copy(v);
            ui.pos = Vector2(x + column * WidthPerColumn + ((column ~= 0) and (column * Settings.elementPadding.x) or 0), y + height);
            ui.size = Vector2(WidthPerColumn, Components[v.type].height);

            if (Components[v.type] and Components[v.type].component_construtor ~= nil) then 
                ui.__elem = Components[v.type].component_construtor(v.id);
                ui.__elem.value = v.value;
                ui.__elem.on('input', function(self_obj, ...)
                    v.value = self_obj.value;
                    self_obj = table.filter_keytbl(self_obj, function(v, k) return (string.sub(k, 1, 1) ~= "_"); end);
                    triggerEvent('onInterfaceElementSettingChange', Elements[EditElementSettings].sourceResourceRoot, EditElementSettings, self_obj, ...);
                end);
            end 

            table.insert(uiCache, ui);

            local includePadding = (i ~= #element.options);
            height = height + Components[v.type].height + (includePadding and Settings.elementPadding.y or 0);
        end 

        addEventHandler('onClientRender', root, rootRender);
        addEventHandler('onClientKey', root, onCloseKey);

        TotalHeight = TotalHeight + Settings.paddingFromTop;
    elseif (not state and uiCache) then 
        removeEventHandler('onClientKey', root, onCloseKey);
        removeEventHandler('onClientRender', root, rootRender);
        uiCache = nil;
    end 
end 

function clamp(num, min, max)
    if (num < min) then return min; end 
    if (num > max) then return max; end 
    
    return num;
end 

addEvent("onInterfaceElementSettingChange", false);