--[[
Server Name: [GER] NATO vs. Terror [MilitaryRP] by ★ MG ★
Server IP:   45.157.232.23:27030
File Path:   addons/wcd/lua/wcd/client/wcd_dealer_ui.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

WCD.DealerUI = WCD.DealerUI or nil
local c = WCD.Colors
local downGradient = Material("vgui/gradient_down")
local upGradient = Material("vgui/gradient_up")
local rightGradient = Material("vgui/gradient-l")
local leftGradient = Material("vgui/gradient-r")
local offsetAdd = 14
local blackCol = Color(0, 0, 0, 120)
local blackCol_2 = Color(30, 30, 30)
local whiteCol = Color(255, 255, 255)

function WCD:OpenDealer(dealer)
	if IsValid(self.DealerUI) then self.DealerUI:Remove() end
	if !self.ClientSideSettingsFound then
		WCD:OpenClientSettings(function() WCD:OpenDealer(dealer) end)
		self.ClientSideSettingsFound = true
		return
	end

	if !IsValid(dealer) or dealer:GetNW2Int("WCD::Group", -1) == -1 then return end
	data = data or {}
	data.dealerName = dealer:GetNW2String("WCD::Name", "No Name") or "Unknown Dealer"
	data.accessGroup = dealer:GetNW2Int("WCD::Group", 1) or 1
	local m = (self.Client.Settings.Fullscreen and 1) or 0.85
	local w, h = ScrW() * m, ScrH() * m
	local frame = vgui.Create("EditablePanel")
	local percentageSides = 0.13
	local percentageTopBottom = 0.11
	local bottomW = w - (w * percentageSides) * 2
	self.DealerUI = frame
	frame:SetSize(w, h)
	frame:Center()
	frame:MakePopup()
	function frame:Think()
		if input.IsKeyDown(KEY_ESCAPE) then
			if WCD.__FavoriteChange then
				WCD:SaveFavorites()
				WCD.__FavoriteChange = false
			end

			frame:Remove()
		end
	end

	frame.active = 1
	frame.car = nil
	function frame:Paint(w, h)
		surface.SetDrawColor(color_black)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	frame.left = frame:Add("EditablePanel")
	frame.left:Dock(LEFT)
	frame.left:SetWide(w * percentageSides)
	frame.right = frame:Add("EditablePanel")
	frame.right:Dock(RIGHT)
	frame.right:SetWide(frame.left:GetWide())
	frame.top = frame:Add("EditablePanel")
	frame.top:Dock(TOP)
	frame.top:SetTall(h * percentageTopBottom)
	frame.bottom = frame:Add("EditablePanel")
	frame.bottom:SetTall(frame.top:GetTall())
	frame.bottom:Dock(BOTTOM)
	frame.middleBack = frame:Add("EditablePanel")
	frame.middleBack:Dock(FILL)
	frame.middle = frame.middleBack:Add("EditablePanel")
	frame.middle:Dock(FILL)
	if self.Client.Settings.MoveableModel then
		frame.middle.model = frame.middle:Add("DAdjustableModelPanel")
	else
		frame.middle.model = frame.middle:Add("DModelPanel")
	end

	if !WCD.Client.Settings.SpinModel then
		function frame.middle.model:LayoutEntity()
		end
	end

	frame.middle.model:Dock(FILL)
	--[[ BASE CONTAINERS CREATED ]]
	--
	function frame.right:Paint(w, h)
		surface.SetDrawColor(c.frameBg)
		surface.DrawRect(0, 0, w, h)
	end

	function frame.top:Paint(w, h)
		surface.SetDrawColor(c.frameBg)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(c.gradient)
		surface.SetMaterial(rightGradient)
		surface.DrawTexturedRect(0, 0, WCD.Settings.ShadowSize, h)
		surface.SetDrawColor(c.gradient)
		surface.SetMaterial(leftGradient)
		surface.DrawTexturedRect(w - WCD.Settings.ShadowSize, 0, WCD.Settings.ShadowSize, h)
		draw.SimpleTextOutlined(dealer:GetNW2String("WCD::Name", "No Name"), "WCD::FontFrameTitle", w / 2, h / 2 - 36, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
		draw.SimpleTextOutlined(WCD.DealerGroups[data.accessGroup] or "", "WCD::FontFrameSubTitle", w / 2, h / 2 + 15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
	end

	function frame.bottom:Paint(w, h)
		surface.SetDrawColor(c.frameBg)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(c.gradient)
		surface.SetMaterial(rightGradient)
		surface.DrawTexturedRect(0, 0, WCD.Settings.ShadowSize, h)
		surface.SetMaterial(leftGradient)
		surface.DrawTexturedRect(w - WCD.Settings.ShadowSize, 0, WCD.Settings.ShadowSize, h)
	end

	function frame.middleBack:Paint(w, h)
		surface.SetDrawColor(c.frameBg)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(c.gradient)
		surface.SetMaterial(downGradient)
		surface.DrawTexturedRect(0, 0, w, WCD.Settings.ShadowSize)
		surface.SetMaterial(upGradient)
		surface.DrawTexturedRect(0, h - WCD.Settings.ShadowSize, w, WCD.Settings.ShadowSize)
		surface.SetMaterial(rightGradient)
		surface.DrawTexturedRect(0, 0, WCD.Settings.ShadowSize, h)
		surface.SetMaterial(leftGradient)
		surface.DrawTexturedRect(w - WCD.Settings.ShadowSize, 0, WCD.Settings.ShadowSize, h)
		local offset = offsetAdd
		if self.text then
			draw.SimpleTextOutlined(self.text, "WCD::FontGenericSmall", 13, offset, color_white, 0, 0, 1, color_black)
			offset = offset + offsetAdd
		end

		if self.text2 then
			draw.SimpleTextOutlined(self.text2, "WCD::FontGenericSmall", 13, offset, color_white, 0, 0, 1, color_black)
			offset = offset + offsetAdd
		end

		-- todo
		--if self.stats and MG_Vehicles then
		--	offset = offset + offsetAdd
		--	draw.SimpleTextOutlined(WCD:Translate(WCD.Lang.dealerVarious.hp, self.hp), "WCD::FontGenericSmall", 13, offset, color_white, 0, 0, 1, color_black)
		--	offset = offset + offsetAdd
		--	draw.SimpleTextOutlined(WCD:Translate(WCD.Lang.dealerVarious.fuel, self.fuel), "WCD::FontGenericSmall", 13, offset, color_white, 0, 0, 1, color_black)
		--	offset = offset + offsetAdd
		--	draw.SimpleTextOutlined(WCD:Translate(WCD.Lang.dealerVarious.fueltype, self.fueltype), "WCD::FontGenericSmall", 13, offset, color_white, 0, 0, 1, color_black)
		--	offset = offset + offsetAdd
		--end
		if MG_SuperAdminGroups[LocalPlayer():GetUserGroup()] and self.stats then
			offset = offset + offsetAdd
			draw.SimpleTextOutlined(WCD.Lang.dealerVarious.stats, "WCD::FontGenericSmall", 13, offset, color_white, 0, 0, 1, color_black)
			offset = offset + offsetAdd
			if self.stat_hp then
				draw.SimpleTextOutlined(WCD:Translate(WCD.Lang.dealerVarious.hp, self.stat_hp), "WCD::FontGenericSmall", 13, offset, color_white, 0, 0, 1, color_black)
				offset = offset + offsetAdd
			end

			if self.stat_weight then
				draw.SimpleTextOutlined(WCD:Translate(WCD.Lang.dealerVarious.stat_weight, self.stat_weight), "WCD::FontGenericSmall", 13, offset, color_white, 0, 0, 1, color_black)
				offset = offset + offsetAdd
			end

			if self.stat_seats then
				draw.SimpleTextOutlined(WCD:Translate(WCD.Lang.dealerVarious.stat_seats, self.stat_seats), "WCD::FontGenericSmall", 13, offset, color_white, 0, 0, 1, color_black)
				offset = offset + offsetAdd
			end

			if self.stat_engineforce then
				draw.SimpleTextOutlined(WCD:Translate(WCD.Lang.dealerVarious.stat_engineforce, self.stat_engineforce), "WCD::FontGenericSmall", 13, offset, color_white, 0, 0, 1, color_black)
				offset = offset + offsetAdd
			end

			if self.stat_weapons then
				draw.SimpleTextOutlined(WCD.Lang.dealerVarious.stat_weapons, "WCD::FontGenericSmall", 13, offset, color_white, 0, 0, 1, color_black)
				offset = offset + offsetAdd
				for name, tbl in pairs(self.stat_weapons) do
					if !tbl.info then continue end
					draw.SimpleTextOutlined(WCD:Translate(WCD.Lang.dealerVarious.stat_weapon, tbl.info.Pods and #tbl.info.Pods or 1, name), "WCD::FontGenericSmall", 13, offset, color_white, 0, 0, 1, color_black)
					offset = offset + offsetAdd
					local weapon = scripted_ents.Get(tbl.class)
					if !weapon then continue end
					if tbl.info.Ammo or weapon.Ammo then
						draw.SimpleTextOutlined(WCD:Translate(WCD.Lang.dealerVarious.stat_weapon_ammo, tbl.info.Ammo or weapon.Ammo), "WCD::FontGenericSmall", 13, offset, color_white, 0, 0, 1, color_black)
						offset = offset + offsetAdd
					end

					if tbl.info.Damage or weapon.Damage then
						draw.SimpleTextOutlined(WCD:Translate(WCD.Lang.dealerVarious.stat_weapon_damage, tbl.info.Damage or weapon.Damage), "WCD::FontGenericSmall", 13, offset, color_white, 0, 0, 1, color_black)
						offset = offset + offsetAdd
					end

					if tbl.info.FireRate or weapon.FireRate then
						draw.SimpleTextOutlined(WCD:Translate(WCD.Lang.dealerVarious.stat_weapon_firerate, tbl.info.FireRate or weapon.FireRate), "WCD::FontGenericSmall", 13, offset, color_white, 0, 0, 1, color_black)
						offset = offset + offsetAdd
					end

					if weapon.mass or weapon.Mass then
						draw.SimpleTextOutlined("		" .. WCD:Translate(WCD.Lang.dealerVarious.stat_weight, weapon.mass or weapon.Mass), "WCD::FontGenericSmall", 13, offset, color_white, 0, 0, 1, color_black)
						offset = offset + offsetAdd
					end
				end
			end
		end

		--[[TODO: VehicleInator
		local class = frame.completeData and frame.completeData["class"] or false
		local own_col = MilitaryRP:GetCoalitionName(LocalPlayer())
		
		if class and MilitaryRP:IsCoalition(own_col) then
			for k, v in pairs(MG_PointSys.Vehicles.Config.Limiter) do
				if table.HasValue(v["vehicles"], class) then
					
					if MG_PointSys.Vehicles.Config.Limiter[k]["cost"] and MG_PointSys.Vehicles.Config.Limiter[k]["cost"][class] then		
						draw.SimpleTextOutlined("Sonderkosten", "WCD::FontFrameTitle", 13, 65, color_white, 0, 0, 1, color_black)
						
						local i = 0
						for _k, _v in pairs(MG_PointSys.Vehicles.Config.Limiter[k]["cost"][class]) do
							local gib_color = color_white
							if MVT_Resources.Resources[own_col][_k]["current"] < _v then
								gib_color = Color(178, 34, 34)
							end
							draw.SimpleTextOutlined(MVT_Resources.Config_Resources[_k]["name"]..": ".._v, "WCD::FontGenericMedium", 13, 120 + (25 * i), gib_color, 0, 0, 1, color_black)
							i = i + 1
						end
					end					
					
					draw.SimpleTextOutlined(own_col.."-Koalition", "WCD::FontGenericMedium", 13, h - 140 - 13,
						color_white, 0, 0, 1, color_black)
						
					if MG_PointSys.Vehicles.Blocked[own_col] then
						draw.SimpleTextOutlined("Ausparken blockiert", "WCD::FontFrameTitle", 13, h - 80 - 13, Color(178, 34, 34), 0, 0, 1, color_black)
					end
						
					local c_limit = "0"
					if MG_PointSys.Vehicles.ClientLimit and MG_PointSys.Vehicles.ClientLimit[own_col][k] then
						c_limit = MG_PointSys.Vehicles.ClientLimit[own_col][k]
					end
					draw.SimpleTextOutlined("Limit: "..c_limit.." / "..MG_PointSys.Vehicles:GetLimitClient(own_col, k), "WCD::FontFrameTitle", 13, h - 120 - 13,
						color_white, 0, 0, 1, color_black)
				end
			end
		end
		]]
		--
		draw.SimpleTextOutlined(WCD:Translate(WCD.Lang.dealerVarious.wallet, DarkRP.formatMoney(LocalPlayer():getDarkRPVar("money"))), "WCD::FontGenericSmall", 13, h - 14 - 13, color_white, 0, 0, 1, color_black)
	end

	function frame.left:Paint(w, h)
		surface.SetDrawColor(c.frameBg)
		surface.DrawRect(0, 0, w, h)
	end

	--[[ CONTAINERS DONE ]]
	--
	--[[ LEFT CONTAINER CHILDREN ]]
	--
	frame.left.top = frame.left:Add("EditablePanel")
	frame.left.top:Dock(TOP)
	frame.left.top:SetTall(frame.top:GetTall())
	frame.left.top.returnVehicles = frame.left.top:Add("WCD::VariousButton")
	frame.left.top.returnVehicles:SetSize(frame.left:GetWide(), 30)
	frame.left.top.returnVehicles:Dock(TOP)
	frame.left.top.returnVehicles:SetFont("WCD::FontGenericSmall")
	frame.left.top.returnVehicles:SetNewText(WCD.Lang.returnVehicles)
	frame.left.top.returnVehicles:SetButtonColor(c.editButton)
	function frame.left.top.returnVehicles:DoClick()
		net.Start("WCD::Return")
		net.SendToServer()
	end

	frame.left.middle = frame.left:Add("DIconLayout")
	frame.left.middle:Dock(TOP)
	frame.left.middle:SetTall(h - frame.top:GetTall() * 2)
	local menuButtonH = frame.left.middle:GetTall() / #WCD.Lang.dealerButtonsLeft
	frame.left.bottom = frame.left:Add("EditablePanel")
	frame.left.bottom:Dock(FILL)
	--[[ END LEFT CONTAINER CHILDREN ]]
	--
	--[[ RIGHT CONTAINER CHILDREN ]]
	--
	frame.right.top = frame.right:Add("EditablePanel")
	frame.right.top:Dock(TOP)
	frame.right.top:SetTall(frame.top:GetTall())
	frame.right.middle = frame.right:Add("EditablePanel")
	frame.right.middle:Dock(TOP)
	frame.right.middle:SetTall(h - frame.top:GetTall() * 2)
	frame.right.bottom = frame.right:Add("EditablePanel")
	frame.right.bottom:Dock(FILL)
	local menuButtons = {}
	frame.lists = {}
	frame.scrolls = {}
	frame.middles = {}
	local chosenList = 1
	local chosenCar = 1
	local boxes = {}
	local count = 1
	local showPage = dealer:GetNW2Bool("WCD::disableShop", false) and 2
	if WCD.Client.Settings.DefaultDealerTab and WCD.Client.Settings.DefaultDealerTab != 1 then showPage = WCD.Client.Settings.DefaultDealerTab end
	for i, v in pairs(WCD.Lang.dealerButtonsLeft) do
		local btn = frame.left.middle:Add("WCD::MenuButton")
		btn:SetSize(frame.left:GetWide(), menuButtonH)
		btn:SetText(v)
		btn.icon = WCD.Icons.DealerButtons[i]
		if i == 1 and dealer:GetNW2Bool("WCD::disableShop", false) then btn:SetVisible(false) end
		if i == 2 and dealer:GetNW2Bool("WCD::disableGarage", false) then btn:SetVisible(false) end
		frame.middles[count] = frame.right.middle:Add("EditablePanel")
		frame.middles[count]:Dock(TOP)
		frame.middles[count]:SetTall(h - frame.top:GetTall() * 2)
		boxes[count] = {}
		btn.list = frame.lists[count]
		btn.middle = frame.middles[count]
		table.insert(menuButtons, btn)
		function btn:DoClick()
			chosenList = i
			chosenCar = 1
			if boxes and boxes[chosenList] and boxes[chosenList][1] and boxes[chosenList][1].DoClick then
				boxes[chosenList][1]:DoClick()
			else
				if frame.SelectedCar then frame:SelectedCar() end
			end

			for i, v in pairs(menuButtons) do
				v:SetActive(false)
				v.middle:SetVisible(false)
			end

			self:SetActive(true)
			self.middle:SetVisible(true)
		end

		if count == showPage then btn:DoClick() end
		count = count + 1
	end

	--[[ END RIGHT CONTAINER CHILDREN ]]
	--
	--[[ START BOTTOM CONTAINER CHILDREN ]]
	--
	frame.bottom.mainAction = frame.bottom:Add("WCD::ActionButton")
	frame.bottom.mainAction:SetDefault(WCD.Lang.dealerActionButtons.buy)
	frame.bottom.mainAction:SetSize(300, 40)
	frame.bottom.mainAction:SetPos(bottomW / 2 - frame.bottom.mainAction:GetWide() / 2, frame.bottom:GetTall() / 2 - frame.bottom.mainAction:GetTall())
	frame.bottom.subAction = frame.bottom:Add("WCD::ActionButton")
	frame.bottom.subAction:SetFont("WCD::FontGenericSmall")
	frame.bottom.subAction:SetSize(frame.bottom.mainAction:GetWide() * 0.7, 30)
	frame.bottom.subAction:SetPos(bottomW / 2 - frame.bottom.subAction:GetWide() / 2, frame.bottom:GetTall() / 2 + 10)
	frame.bottom.customize = frame.bottom:Add("WCD::MenuButton")
	frame.bottom.customize:SetFont("WCD::FontGenericSmall")
	frame.bottom.customize:SetSize(64, 64)
	frame.bottom.customize.icon = WCD.Icons.DealerButtons[5]
	frame.bottom.customize.round = 32
	frame.bottom.customize:SetCoolTip(WCD.Lang.dealerVarious.customize, frame.bottom)
	frame.bottom.customize:SetPos(5, frame.bottom:GetTall() / 2 - frame.bottom.customize:GetTall() / 2)
	frame.bottom.customize:SetVisible(false)
	function frame.bottom.customize:DoClick()
		if !self.id then return end
		net.Start("WCD::SpawnAndCustomize")
		net.WriteFloat(self.id)
		net.SendToServer()
		frame.right.top.close:DoClick()
	end

	function frame.bottom:Build(id)
		frame.bottom.customize:SetVisible(false)
		frame.middleBack.text2 = nil
		frame.completeData = WCD.List[id]
		if WCD.List[id] then
			-- todo
			--frame.middleBack.stat_hp = MG_Vehicles:GetHP(WCD.List[id].class)
			--frame.middleBack.hp = MG_Vehicles:GetStoredHP(LocalPlayer(), id)
			--frame.middleBack.fuel = MG_Vehicles:GetStoredFuel(LocalPlayer(), id)
			--frame.middleBack.fueltype = MG_Vehicles:GetFuelType(WCD.List[id].class)
			local entdata = scripted_ents.Get(WCD.List[id].class)
			if entdata then
				frame.middleBack.stat_weight = entdata.Weight
				frame.middleBack.stat_seats = entdata.Seats and #entdata.Seats
				frame.middleBack.stat_weapons = entdata.Weapons
				frame.middleBack.stat_engineforce = entdata.EngineForce
			else
				local simfphys = list.Get("simfphys_vehicles")[WCD.List[id].class]
				if simfphys then
					if simfphys.Members then
						frame.middleBack.stat_weight = simfphys.Members.Mass
						frame.middleBack.stat_seats = simfphys.Members.PassengerSeats and #simfphys.Members.PassengerSeats
					end
				end
			end

			frame.middleBack.stats = true
		else
			frame.middleBack.stats = false
		end

		if !id or !LocalPlayer():WCD_HasAccess(id) then
			frame.bottom.mainAction:SetVisible(false)
			frame.bottom.subAction:SetVisible(false)
			frame.middleBack.text = nil
			if id and !LocalPlayer():WCD_HasAccess(id) then
				if LocalPlayer():WCD_Owns(id) then
					frame.bottom.subAction:SetVisible(true)
					frame.bottom.subAction:SetDefault(WCD:Translate(WCD.Lang.dealerActionButtons.sell, WCD.Settings.percentage .. "%"))
					function frame.bottom.subAction:DoClick()
						if self.text == self:GetDefault() then
							self.text = WCD.Lang.dealerActionButtons.sure
							return
						end

						self:SetText(self:GetDefault())
						net.Start("WCD::SellVehicle")
						net.WriteFloat(id)
						net.SendToServer()
					end
				end

				frame.middleBack.text2 = "Kein Zugriff: " .. ((WCD.List[id] and WCD.List[id]:GetAccess()) or "")
			end
			return
		end

		if WCD.Settings.spawnCost and WCD.Settings.spawnCost > 0 then frame.middleBack.text2 = "Ausparkkosten: " .. DarkRP.formatMoney(WCD.Settings.spawnCost) end
		if WCD.List[id].spawnCost and WCD.List[id].spawnCost > 0 then frame.middleBack.text2 = "Ausparkkosten: " .. DarkRP.formatMoney(WCD.List[id].spawnCost) end
		frame.bottom.mainAction:SetVisible(true)
		frame.bottom.subAction:SetVisible(true)
		frame.bottom.customize.id = id
		if WCD:RetrieveAllowedCustomizations(id) then
			if LocalPlayer():WCD_Owns(id) and LocalPlayer():WCD_HasAccess(id) and !dealer:GetNW2Bool("WCD::disableCustomization", false) then
				frame.middleBack.text = nil
				frame.bottom.customize:SetVisible(true)
			else
				frame.middleBack.text = WCD.Lang.dealerVarious.canBeCustomized
			end
		else
			frame.middleBack.text = WCD.Lang.dealerVarious.canNotBeCustomized
		end

		if !LocalPlayer():WCD_Owns(id) then
			frame.bottom.mainAction:SetDefault(WCD.Lang.dealerActionButtons.buy)
			frame.bottom.subAction:SetDefault(WCD.Lang.dealerActionButtons.test)
			if !WCD.Settings.testDriving then frame.bottom.subAction:SetVisible(false) end
			function frame.bottom.mainAction:DoClick()
				if self.text == self:GetDefault() then
					self.text = WCD.Lang.dealerActionButtons.sure
					return
				end

				self.text = self:GetDefault()
				if !LocalPlayer():canAfford(WCD.List[id]:GetPrice()) then
					WCD:Notification(WCD.Lang.dealerActionButtons.noAfford)
					return
				end

				net.Start("WCD::BuyVehicle")
				net.WriteFloat(id)
				net.SendToServer()
			end

			function frame.bottom.subAction:DoClick()
				net.Start("WCD::Spawn")
				net.WriteFloat(id)
				net.WriteBool(true)
				net.SendToServer()
				frame.right.top.close:DoClick()
			end
		else
			frame.bottom.mainAction:SetDefault(WCD.Lang.dealerActionButtons.spawn)
			frame.bottom.subAction:SetDefault(WCD:Translate(WCD.Lang.dealerActionButtons.sell, WCD.Settings.percentage .. "%"))
			if WCD.List[id]:GetPrice() == 0 or WCD.List[id]:GetFree() then frame.bottom.subAction:SetVisible(false) end
			function frame.bottom.mainAction:DoClick()
				net.Start("WCD::Spawn")
				net.WriteFloat(id)
				net.WriteBool(false)
				net.SendToServer()
				frame.right.top.close:DoClick()
			end

			function frame.bottom.subAction:DoClick()
				local ply = LocalPlayer()
				local ressources = MG_Vehicles:GetVehicleRessourceCost(WCD.List[id].class)
				local conf = ressSys.config.ressources
				local skill = ply:getSkillPercentage("vehicle_spawncost")

				local action = function()
					net.Start("WCD::Spawn")
					net.WriteFloat(id)
					net.WriteBool(false)
					net.SendToServer()
				end

				if ressources then
					frame.right.top.close:DoClick()
					local confirmationFrame = vgui.Create("DFrame")
					confirmationFrame:SetTitle("Bist du dir sicher?")
					local resourceCount = table.Count(ressources)
					local estimatedHeight = 110 + (resourceCount * 60) + 100
					confirmationFrame:SetSize(400, math.min(600, estimatedHeight))
					confirmationFrame:Center()
					confirmationFrame:MakePopup()
					confirmationFrame.Paint = MG_Theme.Theme.Frame.Paint
					confirmationFrame.PaintOver = MG_Theme.Theme.Frame.PaintOver
					local confirmationLabel = vgui.Create("DLabel", confirmationFrame)
					confirmationLabel:SetSize(400, confirmationFrame:GetTall())
					confirmationLabel:SetText("")
					confirmationLabel.Paint = function(slf, w, h)
						draw.RoundedBox(2, 5, 30, w - 10, h - 35, blackCol_2)
						draw.SimpleText("Beim Ausparken werden", "ressSys.Base.Font28", w / 2, 45, Color(200, 50, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						draw.SimpleText("Folgende Ressourcen ausgelagert:", "ressSys.Base.Font28", w / 2, 70, Color(200, 50, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						local yPos = 100
						local lineHeight = 30
						for k, v in pairs(ressources) do
							local cost = math.floor(v - (1 * skill))
							draw.SimpleText(conf[k]["DisplayName"], "ressSys.Base.Font28", w / 2, yPos, Color(255, 103, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
							draw.SimpleText(cost .. " " .. conf[k]["unit"], "ressSys.Base.Font28", w / 2, yPos + 30, whiteCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
							yPos = yPos + lineHeight * 2
						end
					end
					local buttonWidth = 380
					local buttonHeight = 40
					local startX = 10
					local yesButton = vgui.Create("DButton", confirmationFrame)
					yesButton:SetSize(buttonWidth, buttonHeight)
					yesButton:SetPos(startX, confirmationFrame:GetTall() - buttonHeight * 2 - 15)
					yesButton:SetText("Ja")
					yesButton:SetFont("ressSys.Base.Font28")
					yesButton.DoClick = function()
						confirmationFrame:Close()
						surface.PlaySound("ui/buttonclick.wav")
						action()
					end
					MG_Theme.Theme.Button.SetupTheme(yesButton)
					local noButton = vgui.Create("DButton", confirmationFrame)
					noButton:SetSize(buttonWidth, buttonHeight)
					noButton:SetPos(startX, confirmationFrame:GetTall() - buttonHeight - 10) 
					noButton:SetText("Nein")
					noButton:SetFont("ressSys.Base.Font28")
					noButton.DoClick = function()
						confirmationFrame:Close()
						surface.PlaySound("ui/buttonclick.wav")
					end
					MG_Theme.Theme.Button.SetupTheme(noButton)
				else
					action()
				end
			end
		end
	end

	--[[ END BOTTOM CONTAINER CHILDREN ]]
	--
	frame.right.top.settings = frame.right.top:Add("WCD::VariousButton")
	frame.right.top.settings:SetSize(frame.right:GetWide() - 26, 30)
	frame.right.top.settings:SetPos(0, 0)
	frame.right.top.settings.text = WCD.Lang.clientSettings
	frame.right.top.settings:SetButtonColor(WCD.Colors.configureButton)
	frame.right.top.settings.icon = WCD.Icons.Wrench
	function frame.right.top.settings:DoClick()
		frame:Remove()
		WCD:OpenClientSettings(function() WCD:OpenDealer(dealer) end)
	end

	frame.right.top.close = frame.right.top:Add("WCD::VariousButton")
	frame.right.top.close:SetSize(26, 30)
	frame.right.top.close.text = "x"
	frame.right.top.close:SetPos(frame.right:GetWide() - frame.right.top.close:GetWide())
	function frame.right.top.close:DoClick()
		if WCD.__FavoriteChange then
			WCD:SaveFavorites()
			WCD.__FavoriteChange = false
		end

		frame:Remove()
	end

	--[[ START INPUT CONTENT ]]
	--
	-- ADD CARS TO RIGHT SIDE MENU
	function frame:SelectedCar(id)
		if !id then
			frame.middle:SetVisible(false)
			frame.bottom:Build()
			return
		end

		frame.middle:SetVisible(true)
		local data = WCD.List[id]
		local ref = WCD.VehicleData[data:GetClass()]
		if !data or !ref then
			WCD:Notification("BUG: No Vehicle Data!")
			return
		end

		if !ref.Model and !data.overrideModel then
			WCD:Notification("BUG: No model for " .. id .. "!")
			return
		end

		if data.overrideModel == "models/error.mdl" then data.overrideModel = ref.Model end
		frame.middle.model:SetModel(data.overrideModel or ref.Model)
		local mn, mx = frame.middle.model.Entity:GetRenderBounds()
		local size = 0
		size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
		size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
		size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
		frame.middle.model:SetFOV(45)
		frame.middle.model:SetCamPos(Vector(size, size, size * 0.5))
		frame.middle.model:SetLookAt((mn + mx) * 0.5)
		frame.middle.model:SetPos(Vector(0, 0, 300))
		if frame.middle.model.CaptureMouse then
			local mouseX, mouseY = input.GetCursorPos()
			local x, y = frame.middle.model:GetPos()
			x = x + frame.middle.model:GetWide() / 2
			y = y + frame.middle.model:GetTall() / 2
			frame.middle.model:OnMousePressed(MOUSE_FIRST)
			timer.Simple(0.25, function() frame.middle.model:OnMouseReleased(MOUSE_FIRST) end)
		end

		local specifics = LocalPlayer():WCD_GetSpecifics(id)
		specifics = specifics or {}
		local m = frame.middle.model
		if m.SetColor then m:SetColor(specifics.color or data:GetColor() or color_white) end
		if m.Entity.SetSkin then m.Entity:SetSkin(specifics.skin or data:GetSkin() or 0) end
		if m.Entity.SetBodygroup then
			for i, v in pairs(specifics.bodygroups or data:GetBodygroups() or {}) do
				m.Entity:SetBodygroup(i, v)
			end
		end

		frame.bottom:Build(id)
	end

	local boxHeight = 54
	function frame:RebuildList(id)
		if IsValid(frame.lists[id]) then frame.lists[id]:Remove() end
		if IsValid(frame.scrolls[id]) then frame.scrolls[id]:Remove() end
		if boxes[id] then
			for i, v in pairs(boxes) do
				if IsValid(v) then v:Remove() end
				boxes[id][i] = nil
			end
		end

		frame.scrolls[id] = frame.middles[id]:Add("DScrollPanel")
		frame.scrolls[id]:Dock(FILL)
		frame.scrolls[id]:GetVBar():SetWide(0)
		frame.lists[id] = frame.scrolls[id]:Add("DIconLayout")
		frame.lists[id]:Dock(FILL)
		if clean then
			WCD.__Change = true
			chosenCar = 1
		end

		local tbl = WCD:GetSortedDealerTable(id, data.accessGroup or 1)
		if id == chosenList and table.Count(tbl) < 1 then frame:SelectedCar() end
		for i2, v2 in pairs(tbl) do
			if dealer:GetNW2Bool("WCD::disableShop", false) and !LocalPlayer():WCD_Owns(v2) then continue end
			local box = frame.lists[id]:Add("WCD::CarBox")
			box:SetSize(frame.right:GetWide(), boxHeight)
			box:Setup()
			box:SetVehicle(v2)
			table.insert(boxes[id], box)
			function box:DoClick()
				chosenList = id
				chosenCar = i2
				frame:SelectedCar(v2)
				for i, v in pairs(boxes[chosenList]) do
					if IsValid(v) then v.active = false end
				end

				self.active = true
			end

			if id == chosenList and i2 == chosenCar then box:DoClick() end
		end
	end

	for i = 1, 4 do
		frame:RebuildList(i)
	end
	--[[ END INPUT CONTENT ]]
	--
end

net.Receive("WCD::OpenDealer", function() WCD:OpenDealer(Entity(net.ReadFloat())) end)
timer.Simple(0, function() end) --WCD:OpenDealer(LocalPlayer():GetEyeTrace().Entity)
WCD:Print(WCD:Translate("loadedFile", WCD.Lang.fileNames.dealerui or "dealer UI"))