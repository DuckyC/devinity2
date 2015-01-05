PLUGIN.Name = "Sound Browser"
PLUGIN.fileLimit = 1000

local keyDown = false
local soundPlaying = false
local formats = {".wav", ".ogg", ".mp3"}

function PLUGIN:PanelSetup( container )
	local keyDown = false
	self:SetPanelSize( 500, 430, 0.2 )
	 
	local tree = vgui.Create( "DTree", container )
	--tree:SetSize(SM.Frame:GetWide() - 30, SM.Frame:GetTall() - 131)
	tree:SetPadding(5)
	tree.Paint = function( pnl, w, h )
		DrawRect( 0, 0, w, h, MAIN_BLACKCOLOR )
		DrawOutlinedRect( 0, 0, w, h, MAIN_GUICOLOR )
	end
	tree.Think = function( pnl )
		if input.IsKeyDown(KEY_SPACE) then
			if not keyDown then
				self.derma.btnPlay.DoClick()
				keyDown = true
			end
		else
			keyDown = false
		end
	end
	DV2P.PaintVBar( tree.VBar )
	self.derma.tree = tree

	local treeNode = tree:AddNode( "sound" )
	treeNode.dir  = "sound/"
	treeNode.gen = false
	treeNode.Label:SetTextColor( Color( 255, 255, 255 ) )
	self.derma.treeNode = treeNode
	
	local btnPlay = vgui.Create( "DVButton", container )
	--btnPlay:SetPos(15, container:GetTall() - 73)
	--btnPlay:SetSize(SM.Tree:GetWide()/3 - 2, 28)
	btnPlay:SetText( "Play Sound" )
	btnPlay:SetTooltip( "Use the spacebar as a hotkey!" )
	btnPlay.DoClick = function()
		local item = tree:GetSelectedItem()
		if not item or not item.IsFile then return end

		local file = string.sub( item.dir, 7 ) .. item:GetText()
		print( file )
		RunConsoleCommand( "stopsound" )
		timer.Simple( 0.1, function() surface.PlaySound( file ) end )
	end
	self.derma.btnPlay = btnPlay

	local btnStop = vgui.Create( "DVButton", container )
	--btnStop:SetPos( tree:GetWide() / 3 + 17, container:GetTall() - 73 )
	--btnStop:SetSize(SM.Tree:GetWide()/3 - 2, 28)
	btnStop:SetText( "Stop Sound" )
	btnStop.DoClick = function()
		RunConsoleCommand( "stopsound" )
	end
	self.derma.btnStop = btnStop

	local btnCopy = vgui.Create("DVButton", container)
	--btnCopy:SetPos(SM.Tree:GetWide()*2/3 + 18, SM.Frame:GetTall() - 73)
	--btnCopy:SetSize(SM.Tree:GetWide()/3 - 2, 28)
	btnCopy:SetText( "Copy Filepath" )
	btnCopy.DoClick = function()
		local item = tree:GetSelectedItem()
		if not item or not item.IsFile then return end

		local file = string.sub( item.dir, 7 ) .. item:GetText()
		SetClipboardText( file )
	end
	self.derma.btnCopy = btnCopy

	local btnRefresh = vgui.Create( "DVButton", container )
	--btnRefresh:SetPos(15, SM.Frame:GetTall() - 90)
	--btnRefresh:SetSize(SM.Tree:GetWide(), 15)
	btnRefresh:SetText( "Refresh List" )
	self.derma.btnRefresh = btnRefresh

	//
	local function FindSounds( node, dir )
		local files, dirs = file.Find( dir.."*", "GAME" )
	
		for _, v in pairs( dirs ) do
			local newNode = node:AddNode( v )
			newNode.dir = dir .. v
			newNode.gen = false
			newNode.Label:SetTextColor( Color( 255, 255, 255 ) )
		
			newNode.DoClick = function( pnl )
				if not newNode.gen then
					FindSounds( newNode, dir .. v .. "/" )
					newNode.gen = true
				end
			end
		end
	
		local function GenerateNodes()
			local fileCount = 0

			for k,v in pairs( files ) do
				if fileCount > self.fileLimit then break end

				local format = string.sub( v, -4 )
				if format and table.HasValue( formats, format ) then
					fileCount = fileCount + 1

					local newNode = node:AddNode( v )
					newNode.file   = v
					newNode.dir    = dir
					newNode.IsFile = true
					newNode.format = format
					newNode.Icon:SetImage( "icon16/sound.png" )
					newNode.Label:SetTextColor( Color( 255, 255, 255 ) )

					files[ k ] = ""
				end
			end
		
			if fileCount > self.fileLimit then
				local newNode = node:AddNode( "Click to load more files..." )
				newNode.Icon:SetImage( "icon16/sound_add.png" )
				newNode.Label:SetTextColor( Color( 255, 255, 255 ) )
				newNode.DoClick = function() 
					newNode:Remove()
					GenerateNodes()
				end
			end
		end
		GenerateNodes()
	end
	
	FindSounds( treeNode, "sound/" )

	btnRefresh.DoClick = function()
		treeNode:Remove()
		treeNode = tree:AddNode( "sound" )
		treeNode.dir  = "sound/"
		treeNode.gen = false
		treeNode.Label:SetTextColor( Color( 255, 255, 255 ) )
	
		FindSounds( treeNode, "sound/" )
	end
end

function PLUGIN:PanelPerformLayout( container, w, h )
	self.derma.tree:SetPos( 10, 10 )
	self.derma.tree:SetSize( w - 20, h - 30 - 10 - 4 - 20 - 10 - 4 )

	self.derma.btnRefresh:SetPos( 10, h - 30 - 10 - 4 - 20 )
	self.derma.btnRefresh:SetSize( w - 20, 20 )

	local sW = ( w - 20 ) / 3 - 4

	self.derma.btnPlay:SetPos( 10, h - 30 - 10 )
	self.derma.btnPlay:SetSize( sW, 30 )

	self.derma.btnStop:SetPos( w / 2 - sW / 2, h - 20 - 20 )
	self.derma.btnStop:SetSize( sW, 30 )

	self.derma.btnCopy:SetPos( w - sW - 10, h - 20 - 20 )
	self.derma.btnCopy:SetSize( sW, 30 )
end