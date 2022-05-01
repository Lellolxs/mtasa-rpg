local flyKeys = {};

local function render()
    local x, y, z = getElementPosition(localPlayer)
	local speed = 10

	if flyKeys.a == "down" then
		speed = 3
	elseif flyKeys.s == "down" then
		speed = 150
	end

	if flyKeys.f == "down" then
		local angle = getRotationFromCamera(0)

		setElementRotation(localPlayer, 0, 0, angle)

		angle = math.rad(angle)
		x = x + math.sin(angle) * 0.1 * speed
		y = y + math.cos(angle) * 0.1 * speed
	elseif flyKeys.b == "down" then
		local angle = getRotationFromCamera(180)

		setElementRotation(localPlayer, 0, 0, angle)

		angle = math.rad(angle)
		x = x + math.sin(angle) * 0.1 * speed
		y = y + math.cos(angle) * 0.1 * speed
	end

	if flyKeys.l == "down" then
		local angle = getRotationFromCamera(-90)

		setElementRotation(localPlayer, 0, 0, angle)

		angle = math.rad(angle)
		x = x + math.sin(angle) * 0.1 * speed
		y = y + math.cos(angle) * 0.1 * speed
	elseif flyKeys.r == "down" then
		local angle = getRotationFromCamera(90)

		setElementRotation(localPlayer, 0, 0, angle)

		angle = math.rad(angle)
		x = x + math.sin(angle) * 0.1 * speed
		y = y + math.cos(angle) * 0.1 * speed
	end

	if flyKeys.up == "down" then
		z = z + 0.1 * speed
	elseif flyKeys.down == "down" then
		z = z - 0.1 * speed
	end

	setElementPosition(localPlayer, x, y, z)
end 

local function keyHandler(key, state)
	if key == "lshift" or key == "rshift" or key == "mouse1" then
		flyKeys.s = state
	end
	if key == "lctrl" or key == "rctrl" then
		flyKeys.down = state
	end

	if key == "forwards" then
		flyKeys.f = state
	end
	if key == "backwards" then
		flyKeys.b = state
	end

	if key == "left" then
		flyKeys.l = state
	end
	if key == "right" then
		flyKeys.r = state
	end

	if key == "lalt" or key == "ralt" then
		flyKeys.a = state
	end

	if key == "space" then
		flyKeys.up = state
	end
end

local function toggle(state)
    if state then
		addEventHandler("onClientRender", getRootElement(), render)

		bindKey("lshift", "both", keyHandler)
		bindKey("rshift", "both", keyHandler)
		bindKey("lctrl", "both", keyHandler)
		bindKey("rctrl", "both", keyHandler)
		bindKey("mouse1", "both", keyHandler)

		bindKey("forwards", "both", keyHandler)
		bindKey("backwards", "both", keyHandler)
		bindKey("left", "both", keyHandler)
		bindKey("right", "both", keyHandler)

		bindKey("lalt", "both", keyHandler)
		bindKey("ralt", "both", keyHandler)

		bindKey("space", "both", keyHandler)

		setElementCollisionsEnabled(localPlayer, false)
	else
		removeEventHandler("onClientRender", getRootElement(), render)

		unbindKey("lshift", "both", keyHandler)
		unbindKey("rshift", "both", keyHandler)
		unbindKey("lctrl", "both", keyHandler)
		unbindKey("rctrl", "both", keyHandler)
		unbindKey("mouse1", "both", keyHandler)

		unbindKey("forwards", "both", keyHandler)
		unbindKey("backwards", "both", keyHandler)
		unbindKey("left", "both", keyHandler)
		unbindKey("right", "both", keyHandler)

		unbindKey("lalt", "both", keyHandler)
		unbindKey("ralt", "both", keyHandler)

		unbindKey("space", "both", keyHandler)

		setElementCollisionsEnabled(localPlayer, true)
	end
end 

addEventHandler('onClientElementDataChange', root, function(key, old, new)
    if (source == localPlayer and key == 'admin:fly') then 
        toggle(new == true);
    end 
end);