DV2P.Map = DV2P.Map or {
	initial = true
}
DV2P.Map.debug = false

local Mate = Material("devinity2/hud/board.png")

local Clouds = Material("devinity2/effects/antid2/particle1")
local matLight 	= Material( "devinity2/planets/planetglow" )

local Grad  = surface.GetTextureID("vgui/gradient-r")

local Mat2 = Material("devinity2/hud/awesome.png")
local Mat3 = Material("devinity2/hud/coords.png")
local Prox = Material("devinity2/effects/proximity")
local Bare = Material("color")
local Zero = Vector(0,0,0)
local Up   = Vector(0,0,1)
local Blac = Color(0,0,0,255)
local LineC = Color(150,150,150,30)
local Grey = Color(70,70,70,200)
local Cyan = Color(0,250,250,200)
local Dist = DV2P.Map.Dist or 3000

local SysListDim = {x=5,y=5,w=300,h=500}

local Origin	= Vector(0,0,0)

local CamData = DV2P.Map.CamData or {
	angles 		= Angle(30,0,0),
	fov 		= 90,
	origin 		= Vector(3000,0,3000),
	type 		= "3D",
	w 			= ScrW(),
	h 			= ScrH(),
	aspect 		= ScrW()/ScrH(),
	x 			= 0,
	y 			= 0,
	zfar	 	= 99999,
	znear		= 0.1,
}

local LocalMap = DV2P.Map.LocalMap or false
local MousePos = DV2P.Map.MousePos or nil
local Zoom	   = DV2P.Map.Zoom or 1000

local Clamp 	= math.Clamp
local ceil 		= math.ceil
local floor 	= math.floor
local max		= math.max
local min 		= math.min
local cos		= math.cos
local sin 		= math.sin
local random	= math.random
local Rand		= math.Rand
local rad		= math.rad

local insert	= table.insert

local Blu		= Color(50,200,255,255)
local FT		= UnPredictedCurTime()

local WarpCol   = Color(50,50,100,20)

local DrawText 		= DrawText
local DrawQuadEasy 	= render.DrawQuadEasy
local RDrawBeam 	= render.DrawBeam
local RSetMaterial 	= render.SetMaterial

local DisplayTable = {
	"AsteroidField",
	"Planet",
	"Station",
	"GasCloud",
	"BlackHole",
}

function DV2P.Map.ToScreen( vec )
	local iScreenW = CamData.w
	local iScreenH = CamData.h
	local vDir = vec - CamData.origin
	local angCamRot = CamData.angles
	local fFoV = CamData.fov

	local d = (0.5 * iScreenW) / math.tan(math.rad( fFoV ) * 0.5)
	local fdp = angCamRot:Forward():Dot( vDir )
 
	if fdp == 0 then
		return {
			x = 0,
			y = 0,
			visible = -1
		}
	end
 
	local vProj = ( d / fdp ) * vDir
 
	local x = 0.5 * iScreenW + angCamRot:Right():Dot( vProj )
	local y = 0.5 * iScreenH - angCamRot:Up():Dot( vProj )
 
	local iVisibility
	if fdp < 0 then
		iVisibility = -1
	elseif x < 0 || x > iScreenW || y < 0 || y > iScreenH then	--We've already determined the object is in front of us, but it may be lurking just outside our field of vision.
		iVisibility = 0
	else
		iVisibility = 1
	end
 
	return {
		x = x,
		y = y,
		visible = iVisibility
	}
end

function MouseWheelZoom_map(s,delta)
	if (!IsMapOpen()) then return end
	if (LocalMap) then Zoom = math.Clamp(Zoom-delta*50,20,7000)
	else Zoom = math.Clamp(Zoom-delta*200,20,7000) end
end

