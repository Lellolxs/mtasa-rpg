--local Admin = exports.sarp_admin;

local acceptedInteriorCategories = {
    house = true, 
    garage = true, 
    government = true, 
    business = true
};

local propertySuffixes = {
    house = 'Ház',
    garage = 'Garázs',
    government = 'Hivatal',
    business = 'Biznisz',
};

local propertyCategories = { 'house', 'garage', 'government', 'business' };

addEvent("onPlayerEmitCommand:createinterior", false);
addEventHandler('onPlayerEmitCommand:createinterior', root, function(player, id, type, price, name)
    if (not DefaultInteriors[id]) then 
        return outputChatBox(
            Core:getServerPrefix('error', 'Interior') .. " Nem létezik interior belső " .. id .. ".", 
            player, 255, 255, 255, true
        );
    end 

    local x, y, z = getElementPosition(player);
    local int, dim = getElementInterior(player), getElementDimension(player);

    local dbId = getLowestFreeInteriorId();

    if (not dbId) then 
        return outputChatBox(
            Core:getServerPrefix('error', 'Interior') .. " Lol elfogyott a szabad interior id", 
            player, 255, 255, 255, true
        );
    end

    iprint('csa1');

    dbQuery(
        function(qh)
            local _, insertId = dbPoll(qh, 100);
            if (insertId) then 
                dbQuery(
                    function(qh)
                        local result = dbPoll(qh, 100);
                        if (result) then 
                            LoadInterior(result[1] and result[1] or result); -- nemtudom miert, de igymarad kurvaanyad
                        end 
                    end, Database, 
                    "SELECT * FROM properties WHERE id = ?", insertId
                );
            end 
        end, Database, 
        "INSERT INTO properties (id, name, type, category, interior, entrace, price) VALUES (?, ?, ?, ?, ?, ?, ?)", 
        dbId, name, 'default', type, id, toJSON({ x = x, y = y, z = z, interior = int, dimension = dim }), price
    );
end);
Admin:Command('createinterior',{required={admin=9},args={{type='number',name="Interior belseje"},{type='string',name="Típus ("..table.concat(propertyCategories,', ')..")",values=propertyCategories},{type='number',name="Ár",min=1},{type='text',name="Neve"}}})

addEvent("onPlayerEmitCommand:createcustominterior", false);
addEventHandler('onPlayerEmitCommand:createcustominterior', root, function(player, size, type, price, ...)
    local x, y, z = getElementPosition(player);
    local int, dim = getElementInterior(player), getElementDimension(player);

    local dbId = getLowestFreeInteriorId();
            
    if (not dbId) then 
        return outputChatBox(
            Core:getServerPrefix('error', 'Interior') .. " Lol elfogyott a szabad interior id", 
            player, 255, 255, 255, true
        );
    end 
            
    local default_build_data = {
        floor = {}, 
        entrace = { wall = math.floor(size / 2), type = 0 }, 
        ceiling = {}, 
        walls = {},
    };

    dbQuery(
        function(qh)
            local _, insertId = dbPoll(qh, 100);
            if (insertId) then 
                dbQuery(
                    function(qh)
                        local result = dbPoll(qh, 100);
                        if (result and result[1]) then 
                            LoadInterior(result[1]);
                        end 
                    end, Database, 
                    "SELECT * FROM properties WHERE id = ?", insertId
                );
            end 
        end, Database, 
        "INSERT INTO properties (id, name, type, category, entrace, price, size, build_data) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", 
        dbId, name, 'custom', type, toJSON({ x = x, y = y, z = z, interior = int, dimension = dim }), price, size, toJSON(default_build_data)
    );
end);
Admin:Command('createcustominterior',{required={admin=9},args={{type='number',name='Méret (1-10)',min=1,max=10},{type='string',name="Típus ("..table.concat(propertyCategories,', ')..")",values=propertyCategories},{type='number',name="Ár",min=1},{type='text',name='Neve'}}})

addEvent("onPlayerEmitCommand:destroyinterior", false);
addEventHandler('onPlayerEmitCommand:destroyinterior', root, function(player, interior)
    local x, y, z = getElementPosition(interior.entrace);
    
    for _, player in ipairs(getElementsByType('player')) do 
        if (
            getElementDimension(player) == getElementDimension(interior.exit) and 
            getElementInterior(player) == getElementInterior(interior.exit)
        ) then 
            setElementInterior(player, getElementInterior(interior.entrace));
            setElementDimension(player, getElementDimension(interior.entrace));
            setElementPosition(player, x, y, z);
        end 
    end 
    
    dbExec(Database, "DELETE FROM properties WHERE id = ?", interior.id);
    UnloadInterior(interior.id);
end);
Admin:Command('destroyinterior',{required={admin=9},args={{type='interior'}},alias={"delinterior"}})

addEvent("onPlayerEmitCommand:setinteriorid", false);
addEventHandler('onPlayerEmitCommand:setinteriorid', root, function(player, interior, newInteriorId)
    local newInterior = DefaultInteriors[newInteriorId];

    iprint('fasz', player, interior, newInteriorId)

    if (not newInterior) then 
        return outputChatBox(
            Core:getServerPrefix('error', 'Interior') .. " Interior belső id " .. newInteriorId .. " nem létezik.", 
            player, 255, 255, 255, true
        );
    end 

    iprint('fasz2');

    if (interior.type ~= 'default') then 
        return outputErrorText('Custom interior id-jét nem lehet megváltoztatni.');
    end 

    iprint('fasz3');

    local x, y, z = newInterior.x, newInterior.y, newInterior.z;
    local int = newInterior.interior;
            
    for _, playerInInterior in ipairs(getElementsByType('player')) do 
        iprint('fasz4', type(playerInInterior), playerInInterior);
        if (
            getElementDimension(playerInInterior) == getElementDimension(interior.exit) and 
            getElementInterior(playerInInterior) == getElementInterior(interior.exit)
        ) then 
            iprint('fasz5');
            setElementInterior(playerInInterior, int);
            setElementPosition(playerInInterior, x, y, z);
        end 
    end 
            
    setElementPosition(interior.exit, x, y, z);
    setElementInterior(interior.exit, int);
            
    dbExec(Database, "UPDATE properties SET interior = ? WHERE id = ?", newInteriorId, interior.id);
    Admin:outputToAdmins(Admin:getPlayerAdminName(player) .. " megváltoztatta interior " .. interior.id .. " belsejét erre: " .. newInteriorId, 1);
end);
Admin:Command('setinteriorid',{required={admin=9},args={{type='interior'},{type='number',name="Új interior belső"}}});

addEvent("onPlayerEmitCommand:setinteriorname", false);
addEventHandler('onPlayerEmitCommand:setinteriorname', root, function(player, interior, newName)
    interior.name = newName;
    dbExec(Database, "UPDATE properties SET name = ? WHERE id = ?", newName, interior.id);
    Admin:outputToAdmins(Admin:getPlayerAdminName(player) .. " megváltoztatta interior " .. interior.id .. " nevét erre: " .. newName, 1);
end);
Admin:Command('setinteriorname',{required={admin=9},args={{type='interior'},{type='text',name="Új név"}}});