function formatNumber(number, sep)
	assert(type(tonumber(number))=="number", "Bad argument @'formatNumber' [Expected number at argument 1 got "..type(number).."]")
	assert(not sep or type(sep)=="string", "Bad argument @'formatNumber' [Expected string at argument 2 got "..type(sep).."]")
	local str = tostring(number):reverse():gsub("%d%d%d","%1%"..(sep and #sep>0 and sep or ".")):reverse();
    return (str:sub(1, 1) == (sep or '.')) 
            and str:sub(2)
            or str;
end

function getItemImage(idOrItem)
    if (not idOrItem) then 
        return false;
    end 

    if (type(idOrItem) == 'string' and Items[idOrItem]) then 
        local filePath = ":sa_inventory/client/assets/items/";
        return (fileExists(filePath .. "/" .. idOrItem .. ".png"))
                and (filePath .. "/" .. idOrItem .. ".png")
                or (filePath .. "/nil.png");
    end 

    if (
        type(idOrItem) == 'table' and 
        idOrItem.id and 
        Items[idOrItem.id]
    ) then 
        local item = Items[idOrItem.id];

        if (
            item.methods and
            item.methods.getImage
        ) then 
            return ":sa_inventory/client/assets/items/" .. (item.methods.getImage(idOrItem) or 'nil') .. ".png";
        else 
            local filePath = ":sa_inventory/client/assets/items/";
            return (fileExists(filePath .. "/" .. idOrItem.id .. ".png"))
                    and (filePath .. "/" .. idOrItem.id .. ".png")
                    or (filePath .. "/nil.png");
        end 
    end 

    return ":sa_inventory/client/assets/items/nil.png";
end 