hook.Add("Think","Derp",function()
	DV2P.OFF.RunFunction( "Pre_Map_Think" )
	local lp = LocalPlayer()

	if (!IsValid(lp)) then return end
	if (!lp:IsTyping() and !gui.IsGameUIVisible() and input.KeyPress(KEY_M,"OpenMap")) then OpenMap() end 
	if (IsValid(MAP_Frame) and MAP_Frame:IsVisible()) then
		if (input.KeyPress(KEY_M,"CloseMap")) then MAP_Frame:SetVisible(false) end
	
		if (input.IsMouseDown(MOUSE_MIDDLE)) then
			local mx,my = gui.MousePos() 
			if (!MousePos) then MousePos = {x=mx,y=my,} end
			
			CamData.angles.y = CamData.angles.y-(mx-MousePos.x)/8
			
			CamData.angles.p = math.Clamp(CamData.angles.p+(my-MousePos.y)/8,20,89)
			
			CamData.origin.x = Origin.x-Dist*cos(rad(CamData.angles.y))*sin(rad(-CamData.angles.p+90))
			CamData.origin.y = Origin.y-Dist*sin(rad(CamData.angles.y))*sin(rad(-CamData.angles.p+90))
			CamData.origin.z = Origin.z-Dist*sin(rad(CamData.angles.p+180))

			MousePos = {x=mx,y=my,}
		elseif (input.IsMouseDown(MOUSE_RIGHT)) then
			local mx,my = gui.MousePos() 
			if (!MousePos) then MousePos = {x=mx,y=my,} end
			
			local dist = Dist/700+0.5
			
			if (LocalMap) then dist = dist/10 end
			
			Origin.x = math.Clamp(Origin.x + (mx-MousePos.x)*dist*cos(rad(CamData.angles.y+90))-(my-MousePos.y)*dist*sin(rad(CamData.angles.y-90)),-3000,3000)
			Origin.y = math.Clamp(Origin.y + (mx-MousePos.x)*dist*sin(rad(CamData.angles.y+90))+(my-MousePos.y)*dist*cos(rad(CamData.angles.y-90)),-3000,3000)
			
			CamData.origin.x = Origin.x-Dist*cos(rad(CamData.angles.y))*sin(rad(-CamData.angles.p+90))
			CamData.origin.y = Origin.y-Dist*sin(rad(CamData.angles.y))*sin(rad(-CamData.angles.p+90))
			CamData.origin.z = Origin.z-Dist*sin(rad(CamData.angles.p+180))

			MousePos = {x=mx,y=my,}
		elseif (MousePos) then MousePos = nil end
		
		if (LocalMap) then
			local reg,id = lp:GetRegion()
			
			if (reg=="Space") then
				local lpPos  = lp.PlayerPos/MAIN_MAP_SIZE*2500+lp.FloatPos/MAIN_MAP_SIZE*2500
				Origin.x = lpPos.x
				Origin.y = lpPos.y
				Origin.z = lpPos.z
			elseif (GAMEMODE.SolarSystems[id]) then
			end
		end
		
		if ((Dist-Zoom) != 0) then
			Dist = Dist+floor((Zoom-Dist)/32*10000)/10000
			
			CamData.origin.x = Origin.x-Dist*cos(math.rad(CamData.angles.y))*sin(rad(-CamData.angles.p+90))
			CamData.origin.y = Origin.y-Dist*sin(math.rad(CamData.angles.y))*sin(rad(-CamData.angles.p+90))
			CamData.origin.z = Origin.z-Dist*sin(math.rad(CamData.angles.p+180))
		end
	end

	DV2P.Map.LocalMap = LocalMap
	DV2P.Map.CamData = CamData
	DV2P.Map.MousePos = MousePos
	DV2P.Map.Zoom = Zoom
	DV2P.Map.Dist = Dist

	DV2P.OFF.RunFunction( "Post_Map_Think" )
end)

function IsMapOpen()
	return (IsValid(MAP_Frame) and MAP_Frame:IsVisible())
end

