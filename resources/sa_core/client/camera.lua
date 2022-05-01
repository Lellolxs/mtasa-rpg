local active = false;
local start_tick = 0;

function disableCameraCinematic()
    if (active) then 
        active = false;
        removeEventHandler('onClientPreRender', root, render);
    end 
end 

function doCameraCinematic(from, to, time, force)
    if (not from or not to) then 
        return;
    end 

    local time = (time ~= nil) and time or 10000;

    current = { from = from, to = to, time = time };
    start_tick = getTickCount();

    if (not active) then 
        addEventHandler('onClientPreRender', root, render);
        active = true;
    end 
end 

function render()
    local tick = getTickCount();

    local from = current.from;
    local to = current.to;

    local posX, posY, posZ = interpolateBetween(
        from.pos.x, from.pos.y, from.pos.z, 
        to.pos.x, to.pos.y, to.pos.z, 
        (tick - start_tick) / current.time, 
        "InOutQuad"
    );

    local lookX, lookY, lookZ = interpolateBetween(
        from.at.x, from.at.y, from.at.z, 
        to.at.x, to.at.y, to.at.z, 
        (tick - start_tick) / current.time, 
        "InOutQuad"
    );

    setCameraMatrix(posX, posY, posZ, lookX, lookY, lookZ);

    if ((tick - start_tick) / current.time > 1) then 
        removeEventHandler('onClientPreRender', root, render);
        active = false;
    end
end 