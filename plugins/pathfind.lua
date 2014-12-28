local Zero = Vector( 0, 0, 0 )

// Some random namespace
xxxAddon = xxxAddon or {
	initialized = false,
	mapDerma = {},
	overrides = {},
}

xxxAddon.pathfinder = xxxAddon.pathfinder or {}

xxxAddon.overrides.OpenMap = xxxAddon.overrides.OpenMap or OpenMap
xxxAddon.overrides.CloseMap = xxxAddon.overrides.CloseMap or CloseMap

function xxxAddon.pathfinder:GetSystem( name )
	for k, v in pairs( GAMEMODE.SolarSystems ) do
		if v.Name:lower() == name:lower() then
			return v
		end
	end
end

function xxxAddon.pathfinder:GetOptimalSystem( dest, origin, range )
	if not range then return end
	
	local closest = nil
	local closestDist = 0
	
	for k, v in pairs( GAMEMODE.SolarSystems ) do
		local orig_dist = v.Pos:Distance( origin )
		local dest_dist = v.Pos:Distance( dest )
		if orig_dist <= range then
			if closest == nil or dest_dist < closestDist then
				closest = v
				closestDist = dest_dist
			end
		end
	end
	
	return closest
end

function xxxAddon.pathfinder:CalculatePath( dest, origin, range )
	local dest_dist = dest:Distance( origin )
	
	local path = {}
	
	local maxIterations = #GAMEMODE.SolarSystems
	local iterations = 0
	
	local foundDest = false
	local curr = origin
	while iterations <= maxIterations do
		iterations = iterations + 1
		
		local next = self:GetOptimalSystem( dest, curr, range )
		
		if not next then return end
		
		path[ #path + 1 ] = next
		curr = next.Pos
		
		if curr == dest then
			foundDest = true
			break
		end
		
	end
	
	if not foundDest then return end
	
	return path
end

function xxxAddon.pathfinder:StartWarpTo( system )
	local lp = LocalPlayer()
	
	local sysData = self:GetSystem( system )
	
	if sysData == nil then
		LocalPlayer():AddNote( "Could not find that system" )
		return
	end
	
	local shipData = lp:GetShipData()
	local plyPos = lp.PlayerPos
	local maxWarpDist = shipData.MaxWarpDistance
	
	local sysPos = sysData.Pos
	
	if sysPos:Distance( plyPos ) <= maxWarpDist then
		LocalPlayer():SetWarpDestination( sysData.Pos, Zero )
	else
		self.inProgress = true
		self.dest = sysData
		self.path = nil
	end
end

function xxxAddon.pathfinder:FinishWarp()
	self.inProgress = false
	self.dest = nil
	self.path = nil
end

function xxxAddon.pathfinder:Think()
	if self.inProgress then
		local lp = LocalPlayer()	
		local plyPos = lp.PlayerPos
		local shipData = lp:GetShipData()
		local maxWarpDist = shipData.MaxWarpDistance
		
		if not lp.WarpDest then
			if not self.path then
				self.path = self:CalculatePath( self.dest.Pos, plyPos, maxWarpDist )
				
				self.fullpath = {}
				for k, v in pairs( self.path ) do
					self.fullpath[ k ] = v
				end
				
				local name, id = lp:GetRegion()
				self.start = GAMEMODE.SolarSystems[ id ]
			end
			
			if not self.path then
				self:FinishWarp()
			end
			
			if #self.path > 0 then
				local nextNode = table.remove( self.path, 1 )
				
				print( "NEXT TARGET: " .. nextNode.Name )
				LocalPlayer():SetWarpDestination( nextNode.Pos, Zero )
			else
				self:FinishWarp()
			end
		end
	end
end

function xxxAddon.pathfinder:PaintPanel( pnl, w, h )
	if not LocalMap then
		if self.inProgress then
			local path = self.fullpath
			
			if path then
				local scale = MAIN_SOLARSYSTEM_RADIUS / 100
				
				local lp = LocalPlayer()
				local plyPos = lp.PlayerPos
				
				local prev = nil
				if self.start then
					prev = self.start.SPos	
				end
				for k, v in pairs( path ) do
					if not v then continue end
					local pos = v.SPos
					
					if pos and prev then
						surface.SetDrawColor( 255, 150, 0 )
						surface.DrawLine( prev.x, prev.y, pos.x, pos.y )
					end
					
					prev = pos
				end
				
			end
		end
	end
end

hook.Add( "Think", "xxxAddon_Pathfinder_Think", function()
	if xxxAddon.pathfinder then
		xxxAddon.pathfinder:Think()
	end
end )


function OpenMap()
	xxxAddon.overrides.OpenMap()
	xxxAddon.overrides.MAP_Frame_Paint = xxxAddon.overrides.MAP_Frame_Paint or MAP_Frame.Paint

	function MAP_Frame:Paint( w, h )
		xxxAddon.overrides.MAP_Frame_Paint( self, w, h )
		
		xxxAddon.pathfinder:PaintPanel( self, w, h )
	end
	
	if xxxAddon.initialized then
		for k, v in pairs( xxxAddon.mapDerma ) do
			v:Remove()
		end
		
		xxxAddon.initialized = false	
	end

	local map_w, map_h = MAP_Frame:GetSize()
	
	local window = vgui.Create( "DPanel", MAP_Frame )
	
	xxxAddon.mapDerma.window = window
	
	local systemLabel = vgui.Create( "DLabel", window )
	systemLabel:SetText( "System Name" )
	systemLabel:SizeToContents()
	xxxAddon.mapDerma.systemLabel = systemLabel

	local systemInput = vgui.Create( "DTextEntry", window )
	xxxAddon.mapDerma.systemInput = systemInput
	
	local warpBtn = vgui.Create( "MBButton", window )
	warpBtn:SetText( "Warp" )
	xxxAddon.mapDerma.warpBtn = warpBtn
	
	local cancelBtn = vgui.Create( "MBButton", window )
	cancelBtn:SetText( "Cancel" )
	xxxAddon.mapDerma.cancelBtn = cancelBtn
	
	function warpBtn:DoClick()
		xxxAddon.pathfinder:StartWarpTo( systemInput:GetText() )
	end
	
	function cancelBtn:DoClick()
		xxxAddon.pathfinder:FinishWarp()
	end
	
	function window:PerformLayout( w, h )
		
		window:SetSize( 300, 140 )
		window:SetPos( map_w - w - 10, map_h - h - 10 )

		systemLabel:SetPos( 14, 20 )

		systemInput:SetSize( w - 20, 20 )
		systemInput:SetPos( 10, 40 )
		
		warpBtn:SetSize( w - 40, 25 )
		warpBtn:SetPos( 20, 70 )
		
		cancelBtn:SetSize( w - 40, 25 )
		cancelBtn:SetPos( 20, 100 )
	end
	
	function window:Paint( w, h )
		DrawDV2Box( 0, 0, w - 1, h - 1, w / 3, MAIN_BLACKCOLOR, MAIN_GUICOLOR, 8 )
	end
	
	xxxAddon.initialized = true
end