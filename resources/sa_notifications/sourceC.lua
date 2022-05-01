local Core = exports.sa_core;

loadstring(Core:require({ }))();

local screenX, screenY = guiGetScreenSize()

function reMap(value, low1, high1, low2, high2)
	return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

responsiveMultipler = reMap(screenX, 1024, 1920, 0.75, 1)

function resp(num)
	return num * responsiveMultipler
end

function respc(num)
	return math.ceil(num * responsiveMultipler)
end

local screenWidth, screenHeight = guiGetScreenSize()

local notificationsTable = {}

local notificationsRender = false
local notificationFont = false

-- local notificationFont = dxCreateFont(":sa_assets/files/fonts/Roboto.ttf", resp(12), false, "antialiased")
local notificationFont = Core:requireFont("opensans-bold", 12);

local notificationsNum = 4
local notificationWidth = respc(380)
local notificationBaseHeight = respc(50)
local notificationLineHeight = respc(16);

local notificationBasePosX = (screenX - notificationWidth) / 2
local notificationBasePosY = notificationBaseHeight - respc(268)

local notificationTypes = {
	["error"] = {
		["color"] = {215, 65, 65},
	},
	["warning"] = {
		["color"] = {227, 127, 60},
	},
	["success"] = {
		["color"] = {33, 183, 96},
	},
	["info"] = {
		["color"] = {0, 170, 255},
	},
} 

function showNotification(notifyType, notifyText)
	if notifyText then
		local typeDetails = notificationTypes[notifyType]

		if not typeDetails then
			typeDetails = notificationTypes[notifyType]["info"]
		end

		local currentTick = getTickCount()

		-- if isHudVisible() then
			local remainingNotifications = {}

			for i = 1, notificationsNum do
				local infoboxDetails = notificationsTable[i]

				if infoboxDetails then
					remainingNotifications[i + 1] = infoboxDetails
					infoboxDetails.moveUpStart = currentTick
				end
			end

			notificationsTable = remainingNotifications
			notificationsTable[1] = {
				["messageType"] = notifyType,
				["messageContent"] = notifyText,
				["fadeInStart"] = currentTick,
				["fadeOutStart"] = currentTick + 5000,
				["moveOffsetY"] = (notificationBaseHeight + 5) * notificationsNum,
				["animFactor"] = 0,
				["iconColor"] = typeDetails["color"],
				["iconSize"] = math.min(respc(64), math.ceil(notificationBaseHeight * 0.6)), 
				["lines"] = dxGetTextHeight(notifyText, notificationFont, 1, notificationWidth)
			}


			local wordsTable = split(notifyText, " ")
			local currentText, processedText = "", ""
			local wordWrapCount = 0

			for i = 1, #wordsTable do
				local currentWord = wordsTable[i]

				if dxGetTextWidth(currentText .. currentWord, 1, notificationFont) > notificationWidth - notificationsTable[1]["iconSize"] - respc(20) then
					processedText = processedText .. currentText .. "\n"
					currentText = ""
					wordWrapCount = wordWrapCount + 1
				end

				if wordsTable[i + 1] then
					currentText = currentText .. currentWord .. " "
				else
					currentText = currentText .. currentWord
				end
			end

			notificationsTable[1]["messageContent"] = processedText .. currentText

			-- if wordWrapCount >= 2 then
			-- 	notificationsTable[1]["textScale"] = 1 - wordWrapCount * 0.1
			-- end

			if not notificationsRender then
				notificationsRender = true
				notificationFont = Core:requireFont("opensans-bold", 11);
				addEventHandler("onClientRender", root, renderNotifications)
			end
		-- end

		playSound(":sa_assets/files/sounds/notify.wav")

		outputConsole("[Notification]: " .. notifyText)
	end
end
addEvent("showNotification", true)
addEventHandler("showNotification", localPlayer, showNotification)

function renderNotifications()
	if #notificationsTable == 0 then
		removeEventHandler("onClientRender", root, renderNotifications)

		if isElement(notificationFont) then
			destroyElement(notificationFont)
		end

		notificationFont = nil
		notificationsRender = false

		return
	end

	-- if not isHudVisible() then
	-- 	return
	-- end

	local currentTick = getTickCount()

	for i = 1, notificationsNum do
		local infoboxDetails = notificationsTable[i]

		if infoboxDetails then
			if currentTick > infoboxDetails.fadeInStart and currentTick <= infoboxDetails.fadeOutStart then
				infoboxDetails.animFactor = interpolateBetween(
					infoboxDetails.animFactor, 0, 0,
					1, 0, 0,
					(currentTick - infoboxDetails.fadeInStart) / 1000,
					"InOutQuad"
				)
			elseif currentTick >= infoboxDetails.fadeOutStart then
				infoboxDetails.animFactor = interpolateBetween(
					infoboxDetails.animFactor, 0, 0,
					0, 0, 0,
					(currentTick - infoboxDetails.fadeOutStart) / 1000,
					"InOutQuad"
				)
			end

			if infoboxDetails.moveUpStart then
				if currentTick >= infoboxDetails.moveUpStart then
					infoboxDetails.moveOffsetY = interpolateBetween(
						infoboxDetails.moveOffsetY, 0, 0,
						(notificationBaseHeight + notificationLineHeight * infoboxDetails.lines + 5) * (notificationsNum - i + 1), 0, 0,
						(currentTick - infoboxDetails.moveUpStart) / 250,
						"InOutQuad"
					)
				end
			end

			local x = notificationBasePosX
			local y = notificationBasePosY + infoboxDetails.moveOffsetY

			-- Background
			dxDrawRectangle(x, y, notificationWidth * infoboxDetails.animFactor, notificationBaseHeight + notificationLineHeight * infoboxDetails.lines, tocolor(30, 30, 30, 225 * infoboxDetails.animFactor))

			-- Notification Icon
			dxDrawImage(math.floor(x + respc(5)), math.floor(y + ((notificationBaseHeight + notificationLineHeight * infoboxDetails.lines) - infoboxDetails.iconSize) / 2), infoboxDetails.iconSize, infoboxDetails.iconSize, ":sa_assets/files/images/notify.png", 0, 0, 0, tocolor(infoboxDetails.iconColor[1], infoboxDetails.iconColor[2], infoboxDetails.iconColor[3], 255 * infoboxDetails.animFactor))

			-- Notification Text
			dxDrawText(
				infoboxDetails.messageContent, 
				x + infoboxDetails.iconSize + respc(15), y, 
				x + notificationWidth * infoboxDetails.animFactor, y + notificationBaseHeight + notificationLineHeight * infoboxDetails.lines, 
				tocolor(255, 255, 255, 255 * infoboxDetails.animFactor), 
				infoboxDetails.textScale or 1, notificationFont, 
				"left", "center", true, false, false, true
			);

			-- Progressbar of Remaining Time
			local timeFraction = (currentTick - infoboxDetails.fadeInStart) / (infoboxDetails.fadeOutStart - infoboxDetails.fadeInStart)

			if timeFraction <= 1 then
				dxDrawRectangle(x + 2, y + (notificationBaseHeight + notificationLineHeight * infoboxDetails.lines) - 4, (notificationWidth - 4) * infoboxDetails.animFactor * (1 - timeFraction), 2, tocolor(infoboxDetails.iconColor[1], infoboxDetails.iconColor[2], infoboxDetails.iconColor[3], 255 * infoboxDetails.animFactor))
			end
		end
	end
end