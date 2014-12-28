local cBG			= Material("devinity2/hud/item_resources/bg_crafting.png")
local iBG			= Material("devinity2/hud/stuff.png")
local Grad			= surface.GetTextureID("gui/gradient_down")
local GradUp		= surface.GetTextureID("gui/gradient_up")
local Black			= Color(0,0,0,255)

function ReloadCraftingInventoryList()
	if (!StationMenu or !StationMenu.Crafting or !StationMenu.Crafting.List) then return end
	
	local A = StationMenu.Crafting.List
	
	A:Clear()
	
	for k,v in pairs(LocalPlayer():GetInventory()) do
		if (v.Data and v.Data.Material) then
			local a = A:Add("MBButton")
			a:SetSize(64,64)
			a:SetText("")
			a.ID = k
			a.Paint = function(s,w,h)
				DrawItemIcon(0,0,64,h,v.Data,v.Quantity, s)
				--[[DrawOutlinedRect(0,0,w,h,MAIN_GUICOLOR)
				
				if (s.Hovered) then DrawMaterialRect(0,0,64,h,MAIN_WHITECOLOR,v.Data.Rarity.Overlay)
				else DrawMaterialRect(0,0,64,h,MAIN_WHITECOLORT,v.Data.Rarity.Overlay) end
				
				if (v.Data.Icon) then DrawMaterialRect(0,0,64,h,MAIN_WHITECOLOR,v.Data.Icon) end
				
				DrawText("x"..v.Quantity,"DefaultSmall",2,h-15,MAIN_WHITECOLOR)
				DrawText("T: "..v.Data.Tech,"DefaultSmall",2,0,MAIN_WHITECOLOR)}]]--
			end
			a.DoClick = function(s)
				local X,Y = gui.MousePos()
				
				local menu = DermaMenu() 
				menu.Paint = function(s,w,h) DrawRect(0,0,w,h,MAIN_GUICOLOR) end

				for i=1, 10 do
					menu:AddOption( "Set Slot "..i, function() StationMenu.Crafting.CraftingList[i] = v.Data end ):SetColor(MAIN_TEXTCOLOR)
				end

				menu:Open()
				menu:SetPos(X,Y)
				
				surface.PlaySound("devinity2/ui/buttons/button_hover.wav")
			end
		end
	end
end

