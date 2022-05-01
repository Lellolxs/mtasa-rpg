Core = exports.avCore;
Admin = exports.avAdmin;
Database = Core:getDatabase();

Interiors = {};

function OnStart()
    local query = dbQuery(function(qh)
        local result = dbPoll(qh, 100);
        
        if (result and #result > 0) then 
            for i,v in ipairs(result) do 
                LoadInterior(v);
            end 
        end 

    end, Database, "SELECT * FROM properties");
end 

-- Adatbazis schema
function LoadInterior(interior)
    local newInterior = {
        id = interior.id, 
        owner = interior.owner, 
        name = interior.name, 
        type = interior.type, 
        locked = interior.locked == 1, 
        category = interior.category, 

        entrace = nil, -- Kulso colshape

        inZone = nil, -- Ha custom interior, ez fogja erzekelni ha kiesne es visszadobja kivulre.
        size = (interior.size or -1), 
        build_data = interior.build_data and fromJSON(interior.build_data) or nil,
    };

    local entrace = fromJSON(interior.entrace);

    -- Entrace

    newInterior.entrace = createColSphere(
        entrace.x, entrace.y, entrace.z, 
        ShapeEnum.radius
    );

    setElementInterior(newInterior.entrace, entrace.interior);
    setElementDimension(newInterior.entrace, entrace.dimension);

    setElementData(newInterior.entrace, 'isInterior', true);
    setElementData(newInterior.entrace, 'id', interior.id);
    setElementData(newInterior.entrace, 'category', interior.category);

    if (interior.type == 'default') then 
        local gameInterior = DefaultInteriors[interior.interior];

        if (not gameInterior) then 
            dbExec(Database, 'DELETE FROM properties WHERE id = ?', interior.id);
            return;
        end 

        newInterior.exit = createColSphere(
            gameInterior.x, gameInterior.y, gameInterior.z, 
            ShapeEnum.radius
        );

        setElementData(newInterior.exit, 'isInterior', true);
        setElementData(newInterior.exit, 'id', interior.id);
        setElementData(newInterior.exit, 'category', interior.category);

        setElementInterior(newInterior.exit, gameInterior.interior);
        setElementDimension(newInterior.exit, interior.id);
    elseif (interior.type == 'custom') then 
        local spacing = InteriorEnum.TotalSize * InteriorEnum.MultiplierBetweenInteriors;
        local shapesPerRow = math.floor(InteriorEnum.MapSize / spacing);

        local row = math.floor(interior.id / shapesPerRow);
        local column = interior.id % shapesPerRow;

        newInterior.inZone = createColCuboid(
            -3000 + (spacing * column), 
            -3000 + (spacing * row), 
            InteriorEnum.ZCoord, 
            InteriorEnum.TotalSize, InteriorEnum.TotalSize, 
            InteriorEnum.TotalSize
        );

        setElementInterior(newInterior.inZone, 20);
        setElementDimension(newInterior.inZone, interior.id);

        -- Bejarat poziciojanak szamolasa

        local rotation, clampedId = getInteriorEntraceRotationFromWall(newInterior.build_data.entrace.wall, interior.size);
        local shapeX, shapeY, shapeZ = getElementPosition(newInterior.inZone);
        local interiorSize = newInterior.size * InteriorEnum.UnitSize;

        shapeX = shapeX + InteriorEnum.TotalSize / 2 - interiorSize / 2 + InteriorEnum.UnitSize / 2;
        shapeY = shapeY + InteriorEnum.TotalSize / 2 - interiorSize / 2 + InteriorEnum.UnitSize / 2;
        shapeZ = shapeZ + InteriorEnum.TotalSize / 2;

        local column = 0;
        local row = 0;

        if (clampedId >= 0 and clampedId < newInterior.size) then 
            row = clampedId;
            column = 0;
        elseif (clampedId >= newInterior.size and clampedId < newInterior.size * 2) then 
            row = newInterior.size;
            column = clampedId % newInterior.size;
        elseif (clampedId >= newInterior.size * 2 and clampedId < newInterior.size * 3) then 
            row = newInterior.size - clampedId % newInterior.size;
            column = newInterior.size;
        elseif (clampedId >= newInterior.size * 3 and clampedId < newInterior.size * 4) then 
            column = newInterior.size - clampedId % newInterior.size;
        end 

        local doorX = shapeX + (row * InteriorEnum.UnitSize) - InteriorEnum.UnitSize / 2;
        local doorY = shapeY + (column * InteriorEnum.UnitSize) - InteriorEnum.UnitSize / 2; 
        local doorZ = shapeZ + 1.8;

        doorX, doorY = getPointFromDistanceRotation(doorX, doorY, ShapeEnum.distance, rotation);

        newInterior.exit = createColSphere(doorX, doorY, doorZ - 0.5, ShapeEnum.radius);

        setElementData(newInterior.exit, 'isInterior', true);
        setElementData(newInterior.exit, 'id', interior.id);
        setElementData(newInterior.exit, 'category', interior.category);
    end 

    Interiors[interior.id] = newInterior;
end 

function UnloadInterior(interiorId)
    if (interiorId and Interiors[interiorId]) then 
        local interior = Interiors[interiorId];
        if (isElement(interior.entrace)) then destroyElement(interior.entrace); end
        if (isElement(interior.exit)) then destroyElement(interior.exit); end
    end 
end

function getLowestFreeInteriorId()
    for i = 1, 65535 do 
        if (not Interiors[i]) then 
            return i;
        end 
    end 

    return false;
end 

addEventHandler(
    'onResourceStart', 
    root, 
    function(resource)
        local resourceName = getResourceName(resource);

        if (resourceName == getResourceName(getThisResource())) then 
            OnStart();
        elseif (resourceName == 'oMysql') then 
            Database = exports.oMysql:getDBConnection();
        end 
    end
);