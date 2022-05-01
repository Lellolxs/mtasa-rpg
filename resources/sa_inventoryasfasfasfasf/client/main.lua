Core = exports.sa_core;
Interface = exports.sa_interface;

Colors = Core:getColors();

loadstring(Core:require({ "Rectangle", "Editbox" }))();

Inventory = {};
Actionbar = {}; -- { [key: number]: number (slot) }
TargetInventory = nil; -- ha ez nem nil, akkor ez lesz hasznalva az 'Inventory' helyett.
Visible = false;

OpenTick = nil;
InventoryWeight = nil;

Drag = nil; -- nil | { slot = number, offset = Vector2 }

Components = {};

function OpenInventory(inventory)
    Inventory = (getElementData(localPlayer, 'inventory') or {});

    if (inventory) then 
        TargetInventory = inventory;
    end 

    OpenTick = getTickCount();
    InventoryWeight = (getElementInventoryWeight(localPlayer) or 0);

    Components.inventory.mount();

    Visible = true;
end 

function toggleInventory()
    if (not Visible) then 
        OpenInventory();
    else 
        Components.inventory.unmount();
        Visible = false;
    end 
end 
bindKey('i', 'down', toggleInventory);

addEventHandler(
    'onClientElementDataChange', 
    localPlayer, 
    function(key, old, new)
        if (key == 'inventory') then 
            Inventory = new;
            InventoryWeight = (getElementInventoryWeight(localPlayer) or 0);
            iprint(InventoryWeight)
        end 
    end
);

addEventHandler(
    "onClientResourceStart", 
    resourceRoot, 
    function()
        -- Components.actionbar.mount();
    end
);