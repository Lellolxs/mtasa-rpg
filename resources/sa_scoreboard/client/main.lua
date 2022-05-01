Core = exports.sa_core;
Admin = exports.sa_admin;

loadstring(Core:require({ }))();

local Active = false;
local PlayerList = {};
local ScrollIndex = 1;

-- appearance vars
local HEADER_HEIGHT = 76 * getResp();
local TOTAL_WIDTH = 500 * getResp();
local MAX_VISIBLE_ROWS = 12; 

local Settings = {
    header = { x_margin = 0.02, y_margin = -0.025, bottom_spacing = 0 * getResp() },
    columns = { height = 28 * getResp(), x_padding = 16.0 * getResp(), y_padding = 12.0 * getResp() },
    list = { height = 32 * getResp(), x_padding = 16.0 * getResp(), padding_top = 8.0 * getResp(), padding_bottom = 4.0 * getResp(), spacing_between = 3.0 * getResp() },
};

function rootRender()
    if (ScrollIndex > #PlayerList - MAX_VISIBLE_ROWS) then 
        ScrollIndex = #PlayerList - MAX_VISIBLE_ROWS;
    end 

    local playerRows = (MAX_VISIBLE_ROWS > #PlayerList) and #PlayerList or MAX_VISIBLE_ROWS;

    local width, height = TOTAL_WIDTH, HEADER_HEIGHT + Settings.header.bottom_spacing + (
        Settings.columns.height + Settings.columns.y_padding
    ) + Settings.list.padding_top + (Settings.list.height * playerRows + Settings.list.spacing_between * playerRows) + Settings.list.padding_bottom;
    
    local x, y = ScreenWidth / 2 - width / 2, ScreenHeight / 2 - height / 2;

    -- 
    -- Header
    -- 

    dxDrawRectangle(x, y, width, HEADER_HEIGHT, tocolor(24, 24, 24, 230));
    dxDrawText(
        "San Andreas Stories", 
        x + width * Settings.header.x_margin, y, width, HEADER_HEIGHT * (0.5 - Settings.header.y_margin), 
        tocolor(200, 200, 200), 13.5, 
        'roboto-bold', false, 'antialiased', 
        'left', 'bottom'
    );
    dxDrawText(
        "scoreboard", 
        x + width * Settings.header.x_margin, 
        y + HEADER_HEIGHT * (0.5 + Settings.header.y_margin), width, HEADER_HEIGHT * 0.5, 
        tocolor(200, 200, 200), 13.5, 
        'roboto-thin', false, 'antialiased', 
        'left', 'top'
    );
    
    dxDrawText(
        "Játékosok", 
        x, y, width * (1.0 - Settings.header.x_margin), HEADER_HEIGHT * (0.5 - Settings.header.y_margin), 
        tocolor(200, 200, 200), 13.5, 
        'roboto-bold', false, 'antialiased', 
        'right', 'bottom'
    );
    dxDrawText(
        #PlayerList .. "/200", 
        x, y + HEADER_HEIGHT * (0.5 + Settings.header.y_margin), 
        width * (1.0 - Settings.header.x_margin), HEADER_HEIGHT * 0.5, 
        tocolor(200, 200, 200), 13.5, 
        'roboto-thin', false, 'antialiased', 
        'right', 'top'
    );

    -- 
    -- List
    -- 

    dxDrawRectangle(x, y + HEADER_HEIGHT, width, height - HEADER_HEIGHT, tocolor(32, 32, 32, 230));

    local row = 0;
    for i, player in ipairs(PlayerList) do 
        if (i >= ScrollIndex and i <= ScrollIndex + MAX_VISIBLE_ROWS) then 
            local plrX = x + Settings.list.x_padding / 2;
            local plrY = y + HEADER_HEIGHT + Settings.columns.height + Settings.columns.y_padding + Settings.list.padding_top + row * (Settings.list.height + Settings.list.spacing_between);
            local plrWidth = width - Settings.list.x_padding;
            local plrHeight = Settings.list.height;

            dxDrawRectangle(plrX, plrY, plrWidth, plrHeight, tocolor(22, 22, 22, 180));

            dxDrawText(player.id, plrX + plrWidth * 0.02, plrY, plrWidth * 0.02, plrHeight, tocolor(200, 200, 200), 11, "roboto-bold", false, "antialiased", "center", "center");
            dxDrawText(player.name, plrX + plrWidth * 0.5, plrY, plrWidth * 0.02, plrHeight, tocolor(200, 200, 200), 11, "roboto-bold", false, "antialiased", "center", "center", true, true, false, true);
            dxDrawText(player.ping.value .. " ms", plrX + plrWidth * 0.92, plrY, plrWidth * 0.06, plrHeight, tocolor(unpack(player.ping.color)), 11, "roboto-bold", false, "antialiased", "right", "center", true, true, false, true);

            row = row + 1;
        end 
    end 

    -- 
    -- Columns
    -- 

    local colX = x + Settings.columns.x_padding / 2;
    local colY = y + HEADER_HEIGHT + Settings.columns.y_padding / 2;
    local colWidth = width - Settings.columns.x_padding;
    local colHeight = Settings.columns.height;

    dxDrawRectangle(
        colX, colY, colWidth, colHeight,
        tocolor(22, 22, 22, 180)
    );

    dxDrawText("ID", colX + colWidth * 0.015, colY, 0, colHeight, tocolor(200, 200, 200), 12, "roboto-bold", false, "antialiased", "left", "center");
    dxDrawText("Név", colX + colWidth * 0.5, colY, 0, colHeight, tocolor(200, 200, 200), 12, "roboto-bold", false, "antialiased", "center", "center");
    dxDrawText("Ping", colX + colWidth * 0.92, colY, colWidth * 0.06, colHeight, tocolor(200, 200, 200), 12, "roboto-bold", false, "antialiased", "right", "center");
end 

function updatePlayerList()
    local list = {};

    for _, player in ipairs(getElementsByType("player")) do 
        local playerData = {
            element = player, 
            id = getElementData(player, 'playerid'), 
            logged = getElementData(player, "loggedIn")
        };

        if (playerData.logged) then 
            local adminLevel = Admin:getPlayerAdminLevel(player);
            local inDuty = Admin:isAdminInDuty(player);

            if (adminLevel >= 3 and inDuty) then 
                playerData.name = Admin:getPlayerAdminName(player) .. Admin:getPlayerAdminColor(player) .. " (" .. Admin:getPlayerAdminTitle(player) .. ")";
            elseif (adminLevel > 0 and adminLevel < 3) then 
                playerData.name = getElementData(player, 'name'):gsub("_", " ") .. Admin:getPlayerAdminColor(player) .. " (" .. Admin:getPlayerAdminTitle(player) .. ")"; 
            else 
                playerData.name = getElementData(player, 'name'):gsub("_", " "); 
            end 
        else 
            playerData.name = getPlayerName(player):gsub("#%x%x%x%x%x%x", "");
        end 

        local pR, pG, pB = interpolateBetween(
            87, 209, 71, 130, 31, 31, 
            calcPercentage(getPlayerPing(player), 0, 999) / 100, 
            "Linear"
        );
        playerData.ping = { value = getPlayerPing(player), color = { pR, pG, pB } };

        table.insert(list, playerData);
    end

    PlayerList = list;
end

local playerKeysWhenShouldUpdate = { ['admin'] = true, ['loggedIn'] = true };
function onElementDataChange(key, old, new)
    local player = source;

    if (
        getElementType(source) ~= 'player' or 
        not playerKeysWhenShouldUpdate[key]
    ) then 
        return;
    end 

    local playerId = getElementData(player, 'playerid');
    local index = table.findIndex(PlayerList, function(i) return (i.id == playerId); end);

    if (index) then
        local playerData = {
            element = player, 
            id = getElementData(player, 'playerid'), 
            logged = getElementData(player, "loggedIn")
        };

        if (adminLevel >= 3 and inDuty) then 
            playerData.name = Admin:getPlayerAdminName(player) .. Admin:getPlayerAdminColor(player) .. " (" .. Admin:getPlayerAdminTitle(player) .. ")";
        elseif (adminLevel > 0 and adminLevel < 3) then 
            playerData.name = getElementData(player, 'name'):gsub("_", " ") .. Admin:getPlayerAdminColor(player) .. " (" .. Admin:getPlayerAdminTitle(player) .. ")"; 
        else 
            playerData.name = getElementData(player, 'name'):gsub("_", " "); 
        end 

        local pR, pG, pB = interpolateBetween(
            87, 209, 71, 130, 31, 31, 
            calcPercentage(getPlayerPing(player), 0, 999) / 100, 
            "Linear"
        );
        playerData.ping = { value = getPlayerPing(player), color = { pR, pG, pB } };

        PlayerList[index] = playerData;
    end
end 

function onScrollUp()
    if (ScrollIndex > 1) then 
        ScrollIndex = ScrollIndex - 1;
    end 
end 

function onScrollDown()
    if (ScrollIndex < #PlayerList - MAX_VISIBLE_ROWS) then 
        ScrollIndex = ScrollIndex + 1;
    end
end 

function onStateChange(key, state)
    if (state == 'down' and not Active) then 
        updatePlayerList();

        bindKey('mouse_wheel_up', 'down', onScrollUp);
        bindKey('mouse_wheel_down', 'down', onScrollDown);
        addEventHandler('onClientElementDataChange', root, onElementDataChange);
        addEventHandler('onClientRender', root, rootRender);
        Active = true;
    elseif (state == 'up' and Active) then 
        unbindKey('mouse_wheel_up', 'down', onScrollUp);
        unbindKey('mouse_wheel_down', 'down', onScrollDown);
        removeEventHandler('onClientRender', root, rootRender);
        removeEventHandler('onClientElementDataChange', root, onElementDataChange);
        Active = false;
    end 
end
bindKey("tab", "both", onStateChange);