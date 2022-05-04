WeaponUsages = {
    --{ [key: Player]: { weaponSlot: number, ammoSlot: number } }
};

addEventHandler('onPlayerWeaponSwitch', root, function(previousSlot)
    local player = source;

    if (WeaponUsages[player]) then 
        setPedWeaponSlot(player, previousSlot);
    end 
end);

addEventHandler('onPlayerWeaponFire', root, function()
    local player = source;

    if (WeaponUsages[player]) then 
        local usage = WeaponUsages[player];

        local inventory = (getElementData(player, 'inventory') or {});
        local healthDecrease = math.random(1, 3);

        local hasEnoughAmmo = (inventory and inventory[usage.ammoSlot] and inventory[usage.ammoSlot].count >= 2);
        local weaponNotBreak = (inventory and inventory[usage.weaponSlot] and inventory[usage.weaponSlot].status - healthDecrease > 0);

        if (hasEnoughAmmo and weaponNotBreak) then 
            inventory[usage.ammoSlot].count = inventory[usage.ammoSlot].count - 1;
            inventory[usage.weaponSlot].status = inventory[usage.weaponSlot].status - healthDecrease;
        elseif (not hasEnoughAmmo) then  
            takeAllWeapons(player);
            toggleControl(player, 'previous_weapon', true);
            toggleControl(player, 'next_weapon', true);
            
            Chat:elementSendDo(player, "kattanás hallatszik.");
            Chat:elementSendMe(player, "eltesz egy fegyvert. ((" .. getItemName(inventory[usage.weaponSlot]) .. "))");
            outputChatBox(Core:getServerPrefix("error") .. "Elfogyott a lőszered.", player, 255, 255, 255, true);

            inventory[usage.ammoSlot] = nil;
            WeaponUsages[player] = nil;
        elseif (not weaponNotBreak) then  
            takeAllWeapons(player);
            toggleControl(player, 'previous_weapon', true);
            toggleControl(player, 'next_weapon', true);
            
            Chat:elementSendDo(player, "robbanás hallatszik.");
            Chat:elementSendMe(player, "eltesz egy fegyvert. ((" .. getItemName(inventory[usage.weaponSlot]) .. "))");
            outputChatBox(Core:getServerPrefix("error") .. "eltört a fegyvered.", player, 255, 255, 255, true);

            inventory[usage.weaponSlot].status = 0;
            WeaponUsages[player] = nil;
        end 

        setElementData(player, 'inventory', inventory);
    end 
end);

addEventHandler('onPlayerUseItem', root, function(player, item, slot)
    local itemType = getItemType(item);

    if (itemType == 'weapon') then 
        cancelEvent(true);

        iprint(item.status, item.status < 1)

        if (item.status < 1) then 
            outputChatBox(Core:getServerPrefix("error") .. "Ez a fegyver el van törve.", player, 255, 255, 255, true);
            return;
        end 

        local weapon = Items[item.id];
        if (not WeaponUsages[player]) then 
            local ammoItem, ammoSlot = table.find_keytbl(
                (getElementData(player, 'inventory') or { }), 
                function(v, i) 
                    if (
                        getItemType(v) == 'ammo' and 
                        weapon.ammoType == v.id
                    ) then 
                        return v, i;
                    end 
                end
            );

            if (not ammoItem or ammoItem.count <= 0) then 
                toggleControl(player, 'fire', false);
                toggleControl(player, 'action', false);
            end 

            local count = (ammoItem and ammoItem.count) and ammoItem.count or 1;

            giveWeapon(player, weapon.weaponId, count, true);
            toggleControl(player, 'previous_weapon', false);
            toggleControl(player, 'next_weapon', false);

            Chat:elementSendMe(player, "elővesz egy fegyvert. ((" .. getItemName(item) .. "))");

            WeaponUsages[player] = { weaponSlot = slot, ammoSlot = ammoSlot or -1 };
        else 
            takeAllWeapons(player);
            toggleControl(player, 'previous_weapon', true);
            toggleControl(player, 'next_weapon', true);
            toggleControl(player, 'fire', true);
            toggleControl(player, 'action', true);

            Chat:elementSendMe(player, "eltesz egy fegyvert. ((" .. getItemName(item) .. "))");

            WeaponUsages[player] = nil;
        end 
    end 
end);