AdminLevels = {
    [0] = "Játékos", 
    [1] = "Ideiglenes adminsegéd",
    [2] = "Adminsegéd",
    [3] = "Admin 1", 
    [4] = "Admin 2", 
    [5] = "Admin 3", 
    [6] = "Admin 4", 
    [7] = "Admin 5", 
    [8] = "Főadmin", 
    [9] = "Szuperadmin", 
    [10] = "Tulajdonos", 
    [11] = "Fejlesztő", 
};

AdminColors = {
    [0] = "#c8c8c8", 
    [1] = "#f49ac1", 
    [2] = "#f49ac1", 
    [3] = "#7cc576", 
    [4] = "#7cc576", 
    [5] = "#7cc576", 
    [6] = "#7cc576", 
    [7] = "#7cc576", 
    [8] = "#efad5f", 
    [9] = "#d93617", 
    [10] = "#ed1c24", 
    [11] = "#00aeef", 
};

function getPlayerAdminLevel(player)
    if (
        not isElement(player) or 
        getElementType(player) ~= "player"
    ) then 
        return false;
    end 

    local admin = (getElementData(player, "admin") or {});
    return (admin and admin.level)
            and admin.level
            or 0;
end 

function getPlayerAdminName(player, includeLevelColor)
    if (
        not isElement(player) or 
        getElementType(player) ~= "player"
    ) then 
        return "Ismeretlen admin";
    end 

    local admin = (getElementData(player, "admin") or {});
    return (admin and admin.name)
            and (includeLevelColor) and (AdminColors[getPlayerAdminLevel(player)] .. admin.name .. "#c8c8c8") or admin.name
            or "Ismeretlen admin";
end 

function isAdminInDuty(player)
    if (
        not isElement(player) or 
        getElementType(player) ~= "player"
    ) then 
        return false;
    end 

    local admin = (getElementData(player, "admin") or {});
    return (admin and admin.duty)
            and admin.duty
            or false;
end 

function getPlayerAdminTitle(player)
    if (
        not isElement(player) or 
        getElementType(player) ~= "player"
    ) then 
        return false;
    end 

    local admin = (getElementData(player, "admin") or {});
    return (admin and admin.level and AdminLevels[admin.level])
            and AdminLevels[admin.level]
            or AdminLevels[0];
end 

function getPlayerAdminColor(player)
    if (
        not isElement(player) or 
        getElementType(player) ~= "player"
    ) then 
        return false;
    end 

    local admin = (getElementData(player, "admin") or {});
    return (admin and admin.level and AdminColors[admin.level])
            and AdminColors[admin.level]
            or AdminColors[0];
end 

-- Szintek lekeresei

function getAdminLevelLabel(level)
    if (
        type(level) ~= 'number' or 
        not AdminLevels[level]
    ) then 
        return false;
    end 

    return AdminLevels[level];
end 

function getAdminLevelColor(level)
    if (
        type(level) ~= 'number' or 
        not AdminColors[level]
    ) then 
        return false;
    end 

    return AdminColors[level];
end 