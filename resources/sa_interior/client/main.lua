ScreenWidth, ScreenHeight = guiGetScreenSize();
Interior = nil; -- Jelenlegi interior adatok

function reMap(value, low1, high1, low2, high2)
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

local responsiveMultiplier = math.min(1, reMap(ScreenWidth, 1024, 1920, 0.75, 1))

Fonts = {
    robotomd = dxCreateFont('client/assets/fonts/roboto.ttf', 12),
    robotosm = dxCreateFont('client/assets/fonts/roboto.ttf', 9),
    falg = dxCreateFont('client/assets/fonts/fontawesome.otf', 18),
    faxl1 = dxCreateFont('client/assets/fonts/fontawesome.otf', 75),
    faxl2 = dxCreateFont('client/assets/fonts/fontawesome.otf', 100)
};

InteriorIcons = {
    house = '',
    business = '',
    government = '',
    rentable = '',
    garage = '',
};

function respc(value)
    return math.ceil(value * responsiveMultiplier)
end