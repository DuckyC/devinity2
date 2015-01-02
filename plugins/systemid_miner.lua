PLUGIN.Name = "System ID Miner"
PLUGIN.Description = "Finds the quickest path to go through list of IDs and automatically mines ore."

function PLUGIN:PanelSetup( container )
	self:SetPanelSize( 200, 110 )

	local btnStart = vgui.Create( "DVButton", container )
	btnStart:SetText( "Start" )
	btnStart.DoClick = function( pnl, w, h )
		self:Start( {
			500, 499,
			498, 497,
			496, 495,
			494, 493,
			277, 1
		} )
	end

	self.derma.btnStart = btnStart

	local btnFinish = vgui.Create( "DVButton", container )
	btnFinish:SetText( "Finish" )
	btnFinish.DoClick = function( pnl, w, h )
		self:Finish()
	end

	self.derma.btnFinish = btnFinish
end

function PLUGIN:PanelPerformLayout( container, w, h )
	self.derma.btnStart:SetPos( 10, 10 )
	self.derma.btnStart:SetSize( w - 20, 40 )

	self.derma.btnFinish:SetPos( 10, 60 )
	self.derma.btnFinish:SetSize( w - 20, 40 )
end

function factorial( n )
    f = 1
    
    while n > 0 do
        f = f * n;
        n = n - 1;
    end
    
    return f;
end

local lp = LocalPlayer()
function PLUGIN:CalculatePath( ids )
	local systems = {}
	local count = 0
	for k, v in pairs( ids ) do
		systems[ k ] = GAMEMODE.SolarSystems[ v ]
		count = count + 1
	end

	local shipData = lp:GetShipData()
	local plyPos = lp.PlayerPos
	if not shipData then return end
	
	local maxWarpDist = shipData.MaxWarpDistance

	local fullpath = {}
	local totalDist = 0

	local origin = plyPos
	for i = 0, count do
		local closest = nil
		local closestKey = nil
		local closestDist = 0

		for k, v in pairs( systems ) do
			local path, dist = DV2P.pathfinder:CalculatePath( v.Pos, origin, maxWarpDist )
			if not path then continue end

			if not closest or dist < closestDist then
				closest = path
				closestKey = k
				closestDist = dist
			end 
		end

		if closest then
			fullpath[ #fullpath + 1 ] = closest
			origin = systems[ closestKey ].Pos

			print( systems[ closestKey ].Name )
			totalDist = totalDist + closestDist

			table.remove( systems, closestKey )
		else
			break
		end
	end

	return fullpath, totalDist
end

function PLUGIN:Start( ids )
	self.oreSlotCount = math.floor( MAIN_MAXIMUM_SLOTS / #ids )

	local newIDs = {}
	for k, v in pairs( ids ) do
		local count = self:CheckInventory( v )
		if count < self.oreSlotCount then
			newIDs[ #newIDs + 1 ] = v
		end
	end

	self.fullpath = self:CalculatePath( newIDs )

	if not self.fullpath then return end

	self.currentPathID = 1
	self.state = "warpPath"
	self.inProgress = true
end

function PLUGIN:Finish()
	self.fullpath = nil
	self.currentPathID = nil
	self.state = nil
	self.inProgress = false
end

function PLUGIN:WarpPathID( id, callback )
	local path = self.fullpath[ id ]
	if not path then return end

	if #path == 0 then
		callback()
	end
	DV2P.pathfinder:StartWarpPath( path, callback )
end

function PLUGIN:NextPath()
	self.currentPathID = self.currentPathID + 1
	if self.currentPathID > #self.fullpath then
		self:Finish()
	end
	self.state = "warpPath"
end

function PLUGIN:Mine()
	local Asteroid = DV2P.GetNearest("Asteroid")
	if not Asteroid then return false end

	lp:RequestTarget( Asteroid.ID, 1, false, false)
	DV2P.FireAll("Mining Laser")
end

function PLUGIN:StopMine()
	DV2P.FireAll( "Mining Laser", false )
end

function PLUGIN:CheckForPirates()
	local Pirate = DV2P.GetNearestNPC(5000)
	if not Pirate then DV2P.FireAll("Pulse Cannon", false) return end
	lp:RequestTarget(Pirate:GetIndex(),2,false,true)
	DV2P.FireAll("Pulse Cannon")
end

function PLUGIN:CheckInventory( id )
	local count = 0
	local inv = lp:GetInventory()
	for k, v in pairs( inv ) do
		if not v.Data then continue end

		if v.Data.ID == id then
			if count < self.oreSlotCount && v.Quantity > 0 then
				count = count + 1
			else
				lp:RequestDeleteItem( k, v.Quantity )
			end
		end
	end

	return count
end


PLUGIN.nextThink = 0
function PLUGIN:Think()
	if CurTime() > self.nextThink then
		self.nextThink = CurTime() + 0.5
	else
		return
	end

	if self.inProgress then
		if self.fullpath then
			if DV2P.pathfinder:CanWarp() then
				if self.state == "warpPath" then
					self:WarpPathID( self.currentPathID, function()
						local reg, id = lp:GetRegion()
						--self.fullpath[ self.currentPathID ] = nil
						lp:AddNote( "Arrived to " .. reg )
						self.state = "inSystem"
					end )
				elseif self.state == "inSystem" then
					if not DV2P.IsAt( "AsteroidField" ) then
						DV2P.pathfinder:WarpToMapEnt( DV2P.GetNearest( "AsteroidField" ), function()
							lp:AddNote( "Arrived to asteroid field" )
						end )
					else
						local reg, id = lp:GetRegion()
						local count = self:CheckInventory( id )

						if count < self.oreSlotCount then
							self:Mine()
						elseif count == self.oreSlotCount then
							self:StopMine()
							lp:RequestTarget( 0, 1 )
							self:NextPath()
						end
						self:CheckForPirates()
					end
				end
			end
		end
	end
end

local MatTarget = surface.GetTextureID("devinity2/hud/target_white")
local plugin = PLUGIN
DV2P.OFF.AddFunction( "Post_MAP_Frame_Paint", "SystemIDMinerPaint", function( pnl, w, h )
	xpcall( function()
		//DV2P.pathfinder:PaintPanel( pnl, w, h )
		if DV2P.IsMapScreenLocal() then return end

		if plugin.inProgress then
			if plugin.fullpath then

				local prev = nil

				for k, path in pairs( plugin.fullpath ) do
					local col = Color( k * 25.5, 255 - k * 25.5, 50 )
					surface.SetDrawColor( col )

					if not path then continue end
					if #path == 0 then continue end

					local last = path[ #path ]
					local s = 8 + math.cos( CurTime() * 5 ) * 2
					DrawRect( last.SPos.x - s / 2, last.SPos.y - s / 2, s, s, col )

					for k, v in pairs( path ) do
						if not v then continue end
						local pos = v.SPos
						
						if pos and prev then
							surface.DrawLine( prev.x, prev.y, pos.x, pos.y )
						end
						
						prev = pos
					end
				end
			end
		end
	end, function( err ) print( err ) end )
end )