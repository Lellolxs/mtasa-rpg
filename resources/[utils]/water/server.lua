local Waters = {};

addEvent("water:pushWater", true);
addEventHandler("water:pushWater", root, function(waters)
    for i,v in ipairs(waters) do 
        table.insert(Waters, v);
        createWater(unpack(v));
    end 
end);

addEventHandler("onResourceStart", resourceRoot, function()
    if (fileExists("waters.json")) then 
        local file = fileOpen("waters.json");

        Waters = fromJSON( fileRead( file, fileGetSize(file) ) );

        fileClose(file);
        iprint(Waters);
    end 
end);

addEventHandler("onResourceStop", resourceRoot, function()
    if (fileExists("waters.json")) then 
        fileDelete("waters.json");
    end 

    fileCreate("waters.json");
    local file = fileOpen("waters.json");
    if (not file) then 
        outputDebugString("Failed to load waters.json", 1);
        return;
    end

    fileWrite(file, toJSON(Waters));
end);