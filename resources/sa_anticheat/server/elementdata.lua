local WhitelistedKeys = {
    player = {
        
    },

    vehicle = {

    },

    object = {

    },
};

addEventHandler('onElementDataChange', root, function(key, old, new)
    if (not client) then
        return;
    end 

    local elementType = getElementType(source);
    if (
        not elementType and 
        not ProtectedKeys[elementType] and 
        not ProtectedKeys[elementType][key]
    ) then 
        setElementData(source, key, old);
    end 
end);