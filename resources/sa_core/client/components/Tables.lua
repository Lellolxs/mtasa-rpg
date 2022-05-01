Components['Tables'] = [[
    table = {
        insert = table.insert,
        remove = table.remove, 
        concat = table.concat, 
        sort = table.sort, 
    
        -- Add values from the source table to the target table
        merge=function(a,b)for c,d in pairs(b)do if type(d)=='table'then a[c]=table.merge(a[c]or{},d)else a[c]=d end end;return a end, 
        
        findIndex = function(tbl, cbFn)
            for i = 1, #tbl do 
                if (cbFn(tbl[i], i)) then 
                    return i;
                end 
            end 
    
            return false;
        end
    };
]];