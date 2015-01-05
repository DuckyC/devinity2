PLUGIN.Name = "Derma_Query"
PLUGIN.Description = "Devinity styled Derma_Query"

function DV2P.Derma_Query( strText, strTitle, ... )

	local Window = vgui.Create( "DFrame" )
		Window:SetTitle( strTitle or "Message Title (First Parameter)" )
		Window.lblTitle:SetFont( "DVTextSmall" )
		Window:SetDraggable( false )
		Window:ShowCloseButton( false )
		Window:SetBackgroundBlur( true )
		Window:SetDrawOnTop( true )

		Window.Paint = function( pnl, w, h )
			if ( pnl.m_bBackgroundBlur ) then
				Derma_DrawBackgroundBlur( pnl, pnl.m_fCreateTime )
			end
			
			DrawDV2Button( 0, 0, w, h, 8, MAIN_GUICOLOR, MAIN_BLACKCOLOR )
			DrawRect( 0, 20, w, 2, MAIN_GUICOLOR )
		end
		
	local InnerPanel = vgui.Create( "DPanel", Window )
		InnerPanel:SetDrawBackground( false )
	
	local Text = vgui.Create( "DLabel", InnerPanel )
		Text:SetText( strText or "Message Text (Second Parameter)" )
		Text:SetFont( "DVTextSmall" )
		Text:SizeToContents()
		Text:SetContentAlignment( 5 )
		Text:SetTextColor( color_white )

	local ButtonPanel = vgui.Create( "DPanel", Window )
		ButtonPanel:SetTall( 30 )
		ButtonPanel:SetDrawBackground( false )

	-- Loop through all the options and create buttons for them.
	local NumOptions = 0
	local x = 5

	for k=1, 8, 2 do
		
		local Text = select( k, ... )
		if Text == nil then break end
		
		local Func = select( k+1, ... ) or function() end
	
		local Button = vgui.Create( "DVButton", ButtonPanel )
			Button:SetText( Text )
			Button:SizeToContents()
			Button:SetTall( 20 )
			Button:SetWide( 100 )
			Button.DoClick = function() Window:Close(); Func() end
			Button:SetPos( x, 5 )
			
		x = x + Button:GetWide() + 5
			
		ButtonPanel:SetWide( x ) 
		NumOptions = NumOptions + 1
	
	end

	
	local w, h = Text:GetSize()
	
	w = math.max( w, ButtonPanel:GetWide() )
	
	Window:SetSize( w + 50, h + 25 + 45 + 10 )
	Window:Center()
	
	InnerPanel:StretchToParent( 5, 25, 5, 45 )
	
	Text:StretchToParent( 5, 5, 5, 5 )	
	
	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom( 8 )
	
	Window:MakePopup()
	Window:DoModal()
	
	if ( NumOptions == 0 ) then
	
		Window:Close()
		Error( "Derma_Query: Created Query with no Options!?" )
		return nil
	
	end
	
	return Window

end