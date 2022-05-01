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

function formatNumber(number, sep)
	assert(type(tonumber(number))=="number", "Bad argument @'formatNumber' [Expected number at argument 1 got "..type(number).."]")
	assert(not sep or type(sep)=="string", "Bad argument @'formatNumber' [Expected string at argument 2 got "..type(sep).."]")
	local str = tostring(number):reverse():gsub("%d%d%d","%1%"..(sep and #sep>0 and sep or ".")):reverse();
    return (str:sub(1, 1) == sep) 
            and str:sub(2)
            or str;
end

function getFormattedDate(timestamp)
    local time = getRealTime(timestamp);

    return string.format(
        "%04d-%02d-%02d %02d:%02d:%02d", 
        time.year + 1900, time.month + 1, 
        time.monthday, time.hour,
        time.minute, time.second
    );
end 

-- <3
-- https://forum.mtasa.com/topic/26520-hex-to-rgb/?do=findComment&comment=276287
function hexToRgb(hex)
    hex = hex:gsub("#","") 
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6));
end 