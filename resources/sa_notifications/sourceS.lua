function showNotification(sourcePlayer, notifyType, notifyText)
	if isElement(sourcePlayer) then
		triggerClientEvent(sourcePlayer, "showNotification", sourcePlayer, notifyType, notifyText)
	end
end