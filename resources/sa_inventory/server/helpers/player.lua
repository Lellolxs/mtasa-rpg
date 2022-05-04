PlayerAttachments = {};

AttachmentTypes = {
    helmet = true,
    kevlar = true, 
};

function addPlayerAttachment(player, item)
    local modelId = Items[item.id].model;
    if (not modelId) then 
        outputChatBox(
            Core:getServerPrefix("error", "Armor") .. " Item `" .. item.id .. "`-hoz/-hez nem tartozik model, kérlek jelezd egy fejlesztőnek.", 
            player, 255, 255, 255, true
        );

        return false;
    end 

    local attach = Items[item.id].attach;
    if (not attach) then 
        outputChatBox(
            Core:getServerPrefix("error", "Armor") .. " Item `" .. item.id .. "`-hoz/-hez nem tartozik attach beállítás, kérlek jelezd egy fejlesztőnek.", 
            player, 255, 255, 255, true
        );

        return false;
    end 

    if (not PlayerAttachments[player]) then 
        PlayerAttachments[player] = {};
    end 

    local attachments = PlayerAttachments[player];

    if (attachments[getItemType(item.id)]) then 
        outputChatBox(
            Core:getServerPrefix("error", "Armor") .. " Már van rajtad kevlár.", 
            player, 255, 255, 255, true
        );

        return false;
    end 
    
    local object = createObject(modelId, 0, 0, 3);
    setObjectScale(object, attach.size.x, attach.size.y, attach.size.z);
    if (not object) then 
        outputChatBox(
            Core:getServerPrefix("error", "Armor") .. " Sikertelen kevlar felvétel, kérlek jelezd egy fejlesztőnek. (OBJ_FAILED_TO_CREATE)", 
            player, 255, 255, 255, true
        );

        return false;
    end 

    local attached = Attach:attach(
        object, player, attach.bone, 
        attach.offset.x, attach.offset.y, attach.offset.z, 
        attach.rotation.x, attach.rotation.y, attach.rotation.z
    );
    if (not attached) then 
        if (isElement(object)) then 
            destroyElement(object);
        end 

        outputChatBox(
            Core:getServerPrefix("error", "Armor") .. " Sikertelen kevlar felvétel, kérlek jelezd egy fejlesztőnek. (OBJ_FAILED_TO_ATTACH)", 
            player, 255, 255, 255, true
        );

        return false;
    end 

    attachments[getItemType(item.id)] = object;

    return true;
end 

function removePlayerAttachment(player, item)
    local itemType = getItemType(item.id);

    if (
        not PlayerAttachments[player] or 
        not PlayerAttachments[player][itemType]
    ) then 
        outputChatBox(
            Core:getServerPrefix("error", "Armor") .. " Nincs mit rólad levennixd", 
            player, 255, 255, 255, true
        );
    
        return false;
    end 
    
    local object = PlayerAttachments[player][itemType];
    if (not isElement(object)) then 
        outputChatBox(
            Core:getServerPrefix("error", "Armor") .. " Lol nem letezik a cucc", 
            player, 255, 255, 255, true
        );
    
        return false;
    end 
    
    local detached = Attach:detach(object);
    destroyElement(object);
    PlayerAttachments[player][itemType] = nil;
    
    return true;
end 