PLUGIN.Name = "Equipment Tools"

local Outer = Color(24,40,54,255)
local Inner = Color(7,15,22,255)

local SW, SH		= ScrW(), ScrH()
local xh,yh 		= SW/2,SH/2
local lp 			= LocalPlayer()

local function AddButton(x,y,tooltip, doclick)
	if (input.IsMouseInBox(x,y,16,16)) then
		DrawRect(x,y,16,16,MAIN_GREENCOLOR) 
		DrawOutlinedRect(x,y,16,16,Outer)
		if (input.MousePress(MOUSE_LEFT,"SecretButtons_"..tooltip)) then
			doclick()
		end
		local nx,ny 	= xh, SH-200

		surface.SetFont("DVText")
		local w,h = surface.GetTextSize(tooltip)
		w,h = w+4,h+4

		DrawRect(nx-w/2+2,ny-h/2,w,h,Inner) 
		DrawOutlinedRect(nx-w/2+2,ny-h/2,w,h,Outer)

		DrawText(tooltip,"DVText",nx+2,ny,MAIN_WHITECOLOR, TEXT_ALIGN_CENTER)
	else
		DrawRect(x,y,16,16,Inner) 
		DrawOutlinedRect(x,y,16,16,Outer)
	end
	
end

hook.Add("HUDPaint", "TurretButtons", function()
	local x,y 	= xh, SH-175

	AddButton(x-18, y, "Fire all", function()
		DV2P.FireAll( nil, true )
	end)

	AddButton(x, y, "Unequip All", function() for i=1,64 do RequestUnequipItem(i) end end)
	AddButton(x+18, y, "Stop all", function() DV2P.FireAll( nil, false ) end)
	
end)