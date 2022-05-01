__outputChatBox = outputChatBox;
outputChatBox = function(message, player)
    __outputChatBox(message, player, 200, 200, 200, true);
end 

getPlayerName = function(player, exclude)
    if (not isElement(player)) then 
        return 'Ismeretlen';
    end 

    local characterName = (getElementData(player, 'name') or 'Ismeretlen'):gsub("_", " ");
    return characterName .. ((adminName and not exclude) and (' (' .. getPlayerAdminName(player) .. ')') or '');
end 

setPlayerName = function(p, name)
	return setElementData(p, "name", name:gsub(" ", "_")) or setPlayerName(p, name:gsub(" ", "_"));
end