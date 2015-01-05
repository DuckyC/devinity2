PLUGIN.Name = "Blacklist"
PLUGIN.Description = "Marks blacklisted people as enemies and syncs with a webservice."
PLUGIN._blacklist = PLUGIN._blacklist or {}

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
	self.derma.pnlPlayers:Clear()
	self.derma.container:InvalidateLayout()
end

function PLUGIN:PanelPopulatePlayers()
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
	self.derma.pnlBlacklist:Clear()
	self.derma.container:InvalidateLayout()
end

function PLUGIN:PanelPopulateBlacklist()
	self:PanelClearBlacklist()

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
			self:RemovePlayer( steamID, function( statusCode, err, tbl )
				if statusCode == 200 then
					plugin._blacklist = tbl
					plugin:PanelPopulateBlacklist()
				end
			end )
		end

		self.derma.blacklist[ steamID ] = {
			btnName = btnName,
			btnRemove = btnRemove
		}
	end

	self.derma.container:InvalidateLayout()
end

function PLUGIN:PanelSetup( container )
	self._expanded = self._expanded or false
	self:PanelUpdateSize()

	self.derma.blacklist = self.derma.blacklist or {}
	self.derma.players = self.derma.players or {}

	local lblBlacklist = vgui.Create( "DLabel", container )
	lblBlacklist:SetText( "Blacklist" )
	lblBlacklist:SizeToContents()
	self.derma.lblBlacklist = lblBlacklist

	local btnBlacklistRefresh = vgui.Create( "DVButton", container )
	btnBlacklistRefresh:SetText( "Refresh" )
	btnBlacklistRefresh.DoClick = function( pnl )
		self:FetchAndSetBlacklist( function() self:PanelPopulateBlacklist() end )
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
	self:PanelPopulateBlacklist()
end

function PLUGIN:PanelPerformLayout( container, w, h )
	local _w = math.min( w, 300 )
	self.derma.lblBlacklist:SetPos( 20, 10 )

	self.derma.btnBlacklistRefresh:SetPos( _w - 80 - 10, 10 )
	self.derma.btnBlacklistRefresh:SetSize( 80, 20 )

	self.derma.pnlBlacklist:SetPos( 10, 30 )
	self.derma.pnlBlacklist:SetSize( _w - 20, h - 30 - 10 - 30 - 4 - 20 - 4 - 16 - 20 - 4 )

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

--PLUGIN:UpdatePlayer( "STEAM_0:1:5514303", "Lord Ezrik the Great" )