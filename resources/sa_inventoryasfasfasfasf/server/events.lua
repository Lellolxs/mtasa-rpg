addEvent('inventory:moveItem', true);
addEventHandler('inventory:moveItem', resourceRoot, function(fromSlot, toSlot, amount)
    local player = client;

    if (
        fromSlot == toSlot 
    ) then 
        return;
    end 

    if (
        type(amount) == 'number' and 
        (
            amount < 1 or
            tostring(amount):find("%D")
        )
    ) then 
        outputChatBox('kurva anyadat', player);
        return;
    end 

    local inventory = (getElementData(player, 'inventory') or {});

    if (not inventory[fromSlot]) then 
        return;
    end 

    -- lehet ide kene majd egy recode, de egyelore mukodjon.
    if (not inventory[toSlot]) then 
        if (
            type(fromSlot) == 'number' and
            type(toSlot) == 'number'
        ) then 
            if (
                not amount or 
                (inventory[fromSlot].count - amount) <= 0
            ) then 
                inventory[toSlot] = inventory[fromSlot];
                inventory[fromSlot] = nil;
            else 
                inventory[toSlot] = table.copy(inventory[fromSlot]);
                inventory[toSlot].count = amount;
                inventory[fromSlot].count = inventory[fromSlot].count - amount;
            end 
        else 
            local itemType = getItemType(inventory[fromSlot]);

            if (
                type(fromSlot) == 'number' and 
                type(toSlot) == 'string' and 
                AttachmentTypes[itemType]
            ) then 
                -- olyan slotra huzza ahova nem lehet
                if (itemType ~= toSlot) then 
                    return false;
                end 

                local mounted = addPlayerAttachment(player, inventory[fromSlot]);
                if (mounted ~= false) then 
                    inventory[toSlot] = inventory[fromSlot];
                    inventory[fromSlot] = nil;
                end 
            elseif (
                type(fromSlot) == 'string' and 
                type(toSlot) == 'number' and 
                AttachmentTypes[itemType]
            ) then 
                local unmounted = removePlayerAttachment(player, inventory[fromSlot]);
                if (unmounted ~= false) then 
                    inventory[toSlot] = inventory[fromSlot];
                    inventory[fromSlot] = nil;
                end 
            end 
        end 
    else
        if (
            inventory[fromSlot].id == inventory[toSlot].id and 
            itemHasFlag(inventory[toSlot].id, 'STACKABLE')
        ) then 
            inventory[toSlot].count = inventory[toSlot].count + inventory[fromSlot].count;
            inventory[fromSlot] = nil;
        end 
    end

    if (not wasEventCancelled()) then 
        setElementData(player, 'inventory', inventory);
    end 
end);

addEvent('inventory:useItemOnSlot', true);
addEventHandler('inventory:useItemOnSlot', resourceRoot, function(slot)
    local player = client;

    if (type(slot) ~= 'number' or not player) then 
        return;
    end 

    local inventory = (getElementData(player, 'inventory') or {});

    if (not inventory[slot]) then 
        return;
    end 

    triggerEvent('onPlayerUseItem', root, player, inventory[slot], slot);

    if (not wasEventCancelled()) then 
        if (
            itemHasFlag(inventory[slot], "TAKE_ONE_ON_USE") and 
            inventory[slot].count > 1
        ) then  
            inventory[slot].count = inventory[slot].count - 1;
        else
            inventory[slot] = nil;
        end 

        setElementData(player, 'inventory', inventory);
    end 
end);

local GarbageContainerModels = {
    [3035] = true,
};

addEvent('inventory:moveItemOnElement', true);
addEventHandler('inventory:moveItemOnElement', resourceRoot, function(element, slot, amount)
    local player = client;

    if (
        not isElement(element) or 
        type(slot) ~= 'number'
    ) then 
        return;
    end 

    if (
        type(amount) == 'number' and 
        (
            amount < 1 or
            tostring(amount):find("%D")
        )
    ) then 
        outputChatBox('kurva anyadat', player);
        return;
    end 

    if (player == element) then 
        return outputChatBox('faszert akarnad magadrahuzni?', player);
    end 

    local inventory = (getElementData(player, 'inventory') or {});

    if (GarbageContainerModels[getElementModel(element)]) then 
        Chat:elementSendMe(player, 'kidobott valamit a kukába. ((' .. Items[inventory[slot].id].name .. '))');

        local amount = amount or 1;

        if (
            amount >= inventory[slot].count or 
            inventory[slot].count - amount <= 0
        ) then 
            inventory[slot] = nil;
        else 
            inventory[slot].count = inventory[slot].count - ((type(amount) ~= 'number') and 1 or amount);
        end 
        
        setElementData(player, 'inventory', inventory);

        return;
    end 
end);

addEvent("onPlayerUseItem", false);