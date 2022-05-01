Factions = {};

addEventHandler('onResourceStart', resourceRoot, function()
    iprint('uwu')
    dbQuery(
        function(qh)
            local result = dbPoll(qh, 100);
            
            if (result and #result > 0) then 
                table.foreach(result, function(i, v) Factions[v.id] = Faction(v.id, v); end);
            end 
        end, 
        Database, 
        "SELECT * FROM groups"
    );
end);