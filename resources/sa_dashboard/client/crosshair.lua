Crosshair = {
    enabled = true, 
    width = 8, 
    thickness = 2,
    gap = 3
};

function drawCrosshair(x, y)
    -- top
    dxDrawRectangle(x - Crosshair.thickness / 2, y - Crosshair.gap - Crosshair.width, Crosshair.thickness, Crosshair.width);
    
    -- right
    dxDrawRectangle(x + Crosshair.gap, y - Crosshair.thickness / 2, Crosshair.width, Crosshair.thickness);

    -- bottom
    dxDrawRectangle(x - Crosshair.thickness / 2, y + Crosshair.gap, Crosshair.thickness, Crosshair.width);

    -- left
    dxDrawRectangle(x - Crosshair.gap - Crosshair.width, y - Crosshair.thickness / 2, Crosshair.width, Crosshair.thickness);
end 

addEventHandler('onClientRender', root, function()
    if (not isPedAiming(localPlayer)) then 
        return;
    end 

    if (not Crosshair.enabled and not isPlayerHudComponentVisible('crosshair')) then 
        setPlayerHudComponentVisible('crosshair', true);
    elseif (Crosshair.enabled and isPlayerHudComponentVisible('crosshair')) then 
        setPlayerHudComponentVisible('crosshair', false);
    end 

    if (not Crosshair.enabled) then 
        return;
    end 

    local scX, scY = ScreenWidth * 0.53, ScreenHeight * 0.4;
    drawCrosshair(scX, scY);
end);

function isPedAiming(ped)
    return (
        isElement(ped) and 
        (getElementType(ped) == "player" or getElementType(ped) == "ped") and 
        (getPedTask(ped, "secondary", 0) == "TASK_SIMPLE_USE_GUN" or isPedDoingGangDriveby(ped))
    );
end