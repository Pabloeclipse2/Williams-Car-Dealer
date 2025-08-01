--[[
Server Name: [GER] NATO vs. Terror [MilitaryRP] by ★ MG ★
Server IP:   45.157.232.23:27030
File Path:   addons/wcd/lua/entities/wcd_pump/cl_init.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

include("shared.lua")
function ENT:Initialize()
	self.bars = 0
	self.up = false
end

function ENT:Draw()
	self:DrawModel()
	local dist = LocalPlayer():GetPos():DistToSqr(self:GetPos())
	if dist > 500 ^ 2 then return end
	local c = WCD.Colors.pump
	local lang = WCD.Lang.pump
	if not (c and lang) then return end
	local pos = self:GetPos()
	pos = pos + self:GetUp() * 57.4
	pos = pos + self:GetForward() * 9.2
	pos = pos + self:GetRight() * 15.27
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), 270)
	local w, h = 305, 230
	local barW, barH = 15, 200
	local btnW, btnH = w / 3, 30
	local busy = self:GetNW2Bool("WCD::Busy", false)
	if self.up then
		self.bars = self.bars + 0.3
		if self.bars >= barH then self.up = false end
	else
		self.bars = self.bars - 0.3
		if self.bars <= 0 then self.up = true end
	end

	cam.Start3D2D(pos, ang, 0.1)
	surface.SetDrawColor(c.bg)
	surface.DrawRect(0, 0, w, h)
	local x, y = 35, 15
	surface.SetDrawColor(c.barBg)
	surface.DrawRect(x, y, barW, barH)
	surface.DrawRect(w - barW - x, y, barW, barH)
	y = y + 1
	surface.SetDrawColor(c.bar)
	surface.DrawRect(x, y + barH - self.bars, barW, self.bars)
	surface.DrawRect(w - barW - x, y, barW, self.bars)
	surface.SetDrawColor(c.barBorder)
	surface.DrawOutlinedRect(x, y + barH - self.bars, barW, self.bars)
	surface.DrawOutlinedRect(w - barW - x, y - 1, barW, self.bars + 1)
	draw.SimpleTextOutlined(lang.title, "WCD::FontPumpTitle", w / 2, 25, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
	for i, v in pairs(lang.info) do
		draw.SimpleText(v, "WCD::FontPumpInfo", w / 2, 25 + i * 14, color_white, TEXT_ALIGN_CENTER, 0, 1, color_black)
	end

	draw.SimpleTextOutlined(WCD:Translate(lang.price, DarkRP.formatMoney(WCD.Settings.fuelCost)), "WCD::FontPumpInfo", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
	x = w / 2 - btnW / 2
	y = h - btnH - 16
	if busy then
		surface.SetDrawColor(c.buttonBusyBg)
	else
		surface.SetDrawColor(c.buttonAcceptBg)
	end

	surface.DrawRect(x, y, btnW, btnH)
	surface.SetDrawColor(c.buttonBorder)
	surface.DrawOutlinedRect(x, y, btnW, btnH)
	local text = lang.start
	if busy then text = lang.cancel end
	draw.SimpleTextOutlined(text, "WCD::FontPumpButton", x + btnW / 2, y + btnH / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
	cam.End3D2D()
end