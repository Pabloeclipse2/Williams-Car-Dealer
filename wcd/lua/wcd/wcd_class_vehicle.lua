--[[
Server Name: [GER] NATO vs. Terror [MilitaryRP] by ★ MG ★
Server IP:   45.157.232.23:27030
File Path:   addons/wcd/lua/wcd/wcd_class_vehicle.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

Vehicle = {}
Vehicle.__index = Vehicle
function Vehicle:New(data)
	data = data or {}
	local veh = {
		id = data.id or WCD:GetNewID(),
		name = data.name or WCD.Settings.defaultVehicleName,
		class = data.class or WCD.Settings.defaultVehicleClass,
		price = tonumber(data.price) or 0,
		free = data.free or false,
		disallowCustomization = data.disallowCustomization or WCD.Settings.disallowCustomization,
		fuel = data.fuel or WCD.Settings.fuelTank,
		noFuel = data.noFuel or false,
		skin = data.skin or 0,
		nitro = tonumber(data.nitro) or 0,
		fuelMulti = data.fuelMulti or 1,
		disallowNitro = data.disallowNitro or false,
		disallowSkin = data.disallowSkin or false,
		disallowColor = data.disallowColor or false,
		disallowBodygroup = data.disallowBodygroup or false,
		disallowUnderglow = data.disallowUnderglow or false,
		ownedPriority = data.ownedPriority or false,
		skinCost = data.skinCost or WCD.Settings.skinCost,
		bodygroupCost = data.bodygroupCost or WCD.Settings.bodygroupCost,
		colorCost = data.colorCost or WCD.Settings.colorCost,
		nitroOneCost = data.nitroOneCost or WCD.Settings.nitroOneCost,
		nitroTwoCost = data.nitroTwoCost or WCD.Settings.nitroTwoCost,
		nitroThreeCost = data.nitroThreeCoset or WCD.Settings.nitroThreeCost,
		underglowCost = data.underGlowCost or WCD.Settings.underGlowCost,
		spawnCost = data.spawnCost or WCD.Settings.spawnCost,
		overrideModel = data.overrideModel or nil,
		spawnDelay = data.spawnDelay or 0,
		color = data.color or color_white,
		bodygroups = data.bodygroups or false,
		access = data.access or false,
		dealer = data.dealer or false,
		__WCDEnt = data.__WCDEnt or false
	}

	for i, v in pairs(veh) do
		AccessorFunc(self, i, i:sub(1, 1):upper() .. i:sub(2), type(v))
	end

	setmetatable(veh, Vehicle)
	return veh
end

function Vehicle:Save()
	if SERVER then file.Write("wcd/cars/" .. self.id .. ".txt", util.TableToJSON(self)) end
end

function Vehicle:Delete()
	if SERVER then file.Delete("wcd/cars/" .. self.id .. ".txt", "DATA") end
	WCD.List[self.id] = nil
	self = nil
end

setmetatable(Vehicle, {
	__call = Vehicle.New
})