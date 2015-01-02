PLUGIN.Name = "Item Generator"

local count = table.Count(GAMEMODE.SolarSystems)
local n = 10 //because metamist logic
local max = (n*(2*count-n+1))/2


concommand.Remove("dv2_generate_recipe")
concommand.Add("dv2_generate_recipe", function() 
	local Ore1 = {
		Tech = 1000,
		ID = 1,
		Material = true,
	}
	local Ore2 = table.Copy(Ore1)
	
	local weapon = {}
	print("generating recipies: ", max-55)
	for i=55, max do
		Ore2.ID = Ore2.ID + 1		
		local wep = CraftItem({Ore1, Ore2})
		if not wep or wep.Rarity.Name == "Common" or wep.Rarity.Name == "Uncommon" or wep.Class == "Laser" then continue end

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
				addToContent("        ", Rarity.Name)
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