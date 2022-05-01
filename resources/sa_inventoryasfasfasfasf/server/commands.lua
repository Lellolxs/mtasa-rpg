--getElementEmptyItemSlot

addEvent("onPlayerEmitCommand:giveitem", false);
addEventHandler('onPlayerEmitCommand:giveitem', root, function(player, targetPlayer, itemId, count)
    if (not Items[itemId]) then 
        return outputChatBox(Core:getServerPrefix("error", "Admin") .. " Nem létezik item ilyen azonosítóval.", player, 255, 255, 255, true);
    end 

    local inventory = getElementData(targetPlayer, 'inventory');
    if (not inventory) then 
        return outputChatBox(Core:getServerPrefix("error", "Admin") .. " A játékos nem rendelkezik inventoryval?!? (Kickeld a rakba.)", player, 255, 255, 255, true);
    end 

    local emptySlot = getElementEmptyItemSlot(targetPlayer);
    if (
        not emptySlot or 
        isElementCouldCarryItem(targetPlayer)
    ) then 
        return outputChatBox(Core:getServerPrefix("error", "Admin") .. " A játékosnál nincs elég hely.", player, 255, 255, 255, true);
    end 

    inventory[emptySlot] = { id = itemId, count = count };
    setElementData(targetPlayer, 'inventory', inventory);
end);
Admin:Command('giveitem',{required={admin=8},args={{type='player'},{type='string',name="Item ID"},{type='number', name="Mennyiség",min=1}}});

addEvent('onPlayerEmitCommand:givecarkey', false);
addEventHandler('onPlayerEmitCommand:givecarkey', root, function(player, targetPlayer, vehicle)
    local vehicleId = getElementData(vehicle, 'id');
    if (not vehicleId) then 
        return outputChatBox(Core:getServerPrefix("error", "Admin") .. " Ennek a járműnek nincs ID-je.", player, 255, 255, 255, true);
    end 

    local inventory = getElementData(targetPlayer, 'inventory');
    if (not inventory) then 
        return outputChatBox(Core:getServerPrefix("error", "Admin") .. " A játékos nem rendelkezik inventoryval?!? (Kickeld a rakba.)", player, 255, 255, 255, true);
    end 

    local emptySlot = getElementEmptyItemSlot(targetPlayer);
    if (
        not emptySlot or 
        isElementCouldCarryItem(targetPlayer)
    ) then 
        return outputChatBox(Core:getServerPrefix("error", "Admin") .. " A játékosnál nincs elég hely.", player, 255, 255, 255, true);
    end 

    inventory[emptySlot] = { id = "car_key", count = 1, data = { vehicleId = vehicleId } };
    setElementData(targetPlayer, 'inventory', inventory);
end);
Admin:Command('givecarkey',{required={admin=8},description="Kulcsot ad egy adott járműhöz.",args={{type='player'},{type='vehicle'}}});