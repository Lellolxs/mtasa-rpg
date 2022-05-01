-- __dxDrawText = dxDrawText;
-- dxDrawText = function(text, x, y, width, height, ...)
--     __dxDrawText(text, x, y, x + width, y + height, ...);
-- end 

function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

function findRotation(x1,y1,x2,y2)
	local t = -math.deg(math.atan2(x2-x1,y2-y1))
	if t < 0 then t = t + 360 end;
	return t;
end