Vehicles = {
    [602] = {
        name = "Faszgeci",
        -- baseModelId = 411, -- ha esetleg custom auto lenne.

        attributes = {
            MAX_TRUNK_WEIGHT = 1000,
        },
    },
};

function getVehicleList()
    return Vehicles;
end 

function getVehicleBaseModelId(id)
    return (type(id) == 'number' and Vehicles[id] and Vehicles[id].baseModelId ~= nil)
            and Vehicles[id].baseModelId
            or id;
end 

function getVehicleAttributes(id)
    if (
        type(id) ~= 'number' or 
        type(id) ~= 'userdata'
    ) then 
        return false;
    end 

    local modelId = isElement(id) and getElementModel(id) or id;
    
    return (type(modelId) == 'number' and Vehicles[modelId] and Vehicles[modelId].attributes ~= nil)
            and Vehicles[modelId].attributes
            or nil;
end 

function getVehicleAttribute(id, attributeName)
    local attributes = getVehicleAttributes(id);
    return (attributes and attributes[attributeName] ~= nil)
            and attributes[attributeName]
            or nil;
end 