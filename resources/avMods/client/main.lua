local AllocatedModelIds = {}; -- { [key: number]: { type: 'vehicle' | 'ped' } }[]
local VehicleMods = {
    -- [modelId] = "notcached" | "disabled" | "enabled",
};

addEventHandler('onClientFileDownloadComplete', root, function(fileName, success, requestResource)
    if (string.find(fileName, 'client/assets/vehicles/')) then 
        local modelName = fileName:match("[^/]+$"):gsub('.txd', ''):gsub('.dff', '')
        local modelId = getVehicleModelFromName(modelName);

        if (modelId) then 
            if (
                fileExists("client/assets/vehicles/" .. modelName .. ".txd") and 
                fileExists("client/assets/vehicles/" .. modelName .. ".dff")
            ) then 
                engineImportTXD(
                    engineLoadTXD("client/assets/vehicles/" .. modelName .. ".txd"), 
                    modelId
                );
                engineReplaceModel(
                    engineLoadDFF("client/assets/vehicles/" .. modelName .. ".dff"), 
                    modelId
                );
            end 
        end 
    end 
end);

local replacedObjectIds = {};

addEventHandler("onClientResourceStart", resourceRoot, function()
    engineSetAsynchronousLoading(true, false);

    local vehicles = 0;
    local skins = 0;
    local objects = 0;
    local collections = 0;

    local vehicle_mods = getVehicleModsState();
    VehicleMods = vehicle_mods;

    -- Járművek
    for id, state in pairs(VehicleMods) do 
        local vehicle = config.mods.vehicles[id];

        if (vehicle and state == "enabled") then 
            local modelId = id;
            if (not getVehicleNameFromModel(modelId)) then 
                modelId = engineRequestModel("vehicle", 400);
            end 

            if (not AllocatedModelIds[modelId]) then 
                AllocatedModelIds[modelId] = { type = 'vehicle' };

                local filePath = "client/assets/vehicles/" .. ((vehicle.category and vehicle.category ~= "") and (vehicle.category .. "/") or "") .. vehicle.fileName;

                if (
                    fileExists(filePath .. ".txd") and 
                    fileExists(filePath .. ".dff")
                ) then 
                    engineImportTXD(engineLoadTXD(filePath .. ".txd"), modelId);
                    engineReplaceModel(engineLoadDFF(filePath .. ".dff"), modelId);
                else
                    downloadFile(filePath .. ".txd");
                    downloadFile(filePath .. ".dff");
                end 
                
                vehicles = vehicles + 1;
            else 
                print(modelId .. ' mar allocatelve van.');
            end 
        end 
    end 

    -- Skinek
    for i,v in ipairs(config.mods.skins) do 
        engineImportTXD(engineLoadTXD("client/assets/skins/" .. v.file .. ".txd"), v.id);
        engineReplaceModel(engineLoadDFF("client/assets/skins/" .. v.file .. ".dff"), v.id);
        skins = skins + 1;
    end 

    -- Objectek
    for _, collection in ipairs(config.mods.objects) do 
        local path = "client/assets/objects/" .. collection.category .. "/" .. collection.folder .. "/";

        if (collection.files) then 
            for _, object in ipairs(collection.files) do 
                local errorOccured = false;

                if (replacedObjectIds[object.id]) then
                    iprint('Object id ' .. object.id .. ' mar fel van hasznalva, kerlek adj meg mast ' .. collection.name .. ' nevu kollekcional.');
                else
                    replacedObjectIds[object.id] = true;

                    if (object.collision) then 
                        engineReplaceCOL(engineLoadCOL(path .. object.collision .. ".col"), object.id);
                    elseif (not object.noCOL) then 
                        local isFileExists = fileExists(path .. object.fileName .. ".col");

                        if (isFileExists) then 
                            engineReplaceCOL(engineLoadCOL(path .. object.fileName .. ".col"), object.id);
                        elseif (not isFileExists and config.print_errors) then 
                            outputDebugString(collection.name .. " collectionhoz tartozo " .. object.fileName .. ".col nem letezik vagy nincs megadva a meta.xml-ben.", 1);
                            errorOccured = true;
                        end 
                    end 
                    
                    if (not errorOccured and object.texture) then 
                        engineImportTXD(engineLoadTXD(path .. object.texture .. ".txd"), object.id);
                    elseif (not errorOccured and not object.noTXD) then 
                        local isFileExists = fileExists(path .. object.fileName .. ".txd");

                        if (isFileExists) then 
                            engineImportTXD(engineLoadTXD(path .. object.fileName .. ".txd"), object.id);
                        elseif (not isFileExists and config.print_errors) then 
                            outputDebugString(collection.name .. " collectionhoz tartozo " .. object.fileName .. ".txd nem letezik vagy nincs megadva a meta.xml-ben.", 1);
                            errorOccured = true;
                        end 
                    end 

                    if (not errorOccured and object.model) then 
                        engineReplaceModel(engineLoadDFF(path .. object.model .. ".dff"), object.id);
                    elseif (not errorOccured and not object.noDFF) then 
                        local isFileExists = fileExists(path .. object.fileName .. ".dff");
                        if (isFileExists) then 
                            engineReplaceModel(
                                engineLoadDFF(path .. object.fileName .. ".dff"), 
                                object.id, 
                                (object.allow_transparency ~= nil) and object.allow_transparency or false
                            );
                        elseif (not isFileExists and config.print_errors) then 
                            outputDebugString(collection.name .. " collectionhoz tartozo " .. object.fileName .. ".dff nem letezik vagy nincs megadva a meta.xml-ben.", 1);
                        end 

                        objects = objects + 1;
                    end 

                    engineSetModelLODDistance(object.id, (object.lod_distance) and object.lod_distance or 300);
                end                  
            end 
        end

        if (
            config.print_details and 
            config.print_loaded_collections
        ) then 
            outputDebugString("Object kollekcio " .. collection.name .. " betoltve.", 3);
        end 

        collections = collections + 1;
    end 

    replacedObjectIds = nil;

    if (config.print_details) then 
        outputDebugString("Betöltve összesen " .. vehicles .. " jármű mod.", 3);
        outputDebugString("Betöltve összesen " .. skins .. " skin mod.", 3);
        outputDebugString("Betöltve összesen " .. objects .. " object model.", 3);
        outputDebugString("Betöltve összesen " .. collections .. " map collection.", 3);
        outputDebugString("Custom modellek száma: " .. (vehicles + skins + objects), 3);
    end
end);

