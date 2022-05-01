function getPlayerLevel(player)
    if (
        not isElement(player) or 
        getElementType(player) ~= 'player'
    ) then 
        return false;
    end 

    local playTime = getElementData(player, 'playtime');
    if (not playTime) then
        return false;
    end 

    return (math.ceil(playTime * 0.25 / 60) + 1);
end 