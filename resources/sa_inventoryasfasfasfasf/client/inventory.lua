Components.inventory = {};
local component = Components.inventory;

component.__uiElements = {};

local Width, Height = 465 * getResp(), 255 * getResp();
local X, Y = ScreenWidth * 0.75 - Width / 2, ScreenHeight / 2 - Height / 2;

component.__fonts = {
    general = Core:requireFont("opensans-bold", 15),
    count = Core:requireFont("opensans", 10),
};

local SlotsPerRow = 8;
local SlotSize = 42;

local MaxWeight = 25;
local WeightAnimationInterval = 800;

component.render = function()
    dxDrawRectangle(X, Y, Width, Height, tocolor(22, 22, 22));

    local ui = component.__uiElements;
    local fonts = component.__fonts;
    local inventory = (TargetInventory ~= nil) 
                        and TargetInventory
                        or Inventory;

    local cursorX, cursorY = getCursorPosition();
    local slotX, slotY = X + Width * 0.02, Y + Height * 0.15;
    local slotWidth, slotHeight = Width * 0.0925, Height * 0.17;

    dxDrawImage(
        X + Width * 0.015, Y + Height * 0.025, 
        Width * 0.05, Height * 0.1, 
        ":sa_core/client/assets/logo.png"
    );

    dxDrawText(
        "Tárgyaid", 
        X + Width * 0.085, Y + Height * 0.075, 
        _, _, tocolor(200, 200, 200), 
        1, fonts.general, "left", "center"
    );

    dxDrawText(
        "$ " .. formatNumber(ui.cash, ","), 
        X + Width * 0.825, Y + Height * 0.075, 
        _, _, 
        (ui.cash > 0) and tocolor(200, 200, 200) or tocolor(255, 0, 0), 
        1, fonts.general, "right", "center"
    );

    ui.itemcount.render(
        X + Width * 0.835, Y + Height * 0.025, 
        Width * 0.15, Height * 0.1
    );

    local hoveredSlot = component.__getHoveredItemSlot();

    for slot = 0, 31 do 
        local row = math.floor(slot / SlotsPerRow);
        local column = slot % SlotsPerRow;

        local slotX, slotY = slotX + column * (slotWidth * 1.1), slotY + row * (slotHeight * 1.1);

        dxDrawRectangle(
            slotX, slotY, 
            slotWidth, slotHeight, 
            (hoveredSlot and type(hoveredSlot.slot) == "number" and hoveredSlot.slot == slot) 
                    and tocolor(unpack(Colors.server.rgb))
                    or tocolor(18, 18, 18, 255)
        );

        -- Debug slotmerethez
        -- dxDrawText(
        --     math.floor(slotWidth) .. " - " .. math.floor(slotHeight), 
        --     slotX, slotY, 
        --     slotX + slotWidth, slotY + slotHeight, 
        --     tocolor(255, 255, 255), 1, "arial", 
        --     "center", "center", true, true
        -- );

        if (
            inventory[slot] and 
            (
                not Dragged or
                type(Dragged.slot) ~= "number" or 
                Dragged.slot ~= slot
            )
        ) then 
            local item = inventory[slot];
            local padding = slotWidth * 0.035;

            dxDrawImage(
                slotX + padding, slotY + padding, 
                slotWidth - padding * 2, slotHeight - padding * 2, 
                getItemImage(item)
            );

            dxDrawText(
                item.count, 
                slotX, slotY, 
                slotX + slotWidth, 
                slotY + slotHeight,
                tocolor(0, 0, 0), 
                1, fonts.count, "right", "bottom"
            );
        end 
    end 

    -- Additional slots
    local slotX, slotY = X + Width * 0.8825, Y + Height * 0.15;
    for i,v in ipairs(Config.additional_slots) do 
        i = i - 1;
        local slotY = slotY + i * (slotHeight * 1.1);

        dxDrawRectangle(
            slotX, slotY, 
            slotWidth, slotHeight, 
            (hoveredSlot and type(hoveredSlot.slot) == "string" and hoveredSlot.slot == v.type) 
                    and tocolor(unpack(Colors.server.rgb))
                    or tocolor(18, 18, 18, 255)
        );

        dxDrawText(
            v.type, 
            slotX, slotY, 
            slotX + slotWidth, slotY + slotHeight, 
            tocolor(200, 200, 200), 
            1, "arial", "center", "center", 
            true, true
        );

        dxDrawText(
            tostring(
                not Dragged or 
                type(Dragged.slot) ~= "string" or 
                Dragged.slot ~= slot
            ), 500, 200
        )

        -- Nem biztos hogy betonbiztosxd
        if (
            inventory[v.type] and 
            (
                not Dragged or 
                (type(Dragged.slot) ~= "string" and 
                Dragged.slot ~= slot)
            )
        ) then 
            local item = inventory[v.type];
            local padding = slotWidth * 0.035;

            dxDrawImage(
                slotX + padding, slotY + padding, 
                slotWidth - padding * 2, slotHeight - padding * 2, 
                getItemImage(item)
            );
        end 
    end 

    if (
        Dragged and 
        Dragged.slot and 
        inventory[Dragged.slot]
    ) then 
        dxDrawImage(
            cursorX - Dragged.offset.x, cursorY - Dragged.offset.y, 
            slotWidth, slotHeight, 
            getItemImage(inventory[Dragged.slot])
        );
    end 

    local weightBarWidth = interpolateBetween(
        0, 0, 0, 1, 0, 0, 
        (getTickCount() - OpenTick) / WeightAnimationInterval, 
        "OutQuad"
    );
    local r, g, b = interpolateBetween(
        92, 196, 95, 
        160, 40, 40,
        (InventoryWeight / MaxWeight) * weightBarWidth, 
        "Linear"
    );

    InventoryWeight = (InventoryWeight > MaxWeight) and MaxWeight or InventoryWeight;

    dxDrawRectangle(
        X + Width * 0.025, Y + Height * 0.915, 
        Width * 0.95, Height * 0.05, 
        tocolor(36, 36, 36)
    );

    dxDrawRectangle(
        X + Width * 0.025, 
        Y + Height * 0.915, 
        ((Width * 0.95) * (InventoryWeight / MaxWeight)) * weightBarWidth, 
        Height * 0.05, 
        tocolor(r, g, b)
    );
