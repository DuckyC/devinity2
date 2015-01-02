
local ListX = ScrW()-330
local ListY = 200
local ListH = 20

local lp = LocalPlayer()
local Outer = Color(24,40,54,255)
local Inner = Color(7,15,22,255)


local function AddButton( x, y, w, h, tooltip, doclick )
	if (input.IsMouseInBox(x,y,w,h)) then
		DrawRect(x,y,w,h,MAIN_GREENCOLOR) 
		DrawOutlinedRect(x,y,w,h,Outer)
		if (input.MousePress(MOUSE_LEFT,"SecretButtons_"..tooltip)) then
			doclick()
		end
		local nx,ny 	= x + w / 2, y - h

		surface.SetFont("DVText")
		local w,h = surface.GetTextSize(tooltip)
		w,h = w+4,h+4

		DrawRect(nx-w/2+2,ny-h/2,w,h,Inner) 
		DrawOutlinedRect(nx-w/2+2,ny-h/2,w,h,Outer)

		DrawText(tooltip,"DVText",nx+2,ny,MAIN_WHITECOLOR, TEXT_ALIGN_CENTER)
	else
		DrawRect(x,y,w,h,Inner) 
		DrawOutlinedRect(x,y,w,h,Outer)
	end
	
end

DV2P.OFF.AddFunction( "Post_DrawTargetHUD", "DrawTargetHUDOverlay", function()
	local C = 0
	for k, v in pairs( lp:GetTargets() ) do
		C = C + 1

		local x, y = ListX, ListY + ListH * C

		if input.IsMouseInBox( x, y, 320, ListH ) then

			DrawRect( x, y, 320, ListH, Color( 255, 255, 255, 10 ) )

			if input.MousePress( MOUSE_LEFT, "TargetHUDButtons_" .. k) then
				lp.PrimaryTarget = k
			end
		end
		
		AddButton( x - ListH - 4, y, ListH, ListH, "Untarget", function()
			lp:RequestTarget( 0, k )
		end )
		AddButton( x - ( ListH + 4 ) * 2, y, ListH, ListH, "Look at", function()
			SetCameraLookAt( v ) 
		end )

		if (v.IsPlayer) then
			local OffX,OffY = 130,5
			local w,h = 60,ListH-10

			local HP,MHP = v:GetShipHealth()
			local AM,MAM = v:GetShipArmor()
			local SH,MSH = v:GetShipShield()

			DrawText( math.NiceInt( HP ), "DVSmall", x + OffX + w / 2, y + OffY + h / 2, MAIN_WHITECOLOR, 1 )
			DrawText( math.NiceInt( AM ), "DVSmall", x + OffX + w + w / 2, y + OffY + h / 2, Color( 100, 100, 100 ), 1 )
			DrawText( math.NiceInt( SH ), "DVSmall", x + OffX + w * 2 + w / 2, y + OffY + h / 2, MAIN_WHITECOLOR, 1 )
		end
	end
end )