local Effects = {
    click = { path = 'client/assets/sfx/click.mp3' },
};

function playEffect(name, time)
    local time = (type(time) ~= 'number') and 1000 or time;

    if (not name or not Effects[name]) then 
        return false;
    end 

    local effect = Effects[name];
    local sound = playSound(effect.path);
    
    setTimer(destroyElement, time, 1, sound);

    return sound;
end 