Active = false;
GlobalAlpha = 255;

Colors = Core:getColors();

Components = {};
Pages = {};

CurrentPage = 'settings';

ActiveComponents = {};

TotalWidth, TotalHeight = Config.total_size.x, Config.total_size.y;
ContainerX, ContainerY = ScreenWidth / 2 - TotalWidth / 2, ScreenHeight / 2 - TotalHeight / 2;

local function rootRender()
    for _, compId in ipairs(ActiveComponents) do 
        local component = Components[compId];
        if (component and component.render ~= nil) then 
            component.render();
        end 
    end 

    if (
        CurrentPage and 
        Pages[CurrentPage] and 
        Pages[CurrentPage].render ~= nil
    ) then 
        Pages[CurrentPage].render();
    end 

    -- dxDrawRectangle(ContainerX, ContainerY, TotalWidth, TotalHeight, tocolor(22, 22, 22, 50));
end 

local function Open()
    local renderedComponents = {};
    for id, comp in pairs(Components) do 
        if (comp.mountOnLoad) then 
            comp.mount();
            table.insert(renderedComponents, id);
        end 
    end 

    local page = (CurrentPage and Pages[CurrentPage]) and CurrentPage or 'home';
    if (Pages[page] and Pages[page].mount ~= nil) then 
        Pages[page].mount();
    end 

    addEventHandler('onClientRender', root, rootRender);
    showChat(false);

    ActiveComponents = renderedComponents;
    Active = true;
end 

local function Close()
    for id, comp in pairs(Components) do 
        if (comp.unmount ~= nil) then 
            comp.unmount();
        end 
    end 

    if (CurrentPage and Pages[CurrentPage] and Pages[CurrentPage].unmount ~= nil) then 
        Pages[CurrentPage].unmount();
    end 

    removeEventHandler('onClientRender', root, rootRender);
    showChat(true);

    Active = false;
end 

function Toggle(key, press)
    if (not Active) then 
        Open();
    else 
        Close();
    end 
end 
bindKey('f3', 'down', Toggle);

addEventHandler('onClientResourceStop', resourceRoot, function()
    Close();
end);