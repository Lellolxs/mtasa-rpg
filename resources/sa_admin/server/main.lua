Core = exports.sa_core;
Database = Core:getDatabase();
Colors = Core:getColors();

loadstring(Core:require({ }))();

-- Az osszes beirt serialnak teljes hozzaferese van az osszes parancshoz.
Sudoers = {
    ['01F3C54CEF90AFB6FEE851E6AEA63492'] = "szkiddaj",
    ['8006EB3EC09B840C86CF8C028BA064B3'] = "zol1",
    ['F3CC810EBBD9521110CEE17D97FC3F13'] = "advil",
    ['D0236876BEEAEDA42C7C6B69D974FFB4'] = 'lamar',
    ['EC1E1D3F44AD17FC80B4E76B808C88A1'] = 'Torso',
};

addEventHandler('onResourceStart', root, function(resource)
    if (getResourceName(resource) == 'sa_core') then 
        Core = exports.sa_core;
        Database = Core:getDatabase();
        Colors = Core:getColors();
    end 
end);

-- setTimer(executeCommandHandler, 500, 1, 'ah', getRandomPlayer())