ElementTypesWithInventory = {
    player = true, 
    vehicle = true, 
    object = true,
};

ElementIdentifiers = {
    player = function(element)
        return getElementData(element, 'charId');
    end, 

    vehicle = function(element)

    end, 

    object = function()

    end
};