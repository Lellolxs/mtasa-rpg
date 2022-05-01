Components.navbar = {};
local component = Components.navbar;
local settings = Config.components.navbar;

component.mountOnLoad = true;

local width, height = TotalWidth * settings.size.x, TotalHeight * settings.size.y;
local x, y = ContainerX + TotalWidth * settings.position.x, ContainerY + TotalHeight * settings.position.y;

local lastPageSwitchTick = getTickCount();
local beforeItemIndex = 0;
local currentItemIndex = 0;
local indicatorAnimInterval = 500;
local logoBlinkingInterval = 2500;

local titleColor = Core:getColor("server").rgb;
titleColor[4] = 180;
titleColor = tocolor(unpack(titleColor));

component.render = function()
    dxDrawRectangle(x, y, width, height, settings.background);

    local logoWidth, logoHeight = math.floor(width * 0.235), math.floor(height * 0.075);
    dxDrawImage(x + width * 0.055, y + height * 0.025, logoWidth, logoHeight, ":sa_core/client/assets/logo.png", 0, 0, 0, tocolor(255, 255, 255, 180));
    dxDrawText(
        "Dashboard", x + width * 0.4, y + height * 0.0225, width * 0.765, height * 0.08, 
        titleColor, 15, "opensans-bold", 
        "left", "center", true, true, true
    );

    local tick = getTickCount();
    local rowHeight = height * 0.06;
    local rowPadding = rowHeight * 1.1;
    local indicatorY = interpolateBetween(
        (y + height * 0.125 + beforeItemIndex * rowPadding), 0, 0, 
        (y + height * 0.125 + currentItemIndex * rowPadding), 0, 0,
        (tick - lastPageSwitchTick) / indicatorAnimInterval, "InOutQuad"
    );

    dxDrawRectangle(
        x + width - (width * settings.indicatorSize.x), 
        indicatorY + rowHeight / 2 - (settings.indicatorSize.y * height) / 2, 
        width * settings.indicatorSize.x, 
        height * settings.indicatorSize.y, 
        tocolor(200, 200, 200)
    );

    for i, pageId in ipairs(Config.page_order) do 
        i = i - 1;

        local page = Pages[pageId];

        if (page) then 
            local rowY = y + height * 0.125 + i * rowPadding;
            local textAlpha = 80;

            if (pageId == CurrentPage) then 
                textAlpha = interpolateBetween(
                    80, 0, 0, 
                    220, 0, 0, 
                    (tick - lastPageSwitchTick) / indicatorAnimInterval, "InOutQuad"
                );
            end 

            -- Icon
            dxDrawText(
                page.icon, 
                x + width * 0.06, 
                rowY, 
                width * 0.1, 
                rowHeight, 
                tocolor(200, 200, 200, textAlpha), 
                11, "fa-solid", "center", "center"
            );

            -- Label
            dxDrawText(
                page.label, 
                x + width * 0.225, 
                rowY, 
                width * 0.6, 
                rowHeight, 
                tocolor(200, 200, 200, textAlpha), 
                14, "opensans", "left", "center"
            );
        end 
    end 
end 

component.onclick = function(button, state)
    if (button ~= 'left' or state ~= 'down') then 
        return;
    end 

    if ((lastPageSwitchTick + indicatorAnimInterval) > getTickCount()) then 
        return;
    end 

    for i, pageId in ipairs(Config.page_order) do 
        i = i - 1;
        local page = Pages[pageId];

        if (page) then 
            local rowHeight = height * 0.06;
            local rowPadding = rowHeight * 1.1;
            local rowY = y + height * 0.125 + i * rowPadding;

            if (isCursorInArea(x, rowY, width, height * 0.05)) then 
                local currPage = Pages[CurrentPage];

                if (pageId == CurrentPage) then 
                    return;
                end 

                if (
                    currPage and 
                    currPage.unmount ~= nil and 
                    currPage.unmount() == false 
                ) then 
                    iprint('nemtud unmount');
                    return;
                end 

                if (
                    page and 
                    page.mount and 
                    page.mount() == false
                ) then 
                    iprint('nemtud mount');
                    return;
                end 

                Core:playEffect('click', 1500);

                lastPageSwitchTick = getTickCount();
                beforeItemIndex = currentItemIndex;
                currentItemIndex = i;
                CurrentPage = pageId;
            end 
        end 
    end 
end 

component.mount = function()
    addEventHandler('onClientClick', root, component.onclick);

    component.active = true;
end 

component.unmount = function()
    removeEventHandler('onClientClick', root, component.onclick);

    component.active = false;
end 