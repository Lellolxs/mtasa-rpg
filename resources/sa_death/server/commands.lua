addEvent("onPlayerEmitCommand:revive", false);
addEventHandler('onPlayerEmitCommand:revive', root, function(player, targetPlayer)
    local death = getElementData(targetPlayer, 'death');
    if (not death) then 
        return outputChatBox(Core:getServerPrefix("error") .. " " .. getPlayerName(targetPlayer) .. " nincs meghalva.", player, 255, 255, 255, true);
    end

    Admin:addAdminLog({ admin = player, player = targetPlayer, action = 'revive' });
    Admin:outputToAdmins(Admin:getPlayerAdminName(player) .. " felkaparta " .. getPlayerName(targetPlayer) .. " játékost.", 3, true);
    respawnPlayer(targetPlayer, true);
end);
Admin:Command('revive',{required={admin=3},args={{type="player"}},alias={"felkapar","asegit"}})

getPlayerName = function(player, exclude)
    if (not isElement(player)) then 
        return 'Ismeretlen';
    end 

    local characterName = (getElementData(player, 'name') or 'Ismeretlen'):gsub("_", " ");
    local adminName = Admin:getPlayerAdminName(player);

    return characterName .. ((adminName and not exclude) and (' (' .. adminName .. ')') or '');
end 