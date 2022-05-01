Core = exports.sa_core;
Admin = exports.sa_admin;

loadstring(Core:require({ }))();

Toggled = false;
StreamedElements = {};
ElementOrder = {};
ShowSelf = exports.sa_dashboard:getSettingValue('nametag', 'show_self');

local Font = Core:requireFont('opensans-bold', 14);
local MaxLimit = 25;
local StrokeSides = 4;
local StrokeStrength = 1;

function rootRender()
    if (Toggled) then 
        return;
    end 

    local tick = getTickCount();
    local plrX, plrY, plrZ = getElementPosition(localPlayer);
    local plrDim = getElementDimension(localPlayer);
    local plrInt = getElementInterior(localPlayer);
    local plrVehicle = getPedOccupiedVehicle(localPlayer);
    local camX, camY, camZ = getCameraMatrix();

    for index, element in ipairs(ElementOrder) do 
        local eX, eY, eZ = getElementPosition(element);
        local eDim = getElementDimension(element);
        local eInt = getElementInterior(element);
        local eVehicle = getPedOccupiedVehicle(element);
        local dist = getDistanceBetweenPoints3D(plrX, plrY, plrZ, eX, eY, eZ);
        local hit = processLineOfSight(
            camX, camY, camZ, eX, eY, eZ, 
            true, false, false, true, true, 
            false
        );

        if (
            (element ~= localPlayer or ShowSelf) and 
            StreamedElements[element] and 
            index <= MaxLimit and 
            dist <= 15 and 
            plrDim == eDim and plrInt == eInt and 
            (
                not hit or 
                element == localPlayer
            ) 
        ) then 
            local v = StreamedElements[element];
            local bX, bY, bZ = getPedBonePosition(element, 8);

            local sx, sy = getScreenFromWorldPosition(bX, bY, bZ + 0.33);
            if (sx and sy) then 
                dxDrawStrokedText(
                    v.name .. " " .. v.label, sx, sy, 
                    nil, nil, StrokeStrength, StrokeSides, 
                    tocolor(255, 255, 255), 1, Font, 
                    'center', 'center', 
                    false, false, false, true
                );
            end 
        end 
    end 
end 

local forceRecacheKeys = {
    ['name'] = true, 
    ['admin'] = true, 
    ['playerid'] = true,
    ['label'] = true,
};

function cacheElement(element)
    if (not isElement(element)) then 
        return false;
    end 

    local elementType = getElementType(element);
    local data = {};

    if (elementType == 'player') then
        local inDuty = Admin:isAdminInDuty(element);

        data.name = inDuty
            and Admin:getPlayerAdminName(element) 
            or (getElementData(element, 'name') or "Ismeretlen"):gsub("_", " ");

        data.label = "#ffffff(" .. (getElementData(element, 'playerid') or -1) .. ")";
        if (inDuty) then 
            data.label = Admin:getPlayerAdminColor(element) .. "(" .. Admin:getPlayerAdminTitle(element) .. ") " .. data.label;
        end  

        setPlayerNametagShowing(element, false);
    else 
        data.name = (getElementData(element, "name") or "NPC");
        data.label = (Core:getColor('server').hex .. "[" .. (getElementData(element, "label") or "NPC") .. "]");
    end 

    table.insert(ElementOrder, element);
    StreamedElements[element] = data;
    return true;
end 

function reorderElementsNames()
    if (#ElementOrder < MaxLimit) then 
        return false;
    end 

    local order = table.copy(ElementOrder);
    local x, y, z = getElementPosition(localPlayer);

    table.sort(order, function(a, b)
        if (a == localPlayer or not isElement(b)) then return true; end
        if (b == localPlayer or not isElement(a)) then return false; end

        local aX, aY, aZ = getElementPosition(a);
        local aDist = getDistanceBetweenPoints3D(x, y, z, aX, aY, aZ);

        local bX, bY, bZ = getElementPosition(b);
        local bDist = getDistanceBetweenPoints3D(x, y, z, bX, bY, bZ);

        return (aDist < bDist);
    end);

    ElementOrder = order;
end 

function toggle(toggle, forced)
    if (toggle and not forced) then 
        return;
    end 

    Toggled = not toggle;
end 

function setSelfDrawing(state)
    iprint('owo name', state);
    ShowSelf = state;
end 

function dxDrawStrokedText(text, x, y, width, height, stroke, sides, color, ...)
    local width = (width or x);
    local height = (height or y);
    
    local escaped = text:gsub("#%x%x%x%x%x%x", "");
    
    for i = 1, sides do 
        local angle = i * math.pi / 180 * (360 / sides);
        local textX, textY = x + stroke * math.cos(angle), y + stroke * math.sin(angle);
        dxDrawText(escaped, textX, textY, _, _, tocolor(0, 0, 0), ...);
    end 
    
    dxDrawText(text, x, y, width, height, color, ...);
end 

addEventHandler('onClientElementDataChange', root, function(key)
    if (StreamedElements[source] and forceRecacheKeys[key]) then 
        cacheElement(source);
    end 
end);

local couldHaveNameElementTypes = { player = true, ped = true };
addEventHandler('onClientElementStreamIn', root, function()
    local elementType = getElementType(source);
    if (couldHaveNameElementTypes[elementType]) then 
        cacheElement(source);
    end 
end);

addEventHandler('onClientElementStreamOut', root, function()
    local element = source;

    if (StreamedElements[element]) then 
        StreamedElements[element] = nil;
        ElementOrder = table.filter(ElementOrder, function(x) return (x ~= element) end);
    end 
end);

addEventHandler('onClientElementDestroy', root, function()
    local element = source;

    if (StreamedElements[element]) then 
        StreamedElements[element] = nil;
        ElementOrder = table.filter(ElementOrder, function(x) return (x ~= element) end);
    end 
end);

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('onClientRender', root, rootRender);

    table.foreach(getElementsByType('player', _, true), function(_, player)
        cacheElement(player);
    end);

    table.foreach(getElementsByType('ped', _, true), function(_, player)
        cacheElement(player);
    end);

    setTimer(reorderElementsNames, 1000, 0);
end);

addEventHandler("onClientSettingsChange", resourceRoot, function(key, old, new)
    if (key == 'limit') then 
        MaxLimit = new;
    end
end);