IsSettingsLoaded = false;
Settings = {
    nametag = {
        show_self = false, 
    },
};

local settingsMiddlewares = {
    nametag = {
        show_self = function(old, new)
            exports.sa_name:setSelfDrawing(new);
            return true;
        end
    },
};

function setSettingValue(category, key, newValue)

    assert(type(category) == 'string', "Expected string at argument 1, got " .. type(category));
    assert(type(key) == 'string', "Expected string at argument 2, got " .. type(key));

    if (Settings[category] == nil) then 
        outputDebugString("Nem letezik a megadott kategoriaval.", 1);
        return nil;
    end

    iprint(category, key, newValue);

    if (
        settingsMiddlewares[category] and 
        settingsMiddlewares[category][key] and 
        settingsMiddlewares[category][key](Settings[category][key], newValue) == false
    ) then 
        return false;
    end 

    Settings[category][key] = newValue;
end 

function getSettingValue(category, key)
    if (not IsSettingsLoaded) then 
        return;
    end 

    assert(type(category) == 'string', "Expected string at argument 1, got " .. type(category));
    assert(type(key) == 'string', "Expected string at argument 2, got " .. type(key));

    if (Settings[category] == nil or Settings[category][key] == nil) then 
        outputDebugString("Nem letezik ezzel a kategoriaval vagy annak kulcsaval ertek.", 1);
        return nil;
    end 

    return Settings[category][key];
end 

addEventHandler('onClientResourceStart', resourceRoot, function()
    -- megfogja azt bebassza az alap kfg-t ha nem talalja
    if (not fileExists("settings.json")) then 
        local file = fileCreate("settings.json");

        fileWrite(file, toJSON(Settings));
        fileFlush(file);
        fileClose(file);

        IsSettingsLoaded = true;

        return;
    end 

    local file = fileOpen("settings.json");
    Settings = fromJSON(fileRead(file, fileGetSize(file)));
    fileClose(file);

    IsSettingsLoaded = true;
end);

addEventHandler('onClientResourceStop', resourceRoot, function()
    if (fileExists("settings.json")) then 
        fileDelete("settings.json");
    end 

    local file = fileCreate("settings.json");
    fileWrite(file, toJSON(Settings, true));
    fileFlush(file);
    fileClose(file);
end);