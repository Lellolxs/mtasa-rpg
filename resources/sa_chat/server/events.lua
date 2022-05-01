addEventHandler('onPlayerChat', root, function(message, messageType)
    cancelEvent(); 

    if (messageType == 0) then 
        elementSendMessage(source, message, 'normal');
    end 
end);

addEvent('onPlayerOOCMessage', true);
addEventHandler('onPlayerOOCMessage', resourceRoot, function(message)
    local player = client;

    if (not getElementData(player, 'loggedIn')) then 
        return;
    end 

    local x, y, z = getElementPosition(player);
    local int, dim = getElementInterior(player), getElementDimension(player);

    local players = table.filter(getElementsByType('player'), function(plr)
        local pX, pY, pZ = getElementPosition(plr);
        if (
            getDistanceBetweenPoints3D(x, y, z, pX, pY, pZ) < MessageTypes.ooc.distance and 
            int == getElementInterior(plr) and 
            dim == getElementDimension(plr)
        ) then 
            return true;
        end 

        return false;
    end);

    triggerClientEvent(players, "addOOCMessage", resourceRoot, player, message);
end);

addEvent('onPlayerEnterMe', true);
addEventHandler('onPlayerEnterMe', resourceRoot, function(message)
    local player = client;

    if (not getElementData(player, 'loggedIn')) then 
        return;
    end 

    elementSendMe(player, message);
end);

addEvent('onPlayerEnterDo', true);
addEventHandler('onPlayerEnterDo', resourceRoot, function(message)
    local player = client;

    if (not getElementData(player, 'loggedIn')) then 
        return;
    end 

    elementSendDo(player, message);
end);