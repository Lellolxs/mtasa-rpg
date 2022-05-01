Core = exports.sa_core;
Admin = exports.sa_admin;
Info = exports.sa_notifications;
Chat = exports.sa_chat;
Attach = exports.pAttach;

Database = Core:getDatabase();

loadstring(Core:require({ }))();

function loadElementInventory(element)
    if (not isElement(element)) then 
        return;
    end 

    local elementType = getElementType(element);
    if (not ElementTypesWithInventory[elementType]) then 
        return iprint("element type \"" .. elementType .. "\" cannot have inventory space.");
    end 

    local identifier = ElementIdentifiers[elementType](element);

    if (not identifier) then 
        iprint(element, "has no identifier");
        return;
    end 

    dbQuery(
        function(qh)
            local result = dbPoll(qh, 10);

            if (not result or #result == 0) then 
                result = {};

                dbExec(
                    Database, 
                    [[
                        INSERT INTO
                            items__?? (identifier, items)
                        VALUES
                            (?, ?)
                    ]], 
                    elementType,
                    identifier, 
                    { }
                );
            end 

            local items = fromJSON(result[1].items);

            addElementDataSubscriber(element, "inventory", element);
            setElementData(element, "inventory", items, "subscribe");
        end, 
        Database, 
        [[
            SELECT
                *
            FROM 
                items__??
            WHERE
                identifier = ?
            LIMIT 1
        ]], 
        elementType,
        identifier
    );
end 