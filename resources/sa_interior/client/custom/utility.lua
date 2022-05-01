function showTooltip(x, y, text, text2)
	text = tostring(text)
	local alphaMultipler = 1;

	if text2 then
		text2 = tostring(text2)
	end

	if text == text2 then
		text2 = nil
	end

	local w = dxGetTextWidth(text, 1, Fonts.robotomd, true) + 10
	local h = 3

	if text2 then
		w = math.max(w, dxGetTextWidth(text2, 1, Fonts.robotomd, true) + 10)
		_, h = utf8.gsub(text2, "\n", "")
		h = h + 5
		text = text .. "\n#ffffff" .. text2
	end

	h = 10 * h

	dxDrawRectangle(x - 1, y - 1, w + 2, h + 2, tocolor(50, 50, 50, 240 * alphaMultipler))
	dxDrawRectangle(x, y, w, h, tocolor(28, 28, 28, 240 * alphaMultipler))
	dxDrawText(text, x, y, x + w, y + h, tocolor(255, 255, 255, 255 * alphaMultipler), 1, Fonts.robotomd, "center", "center", false, false, false, true)
end

function getCursorAbsolute()
	if (not isCursorShowing()) then return -1, -1; end
	local cursorX, cursorY = getCursorPosition();
	return cursorX * ScreenWidth, cursorY * ScreenHeight;
end 

function cursorInBox(x, y, width, height)
	if (not isCursorShowing()) then 
		return false;
	end 

	local cursorX, cursorY = getCursorAbsolute();

	return (
		cursorX > x and cursorX < x + width and 
		cursorY > y and cursorY < y + height
	);
end 