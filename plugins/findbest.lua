concommand.Add("dv2_bestore", function()
	local ores = {}
	for ID, System in pairs(GAMEMODE.SolarSystems) do
		ores[ID] = {ID=ID, Ore = GenerateItem(ID,System.Tech,"Resource","Any",true)}
	end
	table.sort(ores, function(a,b) return a.Ore.Price > b.Ore.Price end)
	PrintTable(ores[1])
	PrintTable(GAMEMODE.SolarSystems[ores[1].ID])
end)

concommand.Add("dv2_oreinfo", function()
	local Ores = DV2p.GenerateAllMiningOres(GAMEMODE.SolarSystems)
	print("ID,Tech,Ore Name,Base Price,System Name")
	for k,v in pairs(Ores) do
		print(k..","..v.Tech..","..v.Name..","..v.Price..","..GAMEMODE.SolarSystems[k].Name)
	end
end)