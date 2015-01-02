
local ListX = ScrW()-330
local ListY = 200
local ListH = 20

local lp = LocalPlayer()

DV2P.OFF.AddFunction( "Post_DrawTargetHUD", "DrawTargetHUDOverlay", function() 
	local mX, mY = gui.MousePos()

	local C = 0
	for k, v in pairs( lp:GetTargets() ) do
		C = C + 1

		local x, y = ListX, ListY + ListH * C

		if mX >= x and mX < x + 320 and
			mY >= y and mY < y + ListH then

			DrawRect( x, y, 320, ListH, Color( 255, 255, 255, 10 ) )

			if input.MousePress( MOUSE_LEFT, "TargetHUDButtons_" .. k) then
				lp.PrimaryTarget = k
			end
		end


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