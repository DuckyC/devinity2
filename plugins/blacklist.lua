PLUGIN.Name = "Blacklist"
PLUGIN.Description = "Marks blacklisted people as enemies and syncs with a webservice."
PLUGIN._blacklist = PLUGIN._blacklist or {}

PLUGIN.refreshInterval = 60 * 5
PLUGIN.refreshTime = 0

PLUGIN._playAlarm = ( PLUGIN._playAlarm == nil ) and true or PLUGIN._playAlarm

local lp = LocalPlayer()
local MatTarget = surface.GetTextureID("devinity2/hud/target_white")

function PLUGIN:PanelSetExpanded( expanded )
	self._expanded = expanded
	self:PanelUpdateSize()
end

function PLUGIN:PanelGetExpanded()
	return self._expanded
end

function PLUGIN:PanelUpdateSize()
	if self._expanded then
		self:SetPanelSize( 500, 430, 0.2 )
	else
		self:SetPanelSize( 300, 430, 0.2 )
	end
end

function PLUGIN:PanelClearPlayers()
	if not self:IsInitialized() then return end
	
	if not IsValid( self.derma.pnlPlayers ) then return end

	self.derma.pnlPlayers:Clear()
	self.derma.container:InvalidateLayout()
end

function PLUGIN:PanelPopulatePlayers()
	if not self:IsInitialized() then return end
	
	self:PanelClearPlayers()

	local pnlPlayers = self.derma.pnlPlayers
	local players = player.GetAll()

	for k, v in pairs( players ) do
		if not IsValid( v ) then continue end

		local btnPlayer = vgui.Create( "DVButton", pnlPlayers )
		btnPlayer:SetText( v:Nick() )
		btnPlayer._player = v
		btnPlayer.DoClick = function( pnl )
			if IsValid( pnl._player ) then
				self.derma.txtSteamID:SetText( pnl._player:SteamID() )
				self:PanelSetExpanded( false )
			end
		end

		self.derma.players[ k ] = btnPlayer
	end

	self.derma.container:InvalidateLayout()
end

function PLUGIN:PanelClearBlacklist()
	if not self:IsInitialized() then return end
	
	if not IsValid( self.derma.pnlBlacklist ) then return  end

	self.derma.pnlBlacklist:Clear()
	self.derma.container:InvalidateLayout()
end

function PLUGIN:PanelPopulateBlacklist()
	if not self:IsInitialized() then return end

	self:PanelClearBlacklist()
	self.derma.blacklist = self.derma.blacklist or {}

	local pnlBlacklist = self.derma.pnlBlacklist
	local blacklist = self._blacklist
	if not blacklist.players then return end

	local list = blacklist.players

	for steamID, data in pairs( list ) do
		local btnName = vgui.Create( "DVButton", pnlBlacklist )
		btnName:SetText( data.nick or steamID )
		btnName._data = data
		btnName.DoClick = function( pnl )

		end

		local btnRemove = vgui.Create( "DVButton", pnlBlacklist )
		btnRemove:SetText( "-" )
		btnRemove._data = data
		btnRemove.DoClick = function( pnl )
			local plugin = self
			local query = DV2P.Derma_Query( "Are you sure you want to remove this player from the blacklist?", "Confirmation", "Remove", function()
				self:RemovePlayer( steamID, function( statusCode, err, tbl )
					if statusCode == 200 then
						plugin._blacklist = tbl
						plugin:PanelPopulateBlacklist()
					end
				end )
			end, "Cancel", function()
			end )
		end

		self.derma.blacklist[ steamID ] = {
			btnName = btnName,
			btnRemove = btnRemove
		}
	end

	self.derma.container:InvalidateLayout()
end

function PLUGIN:PanelRefreshBlacklist()
	if not self:IsInitialized() then return end

	self:FetchAndSetBlacklist( function() self:PanelPopulateBlacklist() end )
end

