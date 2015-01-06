local lp   = LocalPlayer()
local mat		= Material("devinity2/hud/hexagon.png")
local xh,yh 	= ScrW()/2,ScrH()/2

local sw, sh = ScrW(),ScrH()

local IsMouseInBox = input.IsMouseInBox

local input 	= input

DV2P.OFF.AddFunction( "Post_DrawTurretSlots", "DrawAllSlots", function( Car )
	
	local Ship 	= lp:GetShipData()
	if Ship and Ship.TurretSlots then
		if not lp.Inventory then lp.Inventory = {} end
		local count = #Ship.TurretSlots
		local extraCount = 63 - count
		
		DrawDV2Button( xh - ( extraCount / 2 ) * 15 - 50, sh - 36, ( extraCount / 2 ) * 30 + 100, 20, 10,MAIN_GUICOLOR,MAIN_BLACKCOLOR)
		
		local k = 1
		local yOff = 0
		local xOff = 0
		local spacing = 30
		for i = count + 1, 63 do
			k = i - count
			local rowW = math.floor( extraCount / 2 )
			if k > math.ceil( extraCount / 2 ) then
				rowW = math.floor( extraCount / 2 ) - 1
			end

			local SlotPos = {
				x = sw / 2 + xOff * spacing - rowW * ( spacing / 2),
				y = sh - 38 + yOff * 24
			}
			local It = lp.Inventory[ Car ]


			xOff = xOff + 1

			if k % math.ceil( extraCount / 2 ) == 0 then
				yOff = yOff + 1
				xOff = 0
			end
			
			if input.IsMouseInBox( SlotPos.x - 8, SlotPos.y - 8, 16, 16 ) then
				DrawDV2Button( SlotPos.x - 10, SlotPos.y - 10, 20, 20, 5, MAIN_GREENCOLOR, MAIN_BLACKCOLOR )
				
				if Car and It and It.Data and not input.IsMouseDown( MOUSE_LEFT ) then
					RequestEquipItem( i, Car )
					Car = nil
				end
			else
				DrawDV2Button( SlotPos.x - 10, SlotPos.y - 10, 20, 20, 5, MAIN_GUICOLOR, MAIN_BLACKCOLOR )
			end
			
			if lp.Equipment and lp.Equipment[ i ] then
				local equip = lp.Equipment[ i ]

				if lp.ActiveSlots and lp.ActiveSlots[ i ] and lp.ActiveSlots[ i ].Time > CurTime() then
					local C = ( lp.ActiveSlots[ i ].Time - CurTime() ) / equip.CD
					local A = MAIN_GREENCOLOR.a * 1
					
					local col = ColorAlpha( MAIN_GREENCOLOR, 100 )
					DrawRect( SlotPos.x - 8, SlotPos.y + 8 - math.max( 0, 16 - 16 * C ), 16, math.max( 0, 16 - 16 * C ), col )
				end

				if DrawItemIcon( SlotPos.x - 8, SlotPos.y - 8, 16, 16, equip, 1, nil, true ) and not Car then
					if input.MousePress( MOUSE_RIGHT, "Swapper" ) then
						local menu = DermaMenu() 
						menu.ID = i
						menu.Paint = function(s,w,h) DrawRect( 0, 0, w, h, MAIN_GUICOLOR ) end
						menu:AddOption( "Unequip item", function()
							RequestUnequipItem(menu.ID)
						end ):SetColor( MAIN_TEXTCOLOR )
						menu:Open()
						menu:SetPos( SlotPos.x, SlotPos.y - 16)

					elseif input.MousePress( MOUSE_LEFT, "Swapper" ) then
						if lp.ActiveSlots and lp.ActiveSlots[ i ] and lp.ActiveSlots[ i ].On then ToggleFire( i,false )
						else ToggleFire( i,true ) end
					end
				end
			end

			DrawText( tostring( i ), "DefaultSmall", SlotPos.x,SlotPos.y + 4, MAIN_WHITECOLORT, 1 )
		end
	end
end )