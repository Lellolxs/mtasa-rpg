TotalWidth, TotalHeight = 1000, 600;
ContainerX, ContainerY = ScreenWidth / 2 - TotalWidth / 2, ScreenHeight / 2 - TotalHeight / 2;

Components = {};
MessagesActive = false;

Config = {
    headerHeight = 0.08,

    -- Ez osszesen legyen 1.0 mert tul rovid vagy hosszu lesz.
    listWidth = 0.20,
    messageWidth = 0.55,
    actionsWidth = 0.25,

    list = {
        padding = 0.02,
        boxHeight = 0.09, 
    },

    conversation = {
        innerTextPadding = 6,
        boxPaddingTop = 32,
    },
};

ConversationRT = nil; --  Rendertarget a beszelgeteshez hogy folyamatos legyen.
SelectedConversation = nil;
Conversations = {
    [911] = { -- AccountID a key
        player = localPlayer, 
        
        playerCache = {
            account_id = 911, 
            character_id = 911, 
            name = 'Evelyn_Eastwood',

            preview = nil, 
        },

        stats = {

        },

        messages = {
            { content = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Quis viverra nibh cras pulvinar. Venenatis cras sed felis eget velit. Neque ornare aenean euismod elementum.", isLocal = true, sent = "09/11/2001 08:42:24" },
            { content = "Csa tesomsz semmi.", isLocal = false, sent = "09/11/2001 08:46:40" },
        },
    },
};

function rootRender()
    Components.header.render(ContainerX, ContainerY, TotalWidth, TotalHeight * Config.headerHeight);
    Components.list.render(ContainerX, ContainerY + TotalHeight * Config.headerHeight, TotalWidth * Config.listWidth, TotalHeight * (1.0 - Config.headerHeight));

    if (
        not SelectedConversation or 
        not Conversations[SelectedConversation]
    ) then 
        local x, y = ContainerX + (TotalWidth * Config.listWidth), ContainerY + TotalHeight * Config.headerHeight;
        local width, height = TotalWidth * (Config.messageWidth + Config.actionsWidth), TotalHeight * (1.0 - Config.headerHeight);

        dxDrawRectangle(x, y, width, height, tocolor(18, 18, 18, 255));
        dxDrawText(
            "Válassz ki egy beszélgetést kezdésnek.", 
            x, y, x + width, y + height, 
            tocolor(200, 200, 200), 
            1, Core:requireFont('opensans-bold'), 
            'center', 'center'
        );
    else 
        Components.conversation.render(
            ContainerX + (TotalWidth * Config.listWidth), ContainerY + TotalHeight * Config.headerHeight, 
            TotalWidth * Config.messageWidth, TotalHeight * (1.0 - Config.headerHeight)
        );

        Components.actions.render(
            ContainerX + (TotalWidth * Config.listWidth) + (TotalWidth * Config.messageWidth),  
            ContainerY + TotalHeight * Config.headerHeight, 
            TotalWidth * Config.actionsWidth, TotalHeight * (1.0 - Config.headerHeight)
        );
    end 
end 

function rootClick(button, state)
    if (isCursorShowing()) then 
        -- Header
        if (
            isCursorInArea(ContainerX, ContainerY, TotalWidth, TotalHeight * Config.headerHeight) and 
            Components.header.onClick ~= nil
        ) then 
            Components.header.onClick(
                button, state, 
                ContainerX, ContainerY, 
                TotalWidth, TotalHeight * Config.headerHeight
            );
        end 

        -- List
        if (
            isCursorInArea(
                ContainerX, ContainerY + TotalHeight * Config.headerHeight, 
                TotalWidth * Config.listWidth, TotalHeight * (1.0 - Config.headerHeight)
            ) and 
            Components.list.onClick ~= nil
        ) then 
            Components.list.onClick(
                button, state, 
                ContainerX, ContainerY + TotalHeight * Config.headerHeight, 
                TotalWidth * Config.listWidth, TotalHeight * (1.0 - Config.headerHeight)
            );
        end 

        if (
            SelectedConversation and 
            Conversations[SelectedConversation]
        ) then
            -- Conversation
            if (
                isCursorInArea(
                    ContainerX + (TotalWidth * Config.listWidth), ContainerY + TotalHeight * Config.headerHeight, 
                    TotalWidth * Config.messageWidth, TotalHeight * (1.0 - Config.headerHeight)
                ) and 
                Components.conversation.onClick ~= nil
            ) then 
                Components.conversation.onClick(
                    button, state, 
                    ContainerX + (TotalWidth * Config.listWidth), ContainerY + TotalHeight * Config.headerHeight, 
                    TotalWidth * Config.messageWidth, TotalHeight * (1.0 - Config.headerHeight)
                );
            end 

            -- Actions
            if (
                isCursorInArea(
                    ContainerX + (TotalWidth * Config.listWidth) + (TotalWidth * Config.messageWidth),  
                    ContainerY + TotalHeight * Config.headerHeight, 
                    TotalWidth * Config.actionsWidth, TotalHeight * (1.0 - Config.headerHeight)
                ) and 
                Components.actions.onClick ~= nil
            ) then 
                Components.actions.onClick(
                    button, state, 
                    ContainerX + (TotalWidth * Config.listWidth) + (TotalWidth * Config.messageWidth),  
                    ContainerY + TotalHeight * Config.headerHeight, 
                    TotalWidth * Config.actionsWidth, TotalHeight * (1.0 - Config.headerHeight)
                );
            end 
        end 
    end 
end 

function Open()
    addEventHandler('onClientRender', root, rootRender);
    addEventHandler('onClientClick', root, rootClick);
end 

function Close()
    removeEventHandler('onClientRender', root, rootRender);
    removeEventHandler('onClientClick', root, rootClick);
end 

addEvent('admin:setMessagePanelState', true);
addEventHandler('admin:setMessagePanelState', root, function()
    if (not MessagesActive) then 
        MessagesActive = true;
        Open();
    else 
        MessagesActive = false;
        Close();
    end 
end);