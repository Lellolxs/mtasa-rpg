Pages.admins = {};
local page = Pages.admins;
local settings = Config.pages.admins;

page.label = "Adminok";
page.icon = "";

page.__list = {};

local width, height = TotalWidth * Config.page.size.x, TotalHeight * Config.page.size.y;
local x, y = ContainerX + TotalWidth * Config.page.position.x, ContainerY + TotalHeight * Config.page.position.y;

page.render = function()
    dxDrawRectangle(x, y, width, height, settings.colors.background);

    dxDrawText(
        settings.footer_text, 
        x - width * 0.03, y + height * 0.85,
        width * 0.945, height * 0.15, 
        settings.colors.footer, 13, "opensans", 
        'left', 'center', true
    );

    for i = 1, 39 do 
        local column = math.floor((i - 1) / settings.countPerColumn);
        local row = (i - 1) % settings.countPerColumn;

        local color = (i % 2 == 0) and settings.colors.row_even or settings.colors.row_odd;

        local boxX = x + width * 0.025 + (column * (width * 0.315)); 
        local boxY = y + height * 0.035 + (row * (height * 0.06));
        local boxWidth, boxHeight = width * 0.315, height * 0.06;

        dxDrawRectangle(boxX, boxY, boxWidth, boxHeight, color);

        local item = page.__list[i];
        if (item) then 
            if (item.type == 'spacer') then 
                dxDrawText(
                    item.color .. item.label, 
                    boxX, boxY, 
                    boxWidth, boxHeight, 
                    tocolor(0, 0, 0), 
                    13, "opensans-bold", 
                    'center', 'center', 
                    false, false, false, true
                );
            elseif (item.type == 'indicator') then 
                dxDrawText(
                    item.color .. item.label, 
                    boxX, boxY, 
                    boxWidth, boxHeight, 
                    tocolor(0, 0, 0), 
                    13, "opensans", 
                    'center', 'center', 
                    false, false, false, true
                );
            elseif (item.type == 'admin') then 
                dxDrawText(
                    item.name .. (item.duty and (" (" .. item.id .. ")") or ""), 
                    boxX, boxY, boxWidth, boxHeight, 
                    item.duty and page.__levelsColors[item.level] or settings.colors.admin_offduty, 
                    13, "opensans", 
                    'center', 'center', 
                    false, false, false, true
                );
            end 
        end 
    end 
end 

page.__cache = function()
    local newList = {};

    local players = getElementsByType('player');
    for i = settings.level_range.from, settings.level_range.to do 
        table.insert(newList, {
            type = 'spacer', 
            label = Admin:getAdminLevelLabel(i), 
            color = Admin:getAdminLevelColor(i)
        });
        
        local adminsInRank = 0;
        for _, player in ipairs(players) do 
            local level = Admin:getPlayerAdminLevel(player);

            if (level == i) then 
                table.insert(newList, {
                    type = 'admin', 
                    id = (getElementData(player, 'playerid') or -1),
                    name = Admin:getPlayerAdminName(player), 
                    duty = Admin:isAdminInDuty(player), 
                    level = level
                });

                adminsInRank = adminsInRank + 1;
            end 
        end 

        if (adminsInRank == 0) then 
            table.insert(newList, {
                type = "indicator", 
                label = "Nincs elérhető admin", 
                color = settings.colors.no_admin
            });

            -- for j = 1, math.random(2, 4) do 
            --     table.insert(newList, {
            --         type = 'admin', 
            --         id = math.random(1, 1024),
            --         name = "Fity Matyi", 
            --         duty = true, 
            --         level = i
            --     });
            -- end 
        end 
    end 

    page.__list = newList;
end 

page.__onDataChange = function(key)
    if (getElementType(source) == 'player' and key == 'admin') then 
        page.__cache();
    end 
end 

page.mount = function()
    page.__list = {};
    page.__levelsColors = {};

    for level = settings.level_range.from, settings.level_range.to do 
        page.__levelsColors[level] = tocolor(hexToRgb(Admin:getAdminLevelColor(level)));
    end 

    page.__cache();
    addEventHandler('onClientElementDataChange', root, page.__onDataChange);
end 

page.unmount = function()
    removeEventHandler('onClientElementDataChange', root, page.__onDataChange);
    page.__list = nil;
    page.__levelsColors = nil;
end 