local disabledLogOutputs = {};

local defaultLogSettings = {
    category = 'general', 
};

function addAdminLog(log)
    if (
        not log or 
        type(log) ~= 'table' or 
        not log.action or 
        type(log.action) ~= 'string'
    ) then 
        return;
    end 

    local category = (type(log.category) ~= 'string') and 'admin' or log.category;
    local fields = {
        admin = ((type(log.admin) == 'userdata') and (getElementData(log.admin, 'userId') or nil) or (type(log.admin) == 'number' and log.admin or nil)),
        player = ((type(log.player) == 'userdata') and (getElementData(log.player, 'userId') or nil) or (type(log.player) == 'number' and log.player or nil)),
        vehicle = ((type(log.vehicle) == 'userdata') and (getElementData(log.vehicle, 'id') or nil) or (type(log.vehicle) == 'number' and log.vehicle or nil)),
        interior = log.interior,
        action = log.action, 
        additional = ((type(log.additional) == 'table') and log.additional or { }),
    };

    local query_str = dbPrepareString(
        Database, 
        [[
            INSERT INTO 
                `logs__??` (admin, player, vehicle, interior, action, date, additional)
            VALUES 
                (?, ?, ?, ?, ?, NOW(), ?)
        ]], 
        category, fields.admin, fields.player, 
        fields.vehicle, fields.interior,
        fields.action, toJSON(fields.additional)
    );

    dbExec(Database, query_str);
end 

function changeAdminStat(player, statName, difference)
    local stats = (getElementData(player, 'adminstats') or {});

    if (not stats[statName]) then
        stats[statName] = 0;
    end 

    stats[statName] = stats[statName] + difference;
    setElementData(player, 'adminstats', stats);
end 

function outputToAdmins(message, minLevel, addPrefix)
    local minLevel = (type(minLevel) == 'number') and minLevel or 1;
    local addPrefix = (addPrefix ~= nil) and addPrefix or true;

    for _, player in ipairs(getElementsByType('player')) do 
        if (
            getPlayerAdminLevel(player) > minLevel and 
            not disabledLogOutputs[player]
        ) then 
            outputChatBox(
                ((addPrefix) and Core:getServerPrefix('server', 'Admin') or '') .. message, 
                player
            );
        end 
    end 
end 

function sendNotificationTo(notifyType, notifyText, minLevel)
    local minLevel = (type(minLevel) == "number") and minLevel or 1

    for _, player in ipairs(getElementsByType("player")) do
        if (
            getPlayerAdminLevel(player) > minLevel and
            not disabledLogOutputs[player]
        ) then
            exports.sa_notifications:showNotification(player, notifyType, notifyText)
        end
    end
end

function changeAdminsLogOutputState(admin)
    if (not admin) then 
        return;
    end 

    if (disabledLogOutputs[admin]) then 
        disabledLogOutputs[admin] = nil;
    else 
        disabledLogOutputs[admin] = true;
    end 

    return (disabledLogOutputs[admin] ~= nil);
end 

addEventHandler('onPlayerQuit', root, function()
    if (disabledLogOutputs[source]) then 
        disabledLogOutputs[source] = nil;
    end 
end);