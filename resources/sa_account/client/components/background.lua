Components.background = {};
local comp = Components.background;

local lineWidth = 3;
local linePadding = 1;
local lineColor = tocolor(unpack(Colors.server.rgb));
local samples = (linePadding > 0) and math.ceil(ScreenWidth / lineWidth) or ScreenWidth;

comp.render = function()
    local soundFFT = getSoundFFTData(comp.__music, 2048, samples);
    if (soundFFT) then 
        for i = 0, samples - 1 do 
            local height = math.sqrt(soundFFT[i]) * 256;

            if (height > 150) then 
                height = 150;
            end 

            dxDrawRectangle(i * (lineWidth + linePadding), ScreenHeight - height, lineWidth, height, lineColor);
        end 
    end 

    dxDrawRectangle(0, 0, ScreenWidth, ScreenHeight, tocolor(20, 20, 20, 220));
end

comp.mount = function()
    comp.__music = playSound('client/assets/music.mp3', true);
    addEventHandler('onClientRender', root, comp.render);
end

comp.unmount = function()
    destroyElement(comp.__music);
    removeEventHandler('onClientRender', root, comp.render);
end