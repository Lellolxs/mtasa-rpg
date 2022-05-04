Inventory = exports.sa_inventory;
Admin = exports.sa_admin;
Chat = exports.sa_chat;

local Items = {
    water = { type = 'drink', value = 10 }, 
    bread = { type = 'food', value = 10 }, 
};

addEventHandler('onPlayerUseItem', root, function(player, item, slot)
    local itemType = Inventory:getItemType(item.id);

    if (itemType and itemType == 'consumable' and Items[item.id]) then 
        local data = Items[item.id];
        local key = data.type == 'drink' and 'thirst' or 'hunger';

        Chat:elementSendMe(player, ((data.type == 'drink') and "ivott" or "evett") .. " egy " .. Inventory:getItemName(item.id) .. "-t.");
        local targetValue = (getElementData(player, key) or 100) + data.value;
        setElementData(player, key, (targetValue > 100) and 100 or targetValue);
    end 
end);

function decreasePlayersNeeds()
    for _, player in ipairs(getElementsByType('player')) do 
        if (
            not Admin:isAdminInDuty(player)
        ) then 
            setElementData(player, 'thirst', (getElementData(player, 'thirst') or 100) - math.random(0.5, 1.5));
            setElementData(player, 'hunger', (getElementData(player, 'hunger') or 100) - math.random(0.25, 0.85));
        end 
    end 
end 
setTimer(decreasePlayersNeeds, 30000, 0);