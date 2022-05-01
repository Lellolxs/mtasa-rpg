Components.actionbar = {};
local component = Components.actionbar;

component.__uiElements = {};

local Width, Height = 275 * getResp(), 51 * getResp();
local X, Y = ScreenWidth / 2 - Width / 2, ScreenHeight - Height * 1.1;

local slotCount = 6;

component.render = function()
    dxDrawRectangle(X, Y, Width, Height, tocolor(22, 22, 22));

    local slotWidth, slotHeight = (Width * 0.94) / slotCount, Height * 0.85;

    for slot = 0, slotCount - 1 do 
        local slotX = X + Width * 0.01 + (slot * (slotWidth * 1.05));
        local slotY = Y + Height * 0.075;
        local isSlotActive = (
            getKeyState(tostring(slot + 1)) or 
            isCursorInArea(slotX, slotY, slotWidth, slotHeight)
        );

        dxDrawRectangle(
            slotX, slotY, slotWidth, slotHeight, 
            isSlotActive and tocolor(unpack(Colors.server.rgb)) or tocolor(28, 28, 28)
        );

        local invSlot = Actionbar[slot];

        if (invSlot and Inventory[invSlot]) then 
            local item = Inventory[invSlot];

            -- dxDrawText(
            --     getItemName(item), 
            --     X + Width * 0.01 + (slot * (slotWidth * 1.05)), 
            --     Y + Height * 0.05, 
            --     X + Width * 0.01 + (slot * (slotWidth * 1.05)) + slotWidth, 
            --     Y + Height * 0.05 + slotHeight, tocolor(255, 255, 255), 
            --     1, 'arial', 'center', 'center'
            -- );

            local padding = slotWidth * 0.035;

            dxDrawImage(
                slotX + padding, slotY + padding, 
                slotWidth - padding * 2, slotHeight - padding * 2, 
                getItemImage(item)
            );
        end 
    end 
end 

component.isCursorOnActionSlot = function()
    local slotWidth, slotHeight = (Width * 0.94) / slotCount, Height * 0.85;
    
    for slot = 0, slotCount - 1 do 
        local slotX = X + Width * 0.01 + (slot * (slotWidth * 1.05));
        local slotY = Y + Height * 0.075;
    
        if (
            isCursorInArea(slotX, slotY, slotWidth, slotHeight)
        ) then    
            return slot;
        end 
    end 

    return false;
end

component.__onKey = function(key, press)
    local key = tonumber(key);

    if (not key) then 
        return;
    end

    key = key - 1;

    if (press and key and key >= 1 and key <= slotCount) then 
        triggerServerEvent(
            'inventory:useItemOnSlot', 
            resourceRoot,
            Actionbar[key]
        );
    end 
end 

component.__uiUpdate = function(id, position, size)
    if (id == 'actionbar') then 
        X, Y = position.x, position.y;
    end
end 

component.mount = function()
    addEventHandler('onClientRender', root, component.render);
    addEventHandler('onClientKey', root, component.__onKey);
end 

component.unmount = function()
    removeEventHandler('onClientRender', root, component.render);
    removeEventHandler('onClientKey', root, component.__onKey);
end

addEventHandler('onInterfaceUpdate', root, component.__uiUpdate);
Interface:mount("actionbar", {
    label = "Actionbar", 
    position = Vector2(X, Y), 
    size = Vector2(Width, Height),
});