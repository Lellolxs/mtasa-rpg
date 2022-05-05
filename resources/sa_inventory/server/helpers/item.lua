local __ItemConstructors = {};

__ItemConstructors['general'] = function(itemId, amount)
    return {
        id = itemId, 
        count = amount
    };
end 

__ItemConstructors['consumable'] = function(element, itemId, amount)
    if (itemHasFlag(itemId, "STACKABLE")) then 
        if (isElementCouldCarryItem())
    else 

    end 

    return true;
end 

function giveItemToElement(element, itemId, amount, ...)
    if (
        not isElement(element) or 
        not ElementTypesWithInventory[getElementType(element)] or 
        not itemId or 
        not Items[itemId]
    ) then 
        return false;
    end 

    local amount = amount or 1;

    local itemData, error = __ItemConstructors[Items[itemId]]();
end 