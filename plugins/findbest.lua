PLUGIN.Name = "Find Best"

concommand.Add("dv2_bestore", function()
	local ores = {}
	for ID, System in pairs(GAMEMODE.SolarSystems) do
		ores[ID] = {ID=ID, Ore = GenerateItem(ID,System.Tech+100,"Resource","Any",true)}
	end
	table.sort(ores, function(a,b) return a.Ore.Price > b.Ore.Price end)
	PrintTable(ores[1])
	PrintTable(GAMEMODE.SolarSystems[ores[1].ID])
end)

concommand.Add("dv2_oreinfo", function()
	local Ores = DV2P.GenerateAllMiningOres(GAMEMODE.SolarSystems)
	print("ID,Tech,Ore Name,Base Price,System Name")
	for k,v in pairs(Ores) do
		print(k..","..v.Tech..","..v.Name..","..v.Price..","..GAMEMODE.SolarSystems[k].Name)
	end
end)

concommand.Add("dv2_vcraft", function(_,_,ores)
	local pl = LocalPlayer()
	local crafting = pl:GetSkillLevel("Crafting")^2
	local mining = pl:GetSkillLevel("Mining")^2
	local CraftingList = {}
	for k,v in pairs(ores) do 
		local ID = tonumber(v) 
		if ID then 
			local System = GAMEMODE.SolarSystems[ID]
			local Data = GenerateItem(ID,System.Tech+mining,"Resource","Any",true)
			if Data then CraftingList[#CraftingList+1] = Data else return end
		else return end
	end
	local Data = CraftItem(CraftingList,crafting)
	print(Data.Type.." "..Data.Class.." "..Data.Rarity.Name)
	print("Tech: "..Data.Tech,"DMG: "..Data.Dmg, "CD: "..Data.CD, "DPS: "..(Data.Dmg / Data.CD), "Price: "..Data.Price)
end)