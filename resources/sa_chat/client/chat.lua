Core = exports.sa_core;
Interface = exports.sa_interface;

loadstring(Core:require({ }))();

local X, Y;
local Width, Height;
local Font = Core:requireFont('opensans-bold', 11);
iprint(Font)
local FontHeight = dxGetFontHeight(1, Font);

local Messages = {}; -- { playerName: string, text: string, lines: number }[]; 

local defaultFonts = { "default-normal", "clear-normal", "default-bold-small", "arial" };

function rootRender()
    -- dxDrawRectangle(X, Y, Width, Height, tocolor(0, 0, 0, 150));

    local total_lines = 0;
    for i = 1, #Messages do 
        local message = Messages[i];

        total_lines = total_lines + message.lines;

        local boxY = (Y + Height) - (FontHeight * total_lines);

        dxDrawBorderedText(
            0.25, message.text, 
            X, (boxY > Y) and boxY or Y, 
            X + Width, boxY + FontHeight * message.lines, 
            message.color, 1, Font, 'left', 'bottom', 
            true, true
        );
    end 
end 

function updateMessageList(newMessage)
    local newList = table.filter(table.copy(Messages), function(v, i)
        if (i < 30) then 
            return true;
        end 

        return false;
    end);

    if (newMessage) then 
        table.insert(newList, 1, newMessage);
    end

    local fontHeight = dxGetFontHeight(1, Font);
    newList = table.map(newList, function(msg)
        msg.lines = dxGetTextHeight(msg.text, Font, 1, Width);

        return msg;
    end);

    Messages = newList;
end 

addEvent('addOOCMessage', true);
addEventHandler('addOOCMessage', resourceRoot, function(player, message)
    local playerName;
    local color;

    if (Admin:isAdminInDuty(player)) then 
        local level = Admin:getPlayerAdminLevel(player);
        playerName = Admin:getPlayerAdminTitle(player).. " " .. Admin:getPlayerAdminName(player);
        color = tocolor(hex2rgb(Admin:getAdminLevelColor(level)));
    else 
        playerName = (getElementData(player, 'name') or "Ismeretlen");
        color = tocolor(255, 255, 255);
    end 

    updateMessageList(
        { 
            text = (playerName:gsub("_", " ") .. ': (( ' .. message:gsub("#%x%x%x%x%x%x", "")) .. ' ))', 
            lines = 1, 
            color = color
        }
    );
end);

addEventHandler('onInterfaceUpdate', root, function(id, position, size)
    if (id == 'ooc_chat') then 
        X, Y = position.x, position.y;
        Width, Height = size.x, size.y;

        updateMessageList();
    end 
end);

addEventHandler('onClientResourceStart', resourceRoot, function()
    local chat = getChatboxLayout();

    local fontHeight = dxGetFontHeight(1, defaultFonts[chat.chat_font]);
    local totalHeight = (ScreenHeight * chat.chat_position_offset_y + fontHeight * chat.chat_lines) * chat.chat_scale[2];

    X, Y = ScreenWidth * chat.chat_position_offset_x, totalHeight;
    Width, Height = ScreenWidth * 0.255, ScreenHeight * 0.2;

    Interface:mount('ooc_chat', {
        label = "OOC Chat", 
        position = Vector2(X, Y * 1.1), 
        size = Vector2(Width, Height),

        sizable = true,
        minSize = Vector2(Width * 0.65, Height * 0.5),
        maxSize = Vector2(Width * 1.25, Height * 1.5),
    });

    addEventHandler('onClientRender', root, rootRender);
end);

function hex2rgb(hex) 
    hex = hex:gsub("#", "");
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)) 
end 

-- TODO: valami meno for loopra alapulo outlined textet irni mert ez szanalmas de most megfelel
function dxDrawBorderedText (outline, text, left, top, right, bottom, color, ...)
    for oX = (outline * -1), outline do
        for oY = (outline * -1), outline do
            dxDrawText (text, left + oX, top + oY, right + oX, bottom + oY, tocolor(0, 0, 0, 255), ...)
        end
    end
    dxDrawText (text, left, top, right, bottom, color, ...)
end

addCommandHandler(
    'clearooc', 
    function()
        Messages = {};
    end 
);