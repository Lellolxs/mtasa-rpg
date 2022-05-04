Components = {};

local default_str = [[
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
        merge=function(a,b)local c={}for d,e in pairs(b)do if type(e)=='table'then c[d]=table.merge(a[d]or{},e)else c[d]=e end end;return c end,
        findIndex=function(a,b)for c=1,#a do if b(a[c],c)then return c end end;return false end,
        findIndex_keytbl=function(a,b)for c,d in pairs(a)do if b(d,c)then return c end end;return false end,
        find=function(a,b)for c=1,#a do if b(a[c],c)then return a[c]end end;return false end,
        find_keytbl=function(a,b)for c,d in pairs(a)do if b(d,c)then return d,c; end end;return false end,
        map=function(a,b)local c={}for d=1,#a do c[d]=b(a[d],d,a)end;return c end, 
        map_keytbl=function(a,b)local c={}for k,v in pairs(a) do c[k]=b(v,k,a)end;return c end, 
        filter=function(a,b)local c={}for d=1,#a do if b(a[d],d)then table.insert(c,a[d])end end;return c end, 
        filter_keytbl=function(a,b)local c={}for d,e in pairs(a)do if b(e,d)then c[d]=e end end;return c end, 
        copy=function(a)local b={}for c,d in pairs(a)do b[c]=d end;return b end, 
        compare_keytbl=function(a,b)for c,d in pairs(a)do if not b[c]or type(d)~=type(b[c])or d~=b[c]then return false end end;return true end, 
        reduce=function(a,b,c)local d=c or 0;for e=1,#a do d=b(d,a[e],e)end;return d end, 
        reduce_tblkey=function(a,b,c)local d=c or 0;for e,f in pairs(a)do d=b(d,f,e)end;return d end
    };
]]

local replaces = {
    ['_OPENDOUBLEBRACKET_'] = '[[',
    ['_CLOSEDOUBLEBRACKET_'] = ']]',
}

function require(list)
    if (type(list) == 'string') then 
        return Components[list];
    elseif (type(list) == 'table') then 
        local str = default_str;

        for _, comp in ipairs(list) do 
            if (comp and Components[comp]) then 
                str = str .. (
                    Components[comp] .. '\n\n'
                );
            end 
        end 

        for key, value in pairs(replaces) do 
            str = str:gsub(key, value);
        end 

        return str;
    end 

    return nil;
end 