Core = exports.sa_core;
Interface = exports.sa_interface;

loadstring(Core:require({ }))();

Component = {
    health = { current_value = 0, before_value = 0, last_change = getTickCount() }, 
    armor = { current_value = 0, before_value = 0, last_change = getTickCount() }, 
    thirst = { current_value = (getElementData(localPlayer, 'hunger') or 100), before_value = 0, last_change = getTickCount() }, 
    hunger = { current_value = (getElementData(localPlayer, 'thirst') or 100), before_value = 0, last_change = getTickCount() }, 
    stamina = { current_value = (getElementData(localPlayer, 'stamina') or 100), before_value = 0, last_change = getTickCount() },
};

local Width, Height = 200 * getResp(), 43 * getResp();
local X, Y = ScreenWidth - Width * 1.025, Height * 0.1;
local BarAnimSpeed = 800;

local Settings = {
    doAnimation = Interface:getInterfaceElementOptionValue("hud", "doAnimation"),
};

Component.render = function()
    local tick = getTickCount();

    local health = 0;
    if (Settings.doAnimation) then 
        health = interpolateBetween(
            Component.health.before_value, 0, 0, 
            Component.health.current_value, 0, 0, 
            (tick - Component.health.last_change) / BarAnimSpeed, "InOutQuad"
        );
    else 
        health = Component.health.current_value;
    end 

    if (
        Component.health.current_value ~= getElementHealth(localPlayer) and 
        Component.health.last_change + 50 < tick
    ) then 
        Component.health.before_value = Component.health.current_value;
        Component.health.current_value = getElementHealth(localPlayer);
        Component.health.last_change = tick;
    end 

    Component.__drawSegmentBar(
        X, Y, 
		Width * 0.485, Height * 0.3, 
        tocolor(24, 24, 24), 
        tocolor(182, 85, 85), 
        health, 
        4 * getResp(), 1.5 * getResp(), 
        1, false, false 
    );

    local armor = 0;
    if (Settings.doAnimation) then 
        armor = interpolateBetween(
            Component.armor.before_value, 0, 0, 
            Component.armor.current_value, 0, 0, 
            (tick - Component.armor.last_change) / BarAnimSpeed, "InOutQuad"
        );
    else 
        armor = Component.armor.current_value;
    end 

    if (
        Component.armor.current_value ~= getPedArmor(localPlayer) and 
        Component.armor.last_change + 50 < tick
    ) then 
        Component.armor.before_value = Component.armor.current_value;
        Component.armor.current_value = getPedArmor(localPlayer);
        Component.armor.last_change = tick;
    end 

    Component.__drawSegmentBar(
        X + Width * 0.5075, Y, 
		Width * 0.485, Height * 0.3, 
        tocolor(24, 24, 24), 
        tocolor(50, 179, 239), 
        armor, 
        4 * getResp(), 1.5 * getResp(),
        1, false, false 
    );

    local hunger = 0;
    if (Settings.doAnimation) then 
        hunger = interpolateBetween(
            Component.hunger.before_value, 0, 0, 
            Component.hunger.current_value, 0, 0, 
            (tick - Component.hunger.last_change) / BarAnimSpeed, "InOutQuad"
        );
    else 
        hunger = Component.hunger.current_value;
    end 

    Component.__drawSegmentBar(
        X, Y + Height * 0.35, 
        Width * 0.485, Height * 0.3, 
        tocolor(24, 24, 24), 
        tocolor(226, 149, 6), 
        (hunger or 100), 
        2 * getResp(), 1.5 * getResp(), 
        1, false, false 
    );

    local thirst = 0;
    if (Settings.doAnimation) then 
        thirst = interpolateBetween(
            Component.thirst.before_value, 0, 0, 
            Component.thirst.current_value, 0, 0, 
            (tick - Component.thirst.last_change) / BarAnimSpeed, "InOutQuad"
        );
    else 
        thirst = Component.thirst.current_value;
    end 
    Component.__drawSegmentBar(
        X + Width * 0.5075, Y + Height * 0.35, 
        Width * 0.485, Height * 0.3, 
        tocolor(24, 24, 24), 
        tocolor(101, 162, 187), 
        (thirst or 100), 
        4 * getResp(), 1.5 * getResp(), 
        1, false, false 
    );

    local stamina = 0;
    if (Settings.doAnimation) then 
        stamina = interpolateBetween(
            (Component.stamina.before_value or 0), 0, 0, 
            (Component.stamina.current_value or 0), 0, 0, 
            (tick - Component.stamina.last_change) / BarAnimSpeed, "InOutQuad"
        );
    else 
        stamina = Component.stamina.current_value;
    end 

    if (
        Component.stamina.current_value ~= getElementData(localPlayer, "stamina") and 
        Component.stamina.last_change + 50 < tick
    ) then 
        Component.stamina.before_value = Component.stamina.current_value;
        Component.stamina.current_value = getElementData(localPlayer, "stamina");
        Component.stamina.last_change = tick;
    end 
    Component.__drawSegmentBar(
        X, Y + Height * 0.7, 
        Width, Height * 0.3, 
        tocolor(24, 24, 24), 
        tocolor(200, 200, 200), 
        (stamina or 100), 
        4 * getResp(), 1.5 * getResp(), 
        2, false, false 
    );
