function setInterior(player, targetPlayer, interior)
    setElementInterior(targetPlayer, interior);
end 
Command("setint",{description="Játékos interiorjának beállítása",required={admin=5,off_admin=8},args={{type="player"},{type="number",name='Interior',min=0,max=255}},alias={"setinterior"}},setInterior);

function setDimension(player, targetPlayer, dimension)
    setElementDimension(targetPlayer, dimension);
end 
Command("setdim",{description="Játékos dimenziójának beállítása",required={admin=5,off_admin=8},args={{type="player"},{type="number",name='Dimenzió',min=0,max=65535}},alias={"setdimension"}},setDimension);

function outputPosition(player)
    local x, y, z = getElementPosition(player);
    local int, dim = getElementInterior(player), getElementDimension(player);
    local rotZ = select(3, getElementRotation(player))

    outputChatBox(Core:getServerPrefix('server', 'Admin') .. ' Pozicio: ' .. x .. ', ' .. y .. ', ' .. z, player);
    outputChatBox(Core:getServerPrefix('server', 'Admin') .. ' Interior: ' .. int, player);
    outputChatBox(Core:getServerPrefix('server', 'Admin') .. ' Dimenzio: ' .. dim, player);
    outputChatBox(Core:getServerPrefix('server', 'Admin') .. ' Rotation: ' .. rotZ, player);
end 
Command("getpos",{description="Pozíció lekérése",required={admin=8}},outputPosition);

function copyPosition(player)
    local x, y, z = getElementPosition(player);

    triggerClientEvent(player, 'admin:copyText', player, x .. ', ' .. y .. ', ' .. z);
    outputChatBox(Core:getServerPrefix('server', 'Admin') .. ' A pozíciód vágólapra került.', player);
end 
Command("copypos",{description="Pozícióid vágólapra másolása",required={admin=8}},copyPosition);

function teleportToCoordinate(player, x, y, z)
    setElementPosition(player, x, y, z);
end 
Command("tppos",{description = "Adott koordinátára teleportálás",required={admin=8},args={{type='number',name="X"},{type='number',name="Y"},{type='number',name='Z'}}},teleportToCoordinate);

function createTemporaryVehicle(player, model)
    local x, y, z = getElementPosition(player);
    local int, dim = getElementInterior(player), getElementDimension(player);

    local vehicle = createVehicle(model, x, y, z);
    if (vehicle) then 
        setElementInterior(vehicle, int);
        setElementDimension(vehicle, dim);

        warpPedIntoVehicle(player, vehicle);
    end 
end 
Command("tempveh",{description="létrehoz egy ideiglenes járművet melléd.",required={admin=11},args={{type='number',name="Model"}}},createTemporaryVehicle);

local __ActiveUsageWindowUsers = {};
function toggleUsageWindow(player)
    local usageResource = getResourceFromName("rescpu");
    if (usageResource and getResourceState(usageResource) == "stopped") then 
        startResource(usageResource);
    end 

    if (not __ActiveUsageWindowUsers[player]) then 
        __ActiveUsageWindowUsers[player] = true;
        triggerClientEvent(player, "rescpu:toggle", root, true);
        outputChatBox(Core:getServerPrefix('server', 'Admin') .. 'Resource használat ablak megjelenítve.', player);
    else 
        __ActiveUsageWindowUsers[player] = nil;
        triggerClientEvent(player, "rescpu:toggle", root, false);
        outputChatBox(Core:getServerPrefix('error', 'Admin') .. 'Resource használat ablak eltüntetve.', player);
    end 
end 
Command("usagewindow",{description="megjeleniti a hasznalatablakot.",required={admin=11},args={}},toggleUsageWindow);