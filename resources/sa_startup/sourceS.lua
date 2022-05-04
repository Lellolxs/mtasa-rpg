local sName = "San Andreas Stories";

local resources = {
	--// Deps
	"pAttach", 
	"object_preview", 

	--// Core
	
	"sa_core",
	"sa_account",
	"sa_admin",

	--// Main scripts
	"sa_interface",
	"sa_chat",
	"sa_inventory",
	"sa_vehicle",

	--// Others

	"sa_serial", 

	"sa_mods"
}

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		local started = 0

		outputDebugString("[" .. sName .. "]: Starting resources...")

		for k, v in ipairs(resources) do
			local resname = getResourceFromName(v)
			local state = startResource(resname)

			if state then
				started = started + 1
			end
		end

		
		outputDebugString("[" .. sName .. "]: " .. started .. " resource(s) started.")
	end
)

function getResourceList()
	return resources
end
