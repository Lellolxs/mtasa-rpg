Core = exports.sa_core;

loadstring(Core:require({ "Rectangle", "Switch" }))();

Elements = {};

function mount(id, settings)
    if (not id or type(id) ~= 'string') then 
        return false;
    end 

    if (not Elements[id]) then 
        Elements[id] = {
            label = settings.label, 

            sourceResource = (sourceResource or getThisResource()), 
            sourceResourceRoot = (sourceResourceRoot or root),

            position = settings.position,
            size = settings.size, 
            sizable = (settings.sizable or false),

            minSize = (settings.minSize or settings.size),
            maxSize = (settings.maxSize or settings.size),

            visible = (settings.visible or true),

            options = (type(settings.options) == 'table') and { } or nil,
        };

        for i,v in ipairs(settings.options) do 
            table.insert(Elements[id].options, {
                id = v.id, 
                label = v.label, 
                type = v.type, 
                value = (v.default ~= nil) and v.default or false
            });
        end 

        return true;
    else 
        local element = Elements[id];

        element.sourceResource = (sourceResource or getThisResource());
        element.sourceResourceRoot = (sourceResourceRoot or root);

        element.label = (element.label ~= settings.label) and settings.label or element.label;

        if (type(settings.table) == 'table') then 
            for i,v in ipairs(settings.options) do 
                local optionIndex = table.findIndex(element.options, function(x) return (x.id == v.id); end);

                if (not optionIndex or not element.options[optionIndex]) then 
                    table.insert(element.options, {
                        id = v.id, 
                        label = v.label, 
                        type = v.type, 
                        value = (v.default ~= nil) and v.default or false
                    });
                else 
                    element.options[optionIndex].label = v.label;
                end 
            end 
        end 
    end 

    return false;
end 

function getInterfaceElementOptionValue(elementId, optionId)
    if (
        not elementId or 
        not Elements[elementId] or 
        not type(Elements[elementId].options) ~= 'table'
    ) then 
        return false;
    end 

    local option = table.find(Elements[elementId].options, function(x) return (x.id == optionId) end);
    
    return (option ~= nil and option.value or false);
end 

function Save()
    local file;
    if (fileExists("save.json")) then 
        fileDelete("save.json");

        file = fileCreate("save.json");
        fileFlush(file);
    end 
    
    local saveData = table.copy(Elements);
    for id, v in pairs(saveData) do 
        v.position = { x = v.position.x, y = v.position.y };
        v.size = { x = v.size.x, y = v.size.y };
        v.minSize = { x = v.minSize.x, y = v.minSize.y };
        v.maxSize = { x = v.maxSize.x, y = v.maxSize.y };
        v.sourceResource = getResourceName(v.sourceResource);
        v.sourceResourceRoot = nil;
    end 

    fileWrite(file, toJSON(saveData));
    fileFlush(file);
    fileClose(file);
end 
addEventHandler('onClientResourceStop', resourceRoot, Save);

addEventHandler('onClientResourceStart', resourceRoot, function()
    local file;
    if (not fileExists("save.json")) then 
        file = fileCreate("save.json");
        fileWrite(file, toJSON({ }));
        fileFlush(file);
    else 
        file = fileOpen("save.json");
    end 

    local saveData = fromJSON(fileRead(file, fileGetSize(file)));

    for id, v in pairs(saveData) do 
        v.position = { x = v.position.x, y = v.position.y };
        v.size = { x = v.size.x, y = v.size.y };
        v.minSize = { x = v.minSize.x, y = v.minSize.y };
        v.maxSize = { x = v.maxSize.x, y = v.maxSize.y };
        v.sourceResource = getResourceFromName(v.sourceResource);
        v.sourceResourceRoot = getResourceDynamicElementRoot(v.sourceResource);
    end 

    Elements = saveData;
    fileClose(file);
end);