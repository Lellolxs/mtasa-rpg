function findPlayer(sourcePlayer, partialNick)
	if not partialNick and not isElement(sourcePlayer) and type(sourcePlayer) == "string" then
		partialNick = sourcePlayer
		sourcePlayer = nil
	end
	
	local candidates = {}
	local matchPlayer = nil
	local matchNickAccuracy = -1

	partialNick = string.lower(partialNick)
	
	if sourcePlayer and partialNick == "*" then
		return sourcePlayer, string.gsub(getPlayerName(sourcePlayer), "_", " ")
	elseif tonumber(partialNick) then
		local players = getElementsByType("player")

		for i = 1, #players do
			local player = players[i]

			if isElement(player) then
				if getElementData(player, "loggedIn") then
					if getElementData(player, "playerid") == tonumber(partialNick) then
						matchPlayer = player
						break
					end
				end
			end
		end

		candidates = {matchPlayer}
	else
		local players = getElementsByType("player")

		partialNick = string.gsub(partialNick, "-", "%%-")

		for i = 1, #players do
			local player = players[i]

			if isElement(player) then
				local playerName = getElementData(player, "name")or getPlayerName(matchPlayer):gsub("_", " ")

				if not playerName then
					playerName = getPlayerName(player)
				end

				playerName = string.gsub(playerName, "_", " ")
				playerName = string.lower(playerName)

				if playerName then
					local startPos, endPos = string.find(playerName, tostring(partialNick))

					if startPos and endPos then
						if endPos - startPos > matchNickAccuracy then
							matchNickAccuracy = endPos - startPos
							matchPlayer = player
							candidates = {player}
						elseif endPos - startPos == matchNickAccuracy then
							matchPlayer = nil
							table.insert(candidates, player)
						end
					end
				end
			end
		end
	end
	
	if not matchPlayer or not isElement(matchPlayer) then
		if isElement(sourcePlayer) then
			if #candidates == 0 then
				outputChatBox("#d16c6c[SAStories - Findplayer]: #ffffffA kiválasztott játékos nem található.", sourcePlayer, 255, 255, 255, true)
			else
				outputChatBox("#6cb3d1[SAStories - Findplayer]: #ffffffEzzel a névrészlettel #6cb3d1" .. #candidates .. " db #ffffffjátékos található:", sourcePlayer, 255, 255, 255, true)
			
				for i = 1, #candidates do
					local player = candidates[i]

					if isElement(player) then
						local playerId = getElementData(player, "playerid")
						local playerName = string.gsub(getPlayerName(player), "_", " ")

						outputChatBox("#6cb3d1    (" .. tostring(playerId) .. ") #ffffff" .. playerName, sourcePlayer, 255, 255, 255, true)
					end
				end
			end
		end
		
		return false
	else
		if getElementData(matchPlayer, "loggedIn") then
			local playerName = getElementData(matchPlayer, "name") or getPlayerName(matchPlayer):gsub("_", " ")

			if not playerName then
				playerName = getPlayerName(matchPlayer)
			end

			return matchPlayer, string.gsub(playerName, "_", " ")
		else
			outputChatBox("#d16c6c[SAStories - Findplayer]:  #ffffffA kiválasztott játékos nincs bejelentkezve.", sourcePlayer, 255, 255, 255, true)
			return false
		end
	end
end