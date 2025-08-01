--[[
Server Name: [GER] NATO vs. Terror [MilitaryRP] by ★ MG ★
Server IP:   45.157.232.23:27030
File Path:   addons/wcd/lua/wcd/wcd_vehicle_data.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

WCD.VehicleData = WCD.VehicleData or {}
WCD.VehicleClassCounter = WCD.VehicleClassCounter or {}
WCD.List = WCD.List or {}
-- if an entity doesnt have the type = vehicle,
-- it will retrieve relevant fields from here
local helper = {
	["sent_sakarias_scar_base"] = {
		Model = "CarModel",
		Name = "PrintName",
	},
	["fighter_base"] = {
		Model = "EntModel",
		Name = "PrintName",
	},
	["speeder_base"] = {
		Model = "EntModel",
		Name = "PrintName",
	},
	["atdptempfix"] = {
		Model = "EntModel",
		Name = "PrintName",
	},
	["wac_hc_base"] = {
		Model = "Model",
		Name = "PrintName"
	},
	["wac_pl_base"] = {
		Model = "Model",
		Name = "PrintName"
	},
	["haloveh_base"] = {
		Model = "EntModel",
		Name = "PrintName"
	},
	["lunasflightschool_basescript"] = {
		Model = "MDL",
		Name = "PrintName"
	},
	["lunasflightschool_basescript_heli"] = {
		Model = "MDL",
		Name = "PrintName"
	},
	["lunasflightschool_basescript_gunship"] = {
		Model = "MDL",
		Name = "PrintName",
	},
	["heracles421_lfs_base"] = {
		Model = "MDL",
		Name = "PrintName",
	},
	["base_nextbot"] = {
		Name = "PrintName"
	},
	["lvs_base"] = {
		Model = "MDL",
		Name = "PrintName"
	},
	["lvs_base_wheeldrive"] = {
		Model = "MDL",
		Name = "PrintName"
	},
	["lvs_bike_wheeldrive"] = {
		Model = "MDL",
		Name = "PrintName"
	},
	["lvs_base_helicopter"] = {
		Model = "MDL",
		Name = "PrintName"
	},
	["lvs_base_fighterplane"] = {
		Model = "MDL",
		Name = "PrintName"
	},
	["lvs_tank_wheeldrive"] = {
		Model = "MDL",
		Name = "PrintName"
	},
	["lvs_base_dark_heli"] = {
		Model = "MDL",
		Name = "PrintName"
	},
	["lvs_base_wheeldrive_trailer"] = {
		Model = "MDL",
		Name = "PrintName"
	},
}

local helperCategories = {
	["Neurotec"] = {
		--Model = "Model",
		Name = "PrintName",
	},
	["lunasflightschool_basescript"] = {
		--Model = "MDL",
		Name = "PrintName"
	}
}

local skip = {"Car Seat", "Car Seat 2", "Car Seat 3", "Chair", "Airboat Seat", "Big Office Chair", "Jeep Seat", "Office Chair", "Pod", "Wooden Chair"}
WCD.VehicleData = WCD.VehicleData or {}
function WCD:PrepareVehicleList()
	local count = 0
	for i, v in pairs(list.Get("Vehicles")) do
		if !(v.Name and v.Model) or self.VehicleData[i] or table.HasValue(skip, v.Name) then continue end
		self.VehicleData[i] = v
		count = count + 1
	end

	for i, v in pairs(scripted_ents.GetList()) do
		if self.VehicleData[i] then continue end
		if v.Base and helper[v.Base] then
			local ref = helper[v.Base]
			local new = {}
			local ok = true
			for i2, v2 in pairs(ref) do
				if !v.t[v2] then
					ok = false
					break
				end

				new[i2] = v.t[v2]
			end

			if !ok then continue end
			new.__WCDEnt = true
			count = count + 1
			self.VehicleData[i] = table.Copy(new)
			new = nil
			if string.find(i, "animal_") then
				local lookForMdl = string.Replace(i, "animal_", "")
				local path = "models/animals/" .. lookForMdl .. ".mdl"
				if string.lower(lookForMdl) == "horse" then path = "models/npc/horse/horse.mdl" end
				self.VehicleData[i].Model = path
			end
		elseif v.t and v.t.Category then
			local found = false
			for i2, v2 in pairs(helperCategories) do
				if string.find(string.lower(v.t.Category), string.lower(i2)) then
					found = i2
					break
				end
			end

			if !found then continue end
			local new = {}
			local ok = true
			for i2, v2 in pairs(helperCategories[found]) do
				if !v.t[v2] then
					ok = false
					break
				end

				new[i2] = v.t[v2]
			end

			if !ok then continue end
			new.__WCDEnt = true
			count = count + 1
			self.VehicleData[i] = table.Copy(new)
			self.VehicleData[i].cat = found
		end
	end

	for i, v in pairs(list.Get("simfphys_vehicles")) do
		if !(v.Name and v.Model) or self.VehicleData[i] then continue end
		self.VehicleData[i] = {
			Name = v.Name,
			Model = v.Model,
			__WCDEnt = true,
			cat = "simfphys",
			simfphys = true
		}

		count = count + 1
	end

	self.VehicleData["v_polmav"] = {
		Name = "Police Helicopter",
		Model = "models/gta5/vehicles/polmav/polmav_body.mdl",
		__WCDEnt = true
	}

	self:Print("Found " .. count .. " compatible vehicles.")
end

hook.Add("InitPostEntity", "WCD::PrepareVehicleList", function() WCD:PrepareVehicleList() end)
WCD:Print(WCD:Translate("loadedFile", WCD.Lang.fileNames.vehicledata or "vehicledata"))