function PLUGIN:PanelSetup( container )
	PrintTable( self.PData )
	self._expanded = self._expanded or false
	self:PanelUpdateSize()

	self.derma.blacklist = self.derma.blacklist or {}
	self.derma.players = self.derma.players or {}

	print( self._playAlarm )

	local chkBlacklist = vgui.Create( "DCheckBoxLabel", container )
	chkBlacklist:SetText( "Play alarm when player is in range" )
	chkBlacklist:SizeToContents()
	chkBlacklist:SetChecked( self._playAlarm )
	chkBlacklist.OnChange = function( pnl, bVal ) self._playAlarm = bVal end
	self.derma.chkBlacklist = chkBlacklist

	local lblBlacklist = vgui.Create( "DLabel", container )
	lblBlacklist:SetText( "Blacklist" )
	lblBlacklist:SizeToContents()
	self.derma.lblBlacklist = lblBlacklist

	local btnBlacklistRefresh = vgui.Create( "DVButton", container )
	btnBlacklistRefresh:SetText( "Refresh" )
	btnBlacklistRefresh.DoClick = function( pnl )
		self:PanelRefreshBlacklist()
	end
	self.derma.btnBlacklistRefresh = btnBlacklistRefresh

	local pnlBlacklist = vgui.Create( "DScrollPanel", container )
	pnlBlacklist.Paint = function( pnl, w, h )
		DrawRect( 0, 0, w, h, MAIN_BLACKCOLOR )
		DrawOutlinedRect( 0, 0, w, h, MAIN_GUICOLOR )
	end
	DV2P.PaintVBar( pnlBlacklist.VBar )
	self.derma.pnlBlacklist = pnlBlacklist

	local btnSelect = vgui.Create( "DVButton", container )
	btnSelect:SetText( "Select from players" )
	btnSelect.DoClick = function( pnl )
		self:PanelSetExpanded( not self:PanelGetExpanded() )

		if self:PanelGetExpanded() then
			self:PanelPopulatePlayers();
		end
	end
	self.derma.btnSelect = btnSelect

	local lblSteamID = vgui.Create( "DLabel", container )
	lblSteamID:SetText( "Steam ID" )
	self.derma.lblSteamID = lblSteamID

	local txtSteamID = vgui.Create( "DTextEntry", container )
	self.derma.txtSteamID = txtSteamID

	local btnAdd = vgui.Create( "DVButton", container )
	btnAdd:SetText( "Add" )
	btnAdd.DoClick = function()
		local steamID = txtSteamID:GetText()
		local ply = DV2P.GetPlayerBySteamID( steamID )
		local nick = nil
		local faction = nil
		if IsValid( ply ) then
			nick = ply:Nick()
			faction = ply:GetFaction()
		end

		self:UpdatePlayer( steamID, nick, faction, function( statusCode, err, tbl )
			if statusCode == 200 then
				self._blacklist = tbl
				self:PanelPopulateBlacklist()
				self.derma.txtSteamID:SetText( "" )
			end
		end )
	end
	self.derma.btnAdd = btnAdd

	-- Expanded

	local pnlPlayers = vgui.Create( "DScrollPanel", container )
	pnlPlayers.Paint = function( pnl, w, h )
		DrawRect( 0, 0, w, h, MAIN_BLACKCOLOR )
		DrawOutlinedRect( 0, 0, w, h, MAIN_GUICOLOR )
	end
	DV2P.PaintVBar( pnlPlayers.VBar )
	self.derma.pnlPlayers = pnlPlayers

	if self:PanelGetExpanded() then self:PanelPopulatePlayers() end
	self:PanelRefreshBlacklist()
end

function PLUGIN:PanelPerformLayout( container, w, h )
	local _w = math.min( w, 300 )
	self.derma.chkBlacklist:SetPos( 20, 10 )

	self.derma.lblBlacklist:SetPos( 20, 10 + 20 + 10 )

	self.derma.btnBlacklistRefresh:SetPos( _w - 80 - 10, 30 )
	self.derma.btnBlacklistRefresh:SetSize( 80, 20 )

	self.derma.pnlBlacklist:SetPos( 10, 30 + 20 + 4 )
	self.derma.pnlBlacklist:SetSize( _w - 20, h - 30 - 10 - 30 - 4 - 20 - 4 - 16 - 20 - 4 - 20 - 4 )

	self.derma.lblSteamID:SetPos( 20, h - 30 - 10 - 20 - 4 - 20 - 20 - 4 )

	self.derma.txtSteamID:SetPos( 10, h - 30 - 10 - 20 - 4 - 20 - 4 )
	self.derma.txtSteamID:SetSize( _w - 20, 20 )

	self.derma.btnSelect:SetPos( _w - 10 - 130, h - 30 - 10 - 20 - 4 )
	self.derma.btnSelect:SetSize( 130, 20 )

	self.derma.btnAdd:SetPos( 10, h - 30 - 10 )
	self.derma.btnAdd:SetSize( _w - 20, 30 )


	-- Expanded

	self.derma.pnlPlayers:SetPos( _w + 10, 10 )
	self.derma.pnlPlayers:SetSize( w - _w - 20, h - 20 )

	local pW, pH = self.derma.pnlPlayers:GetSize()
	local y = 0
	for k, v in pairs( self.derma.players ) do
		if not IsValid( v ) then continue end

		v:SetPos( 4, 4 + ( 20 + 4 ) * y )
		v:SetSize( pW - 8, 20 )

		y = y + 1
	end

	local bW, bH = self.derma.pnlBlacklist:GetSize()
	local y = 0
	for k, v in pairs( self.derma.blacklist ) do
		if not IsValid( v.btnName ) or not IsValid( v.btnRemove ) then continue end

		v.btnName:SetPos( 4, 4 + ( 20 + 4 ) * y )
		v.btnName:SetSize( bW - 8 - 30 - 4, 20 )

		v.btnRemove:SetPos( bW - 30 - 4, 4 + ( 20 + 4 ) * y )
		v.btnRemove:SetSize( 30, 20 )

		y = y + 1
	end
