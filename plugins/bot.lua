PLUGIN.Name = "Bot"
PLUGIN.Description = "Automatically mine and sell"

local actions = {"Warping to Station", "Warping to Asteroid", "Selling", "Mining"}
local ConVarActive		= CreateClientConVar( "dv2_automine", "0" )
local ConVarStatus 		= CreateClientConVar( "dv2_automine_status", "0" )
local ConVarPinPoint 	= CreateClientConVar( "dv2_automine_pinpoint", "0")
local lp = LocalPlayer()
local action = 0

function PLUGIN:PanelSetup( container )
	self:SetPanelSize( 200, 200 )

	local checkboxPinpoint = vgui.Create( "DCheckBoxLabel", container )
	checkboxPinpoint:SetText( "Pinpoint Warp" )
	checkboxPinpoint:SetConVar( "dv2_automine_pinpoint" )
	checkboxPinpoint:SizeToContents()
	checkboxPinpoint:SetChecked(ConVarPinPoint:GetBool())
	self.derma.checkboxPinpoint = checkboxPinpoint

	local checkboxStatus = vgui.Create( "DCheckBoxLabel", container )
	checkboxStatus:SetText( "Print status" )
	checkboxStatus:SetConVar( "dv2_automine_status" )
	checkboxStatus:SizeToContents()
	checkboxStatus:SetChecked(ConVarStatus:GetBool())
	self.derma.checkboxStatus = checkboxStatus

	local btnStart = vgui.Create( "DVButton", container )
	btnStart:SetText( ConVarActive:GetBool()  and "Stop" or "Start" )
	btnStart.DoClick = function( pnl, w, h )
		local Val = (ConVarActive:GetBool() and 0 or 1)
		RunConsoleCommand("dv2_automine", Val)
		btnStart:SetText( Val == 1 and "Stop" or "Start" )
	end
	self.derma.btnStart = btnStart

end

function PLUGIN:PanelPerformLayout( container, w, h )
	self.derma.btnStart:SetPos( 10, h - 40 )
	self.derma.btnStart:SetSize( w - 20, 30 )

	self.derma.checkboxPinpoint:SetPos( 20, 0)
	self.derma.checkboxStatus:SetPos( 20, 20 )
end

local function Mine()
	local Asteroid = DV2P.GetNearest( "Asteroid" )
	if not Asteroid then return false end

	lp:RequestTarget( Asteroid.ID, 1, false, false )
	DV2P.FireAll( "Mining Laser", true, 1 )

	local Pirate = DV2P.GetNearestNPC( 5000 )
	if not Pirate then DV2P.FireAll( "Pulse Cannon", false ) return end

	lp:RequestTarget( Pirate:GetIndex(), 2, false, true )
	DV2P.FireAll( "Pulse Cannon", true, 2 )
end

local function SA(na)
	if ConVarStatus:GetBool() and action != na then 
		print("DV2 Bot:", actions[na]) 
		if na == 2 then
			print("DV2 Bot: ", string.Comma(lp:GetMoney()).." GCS")
		end
	end
	action = na
end

local w,h = ScrW(), ScrH()
hook.Add("HUDPaint", "action", function()
	if not ConVarActive:GetBool() then return end
	DrawText(actions[action] or "no action", "DefaultSmall", w/2, h/2, MAIN_TEXTCOLOR)
end)

local lastrun = 0
hook.Add("Tick", "dv2_automine_tick", function() 
	if not ConVarActive:GetBool()  then return end
	if CurTime() < lastrun + 1 then return end
	lastrun = CurTime()

	if not DV2P.IsMoving() then
		if DV2P.IsInventoryFull() then
			if DV2P.IsAt("Station") then DV2P.SellEverything() SA(3) end
			if (not DV2P.IsAt("Station")) then DV2P.WarpToNearest("Station", ConVarPinPoint:GetBool()) SA(1) end
		else
			if DV2P.IsAt("AsteroidField") then Mine() SA(4) end
			if (not DV2P.IsAt("AsteroidField")) then DV2P.WarpToNearest("AsteroidField", ConVarPinPoint:GetBool()) SA(2) end
		end
	end
	if not DV2P.IsInventoryFull() and lp:GetDocked() then lp:RequestUndock() StationMenu:SetVisible( false ) end
end)