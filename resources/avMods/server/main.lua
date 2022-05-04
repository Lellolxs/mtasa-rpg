addEventHandler('onResourceStart', resourceRoot, function()
    for _, collection in ipairs(config.mods.objects) do 
        if (collection.resource) then
            if (type(collection.resource) == 'string') then  
                local resourceElement = getResourceFromName(collection.resource);
                if (resourceElement and getResourceState(resourceElement) == 'loaded' and startResource(resourceElement)) then 
                    if (config.print_details) then 
                        print(collection.name .. '-hoz/-hez tartozó map elindítva.');
                    end 
                elseif (config.print_errors) then
                    print('A ' .. collection.name .. '-hoz/-hez tartozó map resource elindítása sikertelen.');
                end 
            elseif (type(collection.resource) == 'table') then 
                for _, res in ipairs(collection.resource) do 
                    local resourceElement = getResourceFromName(res);
                    if (resourceElement and  getResourceState(resourceElement) == 'loaded' and startResource(resourceElement)) then 
                        if (config.print_details) then 
                            print(collection.name .. '-hoz/-hez tartozó map elindítva.');
                        end 
                    elseif (config.print_errors) then
                        print('A ' .. collection.name .. '-hoz/-hez tartozó map resource elindítása sikertelen.');
                    end 
                end
            end
        end 
    end 
end);

