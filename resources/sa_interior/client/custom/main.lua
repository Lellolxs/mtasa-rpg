shader = dxCreateShader('client/assets/shader.fx');

Textures = {
    
};

InteriorData = {
    floors = {}, 
    ceiling = {}, 
    walls = {}, 
};

addEvent('sInterior:initCustomInterior', true);
addEventHandler(
    'sInterior:initCustomInterior', 
    root, 
    function(interior)
        local shapeX, shapeY, shapeZ = getElementPosition(interior.inZone);
        local interiorSize = interior.size * InteriorEnum.UnitSize;

        shapeX = shapeX + InteriorEnum.TotalSize / 2 - interiorSize / 2 + InteriorEnum.UnitSize / 2;
        shapeY = shapeY + InteriorEnum.TotalSize / 2 - interiorSize / 2 + InteriorEnum.UnitSize / 2;
        shapeZ = shapeZ + InteriorEnum.TotalSize / 2;

        InteriorData = {
            floors = {}, 
            ceiling = {}, 
            walls = {}, 
        };

        for i = 0, (interior.size * interior.size) - 1 do
            local row = math.floor(i / interior.size);
            local column = i % interior.size;

            local shader = dxCreateShader('client/assets/shader.fx');

            InteriorData.floors[i] = {
                object = createObject(69420, shapeX + (row * InteriorEnum.UnitSize), shapeY + (column * InteriorEnum.UnitSize), shapeZ, 0, 90, 0),
                shader = shader
            };

            dxSetShaderValue(InteriorData.floors[i].shader, 'tex', Textures.default);
            engineApplyShaderToWorldTexture(InteriorData.floors[i].shader, 'unnamed');
        end 

        for i = 0, (interior.size * interior.size) - 1 do
            local row = math.floor(i / interior.size);
            local column = i % interior.size;

            local shader = dxCreateShader('client/assets/shader.fx');

            InteriorData.ceiling[i] = {
                object = createObject(69420, shapeX + (row * InteriorEnum.UnitSize), shapeY + (column * InteriorEnum.UnitSize), shapeZ + 3.5, 0, 90, 0),
                shader = shader
            };

            dxSetShaderValue(InteriorData.ceiling[i].shader, 'tex', Textures.default);
            engineApplyShaderToWorldTexture(InteriorData.ceiling[i].shader, 'unnamed');
        end 

        for i = 0, interior.size * 4 - 1 do 
            local column = 0;
            local row = 0;

            if (i >= 0 and i < interior.size) then 
                row = i;
                column = 0;
            elseif (i >= interior.size and i < interior.size * 2) then 
                row = interior.size;
                column = i % interior.size;
            elseif (i >= interior.size * 2 and i < interior.size * 3) then 
                row = interior.size - i % interior.size;
                column = interior.size;
            elseif (i >= interior.size * 3 and i < interior.size * 4) then 
                column = interior.size - i % interior.size;
            end 

            local shader = dxCreateShader('client/assets/shader.fx');

            local isCorner = i % interior.size == 0;
            local rotation = 90 + math.floor(i / interior.size) * 90;

            InteriorData.walls[i] = {
                object = createObject(isCorner and 7509 or 1905, 
                    shapeX + (row * InteriorEnum.UnitSize) - InteriorEnum.UnitSize / 2, 
                    shapeY + (column * InteriorEnum.UnitSize) - InteriorEnum.UnitSize / 2, 
                    shapeZ + 1.8,
                    0, 0, rotation
                ),
                shader = shader
            };

            dxSetShaderValue(InteriorData.walls[i].shader, 'tex', Textures.default);
            engineApplyShaderToWorldTexture(InteriorData.walls[i].shader, 'unnamed');
        end 
    end
);

addEvent('sInterior:unloadCustomInterior', true);
addEventHandler(
    'sInterior:unloadCustomInterior', 
    root, 
    function()
        for _, data in pairs(InteriorData.floors) do 
            if (isElement(data.object)) then 
                destroyElement(data.object);
            end 

            if (isElement(data.shader)) then 
                destroyElement(data.shader);
            end 
        end

        for _, data in pairs(InteriorData.ceiling) do 
            if (isElement(data.object)) then 
                destroyElement(data.object);
            end 

            if (isElement(data.shader)) then 
                destroyElement(data.shader);
            end 
        end

        for _, data in pairs(InteriorData.walls) do 
            if (isElement(data.object)) then 
                destroyElement(data.object);
            end 

            if (isElement(data.shader)) then 
                destroyElement(data.shader);
            end 
        end
    end
);

addEventHandler(
    'onClientResourceStart', 
    resourceRoot, 
    function()
        Textures.default = dxCreateTexture('client/assets/texture.png');
        
        if (not Textures.default) then 
            print('szartex');
        end 

        loadModel('client/assets/models/floor', 69420);
        loadModel('client/assets/models/wall', 7509);
        loadModel('client/assets/models/wall2', 1905);
        loadModel('client/assets/models/wall3', 1925);
        loadModel('client/assets/models/wall4', 1935);
        loadModel('client/assets/models/wall5', 1945);
        loadModel('client/assets/models/wall6', 1955);
        loadModel('client/assets/models/wall7', 1965);
    end
);