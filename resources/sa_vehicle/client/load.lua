local vehiclesBeingLoaded = {};
local vehiclesLoadRenderActive = false;

local function setVehicleCollidable(vehicle, state)
    for _, player in ipairs(getElementsByType('player')) do 
        setElementCollidableWith(vehicle, player, state);
    end 

    for _, targetVehicle in ipairs(getElementsByType('vehicle')) do 
        setElementCollidableWith(vehicle, targetVehicle, state);
    end 

    for _, object in ipairs(getElementsByType('object')) do 
        setElementCollidableWith(vehicle, object, state);
    end 
end 

local function rootPreRender(delta)
    local proceeded = 0;
    local tick = getTickCount();

    for vehicle, v in pairs(vehiclesBeingLoaded) do 
        -- iprint(v.added + v.duration , tick)
        if (v.added + v.duration > tick) then 
            local value = math.abs(v.value % 200 - 100);
            local alpha = interpolateBetween(200, 0, 0, 50, 0, 0, value / 100, "InOutQuad");

            setElementAlpha(vehicle, alpha);
            v.value = v.value + (0.25 * delta);
            proceeded = proceeded + 1;
        else 
            setElementAlpha(vehicle, 255);
            setVehicleCollidable(vehicle, true);
            vehiclesBeingLoaded[vehicle] = nil;
        end 
    end 

    if (proceeded == 0) then 
        vehiclesLoadRenderActive = false;
        removeEventHandler('onClientPreRender', root, rootPreRender);
    end 
end 

function emitVehicleLoadEffect(vehicle, duration)
    if (
        not isElement(vehicle) or 
        not isElementStreamedIn(vehicle) or 
        vehiclesBeingLoaded[vehicle]
    ) then 
        return false;
    end 

    local duration = duration or 1000;
    setVehicleCollidable(vehicle, false);
    vehiclesBeingLoaded[vehicle] = { added = getTickCount(), duration = duration, value = 0 };

    if (not vehiclesLoadRenderActive) then 
        vehiclesLoadRenderActive = true;
        addEventHandler('onClientPreRender', root, rootPreRender);
    end 
end 
addEvent('emitVehicleLoadEffect', true);
addEventHandler('emitVehicleLoadEffect', root, emitVehicleLoadEffect);