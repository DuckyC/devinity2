local Zero = Vector( 0, 0, 0 )

-- Some random namespace
xxxAddon = xxxAddon or {
	initialized = false,
	mapDerma = {},
	overrides = {},
}

xxxAddon.pathfinder = xxxAddon.pathfinder or {
	nextWarpTime = 0
}

xxxAddon.overrides.OpenMap = xxxAddon.overrides.OpenMap or OpenMap
xxxAddon.overrides.input_KeyPress = xxxAddon.overrides.input_KeyPress or input.KeyPress

local plyMeta = FindMetaTable( "Player" )
xxxAddon.overrides.plyMeta_RequestDock = xxxAddon.overrides.plyMeta_RequestDock or plyMeta.RequestDock

function plyMeta:RequestDock( id )
	if IsValid( MAP_Frame ) and MAP_Frame:IsVisible() then
	else
		return xxxAddon.overrides.plyMeta_RequestDock( self, id )
	end
end

function input.KeyPress( key, stuff )
	if stuff == "CloseMap" then
		if IsValid( MAP_Frame ) and MAP_Frame:IsVisible() then
			if IsValid( xxxAddon.mapDerma.systemInput ) then
				if not xxxAddon.mapDerma.systemInput:HasFocus() then
					return xxxAddon.overrides.input_KeyPress( key, stuff )
				end
			else
				return xxxAddon.overrides.input_KeyPress( key, stuff )
			end
		else
			return xxxAddon.overrides.input_KeyPress( key, stuff )
		end
	elseif stuff == "OpenMap" then
		if not IsValid( MAP_Frame ) or ( IsValid( MAP_Frame ) and not MAP_Frame:IsVisible() ) then
			return xxxAddon.overrides.input_KeyPress( key, stuff )
		end
	else
		return xxxAddon.overrides.input_KeyPress( key, stuff )
	end
end

function xxxAddon.pathfinder:GetSystem( name )
	for k, v in pairs( GAMEMODE.SolarSystems ) do
		if v.Name:lower() == name:lower() then
			return v
		end
	end
end

