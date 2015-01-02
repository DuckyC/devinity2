local Zero = Vector( 0, 0, 0 )
local lp = LocalPlayer()
local MatTarget = surface.GetTextureID("devinity2/hud/target_white")

DV2P.pathfinder = DV2P.pathfinder or {
	vguiInitialized = false,
	mapDerma = {},
	overrides = {},
	nextWarpTime = 0,
	warpDelay = 2
}

DV2P.pathfinder.overrides.input_KeyPress = DV2P.pathfinder.overrides.input_KeyPress or input.KeyPress

local plyMeta = FindMetaTable( "Player" )
DV2P.pathfinder.overrides.plyMeta_RequestDock = DV2P.pathfinder.overrides.plyMeta_RequestDock or plyMeta.RequestDock

function plyMeta:RequestDock( id )
	if IsValid( MAP_Frame ) and MAP_Frame:IsVisible() then
	else
		return DV2P.pathfinder.overrides.plyMeta_RequestDock( self, id )
	end
end

function input.KeyPress( key, stuff )
	if stuff == "CloseMap" then
		if IsValid( MAP_Frame ) and MAP_Frame:IsVisible() then
			if IsValid( DV2P.pathfinder.mapDerma.systemInput ) then
				if not DV2P.pathfinder.mapDerma.systemInput:HasFocus() then
					return DV2P.pathfinder.overrides.input_KeyPress( key, stuff )
				end
			else
				return DV2P.pathfinder.overrides.input_KeyPress( key, stuff )
			end
		else
			return DV2P.pathfinder.overrides.input_KeyPress( key, stuff )
		end
	elseif stuff == "OpenMap" then
		if not IsValid( MAP_Frame ) or ( IsValid( MAP_Frame ) and not MAP_Frame:IsVisible() ) then
			return DV2P.pathfinder.overrides.input_KeyPress( key, stuff )
		end
	else
		return DV2P.pathfinder.overrides.input_KeyPress( key, stuff )
	end
end

function DV2P.pathfinder:GetOptimalSystem( dest, origin, range )
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

