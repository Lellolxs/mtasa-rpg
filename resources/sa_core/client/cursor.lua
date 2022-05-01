local __getCursorPosition = getCursorPosition;

getCursorPosition = function()
    if (not isCursorShowing()) then return -1, -1; end 
    local cursorX, cursorY = __getCursorPosition();
    return cursorX * ScreenWidth, cursorY * ScreenHeight;
end

isCursorInArea = function(position_or_x, size_or_y, width, height)
    if (not position_or_x or not size_or_y) then 
        return false;
    end 

    if (type(width) ~= 'number' and type(height) ~= 'number') then
        width, height = size_or_y.x, size_or_y.y;
        x, y = position_or_x.x, position_or_x.y;
    end 

    local cursorX, cursorY = getCursorPosition();

    return (
        cursorX > x and cursorX < x + width and 
        cursorY > y and cursorY < y + height
    );
end 

bindKey('m', 'down', function() showCursor(not isCursorShowing()); end);