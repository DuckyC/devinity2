PLUGIN.Name = "System ID Miner"
PLUGIN.Description = "Finds the quickest path to go through list of IDs and automatically mines ore."

function PLUGIN:ClearIDs()
	for k, v in pairs( self.derma.ids ) do
		v:Remove()
		v._btnRemove:Remove()
	end
	self.derma.ids = {}
	local container = self.derma.container
	container:InvalidateLayout()
end

function PLUGIN:AddID( id )
	local container = self.derma.container
	local idPanel = self.derma.idPanel

	local i = #self.derma.ids + 1

	local number = vgui.Create( "DNumberWang", idPanel )
	number:SetEditable( true )
	number:SetText( id or "" )

	local btnRemove = vgui.Create( "DVButton", idPanel )
	btnRemove._id = i
	btnRemove:SetText( "-" )
	btnRemove.DoClick = function( pnl )
		self.derma.ids[ pnl._id ]:Remove()
		pnl:Remove()
		table.remove( self.derma.ids, pnl._id )

		for k, v in pairs( self.derma.ids ) do
			v._btnRemove._id = k
		end

		container:InvalidateLayout()
	end
	number._btnRemove = btnRemove
	self.derma.ids[ i ] = number

	container:InvalidateLayout()
end

function PLUGIN:PanelSetup( container )
	self:SetPanelSize( 200, 430 )

	local labelCraftID = vgui.Create( "DLabel", container )
	labelCraftID:SetText( "Crafting ID" )
	labelCraftID:SizeToContents()
	self.derma.labelCraftID = labelCraftID

	local craftID = vgui.Create( "DNumberWang", container )
	craftID:SetEditable( true )
	self.derma.craftID = craftID

	local btnCraftID = vgui.Create( "DVButton", container )
	btnCraftID:SetText( "Set" )
	btnCraftID.DoClick = function( pnl )
		local id = craftID:GetValue()

		local ids, sum = DV2P.GetPlugin( "Item Generator" ):GetOresForCraftingID( id )
		if #ids > 0 then
			self:ClearIDs()
			for k, v in pairs( ids ) do
				self:AddID( v )
			end
		end
	end
	self.derma.btnCraftID = btnCraftID


	local labelIDs = vgui.Create( "DLabel", container )
	labelIDs:SetText( "IDs" )
	labelIDs:SizeToContents()
	self.derma.labelIDs = labelIDs

	local idPanel = vgui.Create( "DScrollPanel", container )
	idPanel.Paint = function( pnl, w, h )
		DrawRect( 0, 0, w, h, MAIN_BLACKCOLOR )
		DrawOutlinedRect( 0, 0, w, h, MAIN_GUICOLOR )
	end
	DV2P.PaintVBar( idPanel.VBar )

	self.derma.idPanel = idPanel

	self.derma.ids = {}

	local btnAdd = vgui.Create( "DVButton", container )
	btnAdd:SetText( "+" )
	btnAdd.DoClick = function( pnl, w, h )
		self:AddID()
	end
	self.derma.btnAdd = btnAdd

	local btnClear = vgui.Create( "DVButton", container )
	btnClear:SetText( "Clear" )
	btnClear.DoClick = function( pnl, w, h )
		self:ClearIDs()
	end
	self.derma.btnClear = btnClear

	local checkboxStraight = vgui.Create( "DCheckBoxLabel", container )
	checkboxStraight:SetText( "Straight" )
	self.derma.checkboxStraight = checkboxStraight

	local btnStart = vgui.Create( "DVButton", container )
	btnStart:SetText( "Start" )
	btnStart.DoClick = function( pnl, w, h )
		local ids = {}
		for k, v in pairs( self.derma.ids ) do
			ids[ k ] = v:GetValue()
		end

		local straight = self.derma.checkboxStraight:GetChecked()
		self:Start( ids, straight )
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
	self.derma.labelCraftID:SetPos( 10, 10 )

	self.derma.craftID:SetPos( 20, 30 - 4 )
	self.derma.craftID:SetSize( w - 40 - 20 - 10 - 4, 20 )

	self.derma.btnCraftID:SetPos( w - 40 - 10, 30 - 4 )
	self.derma.btnCraftID:SetSize( 40, 20 )


	self.derma.labelIDs:SetPos( 10, 10 + 20 + 20 + 4 )

	self.derma.idPanel:SetPos( 10, 10 + 20 + 20 + 20 )
	self.derma.idPanel:SetSize( w - 20, h - 40 - 20 - 20 - 20 - 30 - 4 - 10 - 4 - 20 - 4 - 20 - 4 )

	local iW, iH = self.derma.idPanel:GetSize()

	local y = 0
	for k, v in pairs( self.derma.ids ) do
		v:SetPos( 4, 4 + ( 20 + 4 ) * y  )
		v:SetSize( iW - 8 - 30 - 4, 20 )

		v._btnRemove:SetPos( iW - 30 - 4, 4 + ( 20 + 4 ) * y )
		v._btnRemove:SetSize( 30, 20 )

		y = y + 1
	end

	self.derma.btnAdd:SetPos( w - 30 - 10, h - 40 - 30 - 4 - 20 - 4 - 20 - 4 )
	self.derma.btnAdd:SetSize( 30, 20 )

	self.derma.btnClear:SetPos( 10, h - 40 - 30 - 4 - 20 - 4 - 20 - 4 )
	self.derma.btnClear:SetSize( 50, 20 )

	self.derma.checkboxStraight:SetPos( 20, h - 40 - 30 - 4 - 16 - 4 )

	self.derma.btnStart:SetPos( 10, h - 40 - 30 - 4 )
	self.derma.btnStart:SetSize( w - 20, 30 )

	self.derma.btnFinish:SetPos( 10, h - 40 )
	self.derma.btnFinish:SetSize( w - 20, 30 )
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
function PLUGIN:CalculatePath( ids, straight )
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
			local path, dist = DV2P.pathfinder:CalculatePath( v.Pos, origin, maxWarpDist, straight )
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

