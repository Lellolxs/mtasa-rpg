-- 
-- Teleport
-- 

local TeleportNames, Teleports = {}, {
    ['varoshaza'] = { name = 'Városháza', position = Vector3(0.0, 0.0, 3.0), interior = 0, dimension = 0 },
    ['fcpd'] = { name = 'Fort Carson Police Department', position = Vector3(-213.2646484375, 978.2919921875, 19.32963180542), interior = 0, dimension = 0 },
}; for id, _ in pairs(Teleports) do table.insert(TeleportNames, id); end 

function teleportPlayerToPlace(player, targetPlayer, placeId)
    local place = Teleports[placeId];
    if (not place) then 
        return outputChatBox(Core:getServerPrefix('error', 'Admin') .. "Nincs ilyen teleport tesom.", player);
    end 

    setElementPosition(targetPlayer, place.position);
    if (place.interior) then setElementInterior(targetPlayer, place.interior); end
    if (place.dimension) then setElementDimension(targetPlayer, place.dimension); end

	outputChatBox(Core:getServerPrefix('server', 'Admin') .. getPlayerAdminName(player, true) .." elteleportált téged ide: " .. (place.name or placeId), targetPlayer);
    outputToAdmins(getPlayerAdminName(player, true) .. ' elteleportálta ' .. getPlayerName(targetPlayer) .. ' ide: ' .. (place.name or placeId), 1);
    addAdminLog({ admin = player, player = targetPlayer, action = 'tpto_' .. placeId });
end
Command('tpto', { required = { admin = 3 }, args = { { type = 'player' }, { type = 'string', name = "Hely (" .. table.concat(TeleportNames, ", ") .. ")" } } }, teleportPlayerToPlace);

function gotoPlayer(player, targetPlayer)
    if (player == targetPlayer) then 
        return outputChatBox(Core:getServerPrefix('error', 'Admin') .. "Miért akarnál magadra teleportálni?", player);
    end 

    local x, y, z = getElementPosition(targetPlayer);
    local int, dim = getElementInterior(targetPlayer), getElementDimension(targetPlayer);

    setElementPosition(player, x, y, z);
    setElementInterior(player, int); 
    setElementDimension(player, dim); 

    outputChatBox(Core:getServerPrefix('server', 'Admin') .. getPlayerAdminName(player, true) .." hozzád teleportált.", targetPlayer);
    outputToAdmins(getPlayerAdminName(player, true) .. ' ' .. getPlayerName(targetPlayer) .. ' játékoshoz teleportált.', 1);
    addAdminLog({ admin = player, player = targetPlayer, action = 'goto' });
end
Command('goto', { required = { admin = 3, off_admin = 8 }, args = { { type = 'player' } } }, gotoPlayer);

function gotoPlayerSilent(player, targetPlayer)
    if (player == targetPlayer) then 
        return outputChatBox(Core:getServerPrefix('error', 'Admin') .. "Miért akarnál magadra teleportálni?", player);
    end 

    local x, y, z = getElementPosition(targetPlayer);
    local int, dim = getElementInterior(targetPlayer), getElementDimension(targetPlayer);

    setElementPosition(player, x, y, z);
    setElementInterior(player, int); 
    setElementDimension(player, dim); 

    outputToAdmins(getPlayerAdminName(player, true) .. ' ' .. getPlayerName(targetPlayer) .. ' játékoshoz teleportált.', 6);
    addAdminLog({ admin = player, player = targetPlayer, action = 'gotos' });
end
Command('sgoto', { description = "Anélkül teleporttál rá valakire hogy kiírná a személynek vagy főadmin alatti adminoknak.", required = { admin = 8 }, args = { { type = 'player' } } }, gotoPlayerSilent);

function getHerePlayer(player, targetPlayer)
    if (player == targetPlayer) then 
        return outputChatBox(Core:getServerPrefix('error', 'Admin') .. "Miért akarnád magadat saját magadhoz teleportálni?", player);
    end 

    local x, y, z = getElementPosition(player);
    local int, dim = getElementInterior(player), getElementDimension(player);

    setElementPosition(targetPlayer, x, y, z);
    setElementInterior(targetPlayer, int); 
    setElementDimension(targetPlayer, dim); 

    outputChatBox(Core:getServerPrefix('server', 'Admin') .. getPlayerAdminName(player, true) .." magához teleportált.", targetPlayer);
    outputToAdmins(getPlayerAdminName(player, true) .. ' magához teleportálta ' .. getPlayerName(targetPlayer) .. ' játékost.', 1);
    addAdminLog({ admin = player, player = targetPlayer, action = 'gethere' });
end
Command('gethere', { required = { admin = 3, off_admin = 8 }, args = { { type = 'player' } } }, getHerePlayer);

-- 
-- Admin actions
-- 

function freezePlayer(player, targetPlayer)
    setElementFrozen(player, true);

    outputChatBox(Core:getServerPrefix('server', 'Admin') .. getPlayerAdminName(player, true) .." lefagyasztott.", targetPlayer);
    outputToAdmins(getPlayerAdminName(player, true) .. ' lefagyasztotta ' .. getPlayerName(targetPlayer) .. ' játékost.', 1);
    addAdminLog({ admin = player, player = targetPlayer, action = 'freeze' });
