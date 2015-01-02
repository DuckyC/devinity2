local Close = surface.GetTextureID("gearfox/vgui/close")

DV2P.Plugins = {}
DV2P.PluginMenu = DV2P.PluginMenu or {}
DV2P.PluginMenu.Selected = DV2P.PluginMenu.Selected or nil

local pluginMeta = {
	Description = "None",
	_pnlW = 236,
	_pnlH = 370,
	_pnlDur = 0.5,
	derma = {}
}

pluginMeta.__index = pluginMeta

function pluginMeta:SetPanelSize( w, h, dur )
	self._pnlW = w
	self._pnlH = h
	self._pnlDur = dur
end

function pluginMeta:Think() end
function pluginMeta:HUDPaint() end

hook.Add( "Think", "DV2P_Plugins_Think", function()
	for name, plugin in pairs( DV2P.Plugins ) do
		plugin:Think()
	end
end )

hook.Add( "HUDPaint", "DV2P_Plugins_HUDPaint", function()
	for name, plugin in pairs( DV2P.Plugins ) do
		plugin:HUDPaint()
	end
end )


function DV2P.LoadPlugins( folder )
	local files, dirs = file.Find( folder.."/*.lua", "GAME" )
	for k, v in pairs( files ) do
		PLUGIN = {}
		DV2P.Include( folder.."/", v )
		if PLUGIN then
			DV2P.AddPlugin( PLUGIN )
		end
	end
end

function DV2P.AddPlugin( plugin )
	if not plugin or not plugin.Name then return end

	plugin = setmetatable( plugin, pluginMeta )

	DV2P.Plugins[ plugin.Name ] = plugin

	DV2P.OpenPluginMenu()
end

function DV2P.GetPlugin( name )
	return DV2P.Plugins[ name ]
end

function DV2P.ResizePluginPanel( w, h, dur )
	dur = dur or 0.5

	local pluginName = DV2P.PluginMenu.pluginName
	local pluginDesc = DV2P.PluginMenu.pluginDesc
	local nH = pluginName:GetTall()
	local dH = pluginDesc:GetTall()
	local off = nH + dH

	local w = 108 + 4 + 4 + 4 + 4 + w
	local h = 22 + 4 + 4 + off + 4 + h


	local window = DV2P.PluginMenu.window
	window:SizeTo( w, h, dur, 0 )
end

function DV2P.SetupPluginPanel( name )
	local plugin = DV2P.GetPlugin( name )

	local pluginPanel = DV2P.PluginMenu.pluginPanel
	local panel = vgui.Create( "DPanel", pluginPanel )
	panel:SetPos( 0, 130 )
	panel.Paint = function( pnl, w, h ) end
	DV2P.PluginMenu[ "plugin_" .. name .. "_panel" ] = panel

	if plugin.PanelSetup then
		//plugin._settingUp = true
		plugin:PanelSetup( panel )
		//plugin._settingUp = false
	end

	panel:SetVisible( false )
end

function DV2P.OpenPluginPanel( name )
	local oldSel = DV2P.PluginMenu.Selected
	if oldSel ~= nil then
		local oldPanel = DV2P.PluginMenu[ "plugin_" .. oldSel .. "_panel" ]
		if IsValid( oldPanel ) and oldPanel:IsVisible() then
			oldPanel:SetVisible( false )
		end
	end

	DV2P.PluginMenu.Selected = name
	local sel = DV2P.PluginMenu.Selected
	if sel ~= nil then
		local plugin = DV2P.GetPlugin( sel )
		if not plugin then return end

		local newPanel = DV2P.PluginMenu[ "plugin_" .. sel .. "_panel" ]
		if IsValid( newPanel ) and not newPanel:IsVisible() then
			newPanel:SetVisible( true )

			DV2P.PluginMenu.pluginName:SetText( plugin.Name )
			DV2P.PluginMenu.pluginDesc:SetText( plugin.Description )

			DV2P.PluginMenu.window:InvalidateLayout( true )
			DV2P.ResizePluginPanel( plugin._pnlW, plugin._pnlH, plugin._pnlDur )
		end
	end
end

