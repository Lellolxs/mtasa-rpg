Pages.settings = {};
local page = Pages.settings;
local settings = Config.pages.settings;

page.label = "Beállítások";
page.icon = "";

local width, height = TotalWidth * Config.page.size.x, TotalHeight * Config.page.size.y;
local x, y = ContainerX + TotalWidth * Config.page.position.x, ContainerY + TotalHeight * Config.page.position.y;

page.__current_submenu = "general";
page.__submenu_order = { "general", "character", "graphics" };
page.__submenus = {};

--[[                               ]]--
--[[           Általános           ]]--
--[[                               ]]--

page.__submenus.general = {};
local general = page.__submenus.general;

general.label = "Általános";
general.icon = "";

general.render = function()
    local ui = general.__ui;

    -- 
    -- Nametag
    -- 
    dxDrawRectangle(x + width * 0.045, y + height * 0.15, width * 0.266, height * 0.045, tocolor(22, 22, 22));
    dxDrawText("Nametag", x + width * 0.045, y + height * 0.15, width * 0.266, height * 0.045, _, 12, "roboto-bold", "center", "center");

    dxDrawText("Saját nametag mutatása", x + width * 0.045, y + height * 0.205, width * 0.266, height * 0.045, tocolor(200, 200, 200), 10, "roboto", "left", "center");
    ui.__nametag_show_self.render(x + width * 0.267, y + height * 0.21, width * 0.045, height * 0.035);
    
end 

general.mount = function()
    general.__ui = {};
    local ui = general.__ui;

    -- 
    -- Nametag
    -- 
    ui.__nametag_show_self = Switch("nametag_show_self", { value = getSettingValue('nametag', 'show_self') });
    ui.__nametag_show_self.value = getSettingValue('nametag', 'show_self');
    ui.__nametag_show_self.on("input", function() setSettingValue('nametag', 'show_self', ui.__nametag_show_self.value); end);

    general.ready = true;
end 

general.unmount = function()
    if (general.__ui) then 
        for k,v in pairs(general.__ui) do 
            if (v.__destroy ~= nil) then 
                v.__destroy();
            end 
        end 
    end 

    general.__ui = nil;
    general.ready = false;
end 

--[[                               ]]--
--[[           Karakter            ]]--
--[[                               ]]--

page.__submenus.character = {};
local character = page.__submenus.character;

character.label = "Karakter";
character.icon = "";

character.render = function()

end 

character.mount = function()
    character.__ui = {};
end 

character.unmount = function()
    
end 

--[[                               ]]--
--[[           Graphics            ]]--
--[[                               ]]--

page.__submenus.graphics = {};
local graphics = page.__submenus.graphics;

graphics.label = "Grafika";
graphics.icon = "";

graphics.render = function()

end 

graphics.mount = function()
    graphics.__ui = {};
end 

graphics.unmount = function()
    
end 

--[[                               ]]--
--[[             root              ]]--
--[[                               ]]--

page.render = function()
    dxDrawRectangle(x, y, width, height, settings.colors.background);

    if (
        page.__submenus[page.__current_submenu].render ~= nil and 
        page.__submenus[page.__current_submenu].ready
    ) then 
        page.__submenus[page.__current_submenu].render();
    end 

    local index = 0;
    for _, id in pairs(page.__submenu_order) do 
        if (id and page.__submenus[id]) then 
            local submenu = page.__submenus[id];
            local alpha = (id == page.__current_submenu) and 200 or 80;

            -- dxDrawRectangle(
            --     x + (width * 0.03) + (index * (width * 0.165)),
            --     y + height * 0.045, width * 0.14, height * 0.04, 
            --     tocolor(255, 50, 50, 80)
            -- );

            dxDrawText(
                submenu.icon or "", 
                x + (width * 0.065) + (index * (width * 0.165)),
                y + height * 0.045, 0, 0, tocolor(200, 200, 200, alpha), 
                13, "fa-solid", "right"
            );

            dxDrawText(
                submenu.label or id, 
                x + (width * 0.075) + (index * (width * 0.165)),
                y + height * 0.045, 0, 0, tocolor(200, 200, 200, alpha), 
                15, "opensans-bold", "left"
            );

            index = index + 1;
        end 
    end 
end 

page.onclick = function(button, state)
    if (button ~= 'left' or state ~= 'down') then 
        return;
    end 

    local index = 0;
    for _, id in pairs(page.__submenu_order) do 
        if (id and page.__submenus[id]) then 
            local submenu = page.__submenus[id];

            if (
                isCursorInArea(
                    x + (width * 0.03) + (index * (width * 0.165)),
                    y + height * 0.045, width * 0.14, height * 0.04
                )
            ) then 
                if (
                    page.__submenus[page.__current_submenu].unmount ~= nil and
                    page.__submenus[page.__current_submenu].unmount() == false
                ) then 
                    return false;
                end 

                if (
                    submenu.mount ~= nil and 
                    submenu.mount() == false
                ) then 
                    page.__submenus[page.__current_submenu].mount();
                    return false;
                end 

                page.__current_submenu = id;
                break;
            end 

            index = index + 1;
        end 
    end 
end 

page.mount = function()
    if (
        type(page.__current_submenu) ~= "string" or 
        not page.__submenus[page.__current_submenu]
    ) then 
        page.__current_submenu = "general";
    end 

    if (page.__submenus[page.__current_submenu].mount ~= nil) then 
        iprint('page mountolva v idk')
        page.__submenus[page.__current_submenu].mount();
    end

    addEventHandler("onClientClick", root, page.onclick);
end 

page.unmount = function()
    iprint('gieaiksdnjasd')
    if (page.__submenus[page.__current_submenu].unmount ~= nil) then 
        page.__submenus[page.__current_submenu].unmount();
    end 

    removeEventHandler("onClientClick", root, page.onclick);
end 