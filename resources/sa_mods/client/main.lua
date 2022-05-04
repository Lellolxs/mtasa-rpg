addEvent("mods:onClientReceiveDecodeSecret", true);
addEventHandler("mods:onClientReceiveDecodeSecret", resourceRoot, function(secrets)
    local vehicles = exports.sa_vehicle:getVehicleList();
    for id, v in pairs(vehicles) do 
        if (
            fileExists("client/assets/vehicle/" .. id .. ".dff.gatya") and 
            fileExists("client/assets/vehicle/" .. id .. ".txd.gatya")
        ) then 

            iprint('uwu titkos', secrets.vehicle[tostring(id)], string.len(secrets.vehicle[tostring(id)]));

            -- 
            -- TXD
            -- 

            local txdFile = fileOpen("client/assets/vehicle/" .. id .. ".txd.gatya");
            if (not txdFile) then 
                iprint("Failed to load (vehicle) id " .. id .. " textures.");
                return;
            end 

            local txdContent = fileRead(txdFile, fileGetSize(txdFile));
            iprint("owo txd", txdContent);
            engineImportTXD(engineLoadTXD(decodeString("tea", txdContent, { key = secrets.vehicle[tostring(id)] })), id);

            -- 
            -- DFF
            -- 

            local dffFile = fileOpen("client/assets/vehicle/" .. id .. ".dff.gatya");
            if (not dffFile) then 
                iprint("Failed to load (vehicle) id " .. id .. " models.");
                return;
            end 

            local dffContent = fileRead(dffFile, fileGetSize(dffFile));
            iprint("owo dff", dffContent);
            engineReplaceModel(engineLoadDFF(decodeString("tea", dffContent, { key = secrets.vehicle[tostring(id)] })), id);
        end 
    end 
end);

addEventHandler("onClientResourceStart", resourceRoot, function()
    triggerServerEvent("mods:requireSecretKeys", resourceRoot);
end);