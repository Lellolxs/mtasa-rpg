function getRotationFromCamera(offset)
	local cameraX, cameraY, _, faceX, faceY = getCameraMatrix()
	local deltaX, deltaY = faceX - cameraX, faceY - cameraY
	local rotation = math.deg(math.atan(deltaY / deltaX))

	if (deltaY >= 0 and deltaX <= 0) or (deltaY <= 0 and deltaX <= 0) then
		rotation = rotation + 180
	end

	return -rotation + 90 + offset
end