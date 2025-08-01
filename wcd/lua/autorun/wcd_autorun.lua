--[[
Server Name: [GER] NATO vs. Terror [MilitaryRP] by ★ MG ★
Server IP:   45.157.232.23:27030
File Path:   addons/wcd/lua/autorun/wcd_autorun.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

WCD = WCD or {}
WCD_OK = 1
WCD_WARNING = 2
WCD_DANGER = 3
COLOR_GREEN = Color(0, 168, 0)
COLOR_YELLOW = Color(168, 168, 0)
COLOR_RED = Color(168, 0, 0)
-- 1 = shared
-- 2 = server
-- 3 = client
local files = {{"wcd_util", "wcd_settings", "wcd_class_vehicle", "wcd_meta_player", "wcd_vehicle_data", "wcd_customization", "wcd_minimal", "wcd_fuel"}, {"wcd_database", "wcd_main", "wcd_net", "wcd_dealer", "wcd_disable_phystool", "wcd_various"}, {"wcd_colors", "wcd_vgui", "wcd_clientside_settings", "wcd_various", "wcd_dealer_ui", "wcd_admin_ui", "wcd_net", "wcd_visual", "wcd_designer_ui"}}
include("wcd/language/wcd_english.lua")
AddCSLuaFile("wcd/language/wcd_english.lua")
if SERVER then
	local langFiles, _ = file.Find("wcd/language/*", "LUA")
	for i, v in pairs(langFiles) do
		AddCSLuaFile("wcd/language/" .. v)
	end

	local wrappers, _ = file.Find("wcd/wrapper/*", "LUA")
	for i, v in pairs(wrappers) do
		AddCSLuaFile("wcd/wrapper/" .. v)
	end
end

for i, v in pairs(files) do
	for _, v in pairs(v) do
		local path = v .. ".lua"
		if i == 1 then
			if SERVER then AddCSLuaFile("wcd/" .. path) end
			include("wcd/" .. path)
		elseif i == 2 then
			if CLIENT then continue end
			path = "server/" .. path
			include("wcd/" .. path)
		elseif i == 3 then
			path = "client/" .. path
			if SERVER then
				AddCSLuaFile("wcd/" .. path)
			else
				include("wcd/" .. path)
			end
		end
	end
end

if not WCD.Print then
	MsgC(Color(255, 0, 0), "[WCD] Fatal error loading files!")
	WCD = nil
else
	WCD:Print("Finished loading files!")
end

WCD:Print(WCD:Translate("loadedFile", WCD.Lang.fileNames.storage or "storage"))