function onEnterBind()
    if (Interior) then 
        triggerServerEvent('sInterior:enterInterior', root, Interior.id, 'enter');
    end 
end 