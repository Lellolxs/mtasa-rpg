local afterPrefixColor = "#dbdbdb";

function getServerPrefix(color, suffix)
    if (not color or not Config.colors[color]) then color = 'server'; end 
    return Config.colors[color].hex .. "[" .. Config.server_short .. (suffix and (" - " .. suffix) or "") .. "]: " .. afterPrefixColor;
end 

-- function getServerPrefix(color, suffix)
--     if (not color or not Config.colors[color]) then color = 'server'; end 
--     return Config.colors[color].hex .. Config.server_short .. " " .. (suffix and ("- " .. suffix .. " ") or "") .. "| " .. afterPrefixColor;
-- end 