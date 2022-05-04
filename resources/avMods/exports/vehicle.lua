function getVehicleRealName(id)
    local vehicle = isElement(id) and getElementModel(id) or (type(id) == 'number' and id or getVehicleModelFromName(id));
    local name = (config.mods.vehicles[vehicle] ~= nil) and config.mods.vehicles[vehicle].realName or getVehicleNameFromModel(vehicle);
    return (name or 'Ismeretlen');
end