local __Fonts = {};

__dxDrawText = dxDrawText;
function dxDrawText(text, x, y, width, height, color, size, font, ...)
    local _font = __Fonts[font .. size];
    if (not _font) then 
        __Fonts[font .. size] = Core:requireFont(font, size * getResp());
        _font = __Fonts[font .. size];
    end 

    return __dxDrawText(text, x, y, x + (width or 0), y + (height or 0), color, 1, _font, ...);
end 

function dxDrawBorderedRectangle(x, y, width, height, border, borderColor, middleColor)
    dxDrawRectangle(x + border, y + border, width - border * 2, height - border * 2, middleColor, postGUI);
    dxDrawRectangle(x, y, width, border, borderColor); -- top
    dxDrawRectangle(x, y + border, border, height - border * 2, borderColor); -- left
    dxDrawRectangle(x + width - border, y + border, border, height - border * 2, borderColor); -- right
    dxDrawRectangle(x, y + height - border, width, border, borderColor); -- bottom
end 