--[[

    strela2 -- vege
    strela1 -- kozepso

    strela -- torzs geci

]]

local ModelId = 578;

local Crane = {
    default = {
        -- strela = { position = Vector3(-0.25677061080933, 7.1774821281433, -0.065584897994995), rotation = Vector3(0, 0, 0) },
        -- strela1 = { position = Vector3(0, 0, 0), rotation = Vector3(0, 0, 0) },
        -- strela2 = { position = Vector3(0, 0, 0), rotation = Vector3(0, 0, 0) },
    },
};

addEventHandler('onClientElementStreamIn', root, function()
    if (
        getElementType(source) == 'vehicle' and 
        getElementModel(source) == ModelId
    ) then 
        for component, v in pairs(Crane.default) do 
            setVehicleComponentPosition(source, component, v.position.x, v.position.y, v.position.z, "parent");
            setVehicleComponentRotation(source, component, v.rotation.x, v.rotation.y, v.rotation.z, "parent");
        end 
    end 
end);

addEventHandler("onClientResourceStart", resourceRoot, function()
    iprint("1eeee")
    for _, vehicle in ipairs(getElementsByType('vehicle', _, true)) do 
        iprint("2eeee")
        if (getElementModel(vehicle) == ModelId) then 
            iprint("3eeee")
            for component, v in pairs(Crane.default) do 
                setVehicleComponentPosition(vehicle, component, v.position.x, v.position.y, v.position.z, "parent");
                setVehicleComponentRotation(vehicle, component, v.rotation.x, v.rotation.y, v.rotation.z, "parent");
            end 
        end 
    end 
end);

local excluded = {
    ['hydraulic_dummy'] = true,
    ['hydraulic'] = true,
    ['strelladummy'] = true,
};

addEventHandler ( "onClientRender", root,
function()
	if isPedInVehicle ( localPlayer ) and getPedOccupiedVehicle ( localPlayer ) then
		local veh = getPedOccupiedVehicle ( localPlayer )
        local index = 0;
		for v in pairs ( getVehicleComponents(veh) ) do
            dxDrawText(v, 500, 50 + index * 16);

			local x, y, z = getVehicleComponentPosition ( veh, v, "world" )
            if (
                x and y and z and 
                not excluded[v] and 
                not string.find(v, "wheel") and 
                not string.find(v, "mat_") and 
                not string.find(v, "revl") and 
                not string.find(v, 'osnova') and 
                not string.find(v, "indicator")
            ) then 
                local wx,wy,wz = getScreenFromWorldPosition ( x, y, z )
                if wx and wy then
                    dxDrawText ( v, wx -1, wy -1, 0 -1, 0 -1, tocolor(0,0,0), 1, "default-bold" )
                    dxDrawText ( v, wx +1, wy -1, 0 +1, 0 -1, tocolor(0,0,0), 1, "default-bold" )
                    dxDrawText ( v, wx -1, wy +1, 0 -1, 0 +1, tocolor(0,0,0), 1, "default-bold" )
                    dxDrawText ( v, wx +1, wy +1, 0 +1, 0 +1, tocolor(0,0,0), 1, "default-bold" )
                    dxDrawText ( v, wx, wy, 0, 0, tocolor(0,255,255), 1, "default-bold" )
                end
            end 

            index = index + 1;
		end
	end
end)