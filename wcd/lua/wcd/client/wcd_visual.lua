--[[
Server Name: [GER] NATO vs. Terror [MilitaryRP] by ★ MG ★
Server IP:   45.157.232.23:27030
File Path:   addons/wcd/lua/wcd/client/wcd_visual.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

local x, y = 0, 0
local sizeOne, sizeTwo = 25, 250
--[[
	"Top",
	"Bottom",
	"Left",
	"Right"
]]
--
local margin = 10
local positionSpecific = {
	{
		x = ScrW() / 2 - sizeTwo / 2,
		y = margin,
		w = sizeTwo,
		h = sizeOne,
		center = true
	},
	{
		x = ScrW() / 2 - sizeTwo / 2,
		y = ScrH() - sizeOne - margin,
		w = sizeTwo,
		h = sizeOne,
		center = true
	},
	{
		x = margin,
		y = ScrH() / 2 - sizeTwo / 2,
		w = sizeOne,
		h = sizeTwo
	},
	{
		x = ScrW() - margin - sizeOne,
		y = ScrH() / 2 - sizeTwo / 2,
		w = sizeOne,
		h = sizeTwo
	}
}

net.Receive("WCD::NitroUsed", function() WCD.__UsedNitro = 0 end)
net.Receive("WCD::NitroReady", function() WCD.__WCDNitroReady = 0 end)
local halfScr = ScrH() / 2
hook.Add("HUDPaint", "WCD::DrawFuel", function()
	local veh = LocalPlayer():GetVehicle()
	if not IsValid(veh) or veh:GetNW2Int("WCD::Id", 0) == 0 then return end
	if WCD.__UsedNitro and WCD.__UsedNitro < halfScr then
		draw.SimpleTextOutlined(WCD.Lang.nitroActivated, "WCD::FontNitro", ScrW() / 2, ScrH() / 2 - WCD.__UsedNitro, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, HSVToColor(WCD.__UsedNitro % 360, 1, 1))
		WCD.__UsedNitro = Lerp(FrameTime(), WCD.__UsedNitro, ScrH() / 2 + 200)
	end

	if WCD.__WCDNitroReady and WCD.__WCDNitroReady < halfScr then
		draw.SimpleTextOutlined(WCD.Lang.nitroReady, "WCD::FontNitro", ScrW() / 2, ScrH() / 2 - WCD.__WCDNitroReady, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, HSVToColor(WCD.__WCDNitroReady % 360, 1, 1))
		WCD.__WCDNitroReady = Lerp(FrameTime(), WCD.__WCDNitroReady, ScrH() / 2 + 200)
	end

	local s = WCD.Settings.fuelPos
	local c = WCD.Colors.hud
	local fuelVisible = false
	if not positionSpecific[s] then return end
	local r = positionSpecific[s]
	if WCD.Settings.showFuel and WCD.Settings.fuel and veh.WCD_GetFuel and veh:WCD_GetFuel() >= 0 then
		fuelVisible = true
		local fuel = veh:WCD_GetFuel()
		local max = veh:WCD_GetFuelMax()
		local text = math.Round(fuel, 1) .. "/" .. math.Round(max, 0) .. WCD.Lang.fuel
		local w, percentage
		percentage = (fuel / max) * 100
		local alpha = 255 - 2.5 * percentage
		surface.SetDrawColor(c.bg)
		surface.DrawRect(r.x, r.y, r.w, r.h)
		surface.SetDrawColor(Color(math.Clamp(255 - (7 * percentage), 0, 255), percentage * 2.5, 0, alpha))
		if r.center then
			w = (r.w / 2) * percentage / 100
			surface.DrawRect(r.x + r.w / 2, r.y, w, r.h)
			surface.DrawRect(r.x + r.w / 2 - w + 1, r.y, w, r.h)
			local y = r.y + r.h / 2
			draw.SimpleTextOutlined(text, "WCD::FontHUD", r.x + r.w / 2, y, ColorAlpha(color_white, alpha + 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ColorAlpha(color_black, alpha + 50))
		else
			w = r.h * percentage / 100
			surface.DrawRect(r.x, r.y + (r.h - w), r.w, w)
			draw.SimpleTextOutlined(math.Round(percentage, 0) .. "%", "WCD::FontHUD", r.x + r.w / 2, r.y + r.h + 10, ColorAlpha(color_white, alpha + 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ColorAlpha(color_black, alpha + 50))
		end

		surface.SetDrawColor(ColorAlpha(c.border, alpha))
		surface.DrawOutlinedRect(r.x, r.y, r.w, r.h)
	end

	if WCD.Settings.showSpeed then
		local x, y = r.x, r.y
		if fuelVisible then
			if s == 1 then
				y = y + r.h + margin
			elseif s == 2 then
				y = y - r.h - margin
			elseif s == 3 then
				x = x + r.w + margin
			elseif s == 4 then
				x = x - r.w - margin
			end
		end

		local speed = veh:GetVelocity():Length() * 0.056818181
		local max = 200
		if (WCD.Settings.speedUnits or 1) == 1 then
			speed = speed * 1.6093
			max = max * 1.6093
		end

		speed = math.Clamp(math.Round(speed, 0), 0, max)
		local text = speed .. " " .. WCD.Lang.Units[WCD.Settings.speedUnits or 1]
		local percentage = (speed / max) * 100
		local alpha = speed * 3
		surface.SetDrawColor(c.bg)
		surface.DrawRect(x, y, r.w, r.h)
		surface.SetDrawColor(ColorAlpha(c.speedmeter, alpha))
		if r.center then
			w = (r.w / 2) * percentage / 100
			surface.DrawRect(x + r.w / 2, y, w, r.h)
			surface.DrawRect(x + r.w / 2 - w + 1, y, w, r.h)
			local y = y + r.h / 2
			draw.SimpleTextOutlined(text, "WCD::FontHUD", x + r.w / 2, y, ColorAlpha(color_white, alpha + 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ColorAlpha(color_black, alpha + 50))
		else
			w = r.h * percentage / 100
			surface.DrawRect(x, y + (r.h - w), r.w, w)
			draw.SimpleTextOutlined(text, "WCD::FontHUD", x + r.w / 2, y - 10, ColorAlpha(color_white, alpha + 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ColorAlpha(color_black, alpha + 50))
		end

		surface.SetDrawColor(ColorAlpha(c.border, alpha))
		surface.DrawOutlinedRect(x, y, r.w, r.h)
	end
end)

WCD.UnderglowTracker = {}
hook.Add("OnEntityCreated", "WCD::UnderglowTracker", function(ent) if ent:IsVehicle() and ent.WCD_GetId and ent:WCD_GetId() != 0 and ent.WCD_ProcessUnderglow then WCD.UnderglowTracker[ent] = true end end)
hook.Add("Think", "WCD::Underglow", function()
	local ply = LocalPlayer()
	if not ply:IsValid() then return end
	if input.IsKeyDown(KEY_G) and (not ply.__WCDLastUnderglowToggle or ply.__WCDLastUnderglowToggle + 0.5 < CurTime()) and IsValid(ply:GetVehicle()) and ply:GetVehicle().WCD_GetUnderglow and ply:GetVehicle():WCD_GetUnderglowColor() then
		ply.__WCDLastUnderglowToggle = CurTime()
		net.Start("WCD::ToggleUnderglow")
		net.SendToServer()
	end

	for ent, v in pairs(WCD.UnderglowTracker) do
		if not IsValid(ent) or not ent.WCD_ProcessUnderglow then
			WCD.UnderglowTracker[ent] = nil
			continue
		elseif ply:GetPos():DistToSqr(ent:GetPos()) > 1000000 then
			continue
		end

		ent:WCD_ProcessUnderglow()
		continue
	end
end)

WCD:Print(WCD:Translate("loadedFile", WCD.Lang.fileNames.visual or "visual"))