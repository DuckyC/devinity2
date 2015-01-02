local lp = LocalPlayer()
local MapEntsLookupTable = {["AsteroidField"] = 1,["Planet"] = 1,["Station"] = 1,["GasCloud"] = 1,["BlackHole"] = 1}

function DV2P.GetDistance(ent1, ent2)
	return ( ( (ent1.PlayerPos and ent1.PlayerPos or ent1.Pos) - (ent2.PlayerPos and ent2.PlayerPos or ent2.Pos) ) + ( ent1.FloatPos - ent2.FloatPos ) ):Length()
end

function DV2P.DistanceSort(a,b)
	return DV2P.GetDistance( lp, a ) < DV2P.GetDistance( lp, b )
end

function DV2P.GetLocalSystemPos(pl)
	for k,v in pairs(GAMEMODE.MapEnts) do
		if MapEntsLookupTable[v.Class] and DV2P.GetDistance(pl, v) < 5000 then
			return v.Class, k
		end
	end
	return "In transit", 0
end

function DV2P.GetSystem( name )
	for k, v in pairs( GAMEMODE.SolarSystems ) do
		if v.Name:lower() == name:lower() then
			return v
		end
	end
end

function DV2P.IsAt(Class)
	local AtClass = DV2P.GetLocalSystemPos(lp)
	return AtClass == Class 
end

function DV2P.GetNearest( Class )
	local objects = {}
	local count = 0
	for k,v in pairs( GAMEMODE.MapEnts ) do
		if not Class || v.Class == Class then
			objects[ #objects + 1 ] = v
			count = count + 1
		end
	end
	
	table.sort( objects, DV2P.DistanceSort )
	if count > 0 and objects[ 1 ] then
		return objects[ 1 ]
	end
end
function DV2P.WarpToNearest(Class)
	local nearest = DV2P.GetNearest(Class)
	if nearest then
		LocalPlayer():SetWarpDestination(nearest.Pos, nearest.FloatPos)
	end
end

function DV2P.IsInventoryFull()
	return table.Count(LocalPlayer():GetInventory()) >= MAIN_MAXIMUM_SLOTS
end

function DV2P.CanDock(dock)
	if (!IsValid(lp)) or (!lp:GetRegion() == "Space") or (!lp.PlayerPos or !lp.FloatPos) or lp:GetDocked() then return false end
	for k,v in pairs(self.MapEnts) do
		if (v.Class == "Station" and ((v.Pos-lp.PlayerPos)+(v.FloatPos-lp.FloatPos)):Length() < MAIN_DOCK_RANGE) then
			if dock then lp:RequestDock(k) end
			return true
		end
	end
	return false
end

function DV2P.IsMoving()
	if lp.SimulateSpeed and lp.SimulateSpeed <= 0 then return false end
	if not self.WarpDest then return false end
	return true
end

function DV2P.IsWarping()
	return lp.WarpDest ~= nil
end

function DV2P.UnloadToBank()
	if DV2P.CanDock(true) then return end
	for i=1, MAIN_MAXIMUM_SLOTS do RequestAddBank(i) end
end
function DV2P.SellEverything()
	if DV2P.CanDock(true) then return end
	for i=1, MAIN_MAXIMUM_SLOTS do RequestSellItem( i, 25000 ) end
end

function DV2P.GenerateAllMiningOres(systems)
	systems = systems or GAMEMODE.SolarSystems
	local ores = {}
	for ID,System in pairs(systems) do
		ores[ID] =  GenerateItem(ID,System.Tech,"Resource","Any",true)
	end
	return ores
end

//I know what you're thinking, but fuck you I don't care
function DV2P.EnterGamemode()
	RequestUpdate()
end

function DV2P.ClearTargets()
	for i=1, lp:GetShipData().MaxTargets do 
		lp:RequestTarget( 0, i )
	end
end

function DV2P.FireAll(Class, bool)
	if bool == nil then bool = true end
	for k, v in pairs( lp.Equipment ) do 
		if v.Class == Class then ToggleFire( k, bool ) end
	end
end

function DV2P.GetNearestNPC(maxdistance)
	local NPCs = {}
	for k,v in pairs(DV2_ENTS) do
		if v.Class == "npc_pirate_hawk" then NPCs[#NPCs+1] = v end
	end

	table.sort( NPCs, DV2P.DistanceSort )
	local Pirate = NPCs[1] 
	if Pirate and (DV2P.GetDistance(lp, Pirate) <= (maxdistance or MAIN_SOLARSYSTEM_RADIUS)) then return Pirate end
end

local worldPnl = vgui.GetWorldPanel()
function DV2P.HoversAnyPanel()
	local children = worldPnl:GetChildren()
	
	for k, v in pairs( children ) do
		local x, y = v:GetPos()
		local w, h = v:GetSize()

		if v:IsVisible() then
			if input.IsMouseInBox( x, y, w, h ) then
				return true
			end
		end
	end

	return false
end