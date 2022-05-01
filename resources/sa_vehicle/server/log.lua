function addVehicleLog(log)
    if (
        not log or 
        type(log) ~= 'table' or 
        not log.action or 
        type(log.action) ~= 'string'
    ) then 
        return;
    end 

    local fields = {
        player = ((type(log.player) == 'userdata') and (getElementData(log.player, 'userId') or nil) or (type(log.player) == 'number' and log.player or nil)),
        vehicle = ((type(log.vehicle) == 'userdata') and (getElementData(log.vehicle, 'id') or nil) or (type(log.vehicle) == 'number' and log.vehicle or nil)),
        action = log.action, 
        additional = ((type(log.additional) == 'table') and log.additional or { }),
    };

    local query_str = dbPrepareString(
        Database, 
        [[
            INSERT INTO 
                `logs__vehicle` (player, vehicle, action, date, additional)
            VALUES 
                (?, ?, ?, NOW(), ?)
        ]], 
        fields.player, fields.vehicle, 
        fields.action, toJSON(fields.additional)
    );

    dbExec(Database, query_str);
end 