function xxxAddon.pathfinder:GetOptimalSystem( dest, origin, range )
	if not range then return end
	if not dest or not origin then return end
	
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
		
		if curr:Distance( dest ) <= MAIN_SOLARSYSTEM_RADIUS then
			foundDest = true
			break
		end
		
		local next = self:GetOptimalSystem( dest, curr, range )
		
		if not next then return end
		
		path[ #path + 1 ] = next
		curr = next.Pos
	end
	
	if not foundDest then return end
	
	return path
end

function xxxAddon.pathfinder:GetMapEntClosest( pos, floatPos, class )
	local closest = nil
	local closestDist = 0
	
	for k, v in pairs( GAMEMODE.MapEnts ) do
		if v.Class:lower() == class:lower() then
			local dist = ( ( v.Pos - pos ) + ( v.FloatPos - floatPos ) ):Length()
			
			if not closest or dist < closestDist then
				closest = v
				closestDist = dist
			end
		end
	end

	if closest then
		-- self:WarpToMapEnt( closest )
		return closest
	end
end

function xxxAddon.pathfinder:StartWarpToID( id, callback )
	pcall( function()
		local sysData = GAMEMODE.SolarSystems[ id ]
		
		if not sysData then
			LocalPlayer():AddNote( "Could not find that system." )
			return
		end
		
		self:StartWarpTo( sysData, callback )
	end )
end

function xxxAddon.pathfinder:StartWarpToName( name, callback )
	pcall( function()
		local sysData = self:GetSystem( name )
		
		if not sysData then
			LocalPlayer():AddNote( "Could not find that system." )
			return
		end
		
		self:StartWarpTo( sysData, callback )
	end )
end

function xxxAddon.pathfinder:StartWarpTo( sysData, callback )
	if not sysData then return end
	
	local success, err = pcall( function()
		local lp = LocalPlayer()
		
		if lp.Docked then 
			LocalPlayer():AddNote( "Can't pathfind while docked." )
			return
		end
		
		if lp:IsPlayerDead() then 
			LocalPlayer():AddNote( "Can't pathfind when dead." )
			return
		end
		
		if not sysData then
			return
		end
		
		local shipData = lp:GetShipData()
		local plyPos = lp.PlayerPos
		if not shipData then return end
		
		local maxWarpDist = shipData.MaxWarpDistance
		
		self.inProgress = true
		self.dest = sysData
		self.path = nil
		self.fullpath = nil
		self.callback = callback
	end )
	
	if not success then print( err ) end
end

function xxxAddon.pathfinder:FinishPath()
	self.inProgress = false
	self.dest = nil
	self.path = nil
	self.fullpath = nil
end

function xxxAddon.pathfinder:FinishWarp()
	self.nextWarpPos = nil
	self.nextWarpFloat = nil	
end

function xxxAddon.pathfinder:SetNextWarpDest( pos, floatPos, callback )
	self.nextWarpPos = pos
	self.nextWarpFloat = floatPos or Zero
	self.nextWarpCallback = callback
end

function xxxAddon.pathfinder:WarpToMapEnt( ent, callback )
	if ent then
		self:SetNextWarpDest( ent.Pos, ent.FloatPos, callback )
	end
end

function xxxAddon.pathfinder:CanWarpNormal()
	local lp = LocalPlayer()
	return not lp.WarpDest and
		not lp.Docket and
		not lp:IsPlayerDead() and
		not ( lp.LastDisrupted and lp.LastDisrupted > CurTime()-10 )
end

function xxxAddon.pathfinder:CanWarp()
	return self:CanWarpNormal() and
		self.nextWarpTime <= 0
end

function xxxAddon.pathfinder:Think()
	local lp = LocalPlayer()
	local plyPos = lp.PlayerPos

	if self:CanWarpNormal() then
		if not self.nextWarpPos and self.nextWarpCallback then
			self.nextWarpCallback()
			self.nextWarpCallback = nil
		end
		
		if self.nextWarpTime > 0 then
			self.nextWarpTime = self.nextWarpTime - FrameTime()	
		end
	else
		self.nextWarpTime = 5
	end
	
	if self.inProgress then
		local shipData = lp:GetShipData()
		local maxWarpDist = shipData.MaxWarpDistance
		
		if self:CanWarpNormal() then
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
				self:FinishPath()
				return
			end
			
			if not self.nextNodeSet then
				if #self.path > 0 then
					self.nextNodeSet = true
					local nextNode = table.remove( self.path, 1 )
					
					lp:AddNote( "Next System: " .. nextNode.Name )
					
					self:SetNextWarpDest( nextNode.Pos, nil, function()
						lp:AddNote( "Arrived to system" );
						self.nextNodeSet = false
					end )
				else
					self:FinishPath()
						
					if self.callback then
						self.callback( plyPos, lp.FloatPos )
					end
				end
			end
		end
	end
	
	if self:CanWarp() then
		if self.nextWarpPos then
			lp:SetWarpDestination( self.nextWarpPos, self.nextWarpFloat )
			self:FinishWarp()
		end
	end
end

function xxxAddon.pathfinder:PaintPanel( pnl, w, h )
	local reg, id = LocalPlayer():GetRegion()
	
	local paintPath = false
	
	if IsValid( MAP_Frame ) then
		local children = MAP_Frame:GetChildren()
		
		for k, v in pairs( children ) do
			if IsValid( v ) then
				if v.Text == "Enter Local Map" then
					paintPath = true
					break
				end
			end
		end
	end
	
	if paintPath then
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
		local success, err = pcall( function()
			xxxAddon.pathfinder:Think()
		end )
		
		if not success then print( err ) end
	end
end )


