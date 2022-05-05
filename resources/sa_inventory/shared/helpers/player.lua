function getElementInventoryWeight(element)
    if (
        not isElement(element) or 
        getElementType(element) ~= 'player'
    ) then 
        return false;
    end
    
    local inventory = (getElementData(element, 'inventory') or {});
    local weight = 0;

    for slot = 0, 31 do 
        local item = inventory[slot];

        if (item) then 
            weight = weight + (Items[item.id].weight * item.count);
        end 
    end 

    if (getElementType(element) == 'player') then 
        for i,v in ipairs(Config.additional_slots) do 
            if (inventory[v.type]) then 
                local item = inventory[v.type];
                weight = weight + (Items[item.id].weight * item.count);
            end 
        end 
    end 

    return weight;
end 

function getElementWeightCapacity(element)
    if (not isElement(element)) then 
        return false;
    end 

    -- ha jarmu akkor majd kerje be vehicle rendszerbu azt mindegyiknek mas legyen a max terherbirasa.

    local elementType = getElementType(element);
    local default = Config.carrying_capacities[elementType];

    return default;
end 

function isElementHasItem(element, id, data)
    if (not isElement(element)) then 
        return false;
    end 

    local inventory = getElementData(element, 'inventory');
    if (not inventory) then 
        return false;
    end 

    for slot = 0, 31 do 
        if (
            inventory[slot] and 
            inventory[slot].id == id and 
            (
                not data or 
                (
                    data and 
                    inventory[slot].data and 
                    table.compare_keytbl(data, inventory[slot].data)
                )
            )
        ) then 
            return true, slot, inventory[slot];
        end 
    end 

    return false;
end

function getElementFreeSlotsCount(element)
    local count = 0;

    for slot = 0, 31 do 
        if (inventory[slot] == nil) then 
            count = count + 1;
        end 
    end 

    return count;
end 

function getElementEmptyItemSlot(element)
    if (not isElement(element)) then 
        return false;
    end 

    local inventory = getElementData(element, 'inventory');
    if (not inventory) then 
        return false;
    end 

    for slot = 0, 31 do 
        if (inventory[slot] == nil) then 
            return slot;
        end 
    end 

    return false;
end 

function isElementCouldCarryItem(element, itemId, count)
    if (
        not isElement(element) or 
        itemId ~= 'string' or 
        type(count) ~= 'number' or 
        Items[itemId]
    ) then 
        return false;
    end 

    return (getElementInventoryWeight(element) + getItemWeight(itemId, count) < getElementWeightCapacity(element));
end 

function getElementItemsWithFlag(element, flag)
    if (
        not isElement(element) or 
        type(flag) ~= 'string'
    ) then 
        return false;
    end 

    local inventory = getElementData(element, 'inventory');
    if (not inventory) then 
        return false;
    end 

    local items = {};
    for slot, item in pairs(inventory) do 
        if (itemHasFlag(item.id, flag)) then 
            items[slot] = item;
        end 
    end 

    return items;
end 