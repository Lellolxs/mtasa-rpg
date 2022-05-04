addEventHandler(
    'onClientResourceStart', 
    resourceRoot, 
    function()
        for _, v in ipairs(OBJECT_LIST) do 
            removeWorldModel(v.model, 1.0, v.x, v.y, v.z);
        end 
    end
);