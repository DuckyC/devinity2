local ceil 			= math.ceil
local randomseed 	= math.randomseed
local random 		= math.random
local RT			= table.Random

local NamePrefix = {
	{Name="Common",Chance=100},
	{Name="Uncommon",Chance=30},
	{Name="Rare",Chance=10},
	{Name="Legendary",Chance=1},
}


local function GenerateItemO(Seed,Tech,Class,ShipType)
	math.randomseed(Seed)

	local Rarity = 1
	local Splits = 100/#NamePrefix

	for i = 0,#NamePrefix-1 do	if (random(1,100) <= NamePrefix[#NamePrefix-i].Chance) then Rarity = #NamePrefix-i break end end

	local Dat = {
		ID = Seed,
		Tech = Tech,
		Rarity = Rarity,
		Class = Class,
		Type = ShipType,
		Name = NamePrefix[Rarity].Name.." "..ShipType.. " NAME "..Class,
		Price = random(1,10)*Tech*(Rarity*3-2),
	}

	local Ab = GetWeaponClassData(Class)

	if (Ab) then 
		Dat.Equipable 		= true 
		Dat.CD 		  		= Ab.CD/(0.7+Rarity*0.3)
		Dat.Range 		  	= Ab.Range or 10000
		Dat.Dmg				= random(Ab.Dmg*Dat.Tech,20+Ab.Dmg*Dat.Tech)*Rarity*GetShipTypeDamage(ShipType)
	end

	math.randomseed(os.time())

	return Dat
end


local function CraftItemO(ore1, ore2)
	local Tech, Seed = ore1.Tech+ore2.Tech, ore1.ID+ore2.ID
	Tech = ceil(Tech/2)
	randomseed(Seed)
	return GenerateItemO(random(Seed),Tech,RT(GetWeaponClasses()),RT(GetShipTypes()),false)
end


local Ore1 = {
	Tech = 1000,
	ID = 1,
}
local Ore2 = table.Copy(Ore1)

concommand.Remove("dv2_generate_recipe")
concommand.Add("dv2_generate_recipe", function() 
	local weapon = {}

	for i=55, 1955 do
		Ore2.ID = Ore2.ID + 1		
		local wep = CraftItemO(Ore1, Ore2)
		if not wep then continue end

		weapon[wep.Type] = weapon[wep.Type] or {}
		weapon[wep.Type][wep.Class] = weapon[wep.Type][wep.Class] or {}
		weapon[wep.Type][wep.Class][wep.Rarity] = weapon[wep.Type][wep.Class][wep.Rarity] or {}
		local parent = weapon[wep.Type][wep.Class][wep.Rarity]

		parent[#parent+1] = {CraftID = Ore2.ID + 1, Damage = wep.Dmg, DPS = wep.Dmg / wep.CD, Cooldown = wep.CD}
	end

	function CompareDPS(a, b) return a.DPS > b.DPS end

	local content = ""
	local function addToContent(tab, str) content = content..tab..str.."\r\n" end
	for ShipClass,WeaponTypes in pairs(weapon) do
		addToContent("",ShipClass)
		for WeaponType,Rarities in pairs(WeaponTypes) do
			addToContent("    ", WeaponType)
			for Rarity,Weapons in pairs(Rarities) do
				addToContent("        ", NamePrefix[Rarity].Name)
				table.sort(Weapons, CompareDPS)
				for _,Weapon in pairs(Weapons) do
					addToContent("                ", "CraftID: "..Weapon.CraftID.."    ".."DMG: "..Weapon.Damage.."    ".."DPS: "..Weapon.DPS)
				end
			end
		end
	end
	print(#content, "writing")
	file.Write("dv2exports/recipe.txt", content)
end)