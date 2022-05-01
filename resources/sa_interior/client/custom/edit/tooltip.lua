Edit.components.tooltip = {};
local component = Edit.components.tooltip;

local width, height = respc(300), respc(50)
local x, y = (ScreenWidth - width) * 0.5, (ScreenHeight - height) * 0.005

local options = {
    { icon = nil, text = 'Változtatások elmentése', handler = function() end }, 
    { icon = nil, text = 'Változtatások elvetése', handler = function() end }, 
    { icon = nil, text = 'Falak módosítása', handler = function() end }, 
};

component.render = function()
    dxDrawRectangle(x, y, width, height, tocolor(31, 31, 31, 240));

    local cursorX, cursorY = getCursorAbsolute();

    local index = 0;
    for i, v in ipairs(options) do 
        dxDrawRectangle(x + (index * 35), y, 32, 32, tocolor(255, 0, 0, 150)); 
        
        if (cursorInBox(x + (index * 35), y, 32, 32)) then 
            showTooltip(cursorX + 32, cursorY - 10, v.text, v.text);
        end 

        index = index + 1;
    end 
end 

component.click = function(button, state, cursorX, cursorY)

end