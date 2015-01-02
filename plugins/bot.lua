//function player:SetWarpDestination(vec,fpos)

local actions = {"Warping to Station", "Warping to Asteroid", "Selling", "Mining"}
local activeConVar = CreateClientConVar( "dv2_automine", "0" )
local ConVarStatus = CreateClientConVar( "dv2_automine_status", "0" )
local lp = LocalPlayer()
local action = 0

local function Mine()
	local Asteroid = DV2P.GetNearest("Asteroid")
	if not Asteroid then return false end
	//DV2P.ClearTargets()
	lp:RequestTarget( Asteroid.ID, 1, false, false)
	DV2P.FireAll("Mining Laser")

	local Pirate = DV2P.GetNearestNPC(5000)
	if not Pirate then DV2P.FireAll("Pulse Cannon", false) return end
	lp:RequestTarget(Pirate:GetIndex(),2,false,true)
	DV2P.FireAll("Pulse Cannon")
end

local function SA(na)
	if ConVarStatus:GetInt() == 1 and action != na then 
		print("DV2 Bot:", actions[na]) 
		if na == 2 then
			print("DV2 Bot: ", string.Comma(lp:GetMoney()).." GCS")
		end
	end
	action = na
end

local w,h = ScrW(), ScrH()
hook.Add("HUDPaint", "action", function()
	if activeConVar:GetInt() == 0 then return end
	DrawText(actions[action] or "no action", "DefaultSmall", w/2, h/2, MAIN_TEXTCOLOR)
end)

local lastrun = 0
hook.Add("Tick", "dv2_automine_tick", function() 
	if activeConVar:GetInt() == 0 then return end
	if CurTime() < lastrun + 1 then return end
	lastrun = CurTime()

	if not DV2P.IsMoving() then
		if DV2P.IsInventoryFull() then
			if DV2P.IsAt("Station") then DV2P.SellEverything() SA(3) end
			if (not DV2P.IsAt("Station")) then DV2P.WarpToNearest("Station") SA(1) end
		else
			if DV2P.IsAt("AsteroidField") then Mine() SA(4) end
			if (not DV2P.IsAt("AsteroidField")) then DV2P.WarpToNearest("AsteroidField") SA(2) end
		end
	end
	if not DV2P.IsInventoryFull() and lp:GetDocked() then lp:RequestUndock() StationMenu:SetVisible( false ) end
end)