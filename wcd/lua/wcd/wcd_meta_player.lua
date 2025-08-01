--[[
Server Name: [GER] NATO vs. Terror [MilitaryRP] by ★ MG ★
Server IP:   45.157.232.23:27030
File Path:   addons/wcd/lua/wcd/wcd_meta_player.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

local meta = FindMetaTable("Player")
-- these return a table [vehicle id] = true
function meta:WCD_Owns(id)
	return (self.__WCDCoreOwned and self.__WCDCoreOwned[id]) or WCD.List[id]:GetFree() or false
end

function meta:WCD_GetOwned()
	local tbl = {}
	if self.__WCDCoreOwned then tbl = table.Copy(self.__WCDCoreOwned) end
	for i, v in pairs(WCD.List) do
		if v:GetFree() and self:WCD_HasAccess(i) then tbl[i] = true end
	end
	return tbl
end

function meta:WCD_GetSpecifics(id)
	if not id then return self.__WCDSpecifics or {} end
	return (self.__WCDSpecifics and self.__WCDSpecifics[id]) or {}
end

function meta:WCD_SetSpecifics(id, data)
	self.__WCDSpecifics = self.__WCDSpecifics or {}
	self.__WCDSpecifics[id] = self.__WCDSpecifics[id] or {}
	for i, v in pairs(data) do
		self.__WCDSpecifics[id][i] = v
	end
end

function meta:WCD_ResetSpecifics(id, resetFuel)
	self.__WCDSpecifics = self.__WCDSpecifics or {}
	local fuel = self.__WCDSpecifics[id].fuel or false
	self.__WCDSpecifics[id] = {}
	if not resetFuel and fuel then self.__WCDSpecifics[id].fuel = fuel end
end

function meta:WCD_SendSpecifics(id)
	if CLIENT then return end
	self.__WCDSpecifics = self.__WCDSpecifics or {}
	self.__WCDSpecifics[id] = self.__WCDSpecifics[id] or {}
	net.Start("WCD::SendSpecifics")
	net.WriteFloat(id)
	net.WriteTable(self.__WCDSpecifics[id])
	net.Send(self)
end

function meta:WCD_AddVehicle(id)
	self.__WCDCoreOwned = self.__WCDCoreOwned or {}
	self.__WCDCoreOwned[id] = true
	if SERVER then
		self.__WCDCoreOwned[id] = true
		WCD:SavePlayerData("owned", self, self.__WCDCoreOwned)
	end
end

function meta:WCD_RemoveVehicle(id)
	self.__WCDCoreOwned = self.__WCDCoreOwned or {}
	self.__WCDCoreOwned[id] = nil
	if SERVER then
		self.__WCDCoreOwned[id] = nil
		WCD:SavePlayerData("owned", self, self.__WCDCoreOwned)
		for i, v in pairs(self:WCD_GetActiveCars()) do
			if v:WCD_GetId() == id then v:Remove() end
		end
	end
end

function meta:WCD_GetFavorites()
	if SERVER then return end
	return WCD.Client.Favorites
end

function meta:WCD_GetUnOwned()
	local tbl = {}
	for i, v in pairs(WCD.List) do
		if not self:WCD_Owns(i) and self:WCD_HasAccess(i) then tbl[i] = true end
	end
	return tbl
end

function meta:WCD_GetNoAccess()
	local tbl = {}
	for i, v in pairs(WCD.List) do
		if not self:WCD_HasAccess(i) then tbl[i] = true end
	end
	return tbl
end

function meta:WCD_HasAccess(id)
	local data = WCD.List[id]
	if not data then return false end
	if not data:GetAccess() then return true end
	if data:GetOwnedPriority() and self:WCD_Owns(id) then return true end
	local group = WCD.AccessGroups[data:GetAccess()]
	if not group then return false end
	local hasRank, hasJob = true, true
	local needRank, needJob = false, false
	if group.ranks and table.Count(group.ranks) > 0 then
		needRank = true
		if not group.ranks[self:GetUserGroup()] then hasRank = false end
	end

	if group.jobs and table.Count(group.jobs) > 0 then
		needJob = true
		local teamno = self:GetMGVar("job_override") or self:Team()
		if not group.jobs[team.GetName(teamno)] then hasJob = false end
	end

	if group.needBoth then
		return hasRank and hasJob
	else
		if (needRank and not hasRank) or (needJob and not hasJob) then
			return false
		else
			return true
		end
	end
end

function meta:WCD_ChangedCheck(unset)
	if unset then return end
	self.WCD_HasAccess = self.WCD_GetNoAccess
end

function meta:WCD_GetActiveCars()
	self.__WCDActiveCars = self.__WCDActiveCars or {}
	for i, v in pairs(self.__WCDActiveCars) do
		if not IsValid(v) then self.__WCDActiveCars[i] = nil end
	end
	return self.__WCDActiveCars
end

function meta:WCD_AddActiveCar(_e)
	self.__WCDActiveCars = self.__WCDActiveCars or {}
	if not IsValid(_e) then return end
	table.insert(self.__WCDActiveCars, _e)
end

function meta:WCD_Notify(msg)
	if not (msg and type(msg) == "string" and string.len(msg) > 0) then return end
	if CLIENT then
		WCD:Notification(msg)
	else
		net.Start("WCD::Notification")
		net.WriteString(msg)
		net.Send(self)
	end
end