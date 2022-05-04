local Core = exports.sa_core;
local Admin = exports.sa_admin;

loadstring(Core:require({ }))();

-- Ne ezt modositsd...
local allowedSerials = {};

addEventHandler('onPlayerEmitCommand:addserial', root, function(player, serial, name)
    if (allowedSerials[serial]) then 
        return outputChatBox(
            Core:getServerPrefix("error", "Whitelist") "Serial \"" .. serial .. "\" (" .. allowedSerials[serial] .. ") már hozzá van adva a listához.", 
            root, 255, 255, 255, true
        );
    end 

    allowedSerials[serial] = name;
    Admin:outputToAdmins("Serial \"" .. serial .. "\" hozzáadva a whitelisthez " .. Admin:getPlayerAdminName(player) .. " által.", 1);
end);
Admin:Command('addserial',{description='Serial hozzáadása a whitelisthez.',required={admin=11},args={{type='string',name='Serial',min=32,max=32},{type='string',name='Név',min=3,max=24}}})

addEventHandler(
    "onPlayerConnect", 
    root, 
    function(nick, address, _, serial)
        if (not allowedSerials[serial]) then 
            cancelEvent(true, 'csa helo who.ru? ask me for whitelist if i know you. szkiddaj#9391');
            return outputChatBox(
                Core:getServerPrefix("error", "Whitelist") .. nick .. " megpróbált csatlakozni a szerverhez, de nincs hozzáadva a whitelisthez.", 
                root, 255, 255, 255, true
            );
        end 

        outputChatBox(
            Core:getServerPrefix("server", "Whitelist") .. allowedSerials[serial] .. " csatlakozott a szerverre.", 
            root, 255, 255, 255, true
        );
    end
);

addEventHandler(
    'onResourceStart', 
    resourceRoot, 
    function()
        local file = fileOpen('serials.json');

        if (file) then 
            allowedSerials = fromJSON( fileRead( file, fileGetSize(file) ) );
            fileClose(file);
        end 

        for _, player in ipairs(getElementsByType('player')) do 
            if (not allowedSerials[getPlayerSerial(player)]) then 
                local playerName = getPlayerName(player);
                kickPlayer(player, 'Szerver', 'csa helo who.ru? ask me for whitelist if i know you. szkiddaj#9391');
                outputChatBox(
                    Core:getServerPrefix("error", "Whitelist") .. playerName .. " a szerveren tartózkodott, de mivel nem volt hozzáadva a whitelisthez kickelve lett.", 
                    root, 255, 255, 255, true
                );
            end 
        end 
    end
);

addEventHandler(
    'onResourceStart', 
    root, 
    function(resource)
        local resourceName = getResourceName(resource);

        if (resourceName == 'sa_store') then 
            Core = exports.sa_core;
        elseif (resourceName == 'sa_admin') then 
            Admin = exports.sa_admin;
        end
    end
);