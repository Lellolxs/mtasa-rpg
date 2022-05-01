Core = exports.sa_core;
Interface = exports.sa_interface;

loadstring(Core:require({ }))();

local sx, sy = guiGetScreenSize();

local font = Core:requireFont('opensans-bold', 12);

local Visible = true;
local mapTexture = dxCreateTexture('client/assets/map.png');
local renderTarget = dxCreateRenderTarget(300, 200, true);
local Width, Height = 350 * getResp(), 200 * getResp();
local X, Y = 20 * getResp(), ScreenHeight - Height * 1.1;
local arrowSize = 24 * getResp();

local blipTextures = {};
local imageWidth, imageHeight = dxGetMaterialSize(mapTexture);
local zoom = 1.5;

-- addInterfaceElement('radar', X, Y, Width, Height, settings.limits.width.min, settings.limits.width.max, settings.limits.height.min, settings.limits.height.max, true);

addEventHandler('onClientResourceStart', resourceRoot, function()
    for i= 0, 50 do 
        if fileExists("client/elements/assets/blips/"..i..".png") then 
            blipTextures[i] = dxCreateTexture("client/elements/assets/blips/"..i..".png", "dxt3", true);
        end
    end
end);

addEventHandler('onClientPreRender', root, function()
    -- if (not getElementData(localPlayer, 'logged') or isPedDead(localPlayer)) then return; end

    if (Visible) then
        local _, _, camZ = getElementRotation(getCamera());
        local px, py, pz = getElementPosition(localPlayer);

        local mw, mh = dxGetMaterialSize(renderTarget);
        if (Width ~= mw or Height ~= mh) then 
            destroyElement(renderTarget);
            renderTarget = dxCreateRenderTarget(Width, Height, true);
        end

        if (getKeyState('num_add')) then 
            if (zoom < 4) then 
                zoom = zoom + 0.04;
            end
        elseif (getKeyState('num_sub')) then 
            if (zoom > 0.5) then 
                zoom = zoom - 0.04;
            end
        end

        dxSetRenderTarget(renderTarget, true);
            local mW, mH = dxGetMaterialSize(renderTarget);
            local ex, ey = mW / 2 - px / (6000 / (imageWidth * zoom)), mH / 2 + py / (6000 / (imageHeight * zoom));
            dxDrawRectangle(0,0, mW, mH, tocolor(128, 166, 205));
            dxDrawImage(ex - (imageWidth * zoom)/2, (ey - (imageHeight * zoom)/2), (imageWidth * zoom), (imageHeight * zoom), mapTexture, camZ, (px/(6000/(imageWidth * zoom))), -(py/(6000/(imageHeight * zoom))), tocolor(255, 255, 255, 255));
        dxSetRenderTarget();
        
        dxDrawRectangle(X, Y, Width, Height, tocolor(22, 22, 22));
        dxDrawText(getZoneName(px, py, pz), X + 5, Y + Height, (X + 5) + Width, Y + (Height - 36), tocolor(255, 255, 255), 1, font, 'left', 'center');
        dxDrawImage(X + 2, Y + 2, Width - 4, Height - 36, renderTarget, 0, 0, 0, tocolor(255,255,255), false);

        local _, _, pedZ = getElementRotation(localPlayer);
        dxDrawImage((X + 2) + (Width - 4) / 2 - arrowSize / 2, (Y + 2) + (Height - 36) / 2 - arrowSize / 2, arrowSize, arrowSize, 'client/assets/arrow.png', camZ-pedZ);
    end
end);

addEventHandler('onInterfaceUpdate', root, function(id, position, size)
    if (id == 'radar') then 
        X, Y = position.x, position.y;
        Width, Height = size.x, size.y;
    end 
end);

addEventHandler('onClientResourceStart', resourceRoot, function()
    Interface:mount('radar', {
        label = 'Radar', 
        position = Vector2(X, Y), 
        size = Vector2(Width, Height), 

        minSize = Vector2(Width * 0.6, Height * 0.6),
        maxSize = Vector2(Width * 1.6, Height * 1.6),
        sizable = true, 

        options = {
            { id = "kurva", type = "header", label = "Fasz1", default = false },
            { id = "asd1", type = "switch", label = "asd1", default = false },
            { id = "asd2", type = "switch", label = "asd2", default = false },
            { id = "asd3", type = "switch", label = "asd1", default = false },
            { id = "asd4", type = "switch", label = "asd2", default = false },
            { id = "asd5", type = "switch", label = "asd1", default = false },
            { id = "kurva2", type = "header", label = "Fasz2", default = false },
            { id = "asd6", type = "switch", label = "asd6", default = false },
            { id = "asd7", type = "switch", label = "asd7", default = false },
            { id = "asd8", type = "switch", label = "asd8", default = false },
            { id = "asd9", type = "switch", label = "asd9", default = false },
            { id = "asd10", type = "switch", label = "asd10", default = false },
            { id = "kurva3", type = "header", label = "Fasz3", default = false },
            { id = "asd11", type = "switch", label = "asd11", default = false },
            { id = "asd12", type = "switch", label = "asd12", default = false },
            { id = "asd13", type = "switch", label = "asd13", default = false },
            { id = "asd14", type = "switch", label = "asd14", default = false },
            { id = "asd15", type = "switch", label = "asd15", default = false },
        },
    });
end);