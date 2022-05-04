local move_values = {
    jump = -0.03, 
    sprint = -0.01, 
    jog = -0.005,
    stand = 0.015,
    crouch = 0.015,
    crawl = -0.003,
    walk = 0.008,
};

function rootPreRender(delta)
    local stamina = (getElementData(localPlayer, 'stamina') or 100);
    
    local moveState = getPedMoveState(localPlayer);

    if (
        not isPedInVehicle(localPlayer) and 
        move_values[moveState]
    ) then 
        stamina = stamina + move_values[moveState] * delta;

        if (stamina < 0) then stamina = 0;
        elseif (stamina > 100) then stamina = 100; end

        if (
            stamina < 25 and 
            isControlEnabled('jump')
        ) then 
            toggleControl('jump', false);
            toggleControl('sprint', false);
        elseif (
            stamina >= 25 and 
            not isControlEnabled('jump')
        ) then 
            toggleControl('jump', true);
            toggleControl('sprint', true);
        end 

        setElementData(localPlayer, 'stamina', stamina, false);
    end 
end 

addEventHandler('onClientPreRender', root, rootPreRender);