addEventHandler("onClientResourceStop", resourceRoot, function()
    -- Járművek
    for id, value in pairs(config.mods.vehicles) do 
        if (value.loadByDefault) then 
            engineRestoreModel(id);
        end 
    end 

    -- Skinek
    for i,v in ipairs(config.mods.skins) do 
        engineRestoreModel(v.id)
    end 

    -- Objectek
    for _, collection in ipairs(config.mods.objects) do 
        local path = "client/assets/objects/" .. collection.category .. "/" .. collection.folder .. "/";

        if (collection.files) then 
            for _, object in ipairs(collection.files) do 
                local errorOccured = false;

                if (object.collision) then 
                    engineRestoreCOL(object.id)
                elseif (not object.noCOL) then 
                    local isFileExists = fileExists(path .. object.fileName .. ".col");
                    if (isFileExists) then 
                        engineRestoreCOL(object.id)
                    end 
                end 

                if (not errorOccured and not object.noDFF) then 
                    local isFileExists = fileExists(path .. object.fileName .. ".dff");
                    if (isFileExists) then 
                        engineRestoreModel(object.id)
                    end 
                end 
            end 
        end
    end 
end);

function getVehicleModsState() --: { model: number, state: "notcached" | "disabled" | "enabled" }[]
    local vehicles = {};

    if (not fileExists("mods.xml")) then 
        local xml = xmlCreateFile("mods.xml", "mods");

        for id, vehicle in pairs(config.mods.vehicles) do 
            id = tonumber(id);
            
            if (not id) then 
                local node = xmlCreateChild(xml, "entry");

                xmlNodeSetAttribute(node, "id", id);
                xmlNodeSetAttribute(node, "state", vehicle.default_state);

                vehicles[tonumber(id)] = vehicle.default_state;
            end
        end 

        xmlSaveFile(xml);
    else 
        local xml = xmlLoadFile("mods.xml");

        for id, vehicle in pairs(config.mods.vehicles) do 
            local node = getEntryFromChildById(xml, id);

            if (not node) then
                node = xmlCreateChild(xml, "entry");

                xmlNodeSetAttribute(node, "id", id);
                xmlNodeSetAttribute(node, "state", vehicle.default_state);

                vehicles[tonumber(id)] = vehicle.default_state;
            else 
                local attr = xmlNodeGetAttributes(node);

                if (tonumber(attr.id)) then 
                    vehicles[tonumber(attr.id)] = attr.state;
                end 
            end
        end 
    end 

    return vehicles;
end 

function getEntryFromChildById(child, id)
    local node = xmlNodeGetChildren(child, 0);

    for i = 0, 9999 do 
        local node = xmlNodeGetChildren(child, i);

        if (not node) then
            break;
        end 

        local attributes = xmlNodeGetAttributes(node);

        if (
            attributes and 
            tonumber(attributes.id) and 
            tonumber(attributes.id) == id
        ) then 
            return node;
        end 
    end 

    return false;
end 

table.length = function(tbl)
    local length = 0;

    for _ in pairs(tbl) do 
        length = length + 1;
    end 

    return length;
end

-- Nem, nem see xd
-- addEventHandler("onClientElementStreamIn", root, function()
--     local data = config.mods.vehicles[getElementModel(source)];
--     if (getElementType(source) == "vehicle" and data and data.component) then 
--         setVehicleComponentVisible(source, data.component, false);
--     end 
-- end);

addEventHandler('onClientResourceStop', resourceRoot, function()
    for modelId, v in ipairs(AllocatedModelIds) do 
        engineFreeModel(modelId);
    end 
end);