end

function PLUGIN:OnPanelOpened()
	self:PanelPopulatePlayers()
	self:PanelPopulateBlacklist()
end

local pw = "swagmasterx"

function PLUGIN:UpdatePlayer( steamid, nick, faction, callback )
	if not steamid then return end

	http.Post( "http://metamist.kuubstudios.com/devinity/blacklist/update.php", {
		action = "set",
		password = pw,
		steamid = steamid,
		nick = nick,
		faction = faction,
	}, function( response, contentLength, headers, statusCode )
		if statusCode == 200 then
			local tbl = util.JSONToTable( response )

			if tbl then
				callback( statusCode, nil, tbl )
			else
				callback( 500, nil, nil )
			end
		end
	end, function( err )
		callback( 404, err, nil )
	end )
end

function PLUGIN:RemovePlayer( steamid, callback )
	if not steamid then return end

	http.Post( "http://metamist.kuubstudios.com/devinity/blacklist/update.php", {
		action = "remove",
		password = pw,
		steamid = steamid,
	}, function( response, contentLength, headers, statusCode )
		if statusCode == 200 then
			local tbl = util.JSONToTable( response )

			if tbl then
				callback( statusCode, nil, tbl )
			else
				callback( 500, nil, nil )
			end
		end
	end, function( err )
		callback( 404, err, nil )
	end )
end

function PLUGIN:FetchBlacklist( callback )
	http.Fetch( "http://metamist.kuubstudios.com/devinity/blacklist/list.php?password=" .. pw, function( response, contentLength, headers, statusCode )
		if statusCode == 200 then
			local tbl = util.JSONToTable( response )

			if tbl then
				callback( statusCode, nil, tbl )
			else
				callback( 500, nil, tbl )
			end
		else
			callback( statusCode, nil, nil )
		end
	end, function( err )
		callback( 404, err, nil )
	end )
end

function PLUGIN:FetchAndSetBlacklist( callback )
	local plugin = self
	self:FetchBlacklist( function( statusCode, err, tbl )
		if statusCode == 200 then
			plugin._blacklist = tbl
			callback()
		end
	end )
end

function PLUGIN:Think()
	if CurTime() > self.refreshTime then
		self:PanelRefreshBlacklist()

		self.refreshTime = CurTime() + self.refreshInterval
	end

	local blacklist = self._blacklist
	if not blacklist.players then return end

	self.inArea = self.inArea or {}
	local inRange = {}
	for k, v in pairs( player.GetAllInRegion( lp:GetRegion() ) ) do
		if not IsValid( v ) then return end
		if not blacklist.players[ v:SteamID() ] then continue end

		if v.PlayerPos then --and v ~= lp then
			local pos 	= ( v.PlayerPos - lp.PlayerPos ) + ( v.FloatPos - lp.FloatPos )
			local dis	= pos:Length()
			
			if (dis < MAIN_VISIBLE_RANGE) then
				if not self.inArea[ v:SteamID() ] then
					self.inArea[ v:SteamID() ] = v

					if self._playAlarm then
						sound.PlayFile( "sound/ambient/alarms/apc_alarm_loop1.wav", "noplay", function( snd, errID, err )
							snd:EnableLooping( false )
							snd:Play()
							
							for i = 1, 2 do
								timer.Simple( i * 2, function()
									snd:SetTime( 0 )
									snd:Play()
								end )
							end
						end )
					end
				end
				inRange[ v:SteamID() ] = true
			end
		end
	end

	for k, v in pairs( self.inArea ) do
		if not IsValid( v ) then return end
		if not inRange[ v:SteamID() ] then
			self.inArea[ v:SteamID() ] = nil
		end
	end
