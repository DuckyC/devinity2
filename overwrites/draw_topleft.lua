local Mats = {
	Material("devinity2/hud/hudicons/diplomacy.png"),
	Material("devinity2/hud/hudicons/fleet.png"),
	Material("devinity2/hud/hudicons/friends.png"),
	Material("devinity2/hud/hudicons/mail.png"),
	Material("devinity2/hud/hudicons/options.png"),
	Material("devinity2/hud/hudicons/person.png")
}

local Menu_Fleet
local Menu_Skills

local SkillCol = Color(50,100,50,200)


local function DrawFleet()
	DrawMaterialRect(3,3,16,16,MAIN_BLACKCOLOR,Mats[2]) 
		
	if (input.IsMouseInBox(5,5,16,16)) then
		DrawMaterialRect(5,5,16,16,MAIN_GREENCOLOR,Mats[2]) 
		
		if (input.MousePress(MOUSE_LEFT,"OpenFleetMenu") and (!Menu_Fleet or !Menu_Fleet:IsVisible())) then
			if (!Menu_Fleet) then
				Menu_Fleet = vgui.Create("MBFrame")
				Menu_Fleet:SetPos(5,30)
				Menu_Fleet:SetSize(260,400)
				Menu_Fleet:SetTitle("")
				Menu_Fleet:SetVisible(false)
				Menu_Fleet:SetDeleteOnClose(false)
				Menu_Fleet:MakePopup()
				Menu_Fleet.Paint = function(s,w,h) 
					DrawRect(0,0,w,h,MAIN_BLACKCOLOR)
					DrawOutlinedRect(0,0,w,h,MAIN_GUICOLOR)
					DrawLine(0,22,w,22,MAIN_GUICOLOR)
					
					DrawText("Invite to fleet","DVTextSmall",w/2,11,MAIN_WHITECOLOR,1)
				end
				
				Menu_Fleet.Pane = vgui.Create("DScrollPanel",Menu_Fleet)
				Menu_Fleet.Pane:SetPos(5,25)
				Menu_Fleet.Pane:SetSize(250,345)
				Menu_Fleet.Pane.Paint = function(s,w,h)
					DrawOutlinedRect(0,0,w,h,MAIN_GUICOLOR)
				end
				
				local l = vgui.Create("DListLayout",Menu_Fleet.Pane)
				l:SetSize(Menu_Fleet.Pane:GetWide()-10,Menu_Fleet.Pane:GetTall()-10)
				l:SetPos(5,5)
				
				local ab = vgui.Create("MBButton",Menu_Fleet)
				ab:SetPos(5,375)
				ab:SetSize(250,20)
				ab:SetText("Leave current group")
				ab.DoClick = function()
					local mx,my = gui.MousePos()
					local menu = DermaMenu() 
					menu.Paint = function(s,w,h) DrawRect(0,0,w,h,MAIN_GUICOLOR) end
					menu:AddOption( "Confirm", function() RequestLeaveGroup() end ):SetColor(MAIN_TEXTCOLOR)
					menu:Open()
					menu:SetPos(mx,my)
				end
				ab.Paint = function(s,w,h)
					if (s.Hovered) then DrawRect(0,0,w,h,MAIN_GREENCOLOR) end
					
					DrawText(s.Text,"DVTextSmall",w/2,h/2,MAIN_TEXTCOLOR,1)
				end
				

				Menu_Fleet.List = l
			end
			
			Menu_Fleet.List:Clear()
			
			for k,v in pairs(player.GetAll()) do
				local ab = Menu_Fleet.List:Add("MBButton")
				ab:SetTall(20)
				ab:SetText(v:Nick())
				ab.DoClick = function()
					local mx,my = gui.MousePos()
					local menu = DermaMenu() 
					menu.Paint = function(s,w,h) DrawRect(0,0,w,h,MAIN_GUICOLOR) end
					menu:AddOption( "Invite player", function() RequestInvitePlayer(v) end ):SetColor(MAIN_TEXTCOLOR)
					menu:Open()
					menu:SetPos(mx,my)
				end
				ab.Paint = function(s,w,h)
					if (s.Hovered) then DrawRect(0,0,w,h,MAIN_GREENCOLOR) end
					
					DrawText(s.Text,"Trebuchet18",0,0,MAIN_TEXTCOLOR)
				end
			end
			
			Menu_Fleet:SetVisible(true)
		end
			
	else
		DrawMaterialRect(5,5,16,16,MAIN_WHITECOLOR,Mats[2]) 
	end
