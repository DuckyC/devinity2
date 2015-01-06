local lp = LocalPlayer()

PLUGIN.Name = "Pinpoint Warping"
PLUGIN.Description = "Works exactly like normal warping, except it's pin point accurate."

concommand.Add( "dv2_pinpoint_warp_id", function( ply, cmd, args )
	local id = tonumber( args[ 1 ] )
	if id == nil then return end

	if id == 0 then
		local reg, id = lp:GetRegion()
		local sys = GAMEMODE.SolarSystems[ id ]
		if not sys then return end

		lp:SetPinpointWarpDestination( sys.Pos, Vector() )
	else
		local ent = GAMEMODE.MapEnts[ id ]
		if not ent then return end

		lp:SetPinpointWarpDestination( ent.Pos, ent.FloatPos )
	end
end )

function PLUGIN:SetWarpDestination( pos, fpos )
	local Data = lp:GetShipData()

	local Dir = (pos-lp.PlayerPos)+(fpos-lp.FloatPos)
	local NormDir = Dir:GetNormal()
	local Dist = Dir:Length() - 999
	local PDist = nil
	local ADist = nil
	local SDist = 0

	local speed = 0
	local iterations = 10000
	while (Dist > 2000 or (Dist <= 2000 and speed > 0) ) and iterations >= 0 do
		if Dist > 2000 then
			speed = math.Clamp(speed*1.01+1,0,math.min(Dist/64,MAIN_PLAYER_WARPSPEED))
		else
			if ADist == nil then ADist = Dist end
			speed = math.floor((speed+(0-speed)/32)*1000)/1000
			SDist = SDist + SDist

			if speed <= 0 and PDist == nil then
				PDist = Dist
			end
		end

		speed = math.max( speed, 0 )

		Dist = Dist - (speed * (Data.Speed / 100))

		iterations = iterations - 1
	end

	PDist = PDist or 0
	ADist = ADist or 0
	/*
	print( "Predicted Arrive dist: ", ADist, ADist + 999 )
	print( "Predicted slowdown dist: ", SDist )
	print( "Predicted dist: ", PDist, PDist + 999 )*/
	local p, fp = CleanupPos( pos, fpos + NormDir * ( PDist + 999 ) )

	lp:SetWarpDestination( p, fp )
end

local meta = FindMetaTable("Player")
function meta:SetPinpointWarpDestination( pos, fpos )
	DV2P.GetPlugin( "Pinpoint Warping" ):SetWarpDestination( pos, fpos )
end




/*local prev = -1
local prevOther = -1
local travelled = 0
local travelledOther = 0
local peak = 0
local temp = nil*/
hook.Add( "Think", "Warp_Think", function()
	if not lp then return end

	/*local Data = lp:GetShipData()

	if lp.WarpDest then
		local Dir = (lp.WarpDest-lp.PlayerPos)+(lp.WarpDestDetail-lp.FloatPos)
		local Dis = Dir:Length()-999

		if lp.SimulateSpeed > peak then peak = lp.SimulateSpeed end

		if prev ~= lp.SimulateSpeed then
			travelled = travelled + lp.SimulateSpeed
			--print( math.Clamp( lp.SimulateSpeed, 0, math.min( Dis / 64, MAIN_PLAYER_WARPSPEED ) ), Dis / 64 )
		end

		travelledOther = 0
		prev = lp.SimulateSpeed
		prevOther = lp.SimulateSpeed
		--print( lp.SimulateSpeed, lp.SimulateSpeed*(Data.Speed/100) )
		temp = false
	else
		if temp == false then
			print( "ARRIVE DEST: " .. DV2P.GetDistance( ent, lp ))
			temp = true
		end
		if travelled ~= 0 then
			travelled = 0
		end
		local class, k = DV2P.GetLocalSystemPos( lp )
		local ent = GAMEMODE.MapEnts[ k ]

		if prevOther ~= lp.SimulateSpeed then
			travelledOther = travelledOther + lp.SimulateSpeed
		end

		if lp.SimulateSpeed == 0 and travelledOther ~= 0 then
			print( travelledOther, DV2P.GetDistance( ent, lp ) )
			travelledOther = 0
		end

		prevOther = lp.SimulateSpeed

		--print( MAIN_SOLARSYSTEM_RADIUS - DV2P.GetDistance( ent, lp ), peak )
	end*/

	--print( lp.Speed, lp.SimulateSpeed)

	/*if (lp:GetRegion() == "Space") then
		travelled = 0
	else
		travelled = travelled + lp.SimulateSpeed*(Data.Speed/100)
		-- print( travelled )
	end*/

	--print( lp.PlayerTargDir:Dot(DestDir) )
end )

-- 23499215.98144	902.157
-- 103395333.55678	966.35


DV2P.OFF.AddFunction( "DrawMapEnts_MenuAddOption", "ExtraWarpOptions", function( menu, v, Pos, Dis, SPos )
	if (Dis > 20000) then menu:AddOption( "Pinpoint Warp to", function() lp:SetPinpointWarpDestination(v.Pos,v.FloatPos) end ):SetColor(MAIN_TEXTCOLOR) end
	
end)
