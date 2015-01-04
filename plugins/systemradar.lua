PLUGIN.Name = "System Radar"

surface.CreateFont( "SystemRadar_Name_Big", {size = 16, weight = 0, font = "Jupiter"} )
surface.CreateFont( "SystemRadar_Name_Medium", {size = 12, weight = 800, font = "Jupiter"} )
surface.CreateFont( "SystemRadar_Name_Small", {size = 10, weight = 0, font = "Jupiter"} )
surface.CreateFont( "SystemRadar_Name_Tiny", {size = 8, weight = 0, font = "Jupiter"} )

local fonts = {
	"SystemRadar_Name_Tiny",
	"SystemRadar_Name_Small",
	"SystemRadar_Name_Medium",
	"SystemRadar_Name_Big",
}

local lp = LocalPlayer()
local UnknownFaction = Color(150,150,150,255)
local OwnFaction = Color( 100, 200, 100, 200 )
local EnemyFaction = Color( 200, 100, 100, 200 )

local function GetPlayerColor( ply )
	if not ply then return UnknownFaction end
	local ownFaction = lp:GetFaction()

	local color = UnknownFaction
	local faction = ply:GetFaction()

	if faction ~= "" then
		if faction == ownFaction then
			color = OwnFaction
		else
			color = EnemyFaction
		end
	end

	return color
end

local function DrawRadarPlayer(faction, ply, y)
	local Class, ID = DV2P.GetLocalSystemPos(ply)
	surface.SetFont("DefaultSmall")

	local w1, h1 = surface.GetTextSize( ply:GetName() .." | "..Class.." "..ID)
	DrawText(ply:GetName() .." | "..Class.." "..ID, "DefaultSmall", 202, y, MAIN_TEXTCOLOR)
	faction = (faction != "") and faction or "None"
	
	local col = GetPlayerColor( ply )

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
	local ownFaction = lp:GetFaction()

	xpcall( function()
		local reg, id = lp:GetRegion()

		if not DV2P.IsMapScreenLocal() then
			local counts = {
				[id] = 1
			}
			local Scale = MAIN_MAP_SIZE/2500

			local players = player.GetAll()
			for k, v in pairs( players ) do
				if not v then continue end
				if v == lp then continue end

				local color = GetPlayerColor( v )

				local reg, id = v:GetRegion()
				counts[ id ] = counts[ id ] or 0

				local sys = GAMEMODE.SolarSystems[ id ]
				if not sys then continue end

				local fontID = 1 + math.max( 3 - math.floor( DV2P.Map.Dist / 500 ), 0 )
				local font = fonts[ fontID ]

				local vRealPos = sys.Pos / Scale 
				local sPos = DV2P.Map.ToScreen( vRealPos )
				DrawOutlinedRect( sPos.x - 3, sPos.y - 3, 6, 6, color )
				DrawText( v:Nick(), font, sPos.x + 5, sPos.y + 14 * counts[ id ], color )

				counts[ id ] = counts[ id ] + 1
			end
		else
			local class, k = DV2P.GetLocalSystemPos( lp )
			local players = player.GetAllInRegion( reg, lp )
			local Scale = MAIN_SOLARSYSTEM_RADIUS/100

			local counts = {
				[k] = 1
			}

			for k, v in pairs( players ) do
				if not v then continue end

				local color = GetPlayerColor( v )

				local Reg,ID = v:GetRegion()
				local class, k = DV2P.GetLocalSystemPos( v )

				counts[ k ] = counts[ k ] or 0

				//print( v.SPos )
				local sPos = DV2P.Map.ToScreen((v.PlayerPos-GAMEMODE.SolarSystems[ID].Pos)/Scale+v.FloatPos/Scale)
				DrawOutlinedRect( sPos.x - 3, sPos.y - 3, 6, 6, color )
				DrawText( v:Nick(), "DVTextSmall", sPos.x + 5, sPos.y + 14 * counts[ k ], color )

				if v.WarpDest then
					local warpSPos = DV2P.Map.ToScreen((v.WarpDest-GAMEMODE.SolarSystems[ID].Pos)/Scale+v.WarpDestDetail/Scale)

					DrawLine( sPos.x, sPos.y, warpSPos.x, warpSPos.y, color )
					DrawOutlinedRect( warpSPos.x - 3, warpSPos.y - 3, 6, 6, color )
				end

				counts[ k ] = counts[ k ] + 1
			end
		end
	end, function( err ) print( err ) end )
end )