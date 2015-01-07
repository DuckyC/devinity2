PLUGIN.Name = "Player Info"

local Close = surface.GetTextureID("gearfox/vgui/close")
local Zero = Vector(0,0,0)


function DV2P.ShowPlayerInfo(pl)
	

	local Frame = vgui.Create("DFrame")
	Frame:SetPos(21,30)
	Frame:SetSize(300,150)
	Frame:SetTitle("")
	Frame:SetVisible(true)
	Frame:ShowCloseButton(false)
	Frame.Paint = function(s,w,h) 
		DrawRect(0,0,w,h,MAIN_BLACKCOLOR)
		DrawOutlinedRect(0,0,w,h,MAIN_GUICOLOR)
		DrawLine(0,22,w,22,MAIN_GUICOLOR)
		
		DrawText("Player Information","DVTextSmall",w/2,11,MAIN_WHITECOLOR,1)

		
	
		if (input.IsMouseInBox(w-17 , 3 , 14 , 14)) then DrawTexturedRect( w-17 , 3 , 14 , 14 , MAIN_WHITECOLOR , Close )
		else DrawTexturedRect( w-17 , 3 , 14 , 14 , MAIN_TEXTCOLOR , Close ) end

		local HP,MHP = pl:GetShipHealth()
		local AM,MAM = pl:GetShipArmor()
		local SH,MSH = pl:GetShipShield()
		
		local cHP = math.Clamp(HP/MHP,0,1)
		local cAM = math.Clamp(AM/MAM,0,1)
		local cSH = math.Clamp(SH/MSH,0,1)
		
		local x,y = w-200,h-20
		local OffX,OffY = 0,0
		local hw,hh = 60,10

		DrawDV2Progress(x+OffX,y+OffY,hw,hh,cHP,MAIN_REDCOLOR,MAIN_GUICOLOR)
		DrawDV2Progress(x+hw+OffX,y+OffY,hw,hh,cAM,MAIN_YELLOWCOLOR,MAIN_GUICOLOR)
		DrawDV2Progress(x+hw*2+OffX,y+OffY,hw,hh,cSH,MAIN_BLUECOLOR,MAIN_GUICOLOR)
		
		DrawText( math.NiceInt( HP ), "DVSmall", x + OffX + hw / 2, y + OffY + hh / 2, MAIN_WHITECOLOR, 1 )
		DrawText( math.NiceInt( AM ), "DVSmall", x + OffX + hw + hw / 2, y + OffY + hh / 2, Color( 100, 100, 100 ), 1 )
		DrawText( math.NiceInt( SH ), "DVSmall", x + OffX + hw * 2 + hw / 2, y + OffY + hh / 2, MAIN_WHITECOLOR, 1 )

		if pl.Equipment and #pl.Equipment > 0 then
			local Weapons = {}
			local Count = 0
			for i=0,#pl.Equipment do
				local Wep = pl.Equipment[i]
				if not Wep then continue end
				local Found = false
				for k,v in pairs(Weapons) do
					if CompareItems(Wep,v.Wep) then
						Weapons[k].Amount = Weapons[k].Amount + 1
						Found = true
						break
					end
				end
				if not Found then
					Weapons[#Weapons+1] = {Wep = Wep, Amount = 1}
					Count = Count + 1
				end
			end
			if Count > 0 then
				local nx,ny = 5,h-20
				for i=1, Count do
					local Data = Weapons[i]
					local SX, SY = nx+i*25,ny
					DrawDV2Button( SX - 10, SY - 10, 20, 20, 5, MAIN_GUICOLOR, MAIN_BLACKCOLOR )
					DrawItemIcon( SX - 8, SY - 8, 16, 16, Data.Wep, 1, Frame, true )
					DrawText( "x"..Data.Amount, "DefaultSmall", SX,SY+5, MAIN_WHITECOLOR, 1 )
				end
			end
		end

	end
	local old = Frame.OnMousePressed
	Frame.OnMousePressed =  function (self)
		old(self)
		local x,y = self:LocalToScreen( self:GetWide()-17 , 3 )
		if (input.IsMouseInBox( x , y , 14 , 14 )) then self:Remove() end
	end
	
	Frame.ShipModel = vgui.Create("DModelPanel", Frame)
	Frame.ShipModel:SetPos(5,15)
	Frame.ShipModel:SetSize(85,85)
	Frame.ShipModel:SetLookAt(Zero)
	Frame.ShipModel.Think = function()
		local Ship = pl:GetShipData()
		local CamPos 	= Vector(1,0,0.6)*(Ship.Boundaries.Max-Ship.Boundaries.Min):Length()/2

		Frame.ShipModel:SetModel(Ship.Model)
		Frame.ShipModel:SetCamPos(CamPos)
	end

	local function AddLabel(x,y,text,func)
		local L = vgui.Create("DLabel", Frame)
		L:SetPos(x,y)
		L:SetFont("DVSmall")
		L:SetText("")
		L.LastCheck = os.time()
		L.Think = function()
			if L.LastCheck >= os.time() then return end
			L:SetText(text..(func and func() or ""))
			L:SizeToContents()
			L.LastCheck = os.time()
		end
	end

	AddLabel(5,25, "", function() return pl:GetShipData().Name end)

	AddLabel(100, 30, "Name: "..pl:GetName())
	AddLabel(100, 40, "Money: ",function() return string.Comma(pl:GetMoney()).." GCS" end)
	AddLabel(100, 50, "Faction: "..pl:GetFaction())
end

//Name, Money, Ship, Weapons, Health, Armor, Shield, Faction, 