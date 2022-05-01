Core = exports.sa_core;

ScreenWidth, ScreenHeight = guiGetScreenSize();
ScreenSource = dxCreateScreenSource(ScreenWidth, ScreenHeight);
Shader, Technique = nil;

local Font = Core:requireFont('opensans-bold', 24);

DeathTick = getTickCount();

local Active = false;
local Camera = nil;
local Music = nil;

local requestedRevive = false;

local Settings = {
    text = { in_delay = 5000, fade_interval = 10000 },
    fov = { interval = 3000, target = 100 },
    position = { interval = 6000, diff = 5 },
    shader = { interval = 5000, fade_out = 8000 },
    total_time = 60000 * 10,
};

function render(delta) 
    if (Shader) then 
        local tick = getTickCount();

        --
        -- vege!??!?!
        -- 

        if (
            tick > DeathTick + Settings.total_time and  
            not requestedRevive
        ) then 
            iprint('halo velte?!?!?')
            requestedRevive = true;
            triggerServerEvent('onPlayerDeathTimeUp', resourceRoot);
        end 

        -- 
        -- Shader effect
        -- 

        local intensity = interpolateBetween(0, 0, 0, 1, 0, 0, (tick - DeathTick) / Settings.shader.interval, "InOutQuad");
        local darkness = 0.4;

        if (tick > (DeathTick + Settings.total_time - Settings.shader.fade_out)) then 
            darkness = interpolateBetween(
                0.0, 0.0, 0.0, 
                0.4, 0.0, 0.0, 
                (DeathTick + Settings.total_time - tick) / Settings.shader.fade_out, 
                "Linear"
            );
        end 

        dxUpdateScreenSource(ScreenSource);
        dxSetShaderValue(Shader, "screenSource", ScreenSource);
        dxSetShaderValue(Shader, "intensity", intensity);
        dxSetShaderValue(Shader, "darkness", darkness);
        dxDrawImage(0, 0, ScreenWidth, ScreenHeight, Shader, 0, 0, 0, tocolor(0, 0, 0, 200));

        -- 
        -- Text cucc
        -- 

        local textAlpha = interpolateBetween(
            0, 0, 0, 
            200, 0, 0, 
            (tick < DeathTick + Settings.total_time / 2)
                and ((tick - DeathTick) / Settings.text.fade_interval) -- fade in
                or ((DeathTick + Settings.total_time - tick) / Settings.text.fade_interval), -- fade out
            "Linear"
        );

        dxDrawText(
            getFormattedTime(DeathTick + Settings.total_time - tick), 
            0, 0, ScreenWidth * 0.975, ScreenHeight * 0.975, 
            tocolor(200, 200, 200, textAlpha), 
            1, Font, 'right', 'bottom'
        );
        
        --
        -- Camera cucc
        -- 

        local x, y, z = getElementPosition(localPlayer);
        local fov = interpolateBetween(Camera[8], 0, 0, Settings.fov.target, 0, 0, (tick - DeathTick) / Settings.fov.interval, "InOutQuad");
        local cx, cy, cz = interpolateBetween(
            x, y, z + 1.5, 
            Camera[1], Camera[2], Camera[3] + Settings.position.diff, 
            (tick - DeathTick) / Settings.position.interval, 
            "InOutQuad"
        );

        setCameraMatrix(
            cx, cy, cz,
            x, y, z,
            Camera[7], fov
        );
    end 
end 

function Start()
    Shader, Technique = dxCreateShader('client/assets/shaders/blackandwhite.fx');
    DeathTick = getTickCount();

    setGameSpeed(0.35);
    setCameraTarget(localPlayer);

    Camera = { getCameraMatrix() };

    if (Shader) then 
        addEventHandler('onClientPreRender', root, render);
    end 

    showChat(false);
    exports.sa_name:toggle(false, true)

    Music = playSound('client/assets/music.mp3', true, false);
    Active = true;
end 

function Stop()
    removeEventHandler('onClientPreRender', root, render);
    setCameraTarget(localPlayer);
    setGameSpeed(1.0);
    Camera = nil;

    if (isElement(Music)) then 
        destroyElement(Music);
    end 

    if (isElement(Shader)) then 
        destroyElement(Shader);
    end 

    showChat(true);
    exports.sa_name:toggle(true, true);

    Active = false;
end 

addEventHandler('onClientResourceStop', resourceRoot, function()
    Stop();
end);

addEventHandler('onClientPlayerWasted', localPlayer, function()
    Start();
end);

addEvent("death:toggle", true);
addEventHandler("death:toggle", resourceRoot, function(state)
    if (not state and Active) then 
        Stop();
    elseif (state and not Active) then 
        Start();
    end 
end);

function getFormattedTime(ms)
    local s = ms / 1000;
    return string.format("%.2d:%.2d", s / 60 % 60, s % 60);
end 