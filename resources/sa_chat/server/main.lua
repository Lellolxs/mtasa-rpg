Core = exports.sa_core;

loadstring(Core:require({ }))();

MessageTypes = {
    shouting = { distance = 25, prefix = 'ordítja' }, 
    normal = { distance = 8, prefix = 'mondja' },
    whispering = { distance = 2, prefix = 'suttogja' }, 
    ooc = { distance = 25 },

    action = { distance = 8 }, -- /me
    incidence = { distance = 8 }, -- /do
};

function elementSendMessage(element, message, type)
    local type = (type or 'normal');

    if (
        not isElement(element) or 
        not MessageTypes[type]
    ) then 
        return false;
    end 

    local x, y, z = getElementPosition(element);
    local name = (getElementType(element) == 'player')
                    and (getElementData(element, 'name') or 'Ismeretlen'):gsub("_", " ")
                    or (getElementData(element, 'name') and "Ismeretlen");

    for _, player in ipairs(getElementsByType('player')) do 
        local pX, pY, pZ = getElementPosition(player);
        local distance = getDistanceBetweenPoints3D(x, y, z, pX, pY, pZ);

        if (distance < MessageTypes[type].distance) then 
            local r, g, b = interpolateBetween(
                255, 255, 255, 
                50, 50, 50, 
                distance / MessageTypes[type].distance, 
                "Linear"
            );

            outputChatBox(
                name .. " " .. MessageTypes[type].prefix .. ": " .. message, 
                player, r, g, b, true
            );
        end 
    end 

    return true;
end

function elementSendMe(element, message)
    if (not isElement(element)) then 
        return false;
    end 

    local x, y, z = getElementPosition(element);
    local name = (getElementType(element) == 'player')
                    and (getElementData(element, 'name') or 'Ismeretlen'):gsub("_", " ")
                    or (getElementData(element, 'name') and "Ismeretlen");
    
    for _, player in ipairs(getElementsByType('player')) do 
        local pX, pY, pZ = getElementPosition(player);
        local distance = getDistanceBetweenPoints3D(x, y, z, pX, pY, pZ);
                
        if (distance < MessageTypes.action.distance) then 
            outputChatBox(
                "*** " .. name .. " " .. message,
                player, 194, 162, 218, true
            );
        end 
    end 
end 

function elementSendDo(element, message)
    if (not isElement(element)) then 
        return false;
    end 

    local x, y, z = getElementPosition(element);
    local name = (getElementType(element) == 'player')
                    and (getElementData(element, 'name') or 'Ismeretlen'):gsub("_", " ")
                    or (getElementData(element, 'name') and "Ismeretlen");
    
    for _, player in ipairs(getElementsByType('player')) do 
        local pX, pY, pZ = getElementPosition(player);
        local distance = getDistanceBetweenPoints3D(x, y, z, pX, pY, pZ);
                
        if (distance < MessageTypes.incidence.distance) then 
            outputChatBox(
                "* " .. message .. " ((" .. name .. "))",
                player, 255, 40, 80, true
            );
        end 
    end 
end 