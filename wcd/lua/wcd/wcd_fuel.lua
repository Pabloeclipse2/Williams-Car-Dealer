--[[
Server Name: [GER] NATO vs. Terror [MilitaryRP] by ★ MG ★
Server IP:   45.157.232.23:27030
File Path:   addons/wcd/lua/wcd/wcd_fuel.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

local meta = FindMetaTable("Vehicle")

function meta:WCD_SetFuel(x)
	self.__WCDFuel = math.Clamp(x, 0, 999999)
end

function meta:WCD_GetFuel()
	return self.__WCDFuel or -1
end

function meta:WCD_AddFuel(x)
	self.__WCDFuel = math.Clamp((self.__WCDFuel or 0) + x, 0, self:WCD_GetFuelMax())

	if x > 0 then
		self:Fire("TurnOn", true, 0)
	end
end

function meta:WCD_GetId()
	return self:GetNW2Int("WCD::Id", -1)
end

function meta:WCD_SetFuelMax(x)
	self.__WCDFuelMax = math.Clamp(x, 0, 999)
end

function meta:WCD_GetFuelMax()
	if self:WCD_GetId() == -1 or not WCD.List[self:WCD_GetId()] then return -1 end

	if not self.__WCDFuelMax then
		self.__WCDFuelMax = WCD.List[self:WCD_GetId()]:GetFuel()
	end

	return self.__WCDFuelMax or self.__WCDFuel or 0
end

function meta:WCD_ProcessFuel()
	if (SERVER and not IsValid(self:GetDriver())) or self:WCD_GetId() == -1 or self:WCD_GetFuel() < 0 then return end

	if SERVER and self:WCD_GetFuel() <= 0.2 then
		self:Fire("TurnOff", true, 0)
	elseif SERVER and (not self.__WCDLastFuel or self.__WCDLastFuel < 1) then
		self:Fire("TurnOn", true, 0)
	end

	local oldPos = self.__WCDOldPos or self:GetPos()
	local newPos = self:GetPos()
	local dist = oldPos:Distance(newPos) / 15000
	dist = dist * (WCD.List[self:WCD_GetId()] and WCD.List[self:WCD_GetId()].fuelMulti or WCD.Settings.fuelMulti)
	dist = dist * WCD.Settings.fuelMultiplier
	self:WCD_AddFuel(-dist)
	self.__WCDLastFuel = self:WCD_GetFuel()
	self.__WCDOldPos = self:GetPos()
end

if SERVER then
	WCD.FuelTracker = WCD.FuelTracker or {}
	util.AddNetworkString("WCD::SyncFuel")

	hook.Add("PlayerEnteredVehicle", "WCD::SyncFuel", function(ply, veh, _)
		if WCD.FuelTracker[veh:EntIndex()] then
			net.Start("WCD::SyncFuel")
			net.WriteFloat(veh:WCD_GetFuel())
			net.Send(ply)
			veh:WCD_ProcessFuel()
		end
	end)
else
	net.Receive("WCD::SyncFuel", function()
		local fuel = net.ReadFloat()

		timer.Simple(0.5, function()
			if IsValid(LocalPlayer():GetVehicle()) then
				LocalPlayer():GetVehicle():WCD_SetFuel(fuel)
			end
		end)
	end)
end

function WCD:ProcessFuel()
	if self.Settings.fuel then
		timer.Create("WCD::ProcessFuel", 2, 0, function()
			if SERVER then
				for i, v in pairs(WCD.FuelTracker) do
					if not IsValid(Entity(i)) then
						WCD.FuelTracker[i] = nil
						continue
					end

					if not (Entity(i):GetDriver() and IsValid(Entity(i):GetDriver())) then continue end
					Entity(i):WCD_ProcessFuel()
				end
			else
				if IsValid(LocalPlayer():GetVehicle()) and LocalPlayer():GetVehicle().WCD_ProcessFuel then
					LocalPlayer():GetVehicle():WCD_ProcessFuel()
				end
			end
		end)
	else
		timer.Remove("WCD::ProcessFuel")
	end
end

WCD:Print(WCD:Translate("loadedFile", WCD.Lang.fileNames.fuel or "fuel"))