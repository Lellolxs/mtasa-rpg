addEventHandler('onClientPlayerDamage', root, function()
    if (isAdminInDuty(localPlayer)) then 
        cancelEvent();
    end 
end);

addEvent('admin:copyText', true);
addEventHandler('admin:copyText', root, function(text)
    setClipboard(text);
end);