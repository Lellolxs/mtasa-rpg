function findNearestVehicleToElement(element, maxDistance)
    if (not isElement(element)) then 
        return false;
    end 

    local maxDistance = (maxDistance or 15);

    local x, y, z = getElementPosition(element);
    local targetVehicle;
    local latestDistance = 9999;

    for _, vehicle in ipairs(getElementsByType('vehicle')) do 
        local vX, vY, vZ = getElementPosition(vehicle);
        local distance = getDistanceBetweenPoints3D(x, y, z, vX, vY, vZ);

        if (distance < latestDistance) then 
            latestDistance = distance;
            targetVehicle = vehicle;
        end 
    end 

    if (latestDistance < maxDistance) then 
        return targetVehicle, distance;
    else 
        return false;
    end 
end 