function OpenMap()
	xxxAddon.overrides.OpenMap()
	pcall( function()
		xxxAddon.overrides.MAP_Frame_Paint = xxxAddon.overrides.MAP_Frame_Paint or MAP_Frame.Paint
	
		function MAP_Frame:Paint( w, h )
			xxxAddon.overrides.MAP_Frame_Paint( self, w, h )
			
			pcall( function()
				xxxAddon.pathfinder:PaintPanel( self, w, h )
			end )
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
		systemLabel:SetFont( "Trebuchet18" )
		systemLabel:SetText( "System Name" )
		systemLabel:SizeToContents()
		xxxAddon.mapDerma.systemLabel = systemLabel
	
		local systemInput = vgui.Create( "DTextEntry", window )
		xxxAddon.mapDerma.systemInput = systemInput
		
		local localDropdown = vgui.Create( "DComboBox", window )
		localDropdown:AddChoice( "AsteroidField" )
		localDropdown:AddChoice( "Planet" )
		localDropdown:AddChoice( "Station" )
		localDropdown:AddChoice( "GasCloud" )
		localDropdown:AddChoice( "BlackHole" )
		xxxAddon.mapDerma.localDropdown = localDropdown
		
		local warpBtn = vgui.Create( "MBButton", window )
		warpBtn:SetText( "Warp" )
		xxxAddon.mapDerma.warpBtn = warpBtn
		
		local cancelBtn = vgui.Create( "MBButton", window )
		cancelBtn:SetText( "Cancel" )
		xxxAddon.mapDerma.cancelBtn = cancelBtn
		
		
		function systemInput:GetAutoComplete( text )
			if text == "" then return end
			
			local tbl = {}
			for k, v in pairs( GAMEMODE.SolarSystems ) do
				if not v then continue end
				
				if string.sub( v.Name:lower(), 1, string.len( text ) ) == text:lower() then
					tbl[ #tbl + 1 ] = v.Name	
				end
			end
		
			return tbl
		end
		
		function systemInput:OpenAutoComplete( tab )
			if ( !tab ) then return end
			if ( #tab == 0 ) then return end
			
			if IsValid( self.Menu ) then
				self.Menu:Remove()
				self.Menu = nil
			end
			
			self.Menu = DermaMenu()
			
				for k, v in pairs( tab ) do
					
					self.Menu:AddOption( v, function()
						self:SetText( v )
						self:SetCaretPos( v:len() )
						self:RequestFocus()
					end )		
		
				end
			
			local x, y = self:LocalToScreen( 0, self:GetTall() )
			self.Menu:SetMinimumWidth( self:GetWide() )
			self.Menu:Open( x, y, false, self )
			self.Menu:SetPos( x, y )
			self.Menu:SetMaxHeight( (ScrH() - y) - 10 )
		end
		
		
		
		function warpBtn:DoClick()
			local num = tonumber( systemInput:GetText() )
			if num then
				xxxAddon.pathfinder:StartWarpToID( num )
			else
				local class = localDropdown:GetText()
				
				xxxAddon.pathfinder:StartWarpToName( systemInput:GetText(), function( plyPos, floatPos )
					local ent = xxxAddon.pathfinder:GetMapEntClosest( plyPos, floatPos, class )
					
					if ent then
						xxxAddon.pathfinder:WarpToMapEnt( ent, function()
							LocalPlayer():AddNote( "Arrived to something" );
							surface.PlaySound( "ambient/levels/citadel/portal_open1_adpcm.wav" )
						end )
					end
				end )
				-- xxxAddon.pathfinder:WarpToMapEntNearest( LocalPlayer().PlayerPos, LocalPlayer().FloatPos, localDropdown:GetText() )
			end
			
			surface.PlaySound( "buttons/button24.wav" )
		end
		
		function cancelBtn:DoClick()
			xxxAddon.pathfinder:FinishPath()
			xxxAddon.pathfinder:FinishWarp()
			surface.PlaySound( "buttons/button24.wav" )
		end
		
		function window:PerformLayout( w, h )
			
			window:SetSize( 300, 170 )
			window:SetPos( map_w - w - 10, map_h - h - 10 )
	
			systemLabel:SetPos( 14, 20 )
	
			systemInput:SetSize( w - 20, 20 )
			systemInput:SetPos( 10, 40 )
			
			localDropdown:SetSize( w - 20, 20 )
			localDropdown:SetPos( 10, 65 )
			
			warpBtn:SetSize( w - 40, 25 )
			warpBtn:SetPos( 20, 100 )
			
			cancelBtn:SetSize( w - 40, 25 )
			cancelBtn:SetPos( 20, 130 )
		end
		
		function window:Paint( w, h )
			DrawDV2Box( 0, 0, w - 1, h - 1, w / 3, MAIN_BLACKCOLOR, MAIN_GUICOLOR, 8 )
		end
		
		xxxAddon.initialized = true
	end )
end