end
Command('freeze', { required = { admin = 3, off_admin = 8 }, args = { { type = 'player' } } }, freezePlayer);

function unfreezePlayer(player, targetPlayer)
    setElementFrozen(player, false);

    outputChatBox(Core:getServerPrefix('server', 'Admin') .. getPlayerAdminName(player, true) .." kiolvasztott.", targetPlayer);
    outputToAdmins(getPlayerAdminName(player, true) .. ' kiolvasztotta ' .. getPlayerName(targetPlayer) .. ' játékost.', 1);
    addAdminLog({ admin = player, player = targetPlayer, action = 'unfreeze' });
end
Command('unfreeze', { required = { admin = 3, off_admin = 8 }, args = { { type = 'player' } } }, unfreezePlayer);

function reconPlayer(player, targetPlayer)
    if (
        isElement(targetPlayer) and 
        getElementType(targetPlayer) == 'player' and 
        targetPlayer ~= player
    ) then 
        reconPlayer(player, targetPlayer);
    else 
        disableRecon(player);
    end 
end
Command('recon', { required = { admin = 3, off_admin = 8 }, args = { { type = 'player', optional = true } } }, reconPlayer);

-- 
-- Player's data
-- 

function resetPlayerSerial(player, accountId)
    local activePlayer = table.find(getElementsByType('player'), function(x)
        if ((getElementData(x, 'userId') or -1) == accountId) then 
            return x;
        end 
    end);

    if (activePlayer) then 
        kickPlayer(activePlayer, 'Rendszer', 'lol reseteltek a serialod');
    end 

	dbExec(Database, "UPDATE `users` SET `serial` = '_' WHERE `id` = ?", accountId);
	outputToAdmins(getPlayerAdminName(player, true) .. ' beállította a(z) #' .. accountId.. ' accountId serialját alapértelmezettre.', 1);
    addAdminLog({ admin = player, player = accountId, action = 'resetserial' });
end
Command('resetserial', { required = { admin = 5 }, args = { { type = 'number', name = 'Account ID', min = 1 } } }, resetPlayerSerial);

-- 
-- Admin level & nick
-- 

function setAdminLevel(player, targetPlayer, level)
    if (
        not Sudoers[getPlayerSerial(player)] and 
        player ~= targetPlayer and 
        getPlayerAdminLevel(player) < (getElementData(targetPlayer, 'adminlevel') or 0)
    ) then 
        return outputChatBox(Core:getServerPrefix('error', 'Admin') .. "Hat ezt nem sikerult tesom.", player);
    end 

    if (not AdminLevels[level]) then 
        return outputChatBox(Core:getServerPrefix('error', 'Admin') .. "Nincs is ilyen adminszint lol.", player);
    end 

    if (level == 1 or level == 2) then 
        return outputChatBox(Core:getServerPrefix('error', 'Admin') .. "(Ideiglenes) Adminsegéd adásához használd a(z) /setaslevel parancsot.", player);
    end 

    local beforeAdmin = (getElementData(targetPlayer, 'admin') or { level = 0, name = "Ismeretlen admin" });

    addAdminLog({ admin = player, player = targetPlayer, action = 'makeadmin', additional = { from = beforeAdmin.level, to = level } });

    beforeAdmin.level = level;
    beforeAdmin.duty = false;

    local accountId = getElementData(targetPlayer, 'userId');
    dbExec(Database, "UPDATE users SET `admin` = ? WHERE `id` = ?", toJSON({ level = beforeAdmin.level, name = beforeAdmin.name }), accountId);

    setElementData(targetPlayer, 'admin', beforeAdmin);
    outputChatBox(Core:getServerPrefix('server', 'Admin') .. getPlayerAdminName(player, true) .." beállította " .. getPlayerName(targetPlayer) ..  " adminszintjét a következőre: " .. AdminColors[level] .. getPlayerAdminTitle(targetPlayer), root);
end
Command('makeadmin', { required = { admin = 9 }, args = { { type = 'player' }, { type = 'number', name = "Szint", min = 0, max = 15 } }, alias = { "setalevel", "setadminlevel" } }, setAdminLevel);

function setAdminName(player, targetPlayer, name)
    if (
        not Sudoers[getPlayerSerial(player)] and 
        player ~= targetPlayer and 
        getPlayerAdminLevel(player) < (getElementData(targetPlayer, 'adminlevel') or 0)
    ) then 
        return outputChatBox(Core:getServerPrefix('error', 'Admin') .. "Hat ezt nem sikerult tesom.", player);
    end 

    local beforeAdmin = (getElementData(targetPlayer, 'admin') or { level = 0, name = "Ismeretlen admin" });

    addAdminLog({ admin = player, player = targetPlayer, action = 'setanick', additional = { from = beforeAdmin.name, to = name } });

    beforeAdmin.name = name;
    beforeAdmin.duty = false;

    local accountId = getElementData(targetPlayer, 'userId');
    dbExec(Database, "UPDATE users SET `admin` = ? WHERE `id` = ?", toJSON({ level = beforeAdmin.level, name = beforeAdmin.name }), accountId);

    setElementData(targetPlayer, 'admin', beforeAdmin);
    outputChatBox(Core:getServerPrefix('server', 'Admin') .. getPlayerAdminName(player, true) .." beállította " .. getPlayerName(targetPlayer, true) ..  " adminnevét a következőre: " .. name, root);