function PLUGIN:Start( ids, straight )
	self.oreSlotCount = math.floor( MAIN_MAXIMUM_SLOTS / #ids )

	local newIDs = {}
	for k, v in pairs( ids ) do
		local count = self:CheckInventory( v )
		if count < self.oreSlotCount then
			newIDs[ #newIDs + 1 ] = v
		end
	end

	self.fullpath = self:CalculatePath( newIDs, straight )

	if not self.fullpath then return end

	self.currentPathID = 1
	self.state = "warpPath"
	self.inProgress = true
	self.straight = true
end

function PLUGIN:Finish()
	self.fullpath = nil
	self.currentPathID = nil
	self.state = nil
	self.inProgress = false
	self.straight = nil
	DV2P.pathfinder:FinishPath()
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
	local Asteroid = DV2P.GetNearest( "Asteroid" )
	if not Asteroid then return false end

	lp:RequestTarget( Asteroid.ID, 1, false, false )
	DV2P.FireAll( "Mining Laser", true, 1 )
end

function PLUGIN:StopMine()
	DV2P.FireAll( "Mining Laser", false )
end

function PLUGIN:CheckForPirates()
	local Pirate = DV2P.GetNearestNPC( 5000 )
	if not Pirate then DV2P.FireAll( "Pulse Cannon", false ) return end

	lp:RequestTarget( Pirate:GetIndex(), 2, false, true )
	DV2P.FireAll( "Pulse Cannon", true, 2 )
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
					local reg, id = lp:GetRegion()
					local count = self:CheckInventory( id )

					if count == self.oreSlotCount then
						self:StopMine()
						lp:RequestTarget( 0, 1 )
						self:NextPath()
					else
						if not DV2P.IsAt( "AsteroidField" ) then
							DV2P.pathfinder:WarpToMapEnt( DV2P.GetNearest( "AsteroidField" ), function()
								lp:AddNote( "Arrived to asteroid field" )
							end )
						else

							if count < self.oreSlotCount then
								self:Mine()
							end
							self:CheckForPirates()
						end
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
		if DV2P.IsMapScreenLocal() then return end

		if plugin.inProgress then
			if plugin.fullpath then

				local prev = nil
				local scale = MAIN_MAP_SIZE/2500

				for k, path in pairs( plugin.fullpath ) do
					local col = Color( k * 25.5, 255 - k * 25.5, 50 )
					surface.SetDrawColor( col )

					if not path then continue end
					if #path == 0 then continue end

					local last = path[ #path ]
					if not last then continue end

					local s = 8 + math.cos( CurTime() * 5 ) * 2
					local sPos = nil
					if type( last ) == "Vector" then
						sPos = DV2P.Map.ToScreen( last / scale )
					else
						sPos = last.SPos
					end
					DrawRect( sPos.x - s / 2, sPos.y - s / 2, s, s, col )

					for k, v in pairs( path ) do
						if not v then continue end
						local pos = nil
						if type( v ) == "Vector" then
							pos = DV2P.Map.ToScreen( v / scale )
						else
							pos = v.SPos
						end
						
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