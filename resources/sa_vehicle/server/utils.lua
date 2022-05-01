function playerHasAccessToVehicle(player, vehicle)
    if (getElementData(vehicle, 'temporary')) then 
        return true;
    end 

    local admin = Admin:getPlayerAdminLevel(player);
    local duty = Admin:isAdminInDuty(player);
    if (
        (duty and admin >= 3) or 
        (not duty and admin >= 8)
    ) then 
        return true;
    end 

    if (Inventory:isElementHasItem(player, 'car_key', { vehicleId = (getElementData(vehicle, 'id') or -1) })) then 
        return true;
    end

    return false;
end 