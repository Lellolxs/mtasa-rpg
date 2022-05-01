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

Core = exports.sa_core;
Interface = exports.sa_interface;

loadstring(Core:require({ }))();

Component = {
	actionbar = {}
}

local actionbarW, actionbarH = respc(261), respc(46)

local lastActionBarX = 9999
local lastActionBarY = 9999

Component.render = function ()
	local actionbarX, actionbarY = (screenX - actionbarW) / 2, screenY - actionbarH - respc(5)

	actionbarX, actionbarY = actionbarX + respc(5), actionbarY + respc(5)

	dxDrawRectangle(actionbarX - respc(3), actionbarY - respc(3), actionbarW, actionbarH, tocolor(42, 42, 42, 255))

	if lastActionbarX ~= actionbarX or lastActionBarY ~= actionbarY then
		lastActionbarX = actionbarX
		lastActionBarY = actionbarY

		exports.sa_inventory:changeItemStartPos(actionbarX, actionbarY)
	end

	return true
end

addEvent("requestChangeItemStartPos", true)
addEventHandler("requestChangeItemStartPos", localPlayer,
	function ()
		lastActionBarX, lastActionBarY = 9999, 9999
	end
)

Component.__uiUpdate = function(id, position, size)
    if (id == 'actionbar') then 
        actionbarW, actionbarH = size.x, size.y;
        actionbarX, actionbarY = position.x, position.y;
    end 
end 

Component.mount = function()
    Interface:mount("actionbar", {
        label = "Actionbar", 
        position = Vector2(actionbarX, actionbarY), 

        size = Vector2(actionbarW, actionbarH),
        minSize = Vector2(actionbarW * 0.5, actionbarH),
        maxSize = Vector2(actionbarW * 1.5, actionbarH),

        sizable = true, 

        options = {
            { type = "header", text = "Faszanyad" },
        },
    });

    addEventHandler('onClientRender', root, Component.render);
    addEventHandler('onInterfaceUpdate', root, Component.__uiUpdate);
end

Component.unmount = function()
    removeEventHandler('onInterfaceUpdate', root, Component.__uiUpdate);
end 

Component.mount();