end

Component.__uiUpdate = function(id, position, size)
    if (id == 'hud') then 
        Width, Height = size.x, size.y;
        X, Y = position.x, position.y;
    end 
end 

Component.__uiSettingChange = function(id, ui)
    iprint("elotte", Settings, ui , Settings[ui.id] ~= nil);
    if (ui and Settings[ui.id] ~= nil) then 
        Settings[ui.id] = ui.value;
    end 
    iprint("utana", Settings);
end 

Component.__onDamage = function(attacker, damage, bodypart, loss)
    Component.health.before_value = getElementHealth(localPlayer) + loss;
    Component.health.current_value = getElementHealth(localPlayer);
    Component.health.last_change = getTickCount();
end 

Component.__onDataChange = function(key, old, new)
    if (Component[key]) then 
        Component[key].before_value = Component[key].current_value;
        Component[key].current_value = new;
        Component[key].last_change = getTickCount();
    end 
end 

Component.mount = function()
    Interface:mount("hud", {
        label = "Statisztikák", 
        position = Vector2(X, Y),

        size = Vector2(Width, Height),
        minSize = Vector2(Width * 0.5, Height),
        maxSize = Vector2(Width * 1.5, Height),

        sizable = true, 

        options = {
            { id = "kurva", type = "header", label = "Anyad", default = false },
            { id = "doAnimation", type = "switch", label = "Csík animáció", default = false }
        },
    });

    addEventHandler('onClientRender', root, Component.render);
    addEventHandler('onInterfaceUpdate', root, Component.__uiUpdate);
    addEventHandler('onClientPlayerDamage', localPlayer, Component.__onDamage);
    addEventHandler('onClientElementDataChange', localPlayer, Component.__onDataChange);

    addEvent("onInterfaceElementSettingChange", false);
    addEventHandler('onInterfaceElementSettingChange', resourceRoot, Component.__uiSettingChange);

    local hudComponents = {
        "ammo", "armour", "breath", 
        "clock", "health", "money", 
        "weapon", "wanted", "radar"
    };
    table.foreach(hudComponents, function(i, v) setPlayerHudComponentVisible(v, false) end);
end

Component.unmount = function()
	removeEventHandler('onClientRender', root, Component.render);
    removeEventHandler('onInterfaceUpdate', root, Component.__uiUpdate);
end 

Component.__drawSegmentBar = function(startX, startY, width, height, backgroundColor, progressColor, currentValue, gapWidth, inner, numOfSegments, postGUI, subPixelPositioning)
    inner = inner or 0
    backgroundColor = backgroundColor or tocolor(0, 0, 0, 200)
    progressColor = progressColor or tocolor(0, 150, 255)

    currentValue = currentValue and math.min(100, currentValue) or 0
    gapWidth = gapWidth or 5
    numOfSegments = numOfSegments or 3

    local widthWithGap = width - gapWidth * (numOfSegments - 1)
    local oneSegmentWidth = widthWithGap / numOfSegments - inner / 2

    local progressPerSegment = 100 / numOfSegments
    local remainingProgress = currentValue % progressPerSegment

    local segmentsFull = math.floor(currentValue / progressPerSegment)
    local segmentsInUse = math.ceil(currentValue / progressPerSegment)

    for i = 1, numOfSegments do
        local segmentX = startX + (oneSegmentWidth + gapWidth) * (i - 1)

        dxDrawRectangle(segmentX, startY, oneSegmentWidth, height, backgroundColor, postGUI, subPixelPositioning)

        if i <= segmentsFull then
            dxDrawRectangle(segmentX + inner, startY + inner, oneSegmentWidth - inner * 2, height - inner * 2, progressColor, postGUI, subPixelPositioning)
        elseif i == segmentsInUse then
            if remainingProgress > 0 then
                local boxWidth = oneSegmentWidth / progressPerSegment * remainingProgress - inner * 2;
                dxDrawRectangle(segmentX + inner, startY + inner, (boxWidth < 0) and 0 or boxWidth, height - inner * 2, progressColor, postGUI, subPixelPositioning)
            end
        end
    end
end

Component.mount();