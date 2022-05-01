Players = {};

addEventHandler('onPlayerJoin', root, function()
    for i = 1, 8192 do 
        if (Players[i] == nil) then 
            Players[i] = source;
            setElementData(source, "playerid", i);
            setElementID(source, "player:" .. i);

            break;
        end 
    end 
end);

addEventHandler('onPlayerQuit', root, function()
    local playerId = getElementData(source, 'playerid');

    if (playerId) then 
        Players[playerId] = nil;
    end 
end);

addEventHandler('onResourceStart', resourceRoot, function()
    local id = 1;
    for _, player in ipairs(getElementsByType('player')) do 
        Players[id] = player;
        setElementData(player, "playerid", id);
        setElementID(player, "player:" .. id);

        id = id + 1;
    end 
end);