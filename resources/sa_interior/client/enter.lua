local width, height = 290, 65;
local x, y = ScreenWidth / 2 - width / 2, ScreenHeight * 0.9 - height / 2;

local function render()
    if (not Interior) then 
        return false;
    end 

    local name = Interior.name .. ' (' .. Interior.id .. ')';
    local color = (Interior.locked and tocolor(255, 50, 50) or tocolor(50, 255, 50));

    dxDrawRectangle(x, y, width, height, tocolor(32, 32, 32));
    dxDrawText(name, x + 64, y + height / 2 + 2, _, _, _, 1, Fonts.robotomd, 'left', 'bottom');
    dxDrawText((InteriorIcons[Interior.category] or ''), x + 32, y + height / 2, _, _, _, 1, Fonts.falg, 'center', 'center');
    dxDrawRectangle(x, y + height - 1, width, 2, color);

    -- Lakat
    dxDrawText('K gomb a ' .. (true and 'kinyitáshoz' or 'bezáráshoz') .. ', E a belépéshez.', x + 64, y + height / 2 + 2, 
    _, _, tocolor(255, 255, 255), 1, Fonts.robotosm, 'left', 'top');
end 

addEventHandler(
    'onClientColShapeHit', 
    root, 
    function(element, sameDimension)
        if (element ~= localPlayer) then return; end

        if (element == localPlayer and sameDimension and getElementData(source, 'isInterior')) then 
            triggerServerEvent('sInterior:fetchInterior', root, getElementData(source, 'id'));
            
            bindKey('k', 'down', onLockBind);
            bindKey('e', 'down', onEnterBind);
            addEventHandler('onClientRender', root, render);
        end 
    end
);

addEventHandler(
    'onClientColShapeLeave', 
    root,
    function(element, sameDimension)
        if (element == localPlayer and sameDimension and Interior) then 
            unbindKey('k', 'down', onLockBind);
            unbindKey('e', 'down', onEnterBind);
            removeEventHandler('onClientRender', root, render);
        end 
    end
);

addEvent('sInterior:clientUpdateInterior', true);
addEventHandler(
    'sInterior:clientUpdateInterior', 
    root, 
    function(interior)
        Interior = interior;

        if (interior == nil) then 
            unbindKey('k', 'down', onLockBind);
            unbindKey('e', 'down', onEnterBind);
            removeEventHandler('onClientRender', root, render);
        end 
    end
);
