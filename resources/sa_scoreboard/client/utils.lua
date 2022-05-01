local __Fonts = {};

__dxDrawText = dxDrawText;
function dxDrawText(text, x, y, width, height, color, size, font, fontIsBold, fontAliasing, ...)
    local _font = __Fonts[font .. size];
    if (not _font) then 
        __Fonts[font .. size] = Core:requireFont(font, size * getResp(), fontIsBold, fontAliasing);
        _font = __Fonts[font .. size];
    end 

    return __dxDrawText(text, x, y, x + (width or 0), y + (height or 0), color, 1, _font, ...);
end 

function calcPercentage(val, min, max)
    return ((val - min) * 100) / (max - min);
end 