end 

component.click = function(button, state, _, _, _, _, _, element)
    if (button == "left") then 
        if (state == "down") then 
            local drag = component.__getHoveredItemSlot();

            if (drag) then 
                Dragged = drag;
            end 
        elseif (state == "up" and Dragged) then 
            local hovered = component.__getHoveredItemSlot();
            if (hovered and Dragged.slot ~= hovered.slot) then 
                -- Csak hogy valtoztatva legyen a cache es ne ugraljon.
                -- Inventory[hovered.slot] = Inventory[Dragged.slot];
                -- Inventory[Dragged.slot] = nil;

                local ui = component.__uiElements;
                triggerServerEvent(
                    "inventory:moveItem", 
                    resourceRoot, Dragged.slot, 
                    hovered.slot, tonumber(ui.itemcount.value) or false
                );

                Dragged = nil;
                return;
            end 

            if (isElement(element)) then 
                local ui = component.__uiElements;

                triggerServerEvent(
                    "inventory:moveItemOnElement", 
                    resourceRoot, 
                    element, 
                    Dragged.slot, 
                    tonumber(ui.itemcount.value) or false
                );

                Dragged = nil;
                return;
            end 

            local actionSlot = Components.actionbar.isCursorOnActionSlot();
            if (actionSlot) then
                if (Actionbar[actionSlot]) then 
                    return iprint("van mar a sloton");
                end 
                
                Actionbar[actionSlot] = Dragged.slot;
            end 

            Dragged = nil;
        end 
    elseif (button == "right") then 
        if (state == "down") then 
            local drag = component.__getHoveredItemSlot();

            if (drag) then
                triggerServerEvent(
                    "inventory:useItemOnSlot", 
                    resourceRoot,
                    drag.slot
                );
            end
        elseif (state == "up") then 
            local actionSlot = Components.actionbar.isCursorOnActionSlot();
            if (actionSlot) then
                Actionbar[actionSlot] = nil;
            end 
        end 
    end 
end 

component.__getHoveredItemSlot = function()
    local cursorX, cursorY = getCursorPosition();

    if (not isCursorInArea(X, Y, Width, Height)) then 
        return false;
    end 

    local slotWidth, slotHeight = Width * 0.0925, Height * 0.17;

    for slot = 0, 31 do 
        local row = math.floor(slot / SlotsPerRow);
        local column = slot % SlotsPerRow;

        local slotX, slotY = X + Width * 0.02, Y + Height * 0.15;

        if (
            isCursorInArea(
                slotX + column * (slotWidth * 1.1), 
                slotY + row * (slotHeight * 1.1), 
                slotWidth, slotHeight
            )
        ) then 
            return {
                slot = slot, 
                offset = Vector2(
                    cursorX - (slotX + column * (slotWidth * 1.1)), 
                    cursorY - (slotY + row * (slotHeight * 1.1)) 
                )
            };
        end 
    end 

    -- Additional slots
    local slotX, slotY = X + Width * 0.8825, Y + Height * 0.15;
    for i,v in ipairs(Config.additional_slots) do 
        i = i - 1;

        if (
            isCursorInArea(
                slotX, 
                slotY + i * (slotHeight * 1.1), 
                slotWidth, slotHeight
            )
        ) then 
            return {
                slot = v.type, 
                offset = Vector2(
                    cursorX - (slotX), 
                    cursorY - (slotY + i * (slotHeight * 1.1)) 
                )
            };
        end 
    end 

    return false;
end 

component.__uiUpdate = function(id, position, size)
    if (id == "inventory") then 
        X, Y = position.x, position.y;
    end
end 

component.__onAmountInput = function(self)
    if (
        not tonumber(self.value) or 
        tonumber(self.value) < 0
    ) then 
        self.value = "";
    end 
end 

component.__elementDataChange = function(key, old, new)
    local ui = component.__uiElements;

    if (key == "cash" and source == localPlayer) then 
        ui.cash = new;
    end 
end 

component.mount = function()
    MaxWeight = getElementWeightCapacity(localPlayer);
    local ui = component.__uiElements;

    ui.cash = (getElementData(localPlayer, "cash") or 0);
    ui.itemcount = Editbox("inventory_count", { placeholder = "Mennyiség", font = Core:requireFont("opensans-bold", 10), style = { radius = 0.1, padding = 2, align = "center" } });
    ui.itemcount.on("input", component.__onAmountInput);

    addEventHandler("onClientRender", root, component.render);
    addEventHandler("onClientClick", root, component.click);
    addEventHandler("onClientElementDataChange", root, component.__elementDataChange);
end 

component.unmount = function()
    removeEventHandler("onClientRender", root, component.render);
    removeEventHandler("onClientClick", root, component.click);
    removeEventHandler("onClientElementDataChange", root, component.__elementDataChange);
end

addEventHandler("onInterfaceUpdate", root, component.__uiUpdate);
Interface:mount("inventory", {
    label = "Inventory", 
    position = Vector2(X, Y), 
    size = Vector2(Width, Height),
});