end
Command('setanick', { required = { admin = 9 }, args = { { type = 'player' }, { type = 'string', name = "Név" } }, alias = { "setaname" } }, setAdminName);

function setASLevel(player, targetPlayer, level)
    if (
        not Sudoers[getPlayerSerial(player)] and 
        player ~= targetPlayer and 
        getPlayerAdminLevel(player) < getPlayerAdminLevel(targetPlayer)
    ) then 
        return outputChatBox(Core:getServerPrefix('error', 'Admin') .. "Hat ezt nem sikerult tesom.", player);
    end 

    local beforeAdmin = (getElementData(targetPlayer, 'admin') or { level = 0, name = "Ismeretlen admin" });

    addAdminLog({ admin = player, player = targetPlayer, action = 'setaslevel', additional = { from = beforeAdmin.level, to = level } });

    beforeAdmin.level = level;
    beforeAdmin.duty = level ~= 0;

    if (level ~= 1) then 
        local accountId = getElementData(targetPlayer, 'userId');
        dbExec(Database, "UPDATE users SET `admin` = ? WHERE `id` = ?", toJSON({ level = beforeAdmin.level, name = beforeAdmin.name }), accountId);
    end 

    setElementData(targetPlayer, 'admin', beforeAdmin);

    if (level ~= 0) then 
        outputChatBox(Core:getServerPrefix('server', 'Admin') .. getPlayerAdminName(player, true) .." beállította " .. getPlayerName(targetPlayer, true) ..  " adminsegéd szintjét a következőre: " .. getPlayerAdminTitle(targetPlayer), root);
    end
end
Command('setaslevel', { required = { admin = 5 }, args = { { type = 'player' }, { type = 'number', name = "Ideiglenes (0 = elvétel, 1 = Ideiglenes, 2 = Örök)", min = 0, max = 2 } } }, setASLevel);

-- 
-- Economy 
-- 

function setPlayerPremiumPoints(player, targetPlayer, amount)
    local before = getElementData(targetPlayer, "premium");
	setElementData(targetPlayer, "premium", amount);

	outputChatBox(Core:getServerPrefix('server', 'Admin') .. getPlayerAdminName(player, true) .." adott ".. amount .." prémium pontot.", targetPlayer);
    outputToAdmins(getPlayerAdminName(player, true) .. ' adott ' .. amount .. ' premium pontot ' .. getPlayerName(targetPlayer) .. '-nak/-nek.', 6);
    addAdminLog({ admin = player, player = targetPlayer, action = 'setpp', additional = { from = before, to = amount } });
end
Command('setpp', { required = { admin = 9 }, args = { { type = 'player' }, { type = 'number', min = 1, name = 'Összeg' } } }, setPlayerPremiumPoints);

function setPlayerCash(player, targetPlayer, amount)
    local before = getElementData(targetPlayer, "cash");
    setElementData(targetPlayer, "cash", amount);

	outputChatBox(Core:getServerPrefix('server', 'Admin') .. getPlayerAdminName(player, true) .." beállította a készpénzed ".. amount .." dollárra.", targetPlayer);
    outputToAdmins(getPlayerAdminName(player, true) .. ' beállította ' .. getPlayerName(targetPlayer) .. ' készpénzét ' .. amount .. ' dollárra', 6);
    addAdminLog({ admin = player, player = targetPlayer, action = 'setmoney', additional = { from = before, to = amount } });
end 
Command('setmoney', { required = { admin = 9 }, args = { { type = 'player' }, { type = 'number', min = 1, name = 'Összeg' } } }, setPlayerCash);

-- 
-- Global
-- 

function maximizeAllPlayerHP(admin)
    for _, player in ipairs(getElementsByType('player')) do 
        if (getElementData(player, "spawned")) then 
            setElementData(player, "thirst", 100);
			setElementData(player, "hunger", 100);
			setElementHealth(player, 100);
        end 
    end   

	outputChatBox(Core:getServerPrefix('server', 'Admin') .. getPlayerAdminName(admin) .." beállította mindenki életerejét a maximumra.", root);
    outputToAdmins(getPlayerAdminName(admin) .. ' beállította az összes játékos életerejét a maximumra.', 1);
    addAdminLog({ admin = admin, action = 'globalhp' });
end 
Command('globalhp', { description = "Összes játékos HPja, szomjúsága, éhessége beállítása 100%-ra.", required = { admin = 8 }, args = { } }, maximizeAllPlayerHP);
