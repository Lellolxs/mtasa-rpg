
function getElementWithinInteriorEntrace(player, onlyId)
    if (isElement(player)) then 
        for id, interior in pairs(Interiors) do 
            if (
                isElementWithinColShape(player, interior.entrace) or 
                isElementWithinColShape(player, interior.exit)
            ) then 
                return (onlyId and interior.id or interior);
            end 
        end 
    end 

    return false;
end 

function getInteriorFromId(interiorId) 
	return (type(interiorId) == 'number' and Interiors[interiorId]) 
				and Interiors[interiorId]
				or nil;
end 

function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;

    return x + dx, y + dy;
end

function getInteriorEntraceRotationFromWall(door, interiorSize)
	local walls = interiorSize * interiorSize;

	-- Clampeles, illetve hogy pont nem sarokba dobja-e az ajtot..

	if (door > walls) then 
		door = walls;
	end 

	if (door % interiorSize == 0) then 
		if (door + 1 < walls) then 
			door = door + 1;
		elseif (door - 1 > walls) then 
			door = door - 1;
		end 
	end 

	-- aaaaaa

	local rotation = 0;

	if (door < walls * 0.5) then 
		if (door < walls * 0.25) then 
			rotation = 0;
		else 
			rotation = 90;
		end 
	else 
		if (door < walls * 0.75) then 
			rotation = 180;
		else 
			rotation = 270;
		end 
	end 

	return rotation, door;
end 

-- Szutyok sarp faszsagok

local getServerPrefix = function() return ' '; end

function outputUsageText(commandName, string, playerSource)
	if isElement(playerSource) then
		outputChatBox(getServerPrefix("server", "Ingatlan") .. "/" .. commandName .. " " .. string, playerSource, 255, 255, 255, true)
	end
end

function outputInfoText(string, playerSource)
	if isElement(playerSource) then
		outputChatBox(getServerPrefix("server", "Ingatlan") .. string, playerSource, 255, 255, 255, true)
	end
end

function outputAdminText(string, playerSource)
	if isElement(playerSource) then
		outputChatBox(getServerPrefix("server", "Ingatlan") .. string, playerSource, 255, 255, 255, true)
	end
end

function outputErrorText(string, playerSource)
	if isElement(playerSource) then
		outputChatBox(getServerPrefix("red-dark", "Ingatlan") .. string, playerSource, 255, 255, 255, true)
		--exports.sarp_core:playSoundForElement(playerSource, ":sarp_assets/audio/admin/error.ogg")
	end
end

function havePermission(playerSource, command, forceDuty, helperLevel)
	if isElement(playerSource) then
		if getElementData(playerSource, PlayerEnum.admin) >= 7 then
			return true
		end

		if getElementData(playerSource, PlayerEnum.admin) >= acmds[command][1] and getElementData(playerSource, PlayerEnum.admin) ~= 0 then
            if getElementData(playerSource, PlayerEnum.admin) >= 6 then
                return true
            end

            if forceDuty then
                if not getElementData(playerSource, "adminDuty") then
                    outputErrorText("Csak adminszolgálatban használhatod az admin parancsokat!", playerSource)

                    return false
                else
                    return true
                end
            else
                return true
            end
		end
	end

	return false
end