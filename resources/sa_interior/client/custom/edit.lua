Edit = {
    active = false, 

    components = {},
};

-- addEventHandler(
--     'onClientRender',
--     root, 
--     function()
--         if (getPlayerSerial(localPlayer) ~= '01F3C54CEF90AFB6FEE851E6AEA63492') then 
--             return false;
--         end 

--         for id, component in pairs(Edit.components) do 
--             if (component.render) then 
--                 component.render();
--             end 
--         end 
--     end
-- );