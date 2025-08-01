--[[
Server Name: [GER] NATO vs. Terror [MilitaryRP] by ★ MG ★
Server IP:   45.157.232.23:27030
File Path:   addons/wcd/lua/entities/wcd_dealer/cl_init.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

include("shared.lua")
local localPly
function ENT:Draw()
	self:DrawModel()
end

local max_distance = 500000
local fade_scale = 255 / math.sqrt(max_distance / 5)
local text_color_white = Color(255, 255, 255)
local text_color_black = Color(0, 0, 0)
function ENT:DrawTranslucent()
	localPly = localPly or LocalPlayer()
	local dist = localPly:GetPos():DistToSqr(self:GetPos())
	if dist > max_distance then return end
	local name = self:GetNW2String("WCD::Name", "Unknown name")
	self.up = self.up or self:OBBMaxs().z + 6
	local pos = self:GetPos() + self:GetUp() * self.up
	local ang = localPly:GetAngles()
	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), 90)
	local fade = CalcFade(dist, max_distance, max_distance / 5, fade_scale)
	text_color_white.a = fade
	text_color_black.a = fade
	cam.Start3D2D(pos, ang, 0.1)
	draw.SimpleTextOutlined(name, "WCD::FontDealer", 0, 0, text_color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, text_color_black)
	cam.End3D2D()
end