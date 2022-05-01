Components.conversation = {};
local component = Components.conversation;

local font = Core:requireFont('opensans-bold', 11);
local font2 = Core:requireFont('opensans-bold', 9);

local materialWidth = 0;
local materialHeight = 0;
local yStartsFrom = 24;

component.elements = {};

component.render = function(x, y, width, height)
    dxDrawRectangle(x, y, width, height, tocolor(20, 20, 20, 255));
    
    if (not isElement(ConversationRT)) then 
        return;
    end 

    if (materialHeight > height * 0.825) then 
        local index = component.elements.message_scrollbar.__index;

        dxDrawImageSection(
            x + width * 0.01, y + height * 0.015, 
            width - width * 0.05, height * 0.825,
            0, index,
            width - width * 0.05, height * 0.825, 
            ConversationRT
        );

        component.elements.message_scrollbar.render(
            x + width * 0.975, y + height * 0.015, 
            width * 0.015, height * 0.825, 
            height * 0.825, materialHeight
        );
    else
        dxDrawImage(
            x + width * 0.01, y + height * 0.015, 
            materialWidth, materialHeight, 
            ConversationRT
        );
    end 

    component.elements.message_input.render(
        x + width * 0.02, y + height * 0.86, 
        width * 0.96, height * 0.12
    );
end

component.redrawRT = function()
    local messages = Conversations[SelectedConversation].messages;

    if (isElement(ConversationRT)) then 
        destroyElement(ConversationRT);
        ConversationRT = nil;
    end 

    local maxMessageWidth = TotalWidth * Config.messageWidth * 0.65 - Config.conversation.innerTextPadding;

    local cached = {};
    local fontHeight = dxGetFontHeight(1, font);
    local totalHeight = yStartsFrom;

    local textPadding = Config.conversation.innerTextPadding;
    local boxPadding = Config.conversation.boxPaddingTop;

    for i, v in ipairs(messages) do 
        local width = dxGetTextWidth(v.content, 1, font, false);
        local height = fontHeight + 4;

        if (width > maxMessageWidth) then 
            width = maxMessageWidth;
            height = dxGetTextHeight(v.content, font, 1, maxMessageWidth) * fontHeight;
        end 

        local isLast = i == #messages;
        totalHeight = totalHeight + (height + textPadding * 2 + (isLast and 0 or boxPadding));

        table.insert(cached, { width = width, height = height, index = i });
    end 

    local width, height = TotalWidth * Config.messageWidth, TotalHeight * (1.0 - Config.headerHeight);
    ConversationRT = dxCreateRenderTarget(width, totalHeight, true);

    materialWidth, materialHeight = dxGetMaterialSize(ConversationRT);

    dxSetRenderTarget(ConversationRT, true);
        local nextY = yStartsFrom;

        for i, v in ipairs(cached) do 
            i = i - 1;

            local xLeft = messages[v.index].isLocal 
                            and (TotalWidth * Config.messageWidth - textPadding - (v.width + textPadding)) * 0.895
                            or 0;

            local boxColor = (messages[v.index].isLocal)
                            and tocolor(6, 108, 205, 150)
                            or tocolor(128, 128, 128, 150);

            dxDrawRectangle(
                xLeft, nextY, 
                v.width + textPadding * 2, v.height + textPadding * 2, 
                boxColor
            );

            dxDrawText(
                messages[v.index].sent, 
                xLeft, nextY, 
                xLeft + v.width, nextY, 
                tocolor(200, 200, 200), 1, font2, 
                messages[v.index].isLocal and 'right' or 'left',
                'bottom'
            );

            dxDrawText(
                messages[v.index].content, 
                xLeft + textPadding, nextY + textPadding, 
                xLeft + v.width + textPadding, nextY + v.height + textPadding, 
                tocolor(200, 200, 200), 
                1, font, 'left', 'top', 
                true, true
            );

            nextY = nextY + (v.height + textPadding * 2 + boxPadding);
        end 

    dxSetRenderTarget(nil, true);
end 

component.mount = function()
    component.elements.message_input = Textarea('message_input');
    component.elements.message_scrollbar = Scrollbar('message_scrollbar');

    component.elements.message_input.on('submit', component.onSubmit);

    component.redrawRT();
    component.ready = true;
end 

component.unmount = function()
    component.elements.message_input.destroy();
    component.elements.message_scrollbar.destroy();

    component.elements.message_input = nil;
    component.elements.message_scrollbar = nil;
    component.ready = false;
end 

component.onSubmit = function(input)
    if (input.value == '') then 
        return iprint('ures az input vetel')
    end 

    local conv = Conversations[SelectedConversation];

    if (not conv or not isElement(conv.player)) then 
        return iprint('lelepett az emberxd');
    end 

    triggerServerEvent('admin:sendPMToPlayer', root, conv.player, input.value);

    table.insert(conv.messages, {
        content = input.value, 
        isLocal = true, 
        sent = 'faszom'
    });

    component.redrawRT();
    input.value = "";
end 