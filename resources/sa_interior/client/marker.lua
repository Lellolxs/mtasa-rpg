local StreamedShapes = {};
local markerMaterials = {};

local markerSize = 0.8;

local markerTypes = {
    house = { icon = InteriorIcons.house, color = { 55, 111, 173 } },
    garage = { icon = InteriorIcons.garage, color = { 69, 69, 69 } },
    government = { icon = InteriorIcons.government, color = { 82, 191, 82 } },
    business = { icon = InteriorIcons.business, color = { 230, 214, 76 } },
};

function recacheShapes()
    local x, y, z = getElementPosition(localPlayer);
    local pInt, pDim = getElementInterior(localPlayer), getElementDimension(localPlayer);

    for _, shape in ipairs(getElementsByType('colshape')) do 
        if (
            getElementData(shape, 'isInterior') and 
            pInt == getElementInterior(shape) and 
            pDim == getElementDimension(shape) 
        ) then 
            local sX, sY, sZ = getElementPosition(shape);
            local distance = getDistanceBetweenPoints3D(x, y, z, sX, sY, sZ);
            
            if (distance <= ShapeEnum.stream_distance and not StreamedShapes[shape]) then 
                local r, g, b = unpack(markerTypes[(getElementData(shape, 'category') or 'house')].color);
                local light = exports.dynamic_light:createPointLight(sX, sY, sZ, r, g, b, 0.1, 1.1);
                StreamedShapes[shape] = { value = 0, light = light };
            elseif (distance > ShapeEnum.stream_distance and StreamedShapes[shape]) then 
                exports.dynamic_light:destroyLight(StreamedShapes[shape].light);
                StreamedShapes[shape] = nil;
            end 
        end 
    end 
end 
setTimer(recacheShapes, 250, 0);

addEventHandler(
    'onClientRender', 
    root, 
    function()
        local pX, pY, pZ = getCameraMatrix();

        for shape, v in pairs(StreamedShapes) do 
            local x, y, z = getElementPosition(shape);
            local material = markerMaterials[(getElementData(shape, 'category') or 'house')];

            if (v.value >= 200) then 
                v.value = 0;
            end  

            v.value = v.value + 1;

            local val = math.abs(v.value % 200 - 100);
            local zCoord = interpolateBetween(-0.25, 0, 0, 0.25, 0, 0, val * 0.01, "InOutQuad");

            dxDrawMaterialLine3D(
                x, y, z + markerSize * 0.5 + zCoord, 
                x, y, z - markerSize * 0.5 + zCoord, 
                material, 
                markerSize, tocolor(255, 255, 255, 255), false, 
                pX, pY, pZ
            );
        end 
    end
);

addEventHandler(
    'onClientResourceStart', 
    root, 
    function()
        for type, data in pairs(markerTypes) do 
            local material = dxCreateRenderTarget(500, 500, true);

            dxSetRenderTarget(material);

                local r, g, b = unpack(data.color);
                dxDrawText(data.icon, 0, 0, 500, 250, tocolor(r, g, b, 255), 1, (type == 'garage' or type == 'government') and Fonts.faxl1 or Fonts.faxl2, 'center', 'center');
                dxDrawImage(125, 185, 250, 250, 'client/assets/arrow_'..type..'.png');

            dxSetRenderTarget(nil, true);

            markerMaterials[type] = material;
        end 
    end
);

addEventHandler(
    'onClientResourceStop', 
    root, 
    function()
        for shape, v in pairs(StreamedShapes) do 
            exports.dynamic_light:destroyLight(v.light);
            StreamedShapes[shape] = nil;
        end 
    end
);

addEventHandler(
    'onClientElementDestroy', 
    root, 
    function()
        if (StreamedShapes[source]) then 
            exports.dynamic_light:destroyLight(StreamedShapes[source].light);
            StreamedShapes[source] = nil;
        end 
    end
);