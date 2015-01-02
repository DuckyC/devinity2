
local ListX = ScrW()-330
local ListY = 200
local ListH = 20

local lp = LocalPlayer()

hook.Add( "HUDPaint", "DrawTargetHUDOverlay", function() 

	local mX, mY = gui.MousePos()

	local C = 0
	for k, v in pairs( lp:GetTargets() ) do
		C = C + 1

		local x, y = ListX, ListY + ListH * C

		if mX >= x and mX < x + 320 and
			mY >= y and mY < y + ListH then

			DrawRect( x, y, 320, ListH, Color( 255, 255, 255, 40 ) )

			if input.MousePress( MOUSE_LEFT, "TargetHUDButtons_" .. k) then
				lp.PrimaryTarget = k
			end
		end
	end
end )