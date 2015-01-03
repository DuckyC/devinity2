PLUGIN.Name = "Target HUD"

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
	local targets = lp:GetTargets()
	local targetIDs = {}
	local primTarget = lp:GetPrimaryTarget()
	for k, v in pairs( targets ) do
		C = C + 1

		local x, y = ListX, ListY + ListH * C

		if input.IsMouseInBox( x, y, 320, ListH ) then

			DrawRect( x, y, 320, ListH, Color( 255, 255, 255, 10 ) )

			if input.MousePress( MOUSE_LEFT, "TargetHUDButtons_" .. k) then
				lp.PrimaryTarget = k
			end
		end
		if primTarget == v then
			DrawRect( x, y, 320, ListH, Color( 0, 255, 0, 5 ) )
		end
		
		AddButton( x - ListH - 4, y, ListH, ListH, "Untarget", function()
			lp:RequestTarget( 0, k )
		end )
		AddButton( x - ( ListH + 4 ) * 2, y, ListH, ListH, "Look at", function()
			SetCameraLookAt( v ) 
		end )

		if v.IsPlayer then
			local OffX,OffY = 130,5
			local w,h = 60,ListH-10

			local HP,MHP = v:GetShipHealth()
			local AM,MAM = v:GetShipArmor()
			local SH,MSH = v:GetShipShield()

			DrawText( math.NiceInt( HP ), "DVSmall", x + OffX + w / 2, y + OffY + h / 2, MAIN_WHITECOLOR, 1 )
			DrawText( math.NiceInt( AM ), "DVSmall", x + OffX + w + w / 2, y + OffY + h / 2, Color( 100, 100, 100 ), 1 )
			DrawText( math.NiceInt( SH ), "DVSmall", x + OffX + w * 2 + w / 2, y + OffY + h / 2, MAIN_WHITECOLOR, 1 )
		elseif v.IsNew then
			if v.Health and v.Armor and v.Shield then
				local OffX,OffY = 130,5
				local w,h = 60,ListH-10

				local HP,MHP = v.Health,v.MaxHealth
				local AM,MAM = v.Armor,v.MaxArmor
				local SH,MSH = v.Shield,v.MaxShield

				DrawText( math.NiceInt( HP ), "DVSmall", x + OffX + w / 2, y + OffY + h / 2, MAIN_WHITECOLOR, 1 )
				DrawText( math.NiceInt( AM ), "DVSmall", x + OffX + w + w / 2, y + OffY + h / 2, Color( 100, 100, 100 ), 1 )
				DrawText( math.NiceInt( SH ), "DVSmall", x + OffX + w * 2 + w / 2, y + OffY + h / 2, MAIN_WHITECOLOR, 1 )
			end
		end

		targetIDs[ v:GetIndex() ] = v
	end

	local reg, id = lp:GetRegion()
	local ents = dv2ents.GetInRegion( reg )
	local potentialTargets = {}

	for k, v in pairs( ents ) do
		local Pos 	= v:GetRelativePos(lp)
		local Dis	= Pos:Length()
		
		if (Dis < MAIN_VISIBLE_RANGE) then
			potentialTargets[ #potentialTargets + 1 ] = v
		end
	end

	for k,v in pairs( player.GetAllInRegion( reg, lp ) ) do
		if v.PlayerPos then
			local Pos 	= (v.PlayerPos-lp.PlayerPos)+(v.FloatPos-lp.FloatPos)
			local Dis	= Pos:Length()
			
			if (Dis < MAIN_VISIBLE_RANGE) then
				potentialTargets[ #potentialTargets + 1 ] = v
			end
		end
	end

	local C = 0
	for k, v in pairs( potentialTargets ) do
		if targetIDs[ v:GetIndex() ] == v then continue end
		C = C + 1

		local x, y = ListX - 390, ListY + ListH * C

		DrawRect(x,y,320,ListH,MAIN_BLACKCOLOR)
		DrawOutlinedRect(x,y,320,ListH,MAIN_GUICOLOR)

		if (v.IsPlayer) then
			local HP,MHP = v:GetShipHealth()
			local AM,MAM = v:GetShipArmor()
			local SH,MSH = v:GetShipShield()
			
			local cHP = math.Clamp(HP/MHP,0,1)
			local cAM = math.Clamp(AM/MAM,0,1)
			local cSH = math.Clamp(SH/MSH,0,1)
			
			local OffX,OffY = 130,5
			local w,h = 60,ListH-10

			DrawDV2Progress(x+OffX,y+OffY,w,h,cHP,MAIN_REDCOLOR,MAIN_GUICOLOR)
			DrawDV2Progress(x+w+OffX,y+OffY,w,h,cAM,MAIN_YELLOWCOLOR,MAIN_GUICOLOR)
			DrawDV2Progress(x+w*2+OffX,y+OffY,w,h,cSH,MAIN_BLUECOLOR,MAIN_GUICOLOR)
			
			DrawText( math.NiceInt( HP ), "DVSmall", x + OffX + w / 2, y + OffY + h / 2, MAIN_WHITECOLOR, 1 )
			DrawText( math.NiceInt( AM ), "DVSmall", x + OffX + w + w / 2, y + OffY + h / 2, Color( 100, 100, 100 ), 1 )
			DrawText( math.NiceInt( SH ), "DVSmall", x + OffX + w * 2 + w / 2, y + OffY + h / 2, MAIN_WHITECOLOR, 1 )
		

			DrawText(v:Nick(),"DVSmall",x+4,y+4,MAIN_WHITECOLOR)
		elseif (v.IsNew) then
			--Indication it is an NPC or something that can be killed!
			if (v.Health and v.Armor and v.Shield) then
				local HP,MHP = v.Health,v.MaxHealth
				local AM,MAM = v.Armor,v.MaxArmor
				local SH,MSH = v.Shield,v.MaxShield
				
				local cHP = math.Clamp(HP/MHP,0,1)
				local cAM = math.Clamp(AM/MAM,0,1)
				local cSH = math.Clamp(SH/MSH,0,1)
				
				local OffX,OffY = 130,5
				local w,h = 60,ListH-10
	
				DrawDV2Progress(x+OffX,y+OffY,w,h,cHP,MAIN_REDCOLOR,MAIN_GUICOLOR)
				DrawDV2Progress(x+w+OffX,y+OffY,w,h,cAM,MAIN_YELLOWCOLOR,MAIN_GUICOLOR)
				DrawDV2Progress(x+w*2+OffX,y+OffY,w,h,cSH,MAIN_BLUECOLOR,MAIN_GUICOLOR)
				
				DrawText( math.NiceInt( HP ), "DVSmall", x + OffX + w / 2, y + OffY + h / 2, MAIN_WHITECOLOR, 1 )
				DrawText( math.NiceInt( AM ), "DVSmall", x + OffX + w + w / 2, y + OffY + h / 2, Color( 100, 100, 100 ), 1 )
				DrawText( math.NiceInt( SH ), "DVSmall", x + OffX + w * 2 + w / 2, y + OffY + h / 2, MAIN_WHITECOLOR, 1 )
			
				
				DrawText("T: "..v:GetTech(),"DVSmall",x+OffX-30,y+4,MAIN_CYANCOLOR)
				DrawText(v:GetClass(),"DVSmall",x+4,y+4,MAIN_WHITECOLOR)
			end
		else
			DrawText(v.Class,"DVSmall",x+4,y+4,MAIN_WHITECOLOR)
		end

		if input.IsMouseInBox( x, y, 320, ListH ) then

			DrawRect( x, y, 320, ListH, Color( 255, 255, 255, 10 ) )

			if input.MousePress( MOUSE_LEFT, "TargetHUDButtons_PotentialTarget_" .. k) then

				lp:RequestTarget( v:GetIndex(), nil, v.IsPlayer, v.IsNew )
			end
		end
	end
end )