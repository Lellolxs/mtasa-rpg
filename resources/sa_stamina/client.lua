local stamina = 100
local animRequested = false

toggleAllControls(true, true, true)

function getStamina()
	return stamina
end

local lastSpacePush = 0
function checkMoving()
	local moveState = getPedMoveState(localPlayer)
	if getTickCount()-lastSpacePush < 1000 and moveState ~= "sprint" then
		moveState = "sprint"
	end
	if moveState and (moveState == "sprint" or moveState == "jog" or moveState == "climb" or moveState == "jump") and not getElementData(localPlayer, "user:adminduty") and not isPedDead(localPlayer) and not getPedOccupiedVehicle(localPlayer) then
		if stamina >= 0.2 then
			if moveState == "jump" then
				stamina = stamina - 0.1
			elseif moveState == "jog" then
				stamina = stamina - 0.02
			else
				stamina = stamina - 0.05
			end

			if animRequested then
				toggleAllControls(true, true, true)
				animRequested = false
				setElementData(localPlayer, "staminaBlock", nil, false)
				triggerServerEvent("syncAnimation", localPlayer, nil, nil)
			end
		else
			if not animRequested then
				toggleAllControls(false, true, false)
				setElementData(localPlayer, "staminaBlock", true, false)
				triggerServerEvent("syncAnimation", localPlayer, "FAT", "idle_tired", 8000, true, false, true, false)
				animRequested = true
			end
		end
	else
		if stamina < 100 then
			stamina = stamina + 0.1
			if stamina >= 20 then
				if animRequested then
					animRequested = false
					toggleAllControls(true, true, true)
					setElementData(localPlayer, "staminaBlock", nil, false)
					triggerServerEvent("syncAnimation", localPlayer, nil, nil);
				end
			end
		end
	end

    setElementData(localPlayer, "stamina", stamina, false);
end
addEventHandler("onClientRender", root, checkMoving)

addEventHandler("onClientKey", root, function()
	if getPedControlState("sprint") then
		lastSpacePush = getTickCount()
	end
end)