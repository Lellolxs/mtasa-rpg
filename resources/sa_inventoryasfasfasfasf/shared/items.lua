--[[
    Item types:
        general
        consumable (kaja/pia)

        weapon
        ammo

        helmet
        kevlar

        storage

    Item flags:
        STACKABLE
        CAN_RENAME
        TAKE_ON_DEATH
]]

local defaultItemValue = 0.5;

Items = {
    ['water'] = {
        name = 'Víz', 
        type = 'consumable', 
        weight = 0.5, 

        flags = { "STACKABLE", "TAKE_ONE_ON_USE" },
    },

    ['bread'] = {
        name = 'Kenyér', 
        type = 'consumable', 
        weight = 0.5, 

        flags = { "STACKABLE", "TAKE_ONE_ON_USE" },
    },

    -- 
    -- Keys
    -- 

    ['car_key'] = {
        name = 'Járműkulcs', 
        type = 'general', 
        weight = 0.5, 
    },

    ['property_key'] = {
        name = 'Ingatlankulcs', 
        type = 'general', 
        weight = 0.5, 
    },

    ['gate_key'] = {
        name = 'Kapukulcs', 
        type = 'general', 
        weight = 0.5, 
    },

    -- 
    -- Weapons
    -- 

    ['ak47'] = {
        name = 'AK-47 gépkarabély', 
        type = 'weapon', 
        description = 'lüvéshexdd',
        weight = 3.1, 

        durability = 3000,
        ammoType = '9mm',
        weaponId = 30,

        flags = { "CAN_RENAME", "TAKE_ON_DEATH" },

        methods = {
            getDescription = function(item)
                return "Ez a fegyver még ~" .. math.floor(Items[item.id].durability * (((math.random(-200, 200) / 100) + item.status) / 100)) .. " lövést bír ki.";
            end, 
        },
    },

    ['m4a4'] = {
        name = 'M4 Carbine', 
        type = 'weapon', 
        description = 'lüvéshexdd',
        weight = 3.1, 

        durability = 3000,
        ammoType = '5.56mm',
        weaponId = 31,

        flags = { "CAN_RENAME", "TAKE_ON_DEATH" },

        methods = {
            getDescription = function(item)
                return "Ez a fegyver még ~" .. math.floor(Items[item.id].durability * (((math.random(-200, 200) / 100) + item.status) / 100)) .. " lövést bír ki.";
            end, 
        },
    },

    -- 
    -- Ammo
    --  

    ['5.56mm'] = {
        name = "5.56mm lőszer", 
        type = 'ammo', 

        flags = { "TAKE_ON_DEATH" },

        weight = 0.05
    },

    -- 
    -- Helmets
    -- 

    ['lq_helmet'] = {
        name = 'Alacsony koltsegvetesu sisak', 
        type = 'helmet', 
        weight = 4.5,

        model = 9083,
        attach = {
            bone = 8, 
            offset = Vector3(0, -0.125, -0.04), 
            rotation = Vector3(0, 0, 270), 
            size = Vector3(1.05, 1.05, 1.05)
        },

        flags = { "CAN_RENAME", "TAKE_ON_DEATH" },
    },

    -- 
    -- Kevlars
    -- 

    ['lq_kevlar'] = {
        name = 'Alacsony koltsegvetesu golyóálló mellény', 
        type = 'kevlar', 
        weight = 4.5,

        model = 9593,
        attach = { 
            bone = 3, 
            offset = Vector3(0.01, 0.06, -0.225), 
            rotation = Vector3(90, 8, 4), 
            size = Vector3(1.05, 1.05, 1.05)
        },

        flags = { "CAN_RENAME", "TAKE_ON_DEATH" },
    },
};

function getItemName(idOrItem, excludeTag)
    if (not idOrItem) then 
        return false;
    end 

    if (type(idOrItem) == 'string' and Items[idOrItem]) then 
        return (Items[idOrItem].name or false);
    end 

    if (
        type(idOrItem) == 'table' and 
        idOrItem.id and 
        Items[idOrItem.id]
    ) then 
        local item = Items[idOrItem.id];

        if (
            item.methods and
            item.methods.getName
        ) then 
            return item.methods.getName(idOrItem);
        else 
            return item.name .. ((idOrItem.tag ~= nil and not excludeTag) and " (" .. idOrItem.tag:gsub("#%x%x%x%x%x%x", "") .. ")" or "");
        end 
    end 

    return false;
end 

function getItemType(idOrItem)
    if (not idOrItem) then 
        return false;
    end 

    if (type(idOrItem) == 'string' and Items[idOrItem]) then 
        return Items[idOrItem].type;
    end 

    if (
        type(idOrItem) == 'table' and 
        idOrItem.id and 
        Items[idOrItem.id]
    ) then 
        return Items[idOrItem.id].type;
    end 

    return false;
end 


function getItemDescription(idOrItem)
    if (not idOrItem) then 
        return false;
    end 

    if (type(idOrItem) == 'string' and Items[idOrItem]) then 
        return Items[idOrItem].description;
    end 

    if (
        type(idOrItem) == 'table' and 
        idOrItem.id and 
        Items[idOrItem.id]
    ) then 
        local item = Items[idOrItem.id];
        
        if (
            item.methods and
            item.methods.getDescription
        ) then 
            return item.methods.getDescription(idOrItem);
        else 
            return item.description;
        end 
    end 

    return false;
end 

function getItemWeight(id, count)
    local count = (count or 1);

    return (type(id) == 'string' and Items[id])
            and (Items[id].weight or defaultItemValue) * count
            or false;
end 

function getItemFlags(id)
    return (type(id) == 'string' and Items[id])
            and (Items[id].flags or {})
            or false;
end 

function itemHasFlag(idOrItem, flag)
    if (not idOrItem or not flag) then 
        return false;
    end 

    if (type(idOrItem) == 'string' and Items[idOrItem]) then 
        if (not Items[idOrItem].flags) then 
            return false;
        end 

        return (table.find(Items[idOrItem].flags, function(x) return (x == flag) end) ~= false);
    end 

    if (
        type(idOrItem) == 'table' and 
        idOrItem.id and 
        Items[idOrItem.id]
    ) then 
        if (not Items[idOrItem.id]) then 
            return false;
        end 

        return (table.find(Items[idOrItem.id].flags, function(x) return (x == flag) end) ~= false);
    end 

    return false;
end 