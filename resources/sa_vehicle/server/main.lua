Core = exports.sa_core;
Admin = exports.sa_admin;
Chat = exports.sa_chat;
Inventory = exports.sa_inventory;

Database = Core:getDatabase();

loadstring(Core:require({ "Async" }))();

function loadVehicle(___, vehicle) -- SQL querybol visszaadott adatokkal
    if (isVehicleExistsWithId(vehicle.id)) then 
        return false;
    end 

    local position = fromJSON(vehicle.position);
    local vehicleElement = createVehicle(getVehicleBaseModelId(vehicle.model), position.x, position.y, position.z);
    setElementInterior(vehicleElement, position.interior);
    setElementDimension(vehicleElement, position.dimension);

    setElementData(vehicleElement, 'model', vehicle.model);
    setElementData(vehicleElement, 'baseModel', getVehicleBaseModelId(vehicle.model));

    setElementData(vehicleElement, 'id', vehicle.id);
    setElementData(vehicleElement, 'owner', vehicle.owner);
    setElementData(vehicleElement, 'ownerType', vehicle.owner_type);

    local plate = generateLicensePlate(vehicle.id);
    setElementData(vehicleElement, 'plate', plate);
    setVehiclePlateText(vehicleElement, plate);

    setTimer(triggerClientEvent, 250, 1, root, "emitVehicleLoadEffect", root, vehicleElement, 10000);

    return true;
end 

function loadPlayerVehicles(player)
    local charId = getElementData(player, 'charId');

    if (not charId) then 
        return;
    end 

    dbQuery(
        function(qh)
            local result = dbPoll(qh, 10);

            if (result and #result > 0) then 
                table.foreach(result, loadVehicle);
            end 
        end, 
        Database, 
        [[
            SELECT 
                * 
            FROM 
                vehicles
            WHERE 
                owner = ? AND 
                owner_type = 'player'
        ]], 
        charId
    );
end 

function loadProtectedVehicles()
    dbQuery(
        function(qh)
            local result = dbPoll(qh, 10);

            if (result and #result > 0) then 
                table.foreach(result, loadVehicle);
            end 
        end, 
        Database, 
        [[
            SELECT 
                * 
            FROM 
                vehicles
            WHERE 
                protected = 1
        ]]
    );
end 

function isVehicleExistsWithId(id)
    if (not id or type(id) ~= 'number') then 
        return false;
    end 

    for _, vehicle in ipairs(getElementsByType('vehicle')) do 
        if ((getElementData(vehicle, 'id') or -1) == id) then 
            return vehicle;
        end 
    end 

    return false;
end 

addEventHandler('onResourceStart', resourceRoot, function()
    loadProtectedVehicles();
end);