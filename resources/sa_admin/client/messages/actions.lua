Components.actions = {};
local component = Components.actions;

component.__uiElements = {};

component.render = function(x, y, width, height)
    dxDrawRectangle(x, y, width, height, tocolor(24, 24, 24, 255));
end 

component.mount = function()

end 

component.unmount = function()

end 