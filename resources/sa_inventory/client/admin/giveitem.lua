Components.give_item = {};
local component = Components.give_item;

local Width, Height = 800 * getResp(), 600 * getResp();
local X, Y = ScreenWidth / 2 - Width / 2, ScreenHeight / 2 - Height / 2;

component.render = function()
    dxDrawRectangle(
        X, Y, Width, Height, 
        tocolor(24, 24, 24)
    );
end

component.mount = function()
    addEventHandler("onClientRender", root, component.render);
end

component.unmount = function()
    removeEventHandler("onClientRender", root, component.render);
end

component.mount();