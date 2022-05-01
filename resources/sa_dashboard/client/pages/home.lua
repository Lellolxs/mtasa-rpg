Pages.home = {};
local page = Pages.home;
local settings = Config.pages.home;

page.label = "Főoldal";
page.icon = "";

page.__data = {};

local width, height = TotalWidth * Config.page.size.x, TotalHeight * Config.page.size.y;
local x, y = ContainerX + TotalWidth * Config.page.position.x, ContainerY + TotalHeight * Config.page.position.y;

local highlightColor = Core:getColor("server");

page.render = function()
    dxDrawRectangle(x, y, width, height, settings.colors.background);

    dxDrawText(
        "Adataid",
        x + width * 0.02, y + height * 0.05, 
        width * 0.3, height * 0.1, 
        tocolor(200, 200, 200, 200), 
        24, "opensans-bold"
    );

    for i,v in ipairs(page.__data) do 
        local boxX = x + width * 0.02;
        local boxY = y + (height * 0.08) + (height * (i * 0.04));

        dxDrawText(
            v.prefix .. ": " .. highlightColor.hex .. v.value .. (v.suffix or ""), 
            boxX, boxY, 
            width * 0.45, height * 0.04, 
            tocolor(200, 200, 200), 15, "opensans", 
            "left", "center", false, false, false, true
        );
    end 

    -- 
    -- Object Preview
    -- 

    -- dxDrawRectangle(
    --     x + width * 0.55, y + height * 0.05, 
    --     width * 0.405, height * 0.9, 
    --     tocolor(16, 16, 16, 150)
    -- );
    -- dxDrawRectangle(
    --     x + width * 0.55, y + height * 0.05, 
    --     width * 0.405, height * 0.08, 
    --     tocolor(12, 12, 12, 150)
    -- );
    dxDrawText(
        "Karaktered kinézete", 
        x + width * 0.55, y + height * 0.05, 
        width * 0.405, height * 0.08,
        tocolor(200, 200, 200), 14, "opensans-bold", 
        "center", "center"
    );
end 

page.mount = function()
    local adminLevel = Admin:getPlayerAdminLevel(localPlayer);
    page.__data = {
        { prefix = "Neved", value = (getElementData(localPlayer, "name") or "Ismeretlen"):gsub("_", " ") },
        { prefix = "Account ID", value = (getElementData(localPlayer, "userId") or "?") },
        { prefix = "Karakter ID", value = (getElementData(localPlayer, "charId") or "?") },
        { prefix = "Játszott percek", value = (getElementData(localPlayer, "timespent") or 0) .. " perc" },
        { prefix = "Admin", value = (adminLevel > 0 and "Igen (" .. Admin:getPlayerAdminTitle(localPlayer) .. ")" or "Nem") },
        { prefix = "Admin neved", value = (Admin:getPlayerAdminName(localPlayer)) },
        { prefix = "Készpénz", value = "$ " .. formatNumber((getElementData(localPlayer, "cash") or 0), ",") }, 
        { prefix = "Prémiumpont", value = formatNumber((getElementData(localPlayer, "premium") or 0), ",") .. " PP" }, 
        { prefix = "Járműveid száma", value = 1 .. " db" }, 
        { prefix = "Ingatlanjaid száma", value = 1 .. " db" }, 
    };

    -- 
    -- Object preview
    -- 

    local camX, camY, camZ = getCameraMatrix();
    local playerModel = getElementModel(localPlayer);
    local multiplier = settings.preview.window_multiplier;

    local boxWidth, boxHeight = width * 0.405, height * 0.9;
    local boxX, boxY = x + (width * 0.55) - (boxWidth * multiplier - boxWidth) / 2, y + (height * 0.05) - (boxHeight * multiplier - boxHeight) / 2;

    page.__element = createPed(playerModel, camX, camY, camZ);
    page.__preview = Preview:createObjectPreview(page.__element, 0, 0, 0, boxX, boxY, boxWidth * multiplier, boxHeight * multiplier, false, false, true);
    page.__window = guiCreateWindow(boxX, boxY, boxWidth * multiplier, boxHeight * multiplier, "Preview", false, false);

    guiSetAlpha(page.__window, 0);
    guiWindowSetMovable(page.__window, false);
    guiWindowSetSizable(page.__window, false);

    local projPosX, projPosY = guiGetPosition(page.__window,true);
	local projSizeX, projSizeY = guiGetSize(page.__window, true);
	Preview:setProjection(page.__preview, projPosX, projPosY, projSizeX, projSizeY, true, true);
	Preview:setRotation(page.__preview, 0, 0, 165);
    Preview:setDistanceSpread(page.__preview, 8);
end 

page.unmount = function()
    page.__data = {};

    Preview:destroyObjectPreview(page.__preview);
    if (isElement(page.__element)) then 
        destroyElement(page.__element);
    end 

    if (isElement(page.__window)) then 
        destroyElement(page.__window);
    end 

    return true;
end 