Components = {};

local default_str = [[
    ScreenWidth, ScreenHeight = guiGetScreenSize();
    __visibilityDiff = 100;

    getResp = function()
        return (ScreenWidth + 2048) / (2048 * 2);
    end 

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

        local x, y = position_or_x, size_or_y;

        if (width == nil and height == nil) then
            width, height = size_or_y.x, size_or_y.y;
            x, y = position_or_x.x, position_or_x.y;
        end 

        local cursorX, cursorY = getCursorPosition();

        return (
            cursorX > x and cursorX < x + width and 
            cursorY > y and cursorY < y + height
        );
    end 

    -- https://forum.mtasa.com/topic/112950-help-whole-text-height-calculating/?do=findComment&comment=936992
    -- <3
    dxGetTextHeight = function(text, font, fontSize, rectangeWidth)
        local line_text = ""
        local line_count = 1
            
        for word in text:gmatch("%S+") do
            local temp_line_text = line_text .. " " .. word
                
            local temp_line_width = dxGetTextWidth(temp_line_text, fontSize, font)
            if temp_line_width >= rectangeWidth then
                line_text = word
                line_count = line_count + 1
            else
                line_text = temp_line_text
            end
        end
            
        return line_count
    end
        
    table = {
        insert = table.insert,
        remove = table.remove, 
        concat = table.concat, 
        sort = table.sort, 
        setn = table.setn,
        maxn = table.maxn,
        getn = table.getn,
        foreachi = table.foreachi,
        foreach = table.foreach,
    
        -- Add values from the source table to the target table
        merge=function(a,b)for c,d in pairs(b)do if type(d)=='table'then a[c]=table.merge(a[c]or{},d)else if not a[c] then a[c]=d end end end;return a end,
        findIndex=function(a,b)for c=1,#a do if b(a[c],c)then return c end end;return false end,
        findIndex_keytbl=function(a,b)for c,d in pairs(a)do if b(d,c)then return c end end;return false end,
        find=function(a,b)for c=1,#a do if b(a[c],c)then return a[c]end end;return false end,
        find_keytbl=function(a,b)for c,d in pairs(a)do if b(d,c)then return d end end;return false end,
        map=function(a,b)local c={}for d=1,#a do c[d]=b(a[d],d,a)end;return c end, 
        filter=function(a,b)local c={}for d=1,#a do if b(a[d],d)then table.insert(c,a[d])end end;return c end, 
        filter_keytbl=function(a,b)local c={}for d,e in pairs(a)do if b(e,d)then c[d]=e end end;return c end, 
        copy=function(a)local b={}for c,d in pairs(a)do b[c]=d end;return b end, 
        compare_keytbl=function(a,b)for c,d in pairs(a)do if not b[c]or type(d)~=type(b[c])or d~=b[c]then return false end end;return true end, 
        reduce=function(a,b,c)local d=c or 0;for e=1,#a do d=b(d,a[e],e)end;return d end, 
        reduce_tblkey=function(a,b,c)local d=c or 0;for e,f in pairs(a)do d=b(d,f,e)end;return d end
    };
]]

local after_default = [[
    addEventHandler('onClientClick', root, function(button, state)
        if (not isCursorShowing() or button ~= 'left' or state ~= 'down') then return; end
        local tick = getTickCount();

        if (__Editboxes) then 
            for id, v in pairs(__Editboxes) do 
                if (
                    v.__lastVisible and 
                    (v.__lastVisible + __visibilityDiff) > tick and 
                    (v.__position ~= nil and v.__size ~= nil) and 
                    isCursorInArea(v.__position, v.__size)
                ) then
                    __SelectedEditbox = id;
                    guiSetInputMode("no_binds");
                    v.__emitEvent('focus');

                    return;
                end 
            end 
        end 

        if (__Textareas) then 
            for id, v in pairs(__Textareas) do 
                if (
                    v.__lastVisible and 
                    (v.__lastVisible + __visibilityDiff) > tick and 
                    (v.__position ~= nil and v.__size ~= nil) and 
                    isCursorInArea(v.__position, v.__size)
                ) then
                    __SelectedTextarea = id;
                    guiSetInputMode("no_binds");
                    v.__emitEvent('focus');

                    return;
                end 
            end 
        end 

        guiSetInputMode("allow_binds");
        __SelectedEditbox = nil;
        __SelectedTextarea = nil;
    end);
]]

local replaces = {
    ['_OPENDOUBLEBRACKET_'] = '[[',
    ['_CLOSEDOUBLEBRACKET_'] = ']]',
}

function require(list)
    if (type(list) == 'string') then 
        return default_str .. '\n\n' .. Components[list];
    elseif (type(list) == 'table') then 
        local str = default_str;

        for _, comp in ipairs(list) do 
            if (comp and Components[comp]) then 
                str = str .. (
                    Components[comp] .. '\n\n'
                );
            end 
        end 

        str = str .. '\n\n' .. after_default;

        for key, value in pairs(replaces) do 
            str = str:gsub(key, value);
        end 

        return str;
    end 

    return nil;
end 