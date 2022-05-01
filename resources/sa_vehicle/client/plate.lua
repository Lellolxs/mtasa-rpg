local id = "custom_car_plate";

local StreamedPlates = {};
local shader_src = [[
    texture platert;
    technique TexReplace {
        pass P0 {
            Texture[0] = platert;
        }
    }
]]

local Font = Core:requireFont('opensans-bold', 56);

function applyVehicleCustomPlate(vehicle)
    local rt = dxCreateRenderTarget(350, 60, true);

    dxSetRenderTarget(rt, true);

        dxDrawRectangle(0, 0, 350, 60, 0xffd8d8d8);
        dxDrawText(
            (getVehiclePlateText(vehicle) or ""), 
            0, 0, 350, 60, tocolor(0, 0, 0), 
            1, Font, "center", "center"
        );

    dxSetRenderTarget(nil, true);

    StreamedPlates[vehicle] = dxCreateShader(shader_src);
    dxSetShaderValue(StreamedPlates[vehicle], "platert", rt);
    engineApplyShaderToWorldTexture(StreamedPlates[vehicle], id, vehicle);
end 

addEventHandler('onClientElementStreamIn', root, function()
    if (
        getElementType(source) == 'vehicle' and 
        not StreamedPlates[source]
    ) then 
        applyVehicleCustomPlate(source);
    end 
end);

addEventHandler('onClientElementStreamOut', root, function()
    if (
        getElementType(source) == 'vehicle' and 
        StreamedPlates[source]
    ) then 
        engineRemoveShaderFromWorldTexture(StreamedPlates[vehicle], id, source);
        if (isElement(StreamedPlates[source])) then 
            destroyElement(StreamedPlates[source]);
        end 

        StreamedPlates[source] = nil;
    end 
end);

addEventHandler('onClientResourceStart', resourceRoot, function()
    local platebg = dxCreateShader(shader_src);
    local platetex = dxCreateTexture("client/assets/plate.png", "dxt5");

    dxSetShaderValue(platebg, "platert", platetex);
    engineApplyShaderToWorldTexture(platebg, "plateback*");
end);