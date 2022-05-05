Core = exports.sa_core;
Admin = exports.sa_admin;
Inventory = exports.avInventory;

Database = Core:getDatabase();

local SpawnPoints = {
    { pos = Vector3(-321.228515625, 1056.2177734375, 19.7421875), interior = 0, dimension = 0 }, 
};

function respawnPlayer(player, revivedByAdmin)
    if (
        not isElement(player) or 
        getElementType(player) ~= 'player' or 
        not getElementData(player, 'death')
    ) then 
        return false;
    end 

    if (not revivedByAdmin) then 
        local inventory = getElementData(player, 'inventory');
        local items = Inventory:getElementItemsWithFlag(player, "TAKE_ON_DEATH");
        if (items) then 
            for slot, item in pairs(items) do 
                inventory[slot] = nil;
            end 
        end 

        setElementData(player, 'inventory', inventory);

        local spawn = SpawnPoints[math.random(1, #SpawnPoints)];
        local skin = getElementModel(player);
        spawnPlayer(player, spawn.pos.x, spawn.pos.y, spawn.pos.z, 0, skin, spawn.interior, spawn.dimension);
    else 
        local x, y, z = getElementPosition(player);
        local int, dim = getElementInterior(player), getElementDimension(player);
        local skin = getElementModel(player);

        spawnPlayer(player, x, y, z, 0, skin, int, dim);
    end 

    removeElementData(player, 'death');
    triggerClientEvent(player, "death:toggle", resourceRoot, false);
end 

addEvent('onPlayerDeathTimeUp', true);
addEventHandler('onPlayerDeathTimeUp', resourceRoot, function()
    local player = client;
    if (not player) then
        return false;
    end 

    local death = getElementData(player, 'death');
    if (not death) then 
        return false;
    end 

    respawnPlayer(player);
end);

addEventHandler('onPlayerWasted', root, function(ammo, killer, weapon, bodypart, stealth)
    local player = source;

    setElementData(player, 'death', {
        timestamp = getRealTime().timestamp, 
        killer = isElement(killer) and getElementData(killer, 'id') or false,
    });

    dbExec(
        Database, 
        [[
            INSERT INTO
                logs__death (victim, killer, date)
            VALUES
                (?, ?, NOW())
        ]], 
        getElementData(player, 'charId'), 
        (isElement(killer) and getElementType(killer) ~= 'player' and killer ~= player) 
                and getElementData(killer, 'charId') 
                or nil
    );
end);