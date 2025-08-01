--[[
Server Name: [GER] NATO vs. Terror [MilitaryRP] by ★ MG ★
Server IP:   45.157.232.23:27030
File Path:   addons/wcd/lua/entities/wcd_dealer/shared.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

ENT.Type = "ai"
ENT.Base = "base_ai"
ENT.AutomaticFrameAdvance = true
ENT.PrintName = "Car Dealer"
ENT.Author = "William"
ENT.Category = "William's Car Dealer"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_BOTH
function ENT:SetAutomaticFrameAdvance(bUsingAnim)
	self.AutomaticFrameAdvance = bUsingAnim
end

function ENT:DisableGarage(bool)
	self:SetNW2Bool("WCD::disableGarage", bool)
	self.disableGarage = bool
end

function ENT:DisableShop(bool)
	self:SetNW2Bool("WCD::disableShop", bool)
	self.disableShop = bool
end

function ENT:GlobalReturn(bool)
	self:SetNW2Bool("WCD::globalReturn", bool)
	self.globalReturn = bool
end

function ENT:GlobalSpawn(bool)
	self:SetNW2Bool("WCD::globalSpawn", bool)
	self.globalSpawn = bool
end

function ENT:DisableCustomization(bool)
	self:SetNW2Bool("WCD::disableCustomization", bool)
	self.disableCustomization = bool
end