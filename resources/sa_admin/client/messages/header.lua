Components.header = {};
local component = Components.header;

component.render = function(x, y, width, height)
    dxDrawRectangle(x, y, width, height, tocolor(24, 24, 24, 255));
end 