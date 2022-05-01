Components.list = {};
local component = Components.list;

component.render = function(x, y, width, height)
    dxDrawRectangle(x, y, width, height, tocolor(16, 16, 16, 255));

    local convsIndex = 0;
    for k,v in pairs(Conversations) do 
        local paddingX, paddingY = width * Config.list.padding, height * Config.list.padding;

        local boxX, boxY = x + paddingX, y + paddingY + ((height * Config.list.boxHeight) * convsIndex);
        local boxWidth, boxHeight = width - paddingX * 2, height * Config.list.boxHeight;

        dxDrawRectangle(
            boxX, boxY, 
            boxWidth, boxHeight, 
            tocolor(255, 0, 0, 50)
        );

        dxDrawText(
            v.playerCache.name, 
            boxX, boxY, boxX + boxWidth, boxY + boxHeight * 0.5, 
            tocolor(200, 200, 200), 1, Core:requireFont('opensans-bold'), 
            'left', 'bottom'
        );

        local lastMessage = v.messages[#v.messages].content;
        dxDrawText(
            string.len(lastMessage) > 32 and string.sub(lastMessage, 0, 32) .. '...' or lastMessage, 
            boxX, boxY + boxHeight * 0.5, boxX + boxWidth, boxY + boxHeight, 
            tocolor(200, 200, 200), 1, Core:requireFont('opensans', 10), 
            'left', 'top'
        );

        convsIndex = convsIndex + 1;
    end 

    if (convsIndex <= 0) then 
        dxDrawText(
            "Nincs uzeneted lol", 
            x, y, x + width, y + height, 
            tocolor(200, 200, 200), 1, 
            Core:requireFont('opensans-bold'), 
            'center', 'center'
        );
    end 
end 

component.onClick = function(button, state, x, y, width, height)
    local convsIndex = 0;
    for k,v in pairs(Conversations) do 
        local paddingX, paddingY = width * Config.list.padding, height * Config.list.padding;

        local boxX, boxY = x + paddingX, y + paddingY + ((height * Config.list.boxHeight) * convsIndex);
        local boxWidth, boxHeight = width - paddingX * 2, height * Config.list.boxHeight;

        if (isCursorInArea(boxX, boxY, boxWidth, boxHeight)) then 
            SelectedConversation = k;

            if (not Components.conversation.ready) then 
                Components.conversation.mount();
            end 

            return;
        end 

        convsIndex = convsIndex + 1;
    end 

    if (convsIndex <= 0) then 
        iprint('nincs conv')
    end 
end