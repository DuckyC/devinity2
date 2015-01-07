PLUGIN.Name = "Item Generator"
PLUGIN.Description = "Different kinds of item generators"

local lp = LocalPlayer()

local RaritiyMaterials = {
	Common = Material("devinity2/hud/item_resources/bg_common.png"),
	Uncommon = Material("devinity2/hud/item_resources/bg_uncommon.png"),
	Rare = Material("devinity2/hud/item_resources/bg_rare.png"),
	Legendary = Material("devinity2/hud/item_resources/bg_legend.png"),
}
local Rarities = {"Common", "Uncommon", "Rare","Legendary"}

function PLUGIN:PanelSetup( container )
	self:SetPanelSize( 400, 300 )

	local Tree = vgui.Create("MBTree", container)
	Tree:SetPos(5,0)
	Tree:SetSize(390,295)
	Tree:EnableNodeBG( false )
	Tree.Paint = function(s,w,h)
		DrawOutlinedRect(0,0,w,h,MAIN_GUICOLOR)
	end
	Tree.selecCol = MAIN_COLORD
	Tree:SetVisible(false)
	
	local btnGenerate = vgui.Create( "DVButton", container )
	btnGenerate:SetText( "Generate" )
	btnGenerate.DoClick = function( pnl, w, h)
		Tree:SetVisible(true)
		btnGenerate:SetVisible(false)
		DV2P.GetPlugin( "Item Generator" ):PopulateTreeWithRecipies(Tree)
	end
	self.derma.btnGenerate = btnGenerate
end

function PLUGIN:PopulateTreeWithRecipies(Tree)
	local wps = DV2P.GetPlugin( "Item Generator" ):GenerateRecipeList()

	for _,ShipType in pairs(GetShipTypes()) do
		local ShipTypeNode = Tree:AddNode(ShipType)
		for WeaponClass, Data  in pairs(GetClasses()) do
			local WeaponClassNode = ShipTypeNode:AddNode(WeaponClass)
			WeaponClassNode.Icon:SetMaterial(Data[1])
			for _,Rarity in pairs(Rarities) do
				local RarityNode = WeaponClassNode:AddNode(Rarity)
				RarityNode.Icon:SetMaterial(RaritiyMaterials[Rarity])
				for _, Weapon in pairs(wps) do
					if ShipType == Weapon.Type and WeaponClass == Weapon.Class and Rarity == Weapon.Rarity.Name then
						local WeaponNode = RarityNode:AddNode(Weapon.Name)
						WeaponNode.Icon:SetMaterial(RaritiyMaterials[Rarity])
						WeaponNode.DoClick = function(self)
							local RealWeapon = DV2P.GetPlugin( "Item Generator" ):CraftIDToWepon( Weapon.CraftID ) 
							WeaponNode.Paint = function()
								local LineHeight = WeaponNode:GetLineHeight()
								DrawItemIcon( WeaponNode.Expander.x + WeaponNode.Expander:GetWide() + 4, (LineHeight - WeaponNode.Icon:GetTall()) * 0.5, 16, 16, RealWeapon, 1, WeaponNode, true )
							end
							WeaponNode.Icon:SetVisible( false )
						end
					end
				end
			end
		end
	end
end

function PLUGIN:PanelPerformLayout( container, w, h )
	self.derma.btnGenerate:SetPos( 10, 0 )
	self.derma.btnGenerate:SetSize( w - 20, 30 )
end

local count = table.Count(GAMEMODE.SolarSystems)
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

function PLUGIN:CraftIDToWepon(CraftID)
	local IDs = DV2P.GetPlugin( "Item Generator" ):GetOresForCraftingID( CraftID )
	local Ores = {}
	for i,ID in pairs(IDs) do
		Ores[i] = GenerateItem(ID,GAMEMODE.SolarSystems[ID].Tech+lp:GetSkillLevel("Mining")^2,"Resource","Any",true)
	end
	return CraftItem(Ores ,lp:GetSkillLevel("Crafting")^2)
end

function PLUGIN:GenerateRecipeList()
	local Ore1 = {
		Tech = 1052,
		ID = 1,
		Material = true,
	}
	local Ore2 = table.Copy(Ore1)
	
	local weps = {}
	for i=55, (10*(2*count-10+1))/2 do
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
	print( table.concat( ids, " " ) )
	print( "Adds up to: " .. total )
end )