function DV2P.pathfinder:CalculatePath( dest, origin, range, straight )
	local dest_dist = dest:Distance( origin )
	if dest_dist <= MAIN_SOLARSYSTEM_RADIUS then return {} end
	
	local path = {}
	local foundDest = false
	
	if straight then
		local numJumps = math.ceil( dest_dist / range )

		local prev = origin
		for i = 1, numJumps do
			local dir = ( dest - prev ):GetNormalized()
			local pos = nil

			if prev:Distance( dest ) <= range then
				pos = dest
				foundDest = true
			else
				pos = prev + dir * ( range * 0.99 )
			end

			path[ #path + 1 ] = pos
			
			if foundDest then break end

			prev = pos
		end
	else
		local maxIterations = #GAMEMODE.SolarSystems
		local iterations = 0
		
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
		
	end

	if not foundDest then return end

	return path
end

function DV2P.pathfinder:GetMapEntClosest( pos, floatPos, class )
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

function DV2P.pathfinder:StartWarpToID( id, straight, callback )
	xpcall( function()
		local sysData = GAMEMODE.SolarSystems[ id ]
		
		if not sysData then
			LocalPlayer():AddNote( "Could not find that system." )
			return
		end
		
		self:StartWarpTo( sysData, straight, callback )
	end, function( err ) print( err ) end )
end

function DV2P.pathfinder:StartWarpToName( name, straight, callback )
	xpcall( function()
		local sysData = DV2P.GetSystem( name )
		
		if not sysData then
			LocalPlayer():AddNote( "Could not find that system." )
			return
		end
		
		self:StartWarpTo( sysData, straight, callback )
	end, function( err ) print( err ) end )
end

function DV2P.pathfinder:StartWarpTo( sysData, straight, callback )
	if not sysData then return end
	
	xpcall( function()
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
		self.straight = straight
		self.callback = callback
	end, function( err ) print( err ) end )
end

function DV2P.pathfinder:StartWarpPath( path, callback )
	self.inProgress = true
	self.start = nil
	self.dest = nil
	self.path = path
	self.fullpath = nil
	self.callback = callback
end

function DV2P.pathfinder:AddToCurrentPath( ... )
	if not self:IsInProgress() then return end
	if not self.path then return end

	local args = { ... }

	for k, v in pairs( args ) do
		if v == nil then continue end

		self.path[ #self.path + 1 ] = v

		if not self.fullpath then return end
		self.fullpath[ #self.fullpath + 1 ] = v
	end
end

function DV2P.pathfinder:FinishPath()
	self.inProgress = false
	self.start = nil
	self.dest = nil
	self.path = nil
	self.fullpath = nil
end

function DV2P.pathfinder:FinishWarp()
	self.nextWarpPos = nil
	self.nextWarpFloat = nil
end

function DV2P.pathfinder:SetNextWarpDest( pos, floatPos, callback )
	self.nextWarpPos = pos
	self.nextWarpFloat = floatPos or Zero
	self.nextWarpCallback = callback
end

function DV2P.pathfinder:WarpToMapEnt( ent, callback )
	if ent then
		self:SetNextWarpDest( ent.Pos, ent.FloatPos, callback )
	end
end

function DV2P.pathfinder:IsInProgress()
	return self.inProgress
end

function DV2P.pathfinder:CanWarpNormal()
	return not lp.WarpDest and
		not lp.Docket and
		not lp:IsPlayerDead() and
		not ( lp.LastDisrupted and lp.LastDisrupted > CurTime()-10 )
end

function DV2P.pathfinder:CanWarp()
	return self:CanWarpNormal() and
		self.nextWarpTime <= 0
end

function DV2P.pathfinder:Think()
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
		self.nextWarpTime = self.warpDelay
	end
	
	if self.inProgress then
		local shipData = lp:GetShipData()
		local maxWarpDist = shipData.MaxWarpDistance
		
		if self:CanWarpNormal() then
			if not self.path then
				self.path = self:CalculatePath( self.dest.Pos, plyPos, maxWarpDist, self.straight )
				
				if self.path then
					local name, id = lp:GetRegion()
					print( lp:GetRegion() )
					self.start = GAMEMODE.SolarSystems[ id ]
				else
					lp:AddNote( "Could not find path to specified destination!" );
					self.inProgress = false
				end
			end
			
			if not self.path then
				self:FinishPath()
				return
			else
				if not self.fullpath then
					self.fullpath = {}
					for k, v in pairs( self.path ) do
						self.fullpath[ k ] = v
					end
				end
			end
			
			if not self.nextNodeSet then
				if #self.path > 0 then
					self.nextNodeSet = true
					local nextNode = table.remove( self.path, 1 )
					
					if type( nextNode ) == "Vector" then
						self:SetNextWarpDest( nextNode, nil, function()
							self.nextNodeSet = false
						end )
					else
						lp:AddNote( "Next System: " .. nextNode.Name )
						
						self:SetNextWarpDest( nextNode.Pos, nil, function()
							self.nextNodeSet = false
						end )
					end
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

function DV2P.pathfinder:PaintPanel( pnl, w, h )
	local reg, id = lp:GetRegion()

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
				
				local plyPos = lp.PlayerPos
				surface.SetDrawColor( 255, 150, 50 )

				if self.straight then
					local startPos = lp.SPos
					if self.dest then
						if self.start then startPos = self.start.SPos end

						local endPos = self.dest.SPos

						if startPos and endPos then
							surface.DrawLine( startPos.x, startPos.y, endPos.x, endPos.y )
						end
					end
				else
					local prev = lp.SPos
					if self.start then
						prev = self.start.SPos
					end

					for k, v in pairs( path ) do
						if not v then continue end
						local pos = v.SPos
						
						if pos and prev then
							surface.DrawLine( prev.x, prev.y, pos.x, pos.y )
						end
						
						prev = pos
					end
				end

				local warpDest = lp.WarpSPos
				if DV2P.IsWarping() and warpDest then
					DrawTexturedRectRotated( warpDest.x, warpDest.y, 8 + math.cos( CurTime() * 5 ) * 2,
						8 + math.cos( CurTime() * 5 ) * 2, Color( 255, 150, 50 ), MatTarget, CurTime() * -300 )
				end

				if self.dest then
					local pos = self.dest.SPos
					DrawTexturedRectRotated( pos.x, pos.y, 16 + math.cos( CurTime() * 5 ) * 4,
						16 + math.cos( CurTime() * 5 ) * 4, Color( 100, 255, 100 ), MatTarget, CurTime() * -300 )
				end
			end
		end
	end
end

hook.Add( "Think", "DV2P_Pathfinder_Think", function()
	if DV2P.pathfinder then
		xpcall( function()
			DV2P.pathfinder:Think()
		end, function( err ) print( err ) end )
	end
end )

DV2P.OFF.AddFunction( "Post_MAP_Frame_Paint", "MapPathfindPaint", function( pnl, w, h )
	xpcall( function()
		DV2P.pathfinder:PaintPanel( pnl, w, h )
	end, function( err ) print( err ) end )
end )

DV2P.OFF.AddFunction( "Post_OpenMap", "MapPathfindPanel", function()
	xpcall( function()
		if DV2P.pathfinder.vguiInitialized then
			for k, v in pairs( DV2P.pathfinder.mapDerma ) do
				v:Remove()
			end
			
			DV2P.pathfinder.vguiInitialized = false	
		end
	
		local map_w, map_h = MAP_Frame:GetSize()
		
		local window = vgui.Create( "DPanel", MAP_Frame )
		
		DV2P.pathfinder.mapDerma.window = window
		
		local systemLabel = vgui.Create( "DLabel", window )
		systemLabel:SetFont( "Trebuchet18" )
		systemLabel:SetText( "System Name" )
		systemLabel:SizeToContents()
		DV2P.pathfinder.mapDerma.systemLabel = systemLabel
	
		local systemInput = vgui.Create( "DTextEntry", window )
		DV2P.pathfinder.mapDerma.systemInput = systemInput
		
		local localDropdown = vgui.Create( "DComboBox", window )
		localDropdown:AddChoice( "AsteroidField" )
		localDropdown:AddChoice( "Planet" )
		localDropdown:AddChoice( "Station" )
		localDropdown:AddChoice( "GasCloud" )
		localDropdown:AddChoice( "BlackHole" )
		DV2P.pathfinder.mapDerma.localDropdown = localDropdown
		
		local straightCheckbox = vgui.Create( "DCheckBoxLabel", window )
		straightCheckbox:SetChecked( false )
		straightCheckbox:SetText( "Warp in a straight line" )
		straightCheckbox:SizeToContents()

		function ButtonPaint( pnl, w, h )
			if (pnl.Hovered) then
				DrawDV2Button( 0, 0, w, h, 8, MAIN_GREENCOLOR, MAIN_BLACKCOLOR )
			else
				DrawDV2Button( 0, 0, w, h, 8, MAIN_GUICOLOR, MAIN_BLACKCOLOR )
			end

			DrawText( pnl.Text, "DVTextSmall", w / 2, h / 2 , MAIN_TEXTCOLOR, TEXT_ALIGN_CENTER )
		end

		local warpBtn = vgui.Create( "MBButton", window )
		warpBtn:SetText( "Warp" )
		warpBtn.Paint = ButtonPaint
		DV2P.pathfinder.mapDerma.warpBtn = warpBtn
		
		local cancelBtn = vgui.Create( "MBButton", window )
		cancelBtn:SetText( "Cancel" )
		cancelBtn.Paint = ButtonPaint
		DV2P.pathfinder.mapDerma.cancelBtn = cancelBtn
		
		
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
			if (DV2P.pathfinder:IsInProgress()) then
				DV2P.pathfinder:FinishPath()
				DV2P.pathfinder:FinishWarp()
			end

			local class = localDropdown:GetText()
			local num = tonumber( systemInput:GetText() )
			local callback = function( plyPos, floatPos )
				if class ~= "" then
					local ent = DV2P.pathfinder:GetMapEntClosest( plyPos, floatPos, class )
					if ent then
						DV2P.pathfinder:WarpToMapEnt( ent, function()
							LocalPlayer():AddNote( "Arrived to destination" );
							surface.PlaySound( "ambient/levels/citadel/portal_open1_adpcm.wav" )
						end )
					end
				else
					LocalPlayer():AddNote( "Arrived to destination" );
					surface.PlaySound( "ambient/levels/citadel/portal_open1_adpcm.wav" )
				end
			end

			local straight = straightCheckbox:GetChecked()
			if num then
				DV2P.pathfinder:StartWarpToID( num, straight, callback )
			else
				DV2P.pathfinder:StartWarpToName( systemInput:GetText(), straight, callback )
			end
			
			surface.PlaySound( "buttons/button24.wav" )
		end
		
		function cancelBtn:DoClick()
			DV2P.pathfinder:FinishPath()
			DV2P.pathfinder:FinishWarp()
			surface.PlaySound( "buttons/button24.wav" )
		end
		
		function window:PerformLayout( w, h )
			
			window:SetSize( 300, 174 )
			window:SetPos( map_w - w - 10, map_h - h - 10 )
	
			systemLabel:SetPos( 14, 10 )
	
			systemInput:SetSize( w - 20, 20 )
			systemInput:SetPos( 10, 30 )
			
			localDropdown:SetSize( w - 20, 20 )
			localDropdown:SetPos( 10, 55 )

			straightCheckbox:SetPos( 10, 80 )
			
			warpBtn:SetSize( w - 16, 25 )
			warpBtn:SetPos( 8, 110 )
			
			cancelBtn:SetSize( w - 16, 25 )
			cancelBtn:SetPos( 8, 140 )
		end
		
		function window:Paint( w, h )
			DrawDV2Button( 0, 0, w - 1, h - 1, 12, MAIN_GUICOLOR, MAIN_BLACKCOLOR )
		end
		
		DV2P.pathfinder.vguiInitialized = true
	end, function( err ) print( err ) end )
end )