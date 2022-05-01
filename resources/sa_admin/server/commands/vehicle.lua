-- 
-- Vehicle fix & fuel
-- 



function fixPlayerVehicle(player, targetPlayer)
    local vehicle = getPedOccupiedVehicle(targetPlayer);
    if (not vehicle) then 
        return outputChatBox(Core:getServerPrefix('server', 'Admin') .. getPlayerName(targetPlayer) .." nincs járműben.", targetPlayer);
    end 

    fixVehicle(vehicle);

    local data = getAllElementData(vehicle);
	for k2, v2 in pairs(data) do
		local datas = split(k2, "::");
		if (datas[2]) then
			if (datas[1] == "hide") then
			    setElementData(vehicle, k2, nil);
		    end
		end
	end

    setVehicleDamageProof(vehicle, false);
	setElementData(vehicle, "veh:EngineCrash", 0);

    changeAdminStat(player, 'vehicle_fix', 1);

    outputChatBox(Core:getServerPrefix('server', 'Admin') .. getPlayerAdminName(player, true) .." megszerelte a járműved.", targetPlayer);
    outputToAdmins(getPlayerAdminName(player, true) .. ' megjavította ' .. getPlayerName(targetPlayer) .. ' járművét.', 1);
    addAdminLog({ admin = player, player = targetPlayer, vehicle = vehicle, action = 'fixveh' });
end 
Command('fixveh', { required = { admin = 4, off_admin = 8 }, args = { { type = 'player' } } }, fixPlayerVehicle);

function unflipPlayerVehicle(player, targetPlayer)
    local vehicle = getPedOccupiedVehicle(targetPlayer);
    if (not vehicle) then 
        return outputChatBox(Core:getServerPrefix('server', 'Admin') .. getPlayerName(targetPlayer) .." nincs járműben.", targetPlayer);
    end 

    setElementRotation(vehicle, 0, 0, 0);
    changeAdminStat(player, 'vehicle_unflip', 1);

    outputChatBox(Core:getServerPrefix('server', 'Admin') .. getPlayerAdminName(player, true) .." felfordította a járműved.", targetPlayer);
    outputToAdmins(getPlayerAdminName(player, true) .. ' felfordította ' .. getPlayerName(targetPlayer) .. ' járművét.', 1);
    addAdminLog({ admin = player, player = targetPlayer, vehicle = vehicle, action = 'unflip' });
end 
Command('unflip', { required = { admin = 3, off_admin = 8 }, args = { { type = 'player' } } }, unflipPlayerVehicle);

function fuelPlayerVehicle(player, targetPlayer)
    local vehicle = getPedOccupiedVehicle(targetPlayer);
    if (not vehicle) then 
        return outputChatBox(Core:getServerPrefix('server', 'Admin') .. getPlayerName(targetPlayer) .." nincs járműben.", targetPlayer);
    end 

    setElementData(vehicle, 'veh:FuelData', 100);
    changeAdminStat(player, 'vehicle_fuel', 1);

    outputChatBox(Core:getServerPrefix('server', 'Admin') .. getPlayerAdminName(player, true) .." megtankolta a járműved.", targetPlayer);
    outputToAdmins(getPlayerAdminName(player, true) .. ' megtankolta ' .. getPlayerName(targetPlayer) .. ' járművét.', 1);
    addAdminLog({ admin = player, player = targetPlayer, vehicle = vehicle, action = 'fuelveh' });
end 
Command('fuelveh', { required = { admin = 3, off_admin = 8 }, args = { { type = 'player' } } }, fuelPlayerVehicle);

-- 
-- Vehicle parts
-- 

local fixableVehicleComponents = { "Engine", "Tires", "Brakes", "Oil" };
function fixPlayerVehiclePart(player, targetPlayer, component)
    local vehicle = getPedOccupiedVehicle(targetPlayer);
    if (not vehicle) then 
        return outputChatBox(Core:getServerPrefix('server', 'Admin') .. getPlayerName(targetPlayer) .." nincs járműben.", targetPlayer);
    end 

    setElementData(vehicle, 'problem:' .. component, 100);
    changeAdminStat(player, 'vehicle_fix_component_' .. component, 1);

    outputChatBox(Core:getServerPrefix('server', 'Admin') .. getPlayerAdminName(player, true) .." beállította a járműved " .. component .. " értékét 100%-ra.", targetPlayer);
    outputToAdmins(getPlayerAdminName(player, true) .. ' beállította ' .. getPlayerName(targetPlayer) .. ' járművének ' .. component .. ' értékét 100%-ra.', 1);
    addAdminLog({ admin = player, player = targetPlayer, vehicle = vehicle, action = 'vehicle_fix_component_' .. component });
end 
Command('fixvehcomp', { required = { admin = 4, off_admin = 8 }, args = { { type = 'player' }, { type = 'string', name = 'Komponens (' .. table.concat(fixableVehicleComponents, ', ') .. ')', values = fixableVehicleComponents } } }, fixPlayerVehiclePart);

-- 
-- Teleport
-- 

function gotoVehicle(player, vehicle)
    local x, y, z = getElementPosition(vehicle);
    local int, dim = getElementInterior(vehicle), getElementDimension(vehicle);

    setElementPosition(player, x, y, z);
    setElementInterior(player, int); 
    setElementDimension(player, dim); 
    
    local vehicleName = exports.avMods:getVehicleRealName(vehicle);

    outputToAdmins(getPlayerAdminName(player, true) .. ' odateleportált a(z) #' .. (getElementData(vehicle, 'id') or -1) .. ' ('..vehicleName..') id-jű járműhöz.', 1);
    addAdminLog({ admin = player, vehicle = (getElementData(vehicle, 'id') or -1), action = 'gotocar' });
end 
Command('gotocar', { required = { admin = 3, off_admin = 8 }, args = { { type = 'vehicle' } } }, gotoVehicle);

function getVehicle(player, vehicle)
    local x, y, z = getElementPosition(player);
    local int, dim = getElementInterior(player), getElementDimension(player);

    setElementPosition(vehicle, x, y, z);
    setElementInterior(vehicle, int); 
    setElementDimension(vehicle, dim); 

    local vehicleName = exports.avMods:getVehicleRealName(vehicle);

    outputToAdmins(getPlayerAdminName(player, true) .. ' magához teleportálta a(z) #' .. (getElementData(vehicle, 'id') or -1) .. ' ('..vehicleName..') id-jű járművet.', 1);
    addAdminLog({ admin = player, vehicle = (getElementData(vehicle, 'id') or -1), action = 'getcar' });
end 
Command('getcar', { required = { admin = 3, off_admin = 8 }, args = { { type = 'vehicle' } } }, getVehicle);

-- 
-- Global 
-- 

function fixAllVehicle(player)
    for _, vehicle in ipairs(getElementsByType('vehicle')) do 
        fixVehicle(vehicle);
        local data = getAllElementData(vehicle);
        for k2, v2 in pairs(data) do
            local datas = split(k2, "::");
            if (datas[2]) then
                if (datas[1] == "hide") then
                    setElementData(vehicle, k2, nil);
                end
            end
        end

        setVehicleDamageProof(vehicle, false);
	    setElementData(vehicle, "veh:EngineCrash", 0);
    end   

	outputChatBox(Core:getServerPrefix('server', 'Admin') .. getPlayerAdminName(player, true) .." megszerelte az összes járművet.", root);
    addAdminLog({ admin = player, action = 'fixallveh' });
end 
Command('fixallveh', { description = "Megszereli az összes járművet.", required = { admin = 9 }, args = { } }, fixAllVehicle);