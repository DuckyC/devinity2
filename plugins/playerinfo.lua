PLUGIN.Name = "Player Info"

local Close = surface.GetTextureID("gearfox/vgui/close")
local Zero = Vector(0,0,0)
function DV2P.ShowPlayerInfo(pl)
	local Ship = pl:GetShipData()

	local Frame = vgui.Create("DFrame")
	Frame:SetPos(21,30)
	Frame:SetSize(400,200)
	Frame:SetTitle("")
	Frame:SetVisible(true)
	Frame:ShowCloseButton(false)
	Frame.Paint = function(s,w,h) 
		DrawRect(0,0,w,h,MAIN_BLACKCOLOR)
		DrawOutlinedRect(0,0,w,h,MAIN_GUICOLOR)
		DrawLine(0,22,w,22,MAIN_GUICOLOR)
		
		DrawText("Player Information","DVTextSmall",w/2,11,MAIN_WHITECOLOR,1)

		local x,y = 0,0
	
		if (input.IsMouseInBox(x+w-17 , y+3 , 14 , 14)) then DrawTexturedRect( w-17 , 3 , 14 , 14 , MAIN_WHITECOLOR , Close )
		else DrawTexturedRect( w-17 , 3 , 14 , 14 , MAIN_TEXTCOLOR , Close ) end
	end
	local old = Frame.OnMousePressed
	Frame.OnMousePressed =  function (self)
		old(self)
		local x,y = self:LocalToScreen( self:GetWide()-17 , 3 )
		if (input.IsMouseInBox( x , y , 14 , 14 )) then self:Remove() end
	end

	local CamPos 	= Vector(1,0,0.6)*(Ship.Boundaries.Max-Ship.Boundaries.Min):Length()/2
	
	Frame.ShipModel = vgui.Create("DModelPanel", Frame)
	Frame.ShipModel:SetPos(5,5)
	Frame.ShipModel:SetSize(85,85)
	Frame.ShipModel:SetModel(Ship.Model)
	Frame.ShipModel:SetLookAt(Zero)
	Frame.ShipModel:SetCamPos(CamPos)
end

//Name, Money, Ship, Weapons, Health, Armor, Shield, Faction, 