//function player:SetWarpDestination(vec,fpos)

local actions = {"Warping to Station", "Warping to Asteroid", "Selling", "Mining"}
local activeConVar = CreateClientConVar( "dv2_automine", "0" )
local lp = LocalPlayer()
local action = 0

local function Mine()
	local Asteroid = DV2P.GetNearest("Asteroid")
	if not Asteroid then return false end
	lp:RequestTarget( Asteroid.ID )
	for k, v in pairs( lp.Equipment ) do ToggleFire( k, true ) end
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
	//Warping
	if not DV2P.IsMoving() and DV2P.IsInventoryFull() and (not DV2P.IsAt("Station")) then DV2P.WarpToNearest("Station") action = 1 end
	if not DV2P.IsMoving() and not DV2P.IsInventoryFull() and (not DV2P.IsAt("AsteroidField")) then DV2P.WarpToNearest("AsteroidField") action = 2 end

	//Actions
	if not DV2P.IsMoving() and DV2P.IsInventoryFull() and DV2P.IsAt("Station") then DV2P.SellEverything() action = 3 end
	if not DV2P.IsMoving() and not DV2P.IsInventoryFull() and DV2P.IsAt("AsteroidField") then Mine() action = 4 end

	if lp:GetDocked() and not DV2P.IsInventoryFull() then lp:RequestUndock() StationMenu:SetVisible( false ) end

	lastrun = CurTime()
end)