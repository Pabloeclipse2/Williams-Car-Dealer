--[[
Server Name: [GER] NATO vs. Terror [MilitaryRP] by ★ MG ★
Server IP:   45.157.232.23:27030
File Path:   addons/wcd/lua/wcd/client/wcd_net.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

net.Receive("WCD::SetVehicleNitro", function()
	local ent = Entity(net.ReadFloat())
	local nitro = net.ReadFloat()
	if IsValid(ent) and ent.WCD_SetNitro then ent:WCD_SetNitro(nitro) end
end)

net.Receive("WCD::SendSpecifics", function() LocalPlayer():WCD_SetSpecifics(net.ReadFloat(), net.ReadTable()) end)
net.Receive("WCD::Owned", function()
	local id = net.ReadFloat()
	LocalPlayer():WCD_AddVehicle(id)
	WCD:Print("We own vehicle: " .. id)
	if IsValid(WCD.DealerUI) then
		for i, v in pairs(WCD.DealerUI.lists) do
			WCD.DealerUI:RebuildList(i)
		end
	end

	WCD.__Change = true
end)

net.Receive("WCD::UnOwned", function()
	LocalPlayer():WCD_RemoveVehicle(net.ReadFloat())
	if IsValid(WCD.DealerUI) then
		for i, v in pairs(WCD.DealerUI.lists) do
			WCD.DealerUI:RebuildList(i)
		end
	end

	WCD.__Change = true
end)

net.Receive("WCD::Notification", function() WCD:Notification(net.ReadString()) end)
net.Receive("WCD::SendSettings", function()
	httpnet.Download(httpnet.ReadKey(), function(tbl)
		--print("call handlesettings in client wcd_net")
		WCD:HandleSettings(tbl)
		WCD:ProcessFuel()
		WCD:Notification(WCD.Lang.settingsReceived)
	end)
end)

net.Receive("WCD::AccessGroups", function(_, ply)
	local sendAll = net.ReadBool()
	if sendAll then
		httpnet.Download(httpnet.ReadKey(), function(tbl)
			WCD.AccessGroups = tbl
			WCD:Print("Received all access groups.")
		end)
	else
		local data = net.ReadTable()
		WCD.AccessGroups[data.name] = data
		WCD:Print("Received access group '" .. data.name .. "'.")
	end

	if WCD.AccessHelper and IsValid(WCD.AccessHelper) then WCD:OpenAccessHelper() end
	WCD.__Change = true
end)

net.Receive("WCD::DeleteAccessGroup", function(_, ply)
	local name = net.ReadString()
	WCD.AccessGroups[name] = nil
	WCD:Print("Deleted access group '" .. name .. "'.")
	if WCD.AccessHelper and IsValid(WCD.AccessHelper) then WCD:OpenAccessHelper() end
	WCD.__Change = true
end)

net.Receive("WCD::DealerGroups", function(_, ply)
	local sendAll = net.ReadBool()
	if sendAll then
		httpnet.Download(httpnet.ReadKey(), function(tbl)
			WCD.DealerGroups = tbl
			WCD:Print("Received all dealer groups.")
		end)
	else
		local id = net.ReadFloat()
		local name = net.ReadString()
		WCD.DealerGroups[id] = name
		WCD:Print("Received dealer group '" .. name .. "'.")
	end

	if WCD.DealerHelper and IsValid(WCD.DealerHelper) then WCD:OpenDealerHelper() end
	WCD.__Change = true
end)

net.Receive("WCD::DeleteDealerGroup", function(_, ply)
	local id = net.ReadFloat()
	--print(id)
	WCD:Print("Deleted dealer group: " .. (WCD.DealerGroups[id] or "no group") .. ".")
	WCD.DealerGroups[id] = nil
	if WCD.DealerHelper and IsValid(WCD.DealerHelper) then timer.Simple(0.25, function() WCD:OpenDealerHelper() end) end
	WCD.__Change = true
end)

net.Receive("WCD::EditDealerGroup", function(_, ply)
	local id = net.ReadFloat()
	local name = net.ReadString()
	WCD.DealerGroups[id] = name
	WCD:Print("Received edited dealer group with id " .. id .. ", new name: " .. name .. ".")
	if WCD.DealerHelper and IsValid(WCD.DealerHelper) then WCD:OpenDealerHelper() end
	WCD.__Change = true
end)

net.Receive("WCD::DeleteVehicle", function(_, ply)
	local id = net.ReadFloat()
	if WCD.List[id] then WCD.List[id]:Delete() end
	if IsValid(WCD.AdminUI) then
		WCD.AdminUI.views[2]:RebuildTop()
	elseif IsValid(WCD.DealerUI) then
		WCD.DealerUI:Remove()
	end

	WCD.__Change = true
end)

net.Receive("WCD::AddVehicle", function(_, ply)
	httpnet.Download(httpnet.ReadKey(), function(data)
		WCD.List[data.id] = Vehicle(data)
		if IsValid(WCD.AdminUI) then WCD.AdminUI.views[2]:RebuildTop() end
		WCD:Print("Received data for id " .. data.id)
		WCD.__Change = true
	end)
end)

net.Receive("WCD::AddAllVehicle", function()
	httpnet.Download(httpnet.ReadKey(), function(tbl)
		for _, data in pairs(tbl) do
			WCD.List[data.id] = Vehicle(data)
			if IsValid(WCD.AdminUI) then WCD.AdminUI.views[2]:RebuildTop() end
			WCD:Print("Received data for id " .. data.id)
			WCD.__Change = true
		end
	end)
end)

WCD:Print(WCD:Translate("loadedFile", WCD.Lang.fileNames.net or "net"))