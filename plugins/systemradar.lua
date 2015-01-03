PLUGIN.Name = "System Radar"

local lp = LocalPlayer()
local UnknownFaction = Color(150,150,150,255)
local OwnFaction = Color(0, 200, 0)
local EnemyFaction = Color(255,0,0)

local function DrawRadarPlayer(faction, ply, y)
	local Class, ID = DV2P.GetLocalSystemPos(ply)
	local ownfaction = LocalPlayer():GetFaction()
	surface.SetFont("DefaultSmall")

	local w1, h1 = surface.GetTextSize( ply:GetName() .." | "..Class.." "..ID)
	DrawText(ply:GetName() .." | "..Class.." "..ID, "DefaultSmall", 202, y, MAIN_TEXTCOLOR)
	faction = (faction != "") and faction or "None"
	
	local col = (ownfaction == faction) and OwnFaction or UnknownFaction

	local w2, h2 = surface.GetTextSize( faction )
	DrawText(faction, "DefaultSmall", 202-w2-5, y, col)

	if input.IsMouseInBox(202-w2-5,y,w1+w2+5,h2) and (input.MousePress(MOUSE_LEFT,"OpenPlayerinfo_"..ply:GetName())) then
		
		if not DV2P.HoversAnyPanel() then
			DV2P.ShowPlayerInfo(ply)
		end
	end
end
hook.Add("HUDPaint", "Devinty2SystemRadar", function()
	local ownfaction = LocalPlayer():GetFaction()
	local factions = {}
	for k, v in pairs( player.GetAllInRegion( LocalPlayer():GetRegion() ) ) do 
		local fac = v:GetFaction()
		factions[fac] = factions[fac] or {}
		factions[fac][#factions[fac]+1] = v
	end

	local y = 150
	if factions[ownfaction] then
		for _, ply in pairs( factions[ownfaction] ) do 
			 DrawRadarPlayer(ownfaction, ply, y)
			y = y + 15
		end
	end
	for faction, players in pairs( factions ) do 
		if faction == ownfaction then continue end
		for _, ply in pairs( players ) do 
			 DrawRadarPlayer(faction, ply, y)
			y = y + 15
		end
	end
end)

DV2P.OFF.AddFunction( "Post_MAP_Frame_Paint", "SystemRadarPaint", function( pnl, w, h )
	if not lp then return end

	xpcall( function()
		if not DV2P.IsMapScreenLocal() then return end

		local reg, id = lp:GetRegion()
		local class, k = DV2P.GetLocalSystemPos( lp )
		local players = player.GetAllInRegion( reg, lp )
		local Scale = MAIN_SOLARSYSTEM_RADIUS/100

		local counts = {
			[k] = 1
		}

		for k, v in pairs( players ) do
			local Reg,ID = v:GetRegion()
			local class, k = DV2P.GetLocalSystemPos( v )

			counts[ k ] = counts[ k ] or 0

			//print( v.SPos )
			local sPos = DV2P.Map.ToScreen((v.PlayerPos-GAMEMODE.SolarSystems[ID].Pos)/Scale+v.FloatPos/Scale)
			DrawOutlinedRect( sPos.x - 3, sPos.y - 3, 6, 6, MAIN_GREENCOLOR )
			DrawText( v:Nick(), "DVTextSmall", sPos.x + 5, sPos.y + 14 * counts[ k ], MAIN_GREENCOLOR )

			if v.WarpDest then
				local warpSPos = DV2P.Map.ToScreen((v.WarpDest-GAMEMODE.SolarSystems[ID].Pos)/Scale+v.WarpDestDetail/Scale)

				DrawLine( sPos.x, sPos.y, warpSPos.x, warpSPos.y, MAIN_GREENCOLOR )
				DrawOutlinedRect( warpSPos.x - 3, warpSPos.y - 3, 6, 6, MAIN_GREENCOLOR )
			end

			counts[ k ] = counts[ k ] + 1
		end

	end, function( err ) print( err ) end )
end )