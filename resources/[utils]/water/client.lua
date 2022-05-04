local WaterQueue = {};
local CachedWaters = {};

local StartPosition = {};
local Active = false;
local WaterElement;

local DefaultPadding = 2;
local DefaultHeight = 0;

function rootRender()
    local x, y, z = getElementPosition(localPlayer);
    local sX, sY, sZ = unpack(StartPosition);

    setWaterVertexPosition(
        WaterElement, 1, 
        (x > sX - DefaultPadding) and (sX - DefaultPadding) or x, 
        (y > sY - DefaultPadding) and (sY - DefaultPadding) or y, 
        DefaultHeight
    );
    setWaterVertexPosition(
        WaterElement, 2, sX, 
        (y > sY - DefaultPadding) and (sY - DefaultPadding) or y, 
        DefaultHeight
    );
    setWaterVertexPosition(
        WaterElement, 3, 
        (x > sX - DefaultPadding) and (sX - DefaultPadding) or x, 
        sY, DefaultHeight
    );
    setWaterVertexPosition(WaterElement, 4, sX, sY, DefaultHeight);
end 

function pushQueue()
    triggerServerEvent("water:pushWater", root, WaterQueue);

    for _, water in ipairs(CachedWaters) do 
        if (isElement(water)) then 
            destroyElement(water);
        end 
    end 

    WaterQueue = { };
end 

function saveCurrent()
    if (Active) then 
        local newWater = {};

        for i = 1, 4 do 
            local pos = { getWaterVertexPosition(WaterElement, i) };
            for axis = 1, 3 do table.insert(newWater, pos[axis]); end 
        end 

        table.insert(WaterQueue, newWater);
        table.insert(CachedWaters, WaterElement);

        WaterElement = nil;
        StartPosition = nil;
        removeEventHandler("onClientPreRender", root, rootRender);
        Active = false;
    end 
end 

function toggleEdit()
    if (not Active) then 
        local x, y, z = getElementPosition(localPlayer);

        WaterElement = createWater(
            x - DefaultPadding, y - DefaultPadding, DefaultHeight,
            x, y - DefaultPadding, DefaultHeight,
            x - DefaultPadding, y, DefaultHeight,
            x, y, DefaultHeight, 
            false
        );

        StartPosition = { x, y, z };

        addEventHandler("onClientPreRender", root, rootRender);
        Active = true;
    else
        removeEventHandler("onClientPreRender", root, rootRender);

        if (isElement(WaterElement)) then 
            destroyElement(WaterElement);
        end 

        Active = false;
    end 
end 

bindKey("u", "down", toggleEdit);
bindKey("l", "down", saveCurrent);
bindKey("j", "down", pushQueue);

outputChatBox("csa vizcsinalo gombjai");
outputChatBox("u - letrehozas");
outputChatBox("l - jelenleg modositott mentese ideiglenesen");
outputChatBox("j - minden modositas kozvetitese a szervernek mentesre.");

-- 
-- Dam's water height
-- 

setWaterLevel(0);

local __HardcodedWaterHeights = {
    -- Dam

    Vector3(-1129.2822265625, 2783.6826171875, 40), 
    Vector3(-1063.9921875, 2655.1279296875, 40), 
    Vector3(-926.0615234375, 2351.021484375, 40), 
    Vector3(-980.8857421875, 2633.4140625, 40), 
    Vector3(-967.4697265625, 2472.11328125, 40), 
    Vector3(-507.6484375, 2189.1474609375, 40), 
    Vector3(-565.015625, 2292.98046875, 40), 
    Vector3(-559.66015625, 2111.619140625, 40), 
    Vector3(-532.19140625, 2049.7568359375, 40), 
    Vector3(-526.400390625, 2028.3671875, 40), 
    Vector3(-564.4970703125, 2331.576171875, 40), 
    Vector3(-855.505859375, 2082.515625, 40), 
    Vector3(-944.1962890625, 2212.712890625, 40), 
    Vector3(-1041.5185546875, 2206.5849609375, 40), 
    Vector3(-1097.240234375, 2179.4765625, 40), 
    Vector3(-831.216796875, 2087.802734375, 40), 
    Vector3(-1238.025390625, 2137.9931640625, 40), 
    Vector3(-1356.8408203125, 2116.1748046875, 40), 

    -- Richmond pools
    Vector3(1280.5146484375, -806.1376953125, 87), 
    Vector3(1283.9423828125, -775.373046875, 40), 
    Vector3(1091.802734375, -672.650390625, 112.25), 
    Vector3(511.947265625, -1107.318359375, 78.5), 
    Vector3(193.0712890625, -1231.029296875, 77), 
    Vector3(228.1552734375, -1188.19921875, 74), 
    Vector3(228.5947265625, -1174.5126953125, 74), 
};

for _, v in ipairs(__HardcodedWaterHeights) do 
    setWaterLevel(v.x, v.y, 0, v.z);
end 