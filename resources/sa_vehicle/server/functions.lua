local pendingVehicleEnters = {}; -- { [key: Vehicle]: boolean(engine) }

function toggleVehicleLights(player, _, _, vehicle)
    if (not isElement(vehicle)) then 
        return;
    end 

    local state = getVehicleOverrideLights(vehicle) ~= 2;
    setVehicleOverrideLights(vehicle, state and 2 or 1);
    Chat:elementSendMe(player, (state and "felkapcsolta" or "lekapcsolta") .. " egy jármű fényszóróit.");
    addVehicleLog({ player = player, vehicle = vehicle, action = "SET_LIGHTS", additional = { state = not state } });
end 

function toggleVehicleEngine(player, _, _, vehicle)
    if (not isElement(vehicle)) then 
        return;
    end 

    if (not playerHasAccessToVehicle(player, vehicle)) then 
        return outputChatBox('bocs tesi de nem', player);
    end

    local state = getVehicleEngineState(vehicle);
    setVehicleEngineState(vehicle, not state);
    Chat:elementSendMe(player, (state and "leállítja" or "elindítja") .. " egy jármű motorját.");
    addVehicleLog({ player = player, vehicle = vehicle, action = "TOGGLE_ENGINE", additional = { state = not state } });
end 

local __LastVehicleLockChanges = {};
function toggleVehicleLock(player)
    local vehicle = getPedOccupiedVehicle(player);
    if (not vehicle) then 
        vehicle = Core:findNearestVehicleToElement(player, 10);

        if (not vehicle) then 
            return false;
        end 
    end 

    if (
        __LastVehicleLockChanges[vehicle] and 
        __LastVehicleLockChanges[vehicle] + 3500 > getTickCount()
    ) then 
        return;
    end 

    __LastVehicleLockChanges[vehicle] = getTickCount();

    if (not playerHasAccessToVehicle(player, vehicle)) then 
        return outputChatBox('bocs tesi de nem', player);
    end

    local originalLightState = {};
    for i = 0, 3 do originalLightState[i] = getVehicleLightState(vehicle, i); end 
    setVehicleOverrideLights(vehicle, 2);
    setTimer(setVehicleOverrideLights, 250, 1, vehicle, 0);
    setTimer(setVehicleOverrideLights, 500, 1, vehicle, 2);
    setTimer(setVehicleOverrideLights, 750, 1, vehicle, 0);
    for i = 0, 3 do getVehicleLightState(vehicle, originalLightState[i]); end 
    originalLightState = nil;

    local state = isVehicleLocked(vehicle);
    setVehicleLocked(vehicle, not isVehicleLocked(vehicle));
    Chat:elementSendMe(player, (state and "kinyitja" or "bezárja") .. " egy jármű ajtaját.");
    addVehicleLog({ player = player, vehicle = vehicle, action = "TOGGLE_LOCK", additional = { state = not state } });

    collectgarbage();
end 

setTimer(function() 
    local now = getTickCount(); 

    for vehicle, tick in pairs(__LastVehicleLockChanges) do 
        if (tick + 60000 < now) then 
            __LastVehicleLockChanges[vehicle] = nil;
        end 
    end
end, 60000 * 5, 0);

addEventHandler('onVehicleStartEnter', root, function(player, seat)
    if (not pendingVehicleEnters[source] and seat == 0) then 
        pendingVehicleEnters[source] = getVehicleEngineState(source);
    end 
end);

addEventHandler('onVehicleStartExit', root, function(player, seat)
    if (isVehicleLocked(source)) then 
        outputChatBox(Core:getServerPrefix("error") .. ' zarva van az auto ocskos', player, 255, 255, 255, true);
        return cancelEvent(true);
    end 

    if (
        pendingVehicleEnters[source] and 
        seat == 0 and 
        not wasEventCancelled()
    ) then 
        pendingVehicleEnters[source] = nil;
    end 
end);

addEventHandler('onPlayerVehicleEnter', root, function(vehicle, seat, jacker)
    if (seat == 0) then 
        bindKey(source, 'l', 'down', toggleVehicleLights, vehicle);
        bindKey(source, 'j', 'down', toggleVehicleEngine, vehicle);

        if (pendingVehicleEnters[vehicle] ~= nil) then 
            setVehicleEngineState(vehicle, pendingVehicleEnters[vehicle]);
            pendingVehicleEnters[vehicle] = nil;
        end 
    end 

    addVehicleLog({ 
        player = source, 
        vehicle = vehicle, 
        action = "VEHICLE_ENTER", 
        additional = { 
            seat = seat, 
            jackedBy = jacker, 
            position = { 
                coord = { 
                    pos = { getElementPosition(vehicle) }, 
                    int = getElementInterior(vehicle), 
                    dim = getElementDimension(vehicle) 
                } 
            },
        }
    });
end);

addEventHandler('onPlayerVehicleExit', root, function(vehicle, seat, jacker, forcedByScript)
    if (seat == 0) then 
        unbindKey(source, 'l', 'down', toggleVehicleLights);
        unbindKey(source, 'j', 'down', toggleVehicleEngine);
    end

    addVehicleLog({ 
        player = source, 
        vehicle = vehicle, 
        action = "VEHICLE_EXIT", 
        additional = { 
            seat = seat, 
            jackedBy = jacker, 
            forcedByScript = forcedByScript, 
            position = { 
                coord = { 
                    pos = { getElementPosition(vehicle) }, 
                    int = getElementInterior(vehicle), 
                    dim = getElementDimension(vehicle) 
                } 
            },
        }
    });
end);

addEventHandler('onResourceStart', resourceRoot, function()
    for _, player in ipairs(getElementsByType('player')) do 
        bindKey(player, 'k', 'down', toggleVehicleLock);
    end 
end);

addEventHandler('onPlayerJoin', root, function()
    bindKey(source, 'k', 'down', toggleVehicleLock);
end);