function OpenMap()
	if DV2P.Map.initial or DV2P.Map.debug then
		if IsValid( MAP_Frame ) then
			MAP_Frame:Remove()
			MAP_Frame = nil
			DV2P.Map.initial = false
		end
	end

	DV2P.OFF.RunFunction( "Pre_OpenMap" )
	if (IsValid(MAP_Frame) and MAP_Frame:IsVisible()) then return end
	
	if (!MAP_Frame) then
		MAP_Frame = vgui.Create("MBFrame")
		MAP_Frame:SetPos(0,0)
		MAP_Frame:SetSize(ScrW(),ScrH())
		MAP_Frame:SetTitle("")
		MAP_Frame:SetVisible(false)
		MAP_Frame:ShowCloseButton(false)
		MAP_Frame:MakePopup()
		MAP_Frame.Clouds = {}
		MAP_Frame.Matches = {}
		
		math.randomseed(5)
		
		local A = 20
		local Col = Color(100,150,250,A)
		
		
		for i = 1,20 do
			local Ang = Angle(Rand(-3,3),Rand(0,360),0)
			
			local Pos = Ang:Forward()*random(0,1500)
			
			Col.a = math.ceil(255/(1+Pos:Length()/30))
			
			for a = 1,math.ceil(Col.a/10) do
				Col.a 	= Col.a/1.4
				Pos 	= Pos+Vector(Rand(-1,1),Rand(-1,1),Rand(-0.2,0.2))*100
				
				insert(MAP_Frame.Clouds,{
					Pos=Pos,
					Col=table.Copy(Col),
					Yaw=random(360),
					Size=random(300,700),
				})
				
			end
			
			Col.a = A
		end
		
		MAP_Frame.Paint = function(s,w,h)
			DV2P.OFF.RunFunction( "Pre_MAP_Frame_Paint", s, w, h )
			local lp = LocalPlayer()
			
			if (!lp.PlayerPos or !lp.FloatPos) then return end
			
			DrawRect(0,0,w,h,Blac)
			
			local Hover 		= 0
			local HoverEntity 	= 0
			local Reg,ID = lp:GetRegion()
			
			local MouseInList = input.IsMouseInBox(SysListDim.x,SysListDim.y,SysListDim.w,SysListDim.h)
			
			local FactControls = {}
			
			local OriginSPos
			
			cam.Start(CamData)
				DV2P.OFF.RunFunction( "Pre_OpenMap_Render3D", CamData )

				if (LocalMap and Reg != "Space") then
					local Scale = MAIN_SOLARSYSTEM_RADIUS/100
					DV2P.OFF.RunFunction( "Pre_OpenMap_Render3D_LocalMap", CamData, Scale )
					
					for k,v in pairs(GAMEMODE.MapEnts) do v.SPos = ((v.Pos-GAMEMODE.SolarSystems[ID].Pos)/Scale+v.FloatPos/Scale):ToScreen() end
					
					lp.SPos = ((lp.PlayerPos-GAMEMODE.SolarSystems[ID].Pos)/Scale+lp.FloatPos/Scale):ToScreen()
					
					if (lp.WarpDest) then
						lp.WarpSPos = ((lp.WarpDest-GAMEMODE.SolarSystems[ID].Pos)/Scale+lp.WarpDestDetail/Scale):ToScreen()
					end
					
					RSetMaterial(Prox)
					DrawQuadEasy(Zero,Up,200,200,MAIN_COLOR,CurTime()/3)

					DV2P.OFF.RunFunction( "Post_OpenMap_Render3D_LocalMap", CamData, Scale )
				else
					DV2P.OFF.RunFunction( "Pre_OpenMap_Render3D_SystemMap", CamData, Scale )
					local Scale = MAIN_MAP_SIZE/2500
					local Data	= lp:GetShipData()
					local Radius = Data.MaxWarpDistance/Scale
					local LPRealPos = lp.PlayerPos/Scale+lp.FloatPos/Scale
					local AimFace	= -CamData.angles:Forward()
					
					RSetMaterial(Clouds)
					for k,v in pairs(s.Clouds) do DrawQuadEasy(v.Pos,AimFace,v.Size,v.Size,v.Col,v.Yaw) end
					
					RSetMaterial(matLight)
					
					for k,v in pairs(GAMEMODE.SolarSystems) do 
						DV2P.OFF.RunFunction( "Pre_OpenMap_Render3D_System", CamData, v, Scale )
						local SunRealPos = v.Pos/Scale
						v.SPos = SunRealPos:ToScreen() 
						--DrawQuadEasy(SunRealPos,AimFace,50,50,v.Color,0)
						DrawQuadEasy(SunRealPos,AimFace,5,5,v.TechColor,0)
						
						if (input.IsMouseInBox(v.SPos.x-14,v.SPos.y-14,28,28) and Reg!=v.Name and !MouseInList) then Hover = k end
						
						if (v.Owner) then
							if (!FactControls[v.Owner]) then FactControls[v.Owner] = {} end
							insert(FactControls[v.Owner],v.Pos)
							
							local Col = GetFactionColor(v.Owner)
							Col.a = 20
							
							RSetMaterial(Bare)
							render.DrawSphere( SunRealPos, 30, 32, 32, Col )
							RSetMaterial(matLight)
						end
						
						if (v.Connected) then
							RSetMaterial(Bare)
							for k2,CPos in pairs(v.Connected) do
								RDrawBeam( SunRealPos, CPos/Scale, 1, 0,1,LineC )
							end
							RSetMaterial(matLight)
						end
						DV2P.OFF.RunFunction( "Post_OpenMap_Render3D_System", CamData, v, Scale )
					end 
					
					for faction,Controls in pairs(FactControls) do
						local Sum = Zero
						
						for i,pos in pairs(Controls) do
							Sum = Sum+pos
						end
						
						local Avg = Sum/#Controls
						
						FactControls[faction] = (Avg/Scale):ToScreen()
					end
					
					lp.SPos = LPRealPos:ToScreen()
					
					if (lp.WarpDest) then
						lp.WarpSPos = (lp.WarpDest/Scale+lp.WarpDestDetail/Scale):ToScreen()
					end
					
					RSetMaterial(Bare)
					render.DrawSphere( LPRealPos, Radius, 32, 32, WarpCol )
					render.DrawWireframeSphere( LPRealPos, Radius, 32, 32, WarpCol )
					
					OriginSPos = Zero:ToScreen()
					DV2P.OFF.RunFunction( "Post_OpenMap_Render3D_SystemMap", CamData, Scale )
				end
				DV2P.OFF.RunFunction( "Post_OpenMap_Render3D", CamData )
			cam.End()
			
			if (LocalMap and Reg != "Space") then
				for k,v in pairs(GAMEMODE.MapEnts) do
					if (table.HasValue(DisplayTable,v.Class)) then
						DrawOutlinedRect(v.SPos.x-1,v.SPos.y-1,2,2,MAIN_WHITECOLOR)
						DrawText(v.Class.." "..k,"DVTextSmall",v.SPos.x,v.SPos.y-20,MAIN_TEXTCOLOR,1)
						if (input.IsMouseInBox(v.SPos.x-14,v.SPos.y-14,28,28) and (v.Pos-lp.PlayerPos-lp.FloatPos):Length() > 5000) then HoverEntity = k Hover = ID end
					end
				end
				
				DrawText(GAMEMODE.SolarSystems[ID].Name,"DVText",ScrW()/2,80,MAIN_TEXTCOLOR,1)
			else
				--System List
				local FT = 0.001*(UnPredictedCurTime()-FT)
				local C = (1+math.cos(CurTime()*3))/2
				local Scale = MAIN_MAP_SIZE/2500
				
				for faction,Pops in pairs(FactControls) do
					local Col = GetFactionColor(faction)
					Col.a = 20
					
					DrawText(faction,"DVText",Pops.x,Pops.y,Col,1) 
				end
				
				for k,v in pairs(GAMEMODE.SolarSystems) do
					if (v.SPos.visible) then
						local Siz = 14
						
						if (MAP_Frame.Matches[k]) then
							DrawOutlinedRect(v.SPos.x-Siz-4*C,v.SPos.y-Siz-4*C,Siz*2+8*C,4+Siz*2+8*C,MAIN_COLOR)
						end
						
						if (Hover == k) then
							Blu.a = 255*(cos(CurTime()*4)+1)/2
						
							DrawRect(v.SPos.x-2-Siz,v.SPos.y-2-Siz,4+Siz*2,4+Siz*2,Blu)
							DrawOutlinedRect(v.SPos.x-2-Siz,v.SPos.y-2-Siz,4+Siz*2,4+Siz*2,MAIN_COLOR)
						end
						
						if (v.Tech <= MAIN_SAFEZONE_TECH) then 
							if (MAP_Frame.bShowNames) then
								DrawText("(Safezone)","DefaultSmall",v.SPos.x,v.SPos.y-45,MAIN_GREENCOLOR,1)
								DrawText(v.Name,"DVTextTiny",v.SPos.x,v.SPos.y-30,MAIN_GREENCOLOR,1)
							end
						else 
							local Dat = GetSystemWar(k)
							
							if (Dat) then
								local OldCol = table.Copy(MAIN_TEXTCOLOR)
								OldCol.r = MAIN_TEXTCOLOR.r+(255-MAIN_TEXTCOLOR.r)*C
								OldCol.g = MAIN_TEXTCOLOR.g-MAIN_TEXTCOLOR.g*C
								OldCol.b = MAIN_TEXTCOLOR.b-MAIN_TEXTCOLOR.b*C
								
								local YPos = v.SPos.y-80
								
								DrawText(string.NiceTime(MAIN_FACTIONWAR_TIME-Dat.Ticker),"DefaultSmall",v.SPos.x,YPos,MAIN_TEXTCOLOR,1) 
								DrawText(Dat.Attacker.." VS "..Dat.Defender,"DVTextTiny",v.SPos.x,YPos+10,OldCol,1) 
								
								local Prog = Dat.Points/MAIN_FACTIONWAR_BALANCEPOINT
								
								DrawRect(v.SPos.x-50,YPos+30,100,5,MAIN_BLACKCOLOR)
								DrawRect(v.SPos.x-50,YPos+30,50,5,MAIN_REDCOLOR)
								DrawRect(v.SPos.x,YPos+30,50,5,MAIN_BLUECOLOR)
								
								DrawOutlinedRect(v.SPos.x-50,YPos+30,100,5,MAIN_GUICOLOR)
								
								DrawLine(v.SPos.x-50+100*Prog,YPos+20,v.SPos.x-50+100*Prog,YPos+35,MAIN_YELLOWCOLOR)
								DrawText(Dat.Points.."/"..(MAIN_FACTIONWAR_BALANCEPOINT-Dat.Points),"DefaultSmall",v.SPos.x,YPos+20,MAIN_TEXTCOLOR,1)
								
								DrawText(v.Name.." (Warzone)","DVTextTiny",v.SPos.x,v.SPos.y-30,OldCol,1)  
							else
								if (MAP_Frame.bShowNames) then
									if (v.Owner) then
										local Col = GetFactionColor(v.Owner)
										Col.a = 250
										
										DrawText(v.Name,"DVTextTiny",v.SPos.x,v.SPos.y-30,Col,1) 
									else
										DrawText(v.Name,"DVTextTiny",v.SPos.x,v.SPos.y-30,MAIN_TEXTCOLOR,1) 
									end
								end
							end
						end
					end
				end 
				
				if (OriginSPos) then
					local A = MAIN_TEXTCOLOR.a*1
					
					MAIN_TEXTCOLOR.a = 10
					DrawText("Devinity","DVTextLarge",OriginSPos.x,OriginSPos.y,MAIN_TEXTCOLOR,1)
					MAIN_TEXTCOLOR.a = A
				end
				
				FT = UnPredictedCurTime()
			end 
			
			if (lp.WarpDest and lp.WarpSPos) then
				DrawLine(lp.SPos.x,lp.SPos.y,lp.WarpSPos.x,lp.WarpSPos.y,MAIN_BLUECOLOR)
				DrawOutlinedRect(lp.WarpSPos.x-2,lp.WarpSPos.y-2,4,4,MAIN_BLUECOLOR)
			end
			
			DrawOutlinedRect(lp.SPos.x-2,lp.SPos.y-2,4,4,MAIN_REDCOLOR)
			
			DrawText("You","DVTextSmall",lp.SPos.x+5,lp.SPos.y,MAIN_REDCOLOR)
			
			if (Hover > 0) then
				local System = GAMEMODE.SolarSystems[Hover] 
				
				if (Reg != "Space" and LocalMap) then 
					System = GAMEMODE.MapEnts[HoverEntity]
					
					DrawOutlinedRect(System.SPos.x-3,System.SPos.y-3,6,6,Cyan)
					DrawText("Warp to","DVTextTiny",System.SPos.x-30,System.SPos.y-2,Cyan,1)
					
					if (input.MousePress(MOUSE_LEFT,"MapMouse")) then
						LocalPlayer():SetWarpDestination(System.Pos,System.FloatPos)
					end
				else
					DrawText(System.Name,"DVTextTiny",System.SPos.x,System.SPos.y-30,MAIN_TEXTCOLOR,1) 
					DrawText("Jump to","DVTextTiny",System.SPos.x-50,System.SPos.y-2,Cyan,1)
					
					if (input.MousePress(MOUSE_LEFT,"MapMouse")) then
						LocalPlayer():SetWarpDestination(System.Pos,Zero)
					end
				end
			end
			DV2P.OFF.RunFunction( "Post_MAP_Frame_Paint", s, w, h )
		end
		
		local a = vgui.Create("MBButton",MAP_Frame)
		a:SetPos(MAP_Frame:GetWide()/2+60,5)
		a:SetSize(40,20)
		a:SetText("X")
		a.DoClick = function(s) MAP_Frame:SetVisible(false) end
		a.Paint = function(s,w,h)
			if (s.Hovered) then DrawText(s.Text,"Trebuchet18",w/2,h/2,MAIN_GREENCOLOR,1)
			else DrawText(s.Text,"Trebuchet18",w/2,h/2,MAIN_TEXTCOLOR,1) end
		end
		
		local a = vgui.Create("MBButton",MAP_Frame)
		a:SetPos(MAP_Frame:GetWide()/2-50,5)
		a:SetSize(100,20)
		a:SetText("Enter Local Map")
		a.DoClick = function(s) 
			local lp = LocalPlayer()
			if (!lp.PlayerPos or !lp.FloatPos) then return end
			
			LocalMap = !LocalMap 
			
			if (LocalMap) then Zoom = math.Clamp(Zoom,2,70) Origin = Zero*1 s.Text = "Exit Local Map"
			else Zoom = Zoom*10 s.Text = "Enter Local Map" end
		end
		a.Paint = function(s,w,h)
			if (s.Hovered) then DrawText(s.Text,"Trebuchet18",w/2,h/2,MAIN_GREENCOLOR,1)
			else DrawText(s.Text,"Trebuchet18",w/2,h/2,MAIN_TEXTCOLOR,1) end
		end
		
		local SearchPan = vgui.Create("DPanel",MAP_Frame)
		SearchPan:SetPos(5,5)
		SearchPan:SetSize(200,75)
		SearchPan.Paint = function(s,W,H)
			DrawDV2Button(0,0,W,H,8,MAIN_GUICOLOR,MAIN_BLACKCOLOR)
		end
		
		local sa = vgui.Create("DTextEntry",SearchPan)
		sa:SetText("Name of System")
		sa:SetPos(5,25)
		sa:SetSize(190,20)
		
		local bSa = vgui.Create("DVButton",SearchPan)
		bSa:SetPos(5,50)
		bSa:SetSize(190,20)
		bSa:SetText("Search")
		bSa.DoClick = function(s)
			MAP_Frame.Matches = {}
			for k,v in pairs(GAMEMODE.SolarSystems) do	
				if (v.Name:lower():find(sa:GetText():lower())) then
					MAP_Frame.Matches[k] = true
				end
			end
		end
		
		local a = vgui.Create("DCheckBoxLabel",SearchPan)
		a:SetPos(10,5)
		a:SetText("Display system names")
		a:SetChecked(MAP_Frame.bShowNames)
		a:SizeToContents()
		a.OnChange = function(s, v)
			MAP_Frame.bShowNames = s:GetChecked()
		end
	end
	
	MAP_Frame:SetVisible(true)

	DV2P.OFF.RunFunction( "Post_OpenMap" )
end