end

function PLUGIN:HUDPaint()
	if not lp then return end

	local blacklist = self._blacklist
	if not blacklist.players then return end
	local w, h = ScrW(), ScrH()

	local players = blacklist.players
	for k, v in pairs( player.GetAllInRegion( lp:GetRegion() ) ) do
		if not IsValid( v ) then return end
		if not players[ v:SteamID() ] then continue end

		if v.PlayerPos then --and v ~= lp then
			local pos 	= ( v.PlayerPos - lp.PlayerPos ) + ( v.FloatPos - lp.FloatPos )
			local dis	= pos:Length()
			
			if (dis < MAIN_VISIBLE_RANGE) then
				local sPos 	= pos:ToScreen()
				
				if sPos.visible then
					local size = 32 + math.cos( UnPredictedCurTime() * 5 ) * 10
					local col = Color( 255, 0, 0, 200 )

					DrawTexturedRectRotated( sPos.x, sPos.y, size,
						size, col, MatTarget, UnPredictedCurTime() * -300 )
					DrawTexturedRectRotated( sPos.x, sPos.y, size + 40,
						size + 40, col, MatTarget, UnPredictedCurTime() * 300 )

					DrawRect( sPos.x - 8, sPos.y, 16, 1, col )
					DrawRect( sPos.x, sPos.y - 8, 1, 16, col )
				end
			end
		end
	end
end

DV2P.OFF.AddFunction( "Post_MAP_Frame_Paint", "Blacklist", function( pnl, w, h )
	if not lp then return end

	xpcall( function()
		local plugin = DV2P.GetPlugin( "Blacklist" )
		local blacklist = plugin._blacklist
		if not blacklist.players then return end

		local col = Color( 255, 0, 0, 200 )

		if not DV2P.IsMapScreenLocal() then
			local Scale = MAIN_MAP_SIZE/2500

			local players = player.GetAll()
			for k, v in pairs( players ) do
				if not IsValid( v ) then continue end
				if v == lp then continue end
				if not blacklist.players[ v:SteamID() ] then continue end

				local size = ( 12 + math.cos( UnPredictedCurTime() * 5 ) * 4 ) * ( 1 - math.Clamp( ( DV2P.Map.Dist ) / 2000, 0, 0.8 ) ) * 7

				local reg, id = v:GetRegion()
				local sys = GAMEMODE.SolarSystems[ id ]
				if not sys then continue end

				local vRealPos = sys.Pos / Scale 
				local sPos = DV2P.Map.ToScreen( vRealPos )

				DrawTexturedRectRotated( sPos.x, sPos.y, size,
					size, col, MatTarget, UnPredictedCurTime() * -300 )

				DrawTexturedRectRotated( sPos.x, sPos.y, size * 1.8,
					size * 1.8, col, MatTarget, UnPredictedCurTime() * 300 )
			end
		else
			local reg, id = lp:GetRegion()
			local players = player.GetAllInRegion( reg, lp )
			local Scale = MAIN_SOLARSYSTEM_RADIUS/100

			for k, v in pairs( players ) do
				if not IsValid( v ) then continue end
				if not blacklist.players[ v:SteamID() ] then continue end

				local size = ( 12 + math.cos( UnPredictedCurTime() * 5 ) * 4 ) * ( 1 - math.Clamp( ( DV2P.Map.Dist ) / 400, 0, 0.8 ) ) * 4

				local Reg,ID = v:GetRegion()

				local sPos = DV2P.Map.ToScreen((v.PlayerPos-GAMEMODE.SolarSystems[ID].Pos)/Scale+v.FloatPos/Scale)

				DrawTexturedRectRotated( sPos.x, sPos.y, size,
					size, col, MatTarget, UnPredictedCurTime() * -300 )

				DrawTexturedRectRotated( sPos.x, sPos.y, size * 1.8,
					size * 1.8, col, MatTarget, UnPredictedCurTime() * 300 )

			end
		end
	end, function( err ) print( err ) end )
end )