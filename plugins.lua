DV2P.Plugins = {}

function DV2P.AddPlugin( plugin )
	if not plugin or not plugin.name then return end
	plugin.description = plugin.description or "None"

	DV2P.Plugins[ plugin.name ] = plugin
end



function DV2P.OpenPluginMenu()
	if IsValid(DV2P.PluginMenu) then
		DV2P.PluginMenu:Remove()
		DV2P.PluginMenu = nil
	end
	
	DV2P.PluginMenu = vgui.Create("MBFrame")
	DV2P.PluginMenu:SetPos(21,30)
	DV2P.PluginMenu:SetSize(360,400)
	DV2P.PluginMenu:SetTitle("")
	DV2P.PluginMenu:SetVisible(true)
	DV2P.PluginMenu:SetDeleteOnClose(false)
	DV2P.PluginMenu.Paint = function(s,w,h) 
		DrawRect(0,0,w,h,MAIN_BLACKCOLOR)
		DrawOutlinedRect(0,0,w,h,MAIN_GUICOLOR)
		DrawLine(0,22,w,22,MAIN_GUICOLOR)
		
		DrawText("Plugins","DVTextSmall",w/2,11,MAIN_WHITECOLOR,1)
	end



end

local Icon = Material("devinity2/hud/hudicons/options.png")
hook.Add("HUDPaint", "DrawIcon", function()
	DrawMaterialRect(35,3,16,16,MAIN_BLACKCOLOR,Icon) 
	if (input.IsMouseInBox(35,5,16,16)) then
		DrawMaterialRect(35,3,16,16,MAIN_GREENCOLOR,Icon) 
		if (input.MousePress(MOUSE_LEFT,"OpenPluginMenu") and (!DV2P.PluginMenu or !DV2P.PluginMenu:IsVisible())) then
			DV2P.OpenPluginMenu()
		end
	else
		DrawMaterialRect(35,3,16,16,MAIN_WHITECOLOR,Icon) 
	end
end)