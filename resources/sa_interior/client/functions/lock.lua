function onLockBind()
    triggerServerEvent('sInterior:setLockState', root, Interior.id, not Interior.locked);
end 