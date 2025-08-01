--[[
Server Name: [GER] NATO vs. Terror [MilitaryRP] by ★ MG ★
Server IP:   45.157.232.23:27030
File Path:   addons/wcd/lua/wcd/wcd_customization.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

function WCD:RetrieveAllowedCustomizations(id, ply)
	local ref = self.List[id]
	if not ref then return false end
	if ref.__WCDEnt and not self.Settings.allowEntityCustomization then return false end
	--if(!ref or self.List[id].__WCDEnt) then return false end
	if not ref.GetDisallowCustomization or ref:GetDisallowCustomization() then return false end
	local tbl = {
		nitro = not ref:GetDisallowNitro(),
		skin = not ref:GetDisallowSkin(),
		color = not ref:GetDisallowColor(),
		bodygroups = not ref:GetDisallowBodygroup(),
		underglow = not ref:GetDisallowUnderglow()
	}

	if ref.__WCDEnt or not WCD.Settings.nitro or ref:GetDisallowNitro() then tbl.nitro = false end
	for i, v in pairs(tbl) do
		if not v then
			tbl[i] = nil
		elseif ply and WCD.RankCustomizationRequirements[i] and not table.HasValue(WCD.RankCustomizationRequirements[i], ply:GetUserGroup()) then
			tbl[i] = nil
		end
	end
	return (table.Count(tbl) > 0 and tbl) or false
end

function WCD:CalculateCustomization(ply, ent, data, oldData)
	if not (ent and IsValid(ent) and ent:WCD_GetId()) then return end
	local ref = self.List[ent:WCD_GetId()]
	if not ref then return end
	local oldData = oldData or (ply.__WCDSpecifics and ply.__WCDSpecifics[ent:WCD_GetId()]) or {}
	local newData = {}
	local price = 0
	local allowed = self:RetrieveAllowedCustomizations(ent:WCD_GetId(), ply) or {}
	if data.color and allowed.color and not ref:GetDisallowColor() then
		for i, v in pairs(data.color) do
			if not (i == 'r' or i == 'g' or i == 'b') then data.color[i] = nil end
		end

		data.color.a = 255
		if ref:GetColor().r != data.color.r or ref:GetColor().g != data.color.g or ref:GetColor().b != data.color.b then
			newData.color = data.color
			price = price + ref:GetColorCost()
			self:Print("Color Change")
		end
	end

	if data.bodygroups and allowed.bodygroups and not ref:GetDisallowBodygroup() then
		if oldData.bodygroups then
			for i, v in pairs(oldData.bodygroups) do
				if data.bodygroups[i] != v then
					price = price + ref:GetBodygroupCost()
					self:Print("Bodygroup Change")
				end
			end
		else
			for i, v in pairs(data.bodygroups) do
				if v != ent:GetBodygroup(i) then
					price = price + ref:GetBodygroupCost()
					self:Print("Bodygroup Change")
				end
			end
		end

		newData.bodygroups = data.bodygroups
	end

	if data.skin and allowed.skin and not ref:GetDisallowSkin() then
		data.skin = math.Clamp(data.skin, 0, ent:SkinCount() or 1)
		local active = oldData.skin or ent:GetSkin()
		if data.skin != active then
			price = price + ref:GetSkinCost()
			newData.skin = data.skin
			self:Print("Skin Change")
		end
	end

	if data.nitro and allowed.nitro and not ref:GetDisallowNitro() and data.nitro != oldData.nitro then
		data.nitro = math.Clamp(data.nitro, 0, 3)
		WCD:Print("Nitro Change")
		if data.nitro >= 0 then
			if data.nitro == 1 then
				price = price + ref:GetNitroOneCost()
			elseif data.nitro == 2 then
				price = price + ref:GetNitroTwoCost()
			elseif data.nitro == 3 then
				price = price + ref:GetNitroThreeCost()
			end
		end

		newData.nitro = data.nitro
	end

	if data.underglow and allowed.underglow and not ref:GetDisallowUnderglow() then
		local a = data.underglow
		local b = oldData.underglow or ent:WCD_GetUnderglow()
		for i, v in pairs(data.underglow) do
			if not (i == 'r' or i == 'g' or i == 'b') then data.underglow[i] = nil end
		end

		newData.underglow = a
		newData.underglow["a"] = 255
		price = price + ref:GetUnderglowCost()
		self:Print("Underglow Change")
	end
	return price, newData
end

if SERVER then
	function WCD:PurchaseCustomization(ply, ent, data)
		if not (IsValid(ply) and IsValid(ent) and data and ent.__WCDId and not self.List[ent.__WCDId]:GetDisallowCustomization()) then return end
		local price, data = self:CalculateCustomization(ply, ent, data)
		if not (price and data) or not ply:canAfford(price) then return end
		ply:addMoney(-price)
		ply.__WCDSpecifics[ent.__WCDId] = data
		ply:WCD_Notify(self:Translate(customizationBought, DarkRP.formatMoney(price)))
		self:ApplySpecifics(ent)
		self:SavePlayerData("specifics", ply, ply.__WCDSpecifics)
	end
end

WCD:Print(WCD:Translate("loadedFile", WCD.Lang.fileNames.customization or "customization functionality"))