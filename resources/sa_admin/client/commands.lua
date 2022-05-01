local Width, Height = 920, 500;
local X, Y = ScreenWidth / 2 - Width / 2, ScreenHeight / 2 - Height / 2;

local FilteredCommands;
local Commands = {};
local Active = false;
local uiElements = {};

local MaxVisible = 12;

local Font = Core:requireFont('opensans-bold', 11);
local Font2 = Core:requireFont('opensans-bold', 15);

local function render()
    dxDrawRectangle(X, Y, Width, Height * 0.1, tocolor(16, 16, 16));
    dxDrawRectangle(X, Y + Height * 0.1, Width, Height * 0.9, tocolor(22, 22, 22));

    if (uiElements.scrollbar) then 
        uiElements.scrollbar.render(X + Width * 0.988, Y + Height * 0.11, Width * 0.008, Height * 0.88, MaxVisible, #((not FilteredCommands) and Commands or FilteredCommands));
    end 

    if (uiElements.search) then 
        uiElements.search.render(X + Width * 0.735, Y + Height * 0.02, Width * 0.25, Height * 0.06);
    end
    
    dxDrawText("Admin parancsok", X + Width * 0.01, Y, X + Width, Y + Height * 0.1, tocolor(200, 200, 200), 1, Font2, "left", "center");

    local i = 0;
    for index, v in ipairs((not FilteredCommands) and Commands or FilteredCommands) do 
        if (index > uiElements.scrollbar.__index and i < MaxVisible) then 
            local x, y = X + Width * 0.01, Y + Height * 0.115 + (i * (Height * 0.073));

            local text = AdminColors[v.required.admin] .. "[" .. AdminLevels[v.required.admin] .. "]#c8c8c8 /" .. v.command .. " ";
            
            if (v.__outputErrorArgsCache ~= '') then 
                text = text .. AdminColors[v.required.admin] .. v.__outputErrorArgsCache .. " ";
            end 

            if (v.description and v.description ~= '') then 
                text = text .. "#c8c8c8 > " .. v.description .. '';
            end 

            dxDrawRectangle(x, y, Width * 0.9725, Height * 0.063, tocolor(16, 16, 16));
            dxDrawText(
                text, 
                x + 4, y, 
                x + Width * 0.8, y + Height * 0.063, 
                tocolor(200, 200, 200), 1, Font, 
                'left', 'center', false, false, false, true
            );

            i = i + 1;
        end 
    end 
end

local function filterCommands()
    local text = string.lower(uiElements.search.value);

    if (not text or text == '') then 
        FilteredCommands = nil;
        return;
    end 

    local data = {};

    for _, v in ipairs(Commands) do
        if (
            string.find(string.lower(v.command), text) ~= nil or 
            string.find(string.lower((v.__outputErrorArgsCache or "")), text) ~= nil or 
            string.find(string.lower((v.description or "")), text) ~= nil or 
            table.findIndex(v.alias, function(x) return (string.find(string.lower(x), text) or nil) ~= nil end)
        ) then 
            table.insert(data, v);
        end 
    end

    uiElements.scrollbar.__index = 0;
    FilteredCommands = data;
end 

local function Open(commands)
    local data = {};

    for command, v in pairs(commands) do 
        table.insert(data, v);
    end 

    commands = nil;

    data = table.filter(data, function(x)
        return (
            not x.required or 
            getPlayerAdminLevel(localPlayer) >= (x.required.admin or 0)
        );
    end);

    table.sort(data, function(a, b)
        local aRequired = (not a.required or not a.required.admin) and 0 or a.required.admin;
        local bRequired = (not b.required or not b.required.admin) and 0 or b.required.admin;

        if (aRequired ~= bRequired) then 
            return (aRequired < bRequired);
        else 
            return (a.command < b.command);
        end 
    end);

    uiElements.scrollbar = Scrollbar('admin_commands');
    uiElements.search = Editbox('admin_searchbar', { placeholder = "Keresés" });

    uiElements.scrollbar.__index = 0;
    uiElements.scrollbar.__changeByScroll = 1;
    uiElements.search.on('input', filterCommands);

    Commands = data;
    addEventHandler("onClientRender", root, render);

    Active = true;
end 

local function Close()
    uiElements.scrollbar.destroy();
    uiElements.search.destroy();

    Commands = nil;

    removeEventHandler("onClientRender", root, render);
    Active = false;
end 

addEvent("admin:openCommandList", true);
addEventHandler("admin:openCommandList", root, function(commands)
    if (not Active) then 
        Open(commands);
    else 
        Close();
    end 
end);