end

local function DrawSkills()
	DrawMaterialRect(19,3,16,16,MAIN_BLACKCOLOR,Mats[1]) 
	
	if (input.IsMouseInBox(21,5,16,16)) then
		DrawMaterialRect(21,5,16,16,MAIN_GREENCOLOR,Mats[1]) 
		
		if (input.MousePress(MOUSE_LEFT,"OpenFleetMenu") and (!Menu_Skills or !Menu_Skills:IsVisible())) then
			if (!Menu_Skills) then
				Menu_Skills = vgui.Create("MBFrame")
				Menu_Skills:SetPos(21,30)
				Menu_Skills:SetSize(360,400)
				Menu_Skills:SetTitle("")
				Menu_Skills:SetVisible(false)
				Menu_Skills:SetDeleteOnClose(false)
				Menu_Skills.Paint = function(s,w,h) 
					DrawRect(0,0,w,h,MAIN_BLACKCOLOR)
					DrawOutlinedRect(0,0,w,h,MAIN_GUICOLOR)
					DrawLine(0,22,w,22,MAIN_GUICOLOR)
					
					DrawText("Skills","DVTextSmall",w/2,11,MAIN_WHITECOLOR,1)
				end
				
				Menu_Skills.Pane = vgui.Create("DScrollPanel",Menu_Skills)
				Menu_Skills.Pane:SetPos(5,25)
				Menu_Skills.Pane:SetSize(350,370)
				Menu_Skills.Pane.Paint = function(s,w,h)
					DrawOutlinedRect(0,0,w,h,MAIN_GUICOLOR)
				end
				
				Menu_Skills.Pane.VBar.Paint 			= function(s,w,h)  end
				Menu_Skills.Pane.VBar.btnGrip.Paint 	= function(s,w,h) DrawRect( 2 , 0 , w-4 , h , MAIN_GUICOLOR ) end
				Menu_Skills.Pane.VBar.btnDown.Paint 	= function(s,w,h) DrawRect( 2 , 2 , w-4 , h-4 , MAIN_GUICOLOR ) end
				Menu_Skills.Pane.VBar.btnUp.Paint 		= function(s,w,h) DrawRect( 2 , 2 , w-4 , h-4 , MAIN_GUICOLOR ) end
				
				local l = vgui.Create("DListLayout",Menu_Skills.Pane)
				l:SetSize(Menu_Skills.Pane:GetWide()-10,Menu_Skills.Pane:GetTall()-10)
				l:SetPos(5,5)
				
				Menu_Skills.List = l
				
				local lp = LocalPlayer()
				
				for k,v in pairs(GetSkillsList()) do
					local ab = Menu_Skills.List:Add("Panel")
					ab:SetTall(30)
					ab:SetText("")
					ab.Paint = function(s,w,h)
						DrawDV2Box(0,0,w,h,130,MAIN_BLACKCOLOR,MAIN_GUICOLOR,8)
						DrawText(v,"Trebuchet18",9,0,MAIN_TEXTCOLOR)
						
						local SkillXP,SkillXPNeeded = lp:GetSkillXP(v), lp:GetSkillXPNeeded(v)
						local Level = lp:GetSkillLevel(v)
						
						local C = math.Clamp(SkillXP/SkillXPNeeded,0,1)
						
						DrawRect(20,16,(w-45)*C,10,SkillCol)
						DrawLine(w-25,16,w-25,26,SkillCol)
						DrawLine(20,16,20,26,SkillCol)
						
						DrawText(tostring(Level),"DefaultSmall",9,14,MAIN_TEXTCOLOR)
						DrawText(tostring(Level+1),"DefaultSmall",w-20,14,MAIN_TEXTCOLOR)
						DrawText(string.Comma(SkillXP).." / "..string.Comma(SkillXPNeeded).." ("..(math.floor(C*1000)/10).."%)","DefaultSmall",w/2,20,MAIN_TEXTCOLOR,1)
					end
				end
			end
			
			Menu_Skills:SetVisible(true)
		end
			
	else
		DrawMaterialRect(21,5,16,16,MAIN_WHITECOLOR,Mats[1]) 
	end
end
	

function DrawTopLeft()
	DrawFleet()
	DrawSkills()
end