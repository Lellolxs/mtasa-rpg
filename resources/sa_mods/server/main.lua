local EncodeSuffix = ".gatya";
local SecretKeys = {};

function encodeFile(path, secret)
    if (not fileExists(path)) then 
        return false;
    end 

    local oFile = fileOpen(path);
    if (not oFile) then 
        return false;
    end 

    local content = fileRead(oFile, fileGetSize(oFile));
    iprint('gecisfasz', content)
    local encoded, iv = encodeString("tea", content, { key = secret });

    fileClose(oFile);
    fileCreate(path .. EncodeSuffix);

    local tFile = fileOpen(path .. EncodeSuffix);
    fileWrite(tFile, encoded);
    fileFlush(tFile);
    fileClose(tFile);

    return true;
end 

function processNewModels()
    local models = getNewModels();

    local meta = xmlLoadFile("meta.xml");
    local isAnythingChanged = false;

    for modelId, _ in pairs(models.vehicle) do 
        if (
            fileExists("client/assets/vehicle/" .. modelId .. ".txd") and 
            fileExists("client/assets/vehicle/" .. modelId .. ".dff")
        ) then 
            local secret = generateString(16);

            SecretKeys.vehicle[tostring(modelId)] = secret;

            if (
                encodeFile("client/assets/vehicle/" .. modelId .. ".txd", secret) and 
                encodeFile("client/assets/vehicle/" .. modelId .. ".dff", secret)
            ) then 
                for i, node in ipairs(xmlNodeGetChildren(meta)) do 
                    if (xmlNodeGetName(node) == "file") then 
                        local source = xmlNodeGetAttribute(node, "src");
                        if (source:find(modelId .. ".txd")) then
                            xmlNodeSetAttribute(node, "src", "client/assets/vehicle/" .. modelId .. ".txd" .. EncodeSuffix);
                            isAnythingChanged = true;
                        end

                        if (source:find(modelId .. ".dff")) then
                            xmlNodeSetAttribute(node, "src", "client/assets/vehicle/" .. modelId .. ".dff" .. EncodeSuffix);
                            isAnythingChanged = true;
                        end
                    end 
                end 
            end 
        else 
            outputDebugString(modelId .. " id-vel nem letezik jarmumod.", 1);
        end 
    end 

    xmlSaveFile(meta);
    xmlUnloadFile(meta);

    saveSecrets();

    if (isAnythingChanged) then 
        iprint('geci');
        restartResource(getThisResource());
    end 
end 

function getNewModels()
    local models = { ped = {}, vehicle = {}, object = {} };

    local file = xmlLoadFile("meta.xml");
    for i, node in ipairs(xmlNodeGetChildren(file)) do 
        if (xmlNodeGetName(node) == "file") then 
            local source = xmlNodeGetAttribute(node, "src"):gsub("client/assets/", "");
            if (not source:find(EncodeSuffix)) then
                local splitted = split(source, "/");
                local modelId = splitted[2]:gsub(".txd", ""):gsub(".dff", "");

                if (not models[ splitted[1] ][ modelId ]) then 
                    models[ splitted[1] ][ modelId ] = true;
                end 
            end
        end 
    end 

    return models;
end 

function saveSecrets()
    if (fileExists("secrets.json")) then 
        fileDelete("secrets.json");
    end 

    fileCreate("secrets.json");
    local file = fileOpen("secrets.json");

    fileWrite(file, toJSON(SecretKeys));
    fileFlush(file);
    fileClose(file);
end 

local __CharacterSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
function generateString(length)
    local str = "";
    for i = 1, length do
        local num = math.random(1, string.len(__CharacterSet));
        str = str .. string.sub(__CharacterSet, num, num);
    end 
    return str;
end 

addEvent("mods:requireSecretKeys", true);
addEventHandler("mods:requireSecretKeys", resourceRoot, function()
    triggerClientEvent(client, "mods:onClientReceiveDecodeSecret", resourceRoot, SecretKeys);
end);

addEventHandler("onResourceStart", resourceRoot, function()
    local sFile = fileOpen("secrets.json");
    if (not sFile) then 
        return;
    end 

    SecretKeys = fromJSON(fileRead(sFile, fileGetSize(sFile)));
    fileClose(sFile);

    processNewModels();
end);