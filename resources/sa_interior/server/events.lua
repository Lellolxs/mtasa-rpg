
addEvent('sInterior:fetchInterior', true);
addEventHandler(
    'sInterior:fetchInterior', 
    root, 
    function(interiorId)
        if (interiorId and Interiors[interiorId]) then 
            triggerClientEvent(
                client, 
                'sInterior:clientUpdateInterior', 
                client, 
                Interiors[interiorId]
            );
        end 
    end
);

addEvent('sInterior:setLockState', true);
addEventHandler(
    'sInterior:setLockState', 
    root,
    function(interiorId, state)
        if (interiorId and Interiors[interiorId]) then 
            local interior = Interiors[interiorId];

            interior.locked = state;

            triggerClientEvent(
                client, 
                'sInterior:clientUpdateInterior', 
                client, 
                interior
            );
        end 
    end
);

addEvent('sInterior:enterInterior', true);
addEventHandler(
    'sInterior:enterInterior', 
    root,
    function(interiorId)
        if (interiorId and Interiors[interiorId]) then 
            local interior = Interiors[interiorId];

            local shape = isElementWithinColShape(client, interior.entrace) and interior.exit or interior.entrace;
            local x, y, z = getElementPosition(shape);
            local int, dim = getElementInterior(shape), getElementDimension(shape);

            local vehicle = getPedOccupiedVehicle(client);
            if (vehicle and getVehicleOccupant(vehicle, 0) == client) then 
                if (interior.category ~= 'garage') then 
                    return exports.oInfobox:addInfoBox(
                        client, "Járművel csak garázsba mehetsz be", "error"
                    );
                end 

                if (interior.type == 'custom') then 
                    if (shape == interior.exit) then 
                        triggerClientEvent(client, 'sInterior:initCustomInterior', client, interior);
                    else 
                        triggerClientEvent(client, 'sInterior:unloadCustomInterior', client);
                    end 
                end 

                setElementFrozen(vehicle, true);
                setTimer(setElementFrozen, 1000, 1, vehicle, false);

                setElementPosition(vehicle, x, y, z);
                setElementInterior(vehicle, int);
                setElementDimension(vehicle, dim);

                for _, player in pairs(getVehicleOccupants(vehicle)) do 
                    setElementInterior(player, int);
                    setElementDimension(player, dim);
                    setCameraInterior(player, int);

                    if (interior.type == 'custom') then 
                        triggerClientEvent(player, 'sInterior:initCustomInterior', player, interior);
                    end 
                end 
            elseif (not vehicle) then 
                if (interior.type == 'custom') then 
                    if (shape == interior.exit) then 
                        triggerClientEvent(client, 'sInterior:initCustomInterior', client, interior);
                    else 
                        triggerClientEvent(client, 'sInterior:unloadCustomInterior', client);
                    end 
                end 

                setElementPosition(client, x, y, z);
                setElementInterior(client, int);
                setElementDimension(client, dim);
            end 
        end 
    end
);
