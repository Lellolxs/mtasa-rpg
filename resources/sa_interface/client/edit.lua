Editing = nil;
Selection = nil; -- { state: "select" | "move", position: Vector2, elements: { id: string, offset: Vector2 } } | nil
Active = false;
EditElementSettings = nil;

local SizeModifierSize = 12;
local SettingsButtonSize = 14;
local BoxPadding = 8;
local TextSpeed = 2500;

local SelectionLineWidth = 2;

local function rootRender()
    if (not Active) then 
        return;
    end 

    dxDrawRectangle(0, 0, ScreenWidth, ScreenHeight, tocolor(22, 22, 22, 200));

    if (not EditElementSettings) then 
        local alpha = interpolateBetween(200, 0, 0, 80, 0, 0, math.abs(getTickCount() % TextSpeed - TextSpeed / 2) * 0.001, "InOutQuad");
        dxDrawText(
            "Interface módosítás", 0, 0, 
            ScreenWidth, ScreenHeight, 
            tocolor(200, 200, 200, alpha), 16, "opensans-bold", 
            'center', 'center'
        );
    end 

    for id, v in pairs(Elements) do 
        local x, y = v.position.x - BoxPadding, v.position.y - BoxPadding;
        local width, height = v.size.x + BoxPadding * 2, v.size.y + BoxPadding * 2;

        dxDrawRectangle(x, y, width, height, tocolor(22, 22, 22, 150), true);
        dxDrawText(v.label, x, y, width, height, tocolor(200, 200, 200), 12, "opensans-bold", "center", "center", false, false, true);

        if (v.sizable) then 
            dxDrawRectangle(
                x + (width - SizeModifierSize),
                y + (height - SizeModifierSize),
                SizeModifierSize, SizeModifierSize, 
                tocolor(200, 200, 200, 100), true
            );
        end 

        if (v.options and #v.options > 0) then 
            dxDrawRectangle(
                x + width - SettingsButtonSize, 
                y, SettingsButtonSize, SettingsButtonSize, 
                tocolor(200, 200, 200), true
            );

            dxDrawText(
                "", x, y, width, height, 
                tocolor(200, 200, 200), 
                10, "fontawesome", "right", "top", 
                false, false, true
            );
        end 
    end 

    -- Mozgatas / Meretezes
    if (Editing and Elements[Editing.id]) then 
        if (EditElementSettings) then 
            Editing = nil;
            return;
        end 

        local element = Elements[Editing.id];
        local cursorX, cursorY = getCursorPosition();

        if (Editing.sizing) then 
            local targetWidth, targetHeight = cursorX - element.position.x, cursorY - element.position.y;

            if (element.minSize and element.minSize.x and element.minSize.x > targetWidth) then 
                targetWidth = element.minSize.x; 
            elseif (element.maxSize and element.maxSize.x and element.maxSize.x < targetWidth) then 
                targetWidth = element.maxSize.x; 
            end 

            if (element.minSize and element.minSize.y and element.minSize.y > targetHeight) then 
                targetHeight = element.minSize.y; 
            elseif (element.maxSize and element.maxSize.y and element.maxSize.y < targetHeight) then 
                targetHeight = element.maxSize.y; 
            end 

            if (
                element.size.x ~= targetWidth or 
                element.size.y ~= targetHeight
            ) then 
                element.size = Vector2(targetWidth, targetHeight);
                triggerEvent("onInterfaceUpdate", root, Editing.id, element.position, element.size);
            end
        else
            local newX = cursorX - Editing.offset.x + BoxPadding;
            local newY = cursorY - Editing.offset.y + BoxPadding;

            if (
                element.position.x ~= newX or 
                element.position.y ~= newY
            ) then 
                -- ** Elements[Editing.id].position = cursorPosition - Editing.offset + boxPadding

                Elements[Editing.id].position = Vector2(
                    cursorX - Editing.offset.x + BoxPadding, 
                    cursorY - Editing.offset.y + BoxPadding
                ); 

                triggerEvent("onInterfaceUpdate", root, Editing.id, element.position, element.size);
            end 
        end 
    end 

    if (Selection) then 
        if (EditElementSettings) then 
            Selection = nil;
            return;
        end 

        local cursorX, cursorY = getCursorPosition();
        
        if (Selection.state == 'select') then
            local pos = Selection.position;

            if (cursorX < pos.x + 10) then 
                cursorX = pos.x + 10;
            end 

            if (cursorY < pos.y + 10) then 
                cursorY = pos.y + 10;
            end 

            dxDrawBorderedRectangle(
                pos.x, pos.y, cursorX - pos.x, cursorY - pos.y, 
                3, tocolor(100, 100, 100, 125), tocolor(100, 100, 100, 100)
            );
        -- elseif (Sekection.state == 'move') then 

        end 
    end 
end 

local function rootClick(button, state)
    if (
        not Active or 
        EditElementSettings ~= nil
    ) then 
        return;
    end 

    if (button ~= 'left') then 
        return;
    end 

    if (state == 'down' and not Editing) then 
        for id, v in pairs(Elements) do 
            local x, y = v.position.x - BoxPadding, v.position.y - BoxPadding;
            local width, height = v.size.x + BoxPadding * 2, v.size.y + BoxPadding * 2;

            if (isCursorInArea(x, y, width, height)) then 
                local isEditElementSettings = isCursorInArea(
                    x + width - SettingsButtonSize, 
                    y, SettingsButtonSize, SettingsButtonSize
                );

                if (isEditElementSettings) then 
                    EditElementSettings = id;
                    toggleElementSettings(true, Elements[id]);

                    return;
                end 

                local isSizing = isCursorInArea(
                    x + (width - SizeModifierSize),
                    y + (height - SizeModifierSize),
                    SizeModifierSize, SizeModifierSize
                );

                local cursorX, cursorY = getCursorPosition();
                local offset = Vector2(
                    cursorX - x, 
                    cursorY - y
                );

                Editing = { id = id, sizing = (isSizing and v.sizable), offset = offset };

                return;
            end 
        end 

        if (not Editing) then 
            local cursorX, cursorY = getCursorPosition();
            Selection = { state = "select", position = Vector2(cursorX, cursorY) };
        end 
    elseif (state == 'up') then 
        if (Editing) then 
            Editing = nil;
        end 

        if (Selection) then 
            local cursorX, cursorY = getCursorPosition();
            if (Selection.state == 'select') then 
                local pos = Selection.position;

                if (cursorX < pos.x + 10) then 
                    cursorX = pos.x + 10;
                end 

                if (cursorY < pos.y + 10) then 
                    cursorY = pos.y + 10;
                end 

                local elementsWithin = {};
                for id, v in pairs(Elements) do 
                    if (isElementWithinSelectionArea(id, pos.x, pos.y, cursorX, cursorY)) then 
                        table.insert(elementsWithin, id);
                    end 
                end 

                if (#elementsWithin > 0) then 
                    iprint('zsa');
                else 
                    Selection = nil;
                end
            end 
        end 
    end 
end 

function isElementWithinSelectionArea(id, fromX, fromY, toX, toY)
    if (not id or not Elements[id]) then 
        return false;
    end 

    local element = Elements[id];

    return (
        element.position.x > fromX and 
        element.position.x < toX and 

        element.position.y > fromY and 
        element.position.y < toY
    );
end 

function toggleEdit(state)
    if (state and not Active) then 
        showChat(false);
        Active = true;
    elseif (not state and Active) then 
        if (EditElementSettings) then 
            toggleElementSettings(false);
            EditElementSettings = nil;
        end 

        showChat(true);
        Active = false;
        Editing = nil;
    end 
end 

-- if (getPlayerSerial(localPlayer) == '01F3C54CEF90AFB6FEE851E6AEA63492') then 
    -- toggleEdit(true);
-- end 

addEventHandler('onClientRender', root, rootRender);
addEventHandler('onClientClick', root, rootClick);

addCommandHandler('edithud', function()
    toggleEdit(not Active);
end);

addEvent('onInterfaceUpdate', false);
addEvent('onInterfaceVisibleChange', false);