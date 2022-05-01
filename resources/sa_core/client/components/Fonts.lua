local Fonts = {
    ['fontawesome'] = 'client/assets/fonts/fontawesome.otf',
    ['fa-solid'] = 'client/assets/fonts/fontawesome-solid.ttf',
    ['opensans-bold'] = 'client/assets/fonts/OpenSans-Bold.ttf',
    ['opensans-light'] = 'client/assets/fonts/OpenSans-Light.ttf',
    ['opensans'] = 'client/assets/fonts/OpenSans-Regular.ttf',
    ['lunabar'] = 'client/assets/fonts/lunabar.ttf',

    ['roboto-black'] = 'client/assets/fonts/Roboto-Black.ttf',
    ['roboto-black-italic'] = 'client/assets/fonts/Roboto-BlackItalic.ttf',
    ['roboto-bold'] = 'client/assets/fonts/Roboto-Bold.ttf',
    ['roboto-bold-italic'] = 'client/assets/fonts/Roboto-BoldItalic.ttf',
    ['roboto-italic'] = 'client/assets/fonts/Roboto-Italic.ttf',
    ['roboto-light'] = 'client/assets/fonts/Roboto-Light.ttf',
    ['roboto-light-italic'] = 'client/assets/fonts/Roboto-LightItalic.ttf',
    ['roboto-medium'] = 'client/assets/fonts/Roboto-Medium.ttf',
    ['roboto-medium-italic'] = 'client/assets/fonts/Roboto-MediumItalic.ttf',
    ['roboto'] = 'client/assets/fonts/Roboto-Regular.ttf',
    ['roboto-thin'] = 'client/assets/fonts/Roboto-Thin.ttf',
    ['roboto-thin-italic'] = 'client/assets/fonts/Roboto-ThinItalic.ttf',
};

local Cache = {};

function requireFont(font, size, ...)
    assert(Fonts[font], 'Bad argument 1 @ requireFont (Specified font doesn\'t exist.)');
    assert(fileExists(Fonts[font]), 'Bad argument 1 @ requireFont (Font file with this name doesn\'t exist.)');

    if (not size) then 
        size = 11;
    end 

    size = math.floor(size * (ScreenWidth + 2048) / (2048 * 2));

    assert(type(size), 'Bad argument 2 @ requireFont ("'..type(size)..'" font size is invalid.)');

    if (Cache[font .. size]) then
        return Cache[font .. size]; 
    end 

    Cache[font .. size] = dxCreateFont(Fonts[font], size, ...);

    return Cache[font .. size];
end 