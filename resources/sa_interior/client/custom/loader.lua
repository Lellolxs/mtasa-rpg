function loadModel(path, id)
    if (fileExists(path .. '.txd')) then 
        engineImportTXD(engineLoadTXD(path .. '.txd', true), id);
    end 

    if (fileExists(path .. '.dff')) then 
        engineReplaceModel(engineLoadDFF(path .. '.dff', 0), id);
    end 

    if (fileExists(path .. '.col')) then 
        engineReplaceCOL(engineLoadCOL(path .. '.col'), id);
    end 

    engineSetModelLODDistance(id, 1000);
end