function OpenStation_Crafting(s) 
	local W = math.min(1024,StationMenu:GetWide()-340)+10
	local H = W/2+10
	
	if (!StationMenu.Crafting) then 
		StationMenu.Crafting = vgui.Create("MBFrame",StationMenu)
		StationMenu.Crafting:SetPos(math.max(320,ScrW()/2-W/2),ScrH()/2-H/2)
		StationMenu.Crafting:SetSize(W,H)
		StationMenu.Crafting:SetTitle("")
		StationMenu.Crafting:SetVisible(false)
		StationMenu.Crafting:ShowCloseButton(false)
		StationMenu.Crafting.Type = GetClasses()[1]
		StationMenu.Crafting.Paint = function(s,w,h) 
			DrawRect(0,0,w,h,Black)
			DrawOutlinedRect(0,0,w,h,MAIN_GUICOLOR)
			
			DrawMaterialRect(5,5,w-10,h-10,MAIN_WHITECOLOR,cBG)
			DrawOutlinedRect(5,5,w-10,h-10,MAIN_GUICOLOR)
			
			DrawText("Crafting","DVText",10,5,MAIN_TEXTCOLOR)
			
			local x,y = w/2,25
			local pl = LocalPlayer()
			
			for i = 0,9 do
				local X,Y = x-345+69*i,y+200
					
				DrawMaterialRect(X,Y,64,64,MAIN_WHITECOLOR,iBG)
				
				if (s.CraftingList) then
					local v = s.CraftingList[i+1]
					
					if (v and v.Rarity.Overlay) then
						DrawMaterialRect(X,Y,64,64,MAIN_WHITECOLOR,v.Rarity.Overlay)
						
						if (v.Icon) then
							local Count = pl:CountItems(v)
							local Conflicts = false
							
							for k = 1,4 do
								local b = s.CraftingList[k]
								
								if (k != i+1 and CompareItems(v,b)) then Conflicts = true break end
							end
							
							if (Conflicts) then
								DrawMaterialRect(X,Y,64,64,MAIN_REDCOLOR,v.Icon)
								DrawText("Conflicting","DefaultSmall",X+32,Y-25,MAIN_REDCOLOR,1)
							else
								if (Count >= 200) then DrawMaterialRect(X,Y,64,64,MAIN_WHITECOLOR,v.Icon)
								else 
									DrawMaterialRect(X,Y,64,64,MAIN_REDCOLOR,v.Icon)
									DrawText(Count.."/200","DefaultSmall",X+32,Y-25,MAIN_REDCOLOR,1)
								end
							end
						end
						
						DrawText(v.Name,"DefaultSmall",X+32,Y-10,MAIN_TEXTCOLOR,1)
					end
				end
			end
			
			local X,Y = x-32,y+30
			
			DrawMaterialRect(X,Y,64,64,MAIN_WHITECOLOR,iBG)
			
			if (s.CraftingList) then
				local Add = pl:GetSkillLevel("Crafting")^2
				local Data = CraftItem(s.CraftingList,Add)
				
				if (Data and Data.Rarity.Overlay) then
					DrawMaterialRect(X,Y,64,64,MAIN_WHITECOLOR,Data.Rarity.Overlay)
					
					if (Data.Icon) then DrawMaterialRect(X,Y,64,64,MAIN_WHITECOLOR,Data.Icon) end
					DrawText("Tech: "..(Data.Tech-Add).. " + "..(Add).." (Crafting)","DefaultSmall",X+66,Y,MAIN_TEXTCOLOR)
					DrawText("Price: GCS. "..Data.Price,"DefaultSmall",X+66,Y+15,MAIN_TEXTCOLOR)
					if (Data.Dmg) then DrawText("Damage: "..Data.Dmg,"DefaultSmall",X+66,Y+30,MAIN_TEXTCOLOR) end
					
					DrawText(Data.Name,"DefaultSmall",X+32,Y-10,MAIN_TEXTCOLOR,1)
				end
			end
		end
		
		table.insert(StationMenu.SubMenues,StationMenu.Crafting)
		
		local MW,MH = StationMenu.Crafting:GetWide(),StationMenu.Crafting:GetTall()
		
		local a = vgui.Create("MBButton",StationMenu.Crafting)
		a:SetPos(10,H/4*3-25)
		a:SetSize(120,20)
		a:SetText("")
		a.Paint = function(s,w,h)
			DrawRect(0,0,w,h,MAIN_BLACKCOLOR)
			
			if (s.Hovered) then DrawText("Clear","DVText",w/2,h/2,MAIN_YELLOWCOLOR,1)
			else DrawText("Clear","DVText",w/2,h/2,MAIN_TEXTCOLOR,1) end
		end
		a.DoClick = function(s)
			StationMenu.Crafting.CraftingList = {}
		end
		
		local a = vgui.Create("MBButton",StationMenu.Crafting)
		a:SetPos(135,H/4*3-25)
		a:SetSize(120,20)
		a:SetText("")
		a.Paint = function(s,w,h)
			DrawRect(0,0,w,h,MAIN_BLACKCOLOR)
			
			if (s.Hovered) then DrawText("Craft","DVText",w/2,h/2,MAIN_YELLOWCOLOR,1)
			else DrawText("Craft","DVText",w/2,h/2,MAIN_TEXTCOLOR,1) end
		end
		a.DoClick = function(s)
			if (StationMenu.Crafting.CraftingList) then
				RequestCraftItem(StationMenu.Crafting.CraftingList)
			end
		end

		local a = vgui.Create("MBButton",StationMenu.Crafting)
		a:SetPos(260,H/4*3-25)
		a:SetSize(120,20)
		a:SetText("")
		a.Paint = function(s,w,h)
			DrawRect(0,0,w,h,MAIN_BLACKCOLOR)
			
			if (s.Hovered) then DrawText("Craft All","DVText",w/2,h/2,MAIN_YELLOWCOLOR,1)
			else DrawText("Craft All","DVText",w/2,h/2,MAIN_TEXTCOLOR,1) end
		end
		a.DoClick = function(s)
			if (StationMenu.Crafting.CraftingList) then
				timer.Create( "DV2_AUTOCRAFT", 0.6, 0, function()
					if not StationMenu.Crafting.CraftingList or #StationMenu.Crafting.CraftingList == 0 then timer.Destroy("DV2_AUTOCRAFT") return end
					for k,v in pairs(LocalPlayer():GetInventory()) do if LocalPlayer():CountItems(v) >= 200 then timer.Destroy("DV2_AUTOCRAFT") return end end
					RequestCraftItem(StationMenu.Crafting.CraftingList)	
				end)
			end
		end

		local a = vgui.Create("MBButton",StationMenu.Crafting)
		a:SetPos(385,H/4*3-25)
		a:SetSize(120,20)
		a:SetText("")
		a.Paint = function(s,w,h)
			DrawRect(0,0,w,h,MAIN_BLACKCOLOR)
			
			if (s.Hovered) then DrawText("Cancel Crafting","DVText",w/2,h/2,MAIN_YELLOWCOLOR,1)
			else DrawText("Cancel Crafting","DVText",w/2,h/2,MAIN_TEXTCOLOR,1) end
		end
		a.DoClick = function(s)
			timer.Destroy("DV2_AUTOCRAFT")
		end

		local a = vgui.Create("MBButton",StationMenu.Crafting)
		a:SetPos(510,H/4*3-25)
		a:SetSize(120,20)
		a:SetText("")
		a.Paint = function(s,w,h)
			DrawRect(0,0,w,h,MAIN_BLACKCOLOR)
			
			if (s.Hovered) then DrawText("Set 10 Ores","DVText",w/2,h/2,MAIN_YELLOWCOLOR,1)
			else DrawText("Set 10 Ores","DVText",w/2,h/2,MAIN_TEXTCOLOR,1) end
		end
		a.DoClick = function(s)
			local ores = {}
			for k,v in pairs(LocalPlayer():GetInventory()) do
				if (v.Data and v.Data.Material) then
					ores[k] = v
				end
			end
			if table.Count(ores) > 10 then return end
			StationMenu.Crafting.CraftingList = {}
			for k,v in pairs(ores) do
				StationMenu.Crafting.CraftingList[#StationMenu.Crafting.CraftingList+1] = v.Data
			end
		end
		
		--Inventory
		StationMenu.Crafting.Pane2 = vgui.Create("DScrollPanel",StationMenu.Crafting)
		StationMenu.Crafting.Pane2:SetPos(10,H/4*3)
		StationMenu.Crafting.Pane2:SetSize(MW-20,H/4-10)
		StationMenu.Crafting.Pane2.Paint = function(s,w,h)
			DrawRect(0,0,w,h,MAIN_BLACKCOLOR)
		end
		
		StationMenu.Crafting.Pane2.VBar.Paint 			= function(s,w,h) DrawOutlinedRect( 0 , 0 , w , h , MAIN_GUICOLOR ) end
		StationMenu.Crafting.Pane2.VBar.btnGrip.Paint 	= function(s,w,h) DrawRect( 2 , 0 , w-4 , h , MAIN_GUICOLOR ) end
		StationMenu.Crafting.Pane2.VBar.btnDown.Paint 	= function(s,w,h) DrawRect( 2 , 2 , w-4 , h-4 , MAIN_GUICOLOR ) end
		StationMenu.Crafting.Pane2.VBar.btnUp.Paint 	= function(s,w,h) DrawRect( 2 , 2 , w-4 , h-4 , MAIN_GUICOLOR ) end
		
		local l = vgui.Create("DIconLayout",StationMenu.Crafting.Pane2)
		l:SetPos(5,5)
		l:SetSize(StationMenu.Crafting.Pane2:GetWide()-10,StationMenu.Crafting.Pane2:GetTall()-10)
		l:SetSpaceY(5)
		l:SetSpaceX(5)
		
		StationMenu.Crafting.List = l
		
		ReloadCraftingInventoryList()
	end
	
	StationMenu.Crafting.CraftingList = {}
	ReloadCraftingInventoryList()
	
	StationMenu.Crafting:SetVisible(true)
end