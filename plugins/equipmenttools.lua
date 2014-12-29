local Outer = Color(24,40,54,255)
local Inner = Color(7,15,22,255)

local function AddButton(x,y,tooltip, doclick)
	if (input.IsMouseInBox(x,y,16,16)) then
		DrawRect(x,y,16,16,MAIN_GREENCOLOR) 
		if (input.MousePress(MOUSE_LEFT,"OpenPluginMenu")) then
			doclick()
		end
		local nx,ny = x+15,y-15
		surface.SetFont("DVText")
		local w,h = surface.GetTextSize(tooltip)

		DrawRect(nx,ny,w+4,h+4,Inner) 
		DrawOutlinedRect(nx,ny,w+4,h+4,Outer)

		DrawText(tooltip,"DVText",nx+2,ny+2,MAIN_WHITECOLOR)
	else
		DrawRect(x,y,16,16,Inner) 
	end
	DrawOutlinedRect(x,y,16,16,Outer)
end

local SW, SH		= ScrW(), ScrH()
local xh,yh 		= SW/2,SH/2
local lp 			= LocalPlayer()

hook.Add("HUDPaint", "TurretButtons", function()
	local Num = #lp:GetShipData().TurretSlots
	local Pos 	= {x=SW/2-Num*35+(-100)-35,y=SH-100}

	AddButton(Pos.x, Pos.y, "Fire all", function() for i=1,64 do ToggleFire(i,true) end end)
	AddButton(Pos.x, Pos.y+18, "Stop all", function() for i=1,64 do ToggleFire(i,false) end end)

	AddButton(Pos.x-18, Pos.y+18, "Unequip All", function() for i=1,64 do RequestUnequipItem(i) end end)
end)