function DV2P.OpenPluginMenu()
	if IsValid(DV2P.PluginMenu.window) then
		DV2P.PluginMenu.window:Remove()
		DV2P.PluginMenu.window = nil
	end
	
	local window = vgui.Create( "DVFrame" )
	window:SetPos( 21, 30 )
	window:SetSize( 360, 400 )
	window:SetTitle( "" )
	window:SetVisible( true )
	window:SetDeleteOnClose( false )
	window.Paint = function( pnl, w, h ) 
		DrawRect( 0, 0, w, h, MAIN_BLACKCOLOR )
		DrawOutlinedRect( 0, 0, w, h, MAIN_GUICOLOR )
		DrawLine( 0, 22, w, 22, MAIN_GUICOLOR )
		
		DrawText( "Plugins", "DVTextSmall", w / 2, 11, MAIN_WHITECOLOR, 1 )
	end

	DV2P.PluginMenu.window = window

	local pluginList = vgui.Create( "DScrollPanel", window )
	pluginList:SetPos( 4, 22 + 4)

	pluginList.VBar:SetWide( 8 )
	pluginList.VBar.Paint = function( pnl, w, h ) end 
	pluginList.VBar.btnGrip.Paint = function( pnl, w, h )
		DrawRect( 0, 0, w, h, MAIN_GUICOLOR )
	end
	pluginList.VBar.btnUp.Paint = function( pnl, w, h )
		if pnl.Hovered then
			DrawRect( 0, 0, w, h, MAIN_GREENCOLOR )
		else
			DrawRect( 0, 0, w, h, MAIN_GUICOLOR )
		end
	end
	pluginList.VBar.btnDown.Paint = function( pnl, w, h )
		if pnl.Hovered then
			DrawRect( 0, 0, w, h, MAIN_GREENCOLOR )
		else
			DrawRect( 0, 0, w, h, MAIN_GUICOLOR )
		end
	end
	DV2P.PluginMenu.pluginList = pluginList


	local pluginPanel = vgui.Create( "DPanel", window )
	pluginPanel:SetPos( 108 + 4 + 4 + 4, 22 + 4 )
	pluginPanel:SetSize( window:GetWide() - 108 - 4 - 4 - 4 - 4, window:GetTall() - 22 - 8)
	pluginPanel.Paint = function( pnl, w, h ) end
	DV2P.PluginMenu.pluginPanel = pluginPanel

	local pluginName = vgui.Create( "DLabel", pluginPanel )
	pluginName:SetText( "No Plugin selected" )
	pluginName:SetFont( "DVText" )
	pluginName:SetTextColor( MAIN_WHITECOLOR )
	DV2P.PluginMenu.pluginName = pluginName

	local pluginDesc = vgui.Create( "DLabel", pluginPanel )
	pluginDesc:SetText( "" )
	pluginDesc:SetFont( "DVTextSmall" )
	pluginDesc:SetTextColor( MAIN_WHITECOLOR )
	pluginDesc:SetWrap( true )
	pluginDesc:SetContentAlignment( 8 )
	DV2P.PluginMenu.pluginDesc = pluginDesc
	
	function ButtonPaint( pnl, w, h )
		if pnl.Hovered or DV2P.PluginMenu.Selected == pnl.pluginName then
			DrawDV2Button( 0, 0, w, h, 8, MAIN_GREENCOLOR, MAIN_BLACKCOLOR )
		else
			DrawDV2Button( 0, 0, w, h, 8, MAIN_GUICOLOR, MAIN_BLACKCOLOR )
		end

		DrawText( pnl.Text, "DVTextSmall", w / 2, h / 2 , MAIN_TEXTCOLOR, TEXT_ALIGN_CENTER )
	end

	local btnW, btnH = 100, 40

	local n = 0
	for name, plugin in pairs( DV2P.Plugins ) do
		local desc = plugin.Description

		local btnText = name
		surface.SetFont( "DVTextSmall" )
		local w, h = surface.GetTextSize( btnText )
		if w >= btnW - 8 then
			for i = #btnText, 0, -1  do
				local newName = string.sub( btnText, 0, i ) .. "..."
				local w, h = surface.GetTextSize( newName )
				if w < btnW - 8 then
					btnText = newName
					break
				end
			end
		end

		local button = vgui.Create( "MBButton", pluginList )
		button:SetSize( btnW, btnH )
		button:SetPos( 0, ( btnH + 4 ) * n )
		button:SetText( btnText )
		button.Paint = ButtonPaint
		button.pluginName = name

		button.DoClick = function( pnl )
			DV2P.OpenPluginPanel( pnl.pluginName )
		end

		DV2P.PluginMenu[ "plugin_" .. name .. "_button" ] = button

		DV2P.SetupPluginPanel( name )

		n = n + 1
	end

	function window:PerformLayout( w, h )
		pluginList:SetSize( 108 + 4, h - 22 - 8 )

		pluginPanel:SetSize( w - 108 - 4 - 4 - 4 - 4, h - 22 - 8 )
		local pW, pH = pluginPanel:GetSize()

		pluginName:SetPos( 0, 0 )
		pluginName:SetWide( pW )

		local nH = pluginName:GetTall()
		pluginDesc:SetPos( 10, nH )
		pluginDesc:SetSize( pW - 10, 40 )

		local dH = pluginDesc:GetTall()
		local off = nH + dH

		local selectedPlugin = DV2P.PluginMenu.Selected
		
		for name, plugin in pairs( DV2P.Plugins ) do
			local panel = DV2P.PluginMenu[ "plugin_" .. name .. "_panel" ]

			if not IsValid( panel ) then return end
			panel:SetPos( 0, off + 4)
			panel:SetSize( pW, pH - off - 4 )

			local pW, pH = panel:GetSize()

			if plugin.PanelPerformLayout then
				plugin:PanelPerformLayout( panel, pW, pH )
			end
		end
	end

	if DV2P.PluginMenu.Selected then
		DV2P.OpenPluginPanel( DV2P.PluginMenu.Selected )
	end
end

local Icon = Material("devinity2/hud/hudicons/options.png")
hook.Add("HUDPaint", "DrawIcon", function()
	DrawMaterialRect(35,3,16,16,MAIN_BLACKCOLOR,Icon) 
	if (input.IsMouseInBox(35,5,16,16)) then
		DrawMaterialRect(35,3,16,16,MAIN_GREENCOLOR,Icon) 
		if (input.MousePress(MOUSE_LEFT,"OpenPluginMenu") and (!DV2P.PluginMenu.window or !DV2P.PluginMenu.window:IsVisible())) then
			DV2P.OpenPluginMenu()
		end
	else
		DrawMaterialRect(35,3,16,16,MAIN_WHITECOLOR,Icon) 
	end
end)