local sName = "San Andreas Stories"

local resources = {
	-- ** Core & Database

	"sa_assets",
	"sa_core",
	"sa_controls",

	-- ** Accounts

	"sa_account",

	-- ** Administration

	"sa_admin",

	"sa_serial"
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
