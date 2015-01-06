
DV2P.Overrides.DrawTargetHUD = DV2P.Overrides.DrawTargetHUD or DrawTargetHUD
DV2P.Overrides.DrawMapEnts = DV2P.Overrides.DrawMapEnts or DrawMapEnts

function DrawTargetHUD()
	DV2P.OFF.RunFunction( "Pre_DrawTargetHUD" )
	DV2P.Overrides.DrawTargetHUD()
	DV2P.OFF.RunFunction( "Post_DrawTargetHUD" )
end


local Mat1 = surface.GetTextureID("devinity2/hud/target_white")
local DMC  = Color(30,60,90,250)

local DisplayTable = {
	"AsteroidField",
	"Planet",
	"Station",
	"GasCloud",
	"BlackHole",
}

local DisplayTableIcons = {
	["AsteroidField"] 	= Material("devinity2/hud/asteroid_icon.png"),
	["Planet"] 			= Material("devinity2/hud/planet_icon.png"),
	["Station"] 		= Material("devinity2/hud/target_white"),
	["GasCloud"] 		= Material("devinity2/hud/gascloud_icon.png"),
	["CargoDrop"] 		= Material("devinity2/hud/box.png"),
	["BlackHole"] 		= Material("devinity2/hud/box.png"),
}

function DrawMapEnts()
	local lp 	= LocalPlayer()
	local aim 	= lp:GetAimVector()
	
	if (!lp.PlayerPos) then return end
	
	local Targ = false
	local CurT = CurTime()
	
	for k,v in pairs(GAMEMODE.MapEnts) do
		local Pos 	= (v.Pos-lp.PlayerPos)+(v.FloatPos-lp.FloatPos)
		local Dis	= Pos:Length()
		local Che   = table.HasValue(DisplayTable,v.Class)
		
		if (Che or Dis < MAIN_VISIBLE_RANGE) then
			local SPos 	= Pos:ToScreen()
			
			if (SPos.visible) then
				local Di,Na = ConvertUnits(Dis*MAIN_MULTIPLY_DISTANCE)
				
				if (IsQMenuOpen() and input.IsMouseInBox(SPos.x-8,SPos.y-8,16,16) and !Targ) then 
					Targ = true
					
					DrawTexturedRectRotated(SPos.x,SPos.y,16,16,MAIN_WHITECOLOR,Mat1,CurT*-300)
					DrawText(v.Class.." "..k,"DVTextSmall",SPos.x+12,SPos.y-15,MAIN_WHITECOLOR)
					DrawText(string.Comma(Di).." "..Na,"DefaultSmall",SPos.x+12,SPos.y,MAIN_WHITECOLOR)
					
					if (input.MousePress(MOUSE_RIGHT,"MapMouse") and !lp:IsTargetting(v)) then
						local menu = DermaMenu() 

						menu.Paint = function(s,w,h) DrawRect(0,0,w,h,DMC) end
						if (Dis > 20000) then menu:AddOption( "Warp to", function() lp:SetWarpDestination(v.Pos,v.FloatPos) end ):SetColor(MAIN_TEXTCOLOR)
						elseif (lp.Target != v) then 
							menu:AddOption( "Look at", function() SetCameraLookAt(v) end):SetColor(MAIN_TEXTCOLOR)
							menu:AddOption( "Target", function() lp:RequestTarget(k) end ):SetColor(MAIN_TEXTCOLOR)
							if (v.Class == "CargoDrop") then menu:AddOption( "Take contents", function() TakeJettisonObject(v:GetIndex()) end ):SetColor(MAIN_TEXTCOLOR) end
						end
						DV2P.OFF.RunFunction( "DrawMapEnts_MenuAddOption", menu, v, Pos, Dis, SPos )
						menu:Open()
						menu:SetPos(SPos.x,SPos.y)
					elseif (input.MousePress(MOUSE_LEFT,"MapMouse2") and Dis < 20000) then
						lp:RequestTarget(k)
					end
				end
				
				if (Che or DisplayTableIcons[v.Class]) then
					DrawMaterialRect(SPos.x-8,SPos.y-8,16,16,MAIN_WHITECOLOR,DisplayTableIcons[v.Class])
				else
					DrawMaterialRect(SPos.x-8,SPos.y-8,16,16,MAIN_WHITECOLOR,Mat2)
				end
			end
		end
	end 
end