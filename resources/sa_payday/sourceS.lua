local serverPrefix = exports.sa_core:getServerPrefix("server", "Payday")
local serverName = exports.sa_core:getServerProperty("server_name")

local payDayData = {
	interest = 0.001,	-- Kamat [ % ]
	paymentTax = 0.15,	-- Jövedelem adó [ % ]
	vehicleTax = 50,	-- Jármű adó [ $ ]
	interiorTax = 50	-- Ingatlan adó [ $ ]
}

addCommandHandler("apayday",
	function (sourcePlayer, commandName)
		local adminLevel = getElementData(sourcePlayer, "admin") or { level = 0, name = "Ismeretlen admin" }

		--if adminLevel >= 10 then
			startPayday(sourcePlayer)
		--end
	end
)

function startPayday(sourcePlayer)
	if sourcePlayer then
		local charID = getElementData(sourcePlayer, "charId") or 0
		local characterId = tonumber(charID)

		if characterId then
			local currentMoney = getElementData(sourcePlayer, "money") or 0
			local interest = math.floor(currentMoney * payDayData.interest)

			if interest < 0 then
				interest = 0
			elseif interest > 100000000 then
				interest = 100000000
			end

			local payment = 0
			local paymentTax = math.floor(payment * payDayData.paymentTax)

			outputChatBox(serverPrefix .. "#FFFFFFMegérkezett a fizetésed.", sourcePlayer, 255, 255, 255, true)
			outputChatBox(serverPrefix .. "| Kamat | #FFFFFF" .. interest .. " $", sourcePlayer, 255, 255, 255, true)
		
			setElementData(sourcePlayer, "money", interest)
		end
	end
end

addEventHandler("onElementDataChange", root,
	function (dataName)
		if dataName == "playtime" then
			local playTimeForPayDay = getElementData(source, "paydayTime") or 60

			if playTimeForPayDay - 1 <= 0 then
				setElementData(source, "paydayTime", 60)
				startPayday(source)
			else
				setElementData(source, "paydayTime", playTimeForPayDay - 1)
			end
		end
	end
)