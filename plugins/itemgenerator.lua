PLUGIN.Name = "Item Generator"

local count = table.Count(GAMEMODE.SolarSystems)
local n = 10 //because metamist logic
local max = (n*(2*count-n+1))/2

function PLUGIN:GetOresForCraftingID( id, numOres )
	numOres = numOres or 10

	if id < ( numOres * ( numOres + 1 ) ) / 2 then
		return {}, 0
	end

	local remainder = id
	local list = {}
	local maxID = count
	for i = 1, numOres do
		
		local nextNum = math.min( remainder, maxID )
		while nextNum > 1 and list[ nextNum ] or ( ( i ~= numOres and nextNum > remainder - ( ( ( (numOres - i) * (numOres - i + 1) ) ) / 2 ) ) ) do
			nextNum = nextNum - 1
			if nextNum <= 0 then break end
		end
		
		remainder = remainder - nextNum
		list[ nextNum ] = true
		
		if remainder <= 0 then break end
	end
	if remainder > 0 then
		return {}, 0
	end

	local total = 0
	local newList = {}
	for k, v in pairs( list ) do
		newList[ #newList + 1 ] = k
		total = total + k
	end

	table.sort( newList )
	return newList, total
end
/*
if not wep or wep.Rarity.Name == "Common" or wep.Rarity.Name == "Uncommon" or wep.Class == "Laser" then continue end
weapon[wep.Type] = weapon[wep.Type] or {}
		weapon[wep.Type][wep.Class] = weapon[wep.Type][wep.Class] or {}
		weapon[wep.Type][wep.Class][wep.Rarity] = weapon[wep.Type][wep.Class][wep.Rarity] or {}
		local parent = weapon[wep.Type][wep.Class][wep.Rarity]

		parent[#parent+1] = {CraftID = Ore2.ID + 1, Damage = wep.Dmg, DPS = wep.Dmg / wep.CD, Cooldown = wep.CD, Price = wep.Price}
*/
function PLUGIN:GenerateRecipeList()
	local Ore1 = {
		Tech = 1052,
		ID = 1,
		Material = true,
	}
	local Ore2 = table.Copy(Ore1)
	
	local weps = {}
	for i=55, max do
		Ore2.ID = Ore2.ID + 1		
		local wep = CraftItem({Ore1, Ore2})
		wep.CraftID = Ore2.ID+1
		wep.DPS = (wep.Dmg / wep.CD)
		if wep then weps[#weps+1] = wep end
	end
	return weps
end
local Rarities = {"Rare","Legendary"}
local function ComparePrice(a,b) return a.Price > b.Price end
local function CompareDPS(a, b) return a.DPS > b.DPS end
concommand.Add("dv2_generate_recipe", function() 
	local wps = DV2P.GetPlugin( "Item Generator" ):GenerateRecipeList()
	table.sort(wps, CompareDPS)

	local export = file.Open( "drecipe.txt", "w", "DATA" )
	Msg("Writing file: ")
	for _,ShipType in pairs(GetShipTypes()) do
		export:Write(""..ShipType.."\n")
		for _, WeaponClass in pairs(GetWeaponClasses()) do
			if WeaponClass == "Laser" then continue end
			export:Write("    "..WeaponClass.."\n")
			for _,Rarity in pairs(Rarities) do
				export:Write("        "..Rarity.."\n")
				for _, Weapon in pairs(wps) do
					if ShipType == Weapon.Type and WeaponClass == Weapon.Class and Rarity == Weapon.Rarity.Name then
						export:Write("                ".."CraftID: "..Weapon.CraftID.."    ".."DMG: "..Weapon.Dmg.."    ".."DPS: "..Weapon.DPS.."\n")
					end
				end
			end
		end
	end
	export:Flush()
	export:Close()
	print(" done!")
end)


concommand.Add("dv2_item_most_expensive", function()
	local weps = DV2P.GetPlugin( "Item Generator" ):GenerateRecipeList()
	table.sort(weps, ComparePrice)
	for i=1, 5 do
		local Weapon = weps[i]
		print("                ", "CraftID: "..Weapon.CraftID.."    ".."Price: "..Weapon.Price.."    ".."DPS: "..Weapon.DPS.."    "..Weapon.Type.."    "..Weapon.Class.."    "..Weapon.Rarity.Name)
	end
end)
concommand.Add( "dv2_craftingid_ores", function( ply, cmd, args )
	local id = tonumber( args[ 1 ] )
	local num = tonumber( args[ 2 ] )

	if id == nil then return end
		
	local ids, total = DV2P.GetPlugin( "Item Generator" ):GetOresForCraftingID( id, num )
	print( table.concat( ids, "," ) )
	print( "Adds up to: " .. total )
end )