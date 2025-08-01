--[[
Server Name: [GER] NATO vs. Terror [MilitaryRP] by ★ MG ★
Server IP:   45.157.232.23:27030
File Path:   addons/wcd/lua/wcd/wcd_minimal.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

-- just various stuff too small for their own files
WCD.AccessGroups = WCD.AccessGroups or {}
WCD.DealerGroups = WCD.DealerGroups or {}
local meta = FindMetaTable("Entity")
function meta:WCD_SetId(x)
	self.__WCDId = x
	self:SetNW2Int("WCD::Id", x)
end

function meta:WCD_GetId()
	return self:GetNW2Int("WCD::Id", -1)
end

local meta = FindMetaTable("Vehicle")
function meta:WCD_SetNitro(x)
	self.__WCDNitro = x
end

function meta:WCD_GetNitro()
	return self.__WCDNitro or (WCD.List[self:WCD_GetId()] and WCD.List[self:WCD_GetId()]:GetNitro()) or 0
end

function meta:WCD_UseNitro()
	if CLIENT then return end
	if self:WCD_GetNitro() == 0 or not WCD.Settings.nitro or (self.__WCDLastNitro and self.__WCDLastNitro + WCD.Settings.nitroCooldown >= CurTime()) then return end
	self.__WCDLastNitro = CurTime()
	local phys = self:GetPhysicsObject()
	timer.Create(self:EntIndex() .. "::Boost", 0.025, 50 + (self:WCD_GetNitro() * 3), function() phys:ApplyForceCenter(self:GetForward() * phys:GetMass() * (WCD.Settings.nitroPower * (50 + (self:WCD_GetNitro() * 10)))) end)
	net.Start("WCD::NitroUsed")
	net.Send(self:GetDriver())
	timer.Simple(WCD.Settings.nitroCooldown, function()
		if IsValid(self) and IsValid(self:GetDriver()) then
			net.Start("WCD::NitroReady")
			net.Send(self:GetDriver())
		end
	end)
end

function meta:WCD_SetId(x)
	self.__WCDId = x
	self:SetNW2Int("WCD::Id", x)
end

function meta:WCD_GetId()
	return self:GetNW2Int("WCD::Id", -1)
end

if CLIENT then
	timer.Simple(0, function()
		LocalPlayer().__WCDCoreOwned = LocalPlayer().__WCDCoreOwned or {}
		LocalPlayer().__WCDSpecifics = LocalPlayer().__WCDSpecifics or {}
	end)
else
	util.AddNetworkString("WCD::OpenAdmin")
	util.AddNetworkString("WCD::AskForVehicles")
	net.Receive("WCD::AskForVehicles", function(_, ply)
		if WCD:IsOwner(ply) then
			local timeBeforeOpen = WCD:SendAllVehicles(ply)
			timer.Simple(timeBeforeOpen * 0.05, function()
				if IsValid(ply) then
					net.Start("WCD::OpenAdmin")
					net.Send(ply)
				end
			end)
		end
	end)
end

function meta:WCD_ToggleUnderglow()
	self:SetNW2Bool("WCD::Underglow", not self:GetNW2Bool("WCD::Underglow", true))
end

function meta:WCD_GetUnderglow()
	return self:GetNW2Bool("WCD::Underglow", false)
end

function meta:WCD_GetUnderglowColor()
	return (self:GetNW2Vector("WCD::UnderglowColor", Vector(0, 0, 0)) != Vector(0, 0, 0) and self:GetNW2Vector("WCD::UnderglowColor")) or false
end

function meta:WCD_SetUnderglow(color)
	if not (color and type(color) == "table") then
		self.__WCDUnderglow = false
		return
	end

	self.__WCDUnderglowColor = Vector(color.r, color.g, color.b)
	if SERVER then
		self:SetNW2Bool("WCD::Underglow", true)
		self:SetNW2Vector("WCD::UnderglowColor", self.__WCDUnderglowColor)
	end
end

for i, v in ipairs(ents.FindByClass("prop_vehicle_jeep")) do
	v.__WCDUnderglowData = nil
end

function meta:WCD_ProcessUnderglow(bypass)
	if not bypass and not self:WCD_GetUnderglow() then return end
	local up = self:GetUp()
	local right = self:GetRight()
	local tb = self:GetTable()
	if not tb.__WCDUnderglowData then
		local center = self:OBBCenter()
		local mins = self:OBBMins()
		local maxs = self:OBBMaxs()
		tb.__WCDUnderglowData = {
			center = center,
			sizeCenter = maxs.x,
			distToFront = center:Distance(Vector(mins.x, mins.y, center.z) / 2),
			distToBack = center:Distance(Vector(maxs.x, maxs.y, center.z) / 2),
			distToUnder = center:Distance(Vector(0, 0, mins.z)) / 2,
		}

		tb.__WCDUnderglowFunc = {function() return self:LocalToWorld(tb.__WCDUnderglowData.center) + up * -tb.__WCDUnderglowData.distToUnder end, function() return self:LocalToWorld(tb.__WCDUnderglowData.center) + self:GetRight() * -(tb.__WCDUnderglowData.distToFront - 10) + self:GetUp() * -tb.__WCDUnderglowData.distToUnder end, function() return self:LocalToWorld(tb.__WCDUnderglowData.center) + self:GetRight() * -(tb.__WCDUnderglowData.distToFront - 15) + self:GetUp() * -tb.__WCDUnderglowData.distToUnder end, function() return self:LocalToWorld(tb.__WCDUnderglowData.center) + self:GetRight() * (tb.__WCDUnderglowData.distToBack + 10) + self:GetUp() * tb.__WCDUnderglowData.distToUnder end, function() return self:LocalToWorld(tb.__WCDUnderglowData.center) + self:GetRight() * (tb.__WCDUnderglowData.distToBack + 15) + self:GetUp() * -tb.__WCDUnderglowData.distToUnder end,}
	end

	local color
	if bypass then
		color = Vector(bypass.r, bypass.g, bypass.b, 255)
	else
		color = self:WCD_GetUnderglowColor()
	end

	if type(color) != "Vector" then return end
	color = Vector(color.r, color.g, color.b, 255)
	for i, v in pairs(self.__WCDUnderglowFunc) do
		local light = DynamicLight(self:EntIndex() + i)
		light.pos = v()
		light.nomodel = true
		light.brightness = 6
		light.Decay = 1000
		light.Size = 88
		light.DieTime = CurTime() + FrameTime() * 4
		light.r, light.g, light.b = color.x, color.y, color.z
	end
end

WCD:Print(WCD:Translate("loadedFile", WCD.Lang.fileNames.minimal or "minimal"))