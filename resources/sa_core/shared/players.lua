function findPlayer(identifier)
    if (identifier == nil) then 
        return nil;
    end 

    if (type(identifier) == 'string') then 
        identifier = string.lower(identifier);

        local foundPlayers = {};

        for _, player in ipairs(getElementsByType('player')) do 
            local playerName = (getElementData(player, 'name') or getPlayerName(player));

            if (playerName:lower():find(identifier)) then 
                table.insert(foundPlayers, player);
            end 
        end 

        return (#foundPlayers >= 2) 
                    and foundPlayers
                    or foundPlayers[1];
    elseif (type(identifier) == 'number') then 
        for _, player in ipairs(getElementsByType('player')) do 
            local playerId = getElementData(player, 'playerid');

            if (playerId and playerId == identifier) then 
                return player;
            end 
        end 
    end 

    return nil;
end 